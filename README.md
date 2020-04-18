[![tests-nix-linux](https://github.com/kolloch/nix-cargo-index/workflows/tests-nix-linux/badge.svg)](https://github.com/kolloch/nix-cargo-index/actions?query=workflow%3Atests-nix-linux)

# nix-cargo-index

This is a pure nix library for using a checked out cargo index, e.g. the
[crates.io index](https://github.com/rust-lang/crates.io-index). It does not use
import-from-derivation for parsing the index.

For example, you can search for a matching ripgrep version:

```
❯ nix repl ./cargo-index.nix
nix-repl> ripgrep = crateConfigForVersion { name = "ripgrep"; versionReq = "~12"; }

nix-repl> ripgrep.vers
"12.0.1"

nix-repl> builtins.head ripgrep.deps
{ default_features = true; features = [ ... ]; kind = "normal"; name = "bstr"; optional = false; req = "^0.2.12"; target = null; }
```

It also contains (incomplete) matching support for semver requirement strings
such as "1.2.x" and "^0.3":

```
❯ nix repl semver.nix
nix-repl> matcher = versionMatcher "1.3.x"

nix-repl> matcher "1.3.1"
true

nix-repl> matcher "1.4.1"
false
```

## Contributions

Contributions in the form of documentation and bug fixes are highly welcome.
Please start a discussion with me before working on larger features.

I'd really appreciate tests for all new features. Please run `./run_tests.sh`
before submitting a pull request.

Feature ideas are also welcome -- just know that this is a pure hobby side
project and I will not allocate a lot of bandwidth to this. Therefore, important
bug fixes are always prioritised.

By submitting a pull request, you agree to license your changes via all the
current licenses of the project.