{
  lib ? pkgs.lib,
  pkgs,
}:

pkgs.mkShell {
  shellHook = ''
    ${lib.meta.getExe pkgs.git} fetch --all --tags --prune || true
    echo
    ${lib.meta.getExe pkgs.git} status
  '';
}
