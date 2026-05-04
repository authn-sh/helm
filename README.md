# authn.sh Helm chart

Kubernetes chart for [authn.sh](https://authn.sh). Pulls `ghcr.io/authn-sh/authn:0.1.0` and ships with optional Bitnami Postgres + Redis subcharts for fully self-contained installs.

## Prerequisites

- Kubernetes 1.27+.
- Helm 3.13+.
- An ingress controller (nginx, Traefik, or your cloud's). Optional but recommended.
- [cert-manager](https://cert-manager.io/) when you want a wildcard TLS cert provisioned automatically.

## Install

### 1. Bring-your-own DB

```bash
helm install authn oci://ghcr.io/authn-sh/charts/authn \
  --namespace authn --create-namespace \
  --set postgresql.enabled=false \
  --set redis.enabled=false \
  --set externalDatabase.host=postgres.example.com \
  --set externalDatabase.username=authn \
  --set secrets.values.DB_PASSWORD='…' \
  --set externalRedis.host=redis.example.com \
  --set secrets.values.REDIS_PASSWORD='…' \
  --set env.AUTHN_APP_URL=https://authn.example.com \
  --set ingress.hosts[0].host=authn.example.com \
  --set secrets.values.APP_KEY="$(openssl rand -base64 32 | sed 's/^/base64:/')" \
  --set secrets.values.AUTHN_BOOTSTRAP_ADMIN_EMAIL=op@example.com \
  --set secrets.values.AUTHN_BOOTSTRAP_ADMIN_PASSWORD='change-me-please'
```

### 2. In-cluster Bitnami DB + Redis

```bash
helm dependency update
helm install authn . \
  --namespace authn --create-namespace \
  --set env.AUTHN_APP_URL=https://authn.example.com \
  --set secrets.values.APP_KEY="base64:$(openssl rand -base64 32)" \
  --set secrets.values.AUTHN_BOOTSTRAP_ADMIN_EMAIL=op@example.com \
  --set secrets.values.AUTHN_BOOTSTRAP_ADMIN_PASSWORD='change-me-please' \
  --set secrets.values.DB_PASSWORD='ship-a-real-one' \
  --set secrets.values.REDIS_PASSWORD='ship-a-real-one' \
  --set postgresql.auth.password='ship-a-real-one' \
  --set redis.auth.password='ship-a-real-one'
```

### 3. With cert-manager + wildcard TLS

Set `ingress.tls[0].hosts` to include `*.authn.example.com` (FAPI subdomains) and tell the chart about your ClusterIssuer:

```bash
helm install authn . \
  --namespace authn --create-namespace \
  --set env.AUTHN_APP_URL=https://authn.example.com \
  --set ingress.hosts[0].host=authn.example.com \
  --set "ingress.tls[0].hosts[0]=authn.example.com" \
  --set "ingress.tls[0].hosts[1]=*.authn.example.com" \
  --set ingress.tls[0].secretName=authn-tls \
  --set certManager.enabled=true \
  --set certManager.clusterIssuer=letsencrypt-prod \
  --set certManager.dnsSolver=cloudflare \
  ...
```

The wildcard cert needs DNS-01 issuance. See [cert-manager's DNS-01 docs](https://cert-manager.io/docs/configuration/acme/dns01/) for solver setup.

## Path mode vs subdomain mode

- `env.AUTHN_ROUTING_MODE: subdomain` (default) — wildcard DNS + TLS required. Each tenant env lives at `<routing_label>.<APP_HOST>`.
- `env.AUTHN_ROUTING_MODE: path` — single host. Tenant envs live at `<APP_HOST>/<routing_label>`. Simpler ingress but FAPI URLs are uglier. Recommended for self-hosters who don't want to deal with wildcard certs.

## After install

The post-install Job runs migrations + `authn:bootstrap`. Tail it:

```bash
kubectl logs -n authn job/authn-bootstrap
```

The first operator's `pk_live_…` and `sk_live_…` keys are printed once. Save them.

## Upgrade

```bash
helm upgrade authn . \
  --namespace authn \
  --reuse-values \
  --set image.tag=0.2.0
```

The post-install/upgrade Job re-runs migrations idempotently. Don't restart pods manually before the Job finishes.

## Acceptance / smoke

```bash
helm lint .
helm template . -f ci/test-values.yaml | kubeconform -strict
helm install authn-ci . -f ci/test-values.yaml --wait
helm test authn-ci
```

`ci/test-values.yaml` is what CI uses against a kind cluster.
