#!/bin/bash -xe
{{- $influxdb := .Values.influxdb }}

echo 'Starting influxdb'

COMMAND="${@:-start}"


function start(){
    echo "Starting influxdb in the background"
    exec /usr/bin/influxd --config /etc/influxdb/influxdb.conf &

    echo "Waiting for InfluxDB to come up..."
    until $(curl -k --fail --output /dev/null --silent 127.0.0.1:8086/ping); do
      echo "Seep 2s."
      sleep 2
    done
    echo "InfluxDB is up and running."

    influx -execute "CREATE USER {{ $influxdb.root_user }} WITH PASSWORD '{{ $influxdb.root_password }}' WITH ALL PRIVILEGES;"
    {{- range $influxdb.dbs }}
    influx -execute "CREATE DATABASE {{ . }};"
    {{- end }}
    # sed -i 's/auth-enabled =.*/auth-enabled = true/g' /etc/influxdb/influxdb.conf
    sed -i 's/bind-address = "127.0.0.1:8088"/bind-address = "0.0.0.0:8088"/g' /etc/influxdb/influxdb.conf
    sed -i 's/bind-address = "127.0.0.1:8086"/bind-address = "0.0.0.0:8086"/g' /etc/influxdb/influxdb.conf
    pkill influxd

    /usr/bin/influxd --config /etc/influxdb/influxdb.conf
}


$COMMAND
