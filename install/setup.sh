#!/bin/sh

####################################################################################
#
# Initiates the GE Istio Demo
#
# Requires an existing Gloo Edge 1.16+ setup and an existing Gloo Mesh Enterprise 2.5.5+ setup.
# Requires the glooctl CLI to be installed.
#
####################################################################################

pushd ../


# # Gloo Gateway FDS Whitelist labels
# kubectl label namespace default discovery.solo.io/function_discovery=enabled


# kubectl label upstream -n myapp myupstream discovery.solo.io/function_discovery=enabled

# # if the Upstream was discovered and is managed by UDS (Upstream Discovery Service)
# # then you can add the label to the service and it will propagate to the Upstream
# kubectl label service -n myapp myservice discovery.solo.io/function_discovery=enabled



# Label the default namespace for Istio sidecar injection ...
# kubectl label namespace default istio-injection=enabled
export REVISION=$(kubectl get pod -L app=istiod -n istio-system -o jsonpath='{.items[0].metadata.labels.istio\.io/rev}')
# echo $REVISION
kubectl label ns default istio.io/rev=$REVISION --overwrite=true

kubectl label ns default shared-gateway-access="true" --overwrite=true



# Apply the HTTPBin sevice
kubectl apply -f apis/httpbin.yaml

# Apply the Istio Peer Authentication policy.
kubectl apply -f policies/istio/peer-authentication-policy.yaml

# Apply the VirtualService
kubectl apply -f virtualservices/api-example-com-vs.yaml

# Configure mTLS on the HTTPBin Upstream,
# printf "\nConfiguring mTLS on default HTTPBin Upstream ...\n"
# sleep 2
# glooctl istio enable-mtls --upstream default-httpbin-8000
# glooctl istio disable-mtls --upstream default-httpbin-8000

popd
