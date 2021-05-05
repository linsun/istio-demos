#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD
TAG="1.10.0-rc.0"
desc "I have Istio 1.8.3 on my cluster"
run "kubectl get pods -n istio-system"

desc "Let's download Istio 1.10 rc build"
run "wget https://github.com/istio/istio/releases/download/1.10.0-rc.0/istio-$TAG-linux-arm64.tar.gz"
run "tar -xvf istioctl-$TAG-linux-amd64.tar.gz"