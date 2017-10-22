# openstack-helm


## Requirements
* helm>=2.6.0
* kubernetes>=2.7.0


### Set helm repo
* openstack-helmの各chartを以下のrepoに置いてあるので、これを追加します
```
helm init -c
helm repo add charts https://syunkitada.github.io/chartrepo/charts
```


### Set labels
* 各ノードに役割に応じたラベルを振ります
    * ingress-controller=enable
        * ingress-controllerはkubernetesクラスタで共有することを想定
        * VIP配下にingress-controllerが配置されることを想定し、そのノードにこのラベルを設定します
        * このラベルがついてるingress-controllerにIngressをデプロイします
    * openstack-region=[hoge]
        * Kubernetesは各リージョンで共有されると想定
        * そのリージョン用のノードすべてにこのラベルを設定します
    * rabbitmq-node=enable
        * openstack-region, rabbitmq-nodeが設定されてるノードにRabbitmq Clusterをデプロイします
        * 推奨は、3台以上のノードにこのラベルを設定します
    * openstack-controller=enable
        * openstack-region, openstack-controllerが設定されてるノードにOpenStack Controller群をデプロイします
        * 推奨は、3台以上のノードにこのラベルを設定します
    * openstack-compute=enable
        * TODO
    * openstack-net-node=enable
        * TODO
    * block-storage=enable
        * TODO
    * object-storage=enable
        * TODO
    * database-node=enable
        * TODO
    * develop-node=enable
        * 開発で利用するノードがある場合は、このラベルを設定します
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

kubectl label nodes kubernetes-centos7-1.example.com develop-node=enable
```


### Create NS for Openstack
* Openstack用のリソースを展開するためのnamespaceを作成します
* このnamespaceは、Region名と一致させます
```
kubectl create ns openstack
```


### Create TLS for Ingress
* Ingressで利用する各Region用のTLSを作成します
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


## Install charts for production
```
# Install ingress
helm install --name ingress charts/ingress

# Create values.yaml. And if you want to change values, edit values.yaml
git clone git@github.com:syunkitada/openstack-helm.git
cp openstack-helm/openstack/values.yaml ./values.yaml
vim values.yaml

# Install openstack
helm install charts/openstack -n openstack --namespace openstack -f values.yaml
```

## Install charts for development
```
git clone git@github.com:syunkitada/openstack-manager.git
cd openstack-manager
make dev

# Install openstack for develop
helm install openstack-helm/openstack -n openstack -f openstack-helm/openstack/values.yaml --set is_develop=true,chart_prefix=/home/fabric/openstack-helm
```


# Design
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
