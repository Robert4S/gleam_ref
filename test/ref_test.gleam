import gleam/list
import gleeunit
import gleeunit/should
import ref

pub fn main() {
  gleeunit.main()
}

fn loop(for: List(a), f: fn(a) -> Nil) {
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
    use i <- loop(list.range(1, 13))
    ref.set(state, fn(a) { a * i })
  }
  ref.get(state)
  |> should.equal(6_227_020_800)
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
