#!/bin/bash

. /etc/env

# kubeinit
mkdir -p /home/claudio/kubecfg/
cat > /home/claudio/kubecfg/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
apiServer:
  certSANs:
  - "${MGMT_KEEPALIVED_VIP}"
controlPlaneEndpoint: "${MGMT_KEEPALIVED_VIP}:6443"
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

# taint master nodes
kubectl taint nodes --all node-role.kubernetes.io/master-

# enable kubelet service
sudo systemctl enable kubelet
