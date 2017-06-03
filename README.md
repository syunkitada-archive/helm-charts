# openstack-helm

## Require

### mysql
https://github.com/kubernetes/charts/tree/master/stable/mariadb
```
helm install stable/mariadb --name openstack-db --set persistence.enabled=false,mariadbRootPassword=rootpass

# How to access db
$ kubectl run torpid-bat-mariadb-client --rm --tty -i --image bitnami/mariadb --command -- bash
# mysql -h openstack-db-mariadb
```

### rabbitmq
https://github.com/kubernetes/charts/tree/master/stable/rabbitmq
```
helm install stable/rabbitmq --name openstack-rpc --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass

echo URL : http://127.0.0.1:15672
kubectl port-forward $POD_NAME 15672:15672

```

### memcached
https://github.com/kubernetes/charts/tree/master/stable/memcached
```
helm install stable/memcached --name openstack-cache --set replicaCount=1,memcached.maxItemMemory=512
```
