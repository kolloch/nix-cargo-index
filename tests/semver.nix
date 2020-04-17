let
  sources = import ../nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { config = {}; };
  semver = pkgs.callPackage ../semver.nix {};
  firstMatch = semver.internal.firstMatch;
in
{
  test_VERSION_PREFIX_matches = rec {
    recognizedVersionPrefixes = [
      "1"
      "1.23"
      "0.1"
      "0.1.2-pre.0"
    ];

    expr = builtins.map (firstMatch semver.VERSION_PREFIX) recognizedVersionPrefixes;
    expected = recognizedVersionPrefixes;
  };

  test_VERSION_MATCH_OP_matches = rec {
    recognizedOps = [
      "^"
      ">="
      "<="
      "~"
      "="
    ];

    expr = builtins.map (firstMatch semver.VERSION_MATCH_OP) recognizedOps;
    expected = recognizedOps;
  };

  test_VERSION_MATCH_OP_nomatch = rec {
    unrecognized = [
      "x"
      "1"
      "1.2"
    ];

    expr = builtins.map (firstMatch semver.VERSION_MATCH_OP) unrecognized;
    expected = builtins.map (x: null) unrecognized;
  };
}
