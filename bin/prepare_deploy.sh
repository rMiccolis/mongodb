#!/bin/bash


# setting variables for tls certificate
KEY_FILE="tls-cert.key"
CERT_FILE="mongodb.pem"

# setting secret for tls certificate
kubectl create secret generic tls-cert --from-file=${CERT_FILE}=$repository_root_dir/tls/tls-cert.pem -n mongodb
kubectl create secret generic mongodb-ca \
  --from-file=ca.crt=/home/apps/mongodb/tls/ca.crt \
  -n mongodb

# use mongod.conf file to tell mongodb to use it for configuration (it contains tls certificates)
# store this mongod.conf containing configuration for mongo inside a configmap that will be loaded inside the container

kubectl create configmap mongodb-config --from-file=$repository_root_dir/apps/mongodb/res/mongod.conf -n mongodb


helm install mongodb bitnami/mongodb \
  -f values.yaml \
  -n mongodb
