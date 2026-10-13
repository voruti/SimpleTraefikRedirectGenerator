# AGENTS.md

One-purpose repo: generate Traefik `redirectregex` labels from a `redirects.json` mapping, emitting `compose.override.yml`.

## Self-Maintenance (keep this file current)

This is a living document - a small part of every task. At the end of a task, review what you did and update this file with anything reusable: a new convention/gotcha, a hard-won command, or a stale-info fix. Don't wait to be asked.

- **Add** when you reveal an undocumented convention/quirk, correct stale info, or record a workflow that would save a future session.
- **Don't add** one-off task details, anything readable off a single file in one `Read`, speculation, or duplicates.
- Keep entries to 1-2 lines, factual, matching this style; prefer updating an existing bullet over a new section.

## Two parallel implementations

- `redirect-generator.js` — the runtime implementation, executed via Docker (`redirect-generator.js:38`).
- `lib/default.nix` (`createConfig`, `types.redirects`) — Nix port used only by the flake checks.

Any change to router/middleware naming, regex, or replacement logic must be applied to **both**; only the Nix side has tests (`checks/createConfig.nix`, `checks/redirect-type.nix`).

They diverge in **output shape and `$` escaping**: JS emits flat docker-compose `traefik.http.*` labels and doubles the regex/replacement `$` (`$$`) for compose parsing; Nix `createConfig` returns a nested Traefik dynamic-config attrset (`http.routers.<name>`, `http.middlewares.<name>.redirectRegex`) with a single `$`. Both consume the mapping differently: JS reads `redirects.json` as an array of `{ old, subdomain }`, while Nix uses an attrset `{ old = subdomain; }`.

## Verification

- `nix flake check` — runs both check files (CI: `.github/workflows/check.yml`)
- `nix fmt -- --ci` — treefmt check (CI: `formatting.yml`); use `nix fmt` to fix. Formatters from `formatter.nix`: nixfmt/deadnix (`.nix`), prettier (js/json/md/yml/…), shellcheck+beautysh (`.sh`, `.envrc`), keep-sorted.
- Runtime (intended path): `docker compose up` — builds the `node:slim` image (`Dockerfile`), reads `redirects.json` from the bound `WORKING_DIR` (mounted at `/workdir`, the script's CWD) and writes `compose.override.yml` there. `WORKING_DIR` is required by `compose.yml`.

## Domain constraint

`subdomain` values must match `^[a-z0-9-]+$` (no dots, no uppercase, enforced by the Nix type; JS does not validate). `old` values are arbitrary hostnames.

## Blueprint output mapping (folder → flake output)

`flake.nix` uses Blueprint to generate flake outputs from the folder structure. Per-system files take `{ inputs, flake, system, perSystem, pkgs }` plus `pname` for packages/checks. Use `inputs.nixpkgs.lib`, not a bare `lib`.

- `lib/default.nix` → `lib` (exposes `createConfig` and `types.redirects`).
- `checks/<name>.nix` → `checks.<system>.<name>` (bare name, no `pkgs-` prefix): `createConfig`, `redirect-type`.
- top-level `formatter.nix` → package `packages.<system>.formatter` + auto check `checks.<system>.pkgs-formatter`.
- `devshell.nix` → `devShells.<system>.default` + auto check `checks.<system>.devshell-default`.

## Nix conventions

- Prefer fully qualified `lib.attrsets.xxx` (and similar) over the `lib.xxx` shortcut.
- Prefer the `builtins.X` variant where one exists (e.g. `builtins.replaceStrings`, `builtins.attrNames`); only use the NixOS-lib form (`lib.attrsets.filterAttrs`, …) where no `builtins` equivalent exists.

## Gotchas

- The repo's `redirects.json` is an example; real data lives in `WORKING_DIR` (default `..`) alongside `acme.json`/Traefik config.
- `.env` (from `template.env`) is where `HOST_TO_REDIRECT_TO`, `WORKING_DIR`, optional `TRAEFIK_SERVICE_NAME`, `PUID`/`PGID` come from; `compose.yml` requires `WORKING_DIR` and `HOST_TO_REDIRECT_TO`.
- No JS test/lint/typecheck tooling — there is no package.json; the Docker image is just `node:slim` + the single script (`Dockerfile`).
- Dev env is direnv-based (`.envrc` → `use flake` → `devshell.nix`).
