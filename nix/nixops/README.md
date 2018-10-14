#NixOps

### What is NixOps

Nixops is the best provisioning tool out there. It can nonetheless improve a lot. it's only handicap is that is only used for NixOS systems.


In this (paper)[https://nixos.org/~eelco/pubs/charon-releng2013-final.pdf] NixOps was introduced as a tool for automated provisioning and deployment of machines. NixOps has several important characteristics:

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

``` {
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

```
$ nixops create -d simple network.nix
$ nixops deploy -d simple
```
=> This will create the instances, and then build, upload and activate the NixOS configurations you specified. To change something to the configuration, you just edit the specification and run `nixops deploy` again.

NixOps makes it easy to abstract over target environments, allowing you to use the same “logical” specification for both testing and production deployments. For instance, to deploy to Amazon EC2, you would just change the deployment.* options to:
```
  deployment.targetEnv = "ec2";
  deployment.region = "eu-west-1";
```
