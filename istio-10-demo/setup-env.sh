cd /Users/linsun/go/src/github.com/solo-io/workshops/terraform

cat > ./hosts <<EOF
[hosts]
vagrant ansible_host=127.0.0.1 ansible_port=2222 ansible_python_interpreter=/usr/bin/python3 ansible_user=vagrant ansible_ssh_private_key_file=$(pwd)/.vagrant/machines/default/virtualbox/private_key
EOF

vagrant up

ssh-keyscan -p 2222 127.0.0.1 >> $HOME/.ssh/known_hosts
ssh-add $(pwd)/.vagrant/machines/default/virtualbox/private_key
export DOCKER_HOST="ssh://vagrant@127.0.0.1:2222"
vagrant ssh -c "sudo usermod -aG docker vagrant"


cd /Users/linsun/go/src/github.com/solo-io/workshops/scripts

./deploy.sh 1 istio-workshop


cd /Users/linsun/go/src/github.com/solo-io/workshops/terraform
./setup-local.sh

kubectl config use-context istio-workshop

sleep 30