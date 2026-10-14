{
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}:

let
  redirects = (lib.types.attrsOf (lib.types.strMatching "^[a-z0-9-]+$")) // {
    name = "redirects";
    description = "Redirection rules that add redirects from hosts/domains/FQDNs to a host part/subdomain/third-level domain name, each.";
    descriptionClass = "composite";
  };

  createConfig =
    { hostToRedirectTo, redirects }:
    let
      routerName = old: "redirect-${builtins.replaceStrings [ "." ] [ "-" ] old}";
    in
    lib.attrsets.optionalAttrs (redirects != { }) {
      http = {
        routers = lib.attrsets.mapAttrs' (old: _subdomain: {
          name = routerName old;
          value = {
            rule = "Host(`${old}`)";
            middlewares = [ (routerName old) ];
            service = "noop@internal";
          };
        }) redirects;
        middlewares = lib.attrsets.mapAttrs' (old: subdomain: {
          name = routerName old;
          value = {
            redirectRegex = {
              regex = "^\\S*?${builtins.replaceStrings [ "." ] [ "\\." ] old}(\\S*)$";
              replacement = "https://${subdomain}.${hostToRedirectTo}\${1}";
              permanent = true;
            };
          };
        }) redirects;
      };
    };
in

{
  types = { inherit redirects; };
  inherit createConfig;
}
