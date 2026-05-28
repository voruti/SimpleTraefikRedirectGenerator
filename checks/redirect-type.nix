{
  flake,
  pkgs,
  pname,
  ...
}:

let
  typeToTest = flake.lib.types.redirect;
  assertValid =
    value:
    if
      (typeToTest.merge
        [ ]
        [
          {
            file = "";
            inherit value;
          }
        ]
      ) == value
    then
      ""
    else
      builtins.throw "Test failure";

  basicExample = {
    old = "old.example.com";
    subdomain = "test";
  };
  withSeparators = {
    old = "old-foo-bar.example.com";
    subdomain = "test-foo-bar";
  };
  withNumbers = {
    old = "old123.example.com";
    subdomain = "test123";
  };
  hostAsOld = {
    old = "foo";
    subdomain = "bar";
  };

  assertInvalid =
    value:
    if
      (builtins.tryEval (
        (typeToTest.merge
          [ ]
          [
            {
              file = "";
              inherit value;
            }
          ]
        ) == value
      )).success == false
    then
      ""
    else
      builtins.throw "Test failure";

  subdomainWithDot = {
    old = "old.example.com";
    subdomain = "test.local";
  };
  uppercaseOld = {
    old = "OLD.example.com";
    subdomain = "test";
  };
  uppercaseSubdomain = {
    old = "old.example.com";
    subdomain = "TEST";
  };
in

(pkgs.runCommand pname { } ''
  ${assertValid basicExample}
  ${assertValid withSeparators}
  ${assertValid withNumbers}
  ${assertValid hostAsOld}

  ${assertInvalid subdomainWithDot}
  ${assertInvalid uppercaseOld}
  ${assertInvalid uppercaseSubdomain}

  touch $out
'')
