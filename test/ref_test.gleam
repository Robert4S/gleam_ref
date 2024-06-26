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
  let state = ref.cell([])
  {
    use i <- loop(list.range(0, 10_000))
    case i % 2 {
      0 -> ref.set(state, fn(a) { [i, ..a] })
      _ -> Nil
    }
  }
  state
  |> ref.get
  |> list.reverse
  |> should.equal(list.range(0, 10_000) |> list.filter(fn(a) { a % 2 == 0 }))
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

pub fn concurrent_test() {
  let state = ref.cell(0)
  {
    use i <- loop(list.range(0, 10_000))
    process.start(fn() { ref.set(state, fn(a) { i + a }) }, True)
  }

  process.sleep(1)

  state
  |> ref.get
  |> should.equal(list.fold(list.range(0, 10_000), 0, fn(a, b) { a + b }))
}

pub fn get_is_constant_test() {
  let state = ref.cell(10)
  let ten = ref.get(state)
  ref.set(state, fn(_a) { 1 })
  state
  |> ref.get
  |> should.not_equal(ten)
}
