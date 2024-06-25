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
    ref.set(state, ref.get(state) * i)
  }
  ref.get(state)
  |> should.equal(6_227_020_800)
}

pub fn imperative_filter_test() {
  let state = ref.cell([])
  {
    use i <- loop(list.range(0, 10_000))
    case i % 2 == 0 {
      True -> ref.set(state, [i, ..ref.get(state)])
      False -> Nil
    }
  }
  state
  |> ref.get
  |> list.reverse
  |> should.equal(list.range(0, 10_000) |> list.filter(fn(a) { a % 2 == 0 }))
}
