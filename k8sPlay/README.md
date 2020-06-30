# K8s Play

## Steps
  - deploy simple resources
  - deploy redis cache node
  - clean up

### deploy simple resources
 - look at the counting service app deployment definition
 ```bash
 cat yaml-minimal/counting-deployment.yaml
 ```
 - apply counting service via kubectl
 ```bash
 kubectl apply -f yaml-minimal/counting-deployment.yaml
 ```
 - check the log to verify all is well **NOTE**: should see Serving at http://localhost:9001 in the stdout
 ```bash
 kubectl get pods
 ```
 ```bash
 kubectl logs <name of pod>
 ```
 **NOTE**: spoiler alert; the pod's name is counting-minimal-pod
 - it's local, so we can leverage the power of k8s to forward the port...
 ```bash
 kubectl port-forward pod/counting-minimal-pod 9001:9001
 ```
 - then [look at it](http://localhost:9001)
 - now let's look at the node port
 ```bash
 cat yaml-minimal/counting-node-port.yaml
 ```
 - apply it with kubectl
 ```bash
 kubectl apply -f yaml-minimal/counting-node-port.yaml
 ```

### deploy Redis cache
 - look at the Redis cache definition
 ```bash
 cat redis-cache/redis.yaml
 ```
 - apply counting service via kubectl
 ```bash
 kubectl apply -f redis-cache/redis.yaml
 ```

- inspect the distribution pods
```bash
kubectl get pods -l app=redis -o wide
```

Note that since we have specified 5 replicas of the cache pods, with a podAntiAffinity clause to ensures that a node runs one and only one Redis Pod. Therefore one or more pods might be in Pending status.

### clean up
We don't need any of this anymore, it was just for fun...please be responsible and kill it!
```bash
kubectl delete -f yaml-minimal/counting-deployment.yaml && kubectl delete -f yaml-minimal/counting-node-port.yaml
```

It's time to go back to lecture...
