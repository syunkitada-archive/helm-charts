helm install stable/mariadb --set persistence.enabled=false

$ kubectl run torpid-bat-mariadb-client --rm --tty -i --image bitnami/mariadb --command -- bash
# mysql -h torpid-bat-mariadb



helm install stable/rabbitmq --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass

echo URL : http://127.0.0.1:15672
kubectl port-forward $POD_NAME 15672:15672

helm install stable/memcached --set replicaCount=1



rabbitmqctl add_user openstack openstackpass
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

