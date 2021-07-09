# K8S

# components

1 - ETCD: a key/value store that stores all relevant data on the cluster such as pods, rs, secrets, ...

2 - api-server: used to communicate with the server ( kubectl use it for example) or we can use api calls, it communicate with all the other components to execute the admins request

3 - Kube controller manager: Controls various components in the system and want to bring it to the desired state:
* Node controller: Monitor the state of the nodes and take action to keep them in line with desired state
* replication controller: Monitor the status of RS and make sure to bring the number of pods to the desired count
* there is some other controllers that basically try to do the same such as deployment controller, namespace Controller, ...

4 - kube scheduler: decides which pod goes on which node

5 - kubelet: actually create the pod on the node. They also send back reports on the status of the ship, ...

6 - kube-proxy: create rules on nodes to forward traffic to the actual pods

# 1st working method

## Deploy using eksctl

1 - Deploy a cluster: https://eksctl.io/usage/creating-and-managing-clusters/

        eksctl create cluster -f cluster.yaml

_ eksctl, will create a cfn template where it creates an eks cluster with all the needed networking ( vpc included). it will also creates a nodegroup worker ( or something else such as builder) with another cfn, the node group worker contains autoscaling group, roles and sg for ec2_

We can check the number of nodes we have using 

        kubectl get nodes

for more info about os running on nodes or other stuff

        kubectl get nodes -o wide

