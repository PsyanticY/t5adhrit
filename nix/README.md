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

- To update all stuff: `nix-env -u`.

- To update a package and it's dependencies run: `nix-env -uA pcre-8.41`.

- The A means install with the package name with a pkgs. prefix.

- To remove uninstalled packages: `nix-collect-garbage`.

- Completely delete all cache, unused store: `nix-collect-garbage -d`.

- To start a repl: `nix repl '/path/to/nixpkgs'`

## NixOps

- Get device mapping to deploy from snaps: `nixoos show-physical -d nagatoPain --backup xxxxxxxxxxxx`.

- Take a backup with filesystem: `nixops backup -d nagatoPain`.

- Take backup with freeze (works only for xfs) `nixops backup -d nixos-hardened-image --freeze`.

- Start a nixops dev-shell: `./dev-shell  -I channel:nixos-18.09` (use the channnel you want ofc).
