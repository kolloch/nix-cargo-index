{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, lib ? pkgs.lib
, error ? message: replacement: builtins.throw message
}:

rec {
  /* Returns a matcher that corresponds to the given version
     requirement.

     Incomplete implementation of some of https://www.npmjs.com/package/semver.

     Usage:
       let matcher = versionMatcher requirement;
       in matcher version; // => true or false

     Type: versionMatcher :: string -> string -> bool

     Example:
       versionMatcher "*" "1.2.0"
       => true
       versionMatcher "^1" "1.2.0"
       => true
       versionMatcher "~1" "1.2.0"
       => true
       versionMatcher "=1.2.0" "1.2.0"
       => true
       versionMatcher "1.x" "1.2.3"
       => true
  */
  versionMatcher = requirement:
    assert builtins.isString requirement;
    let
      xrange =
        internal.matchAndRest
          internal.VERSION_XRANGE
          requirement;
      op =
        internal.matchAndRest
          internal.VERSION_MATCH_OP
          requirement;
      versionPrefix =
        internal.matchAndRest
          internal.VERSION_PREFIX
          op.rest;
    in
      if requirement == "*"
      then version: true
      else if xrange ? match
      then internal.xrangeMatch xrange
      else if !(op ? match)
      then
        error
          "unrecognized version requirement, no op found: ${requirement}"
          (version: false)
      else if versionPrefix.rest != ""
      then error
        "unrecognized version requirement, string after versionPrefix: ${versionPrefix.rest}"
        (version: false)
      else if op.match == "^"
      then internal.caretMatch versionPrefix.match
      else if op.match == "~"
      then internal.tildeMatch versionPrefix.match
      else if op.match == "="
      then version: versionPrefix.match == version
      else if op.match == ">="
      then version: (builtins.compareVersions versionPrefix.match version) <= 0
      else if op.match == "<="
      then version: 0 < (builtins.compareVersions versionPrefix.match version)
      else error
        "unrecognized version requirement, op.match ${op.match}: ${requirement}" (version: false);

  internal = rec {
    /* Matches a unary operator in front of a version (prefix).
    */
    VERSION_MATCH_OP = ''(\^|>=|<=|~|=)'';

    /* Matches version prefixes or full versions.
      Also matches other things but we assume well formed version requirements.
    */
    VERSION_PREFIX = ''(([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[-a-z.0-9_A-Z]+)?)'';

    /* Matches version specs like 1.2.x or 1.x. */
    VERSION_XRANGE = ''(([0-9]+)(\.[0-9]+)?)\.x'';

    /*
      Matches a version spec matched with VERSION_XRANGE.

      Type: { match, rest } -> string -> bool
    */
    xrangeMatch = { match, rest }:
      if rest != ".x"
      then error
        "unrecognized version requirement, string after xrange: ${builtins.substring 2 100 rest}"
        (version: false)
      else
        version:
          assert builtins.isString version;
          let
            versionMatch = builtins.match VERSION_PREFIX version;
            hasPrerelease = (builtins.elemAt versionMatch 4) != null;
          in
            lib.hasPrefix "${match}." version && !hasPrerelease;

    /*
      Matches the given version `prefix` (e.g. "1.2") against the given
      `version` (e.g. 1.2.3) with semver "^prefix" semantics.
    */
    caretMatch = prefix: version:
      assert builtins.isString version;
      let
        match = builtins.match VERSION_PREFIX prefix;
        major = builtins.elemAt match 1;
        majorInt = lib.toInt major;
        nextMajor = builtins.toString (majorInt + 1);
        minor = builtins.substring 1 100 (builtins.elemAt match 2);
        minorInt = lib.toInt minor;
        nextMinor = builtins.toString (minorInt + 1);
        versionCmp = builtins.compareVersions prefix version;
      in
        if versionCmp == 1
        then false
        else if versionCmp == 0
        then true
        else if major != "0"
        then (builtins.compareVersions version nextMajor) < 0
        else (builtins.compareVersions version "0.${nextMinor}") < 0;

    /*
      Matches the given version `prefix` (e.g. "1.2") against the given
      `version` (e.g. 1.2.3) with semver "~prefix" semantics.
    */
    tildeMatch = prefix: version:
      assert builtins.isString version;
      let
        match = builtins.match VERSION_PREFIX prefix;
        major = builtins.elemAt match 1;
        majorInt = lib.toInt major;
        nextMajor = builtins.toString (majorInt + 1);
        dotMinor = builtins.elemAt match 2;
        minor = builtins.substring 1 100 dotMinor;
        minorInt = lib.toInt minor;
        nextMinor = builtins.toString (minorInt + 1);
        versionCmp = builtins.compareVersions prefix version;
      in
        if versionCmp == 1
        then false
        else if versionCmp == 0
        then true
        else if dotMinor != null
        then (builtins.compareVersions version "${major}.${nextMinor}") < 0
        else (builtins.compareVersions version nextMajor) < 0;

    /* Returns first match item returned by `builtins.match` or `null`.

       Type: string -> string -> string | null
    */
    firstMatch = regex: string:
      let
        match = builtins.match regex string;
      in
        if match != null
        then builtins.head match
        else null;

    /* Matches regex against a prefix of `string` and returns the match and
       the rest of the string.

       If the regex does not match, it returns an empty attrset.

       Type: string -> string -> { match?, rest? }
    */
    matchAndRest = regex: string:
      assert builtins.isString regex;
      assert builtins.isString string;
      let
        match = firstMatch "${regex}.*" string;
        matchLen = builtins.stringLength match;
        len = builtins.stringLength string;
        rest = builtins.substring matchLen len string;
      in
        if match != null
        then
          assert builtins.isString match;
          assert builtins.isString rest;
          { inherit match rest; }
        else {};
  };
}
