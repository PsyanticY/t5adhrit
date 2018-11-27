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

### Packer terminology

- `Artifacts` are the results of a single build, and are usually a set of IDs or files to represent a machine image.
- `Builds` are a single task that eventually produces an image for a single platform.
- `Builders` are components of Packer that are able to create a machine image for a single platform. Builders read in some configuration and use that to run and generate a machine image.
- `Commands` are sub-commands for the packer program that perform some job.
- `Post-processors` are components of Packer that take the result of a builder or another post-processor and process that to create a new artifact.
- `Provisioners` are components of Packer that install and configure software within a running machine prior to that machine being turned into a static image. They perform the major work of making the image contain useful software.
- `Templates` are JSON files which define one or more builds by configuring the various components of Packer.

### Packer Commands (CLI)

Enabling Machine-Readable Output: The machine-readable output format can be enabled by passing the -machine-readable flag to any Packer command.

Format for Machine-Readable Output: `timestamp,target,type,data...`

- `timestamp` is a Unix timestamp in UTC of when the message was printed.
- `target` When you call packer build this can be either empty or individual build names
- `type` is the type of machine-readable message being outputted. The two most common types are ui and artifact
- `data` is zero or more comma-separated values associated with the prior type.

- Build Command: The `packer build` command takes a template and runs all the builds within it in order to generate a set of artifacts.
- Fix Command: The `packer fix` command takes a template and finds backwards incompatible parts of it and brings it up to date so it can be used with the latest version of Packer. After you update to a new Packer release, you should run the fix command to make sure your templates work with the new release.
example: `packer fix old.json > new.json`
- Inspect Command: the `packer inspect` command takes a template and outputs the various components a template defines. This can help you quickly learn about a template without having to dive into the JSON itself.
- Validate Command: The `packer validate` command is used to validate the syntax and configuration of a template.


### Template Structure

The configuration file used to define what image we want built and how is called a template in Packer terminology. The format of a template is simple JSON

- `builders` (required) is an array of one or more objects that defines the builders that will be used to create machine images for this template, and configures each of those builders.
- `description` (optional) is a string providing a description of what the template does. This output is used only in the inspect command.
- `min_packer_version` (optional) is a string that has a minimum Packer version that is required to parse the template. This can be used to ensure that proper versions of Packer are used with the template. A max version can't be specified because Packer retains backwards compatibility with packer fix.
- `post-processors` (optional) is an array of one or more objects that defines the various post-processing steps to take with the built images.
- `provisioners` (optional) is an array of one or more objects that defines the provisioners that will be used to install and configure software for the machines created by each of the builders. Provisioners use builtin and third-party software to install and configure the machine image after booting. Provisioners prepare the system for use, so common use cases for provisioners include:
    * installing packages
    * patching the kernel
    * creating users
    * downloading application code

- `variables` (optional) is an object of one or more key/value strings that defines user variables contained in the template. If it is not specified, then no variables are defined.

An example of a predefined provisioner :
The file provisioner can upload both single files and complete directories.
```json
"provisioners": [
    {
      "type": "shell-local",
      "command": "tar cf toupload/files.tar files"
    },
    {
      "destination": "/tmp/",
      "source": "./toupload",
      "type": "file"
    },
    {
      "inline": [
        "cd /tmp && tar xf toupload/files.tar",
        "rm toupload/files.tar"
      ],
      "type": "shell"
    }
  ]
}
```
There is a wide range of provisioner types: check them [here](https://www.packer.io/docs/provisioners/index.html).

To pass the access and secret keys to the template we can use the following piece of code to make packer prompt us for the access keys:

```json
"variables": {
    "aws_access_key": "",
    "aws_secret_key": ""
  },
```

We can also use env variables:
```json
{
  "variables": {
    "my_secret": "{{env `MY_SECRET`}}",
  }
}
```

Use `packer validate example.json` to validate the template

#### Build an Image

```bash
$ packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var 'aws_secret_key=YOUR SECRET KEY' \
    example.json
```

--> At the end of running packer build, Packer outputs the artifacts that were created as part of the build. Artifacts are the results of a build, and typically represent an ID (such as in the case of an AMI) or a set of files (such as for a VMware virtual machine).

If we have multiple builders (involving multiple cloud provider) and we want to restrick the build to a given we can use: `packer build -only=amazon-ebs example.json`

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

To configure the provisioners, we add a new section provisioners to the template, alongside the builders configuration. The provisioners section is an array of provisioners to run. If multiple provisioners are specified, they are run in the order given.

By default, each provisioner is run for every builder defined. So if we had two builders defined in our template, such as both Amazon and DigitalOcean, then the shell script would run as part of both builds. There are ways to restrict provisioners to certain build

Packer is able to make an AMI and a VMware virtual machine in parallel provisioned with the same scripts

The one provisioner we defined has a type of shell. This provisioner ships with Packer and runs shell scripts on the running machine.

## Vagrant Boxes as post-processors

Packer also has the ability to take the results of a builder and turn it into a Vagrant box.

Post-processors are added in the post-processors section of a template, which we haven't created yet

```json
{
  "builders": ["..."],
  "provisioners": ["..."],
  "post-processors": ["vagrant"]
}
```
