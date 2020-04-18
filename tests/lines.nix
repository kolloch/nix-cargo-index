let
  sources = import ../nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { config = {}; };
  lib = pkgs.lib;
  lines = pkgs.callPackage ../lines.nix {};
in
{
  test_lines_empty = {
    expr = lines.lines "";
    expected = [];
  };

  test_lines_one = {
    expr = lines.lines "line 1";
    expected = [ "line 1" ];
  };

  test_lines_one_with_newline = {
    expr = lines.lines "line 1\n";
    expected = [ "line 1" ];
  };

  test_lines_seven = {
    expr = lines.lines "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\n";
    expected = [ "line 1" "line 2" "line 3" "line 4" "line 5" "line 6" "line 7" ];
  };

  test_lines_seven_without_final_newline = {
    expr = lines.lines "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7";
    expected = [ "line 1" "line 2" "line 3" "line 4" "line 5" "line 6" "line 7" ];
  };

  test_lines_eight = {
    expr = lines.lines "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8\n";
    expected = [ "line 1" "line 2" "line 3" "line 4" "line 5" "line 6" "line 7" "line 8" ];
  };

  test_lines_eight_without_final_newline = {
    expr = lines.lines "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8";
    expected = [ "line 1" "line 2" "line 3" "line 4" "line 5" "line 6" "line 7" "line 8" ];
  };
}
