#!/bin/bash

USER=claudio # customizable
sudo mkdir -p /etc/kubernetes/pki/etcd
sudo mv /home/${USER}/ca.crt /etc/kubernetes/pki/
sudo mv /home/${USER}/ca.key /etc/kubernetes/pki/
sudo mv /home/${USER}/sa.pub /etc/kubernetes/pki/
sudo mv /home/${USER}/sa.key /etc/kubernetes/pki/
sudo mv /home/${USER}/front-proxy-ca.crt /etc/kubernetes/pki/
sudo mv /home/${USER}/front-proxy-ca.key /etc/kubernetes/pki/
sudo mv /home/${USER}/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
sudo mv /home/${USER}/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
sudo mv /home/${USER}/admin.conf /etc/kubernetes/admin.conf
sudo mkdir -p /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config

sudo mkdir -p /home/${USER}/.kube
sudo cp /etc/kubernetes/admin.conf /home/${USER}/.kube/config
sudo chown -R ${USER}: /home/${USER}/.kube



sudo systemctl enable kubelet

sudo kubeadm join 10.20.10.20:6443 --token <token> --discovery-token-ca-cert-hash sha256:<cert-hash> --experimental-control-plane