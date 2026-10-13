{
  flake,
  lib ? pkgs.lib,
  perSystem,
  pkgs,
  pname,
  ...
}:

pkgs.runCommand pname { } ''
  cp -r ${flake} source
  chmod -R +w source

  HOME=$TMPDIR ${lib.meta.getExe perSystem.self.formatter} --no-cache --fail-on-change --tree-root source

  touch $out
''
