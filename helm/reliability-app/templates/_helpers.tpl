{{- define "reliability-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "reliability-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "reliability-app.name" . -}}
{{- end -}}
{{- end -}}

{{- define "reliability-app.labels" -}}
app.kubernetes.io/name: {{ include "reliability-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/part-of: kubernetes-reliability-lab
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{- define "reliability-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "reliability-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
