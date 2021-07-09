Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories), and automating updates to configuration when there is new code to deploy.

Flux helps

- cluster operators who automate provision and configuration of clusters;
- platform engineers who build continuous delivery for developer teams;
- app developers who rely on continuous delivery to get their code live.

The GitOps Toolkit is for platform engineers who want to make their own continuous delivery system, and have requirements not covered by Flux.

###### What can I do with Flux?

Flux is based on a set of Kubernetes API extensions (“custom resources”), which control how git repositories and other sources of configuration are applied into the cluster (“synced”). For example, you create a GitRepository object to mirror configuration from a Git repository, then a Kustomization object to sync that configuration.

Flux works with Kubernetes' role-based access control (RBAC), so you can lock down what any particular sync can change. It can send notifications to Slack and other like systems when configuration is synced and ready, and receive webhooks to tell it when to sync.

The flux command-line tool is a convenient way to bootstrap the system in a cluster, and to access the custom resources that make up the API.

getting started tutorial: https://fluxcd.io/docs/get-started/

