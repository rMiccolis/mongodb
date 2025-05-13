#!/bin/bash


# setting variables for tls certificate
KEY_FILE="tls-cert.key"
CERT_FILE="mongodb.pem"

# setting secret for tls certificate
awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' $repository_root_dir/tls/tls-cert.pem > mongodb-ca-key.pem
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' $repository_root_dir/tls/tls-cert.pem > mongodb-ca-cert.pem

kubectl -n mongodb create secret generic mongodb-ca-secret \
    --from-file=mongodb-ca-cert=./mongodb-ca-cert.pem \
    --from-file=mongodb-ca-key=./mongodb-ca-key.pem

helm install mongodb oci://registry-1.docker.io/bitnamicharts/mongodb -n mongodb -f $repository_root_dir/apps/mongodb/res/values.yaml
