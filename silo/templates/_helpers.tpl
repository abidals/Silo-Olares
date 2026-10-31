{{/*
Silo chart helpers.

Generate the SECRET_KEY master key ONCE and reuse it on every later render,
so an upgrade (or a reinstall that reattaches the same data) keeps decrypting
stored credentials. `lookup` returns nothing when the chart renders without a
cluster (e.g. `chart lint`), so the `else` branch must mint a fresh value.
*/}}
{{- define "silo.secretKey" -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" .Release.Name) -}}
{{- if and $existing $existing.data (index $existing.data "secret_key") -}}
{{- index $existing.data "secret_key" | b64dec -}}
{{- else -}}
{{- randAlphaNum 48 -}}
{{- end -}}
{{- end -}}
