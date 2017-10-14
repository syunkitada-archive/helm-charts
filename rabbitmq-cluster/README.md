# rabbitmq-cluster

## 障害試験
* 3 node(node1, node2, node3)で障害試験をする
* node1のdockerをstopする
    * cluster_statusのrunning_nodesからnode1のpodが外れる
    * nodeがNotReadyになると serviceのendpointからpodが外れる
    * podのstatusはRunningのまま
    * evictionされる前に、dockerとkubeletを再度起動させると、
        * podのstatusはいったんErrorに落ち、再度Podが起動する
        * cluster_statusのrunning_nodesに加わる
    * evictionされると、
        * 新規のPodがPending状態で追加される
        * 元のpodのステータスはUnknownに代わる
        * dockerをstartし、NodeがReadyになるとUnknownのPodは削除される
        * PdendingのPodは、Runningとなり、rabbit clusterに参加する
* node1をdrainする
    * podがevictionされ、新規のpodがpendingとなる
    * node1をuncordonすると、podがcreatingとなる起動し、rabbit clusterに参加する
* node2, node3をdrainする
    * podがevictionされ、新規のpodがpendingとなる
    * node2, node3をuncordonすると、pendingからrunningとなり再度起動する
