#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0-rc.0"
desc "I have Istio 1.8.3 and $TAG on my cluster"
run "cd istio-$TAG/bin/"
run "kubectl get pods,svc,mutatingwebhookconfigurations -n istio-system"

desc "check data plane overall status"
run "./istioctl version"

desc "check web-api pod data plane status"
run "./istioctl proxy-status | grep web-api | awk '{print $7}'"

desc "check the istioinaction namespace"
run "kubectl get namespace istioinaction -L istio.io/rev"

desc "use revision tag command to tag Istio $TAG canary"
run "./istioctl x revision tag set canary --revision 1-10-0"

desc "Testing with the new version - label namespace istioinaction canary"
run "kubectl label namespace istioinaction istio.io/rev=canary --overwrite"
desc "Deploy web-api-canary.yaml to istioinaction namespace"
run "cat ../../web-api-canary.yaml"
run "kubectl apply -f ../../web-api-canary.yaml -n istioinaction"

desc "check web-api pod data plane status"
run "./istioctl proxy-status | grep web-api | awk '{print $7}'"

desc "Testing...send some traffic to web-api"
run "kubectl exec -it deploy/sleep -- curl http://web-api.istioinaction:8080/"

desc "Restart web-api to pick up the proxy from $TAG"
run "kubectl rollout restart deployment web-api -n istioinaction"

desc "Testing...send some traffic to web-api"
run "kubectl exec -it deploy/sleep -- curl http://web-api.istioinaction:8080/"

desc "Delete the web-api-canary deployment"
run "kubectl delete deployment web-api-canary -n istioinaction"

desc "Check web-api pod data plane status"
run "./istioctl proxy-status | grep web-api | awk '{print $7}'"

desc "Check data plane overall status"
run "./istioctl version"

desc "Update Istio ingress gateway...in place"
run "cat ../../ingress-gateways.yaml"
run "./istioctl install -y -n istio-system -f ../../ingress-gateways.yaml --revision 1-10-0"
run "kubectl get pods -n istio-system"
run "./istioctl proxy-status | grep istio-ingressgateway | awk '{print $7}'"

desc "Validate web-api can be accessed from istio-ingressgateway"
"GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}")"
desc "curl -H \"Host: istioinaction.io\" http://$GATEWAY_IP"


