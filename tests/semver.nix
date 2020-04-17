let
  sources = import ../nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { config = {}; };
  lib = pkgs.lib;
  semver = pkgs.callPackage ../semver.nix {};
  firstMatch = semver.internal.firstMatch;
  evalVersionTestCase = { req, version, ... }:
    let
      matcher = semver.versionRequirement req;
      match = matcher version;
    in
      assert builtins.isFunction matcher;
      assert builtins.isBool match;
      {
        inherit req version match;
      };
in
{
  test_wildcard_match = rec {
    matched = [
      "1"
      "1.23"
      "0.1"
      "0.1.2-pre.0"
    ];

    expr = builtins.map (semver.versionRequirement "*") matched;
    expected = builtins.map (x: true) matched;
  };

  test_caret_match1 = rec {
    testCase = { req = "^1.0.2"; version = "1.1.2"; match = true; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_caret_match2 = rec {
    testCase = { req = "^1.0.2"; version = "2.1.2"; match = false; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_caret_match3 = rec {
    testCase = { req = "^1.0"; version = "1.0.2"; match = true; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_caret_match4 = rec {
    testCase = { req = "^1"; version = "1.0.2"; match = true; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_caret_match5 = rec {
    testCase = { req = "^1.0.2"; version = "1.0.2"; match = true; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_caret_match_minor = rec {
    testCase = { req = "^0.1.2"; version = "0.1.3"; match = true; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_caret_match_minor2 = rec {
    testCase = { req = "^0.1.2"; version = "0.2.3"; match = false; };
    expr = evalVersionTestCase testCase;
    expected = testCase;
  };

  test_matchAndRest_up = {
    expr = semver.internal.matchAndRest semver.VERSION_MATCH_OP "^1.2";
    expected = { match = "^"; rest = "1.2"; };
  };

  test_matchAndRest_tilde = {
    expr = semver.internal.matchAndRest semver.VERSION_MATCH_OP "~1.2";
    expected = { match = "~"; rest = "1.2"; };
  };

  test_VERSION_PREFIX_matches = rec {
    recognized = [
      "1"
      "1.23"
      "0.1"
      "0.1.2-pre.0"
    ];

    expr = builtins.map (firstMatch semver.VERSION_PREFIX) recognized;
    expected = recognized;
  };

  test_VERSION_PREFIX_nomatch = rec {
    unrecognized = [
      "x"
      ">"
      "~"
    ];

    expr = builtins.map (firstMatch semver.VERSION_PREFIX) unrecognized;
    expected = builtins.map (x: null) unrecognized;
  };

  test_VERSION_MATCH_OP_matches = rec {
    recognized = [
      "^"
      ">="
      "<="
      "~"
      "="
    ];

    expr = builtins.map (firstMatch semver.VERSION_MATCH_OP) recognized;
    expected = recognized;
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
