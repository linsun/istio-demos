#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0"
desc "I have Istio 1.8.3 and $TAG on my cluster"
run "cd istio-$TAG/"
run "kubectl get pods,svc,mutatingwebhookconfigurations -n istio-system"

desc "What is the data plane overall status?"
run "bin/istioctl version"

desc "What is the web-api pod data plane status?"
run "bin/istioctl proxy-status | grep web-api | awk '{print $7}'"

desc "check the rev label of istioinaction namespace"
run "kubectl get namespace istioinaction -L istio.io/rev"

desc "How can I tag Istio $TAG canary?"
run "bin/istioctl x revision tag set canary --revision 1-10-0"

desc "Testing with the new version - label namespace istioinaction canary"
run "kubectl label namespace istioinaction istio.io/rev=canary --overwrite"
desc "Deploy web-api-canary.yaml to istioinaction namespace"
run "cat ../web-api-canary.yaml"
run "kubectl apply -f ../web-api-canary.yaml -n istioinaction"

desc "check web-api pod data plane status"
run "bin/istioctl proxy-status | grep web-api | awk '{print $7}'"

desc "Testing...send some traffic to web-api from the sleep pod"
run "kubectl exec -it deploy/sleep -- curl http://web-api.istioinaction:8080/"

desc "Open up Kiali using istioctl dashboard kiali and generate some load"
run "kubectl get secret -n istio-system -o jsonpath="{.data.token}" $(kubectl get secret -n istio-system | grep kiali-dashboard | awk '{print $1}' ) | base64 --decode"

desc "Restart web-api to pick up the proxy from $TAG"
run "kubectl rollout restart deployment web-api -n istioinaction"

# desc "Testing...send some traffic to web-api"
# run "kubectl exec -it deploy/sleep -- curl http://web-api.istioinaction:8080/"

desc "Delete the web-api-canary deployment"
run "kubectl delete deployment web-api-canary -n istioinaction"

desc "Check web-api pod data plane status"
run "bin/istioctl proxy-status | grep web-api | awk '{print $7}'"

desc "Check data plane overall status"
run "bin/istioctl version"

# desc "Update Istio ingress gateway canary."
# run "cat ../ingress-gateways-injection-canary.yaml"
# run "kubectl apply -f ../ingress-gateway-injection-canary.yaml -n istio-ingress"
# run "kubectl get pods -n istio-ingress"
# run "bin/istioctl proxy-status | grep istio-ingressgateway | awk '{print $7}'"

# desc "Update Istio ingress gateway to use gateway injection."
# run "cat ../ingress-gateways-injection.yaml"
# run "kubectl apply -f ../ingress-gateway-injection.yaml -n istio-ingress"
# run "kubectl get pods -n istio-system"
# run "bin/istioctl proxy-status | grep istio-ingressgateway | awk '{print $7}'"

desc "Update Istio ingress gateway...in place?"
run "cat ../ingress-gateways.yaml"
run "bin/istioctl install -y -n istio-ingress -f ../ingress-gateways.yaml --revision 1-10-0"
run "kubectl get pods -n istio-ingress"
run "bin/istioctl proxy-status | grep istio-ingressgateway | awk '{print $7}'"

desc "Validate web-api can be accessed from istio-ingressgateway"
run "kubectl get svc -n istio-ingress istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}""
GATEWAY_IP=$(kubectl get svc -n istio-ingress istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
desc "curl -H \"Host: istioinaction.io\" http://$GATEWAY_IP"
#run "cd  ~/go/src/github.com/solo-io/workshops/terraform"
#run "vagrant ssh"




