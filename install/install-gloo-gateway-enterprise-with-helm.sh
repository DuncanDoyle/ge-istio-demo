#!/bin/sh

export GLOO_GATEWAY_VERSION="1.17.0"
export GLOO_MESH_VERSION="2.6.0-rc1"

export GLOO_GATEWAY_HELM_VALUES_FILE="gloo-gateway-helm-values.yaml"
export GLOO_MESH_HELM_VALUES_FILE="gloo-mesh-helm-values.yaml"

export GLOO_MESH_CLUSTER_NAME="gm-demo-single"

if [ -z "$GLOO_GATEWAY_LICENSE_KEY" ]
then
   echo "Gloo Gateway License Key not specified. Please configure the environment variable 'GLOO_GATEWAY_LICENSE_KEY' with your Gloo Gateway License Key."
   exit 1
fi

if [ -z "$GLOO_MESH_LICENSE_KEY" ]
then
   echo "Gloo Mesh License Key not specified. Please configure the environment variable 'GLOO_GATEWAY_LICENSE_KEY' with your Gloo Gateway License Key."
   exit 1
fi

# You need to install the GME CRDs first, i.e. before installing Gloo GATEWAY. If not, the GME CRDs will fail to install.
# See https://github.com/solo-io/gloo-mesh-enterprise/issues/14143

printf "\nInstalling Gloo Mesh CRDs\n"
helm upgrade --install gloo-platform-crds gloo-platform/gloo-platform-crds \
   --namespace=gloo-mesh \
   --create-namespace \
   --version $GLOO_MESH_VERSION
printf "\n"

printf "\nCreate gloo-mesh-addons namespace if it does not yet exist.\n"
kubectl create namespace gloo-mesh-addons --dry-run=client -o yaml | kubectl apply -f -

printf "\nInstalling Gloo Mesh $GLOO_MESH_VERSION ...\n"
helm upgrade --install gloo-platform gloo-platform/gloo-platform \
   --namespace gloo-mesh \
   --version $GLOO_MESH_VERSION \
   --values $GLOO_MESH_HELM_VALUES_FILE \
   --set common.cluster=$GLOO_MESH_CLUSTER_NAME \
   --set licensing.glooMeshLicenseKey=$GLOO_MESH_LICENSE_KEY
   # --set licensing.glooGatewayLicenseKey=$GLOO_GATEWAY_LICENSE_KEY \
printf "\n"


#----------------------------------------- Install Gloo Gateway with K8S Gateway API support -----------------------------------------

printf "\nApply K8S Gateway CRDs ....\n"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


printf "\nInstalling Gloo GATEWAY $GLOO_GATEWAY_VERSION ...\n"
helm upgrade --install gloo glooe/gloo-ee --namespace gloo-system --create-namespace --set-string license_key=$GLOO_GATEWAY_LICENSE_KEY -f $GLOO_GATEWAY_HELM_VALUES_FILE --version $GLOO_GATEWAY_VERSION
printf "\n"


pushd ../
#----------------------------------------- Deploy the Gateway -----------------------------------------

# create the ingress-gw namespace
kubectl create namespace ingress-gw --dry-run=client -o yaml | kubectl apply -f -

printf "\nDeploy the Gateway ...\n"
kubectl apply -f gateways/gw.yaml





popd