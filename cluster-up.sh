#!/bin/bash

# Create the cluster
if ! kind create cluster --config cluster.yaml; then
    exit 1
fi;

# Untaint the master
kubectl --context kind-kind taint nodes --all node-role.kubernetes.io/master- || true

# Applies the manifests
kubectl --context kind-kind apply -f bundle
# yeah some CRDs are not available right away
sleep 10
kubectl --context kind-kind apply -f bundle

# give some crds time to register
sleep 20
# and try again
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
if [ "${INSTALL_PROM}" = "yes" ]; then
    helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack
fi;

sleep 5
echo ""
echo "Traefik: http://traefik.localhost"
echo "Dashboard: http://dashboard.localhost"
if [ "${INSTALL_PROM}" = "yes" ]; then
    echo "http://grafana.localhost credentials: $(kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-user| cut -d: -f2|tr -d \  | base64 -d):$(kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-password| cut -d: -f2|tr -d \  | base64 -d)\n"
fi;
