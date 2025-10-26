{{/*
Expand the name of the chart.
*/}}
{{- define "paperless-ngx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "paperless-ngx.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "paperless-ngx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "paperless-ngx.labels" -}}
helm.sh/chart: {{ include "paperless-ngx.chart" . }}
{{ include "paperless-ngx.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "paperless-ngx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "paperless-ngx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "paperless-ngx.postgresql.host" -}}
{{- if .Values.postgresql.external.enabled }}
{{- .Values.postgresql.external.host }}
{{- else }}
{{- printf "%s-postgresql" (include "paperless-ngx.fullname" .) }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "paperless-ngx.postgresql.port" -}}
{{- if .Values.postgresql.external.enabled }}
{{- .Values.postgresql.external.port | toString }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "paperless-ngx.redis.host" -}}
{{- if .Values.redis.external.enabled }}
{{- .Values.redis.external.host }}
{{- else }}
{{- printf "%s-redis" (include "paperless-ngx.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "paperless-ngx.redis.port" -}}
{{- if .Values.redis.external.enabled }}
{{- .Values.redis.external.port | toString }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
Redis URL
Constructs the Redis URL with optional authentication.
Format: redis://[username]:[password]@host:port/database
*/}}
{{- define "paperless-ngx.redis.url" -}}
{{- $host := include "paperless-ngx.redis.host" . }}
{{- $port := include "paperless-ngx.redis.port" . }}
{{- $database := .Values.redis.external.database | toString }}
{{- $username := .Values.redis.external.username | default "" }}
{{- $password := .Values.redis.external.password | default "" }}
{{- if and $username $password }}
{{- printf "redis://%s:%s@%s:%s/%s" $username $password $host $port $database }}
{{- else if $password }}
{{- printf "redis://:%s@%s:%s/%s" $password $host $port $database }}
{{- else }}
{{- printf "redis://%s:%s/%s" $host $port $database }}
{{- end }}
{{- end }}