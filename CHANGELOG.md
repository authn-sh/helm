# Changelog

## [0.5.0] — 2026-05-11

### Changed

- Chart `version` bumped to `0.5.0` — picks up the v0.5 application surface (Passkeys / WebAuthn, server-side Appearance + Localization, six additional OAuth presets: Discord / Facebook / LinkedIn / X / GitLab / Slack).
- `appVersion` rolled forward to `"0.5.0"` — the stable `ghcr.io/authn-sh/authn:0.5.0` image ships alongside this chart. Operators wanting an alpha can set `image.tag=0.5.0-alpha.N` explicitly.

No template / `values.yaml` changes: v0.5 added no new required env vars, secrets, or external dependencies. WebAuthn derives the RP-ID from each environment's FAPI host at request time, and appearance / localization blobs are stored in Postgres and served by the existing FAPI / BAPI routes — no chart-level wiring required. Existing 0.4.x installs upgrade cleanly.

### Notes for operators

- Two new BAPI surfaces are now reachable through the existing BAPI ingress: `PATCH /v1/instance/appearance` and `PATCH /v1/instance/localization`. The dashboard editors call these — no extra routing or auth wiring is needed.
- A new **public** FAPI surface is reachable through the existing FAPI ingress: `GET /v1/localization/{locale}`. This route is CORS-open and is hit on every page load by the SDK to fetch the active localization bundle. Self-hosters who front their FAPI host with their own CDN should respect the `Cache-Control` / `ETag` headers the app emits (defaults to a short TTL with revalidation) so that operator edits in the dashboard propagate within seconds, not hours.

## [0.4.0] — 2026-05-10

### Changed

- Chart `version` bumped to `0.4.0` — picks up the v0.4 application surface (OAuth social sign-in, phone numbers, SMS engine + drivers, `phone_code` second factor, BAPI sms-templates).
- `appVersion` rolled forward to `"0.4.0"` — the stable `ghcr.io/authn-sh/authn:0.4.0` image ships alongside this chart. Operators wanting an alpha can set `image.tag=0.4.0-alpha.N` explicitly.
- `values.yaml` comments document the new `AUTHN_SMS_*` env-var keys (driver selection + Twilio / Vonage credentials). No schema change — these are env-var fall-throughs via `extraEnv` or per-environment `Environment.sms.*` runtime config.

No template changes. v0.4 added no new required env vars, secrets, or external dependencies at chart level — existing 0.3.x installs upgrade cleanly.

## [0.3.0] — 2026-05-10

### Changed

- `appVersion` bumped to `0.3.0` — picks up the v0.3 application release (multi-factor authentication: TOTP + backup codes, second-factor Challenge wiring, BAPI MFA admin overrides).

No template / values changes: v0.3 added no new required env vars, secrets, or external dependencies. Existing values from a 0.2.x install upgrade cleanly. The MFA surface is fully internal to the authn server.

## [0.2.0] — 2026-05-10

### Changed

- `appVersion` bumped to `0.2.0` — picks up the v0.2 application release (Organizations + magic-link + Challenge sub-resource + kebab-case URL paths).

No template / values changes: v0.2 added no new required env vars, secrets, or external dependencies. Existing values from a 0.1.x install upgrade cleanly.

## [0.1.0] — 2026-05-04

Initial chart. Deploys the Account Portal + Dashboard + FAPI + BAPI + webhook dispatcher in a single Deployment, fronted by an optional Service / Ingress. Optional Bitnami Postgres + Redis subcharts. Bootstrap Job seeds the first operator + workspace.
