#!/bin/bash

. route.sh
. /etc/env

# kubeinit
mkdir -p /home/claudio/kubecfg/
cat > /home/claudio/kubecfg/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
apiServer:
  certSANs:
  - "${IP_SERV}"
controlPlaneEndpoint: "${IP_SERV}:6443"
networking:
  podSubnet: 10.10.0.0/16
EOF
sudo kubeadm init --config=/home/claudio/kubecfg/kubeadm-config.yaml


# copy kube configs
sudo mkdir -p /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config

sudo mkdir -p /home/${USER}/.kube
sudo cp /etc/kubernetes/admin.conf /home/${USER}/.kube/config
sudo chown -R ${USER}: /home/${USER}/.kube

# untainting node
kubectl taint nodes --all node-role.kubernetes.io/master-

# enable kubelet service
sudo systemctl enable kubelet

#apply weave network
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl get pod -n kube-system -w
