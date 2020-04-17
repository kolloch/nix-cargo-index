{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {}
, sources ? import ./sources.nix
, crate2nix ? sources.crate2nix
, crate2nixTools ? pkgs.callPackage "${crate2nix}/tools.nix" {}
}:

{
  dev = {

    inherit (pkgs)
      nixpkgs-fmt jq
      nix
      git
      utillinux
      cacert
      ;

    nixTest = let
      cargoNix = crate2nixTools.appliedCargoNix rec {
        name = "nix-test-runner";
        src = sources."${name}";
      };
    in
      cargoNix.rootCrate.build;
  };
}
