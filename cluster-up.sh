#!/bin/bash

# Create the cluster
kind create cluster --config cluster.yaml

# Untaint the master
kubectl --context kind-kind taint nodes --all node-role.kubernetes.io/master-

# Applies the manifests
kubectl --context kind-kind apply -f bundle

# Installs the metrics server
kubectl --context kind-kind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sleep 10

# Install stuff via Helm
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user \
    --set metricsScraper.enabled=true
helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack

sleep 5
echo "http://grafana.localhost crededntials: "
kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-password| cut -d: -f2|tr -d \  | base64 -d
kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-user| cut -d: -f2|tr -d \  | base64 -d
