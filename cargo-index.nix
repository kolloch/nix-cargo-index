{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { config = {}; }
, lib ? pkgs.lib
, cratesIoIndex ? sources."crates.io-index"
, semver ? pkgs.callPackage ./semver.nix {}
, lines ? pkgs.callPackage ./lines.nix {}
}:

rec {
  /* Returns all uploaded crateConfigs for the crate with the given name
     from the given checked out index.
  */
  crateConfigs = { name, index ? cratesIoIndex, ... }@args:
    let
      lines = crateConfigLines args;
      configs = builtins.map builtins.fromJSON lines;
    in builtins.sort (a: b: lib.versionOlder b.vers a.vers) configs;

  /* Returns a config that matches the given `versionReq` or `null`.

     Otherwise similar to `crateConfigs`.
  */
  crateConfigForVersion = { name, versionReq, index ? cratesIoIndex }@args:
    let
      configs = crateConfigs args;
      versionMatcher = semver.versionMatcher versionReq;
      matchPackage = pkg: versionMatcher pkg.vers;
      matchingPackages = builtins.filter matchPackage configs;
      firstMatch = builtins.head matchingPackages;
    in
      if matchingPackages != []
      then firstMatch
      else null;

  /* Returns the index sub path for the given crate name

     The corresponding cargo code looks like this:

     ```rust
     // See module comment in `registry/mod.rs` for why this is structured
     // the way it is.
     let fs_name = name
         .chars()
         .flat_map(|c| c.to_lowercase())
         .collect::<String>();
     let raw_path = match fs_name.len() {
         1 => format!("1/{}", fs_name),
         2 => format!("2/{}", fs_name),
         3 => format!("3/{}/{}", &fs_name[..1], fs_name),
         _ => format!("{}/{}/{}", &fs_name[0..2], &fs_name[2..4], fs_name),
     };
     ```
  */
  cratePath = name:
    let
      lower = lib.toLower name;
      len = builtins.stringLength lower;
    in
      assert len > 0;
      if len == 1
      then "1/${lower}"
      else if len == 2
      then "2/${lower}"
      else if len == 3
      then "3/${lower}"
      else "${builtins.substring 0 2 lower}/${builtins.substring 2 2 lower}/${lower}";

  crateConfigLines = { name, index ? cratesIoIndex, ... }:
    let
      config = builtins.readFile "${index}/${cratePath name}";
    in lines.lines config;

  inherit lib cratesIoIndex;
}
