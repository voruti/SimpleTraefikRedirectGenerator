const fs = require('fs');

// validate the environment variables:
if (!process.env.HOST_TO_REDIRECT_TO) {
  console.error("Please set the environment variable HOST_TO_REDIRECT_TO");
  process.exit(1);
}

// read the JSON file:
const data = fs.readFileSync('redirects.json');
const file = JSON.parse(data);
const redirects = file.redirects;

// function to get the router/middleware name:
function getRouterName(old) {
  return `redirect-${old.replace(/\./g, '-')}`;
}

// generate the compose.override.yml file content:
let content = `services:\n\n  ${process.env.TRAEFIK_SERVICE_NAME || "traefik"}:\n    labels:\n      # redirects:`;
for (const entry of redirects) {
  const routerName = getRouterName(entry.old);

  content += `\n      traefik.http.routers.${routerName}.rule: "Host(\`${entry.old}\`)"`
  content += `\n      traefik.http.routers.${routerName}.middlewares: "${routerName}"`
  content += `\n      traefik.http.routers.${routerName}.service: "noop@internal"`
  content += `\n      traefik.http.middlewares.${routerName}.redirectregex.regex: "^\\\\S*?${entry.old.replace(/\./g, '\\\\.')}(\\\\S*)$$"`
  content += `\n      traefik.http.middlewares.${routerName}.redirectregex.replacement: "https://${entry.subdomain}.${process.env.HOST_TO_REDIRECT_TO}$\${1}"`
  content += `\n      traefik.http.middlewares.${routerName}.redirectregex.permanent: "true"\n`
}

// write the compose.override.yml file
fs.writeFileSync('compose.override.yml', content);

console.log("Done");
