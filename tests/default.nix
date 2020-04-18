let
  sources = import ../nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs {};
  lib = pkgs.lib;
  crate2nix = pkgs.callPackage ../default.nix {};
  testFiles = [ "semver" "lines" "cargo-index" ];
  testsInFile = f:
    let
      tests = import (./. + "/${f}.nix");
      prefixedTests = lib.mapAttrs' (n: v: lib.nameValuePair "${n} in ${f}.nix" (if builtins.isAttrs v then v else {})) tests;
    in
      assert builtins.isAttrs prefixedTests;

      prefixedTests;

  all = lib.foldl (cum: f: cum // (testsInFile f)) {} testFiles;
in
all
