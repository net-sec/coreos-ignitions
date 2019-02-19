#!/bin/bash

kubectl create -f resources/rbac.yaml
helm init --service-account tiller