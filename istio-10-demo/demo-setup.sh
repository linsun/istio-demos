#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0-rc.1"
desc "I have Istio 1.8.3 and a few pods on my cluster"
run "kubectl get services -n istio-system"
run "kubectl get pods -A"

desc "Let us download Istio $TAG"
run "wget https://github.com/istio/istio/releases/download/$TAG/istio-$TAG-osx.tar.gz"
run "tar -xvf istio-$TAG-osx.tar.gz"
run "cd istio-$TAG/bin/"

desc "Display istioctl version"
run "./istioctl version"

desc "Check if it is safe to install Istio 1.10"
run "./istioctl x precheck"
run "./istioctl analyze"

desc "Install Istiod 1.10"
run "cat ../../control-plane.yaml"
run "./istioctl install -y -n istio-system --revision 1-10-0 -f ../../control-plane.yaml"

desc "Check Istiod $TAG pods"
run "kubectl get pods -n istio-system"

desc "Check connections to Istiod $TAG"
run "kubectl exec -n istio-system -it deploy/istiod-1-10-0 -- pilot-discovery request GET /debug/connections"

desc "Check services to Istiod $TAG"
run "kubectl exec -n istio-system -it deploy/istiod-1-10-0 -- pilot-discovery request GET /debug/registryz"
