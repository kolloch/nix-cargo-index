let
  sources = import ../nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { config = {}; };
  lib = pkgs.lib;
  cargoIndex = pkgs.callPackage ../cargo-index.nix {};
in
{
  test_crateConfig_crate2nix =
    let
      match = cargoIndex.crateConfigForVersion {
        name = "crate2nix";
        versionReq = "^0.8";
      };
    in {
      expr = if match == null then null else match.vers;
      expected = "0.8.0";
    };

  test_crateConfig_crate2nix_star_matches_no_prerelease =
    let
      match = cargoIndex.crateConfigForVersion {
        name = "nix-base32";
        versionReq = "*";
      };
    in {
      expr = if match == null then null else match.vers;
      # Annoyingly, we need to upate this to the latest
      # non-prerelease version.
      expected = "0.1.1";
    };

  test_crateConfig_no_yanked =
    let
      match = cargoIndex.crateConfigForVersion {
        name = "bmp388";
        versionReq = "=0.0.1";
      };
    in {
      expr = if match == null then null else match.vers;
      expected = null;
    };

  test_crateConfig_ripgrep =
    let
      match = cargoIndex.crateConfigForVersion {
        name = "ripgrep";
        versionReq = "~11";
      };
    in {
      expr = if match == null then null else match.vers;
      expected = "11.0.2";
    };

  test_cratePath_one = {
    expr = cargoIndex.cratePath "a";
    expected = "1/a";
  };
  test_cratePath_two = {
    expr = cargoIndex.cratePath "ab";
    expected = "2/ab";
  };
  test_cratePath_three = {
    expr = cargoIndex.cratePath "abc";
    expected = "3/a/abc";
  };
  test_cratePath_four = {
    expr = cargoIndex.cratePath "abcd";
    expected = "ab/cd/abcd";
  };
}
