#!/bin/bash

# setting variables for tls certificate
KEY_FILE="tls.key"
CERT_FILE="tls.crt"
HOST="$app_server_addr"
#   cert_file_name='tls-cert'
# create a certificate for https protocol
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}" -addext "subjectAltName = DNS:${HOST}"

# create a tls.pem file from combination of $CERT_FILE and $KEY_FILE
cat $KEY_FILE $CERT_FILE > tls.pem
kubectl create secret generic tls --from-file=${CERT_FILE}=tls.pem -n mongodb

# use mongod.conf file to tell mongodb to use it for configuration (it contains tls certificates)
# store this mongod.conf containing configuration for mongo inside a configmap that will be loaded inside the container

kubectl create configmap mongodb-config --from-file=$repository_root_dir/apps/mongodb/res/mongod.conf -n mongodb
