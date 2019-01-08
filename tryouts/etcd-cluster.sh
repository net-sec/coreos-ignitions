#Defaults or even better .env file
TOKEN=very-unique
CLUSTER_STATE=new
declare -A IP
IP[coreos-1]=10.20.1.51
IP[coreos-2]=10.20.1.52
IP[coreos-3]=10.20.1.53

CLUSTER=""
LOOP=0
for index in ${!IP[*]}
do
  CLUSTER+="$index=http://${IP[$index]}:2380"
  if [ $LOOP != 2 ]
  then
    CLUSTER+=","
  fi
  LOOP=$LOOP+1
done

# For machine 1
THIS_NAME=$(hostname) # [1,2,3] in a cluster of three nodes
THIS_IP=${IP[$THIS_NAME]} # [1,2,3] in a cluster of three nodes


rm -rf /tmp/etcd-data.tmp && mkdir -p /tmp/etcd-data.tmp && \
  docker image pull gcr.io/etcd-development/etcd:v3.3.10 || true && \
  docker rm -f ${THIS_NAME} || true && \
  docker run \
  --name ${THIS_NAME} \
  -p ${THIS_IP}:2379:2379 \
  -p ${THIS_IP}:2380:2380 \
  --mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
  gcr.io/etcd-development/etcd:v3.3.10 \
  /usr/local/bin/etcd \
  --name ${THIS_NAME} \
  --data-dir /etcd-data \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://${THIS_IP}:2379 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-token ${TOKEN} \
  --initial-cluster-state ${CLUSTER_STATE}





# For machine 2
THIS_NAME=${NAME_2}
THIS_IP=${HOST_2}
etcd --data-dir=data.etcd --name ${THIS_NAME} \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 --listen-peer-urls http://${THIS_IP}:2380 \
  --advertise-client-urls http://${THIS_IP}:2379 --listen-client-urls http://${THIS_IP}:2379 \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-state ${CLUSTER_STATE} --initial-cluster-token ${TOKEN}

# For machine 3
THIS_NAME=${NAME_3}
THIS_IP=${HOST_3}
etcd --data-dir=data.etcd --name ${THIS_NAME} \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 --listen-peer-urls http://${THIS_IP}:2380 \
  --advertise-client-urls http://${THIS_IP}:2379 --listen-client-urls http://${THIS_IP}:2379 \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-state ${CLUSTER_STATE} --initial-cluster-token ${TOKEN}