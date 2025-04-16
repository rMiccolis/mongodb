#!/bin/bash


# setting variables for tls certificate
KEY_FILE="tls-cert.key"
CERT_FILE="tls-cert.crt"

# setting secret for tls certificate
kubectl create secret generic tls-cert --from-file=${CERT_FILE}=$repository_root_dir/tls/tls-cert.pem -n mongodb

# use mongod.conf file to tell mongodb to use it for configuration (it contains tls certificates)
# store this mongod.conf containing configuration for mongo inside a configmap that will be loaded inside the container

kubectl create configmap mongodb-config --from-file=$repository_root_dir/apps/mongodb/res/mongod.conf -n mongodb
