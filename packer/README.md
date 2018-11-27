# Hashicorp Packer

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration.


### Use Cases

- Continuous Delivery
- Dev/Prod Parity
- Appliance/Demo Creation

### Installation

- Using nix: `nix-env -i packer`
- Using other linux distor: use `yum` or `apt`
- Install from source

## Build an Image

### The Template

The configuration file used to define what image we want built and how is called a template in Packer terminology. The format of a template is simple JSON
To pass the access and secret keys to the template we can use the following piece of code to make packer prompt us for the access keys

```json
"variables": {
    "aws_access_key": "",
    "aws_secret_key": ""
  },
```

Use `packer validate example.json` to validate the template

### Build an Image

```bash
$ packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var 'aws_secret_key=YOUR SECRET KEY' \
    example.json
```

--> At the end of running packer build, Packer outputs the artifacts that were created as part of the build. Artifacts are the results of a build, and typically represent an ID (such as in the case of an AMI) or a set of files (such as for a VMware virtual machine).

## Provision

Packer fully supports automated provisioning in order to install software onto the machines prior to turning them into images.

### Configuring Provisioners

Provisioners are configured as part of the template. We'll use the built-in shell provisioner that comes with Packer to install Redis.

```json
{
  "variables": ["..."],
  "builders": ["..."],

  "provisioners": [{
    "type": "shell",
    "inline": [
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server"
    ]
  }]
}
```
