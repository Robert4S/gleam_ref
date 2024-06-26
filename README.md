# ref

[![Package Version](https://img.shields.io/hexpm/v/ref)](https://hex.pm/packages/ref)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ref/)

```sh
gleam add ref
```
```gleam
import ref

pub fn main() {
  let myref = ref.cell(0)
  io.debug(ref.get(myref))
  // -> 0

  ref.set(myref, fn(a) { a + 1 })
  ref.set(myref, fn(a) { a + 1 })
  ref.set(myref, fn(a) { a + 1 })

  io.debug(ref.get(myref))
  // -> 3
}
```

Further documentation can be found at <https://hexdocs.pm/ref>.
