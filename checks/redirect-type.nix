{
  flake,
  pkgs,
  pname,
  ...
}:

let
  typeToTest = flake.lib.types.redirects;
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
    "old.example.com" = "test";
  };
  multiple = {
    "old.example.com" = "test";
    "custom.local" = "test2";
  };
  withSeparators = {
    "old-foo-bar.example.com" = "test-foo-bar";
  };
  withNumbers = {
    "old123.example.com" = "test123";
  };
  hostAsOld = {
    "foo" = "bar";
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
    "old.example.com" = "test.local";
  };
  uppercaseSubdomain = {
    "old.example.com" = "TEST";
  };
in

(pkgs.runCommand pname { } ''
  ${assertValid basicExample}
  ${assertValid multiple}
  ${assertValid withSeparators}
  ${assertValid withNumbers}
  ${assertValid hostAsOld}

  ${assertInvalid subdomainWithDot}
  ${assertInvalid uppercaseSubdomain}

  touch $out
'')
