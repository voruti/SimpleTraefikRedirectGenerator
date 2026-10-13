# SimpleTraefikRedirectGenerator

A script that can simplify creation of redirects from one host/domain to another.

It maps each `old` host from a `redirects.json` file onto a subdomain of a configured host/TLD (`HOST_TO_REDIRECT_TO`), creating a `compose.override.yml` file with labels that configure the redirects using routers and middlewares.

## Usage example

Clone the repository into your Traefik configuration directory and copy the `redirects.json` example file out of the repo, like so:

<!-- prettier-ignore -->
```yml
- repo/...        # the clone of this repository
- ...             # other files like acme.json, traefik.yml, etc. of your Traefik configuration
- compose.yml     # compose file of Traefik
- redirects.json  # copied from the repo: your mappings
```

Inside the repository directory:

- Copy `template.env` to `.env` and adjust values as desired.
- Execute with `docker compose up`.

Required environment variables (set in `.env`):

| Variable              | Description                                                                 |
| --------------------- | --------------------------------------------------------------------------- |
| `WORKING_DIR`         | Directory holding `redirects.json`; `compose.override.yml` is written there |
| `HOST_TO_REDIRECT_TO` | Host/TLD that all redirects point to                                        |

Optional (see `template.env`): `TRAEFIK_SERVICE_NAME` (defaults to `traefik`), `PUID`/`PGID` (defaults to `0`).

## Nix

This repository also provides a Nix port of the same logic, exposed as the flake `lib`:

- `lib.createConfig` — builds a Traefik dynamic-config attrset from `{ hostToRedirectTo, redirects }`
- `lib.types.redirects` — the redirects type (an attrset of `old` -> `subdomain`)
