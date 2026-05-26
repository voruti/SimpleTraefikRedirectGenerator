_:

let
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
  inherit createLabels;
}