2- Deploy a deployment (https://kubernetes.io/docs/tutorials/stateless-application/guestbook/)

        kubectl apply -f mango-deployment.yaml

We can check deployments and pods using 

        kubectl get deployments
        kubectl get pods
        kubectl get rs

To check and get everything created we can run 

        kubectl get all


we get logs: 

        kubectl logs -f deployment/mongo

3 - create the services (Creating the MongoDB Service as an example):

The guestbook application needs to communicate to the MongoDB to write its data. You need to apply a Service to proxy the traffic to the MongoDB Pod. A Service defines a policy to access the Pods.

we can get our services: 

        kubectl get services

note: we can query pods using labels as filters ( (label = tags cause GCP) name was set in a deployment file to guestbook)

        kubectl get pods -l app.kubernetes.io/name=guestbook

To scale up or down (based on the number of replicas compared to current numbers) the deployment called "frontend" we run

        kubectl scale deployment frontend --replicas=2

To clean up we need to delete all the deployments and the services

        kubectl delete deployment -l app.kubernetes.io/name=mongo
        kubectl delete service -l app.kubernetes.io/name=mongo
        kubectl delete deployment -l app.kubernetes.io/name=guestbook
        kubectl delete service -l app.kubernetes.io/name=guestbook

We can also create secrets and storage: details in here: https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

more details on eks : https://eksctl.io/introduction/


# 2st working method


we deploy using ekscli as well but we continue managing using helm


## introduction to helm

Helm is the package manager for Kubernetes

Three Big Concepts

- A Chart is a Helm package. It contains all of the resource definitions necessary to run an application, tool, or service inside of a Kubernetes cluster. Think of it like the Kubernetes equivalent of a Homebrew formula, an Apt dpkg, or a Yum RPM file

- A Repository is the place where charts can be collected and shared. It's like Perl's CPAN archive or the Fedora Package Database, but for Kubernetes packages.

- A Release is an instance of a chart running in a Kubernetes cluster.

1 - we install helm client locally and its server `tiller` as part of kube-system in our k8s cluster

        helm init

2 - helm init will do some stuff and get some file and set an env variable to point to a home path that contains files and folders, we then install our sample app using 

        helm lint sample # this is for linting
        helm install --name sample sample

3 - we can list and delete charts as well ofc

        helm list
        helm delete sample


## Deploying with terraform 

https://learn.hashicorp.com/tutorials/terraform/eks


## Production considerations

 requirements for a Kubernetes cluster are influenced by the following issues:

 - Availability
 - Scale
 - Security and access management


#### Production cluster setup:


- Choose deployment tools
- Manage certificates
- Configure load balancer for apiserver
- Separate and backup etcd service
- Create multiple control plane systems
- Span multiple zones
- Manage on-going features


resources: https://kubernetes.io/docs/setup/best-practices/ , https://kubernetes.io/docs/setup/production-environment/



# other Resources

[kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)



# Theoretical definitions

## Pod

- generally run a single container
- we can run multiple container in a simple pod but it is usually a helper container
- all container inside a single pod share the same networking resources (ie have the same ip)
- pods lives in a node
- pods can span multiple or single nodes
- when creating a pod with yaml we set the kind to `POD`
- multi-container pod are a solution where we want a couple of container running always together, These containers inside the pods thus share the same lifecycle, same networking (can refer the each others using localhost) and the same storage (design types are sidecar, embassador and adapter)
- In a multi-container pod, each container is expected to run a process that stays alive as long as the POD's lifecycle. If any of them fails, the POD restarts.
- But at times you may want to run a process that runs to completion in a container. This is initContainers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  nodeName: node_name
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ;']
```

We can have multiple initContainers running sequentially

- When a POD is first created the initContainer is run, and the process in the initContainer must run to a completion before the real container hosting the application starts. 
- If any of the initContainers fail to complete, Kubernetes restarts the Pod repeatedly until the Init Container succeeds.
- Check this for more info on initContainers: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/


## ReplicaSet

- Make sure the number of requested resources are met 
- even if we have just 1 pod rs will make sure to bring a new one if that goes down
- when creating a rs with yaml we set the kind to `ReplicaSet`  (version: `apps/v1`)

## Deployments

- come higher in the hierarchy and engulf rs, 
- when creating a deployment with yaml we set the kind to `Deployment`  (version: `apps/v1`)
- definition of the yaml is similar to the rs
- we usually update deployments using 2 strategies, rollingUpdates or recreate:
        * recreate: delete old the create new
        * rollingUpdates: create new then delete old one by one


to update a deployment we just need to apply the new config file

useful commands:

        kubeclt rollout status deployments/deployments-name
        kubeclt rollout history deployments/deployments-name
        kubeclt rollout undo deployments/deployments-name


## services

- each pods have a proper IP address inside a node
- nodes have IP addresses but are of a different subnet then the Pods ( for example nodes 10.x.x.x and pods 172.16.x.x)
- Pods can go down and new ones are provisioned so we can't rely on pods' IP addresses for networking
- when creating a service with yaml we set the kind to `Service`  (version: `v1`)
- service types can be `NodePort`, `loadBalancer` or `ClusterIp`
- to create a service we just need to use kubectl to apply the yaml configuration
- NodePort allow access from users end to the pods inside the nodes by mapping ports
- ClusterIp is a service that allow internal communication between different (layers of) pods
- LoadBalancer just load balance all traffic to the pods via a single IP/DNS for end users

To get current services:

        kubectl get svc
        kubectl describe service

## namespaces

- used to isolate resources from each other
- we can grant limited set of resource to a given namespace to make sure it is within limits
- system ns called kube-system which is used to host all the things related the k8s abd how it operates
- when a resource is created, a DNS entry is automatically created for it:
        
        db-service.dev.svc.cluster.local

        * db-service: service name
        * dev: namespace
        * svc: service
        * cluster.local: domain

- to run a command in a given ns we append `--namespace=name`
- we can also make sure resources are created in a desired ns by adding `namespace: name` in the yaml definition file under the metadata section
- when creating a definition in a yaml file we use the kind `Namespace` with apiversion `v1` 
- to change the default name space we can run:
        kubectl config set-context $(kubectl config current-context) --namespace=dev

- to check resources in all namespaces we can run this command
        kubectl get pods --all-namespaces

- to limit resources in a namespace, we create a resource quota ( kind: `ResourceQuota` (apiVersion : `v1`))


## taints and tolerance

- We can taint a node to prevent pods from being provisioned their unless they are tolerant to that node taint
- To taint a node: 
        jubectl taint nodes nodename key=value:taint-effect

- `key=value` can be something like `app=blue` which is kinda of the taint name we can say
- taint effect is the effect the pod will suffer if the scheduler tries to provision it there: 
        * NoSchedule
        * PreferNoSchedule 
        * NoExecute ( evict existing untolerant nodes )

- Note: taints do not tell a certain pod to go to a certain node it just allow nodes to accept a certain pods
- master node: only hosts system pods, in fact a `NoSchedule` taint is applied there to ensure new "non system" pods are not scheduled there

to grant a pod tolerance towards a given node we use the tolerations entry under spec:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bee
spec:
  containers:
  - image: nginx
    name: bee
  tolerations:
  - key: spray
    value: mortein
    effect: NoSchedule
    operator: Equal
```

## node selectors

- To make sure a given pod run on a specific node we can use labeling
- we label a node using
        kubectl label node node01 key=value    
- then on the pod yaml definition we make sure to add a selector such as 

```yaml
nodeSelector:
  key: value
```

- node selector are pretty limited

## node affinity

- this is to ensure that pods are hosted in particular nodes
- node affinity on a pod definition provide more flexibility by allowing searching for more than just one value for a given key


## Resource limits

- the scheduler when putting pods in a given nodes take into consideration resources requested by the pod and available resources on the nodes
- Minimum requested resources by a container is 0.5 CPU and 256 MEM
- To request a set amount of resources for a given pod we can add `resources` directive under the pod `spec`

```yaml
spec:
  resources:
    requests:
      cpu: 1
      memory: "1Gi"
    limits:
      cpu: 2
      memory: "1Gi"
```

- k8s set default limits on resources consumption for the containers: 1 CPU and 512Mi MEM
- we can also specify limits in the `resources` section `spec` (check above yaml file)
- if the pods want to use more than its limited cpu, cpu will be throttled, for MEM, it can but if is constantly exeeding limits the pod will be terminated


## daemon-sets

- Similar to Replica-set but it allows u to run 1 copy of a pod per node
- A good use case of a ds is to deploy a monitoring agent or logging agent
- In yaml config creating we use kind as `DaemonSet` and apiVersion is set to `apps/v1`
- definition file are very similar to a rs we just need to update the `kind`


## static PODS;

- a static pod is a pod created by the `kubelet` on the node by placing the definition file under a certain path in the node cet by the option `pod-manifest-path` when running kubelet service
- static pod can be seen by the kube apiserver but can only be modified by the manifest file
- kubeadmin tool basically use static pod to do the first setup of the pods in the master nods ie setting up etcd, apiserver, control-manager, ...


## Scheduler

- we can write our own scheduler, we can package it and use it to meet our specific needs
- we can also add our scheduler as the main scheduler or as a secondary one so default app use default scheduler and i can use the specific scheduler for the specific need with the specific app

- to add a custom scheduler, we modify the scheduler manifest file and add `--scheduler-name=blabla` under command under containers under spec
- use `lock-object-name` to differentiate the custom scheduler from the rest in the leader election process
- in pod definition under spec we use `schedulerName` to chose which scheduler to schedule this pod


## monitoring and logging

- kubelet contain CAdvisor which is responsible for retrieving performance metric from pods and expose them to the kubelet api to make them available fot the metric server
- use `kubectl top node` or `kubectl top pod` to view cpu and mem consumption on the node/pod
- we can have 1 metric server per k8s cluster

we can use this command to stream logs: `kubectl logs -f pod-name`


## Commands

- to ensure that the container inside a pod run a given command or directive we can use the `command` directive inside the yaml config

```yaml
...
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command:
      - "sleep"
      - 1200
```

or 

```yaml
spec:
  containers:
  - name: simple-webapp
    image: kodekloud/webapp-color
    command: ["python", "app.py"]
    args: ["--color", "pink"]
```

## Env variables


- we can provide env variable to the pod/resources in the yaml files;
- env variable types: `plain text`, `ConfigMap`, `Secrets`

#### ConfigMap

- ConfigMap centrally manage env variables, so we take it from the pods definition files and add it to config maps, they inject these configuration key value pairs into the pod so they are available as env variable for the app inside of the pod
- To create a config map: `kubectl create configmap app_configmap_name --from-literal=key_name=key_value`
- We can also use a yaml config file with Kind as `ConfigMap` and apiVersion as `v1`
- instead of spec we use `data`, then we create it the usual way : `kubectl create -f configmap.yaml`

The usual commands:
        kubectl get configmaps
        kubectl describe configmaps

- To inject the configmap to a pod we add the `configMapRef` under `envFrom` directive under `spec`

sample configmap yaml config:
```yaml
apiVersion: v1
kind: ConfigMap
metadata: 
  name: webapp-config-map
data:
  APP_COLOR: darkblue
```

To use configmap in a pod: 

```yaml
spec:
  containers:
  - image: kodekloud/webapp-color
    name: webapp-color
    envFrom:
      - configMapRef:
          name: webapp-config-map
```

#### Secrets

- ConfigMap are a good way to store shared variables but are not good for secrets,
- Secrets are encrypted/hashed entities that work similarly to ConfigMap
- For the yaml config file we create it with Kind as `Secret` and apiVersion as `v1`

To imperatively create a secret: 
        kubectl create secret secret_name --from-literal=key_name=key_value
        kubectl create secret secret_name --from-file=file_path

The usual commands:
        kubectl get secrets
        kubectl describe secrets

Example yaml file
```yaml
apiVersion: v1
kind: Secret
metadata:
        name: db-secret
data:
        DB_Host: c3FdsqsMDE=
        DB_User: cm9vdqsdA==
        DB_Password: UGFzc3dvcmdsqQxMjM=
```

Secret here are encode with base64 ( `echo -n 'password' | base64` )

Get secret in a pod

```yaml
    envFrom:
    - secretRef:
        name: db-secret
```

The concept of safety of the Secrets is a bit confusing in Kubernetes. The kubernetes documentation page and a lot of blogs out there refer to secrets as a "safer option" to store sensitive data. They are safer than storing in plain text as they reduce the risk of accidentally exposing passwords and other sensitive data. In my opinion it's not the secret itself that is safe, it is the practices around it. 

## OS Upgrade:

- If node is down for more than 5 minute, it is considered dead and terminated (can be changed using `--pod-eviction-timeout`)
- To perform maintenance on a node we can schedule a downtime on a given node and drain it so pods are scheduled on other Nodes, `kubectl drain node01` (pods are terminated then created on other nodes)
- when the node is back it is considered as unschedulable ( no new pod can be provisioned there until we remove the restriction using `kubectl uncordon node01`) 
- On a side note we can mark a node as unschedulable using `kubectl cordon node01`
- we can't drain manually provisioned pods from nodes


## Cluster upgrade

- Since the kube-apiserver is the main component that manage the whole k8s cluster it should be the one with the higher version, other components can have different version
- kubectl can be a version higher then kube-apiserver
- k8s support the oldest 3 versions
- It is recommended to upgrade a minor version at a time
- when upgrading, we start with the master node and the main component there are briefly down
- after the master node, we can either upgrade the worker nodes all at the same time or one by one

Steps on the master node:
        kubectl drain controlplane
        apt update
        apt install kubeadm=1.20.0-00
        kubeadm upgrade apply v1.20.0
        apt install kubelet=1.20.0-00
        systemctl restart kubelet
        kubectl uncordon controlplane

Steps to update the worker node
        kubectl drain node01
        ssh node01
        apt update
        apt install kubeadm=1.20.0-00
        kubeadm upgrade node
        apt install kubelet=1.20.0-00
        systemctl restart kubelet
        exit
        kubectl uncordon node01


Check cluster info ( api server specifically )

        kubectl cluster-info

## backup and restore

For backup we can save resource configuration to a local device or to github, e can also query the apiserver for a full breakdown of the configuration.

Or we cna use ETCD to take snapshot for backup and restore these snapshot if we wanna restore configuration from a given date


To create an etcd snapshot: 
        ETCDCTL_API=3 etcdctl snapshot save /opt/snapshot-pre-boot.db --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key

For certificates and endpoints we can find them using: `kubectl describe pod etcd-controlplane -n kube-system`


To restore: 
        etcdctl --data-dir /var/lib/etcd-from-backup snapshot restore /opt/snapshot-pre-boot.db

then update the path to the data folder for the etcd pod under its manifest in the controlplane ( should be under `/etc/kubernetes/manifests/etcd.yaml`) (hostPath)


## Security

- kube-apiserver is the most important piece to secure since most interaction is with that components
- All communication between the different components in a k8s cluster is done using tls encryption
- authorization is managed by 4 methods: 
        * RBAC authorization
        * ABAC authorization
        * Node authorization
        * webhook authorization

- by default pods can access each other, we can implement networking policy to restrict that

## Certificates

- each component use a certificate to authenticate and communicate with other components 
- we generally have client certificate for clients and server certificate for servers
- All these certificate are signed using a CA
- On a side note we can have a CA for all the component and another CA to ETCD
- When signing a certificate for the admin user, we need to specify the Group O=SYSTEM:MASTERS to allow him admin access
- For system components their name should be prefixed with the key word SYSTEM
- To make sure of the admin certificate (for example since this is the one human will be using) we add it to the kube-config.yaml file
- component may call the kube-api server different names or even use its ip thus we need to include all those alt names/ips in the certificate
- we need a certificate for each kubelet server, to differentiate the server, we use the nodes name in the certificate ( generally system:node:node01)
- A user can gain access by generating a certificate with adequate group name (system:masters) and getting his certificate to be signed by the CA ( usually done by another admin)
- Certificate API allow to easily manage certificate signing requests,
- to create a yaml file for a certificate singing request we use the Kind `CertificateSigningRequest` with the apiVersion set to `certificates.k8s.io/v1`; 
- To get the csr: `kubectl get csr` then approve: `kubectl certificate approve csr_name`
- To reject it run: `kubectl certificate deny csr_name`
- To delete the csr: `kubectl delete csr csr_name`
- The received certificate is encode in base 64 ( so run base64 --uncode to get it)
- Behind the scenes, the controller manager is the component taking care of all this for us (the option name is `--cluster-signing-cert-file` and same with key)

sample csr:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
        name: akshay
spec:
  signerName: kubernetes.io/kube-apiserver-client
  groups:
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZV3R6YUdGNU1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQXh5QWZINzR4R1U5SW1CQUdrb3ZNcUxUSjI2TXRmQmJDR0t3K3NxNUlSNXRtCmd0c0d5ZTdzcTJTTXZxdHhHVkFRaFpaZ1k2REtNS1Y0RWdzTUVDK2VBUU9DNWFiaFg3MWlJM3NIMG5KSnlQbHcKbS90RUFxVnNzcnA2SnAxMnkranBhcy9WcHh5Z21GUnBGajR6V2ZpVDRxWlgzYmk2aDFsRWJNakdHMlNHZjBHWApnRzYrTXphSk8rK3dhcVNLY3lwL3lhSmcvb3pZeHFzM0U1dU52alk2SU56NS8wOW44V29mSmNGYjFPbmZTaWppCitGZk9yTEVNRjBVekJyV2U1TVhwbnJ3M2dXZmdwc3NhOTlWeWlwcHJMTTk0MVRCaHZ5ZFhhcU1yQml3QjZZQ3QKWmlLZzhEdlBWRTRySC9ZT0hjOVp0UHE4YTVWSWVLanFOeXNiNkRCajhRSURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBRDRwSGVUQlRuNTZxck90WDBnSERyOXl3ZEdOcklHc3llZDE0bURmSDRGUHRSaHVEYUtWCkZsRHRPa2FEOFVYRkZJSWZtajZ3aCtXRzdmaWo3M3FHYm9pcDdTdWhBSWhzSTdlOUlDM0JINDVEeTVnSFBjNGgKYXZSaFlWaXFyaTVSeXVBU2d4UXFmWDdJY2dVMFo1Z3Z2L3kvckYyaVZkNGl1SExOdXo1d1RWUmdodUJ6Tk5PNgplTTl4d2lvdFZDbVJGU2ZONGt5K1VLcFp4U1JINDdUNjNGU01lSU93UEVlV01RdUU0V040RlNERUtkMlhlZVRTClppSjJNRU5lNFFWSmY5d3hHSjN6R1FsL3F2NVVQMlRXdlkxZjVOQ2dDcjRXL1J2L3o1TUNpZlVYbVhsQXdPMisKZlR5WHltc1ZQTFY1eFo1WEtad3NCTWRZbTM5OVFGNDdWSW89Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=S0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZV3R6YUdGNU1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQXh5QWZINzR4R1U5SW1CQUdrb3ZNcUxUSjI2TXRmQmJDR0t3K3NxNUlSNXRtCmd0c0d5ZTdzcTJTTXZxdHhHVkFRaFpaZ1k2REtNS1Y0RWdzTUVDK2VBUU9DNWFiaFg3MWlJM3NIMG5KSnlQbHcKbS90RUFxVnNzcnA2SnAxMnkranBhcy9WcHh5Z21GUnBGajR6V2ZpVDRxWlgzYmk2aDFsRWJNakdHMlNHZjBHWApnRzYrTXphSk8rK3dhcVNLY3lwL3lhSmcvb3pZeHFzM0U1dU52alk2SU56NS8wOW44V29mSmNGYjFPbmZTaWppCitGZk9yTEVNRjBVekJyV2U1TVhwbnJ3M2dXZmdwc3NhOTlWeWlwcHJMTTk0MVRCaHZ5ZFhhcU1yQml3QjZZQ3QKWmlLZzhEdlBWRTRySC9ZT0hjOVp0UHE4YTVWSWVLanFOeXNiNkRCajhRSURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBRDRwSGVUQlRuNTZxck90WDBnSERyOXl3ZEdOcklHc3llZDE0bURmSDRGUHRSaHVEYUtWCkZsRHRPa2FEOFVYRkZJSWZtajZ3aCtXRzdmaWo3M3FHYm9pcDdTdWhBSWhzSTdlOUlDM0JINDVEeTVnSFBjNGgKYXZSaFlWaXFyaTVSeXVBU2d4UXFmWDdJY2dVMFo1Z3Z2L3kvckYyaVZkNGl1SExOdXo1d1RWUmdodUJ6Tk5PNgplTTl4d2lvdFZDbVJGU2ZONGt5K1VLcFp4U1JINDdUNjNGU01lSU93UEVlV01RdUU0V040RlNERUtkMlhlZVRTClppSjJNRU5lNFFWSmY5d3hHSjN6R1FsL3F2NVVQMlRXdlkxZjVOQ2dDcjRXL1J2L3o1TUNpZlVYbVhsQXdPMisKZlR5WHltc1ZQTFY1eFo1WEtad3NCTWRZbTM5OVFGNDdWSW89Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  usages:
  - digital signature
  - key encipherment
  - server auth
```

## Kubectl config

- kubectl uses a config file to offload the need to add the certificate in each request
- it also allow the setting of multiple context that users uses to authenticate to different clusters using different permissions, 

Some commands:
        kubectl config view
        kubectl config use-context prod-user@production


## API Groups

they are categorized into core group (/api) and named group (/apis)
check the lesson for more details since it is kinda a lot to write but not very important i think; https://kodekloud.com/courses/539883/lectures/9808255

## Authorization
Node authorize: allow kubelet access from within the system based on certificates

* ABAC: Associate a user with a set of permissions, create a policy file and pass it to the api server, every time we need to do an update for these policy files we need to manually edit them then restart the kube-api-server, thus there are hard to manage

* Webhook: outsource all the authorization mechanism (Open policy agent a 3rd party tool that helps with that ): user make an api call to the api-server that will reach out to this agent that will decide if to let the user in or no

* AlwaysAllow default behavior, 

* AlwaysDeny

To update the authorization mechanism: use this option in the api-server: `--authorization-mode`

* RBAC: We create a role ( for dev for example) then we associate that role with any new user that needs dev permissions

Some commands:
        kubectl get roles
        kubectl get rolebindings
        kubectl describe role dev
        kubectl describe rolebindings devuser-dev-binding

Check access: 
        kubectl auth can-i create deployments
        kubectl auth can-i delete pods
        kubectl auth can-i delete pods as dev-user
        kubectl auth can-i delete pods as dev-user --namespace dev-space

role sample:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: 
        namespace: default
        name: developer
rules:
        - apiGroups: [""]
          resources: ["pods"]
          verbs: ["list", "create"]
```

```yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: blue
  name: deploy-role
rules:
- apiGroups: ["apps", "extensions"]
  resources: ["deployments"]
  verbs: ["create"]
```

Rolebinding sample: 

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-user-binding
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```


## Cluster roles

Resources in k8s are categorized as either namespaced or cluster scoped

cluster scoped resources are those created without specifying a namespace such as Nodes, PV, clusterroles clusterrolebindings, certificatesignaturerequest, namespaces, ...

To get a full list of these resources ( namespaces or cluster scoped) just run: `kubectl api-resources --namespaced= true` or false

To authorize uses to cluster wide resources we use cluster roles and cluster role bindings, the way these role works is similar to the normal roles discussed in the previous ##

We can create cluster roles for namespace resources, the user will therefore, have access to all resources in that cluster across all namespaces

sample role:

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nodes_access
rules:
- apiGroups: ["*"]
  resources: ["nodes"]
  verbs: ["*"]
```

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-role-binding
subjects:
- kind: User
  name: michelle
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: nodes_access
  apiGroup: rbac.authorization.k8s.io
```

## Secure Images

- By default images defined in config files are pulled from docker `docker.io/nginx/nginx`
- When using a private repo for our images we need to specify the full url of the registry and provide secrets for authentication, this is done by creating a k8s secret

Create a secret of type docker registry

`kubectl create secret docker-registry secret_name --docker-username=dock_user --docker-password=dock_password --docker-server=myprivateregistry.com:5000 --docker-email=dock_user@myprivateregistry.com`

To use the newly created secret, with the image directive add `imagePullSecrets: secret_name` (this should be at the same level as the container not part of container)

## Security context

Configuring security context on the pod level will carry on to all the containers inside that pod

If we configure it at the container and at the pod level, the ones on he container will override the pod level config

For pod level add directive under the spec section, and for container level add it under the container definition

sample:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper
spec:
  securityContext:
    runAsUser: 1010
  containers:
  - image: ubuntu
    name: ubuntu-sleeper
    command:
      - "sleep"
      - "3600"
```

To run a command on a particular container: `kubectl exec -it ubuntu-sleeper -- date -s '19 APR 2012 11:14:00'`

To grant permission to run things as root that your not usually supposed to be able to run

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper
spec:
  containers:
  - image: ubuntu
    name: ubuntu-sleeper
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
    command:
      - "sleep"
      - "3600"
```

## Networking

- By default ( and it required) all pods in a k8s cluster can communicate with each others
- To prevent a given pod from communicating with other pods we can implement a network policy that we link to one or multiple pods
- We use labels and selectors to link network policies to pods
- we use label as well to let ingress access for example from namespaces or pods with matching labels
- we can also allow acress from external ips

commands:
        kubectl get networkpolicies

example policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: internal-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      name: internal
  policyTypes:
  - Egress
  - Ingress
  ingress:
    - {}
    # we can remove ingress related stuff
  egress:
  - to:
    - podSelector:
        matchLabels:
          name: mysql
    ports:
    - protocol: TCP
      port: 3306

  - to:
    - podSelector:
        matchLabels:
          name: payroll
    ports:
    - protocol: TCP
      port: 8080
 
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
      # we need to add these to fix dns issues
```


## Volumes

To create a volume that will be used by the container we can do that using a path in the host server

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: random-number-generator
spec:
  containers:
  - image: alpine
    name: alpine
    command: ["/bin/sh", "-c"]
    args: ["shuff -i 0-100 -n 1 >> /opt/number.out;"]
    volumeMounts:
    - mountPath: /opt
      name: data-volume
  volumes:
  - name: data-volume
    hostPath:
      path: /data
      type: Directory
```

For aws volume storage we can do this instead

```yaml
...
...
...
    volumeMounts:
    - mountPath: /opt
      name: data-volume
  volumes:
  - name: data-volume
    awsElasticBlockStore:
      volumeID: aws-volume-id
      fsType: ext4
```


Managing volumes for each pods can be tedious, so we it is better to use a pool of persistent volumes managed by administrator and pods (devs creating the pods) can get some storage on that pool using volume claims

sample persistent volume config file

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-vol1
spec:
  # persistentVolumeReclaimPolicy: Retain # we can add it if needed
  accessModes:
    - ReadWriteOnce #
  capacity:
    storage: 1Gi
  awsElasticBlockStore:
    volumeID: aws-volume-id
    fsType: ext4
```

commands:
      kubectl get persistentvolume
      kubectl get persistentvolumeclaim
      kubectl delete persistentvolumeclaim pv-claim

after deleting a claim, the persistent volume is by default set to retain until deleted manually but it is not available for reuse

pv claim definition

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-claim
spec:
  accessModes:
    - ReadWriteOnce # ReadOnlyMany, ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

To attach a pvc to a pod we can do as follow
(The same is true for ReplicaSets or Deployments. Add this to the pod template section of a Deployment on ReplicaSet.)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```

pvc can't claim pv when the access mode is different

When using cloud it would be tedious to manually provision pv each time we need one so instead of statically creating pv we can do that dynamically by no longer using a pv definition but a storage class definition (sc) 

some sc commands
      kubectl get storageclass
      kubectl get sc



sample pvc: 
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: delayed-volume-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```


## network

network namespaces: make sure to isolate containers network from seeing the external host or any other network interfaces from other containers

Host can always see whats inside containers but containers can't see whats outside

CNI: Container network interface: a set of standards that defines how programs should be developed to solve networking challenges in a container runtime env, the program is refereed to as plugin

CNI defines a set f responsibility for container runtime and for plugins

Docker do not really support cns but it supports cnm (container network model) thus cni plugins do not integrate with docker; So to work around that we need to :

1- Create a docker container without any networking config
2- manually invoke the bridge plugin

==> thats how k8s do stuff

To check the mac address of another node from the controlplane, run `arp node01`

`netstat -nplt` to check Active Internet connections on a server


The kubelet is the responsible for configuring CNI on each pod it creates

the default path configured with all binaries of CNI supported plugins is : /opt/cni/bin

Run the command: ls /etc/cni/net.d/ and identify the name of the plugin used for the k8s cluster

to get all system endpoints:
          kubectl get endpoints
          kubectl get ep



## ingress

- ingress are something similar to routing based on path in an AWS ALB
- We deploy a solution called ingress controller to take care of routing traffic for different apps/parts of the apps in our deployment
- We need to configure an ingress controller in our k8s cluster since they are not there by default. so the ingress resources can work as expected

- An Ingress Nginx controller is just another deployment so we deploy it like one, we generally need to pass argument to the deployment so we create a configMap to take care of that , we also need to create a service to expose the controller to the external worlds

- Ingress resource is created using the apiVersion `extensions/v1beta1` and kind `Ingress`

Some typical commands:
        kubectl get ingress
        kubectl describe ingress


example ingress service
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: critical-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: pay-ingress
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: pay-service
          servicePort: 8282
        path: /pay
      - backend:
          serviceName: wear-service
          servicePort: 8080
        path: /wear
        pathType: ImplementationSpecific
      - backend:
          serviceName: video-service
          servicePort: 8080
        path: /stream
        pathType: ImplementationSpecific
```

Get all resources using this command
        kubectl get all --all-namespaces

To create a serviceaccount (https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) 

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress-serviceaccount
  namespace: ingress-space
```

sample ingress-controller deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-controller
  namespace: ingress-space
spec:
  replicas: 1
  selector:
    matchLabels:
      name: nginx-ingress
  template:
    metadata:
      labels:
        name: nginx-ingress
    spec:
      serviceAccountName: ingress-serviceaccount
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
          args:
            - /nginx-ingress-controller
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
            - --default-backend-service=app-space/default-http-backend
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - name: http
              containerPort: 80
            - name: https
              containerPort: 443
```

sample service associated with the ingress
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress
  namespace: ingress-space
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    nodePort: 30080
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    name: nginx-ingress
```

ingress objects generally ( i think ) should live in the app namespace 


## HA mode

The api server can be running in HA mode using a loadbalancer in front of them

The other component (scheduler and controller) though, they are in an active, standby mode, and these modes are deciding using a leader election algorithm

## ETCD in HA

When we have multiple ETCD instance, ETCD use a leader architecture to ensure data consistency, data received by a given node is sent to the leader to process it, then the leader send copies of that to the other instances, a write is only considered complete when all the nodes receives a copy ( majority of the nodes ( quorum)).

In a HA env we want to have 3 etcd instances


## JSON PATH

basically get the info on a k8s object using json then format the output to display what you want to see

examples (display these info for all nodes): 

    kubectl get pods -o=jsonpath='{.items[*].metadata.name}{"\n"}{.items[*].status.capacity.cpu}'

we generally want to display all info for each node so it is better to use loops

    kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\n"}{end}'

There is an utility that can help us with this called column

    kubectl get pods -o=custom-columns=NODE:.metadata.name,CPU:.status.capacity.cpu


When using the normal get we can also sort output based on a filed

    kubectl get pods --sort-by= .status.capacity.cpu


Use a JSON PATH query to identify the context configured for the aws-user in the my-kube-config context fil

        kubectl config view --kubeconfig=my-kube-config -o jsonpath="{.contexts[?(@.context.user=='aws-user')].name}" > /opt/outputs/aws-context-name