# openstack-helm

## Require
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

kubectl create secret tls tls-ingress --key server.key --cert server.crt


helm repo add charts https://syunkitada.github.io/chartrepo/charts
helm install --name ingress charts/ingress
```


### set label
```
kubectl label nodes kubernetes-centos7-2.example.com openstack-controller=
kubectl label nodes kubernetes-centos7-3.example.com openstack-controller=
kubectl label nodes kubernetes-centos7-3.example.com openstack-compute=
sudo mkdir -p /opt/kubernetes/bin
sudo cp /usr/local/bin/helm /opt/kubernetes/bin/
sudo cp /usr/bin/kubectl /opt/kubernetes/bin/
```


## Install openstack
```
helm install --name openstack openstack
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
