#!/bin/bash

. route.sh

CNI_VERSION="v0.7.4"
CRICTL_VERSION="v1.13.0"
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

function installCniTools() {
	sudo mkdir -p /opt/cni/bin
	curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz
}


function installCriTools() {
	sudo mkdir -p /opt/bin
	curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | sudo tar -C /opt/bin -xz
}



function installKubeTools() {
	sudo mkdir -p /opt/bin
	sudo cd /opt/bin
	sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
	sudo chmod +x {kubeadm,kubelet,kubectl}
	cd -
}

function installKubelet() {
	curl -L --remote-name-all "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service"
	sed "s:/usr/bin:/opt/bin:g"  kubelet.service
	sudo mv kubelet.service /etc/systemd/system/kubelet.service
	
	mkdir -p /etc/systemd/system/kubelet.service.d
	curl -L --remote-name-all "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf"
	sed "s:/usr/bin:/opt/bin:g" 10-kubeadm.conf
	sudo mv 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
}


installCniTools
installCriTools
installKubeTools
installKubelet
