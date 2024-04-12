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

# Label the default namespace for Istio sidecar injection ...
kubectl label namespace default istio-injection=enabled

# Apply the HTTPBin sevice
kubectl apply -f apis/httpbin.yaml

# Apply the Istio Peer Authentication policy.
kubectl apply -f policies/istio/peer-authentication-policy.yaml

# Apply the VirtualService
kubectl apply -f virtualservices/api-example-com-vs.yaml

# Configure mTLS on the HTTPBin Upstream,
printf "\nConfiguring mTLS on default HTTPBin Upstream ...\n"
sleep 2
glooctl istio enable-mtls --upstream default-httpbin-8000
# glooctl istio disable-mtls --upstream default-httpbin-8000

popd
