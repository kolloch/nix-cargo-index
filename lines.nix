{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, lib ? pkgs.lib
, error ? message: replacement: builtins.throw message
}:

rec {
  /* Returns the first line from text. */
  firstLine = text:
    let
      m = builtins.match "([^\n]*\n).*" text;
    in if m == null then null else builtins.head m;

  lines = text:
    let
    some = internal.someLines text;
    in
    if text == ""
    then []
    else if some ? lines
    then
        some.lines ++ (lines some.rest)
    else [ text ];

  internal = {

    /* Returns some lines from text and the rest of the text. */
    someLines = text:
      let
        # As far as I can see, we cannot extract repeated matches except by repeating the regexp capture group.
        # We want to match multiple lines every go for efficiency.
        m = builtins.match "(([^\n]*\n)([^\n]*\n)?).*" text;
        lineMatches = builtins.tail m;
        len = builtins.stringLength (builtins.head m);
        rest = builtins.substring len (builtins.stringLength text) text;
      in
        if m == null
        then {}
        else {
          lines = builtins.filter (l: l != null) lineMatches;
          inherit rest;
        };

  };
}
