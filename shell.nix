{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, dependencies ? pkgs.callPackage ./nix/dependencies.nix {}
, lib ? pkgs.lib
}:

pkgs.mkShell {
  buildInputs = lib.attrValues dependencies.dev;

  shellHook = ''
    export NIX_PATH="nixpkgs=${sources.nixpkgs}"
    export IN_SHELL="nix-cargo-index"
  '';
}
