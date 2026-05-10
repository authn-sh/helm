# Changelog

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
