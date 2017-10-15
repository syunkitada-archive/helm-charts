# rabbitmq-cluster

## 設計
* hard anti affinityを利用しているため、Node数はDeploymentのreplicas数以上であるとします
    * default replicasは3のため3 Node以上のKubernetes Nodeが必要です
* 起動スクリプトは、開始時にMaster Podを一つ決定する
    * Masterが決定されるとMaster Podは起動処理を開始し、Slave PodsはMasterがReadyとなるまで待機する
    * Master Podは初回時は、userやvhostの作成を行い、再起動時は何もせずに起動する
    * Slave Podsは初回起動時は、rabbitmq clusterへの参加を行い、再起動時は何もせずに起動する
        * ただし、再起動時Masterがcluster_nodes.confに登録されてない場合は、
        * クラスタが崩壊していたとみなし、mnesiaを削除してから起動し、新しいrabbitmq clusterへ参加します
* RabbitMQのスタートに失敗した場合(起動待ち状態が一定時間続く場合)、Podは自身をDeleteする
    * 失敗の主原因は古いデータのせいで起動に失敗する場合があるため、Deleteによりリセットする


## 障害試験
* 3 Node(Node1, Node2, Node3)で障害試験をする
* Node1のdockerをstopする
    * cluster_statusのrunning_nodesからNode1のpodが外れる
    * ServiceのEndpointsにはPodへのルートが残るので、3度に一度は接続に失敗する状態となる
    * Node1がNotReadyになると ServiceのEndpointsからNode1のPodが外れる
        * このとき、PodのStatusはRunningのまま
    * evictionされる前に、dockerとkubeletを再度起動させると、
        * podのstatusはいったんError or Completeに落ち、再度Podが起動する
        * 正常に起動しなおすと、Podがcluster_statusのrunning_nodesに加わる
    * evictionされると、
        * 新規のPodがPending状態で追加され、元のPodのStatusはUnknownとなる
        * dockerをstartし、Node1がReadyになるとUnknownのPodは削除される
        * PendingのPodは、Node1上でRunningとなり、rabbitmq clusterに新規で参加する
* Node1をdrainする
    * Node1上のPodがevictionされ、新規のPodがPending状態で追加される
    * Node1をuncordonすると、PendingのPodはNode1上でRunningとなり、rabbitmq clusterに新規で参加する
* Node2, Node3をdrainする
    * Node2, Node3上のPodがevictionされ、新規のPodがPending状態で追加される
    * Node2, Node3をuncordonすると、PendingからRunningとなり、rabbitmq clusterに新規で参加する
* 全Nodeのdockerを同時にstopする
    * 全NodeがNotReadyとなる、その後、全Nodeのdocker, kubeletをstartする
    * Master Podが起動処理を始める
        * Master Podが起動に失敗した場合、Master Podは自身をdeleteする
        * Masterが不在となるため、Masterの再決定が行われる
    * Master Podが起動すると、Slave Podsも起動処理を始める
    * Slave Podsは起動時に以前のクラスタデータを削除してから、新しいrabbitmq clusterへ新規で参加する
