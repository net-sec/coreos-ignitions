#!/bin/bash

# install operator
helm repo add storageos https://charts.storageos.com
helm install storageos/storageoscluster-operator --namespace storageos-operator

# create a secret
API_USERNAME=$(echo -n your-api-username | base64)
API_PASSWORD=$(echo -n your-very-secret-string | base64)
kubectl create -f - <<END
apiVersion: v1
kind: Secret
metadata:
  name: "storageos-api"
  namespace: "default"
  labels:
    app: "storageos"
type: "kubernetes.io/storageos"
data:
  apiUsername: ${API_USERNAME}
  apiPassword: ${API_PASSWORD}
END

helm install storageos/storageos                               \
    --name=default-shared-storage                              \
    --version=0.2.x                                            \
    --namespace=storageos                                      \
    --set cluster.join="10.20.10.21\,10.20.10.22\,10.20.10.23" \
    --set csi.enable=true


kubectl -n storageos port-forward svc/storageos 5705:5705