# openstack-helm

## Requires
### Install Helm
``` bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.5.1-linux-amd64.tar.gz && \
tar -xf helm-v2.5.1-linux-amd64.tar.gz && \
sudo mv linux-amd64/helm /usr/local/bin/ && \
helm init && \
kubectl create serviceaccount --namespace kube-system tiller && \
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller && \
kubectl patch deployment tiller-deploy -p'{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system
```

### Set helm repo
```
helm init -c
helm repo add charts https://syunkitada.github.io/chartrepo/charts
```

### Create NS for openstack
```
kubectl create ns openstack
```

### Create TLS for openstack
```
cat << EOS > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.k8s.example.com
EOS

openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr -subj "/CN=*.k8s.example.com" -config openssl.cnf
openssl x509 -days 365 -req -signkey server.key -in server.csr -out server.crt

kubectl create secret tls tls-ingress --key server.key --cert server.crt -n openstack
```


### set label
```
kubectl label nodes kubernetes-centos7-1.example.com ingress-controller=enable

kubectl label nodes kubernetes-centos7-1.example.com rabbitmq-node=enable
kubectl label nodes kubernetes-centos7-2.example.com rabbitmq-node=enable
kubectl label nodes kubernetes-centos7-3.example.com rabbitmq-node=enable

kubectl label nodes kubernetes-centos7-1.example.com openstack-region=openstack
kubectl label nodes kubernetes-centos7-2.example.com openstack-region=openstack
kubectl label nodes kubernetes-centos7-3.example.com openstack-region=openstack

kubectl label nodes kubernetes-centos7-1.example.com openstack-controller=enable
kubectl label nodes kubernetes-centos7-2.example.com openstack-controller=enable
kubectl label nodes kubernetes-centos7-3.example.com openstack-controller=enable

kubectl label nodes kubernetes-centos7-3.example.com openstack-compute=enable

kubectl label nodes kubernetes-centos7-1.example.com develop-node=enable
```


## Install charts
```
# Install ingress
helm install --name ingress charts/ingress

# Create values.yaml. And if you want to change values, edit values.yaml
git clone git@github.com:syunkitada/openstack-helm.git
cp openstack-helm/openstack/values.yaml ./values.yaml
vim values.yaml

# Install openstack
helm install charts/openstack --name openstack --namespace openstack -f values.yaml
```


# Design
* 各ノードを役割に応じてラベルを振る
  * controller, compute, net-node, block-storage, object-storage, database
  * Kubernetesは各regionで共有することを前提する
      openstack-region=openstack

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
