#!/bin/bash -xe
{{- $name := .Release.Name }}

COMMNAD="${@:-help}"
HOSTNAME=`hostname`


function help() {
    echo "help"
}


function _init_master() {
    nodes=`kubectl get pod -l app={{ $name }} | grep Running | awk '{print $1}'`
    if [ `echo "$nodes" | wc -l` == {{ .Values.replicas }} ]; then
        tmp_master=`echo "$nodes" | head -n 1`
        kubectl patch cm {{ $name }} -p "{\"data\":{\"master\":\"$tmp_master\"}}"
    fi
}


function _change_master() {
    nodes=`kubectl get pod -l app={{ $name }} | grep Running | awk '{print $1}'`
    if [ `echo "$nodes" | wc -l` == {{ .Values.replicas }} ]; then
        tmp_master=`echo "$nodes" | grep -v $HOSTNAME | head -n 1`
        kubectl patch cm {{ $name }} -p "{\"data\":{\"master\":\"$tmp_master\"}}"
    fi
}


master=none
function _set_master() {
    set +e
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
                if [ $master == 'dummy' ]; then
                    # If master is dummy(this is initial value), _init_master set master value.
                    _init_master
                else
                    # If master pod is not found, _change_master set master value from existing pods.
                    _change_master
                fi
            fi
        else
            echo 'Failed get cm' 1>&2
        fi
        echo 'Sleep 10' 1>&2
        sleep 10
    done
}


function start() {
    _set_master

    rouser=guest
    ropass=guestpass
    user=openstack
    pass=openstackpass
    cookie=hello
    tags=administrator

    echo $cookie > var/lib/rabbitmq/.erlang.cookie
    chmod 400 /var/lib/rabbitmq/.erlang.cookie
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

    for host in `kubectl get pod -l app={{ $name }} | grep {{ $name }} | awk '{print $1}'`
    do
        ip=`kubectl get pod $host -o jsonpath={.status.podIP}`
        echo "$ip $host" >> /etc/hosts
    done

    if [ -e /var/lib/rabbitmq/mnesia/ ]; then
        echo "mnesia is already exists"
    else
        if [ $HOSTNAME == $master ]; then
            ( \
            sleep 100; \
            rabbitmqctl start_app; \
            sleep 2; \
            rabbitmqctl add_user $user $pass; \
            rabbitmqctl set_user_tags $user $tags; \
            rabbitmqctl add_user $rouser $ropass; \
            rabbitmqctl set_user_tags $rouser $tags; \
            rabbitmqctl delete_user guest; \
            {{- range $vhost_name, $vhost := .Values.vhost_map }}
            rabbitmqctl add_vhost {{ $vhost_name }}; \
            rabbitmqctl set_permissions -p {{ $vhost_name }} $user '.*' '.*' '.*'; \
            rabbitmqctl set_permissions -p {{ $vhost_name }} $rouser '' '' '.*'; \
            {{- range $vhost.policies }}
            rabbitmqctl set_policy {{ . }} -p {{ $vhost_name }}; \
            {{- end }}
            {{- end }}
            rabbitmq-plugins enable rabbitmq_management; \
            ) &

        else
            ( \
            sleep 100; \
            rabbitmqctl stop_app; \
            sleep 2; \
            rabbitmqctl join_cluster rabbit@${master}; \
            sleep 2; \
            rabbitmqctl start_app;
            sleep 2; \
            rabbitmq-plugins enable rabbitmq_management; \
            ) &
        fi
    fi

    ulimit -n 32768
    rabbitmq-server $@
}


function liveness() {
    test `ss -ln | egrep ":5672 |:15672 |:25672 " | wc -l` == 3
    rabbitmqctl eval 'ok.'
}


function readiness() {
    liveness
}


function stop() {
    pkill rabbitmq-server
}


$COMMNAD
