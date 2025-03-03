#!/bin/sh

CLUSTER_NAME="gg-demo-single"
GLOO_PLATFORM_VERSION="2.6.9"
GLOO_PLATFORM_HELM_VALUES_FILE="gloo-mesh-helm-values.yaml"

if [ -z "$GLOO_GATEWAY_LICENSE_KEY" ]
then
   echo "Gloo Gateway License Key not specified. Please configure the environment variable 'GLOO_GATEWAY_LICENSE_KEY' with your Gloo Gateway License Key."
   exit 1
fi

if [ -z "$GLOO_MESH_LICENSE_KEY" ]
then
   echo "Gloo MESH License Key not specified. Please configure the environment variable 'GLOO_MESH_LICENSE_KEY' with your Gloo Mesh License Key."
   exit 1
fi

# First, install Gateway API and Gloo Gateway on the management cluster to make sure CRDs are present:
printf "\nApply K8S Gateway CRDs ....\n"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# Install Gloo Mesh CRDS
helm upgrade --install gloo-platform-crds gloo-platform/gloo-platform-crds \
  --namespace gloo-mesh \
  --create-namespace \
  --version $GLOO_PLATFORM_VERSION

helm upgrade --install gloo-platform gloo-platform/gloo-platform \
  --namespace gloo-mesh \
  --version $GLOO_PLATFORM_VERSION \
  --values $GLOO_PLATFORM_HELM_VALUES_FILE \
  --set common.cluster=$CLUSTER_NAME \
  --set licensing.glooMeshLicenseKey=$GLOO_MESH_LICENSE_KEY \
  --set licensing.glooGatewayLicenseKey=$GLOO_GATEWAY_LICENSE_KEY
