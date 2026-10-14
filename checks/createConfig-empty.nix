{
  flake,
  pkgs,
  pname,
  ...
}:

let
  input = {
    hostToRedirectTo = "foo.example";
    redirects = { };
  };

  expectedOutput = { };
in

(pkgs.runCommand pname { } ''
  ${
    let
      output = flake.lib.createConfig input;
    in
    if output != expectedOutput then throw ("Test failure: " + builtins.toJSON output) else ""
  }
  touch $out
'')
