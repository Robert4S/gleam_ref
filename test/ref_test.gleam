import gleam/erlang/process
import gleam/list
import gleeunit
import gleeunit/should
import ref

pub fn main() {
  gleeunit.main()
}

fn loop(for: List(a), f: fn(a) -> b) {
  case for {
    [] -> Nil
    [x, ..xs] -> {
      f(x)
      loop(xs, f)
    }
  }
}

pub fn factorial_test() {
  let state = ref.cell(1)
  {
    use i <- loop(list.range(1, 20))
    use curr <- ref.set(state)
    curr * i
  }
  ref.get(state)
  |> should.equal(2_432_902_008_176_640_000)
}

pub fn imperative_filter_test() {
  let evens = list.filter(_, fn(a) { a % 2 == 0 })

  let state = ref.cell([])
  {
    use i <- loop(list.range(0, 10_000))
    case i % 2 {
      0 -> {
        ref.set(state, fn(a) { [i, ..a] })
        Nil
      }
      _ -> Nil
    }
  }
  state
  |> ref.get
  |> list.reverse
  |> should.equal(list.range(0, 10_000) |> evens)
}

pub fn set_function_test() {
  let add = fn(a, b) { a + b }

  let state = ref.cell(list.range(0, 100))
  {
    use ls <- ref.set(state)
    ls
    |> list.map(add(_, 1))
  }

  state
  |> ref.get
  |> should.equal(list.range(0, 100) |> list.map(add(_, 1)))
}

@target(erlang)
pub fn concurrent_test() {
  let sum = list.fold(_, 0, fn(a, b) { a + b })

  let state = ref.cell(0)
  {
    use i <- loop(list.range(0, 100_000))
    process.start(fn() { ref.set(state, fn(a) { i + a }) }, True)
  }

  process.sleep(1)

  state
  |> ref.get
  |> should.equal(sum(list.range(0, 100_000)))
}

pub fn get_does_not_get_mutated_test() {
  let state = ref.cell(10)
  let ten = ref.get(state)
  ref.set(state, fn(_) { 1 })
  state
  |> ref.get
  |> should.not_equal(ten)
}

pub fn proper_updated_value_is_returned() {
  let state = ref.cell(list.range(0, 10))
  let newls = {
    use ls <- ref.set(state)
    list.map(ls, fn(a) { a * 2 })
  }

  state
  |> ref.get
  |> should.equal(newls)
}

pub fn killed_actor_should_error_test() {
  let state = ref.cell(0)
  ref.kill(state)
  ref.try_get(state)
  |> should.be_error
}
