# ref

[![Package Version](https://img.shields.io/hexpm/v/ref)](https://hex.pm/packages/ref)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ref/)

```sh
gleam add ref
```
```gleam
import ref

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
```

Further documentation can be found at <https://hexdocs.pm/ref>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
