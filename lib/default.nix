{
  inputs,
  lib ? inputs.nixpkgs.lib,
}:

let
  redirect =
    lib.types.submodule {
      options = {
        old = lib.types.strMatching "^[a-z0-9.-]+$";
        subdomain = lib.types.strMatching "^[a-z0-9-]+$";
      };
      example = {
        old = "old.example.com";
        subdomain = "test";
      };
    }
    // {
      name = "redirect";
      description = "A redirection rule that adds a redirect from an 'old' domain to a 'subdomain' of a specified domain.";
      descriptionClass = "noun";
    };

  createLabels =
    { hostToRedirectTo, redirects }:
    builtins.listToAttrs (
      builtins.concatMap (
        entry:
        let
          routerName = "redirect-${builtins.replaceStrings [ "." ] [ "-" ] entry.old}";
        in
        [
          {
            name = "traefik.http.routers.${routerName}.rule";
            value = "Host(`${entry.old}`)";
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
            value = "^\\S*?${builtins.replaceStrings [ "." ] [ "\\." ] entry.old}(\\S*)$$";
          }
          {
            name = "traefik.http.middlewares.${routerName}.redirectregex.replacement";
            value = "https://${entry.subdomain}.${hostToRedirectTo}$\${1}";
          }
          {
            name = "traefik.http.middlewares.${routerName}.redirectregex.permanent";
            value = true;
          }
        ]
      ) redirects
    );
in

{
  types = { inherit redirect; };
  inherit createLabels;
}
