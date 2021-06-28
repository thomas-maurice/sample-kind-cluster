# Sample Kind cluster

This repo aims at showcasing how to create a basic viable [Kind](https://kind.sigs.k8s.io/) cluster with a dynamic volumes provisioner as well as a pre-configured [traefik v2](https://doc.traefik.io/traefik/v2.3/) ingress controller.

## Install Kind
Simply run
```
$ GO111MODULE="on" go get sigs.k8s.io/kind@v0.11.1
```

## Create the cluster
Just run:
```
$ cluster-up.sh
```
Or
```
$ kind create cluster --config cluster.yaml
# untaint the master
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```
Then apply the manifests
```
$ kubectl --context kind-kind apply -f bundle
```

Wait a bit then you should have your traefik dashboard available at [localhost:8080](http://localhost:8080)

You can also install helm:
```
helm init --service-account=tiller
```

The script will also install the k8s dashboard that will be accessible at [dashboard.localhost](http://dashboard.localhost) and the traefik dashboard at [traefik.localhost](http://traefik.localhost/dashboard/#/)
