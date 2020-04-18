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

  /* Returns nonEmpty lines from text. */
  lines = text:
    let
      split = builtins.split "\n" text;
    in
      builtins.filter (s: builtins.isString s && s != "") split;
}
