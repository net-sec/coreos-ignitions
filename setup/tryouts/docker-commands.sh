#coreos-1
docker run -d --net=host --cap-add NET_ADMIN \
--restart=unless-stopped					 \
-e KEEPALIVED_AUTOCONF=true                  \
-e KEEPALIVED_STATE=MASTER                   \
-e KEEPALIVED_INTERFACE=enp0s3               \
-e KEEPALIVED_VIRTUAL_ROUTER_ID=1            \
-e KEEPALIVED_UNICAST_SRC_IP=10.20.1.51      \
-e KEEPALIVED_UNICAST_PEER_0=10.20.1.52      \
-e KEEPALIVED_UNICAST_PEER_1=10.20.1.53      \
-e KEEPALIVED_TRACK_INTERFACE_1=enp0s3       \
-e KEEPALIVED_VIRTUAL_IPADDRESS_1="10.20.1.50/24 dev enp0s3" \
arcts/keepalived

docker run -d -p 8080:8080 -p 6444:6443 -e LB_HOST=$(hostname) --restart=unless-stopped --name=k8s-haproxy walser/haproxy:latest



#coreos-2
docker run -d --net=host --cap-add NET_ADMIN \
--restart=unless-stopped					 \
-e KEEPALIVED_AUTOCONF=true                  \
-e KEEPALIVED_STATE=BACKUP                   \
-e KEEPALIVED_INTERFACE=enp0s3               \
-e KEEPALIVED_VIRTUAL_ROUTER_ID=1            \
-e KEEPALIVED_UNICAST_SRC_IP=10.20.1.52      \
-e KEEPALIVED_UNICAST_PEER_0=10.20.1.51      \
-e KEEPALIVED_UNICAST_PEER_1=10.20.1.53      \
-e KEEPALIVED_TRACK_INTERFACE_1=enp0s3       \
-e KEEPALIVED_VIRTUAL_IPADDRESS_1="10.20.1.50/24 dev enp0s3" \
arcts/keepalived

docker run -d -p 8080:8080 -p 6444:6443 -e LB_HOST=$(hostname) --restart=unless-stopped --name=k8s-haproxy walser/haproxy:latest


#coreos-3
docker run -d --net=host --cap-add NET_ADMIN \
--restart=unless-stopped					 \
-e KEEPALIVED_AUTOCONF=true                  \
-e KEEPALIVED_STATE=BACKUP                   \
-e KEEPALIVED_INTERFACE=enp0s3               \
-e KEEPALIVED_VIRTUAL_ROUTER_ID=1            \
-e KEEPALIVED_UNICAST_SRC_IP=10.20.1.53      \
-e KEEPALIVED_UNICAST_PEER_0=10.20.1.51      \
-e KEEPALIVED_UNICAST_PEER_1=10.20.1.52      \
-e KEEPALIVED_TRACK_INTERFACE_1=enp0s3       \
-e KEEPALIVED_VIRTUAL_IPADDRESS_1="10.20.1.50/24 dev enp0s3" \
arcts/keepalived

docker run -d -p 8080:8080 -p 6444:6443 -e LB_HOST=$(hostname) --restart=unless-stopped --name=k8s-haproxy walser/haproxy:latest

