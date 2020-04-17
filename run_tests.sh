#!/usr/bin/env bash
#
# Regenerates build files and runs tests on them.
# Please use this to validate your pull requests!
#

set -Eeuo pipefail

top="$(readlink -f "$(dirname "$0")")"

if [ "${IN_SHELL:-}" != "nix-cargo-index" -o "${IN_NIX_SHELL:-}" = "impure" ]; then
  echo -e "\e[1m=== Entering $top/shell.nix\e[0m" >&2
  exec nix-shell --pure "$top/shell.nix" --run "$(printf "%q " $0 "$@")"
fi

cd "$top"
echo -e "\e[1m=== Reformatting nix code\e[0m" >&2
./nixpkgs-fmt.sh \
    ./{,nix/,tests/}*.nix

echo -e "\e[1m=== Run nix unit tests\e[0m" >&2
nix-test tests
