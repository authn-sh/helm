# Changelog

## [0.6.0] — 2026-05-11

### Changed

- Chart `version` bumped to `0.6.0` — picks up the v0.6 application surface (Enterprise SSO with unified SAML + OIDC connection model, SCIM 2.0 provisioning, verified-domain sign-in routing).
- `appVersion` rolled forward to `"0.6.0"` — the stable `ghcr.io/authn-sh/authn:0.6.0` image ships alongside this chart. Operators wanting an alpha can set `image.tag=0.6.0-alpha.N` explicitly.
- `values.yaml` comments document two new optional env-var keys for the SAML SP signing key (`AUTHN_SAML_SP_SIGNING_KEY_PATH`, `AUTHN_SAML_SP_SIGNING_KEY_B64`). Both are optional — connections without a configured key skip signing AuthnRequests, which most IdPs accept.

No template changes. The new BAPI / FAPI / SCIM surfaces reuse the existing FAPI ingress — no extra Service, Ingress, or route wiring is required. Existing 0.5.x installs upgrade cleanly.

### Notes for operators

- The v0.6 application adds the following endpoints, all served through the existing FAPI ingress:
  - **BAPI** — `/v1/enterprise-connections` (CRUD + dry-run probe), `/v1/enterprise-accounts` (read + unlink).
  - **FAPI** (org admin surface) — `/v1/organizations/{org_id}/enterprise-connections` (CRUD + probe), `/v1/organizations/{org_id}/scim/endpoint`, `/v1/organizations/{org_id}/scim/tokens` (issue + revoke), `/v1/organizations/{org_id}/scim/attribute-mappings`.
  - **FAPI** (IdP-facing SCIM) — `/scim/v2/Users`, `/scim/v2/Groups`, `/scim/v2/ServiceProviderConfig`, `/scim/v2/ResourceTypes`, `/scim/v2/Schemas`. Authenticated by per-org bearer SCIM tokens.
  - **FAPI** (browser callbacks) — `/v1/saml/{id}/acs`, `/v1/saml/{id}/metadata`, `/v1/enterprise-sso-callback`.
- The optional SAML SP signing key is read at request time from one of two env vars (mutually exclusive — `*_PATH` wins if both are set):
  - `AUTHN_SAML_SP_SIGNING_KEY_PATH` — filesystem path to a PEM-encoded private key. Preferred for k8s — pair with a Secret volume mount:
    ```yaml
    extraEnv:
      - name: AUTHN_SAML_SP_SIGNING_KEY_PATH
        value: /etc/authn-saml/sp-signing.pem
    extraVolumes:
      - name: saml-signing-key
        secret:
          secretName: authn-saml-signing-key
    extraVolumeMounts:
      - name: saml-signing-key
        mountPath: /etc/authn-saml
        readOnly: true
    ```
  - `AUTHN_SAML_SP_SIGNING_KEY_B64` — base64-encoded PEM as an inline env value. Useful when a file mount isn't practical (e.g. SecretsManager-fed env on ECS).
- Per-connection `saml_signing_key` (stored encrypted on `EnterpriseConnection`) takes precedence over the instance-wide env var when set. Self-hosters with one tenant and one IdP can configure the env var and skip the per-connection key entirely.

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
