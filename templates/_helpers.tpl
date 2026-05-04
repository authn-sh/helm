{{/*
Expand the name of the chart.
*/}}
{{- define "authn.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "authn.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "authn.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "authn.labels" -}}
helm.sh/chart: {{ include "authn.chart" . }}
{{ include "authn.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "authn.selectorLabels" -}}
app.kubernetes.io/name: {{ include "authn.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "authn.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "authn.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image reference.
*/}}
{{- define "authn.image" -}}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}

{{/*
Secret name to reference for env vars: existing if set, otherwise the
chart-managed Secret named after the release.
*/}}
{{- define "authn.secretName" -}}
{{- if .Values.secrets.existingSecret }}
{{- .Values.secrets.existingSecret }}
{{- else }}
{{- include "authn.fullname" . }}
{{- end }}
{{- end }}

{{/*
Database host: in-cluster postgres subchart vs externalDatabase.
*/}}
{{- define "authn.dbHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else }}
{{- required "externalDatabase.host is required when postgresql.enabled=false" .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{- define "authn.dbPort" -}}
{{- if .Values.postgresql.enabled }}5432{{- else }}{{ .Values.externalDatabase.port }}{{- end }}
{{- end }}

{{- define "authn.dbName" -}}
{{- if .Values.postgresql.enabled }}{{ .Values.postgresql.auth.database }}{{- else }}{{ .Values.externalDatabase.database }}{{- end }}
{{- end }}

{{- define "authn.dbUser" -}}
{{- if .Values.postgresql.enabled }}{{ .Values.postgresql.auth.username }}{{- else }}{{ .Values.externalDatabase.username }}{{- end }}
{{- end }}

{{- define "authn.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" .Release.Name }}
{{- else }}
{{- required "externalRedis.host is required when redis.enabled=false" .Values.externalRedis.host }}
{{- end }}
{{- end }}

{{- define "authn.redisPort" -}}
{{- if .Values.redis.enabled }}6379{{- else }}{{ .Values.externalRedis.port }}{{- end }}
{{- end }}
