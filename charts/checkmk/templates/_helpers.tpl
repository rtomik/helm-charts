{{/*
Expand the name of the chart.
*/}}
{{- define "checkmk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "checkmk.fullname" -}}
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
{{- define "checkmk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "checkmk.labels" -}}
helm.sh/chart: {{ include "checkmk.chart" . }}
{{ include "checkmk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "checkmk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "checkmk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the secret holding CMK_PASSWORD
*/}}
{{- define "checkmk.secretName" -}}
{{- .Values.config.adminPassword.existingSecret | default (printf "%s-secrets" (include "checkmk.fullname" .)) }}
{{- end }}

{{/*
Web UI path for health probes: /<siteId>/check_mk/login.py
*/}}
{{- define "checkmk.probePath" -}}
{{- printf "/%s/check_mk/login.py" .Values.config.siteId }}
{{- end }}

{{/*
tmpfs mount path derived from site ID
*/}}
{{- define "checkmk.tmpPath" -}}
{{- printf "/opt/omd/sites/%s/tmp" .Values.config.siteId }}
{{- end }}
