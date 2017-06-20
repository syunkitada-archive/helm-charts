search {{ .Release.Namespace }}.svc.{{ .Values.network.dns.kubernetes_domain }} svc.{{ .Values.network.dns.kubernetes_domain }} {{ .Values.network.dns.kubernetes_domain }}
{{- range .Values.network.dns.servers }}
nameserver {{ . | title }}
{{- end }}
nameserver 192.168.122.1
options ndots:5
