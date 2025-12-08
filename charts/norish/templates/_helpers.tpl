{{/*
Expand the name of the chart.
*/}}
{{- define "norish.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "norish.fullname" -}}
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
{{- define "norish.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "norish.labels" -}}
helm.sh/chart: {{ include "norish.chart" . }}
{{ include "norish.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "norish.selectorLabels" -}}
app.kubernetes.io/name: {{ include "norish.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Database connection URL
*/}}
{{- define "norish.databaseUrl" -}}
{{- $username := .Values.database.username }}
{{- $password := .Values.database.password }}
{{- $host := .Values.database.host }}
{{- $port := .Values.database.port }}
{{- $database := .Values.database.name }}
{{- printf "postgres://%s:%s@%s:%d/%s" $username $password $host (int $port) $database }}
{{- end }}
