{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, lib ? pkgs.lib
}:

rec {
  /* Returns a matcher that corresponds to the given version
     requirement.

     Rudimentary implementation of some of https://www.npmjs.com/package/semver.

     Type: string -> string -> bool
     Example:
       versionRequirement "*" "1.2.0"
       => true
       versionRequirement "^1" "1.2.0"
       => true
       versionRequirement "=1.2.0" "1.2.0"
       => true
  */
  versionRequirement = requirement:
    assert builtins.isString requirement;
    let
      op = internal.matchAndRest VERSION_MATCH_OP requirement;
      versionPrefix = internal.matchAndRest VERSION_PREFIX op.rest;
    in
      if requirement == "*"
      then version: true
      else if !(op ? match)
      then builtins.trace "unrecognized version requirement, no op found: ${requirement}" (version: false)
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
      else builtins.trace "unrecognized version requirement, op.match ${op.match}: ${requirement}" (version: false);

  /* Matches a unary operator in front of a version (prefix).
   */
  VERSION_MATCH_OP = ''(\^|>=|<=|~|=)'';

  /* Matches version prefixes.
     Also matches other things but we assume well formed version requirements.
  */
  VERSION_PREFIX = ''(([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[-a-z.0-9_A-Z]+)?)'';

  internal = rec {
    caretMatch = prefix: version:
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

    tildeMatch = prefix: version:
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

    firstMatch = regex: string:
      let
        match = builtins.match regex string;
      in
        if match != null
        then builtins.head match
        else null;

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
