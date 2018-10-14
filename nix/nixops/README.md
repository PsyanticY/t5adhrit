# NixOps

### What is NixOps

Nixops is the best provisioning tool out there. It can nonetheless improve a lot. it's only handicap is that is only used for NixOS systems.


In this [paper](https://nixos.org/~eelco/pubs/charon-releng2013-final.pdf) NixOps was introduced as a tool for automated provisioning and deployment of machines. NixOps has several important characteristics:

• It is declarative
• It performs provisioning
• It allows abstracting over the target environment
• It uses a single configuration formalism (Nix’s purely functional language)

--------------------------------------------------------------------------------

NixOps is a tool for deploying sets of NixOS Linux machines, either to real hardware or to virtual machines.
It extends NixOS’s declarative approach to system configuration management to networks and adds provisioning.

For example, here is a NixOps specification of a network consisting of two machines — one running Apache httpd,
 the other serving a file system via NFS:

--------------------------------------------------------------------------------

```
{
   webserver =
     { deployment.targetEnv = "virtualbox";
       services.httpd.enable = true;
       services.httpd.documentRoot = "/data";
       fileSystems."/data" =
         { fsType = "nfs4";
           device = "fileserver:/"; };
     };

   fileserver =
     { deployment.targetEnv = "virtualbox";
       services.nfs.server.enable = true;
       services.nfs.server.exports = "...";
     };
 }
 ```

 -------------------------------------------------------------------------------

The values of the webserver and fileserver attributes are regular NixOS system specifications, except for the deployment.* options, which tell NixOps how each machine should be instantiated (in this case, as VirtualBox virtual machines running on your desktop).


=> This following commands will download and install NixOps (you should have the nix package manager installed ), create the instances, build, upload and activate the NixOS configurations you specified. To change something to the configuration, you just edit the specification and run `nixops deploy` again.

```
$ nix-env -i nixops
$ nixops create -d simple network.nix
$ nixops deploy -d simple
```

NixOps makes it easy to abstract over target environments, allowing you to use the same “logical” specification for both testing and production deployments. For instance, to deploy to Amazon EC2, you would just change the deployment.* options to:
```
  deployment.targetEnv = "ec2";
  deployment.region = "eu-west-1";
```

---------------------------------------------------------------------------

Here is the config of a simple machine running NGINX

```
{pkgs, ...}:
{
	# Describe your "deployment"
	network.description = "NGINX web server";

	# A single machine description.
	server = {
		deployment.targetEnv = "virtualbox";
		deployment.virtualbox.memorySize = 1024; # megabytes

		services.nginx.enable = true;
		services.nginx.config = ''
			http {
				include       ${pkgs.nginx}/conf/mime.types;
				default_type  application/octet-stream;

				server {
					listen 80 default_server;
					server_name _;

					root "/var/nginx/html.html"; # or something more relevant
				}
			}
		'';
	};
}
```
This example builds a VM but if you want to deploy over SSH just change the  deployment.* lines to the following, filling in your IP and hostname.
```
deployment.targetEnv = "none";
deployment.targetHost = "10.2.2.5";
networking.hostName = "my-kobay-machine";


fileSystems."/" = {
	device = "/dev/disk/by-label/nixos";
	fsType = "ext4";
};

boot.loader.grub = {
	enable = true;
	version = 2;
	device = "/dev/sda";
};
```

When you are writing a configuration you are creating a nested set (that's what Nix calls it but I would consider it a dictionary).
The Nix language has a lot of convenience syntax around sets for this reason. The most important thing to realize is that nested sets are automatically created.

```
a.b.c.d = 5
# Is the same as
a = { b = { c = { d = 5; }; }; }
```

## Modules

It is a good practice to keep services in modules. In this setup, module are divided into a number of modules based on how they are used.

For example:
* `base/`: Configuration that is used by all machines. Each machine will include  base/default.nix and nothing else out of this directory.
* `services/`: Configuration for services that I can enable on my machines. These will be included by the machine configurations themselves to deploy services to those machines.
* `lib/`: Modules used by other services and modules but not useful to be included into server configs directly (for example my SSL certificates).
* `pkg/`: out-of-tree programs for peculiar use. These are generally personal projects.
* `users/`: Descriptions of human users, this includes their SSH keys and preferred shells, aliases and other personal configs. Some users are present in every machine (they are included in base/users.nix) others are pulled in by services.

So to fit into this structure we'll extract the NGINX config into  services/nginx.nix.

```
{pkgs, ...}: let
	# Extract the config into a binding.
	config = ''
		http {
			include       ${pkgs.nginx}/conf/mime.types;
			default_type  application/octet-stream;

			server {
				listen 80 default_server;
				server_name _;

				root "/var/nginx/html.html"; # or something more relevant
			}
		}
	'';
in {
	services.nginx = {
		enable = true;
		config = config;
	};
}
```
And modify the existing config file to:
```
{pkgs, ...}:
{
	# Describe your "deployment"
	network.description = "NGINX web server";

	# A single machine description.
  server = {
		imports = [
			services/nginx.nix
		];

		deployment = {
			targetEnv = "virtualbox";
			virtualbox.memorySize = 1024; # megabytes
		};
	};
}
```

The way imports work is Nix is very nice, the file gets loaded and if it is a function it gets passed the global argument set (this is where we get the pkgs variable from). Then the result is merged into the importing module. This means that you don't have to worry about where in the tree your code gets included,
it is always the root. Now by commenting out or deleting the NGINX import and deploying you can simply remove the service from your system. This is the primary benefit of how I structure the code. Selecting what services should be on a machine (other then the base services which are always present) is as simple as adding or removing imports from the services/ directory.

## Use of arguments

Generally we create a nix file that contains things that can change from on env to another `dev` to `prod` ...
To ease alot of work we can use arguments to parameterize that.

Arguments are declared as follow in the top of the nixops config file.

For example we can have an `ec2.nix` as follow:

```
{ account
, accountId
, region ? "us-east-1"
, instanceType ? "r3.xlarge"

# Tagging arguments
, client ? "PDX"
, project ? "UNKNOWN"
, category ? "DEV"
, owner ? "someone@infor.com"
, approver ? "someone@infor.com"
, keep ? false

, description ? ""

, ...
}:
{
  network.description = description;
  defaults =
    { resources, lib, ... }:

    deployment.targetEnv = "ec2";

    deployment.ec2 = {
      inherit region zone;
      instanceType = lib.mkDefault instanceType;
      spotInstancePrice = lib.mkDefault spotInstancePrice;
      ...
      ...
      ...
      tags = {
        Client = client;
        Project = project;
        Category = category;
        Owner = owner;
      };
    };
}
```
The arguments can have default values if not specified in the deployment: `instanceType ? "r3.xlarge"`.
The `?` is for requiring an argument, the "r3.xlarge" is the default argument (or value) given to the variable if no argument is given.
Assigning arguments a value use set-args: `nixops set-args -d deployment-name --argstr argument1 "DovahAssassins" --argstr argument2 "FeelPain" --arg isTrue true --unset argument3`
`arg` is for boolean and `argstr` for string `unset` is to remove an argument.
