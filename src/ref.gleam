//// A ref cell library for gleam. The implementation uses actors on the erlang target for keeping track of the values
//// of references, so a new process is spawned for each mutable reference you create. These mutable references should
//// only be used if mutability is absolutely required. Immutability should always be preferred, 
//// and this implementation loses the performance benefits that mutability generally provides.

import gleam/erlang/process.{type CallError}
import gleam/otp/actor

type Msg(a) {
  Get(reply_with: process.Subject(a))
  Set(fn(a) -> a, process.Subject(a))
  ShutDown
}

@external(javascript, "./ref_extern.mjs", "dummy")
fn handle_ref(msg: Msg(a), contents: a) -> actor.Next(Msg(a), a) {
  case msg {
    Get(client) -> {
      process.send(client, contents)
      actor.continue(contents)
    }
    Set(f, client) -> {
      let new_contents = f(contents)
      process.send(client, new_contents)
      actor.continue(new_contents)
    }
    ShutDown -> actor.Stop(process.Normal)
  }
}

/// The reference cell type for holding mutable data
pub opaque type RefCell(a) {
  Cell(state: process.Subject(Msg(a)))
}

/// Public constructor for creating a new RefCell. The initial value is passed, and a RefCell containing that value is returned.
/// # Examples
/// ```gleam
/// let immutable_value: List(Int) = [1, 2, 3, 4]
/// let mutable_copy: RefCell(List(Int)) = ref.cell(immutable_value)
/// ```
@external(javascript, "./ref_extern.mjs", "cell")
pub fn cell(contents: a) -> RefCell(a) {
  let assert Ok(state) = actor.start(contents, handle_ref)
  Cell(state)
}

/// Used for extracting the held data in a RefCell.
/// Once the value has been extracted with this function, any mutations on the Cell will not affect the data already extracted.
/// On erlang, this may panic if the actor is dead. If you want to return a result instead, use try_get. On javascript, get should always be used.
/// # Examples
/// ```gleam
/// let state = ref.cell(20)
/// ref.get(state) |> io.debug
/// // > 20
/// ref.set(state, fn(a) { a + 5 })
/// ref.get(state) |> io.debug
/// // > 25
/// ```
@external(javascript, "./ref_extern.mjs", "get")
pub fn get(cell: RefCell(a)) -> a {
  process.call(cell.state, Get(_), 1000)
}

/// Similar to ref.get, but will return a result instead of panicking if the actor is dead.
/// # Examples
/// ```gleam
/// let state = ref.cell(20)
/// ref.try_get(state) |> io.debug
/// // > Ok(20)
/// ref.set(state, fn(a) { a + 5 })
/// ref.try_get(state) |> io.debug
/// // > Ok(25)
/// ref.kill(state)
/// ref.try_get(state) |> io.debug
/// // > Error(_)
/// ```
@external(javascript, "./ref_extern.mjs", "try_get")
pub fn try_get(cell: RefCell(a)) -> Result(a, CallError(a)) {
  process.try_call(cell.state, Get(_), 1000)
}

/// Pass a function that takes and returns the inner type of the RefCell, and set the contents of the cell to its return value
/// # Examples
/// ```gleam
/// let state = ref.cell([1, 2, 3])
/// ref.set(state, fn(a) { list.map(a, fn(b) { b + 1 }) })
/// // or
/// use ls <- ref.set(state)
/// list.map(ls, fn(a) { a + 1 })
/// // state -> RefCell([2, 3, 4])
/// ```
@external(javascript, "./ref_extern.mjs", "set")
pub fn set(cell: RefCell(a), operation: fn(a) -> a) -> a {
  actor.call(cell.state, Set(operation, _), 1000)
}

/// On erlang, this will shut down the underlying actor holding the state of a RefCell. On javascript, this will do nothing,
/// # Examples
/// ```gleam
/// let state = ref.cell([1, 2, 3])
/// ref.kill(state)
/// ref.try_get(state) |> io.debug
/// // > Error(_)
/// ```
@external(javascript, "./ref_extern.mjs", "kill_ref")
pub fn kill(cell: RefCell(a)) -> Nil {
  actor.send(cell.state, ShutDown)
}

/// Map the result of a function taking a Cell's contents into a new RefCell. No mutation takes place
pub fn map(subj: RefCell(a), f: fn(a) -> b) -> RefCell(b) {
  subj
  |> get
  |> f
  |> cell
}
