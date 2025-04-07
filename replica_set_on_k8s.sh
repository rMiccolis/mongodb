kubectl apply -f ./kubernetes/0-mongodb-namespace.yaml
kubectl apply -f ./kubernetes/2-mongodb-rbac.yaml
kubectl apply -f ./kubernetes/3-mongodb-secrets.yaml
kubectl apply -f ./kubernetes/4-mongodb-pv.yaml
kubectl apply -f ./kubernetes/5-mongodb-pvc.yaml

create statefulset if mongodb replicas are more than 1
instructions for statefulset mongodb
if [ "$mongodb_replica_count" != "1" ]; then
    kubectl apply -f ./kubernetes/2-mongodb/1-mongodb-headless_service.yaml
    kubectl apply -f ./kubernetes/2-mongodb/6-mongodb-statefulset.yaml
    # let's wait for mongodb stateful set to be ready
    exit_loop=""
    ready_sts_condition="$mongodb_replica_count/$mongodb_replica_count"
    while [ "$exit_loop" != "$ready_sts_condition" ]; do
        sleep 10
        exit_loop=$(kubectl get sts -n mongodb | awk 'NR==2{print $2}')
        echo "StatefulSet pod ready: $exit_loop"
    done
    echo -e "${LBLUE}Configuring Mongodb statefulset...${WHITE}"
    # when all mongodb replicas are created, let's setup the replicaset
    members=()
    for i in $(seq $mongodb_replica_count); do
        replica_index="$(($i-1))"
        if [ "$i" != "$mongodb_replica_count" ]; then
            member_str="{ _id: $replica_index, host : '"mongodb-replica-$replica_index.mongodb:27017"' },"
        else
            member_str="{ _id: $replica_index, host : '"mongodb-replica-$replica_index.mongodb:27017"' }"
        fi
        members+=($member_str)
    done
    initiate_command="rs.initiate({ _id: 'rs0',version: 1,members: [ ${members[@]} ] })"
    kubectl exec -n mongodb mongodb-replica-0 -- mongosh --eval "$initiate_command"

    echo -e "${LBLUE}EXECUTED: kubectl exec -n mongodb mongodb-replica-0 -- mongosh --eval '$initiate_command' ${WHITE}"

    kubectl exec -n mongodb mongodb-replica-0 -- mongosh --eval "rs.status()"
fi

kubectl apply -f /home/$USER/temp/2-mongodb/1-mongodb-service.yaml
kubectl apply -f /home/$USER/temp/2-mongodb/6-mongodb-deployment.yaml