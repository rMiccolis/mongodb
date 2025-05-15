# setting variables for tls certificate
KEY_FILE="tls-cert.key"
CERT_FILE="mongodb.pem"

# setting secret for tls certificate
mkdir $repository_root_dir/tls/mongodb
awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' $repository_root_dir/tls/tls-cert.pem > $repository_root_dir/tls/mongodb/mongodb-ca-key.pem
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' $repository_root_dir/tls/tls-cert.pem > $repository_root_dir/tls/mongodb/mongodb-ca-cert.pem

kubectl -n mongodb create secret generic mongodb-ca-secret \
    --from-file=mongodb-ca-cert=$repository_root_dir/tls/mongodb/mongodb-ca-cert.pem \
    --from-file=mongodb-ca-key=$repository_root_dir/tls/mongodb/mongodb-ca-key.pem

helm install mongodb oci://registry-1.docker.io/bitnamicharts/mongodb -n mongodb -f $repository_root_dir/apps/mongodb/env_subsitution/values.yaml

kubectl rollout status deployment mongodb -n $namespace --timeout=3000s > /dev/null 2>&1
kubectl wait --for=condition=Ready --all pods --all-namespaces --timeout=3000s &
wait

# # copy /certs/mongodb.pem from mongodb pod to local file system
# mongodb_podname=$(kubectl get pods -n mongodb | awk 'NR==2{print $1}')
# kubectl -n mongodb cp ${mongodb_podname}:/certs/mongodb.pem ${repository_root_dir}/tls/mongodb/mongodb.pem