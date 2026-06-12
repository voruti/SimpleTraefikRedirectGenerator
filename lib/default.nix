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

  createLabels =
    { hostToRedirectTo, redirects }:
    builtins.listToAttrs (
      lib.lists.flatten (
        lib.attrsets.mapAttrsToList (
          old: subdomain:
          let
            routerName = "redirect-${builtins.replaceStrings [ "." ] [ "-" ] old}";
          in
          [
            {
              name = "traefik.http.routers.${routerName}.rule";
              value = "Host(`${old}`)";
            }
            {
              name = "traefik.http.routers.${routerName}.middlewares";
              value = routerName;
            }
            {
              name = "traefik.http.routers.${routerName}.service";
              value = "noop@internal";
            }
            {
              name = "traefik.http.middlewares.${routerName}.redirectregex.regex";
              value = "^\\S*?${builtins.replaceStrings [ "." ] [ "\\." ] old}(\\S*)$$";
            }
            {
              name = "traefik.http.middlewares.${routerName}.redirectregex.replacement";
              value = "https://${subdomain}.${hostToRedirectTo}$\${1}";
            }
            {
              name = "traefik.http.middlewares.${routerName}.redirectregex.permanent";
              value = true;
            }
          ]
        ) redirects
      )
    );
in

{
  types = { inherit redirects; };
  inherit createLabels;
}
