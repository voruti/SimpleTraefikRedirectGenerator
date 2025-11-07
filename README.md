# SimpleTraefikRedirectGenerator

A script that can simplify creation of redirects from one host/domain to another.

Redirects according to a mapping of hosts onto subdomains of a configured TLD (/host).
Creates a `compose.override.yml` file with labels that configure the redirects using routers and middlewares.

## Usage example

Clone the repository into your Traefik configuration directory and copy the `redirects.json` example file out of the repo, like so:

```yml
- repo/...        # the clone of this repository
- ...             # other files like acme.json, traefik.yml, etc. of your Traefik configuration
- compose.yml     # compose file of Traefik
- redirects.json  # copied from the repo: your mappings
```

Execute with `docker compose up` inside the repository directory.
