#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0-rc.0"

desc "Validate web-api can be accessed from istio-ingressgateway"
GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
desc "curl -H \"Host: istioinaction.io\" http://$GATEWAY_IP"

desc "Display web-api endpoints and routes"
run "cd istio-$TAG/bin/"
run "./istioctl pc endpoint deploy/web-api -n istioinaction"
run "./istioctl pc routes deploy/web-api -n istioinaction"

desc "Label namespace istioinaction with istio-discovery=enabled"
run "kubectl label namespace istioinaction istio-discovery=enabled"

desc "Configure discovery selectors"
run "cat ../../control-plane-w-discovery.yaml"
run "./istioctl install -y -n istio-system --revision 1-10-0 -f ../../control-plane-w-discovery.yaml"

desc "Display web-api endpoints"
run "./istioctl pc endpoint deploy/web-api -n istioinaction"
run "./istioctl pc routes deploy/web-api -n istioinaction"

desc "Debug commands"
run "./istioctl pc all deploy/web-api -n istioinaction"
run "./istioctl pc all deploy/web-api -n istioinaction -o json > ~/Downloads/output.json"

desc "Display output.json in UI for easy read"

desc "List my revisions"
run "./istioctl x revision list"
run "./istioctl x revision describe 1-10-0"
run "./istioctl x revision describe 1-8-3"

desc "Check connections to Istiod $TAG"
run "kubectl exec -n istio-system -it deploy/istiod-1-10-0 -- pilot-discovery request GET /debug/connections"









