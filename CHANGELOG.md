# Changelog

## [0.4.0] — 2026-05-10

### Changed

- Chart `version` bumped to `0.4.0` — picks up the v0.4 application surface (OAuth social sign-in, phone numbers, SMS engine + drivers, `phone_code` second factor, BAPI sms-templates).
- `appVersion` stays at `0.3.0` for now; the v0.4.0 application image is published as `0.4.0-alpha.N` during cross-repo integration. The default `appVersion` rolls forward to `"0.4.0"` once the stable `ghcr.io/authn-sh/authn:0.4.0` tag is cut. Operators wanting an alpha can set `image.tag=0.4.0-alpha.N` explicitly.
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
