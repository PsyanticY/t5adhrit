# Quick tip sand tricks

- Completely delete all cache, unused store: `nix-collect-garbage -d`

- Build a package: `nix-build -A pipreqs  --option sandbox true`

- Delete a store path: `nix-store --delete /nix/store/dovahbalblaremismylovekagatoo-somepackagename.tar.gz --ignore-liveness`
