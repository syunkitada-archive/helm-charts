#!/bin/bash -xe

helm init -c
helm repo add charts {{ .Values.chart_repo }}
helm repo update
