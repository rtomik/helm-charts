{{/*
Expand the name of the chart.
*/}}
{{- define "karakeep.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "karakeep.fullname" -}}
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
{{- define "karakeep.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "karakeep.labels" -}}
helm.sh/chart: {{ include "karakeep.chart" . }}
{{ include "karakeep.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "karakeep.selectorLabels" -}}
app.kubernetes.io/name: {{ include "karakeep.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "karakeep.secretName" -}}
{{- if .Values.secrets.existingSecret }}
{{- .Values.secrets.existingSecret }}
{{- else }}
{{- include "karakeep.fullname" . }}-secret
{{- end }}
{{- end }}

{{/*
Create the name of the data PVC
*/}}
{{- define "karakeep.dataPvcName" -}}
{{- include "karakeep.fullname" . }}-data
{{- end }}

{{/*
Create the name of the meilisearch PVC
*/}}
{{- define "karakeep.meilisearchPvcName" -}}
{{- include "karakeep.fullname" . }}-meilisearch
{{- end }}