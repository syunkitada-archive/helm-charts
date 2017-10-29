{{ $rabbitmq := .Values.rabbitmq }}
[k8s]
chart_repo_prefix = charts


[rabbitmq_manager]
user = {{ $rabbitmq.user }}
password = {{ $rabbitmq.pass }}
