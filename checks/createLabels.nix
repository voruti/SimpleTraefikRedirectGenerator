{
  flake,
  pkgs,
  pname,
  ...
}:

let
  input = {
    hostToRedirectTo = "foo.example";
    redirects = [
      {
        old = "old.example.com";
        subdomain = "test";
      }
      {
        old = "custom.local";
        subdomain = "test2";
      }
    ];
  };

  expectedOutput = {
    "traefik.http.routers.redirect-old-example-com.rule" = "Host(`old.example.com`)";
    "traefik.http.routers.redirect-old-example-com.middlewares" = "redirect-old-example-com";
    "traefik.http.routers.redirect-old-example-com.service" = "noop@internal";
    "traefik.http.middlewares.redirect-old-example-com.redirectregex.regex" =
      "^\\S*?old\\.example\\.com(\\S*)$$";
    "traefik.http.middlewares.redirect-old-example-com.redirectregex.replacement" =
      "https://test.foo.example$\${1}";
    "traefik.http.middlewares.redirect-old-example-com.redirectregex.permanent" = true;

    "traefik.http.routers.redirect-custom-local.rule" = "Host(`custom.local`)";
    "traefik.http.routers.redirect-custom-local.middlewares" = "redirect-custom-local";
    "traefik.http.routers.redirect-custom-local.service" = "noop@internal";
    "traefik.http.middlewares.redirect-custom-local.redirectregex.regex" =
      "^\\S*?custom\\.local(\\S*)$$";
    "traefik.http.middlewares.redirect-custom-local.redirectregex.replacement" =
      "https://test2.foo.example$\${1}";
    "traefik.http.middlewares.redirect-custom-local.redirectregex.permanent" = true;
  };
in

(pkgs.runCommand pname { } ''
  ${if flake.lib.createLabels input != expectedOutput then builtins.throw "Test failure" else ""}
  touch $out
'')
