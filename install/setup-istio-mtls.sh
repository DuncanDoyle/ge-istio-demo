#!/bin/sh

####################################################################################
#
# Initiates the GG Istio Demo
#
# Requires an existing Gloo Edge 1.18.* setup and an existing Gloo Mesh Enterprise 2.6.* setup.
# Requires the glooctl CLI to be installed.
#
####################################################################################

pushd ../


#----------------------------------------- HTTPBin Istio Sidecar Injection -----------------------------------------

# Label the default namespace for Istio sidecar injection ...
# kubectl label namespace httpbin istio-injection=enabled
export REVISION=$(kubectl get pod -L app=istiod -n istio-system -o jsonpath='{.items[0].metadata.labels.istio\.io/rev}')
echo "Istio revision: $REVISION"
kubectl label ns httpbin istio.io/rev=$REVISION --overwrite=true

# Restart the app
kubectl -n httpbin rollout restart deployment httpbin

#----------------------------------------- Enable Peer Authentication -----------------------------------------

# Apply the Istio Peer Authentication policy.
kubectl apply -f policies/istio/peer-authentication-policy.yaml


#----------------------------------------- Set Upstream mTLS -----------------------------------------

# Configure mTLS on the HTTPBin Upstream,
# printf "\nConfiguring mTLS on default HTTPBin Upstream ...\n"
# sleep 2
# glooctl istio enable-mtls --upstream default-httpbin-8000
# glooctl istio disable-mtls --upstream default-httpbin-8000

popd
