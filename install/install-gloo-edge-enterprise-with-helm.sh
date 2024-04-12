#!/bin/sh

export GLOO_EDGE_VERSION="1.16.5"
export GLOO_MESH_VERSION="2.5.5"

export GLOO_EDGE_HELM_VALUES_FILE="gloo-edge-helm-values.yaml"
export GLOO_MESH_HELM_VALUES_FILE="gloo-mesh-helm-values.yaml"

export GLOO_MESH_CLUSTER_NAME="gm-demo-single"

if [ -z "$GLOO_EDGE_LICENSE_KEY" ]
then
   echo "Gloo Edge License Key not specified. Please configure the environment variable 'GLOO_EDGE_LICENSE_KEY' with your Gloo Edge License Key."
   exit 1
fi

if [ -z "$GLOO_MESH_LICENSE_KEY" ]
then
   echo "Gloo Mesh License Key not specified. Please configure the environment variable 'GLOO_EDGE_LICENSE_KEY' with your Gloo Edge License Key."
   exit 1
fi

# You need to install the GME CRDs first, i.e. before installing Gloo Edge. If not, the GME CRDs will fail to install.
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

printf "\nInstalling Gloo Edge $GLOO_EDGE_VERSION ...\n"
helm upgrade --install gloo glooe/gloo-ee --namespace gloo-system --create-namespace --set-string license_key=$GLOO_EDGE_LICENSE_KEY -f $GLOO_EDGE_HELM_VALUES_FILE --version $GLOO_EDGE_VERSION
printf "\n"
