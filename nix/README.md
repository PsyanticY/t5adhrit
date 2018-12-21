# Quick tip sand tricks


- Build a package: `nix-build -A pipreqs  --option sandbox true`.

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
