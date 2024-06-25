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

pub fn incrementing_test() {
  let state = ref.cell(1)
  {
    use i <- loop(list.range(1, 10))
    ref.set(state, ref.get(state) * i)
  }
  ref.get(state)
  |> should.equal(3_628_800)
}
