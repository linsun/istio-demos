#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0"

desc "Display web-api endpoints and routes"
run "cd istio-$TAG/"
run "bin/istioctl pc endpoint deploy/web-api -n istioinaction"
run "bin/istioctl pc routes deploy/web-api -n istioinaction"

desc "How can I configure my Istio control plane to see only what is needed?"
desc "Label namespace istioinaction with istio-discovery=enabled"
run "kubectl label namespace istioinaction istio-discovery=enabled"

desc "Do we also need to label the istio-ingress namespace?"
run "kubectl label namespace istio-ingress istio-discovery=enabled"

desc "Configure discovery selectors. Question: can we do this step before labelling the namespaces?"
run "cat ../control-plane-w-discovery.yaml"
run "bin/istioctl install -y -n istio-system --revision 1-10-0 -f ../control-plane-w-discovery.yaml"

desc "Display web-api endpoints"
run "bin/istioctl pc endpoint deploy/web-api -n istioinaction"
run "bin/istioctl pc routes deploy/web-api -n istioinaction"

desc "Can we export all Istio configs for an app?"
run "bin/istioctl pc all deploy/web-api -n istioinaction"
run "bin/istioctl pc all deploy/web-api -n istioinaction -o json > ~/Downloads/output.json"

desc "Display output.json in https://envoyui.solo.io for easy read"
run "open https://envoyui.solo.io"

desc "List my revisions"
run "bin/istioctl x revision list"
run "bin/istioctl x revision describe 1-10-0"
run "bin/istioctl x revision describe 1-8-3"

desc "What are connections to the Istiod $TAG?"
run "kubectl exec -it deploy/sleep -- curl istiod-1-10-0.istio-system:15014/debug/connections"









