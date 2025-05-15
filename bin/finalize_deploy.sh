mongodb_podname=$(kubectl get pods -n mongodb | awk 'NR==2{print $1}')

kubectl -n mongodb cp ${mongodb_podname}:/certs/mongodb.pem ${repository_root_dir}/tls/mongodb/mongodb.pem