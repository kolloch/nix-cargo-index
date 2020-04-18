let
  sources = import ../nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { config = {}; };
  lib = pkgs.lib;
  semver = pkgs.callPackage ../semver.nix {
    # Non-fatal errors.
    error = message: replacement: builtins.trace message replacement;
  };
  firstMatch = semver.internal.firstMatch;
  evalVersionTestCase = { req, version, match } @ expected:
    let
      matcher = semver.versionMatcher req;
      match = matcher version;
    in
      assert builtins.isFunction matcher;
      assert builtins.isBool match;
      {
        inherit expected;
        expr = {
          inherit req version match;
        };
      };
in
{
  test_wildcard_match = rec {
    matched = [
      "1"
      "1.23"
      "0.1"
    ];

    expr = builtins.map (semver.versionMatcher "*") matched;
    expected = builtins.map (x: true) matched;
  };

  test_wildcard_match_no_prerelease = evalVersionTestCase {
    req = "*";
    version = "1.7.4-alpha.0";
    match = false;
  };

  test_xrange_patch_match = evalVersionTestCase {
    req = "1.7.x";
    version = "1.7.4";
    match = true;
  };

  test_xrange_patch_nomatch = evalVersionTestCase {
    req = "1.7.x";
    version = "1.8.4";
    match = false;
  };

  test_xrange_prerelease_nomatch2 = evalVersionTestCase {
    req = "1.7.x";
    version = "1.7.4-patch.3";
    match = false;
  };

  test_xrange_minor_match = evalVersionTestCase {
    req = "3.x";
    version = "3.4.5";
    match = true;
  };

  test_xrange_minor_nomatch = evalVersionTestCase {
    req = "3.x";
    version = "4.4.5";
    match = false;
  };

  test_VERSION_XRANGE_matches1 = rec {
    expr = semver.internal.matchAndRest semver.internal.VERSION_XRANGE "1.2.x";
    expected = { match = "1.2"; rest = ".x"; };
  };

  test_VERSION_XRANGE_matches2 = rec {
    expr = semver.internal.matchAndRest semver.internal.VERSION_XRANGE "1.x";
    expected = { match = "1"; rest = ".x"; };
  };

  test_caret_match1 = evalVersionTestCase {
    req = "^1.0.2";
    version = "1.1.2";
    match = true;
  };

  test_caret_match2 = evalVersionTestCase {
    req = "^1.0.2";
    version = "2.1.2";
    match = false;
  };

  test_caret_match3 = evalVersionTestCase {
    req = "^1.0";
    version = "1.0.2";
    match = true;
  };

  test_caret_match4 = evalVersionTestCase {
    req = "^1";
    version = "1.0.2";
    match = true;
  };

  test_caret_match5 = evalVersionTestCase {
    req = "^1.0.2";
    version = "1.0.2";
    match = true;
  };

  test_caret_match_minor = evalVersionTestCase {
    req = "^0.1.2";
    version = "0.1.3";
    match = true;
  };

  test_caret_match_minor2 = evalVersionTestCase {
    req = "^0.1.2";
    version = "0.2.3";
    match = false;
  };

  test_tilde_match1 = evalVersionTestCase {
    req = "~1.0.2";
    version = "1.1.2";
    match = false;
  };

  test_tilde_match1b = evalVersionTestCase {
    req = "~1.0.2";
    version = "1.0.1";
    match = false;
  };

  test_tilde_match2 = evalVersionTestCase {
    req = "~1.0.2";
    version = "2.1.2";
    match = false;
  };

  test_tilde_match3 = evalVersionTestCase {
    req = "~1.0";
    version = "1.0.2";
    match = true;
  };

  test_tilde_match4 = evalVersionTestCase {
    req = "~1";
    version = "1.33.2";
    match = true;
  };

  test_tilde_match5 = evalVersionTestCase {
    req = "~1.0.2";
    version = "1.0.2";
    match = true;
  };

  test_tilde_match_minor = evalVersionTestCase {
    req = "~0.1.2";
    version = "0.1.3";
    match = true;
  };

  test_tilde_match_minor2 = evalVersionTestCase {
    req = "~0.1.2";
    version = "0.1.1";
    match = false;
  };

  test_tilde_match_minor3 = evalVersionTestCase {
    req = "~0.1.2";
    version = "0.2.3";
    match = false;
  };

  test_matchAndRest_up = {
    expr = semver.internal.matchAndRest semver.internal.VERSION_MATCH_OP "^1.2";
    expected = { match = "^"; rest = "1.2"; };
  };

  test_matchAndRest_tilde = {
    expr = semver.internal.matchAndRest semver.internal.VERSION_MATCH_OP "~1.2";
    expected = { match = "~"; rest = "1.2"; };
  };

  test_VERSION_PREFIX_matches = rec {
    recognized = [
      "1"
      "1.23"
      "0.1"
      "0.1.2-pre.0"
    ];

    expr = builtins.map (firstMatch semver.internal.VERSION_PREFIX) recognized;
    expected = recognized;
  };

  test_VERSION_PREFIX_nomatch = rec {
    unrecognized = [
      "x"
      ">"
      "~"
    ];

    expr = builtins.map (firstMatch semver.internal.VERSION_PREFIX) unrecognized;
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

    expr = builtins.map (firstMatch semver.internal.VERSION_MATCH_OP) recognized;
    expected = recognized;
  };

  test_VERSION_MATCH_OP_nomatch = rec {
    unrecognized = [
      "x"
      "1"
      "1.2"
    ];

    expr = builtins.map (firstMatch semver.internal.VERSION_MATCH_OP) unrecognized;
    expected = builtins.map (x: null) unrecognized;
  };
}
