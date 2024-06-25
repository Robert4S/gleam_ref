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

  set(myref, get(myref) + 1)
  set(myref, get(myref) + 1)
  set(myref, get(myref) + 1)

  io.debug(get(myref))
  // -> 3
}

type Msg(a) {
  Get(reply_with: process.Subject(a))
  Set(a)
}

fn handle_ref(msg: Msg(a), contents: a) -> actor.Next(Msg(a), a) {
  case msg {
    Get(client) -> {
      process.send(client, contents)
      actor.continue(contents)
    }
    Set(a) -> actor.continue(a)
  }
}

/// The reference cell type for holding mutable data
pub opaque type RefCell(a) {
  Cell(state: process.Subject(Msg(a)))
}

/// Public constructor for creating a new RefCell. The initial value is passed, and a RefCell containing that value is returned.
pub fn cell(contents: a) {
  let assert Ok(state) = actor.start(contents, handle_ref)
  Cell(state)
}

/// Used for extracting the held data in a RefCell.
/// Once the value has been extracted with this function, any mutations on the Cell will not affect the data already extracted.
pub fn get(cell: RefCell(a)) {
  actor.call(cell.state, Get(_), 10)
}

/// Used for setting the inner value of a RefCell
pub fn set(cell: RefCell(a), contents: a) {
  actor.send(cell.state, Set(contents))
}
