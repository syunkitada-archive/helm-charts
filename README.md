# openstack-helm

## Require
### Install Helm
``` bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.4.2-linux-amd64.tar.gz && \
tar -xf helm-v2.4.2-linux-amd64.tar.gz && \
sudo mv linux-amd64/helm /usr/local/bin/ && \
helm init && \
kubectl create serviceaccount --namespace kube-system tiller && \
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller && \
kubectl patch deployment tiller-deploy -p'{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system
```

kubectl create serviceaccount openstack && \
kubectl create clusterrolebinding openstack-cluster-rule --clusterrole=cluster-admin --serviceaccount=default:openstack


kubectl label nodes kubernetes-ubuntu7-1-hostname openstack-controller=common
mkdir -p /opt/kubernetes/bin
cp /usr/local/bin/helm /opt/kubernetes/bin/
cp /usr/bin/kubectl /opt/kubernetes/bin/


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


## Deploy openstack
``` deploy openstack-common
helm install --name ingress ingress
helm install --name openstack openstack
helm install --name keystone keystone
helm install --name glance glance
helm install --name neutron neutron
helm install --name nova nova
helm install --name horizon horizon
```


# Design

* 各ノードを役割に応じて抽象化しラベルを振る
  * controller, compute, net-node, block-storage, object-storage, database
* controller nodes
  * ステートレスなノード群
  * ingress, service, deploymentリソースによりAPIを構成するノード群
  * Statefullset
      * nova-scheduler, nova-conductor などのhost名を固定化させるべきものはStatefullsetを利用する
      * 一時データを保存するmemcached, rabbitmqもStatefullsetでデプロイする
* compute, net-node, block-storage, object-storage, database
  * ステートフルなノード軍
  * hostnet: true
  * 場合によりcontrackを無効にし、kubeのネットワークにも乗せない
  * daemonsetによってcontrollerプロセスを配備し、controllerコンテナないから親ホストの/(ルート)を/hostにマウントする
  * /host/opt/配下にvirtualenv、/host/etc/に設定ファイル、/lib/systemd/system/にサービスファイルをコピーする
  * /hostにchrootし、systemdでサービスを起動する
    * このため、サービスプロセスはkube管轄外となる
  * controllerプロセスでステータスを監視し正常性をコントロールする
* openstack-controller
  * configmapの変更をすべてマウントし、変更を検知したらpodの環境変数にhashをセットしてpodの作り直しを促す
  * podのステータスを監視し正常性をコントロールする
