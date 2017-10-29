#!/bin/bash -xe
{{- $name := .Release.Name }}
{{- $rabbitmq := .Values.rabbitmq }}

COMMNAD="${@:-help}"
HOSTNAME=`hostname`


function help() {
    echo "help"
}


function _change_master() {
    ready_pods=`kubectl get pod -l app={{ $name }} | grep -v $HOSTNAME | grep Running | grep ' 1/1 ' | awk '{print $1}'`
    if [ "$ready_pods" != "" ]; then
        tmp_master=`echo "$ready_pods" | head -n 1`
        kubectl patch cm {{ $name }} -p "{\"data\":{\"master\":\"$tmp_master\"}}"
    else
        running_pods=`kubectl get pod -l app={{ $name }} | grep Running | awk '{print $1}'`
        if [ "$running_pods" != "" ]; then
            tmp_master=`echo "$running_pods" | head -n 1`
            kubectl patch cm {{ $name }} -p "{\"data\":{\"master\":\"$tmp_master\"}}"
        fi
    fi

}


master=none
function _set_master() {
    while :
    do
        master=`kubectl get cm {{ $name }} -o jsonpath='{.data.master}'`
        if [ $? == 0 ]; then
            echo "Success get cm {{ $name }}" 1>&2

            kubectl get pod $master
            if [ $? == 0 ]; then
                if [ $master == $HOSTNAME ]; then
                    break
                fi

                # If master is not running, this wait for master running.
                kubectl get pod $master | grep ' Running ' | grep ' 1/1 '
                if [ $? == 0 ]; then
                    break
                else
                    echo 'Master is not Running' 1>&2
                fi
            else
                echo 'Failed get master pod' 1>&2
                _change_master
            fi
        else
            echo 'Failed get cm, this pod will exit after 10 seconds.' 1>&2
            sleep 10
            exit 1
        fi
        echo 'Sleep 10' 1>&2
        sleep 10
    done
}


function start() {
    set +e
    _set_master
    set -e

    rouser={{ $rabbitmq.ro_user }}
    ropass={{ $rabbitmq.ro_pass }}
    user={{ $rabbitmq.user }}
    pass={{ $rabbitmq.pass }}
    cookie={{ $name }}{{ $rabbitmq.ro_pass }}
    tags=administrator

    echo $cookie > var/lib/rabbitmq/.erlang.cookie
    chmod 400 /var/lib/rabbitmq/.erlang.cookie
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

    for host in `kubectl get pod -l app={{ $name }} | grep {{ $name }} | awk '{print $1}'`
    do
        ip=`kubectl get pod $host -o jsonpath={.status.podIP}`
        echo "$ip $host" >> /etc/hosts
    done

    ulimit -n 65536

    if [ -e /var/lib/rabbitmq/mnesia/ ]; then
        echo "mnesia is already exists, and check cluster_nodes.conf"
        grep ${master} /var/lib/rabbitmq/mnesia/rabbit\@${HOSTNAME}/cluster_nodes.config || rm -rf /var/lib/rabbitmq/mnesia
    fi

    if [ -e /var/lib/rabbitmq/mnesia/ ]; then
        echo "mnesia is already exists"
        _start_rabbitmq
        rabbitmq-plugins list | grep '*] rabbitmq_management' || rabbitmq-plugins enable rabbitmq_management
    else
        _start_rabbitmq
        if [ $HOSTNAME == $master ]; then
            rabbitmqctl start_app
            sleep 2
            rabbitmqctl add_user $user $pass
            rabbitmqctl set_user_tags $user $tags
            rabbitmqctl add_user $rouser $ropass
            rabbitmqctl set_user_tags $rouser $tags
            rabbitmqctl delete_user guest
            {{- range $vhost_name, $vhost := $rabbitmq.vhost_map }}
            rabbitmqctl add_vhost {{ $vhost_name }}
            rabbitmqctl set_permissions -p {{ $vhost_name }} $user '.*' '.*' '.*'
            rabbitmqctl set_permissions -p {{ $vhost_name }} $rouser '' '' '.*'
            {{- range $vhost.policies }}
            rabbitmqctl set_policy {{ . }} -p {{ $vhost_name }}
            {{- end }}
            {{- end }}
            rabbitmq-plugins enable rabbitmq_management

        else
            rabbitmqctl stop_app
            sleep 2
            rabbitmqctl join_cluster rabbit@${master}
            sleep 2
            rabbitmqctl start_app
            sleep 2
            rabbitmq-plugins enable rabbitmq_management
        fi
    fi

    echo "Bringing RabbitMQ back to the foreground"
    fg
}


function _start_rabbitmq() {
    set +e
    set -m
    echo "Starting RabbitMQ in the background"
    rabbitmq-server $@ &
    echo "Waiting for RabbitMQ to come up..."
    count=0
    until [ `ss -ln | grep ":5672" | wc -l` = 1 ]; do
        printf "."
        sleep 2
        ((count++))
        if [ $count -gt 60 ]; then
            kubectl delete pod $HOSTNAME &
            sleep 30
            exit 1
        fi
    done
    echo "RabbitMQ is up and running."
    set -e
}


function liveness() {
    test -e /tmp/status
}


function readiness() {
    set +e

    test `ss -ln | egrep ":5672 |:15672 |:25672 " | wc -l` == 3
    if [ $? != 0 ]; then
        rm -rf /tmp/status
        exit 1
    fi

    rabbitmqctl eval 'ok.'
    if [ $? != 0 ]; then
        rm -rf /tmp/status
        exit 1
    fi

    rabbitmqctl node_health_check -t 10
    if [ $? != 0 ]; then
        rm -rf /tmp/status
        exit 1
    fi

    rabbitmqctl cluster_status | grep -F '{partitions,[]},'
    result=$?
    if [ $result != 0 ]; then
        rm -rf /tmp/status
        exit 1
    fi

    set -e
    touch /tmp/status
}


function stop() {
    pkill rabbitmq-server
}


$COMMNAD
