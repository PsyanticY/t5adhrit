# Introduction

Terraform is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc. Terraform can manage both existing service providers and custom in-house solutions.


### Key Features

#### Infrastructure as Code
You describe your infrastructure using Terraform's high-level configuration language in human-readable, declarative configuration files. This allows you to create a blueprint that you can version, share, and reuse.

#### Execution Plans
Terraform generates an execution plan describing what it will do and asks for your approval before making any infrastructure changes. This allows you to review changes before Terraform creates, updates, or destroys infrastructure.

#### Resource Graph
Terraform builds a resource graph and creates or modifies non-dependent resources in parallel. This allows Terraform to build resources as efficiently as possible and gives you greater insight into your infrastructure.

#### Change Automation
Terraform can apply complex changesets to your infrastructure with minimal human interaction. When you update configuration files, Terraform determines what changed and creates incremental execution plans that respect dependencies.


### Use cases:

- Heroku App Setup
- Multi-Tier Applications
- Self-Service Clusters
- Software Demos
- Disposable Environments
- Software Defined Networking
- Resource Schedulers
- Multi-Cloud Deployment


### Terraform State

- Mapping to the Real World: Terraform requires some sort of database to map Terraform config to the real world.
- Metadata: Alongside the mappings between resources and remote objects, Terraform must also track metadata such as resource dependencies. Terraform typically uses the configuration to determine dependency order. However, when you delete a resource from a Terraform configuration, Terraform must know how to delete that resource. Terraform can see that a mapping exists for a resource not in your configuration and plan to destroy. However, since the configuration no longer exists, the order cannot be determined from the configuration alone.
- Performance: In addition to basic mapping, Terraform stores a cache of the attribute values for all resources in the state. This is the most optional feature of Terraform state and is done only as a performance improvement. For larger infrastructures, querying every resource is too slow. Many cloud providers do not provide APIs to query multiple resources at once, (...)  Larger users of Terraform make heavy use of the `-refresh=false` flag as well as the `-target` flag in order to work around this. 
- Syncing : locally or we can use remote state using terraform enterprise

### Provider Configuration

Terraform relies on plugins called "providers" to interact with remote systems.

Terraform configurations must declare which providers they require, so that Terraform can install and use them. Additionally, some providers require configuration (like endpoint URLs or cloud regions) before they can be used.

#### Provider Configuration

Provider configurations belong in the root module of a Terraform configuration  provider configuration is created using a provider block:

```hcl
provider "google" {
  project = "acme-app"
  region  = "us-central1"
}
```

You can use expressions in the values of these configuration arguments, but can only reference values that are known before the configuration is applied. This means you can safely reference input variables, but not attributes exported by resource

Some providers can use shell environment variables when available, we recommend using this as a way to keep credentials out of your version-controlled Terraform code.

There are also two "meta-arguments" that are defined by Terraform itself and available for all provider blocks:

- alias: You can optionally define multiple configurations for the same provider, and select which one to use on a per-resource or per-module basis. The primary reason for this is to support multiple regions for a cloud platform; A provider block without an alias argument is the default configuration for that provider.
- version, which we no longer recommend (use provider requirements instead)

#### refresh command


The `terraform refresh` command updates the state file when physical resources change outside of the Terraform workflow.

Terraform also updates your state file when you run a `terraform destroy` operation.


### Terraform Settings

The special terraform configuration block type is used to configure some behaviors of Terraform itself, such as requiring a minimum Terraform version to apply your configuration.

only constant values can be used; arguments may not refer to named objects such as resources, input variables, etc, and may not use any of the Terraform language built-in functions.

The nested backend block configures which backend Terraform should use.

The required_providers block specifies all of the providers required by the current module, mapping each local provider name to a source address and a version constraint.

```hcl
terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }
}
```

### Provisioners

Provisioners can be used to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service.

Terraform includes the concept of provisioners as a measure of pragmatism, knowing that there will always be certain behaviors that can't be directly represented in Terraform's declarative model.

However, they also add a considerable amount of complexity and uncertainty to Terraform usage. 

#### How to use Provisioners

you can add a provisioner block inside the resource block of a compute instance.

```hcl
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo The server's IP address is ${self.private_ip}"
  }
}
```

The local-exec provisioner requires no other configuration, but most other provisioners must connect to the remote system using SSH or WinRM. You must include a connection block so that Terraform will know how to communicate with the server.

#### the self object
Expressions in provisioner blocks cannot refer to their parent resource by name. Instead, they can use the special self object.

The self object represents the provisioner's parent resource, and has all of that resource's attributes. For example, use self.public_ip to reference an aws_instance's public_ip attribute.

#### Destroy-Time Provisioners

If when = destroy is specified, the provisioner will run when the resource it is defined within is destroyed.

Destroy provisioners are run before the resource is destroyed. If they fail, Terraform will error and rerun the provisioners again on the next terraform apply. Due to this behavior, care should be taken for destroy provisioners to be safe to run multiple times.

#### Multiple Provisioners

Multiple provisioners can be specified within a resource. Multiple provisioners are executed in the order they're defined in the configuration file.

### 
