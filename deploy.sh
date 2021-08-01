# bin/bash
helm reset

echo "=========================================================="
echo "CHECKING HELM 3 VERSION (if absent will install latest Helm 3 version) "
set +e
LOCAL_VERSION=$( helm version ${HELM_TLS_OPTION} --template="{{ .Version }}" | cut -c 2- )
# if no Helm 3 locally installed, LOCAL_VERSION will be empty -- will install latest then
set -e

echo "Installing latest Helm 3 client"
  WORKING_DIR=$(pwd)
  mkdir ~/tmpbin && cd ~/tmpbin
  HELM_INSTALL_DIR=$(pwd)
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  export PATH=${HELM_INSTALL_DIR}:$PATH
  cd $WORKING_DIR
helm version ${HELM_TLS_OPTION}

echo "=========================================================="
echo -e "CHECKING HELM releases in this namespace: ${CLUSTER_NAMESPACE}"
helm list ${HELM_TLS_OPTION} --namespace ${CLUSTER_NAMESPACE}

helm repo add stable https://charts.helm.sh/stable --force-update
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update
helm install store-recyminer -f helm/values.yml -f helm/secrets.yml stable/lamp
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml
kubectl delete namespace cert-manager
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager --version v0.15.0 --namespace cert-manager jetstack/cert-manager

kubectl create -f ingress.yml
kubectl create -f staging_issuer.yml

kubectl get service nginx-ingress-controller
