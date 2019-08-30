# Quick tip sand tricks

## Nix 

- Build a package: `nix-build -A pipreqs  --option sandbox true`.

- Build a python package: `nix-build -A pythonPackages.mail-parser`.

-> We usually want to build with sandboxing enabled.

- Delete a store path: `nix-store --delete /nix/store/dovahbalblaremismylovekagatoo-somepackagename.tar.gz --ignore-liveness`.

- To query available packages: `nix-env -qaP`.

- List installed packages: `nix-env -q`.

- To install: `nix-env -i pcre-8.41`.

- To remove: `nix-env -e pcre-8.41`.

- To install from a specific version of nixpkgs: `nix-env -i vulnix -I nixpkgs=channel:nixos-18.09`

- Open a nix shell with a package: `nix-shell -p cfnflip -I nixpkgs=channel:nixos-19.03`

- To update all stuff: `nix-env -u`.

- To update a package and it's dependencies run: `nix-env -uA pcre-8.41`.

- The A means install with the package name with a pkgs. prefix.

- To remove uninstalled packages: `nix-collect-garbage`.

- Completely delete all cache, unused store: `nix-collect-garbage -d`.

- To start a repl: `nix repl '/path/to/nixpkgs'`

- To check a package declaration: `nix edit nixpkgs.ossec`. (use EDITOR to set editors for edit)

- To check which nixpkgs version you have by default: `nix-instantiate --eval --expr 'builtins.readFile <nixpkgs/.version>'`.


## NixOps

- Get device mapping to deploy from snaps: `nixoos show-physical -d nagatoPain --backup xxxxxxxxxxxx`.

- Take a backup: `nixops backup -d nagatoPain`.

- Take backup with freeze (works only for xfs) `nixops backup -d nagatoPain --freeze`.

- Show backup status: `nixops backup-status -d nagatoPain`

- Show latest backup status: `nixops backup-status -d nagatoPain --latest`.

- Get status of a given backupid: `nixops backup-status -d nagatoPain --backupid`

- Start a nixops dev-shell: `./dev-shell  -I channel:nixos-18.09` (use the channnel you want ofc).

- To use latest packages: `./dev-shell -I channel:nixos-unstable`

- Run nixops test for ec2: `AWS_ACCESS_KEY_ID=default  python2  tests.py tests.functional -A ec2 --verbose`

- Dump closure paths: `nixops dump-nix-paths -d ec2-killer`.

## Repl

- Evaluate and expressions:

			nix-repl> f
			[ { ... } { ... } ]

=>

			nix-repl> :p f
			[ { z = "a"; } { z = "b"; } ]

## other

- nixpkgs-channel follow nixpkhs but it merges packages after they get built and tested
