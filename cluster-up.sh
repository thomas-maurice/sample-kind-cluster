#!/bin/bash

kind create cluster --config cluster.yaml
kubectl --context kind-kind taint nodes --all node-role.kubernetes.io/master-
kubectl --context kind-kind apply -f bundle
kubectl --context kind-kind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
helm init --service-account=tiller
sleep 10
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm install kubernetes-dashboard/kubernetes-dashboard \
    --name kubernetes-dashboard \
    --namespace kubernetes-dashboard \
    --set protocolHttp=true \
    --set serviceAccount.create=false \
    --set serviceAccount.name=admin-user