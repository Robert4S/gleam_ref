//// A ref cell library for the gleam erlang target. The implementation uses actors for keeping track of the values
//// of references, so a new process is spawned for each mutable reference you create. These mutable references should
//// only be used if mutability is absolutely required. Immutability should always be preferred, and this implementation loses
//// the performance benefits that mutability generally provide.

import gleam/erlang/process
import gleam/io
import gleam/otp/actor

pub fn main() {
  let myref = cell(0)
  io.debug(get(myref))
  // -> 0

  set(myref, fn(a) { a + 1 })
  set(myref, fn(a) { a + 1 })
  set(myref, fn(a) { a + 1 })

  io.debug(get(myref))
  // -> 3
}

type Msg(a) {
  Get(reply_with: process.Subject(a))
  Set(fn(a) -> a)
}

@external(javascript, "./ref_extern.mjs", "dummy")
fn handle_ref(msg: Msg(a), contents: a) -> actor.Next(Msg(a), a) {
  case msg {
    Get(client) -> {
      process.send(client, contents)
      actor.continue(contents)
    }
    Set(f) -> actor.continue(f(contents))
  }
}

/// The reference cell type for holding mutable data
pub opaque type RefCell(a) {
  Cell(state: process.Subject(Msg(a)))
}

/// Public constructor for creating a new RefCell. The initial value is passed, and a RefCell containing that value is returned.
@external(javascript, "./ref_extern.mjs", "cell")
pub fn cell(contents: a) -> RefCell(a) {
  let assert Ok(state) = actor.start(contents, handle_ref)
  Cell(state)
}

/// Used for extracting the held data in a RefCell.
/// Once the value has been extracted with this function, any mutations on the Cell will not affect the data already extracted.
@external(javascript, "./ref_extern.mjs", "get")
pub fn get(cell: RefCell(a)) -> a {
  actor.call(cell.state, Get(_), 100)
}

/// Pass a function that takes and returns the inner type of the RefCell, and set the contents of the cell to its return value
@external(javascript, "./ref_extern.mjs", "set")
pub fn set(cell: RefCell(a), operation: fn(a) -> a) -> Nil {
  actor.send(cell.state, Set(operation))
}

/// Map the result of a function taking a Cell's contents into a new RefCell. No mutation takes place
pub fn map(subj: RefCell(a), f: fn(a) -> b) -> RefCell(b) {
  subj
  |> get
  |> f
  |> cell
}
