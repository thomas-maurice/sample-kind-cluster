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
helm repo update
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user \
    --set metricsScraper.enabled=true
