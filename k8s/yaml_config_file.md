in a pod definition, there is 4 required fields

```yaml
apiVersion: v1
kind: Pod
metadata:


spec:
    containers:
        - name: nginx-container
          image: nginx


```

`apiVersion` We set the version to v1 since we are working with pods

`kind` is the type of the object we wanna create, it can be POD, service, ReplicaSet or  Deployment

`Metadata` is data about the object such as its name, label , etc

`spec` data on how k8s can create the kind we provided here it provides what container should be run in the pod

ReplicaSet config file sample

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-1
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
```

get the definition of a running rs if we lost the yaml file

        kubectl get rs name-of-set -o yaml

  