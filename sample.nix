let func = { sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, lib ? pkgs.lib
, cargoIndex ? pkgs.callPackage ./cargo-index.nix {}
}:

let packages = [
    "bat"
    "exa"
    "fd"
    "hexyl"
    "lsd"
    "miniserve"
    "vivid"
    "ripgrep"
    ];
    packagesAndDeps = builtins.map (name: { inherit name; value = cargoIndex.transitiveCrateConfigs { inherit name; }; })
        packages;
in builtins.listToAttrs packagesAndDeps;

in func {}