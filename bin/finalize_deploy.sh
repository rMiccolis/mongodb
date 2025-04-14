#!/bin/bash

# pod_name=$(kubectl get pods -n mongodb -l app=mongodb -o jsonpath="{.items[0].metadata.name}")
dirname=$repository_root_dir
cat << EOF | sudo tee $dirname/apps/mongodb/kubernetes/7-mongodb-deployment-tls-config.yaml > /dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  namespace: mongodb
  labels:
    app: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      volumes:
      - name: mongodb-storage
        persistentVolumeClaim:
          claimName: mongodb-pvc
      - name: mongodb-tls-cert
        secret:
          secretName: tls-cert
      - name: mongodb-config-volume
        configMap:
          name: mongodb-config
      containers:
      - name: mongodb
        image: mongo
        command: ["mongod"]
        args: ["--config", "/etc/mongodb/config/mongod.conf"]
        resources:
          requests:
            memory: 256Mi
            cpu: 200m
          limits:
            memory: 256Mi
            cpu: 200m
        ports:
        - containerPort: 27017
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
           secretKeyRef:
             name: mongodb-secret
             key: MONGO-ROOT-USERNAME
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
           secretKeyRef:
             name: mongodb-secret
             key: MONGO-ROOT-PASSWORD
        volumeMounts:
        - name: mongodb-storage
          mountPath: /data/db
        - name: mongodb-tls-cert
          mountPath: /etc/mongodb/tls
        - name: mongodb-config-volume
          mountPath: /etc/mongodb/config
          readOnly: true
EOF

kubectl apply -f $dirname/apps/mongodb/kubernetes/7-mongodb-deployment-tls-config.yaml
# kubectl -n mongodb scale --replicas=0 deployment mongodb
# kubectl -n mongodb scale --replicas=1 deployment mongodb
kubectl rollout status deployment $project_name -n mongodb --timeout=3000s > /dev/null 2>&1
