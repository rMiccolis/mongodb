#!/bin/bash


# setting variables for tls certificate
KEY_FILE="tls-cert.key"
CERT_FILE="mongodb.pem"

# setting secret for tls certificate
awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' $repository_root_dir/tls/tls-cert.pem > $repository_root_dir/tls/mongodb-ca-key.pem
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' $repository_root_dir/tls/tls-cert.pem > $repository_root_dir/tls/mongodb-ca-cert.pem

kubectl -n mongodb create secret generic mongodb-ca-secret \
    --from-file=mongodb-ca-cert=$repository_root_dir/tls/mongodb-ca-cert.pem \
    --from-file=mongodb-ca-key=$repository_root_dir/tls/mongodb-ca-key.pem

# cat $repository_root_dir/apps/mongodb/utils/values.yaml | envsubst | tee $repository_root_dir/apps/mongodb/utils/values-submitted.yaml

helm install mongodb oci://registry-1.docker.io/bitnamicharts/mongodb -n mongodb -f $repository_root_dir/apps/mongodb/utils/values.yaml
