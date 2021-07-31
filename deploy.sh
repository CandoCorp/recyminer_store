# bin/bash

helm install store-recyminer -f helm/values.yml -f helm/secrets.yml stable/lamp
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager --version v0.15.0 --namespace cert-manager jetstack/cert-manager

kubectl create -f ingress.yml
kubectl create -f production_issuer.yml

kubectl get service nginx-ingress-controller
