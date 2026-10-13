{
  flake,
  pkgs,
  pname,
  ...
}:

let
  input = {
    hostToRedirectTo = "foo.example";
    redirects = {
      "old.example.com" = "test";
      "custom.local" = "test2";
    };
  };

  expectedOutput = {
    http = {
      routers = {
        "redirect-old-example-com" = {
          rule = "Host(`old.example.com`)";
          middlewares = [ "redirect-old-example-com" ];
          service = "noop@internal";
        };
        "redirect-custom-local" = {
          rule = "Host(`custom.local`)";
          middlewares = [ "redirect-custom-local" ];
          service = "noop@internal";
        };
      };
      middlewares = {
        "redirect-old-example-com".redirectRegex = {
          regex = "^\\S*?old\\.example\\.com(\\S*)$";
          replacement = "https://test.foo.example\${1}";
          permanent = true;
        };
        "redirect-custom-local".redirectRegex = {
          regex = "^\\S*?custom\\.local(\\S*)$";
          replacement = "https://test2.foo.example\${1}";
          permanent = true;
        };
      };
    };
  };
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
