Omnia

master-1 and master-2
Network
	direct link to omnia for public internet, configured using static ipv6
	link to serv network, ideally sfp+ 10GB
	link to mgmt network, ideally sfp+ 10GB
	link to stor network, ideally sfp+ 10GB
Software
	Loadbalancers for Kubernetes and Openshift
	DNS for Kubernetes and Openshift
	HA using keepalived


storage-1 and storage-2
Network
	link to stor network, must have 10GB sfp+
Software
	glusterfs


control-1, control-2 and control-3
Network
	link to serv network, ideally sfp+ 10GB
	link to mgmt network, ideally sfp+ 10GB
	link to stor network, ideally sfp+ 10GB
Software
	Kubernetes Master nodes, using mgmt Network for default Communication in between nodes
		and serv network for exposing ingresses

worker-1 and worker-2
	Kubernetes Worker Nodes exposing services on serv network