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


#----------------------------------------- HTTPBin API Product -----------------------------------------

# Create httpbin namespace if it does not exist yet
kubectl create namespace httpbin --dry-run=client -o yaml | kubectl apply -f -

printf "\nDeploy HTTPBin service ...\n"
kubectl apply -f apis/httpbin/httpbin.yaml

# printf "\nDeploy the ReferenceGrant. This is needed for cross-namespace routing ...\n"
kubectl apply -f referencegrants/httpbin-ns/httproute-default-service-rg.yaml

kubectl apply -f upstreams/httpbin-upstream.yaml

#----------------------------------------- api.example.com HTTPRoute -----------------------------------------

# Label the default namespace, so the gateway will accept the HTTPRoute from that namespace.
printf "\nLabel default namespace ...\n"
kubectl label namespaces default --overwrite shared-gateway-access="true"

printf "\nDeploy the HTTPRoute ...\n"
kubectl apply -f routes/api-example-com-httproute.yaml


#----------------------------------------- api.example.com VirtualService -----------------------------------------

# Apply the VirtualService
kubectl apply -f virtualservices/api-example-com-vs.yaml

popd
