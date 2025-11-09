# Collection of personal Typst packages

This is a collection of personal [Typst](https://github.com/typst/typst) packages
that can be installed as a local package according to the method described in
[Typst packages](https://github.com/typst/packages).

To install, first install Typst following the instructions in the
[Typst repository](https://github.com/typst/typst) and then clone this project
while in the directory `{data-dir}/typst/packages/local`, where `{data-dir}` is

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

The packages can then be imported from within a `.typ` file by typing
`#import "@local/elias:{version}`, where `{version}` is any of the available
versions of this package at that time. For example `1.0.0`.

Packages in the data directory have precedence over ones in the cache directory.

Note that future iterations of Typst's package management may change/break this
local setup.
