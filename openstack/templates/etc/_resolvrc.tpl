vip={{ .Values.openstack.ingress_vip }}
{{- $ingress_suffix := .Values.openstack.ingress_suffix }}
{{- range $key, $ingress := .Values.ingress }}
domain={{ $ingress.name }}{{ $ingress_suffix }}
grep "$vip $domain" /etc/hosts || echo "$vip $domain" >> /etc/hosts
{{- end }}


dnsip=`kubectl get svc -n kube-system -l k8s-app=kube-dns | grep kube-dns | awk '{print $2}'`
grep $dnsip /etc/resolv.conf \
    || ( sed -e "1s/^/nameserver $dnsip\n/" /etc/resolv.conf > /tmp/resolv.conf \
         && cat /tmp/resolv.conf > /etc/resolv.conf )
grep -e "search.*cluster.local" /etc/resolv.conf || echo "search {{ .Release.Namespace }}.svc.cluster.local svc.cluster.local cluster.local" >> /etc/resolv.conf
grep "options ndots:5" /etc/resolv.conf || echo "options ndots:5" >> /etc/resolv.conf


kubectl get secret {{ .Values.openstack.ingress_tls }} -o jsonpath='{.data.tls\.crt}' | base64 --decode > /usr/share/pki/ca-trust-source/anchors/tls-ingress.crt
update-ca-trust extract

export REQUESTS_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
