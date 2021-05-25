#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0"
desc "I have Istio 1.8.3 and a few pods on my cluster"
run "kubectl get services -n istio-system"
run "kubectl get pods -A"

desc "Let us download Istio $TAG"
run "wget https://github.com/istio/istio/releases/download/$TAG/istio-$TAG-osx.tar.gz"
run "tar -xvf istio-$TAG-osx.tar.gz"
run "cd istio-$TAG/"

desc "What is my istioctl version?"
run "bin/istioctl version"

desc "Is it safe to install Istio 1.10?"
run "bin/istioctl x precheck"
run "bin/istioctl analyze"

desc "Install Istiod 1.10"
run "cat ../control-plane.yaml"
run "bin/istioctl install -y -n istio-system --revision 1-10-0 -f ../control-plane.yaml"

desc "Is the Istiod $TAG pod(s) running?"
run "kubectl get pods -n istio-system"

desc "What are connections to the Istiod $TAG?"
run "kubectl exec -it deploy/sleep -- curl istiod-1-10-0.istio-system:15014/debug/connections"

desc "What are the services and endpoints known to Istiod $TAG?"
run "kubectl exec -it deploy/sleep -- curl istiod-1-10-0.istio-system:15014/debug/registryz"

# desc "install Istio's addons"
# run "kubectl apply -f samples/addons"