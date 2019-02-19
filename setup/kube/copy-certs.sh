#!/bin/bash

USER=claudio
CONTROL_PLANE_IPS="10.20.10.22 10.20.10.23"

sudo cp -R /etc/kubernetes /home/${USER}
sudo chown -R ${USER}: /home/${USER}/kubernetes

for host in ${CONTROL_PLANE_IPS}; do
    scp /home/${USER}/kubernetes/pki/ca.crt "${USER}"@$host:
    scp /home/${USER}/kubernetes/pki/ca.key "${USER}"@$host:
    scp /home/${USER}/kubernetes/pki/sa.key "${USER}"@$host:
    scp /home/${USER}/kubernetes/pki/sa.pub "${USER}"@$host:
    scp /home/${USER}/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:
    scp /home/${USER}/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:
    scp /home/${USER}/kubernetes/pki/etcd/ca.crt "${USER}"@$host:etcd-ca.crt
    scp /home/${USER}/kubernetes/pki/etcd/ca.key "${USER}"@$host:etcd-ca.key
    scp /home/${USER}/kubernetes/admin.conf "${USER}"@$host:
done
