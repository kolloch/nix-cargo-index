{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, lib ? pkgs.lib
}:

rec {
  /* Returns a matcher that corresponds to the given version
     requirement.

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

    if requirement == "*"
    then version: true
    else builtins.throw "unrecognized version requirement";

  /*
  */
  VERSION_MATCH_OP = ''(\^|>=|<=|~|=)'';

  /* Matches version prefixes.
     Also matches other things but we assume well formed version requirements.
  */
  VERSION_PREFIX = ''(([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[-a-z.0-9_A-Z]+)?)'';

  internal = rec {
    firstMatch = regex: string:
      let
        match = builtins.match regex string;
      in
        if match != null
        then builtins.head match
        else null;
  };
}
