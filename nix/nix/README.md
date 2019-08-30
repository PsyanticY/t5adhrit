# nix expressions notes


### Export a hell path variable

```nix
environment.shellInit = ''
  export NIX_PATH=$NIX_PATH:new_path=$HOME/new_path
  export PYTHONPATH=$PYTHONPATH:"${pkgs.python27Packages.boto}/lib/python2.7/site-packages/"
'';
```
Add a binary cache to a server:
```nix
nix.binaryCaches = [ "http://cache.nixos.org" "dovahkin.nix"];
nix.binaryCachePublicKeys = [ "bianrykey of the binary cache" ];
```

## When and how should default.nix, shell.nix and release.nix be used?

[Original question on stackoverflow](https://stackoverflow.com/questions/44088192/when-and-how-should-default-nix-shell-nix-and-release-nix-be-used/44118856)

- `default.nix` and `shell.nix` have special meanings in Nix tool, but `release.nix` is a convenience one.

- `default.nix` is used as a default file when running `nix-build`, and `shell.nix` is used as a default file when running `nix-shell`.

- `default.nix` isn't used only for `nix-build`. For example, `[<nixpkgs/lib/default.nix>](https://github.com/NixOS/nixpkgs/blob/master/lib/default.nix)` is used as aggregator for functions, and doesn't contain derivations. So not every `default.nix` is supposed to be "built" (but if `default.nix` is an attribute set of derivations, it will be buildable, and `nix-build` will build all of them).

- `nix-shell` will use `default.nix` if no `shell.nix` is found.

- `default.nix` is used as default file when importing directory. So if you write `x = import ./some/directory;`, then `./some/directory/default.nix` will be imported. That actually should explain why `nix-build .` uses `default.nix`.

- there are two common formats for derivations in `default.nix`: derivation, and `callPackage` derivation. You can't `nix-build` the latter. Almost any package in nixpkgs is written in this style, see hello. But you can `nix-build -E 'with import <nixpkgs> { }; callPackage ./path/to/default.nix { }'` as a workaround. `nix-shell` also supports this -E argument.

- `release.nix`: Hydra jobset declaration.


## hydra vs nix-build

These examples are taken from [here](https://github.com/Gabriel439/haskell-nix/tree/master/project0)

to build a package with `nix-build` we just need something like this
```nix
let
  pkgs = import <nixpkgs> { };

in
  pkgs.haskellPackages.callPackage ./project0.nix { }
```

For hydra compatibility we need to change it like this:
```
let
  pkgs = import <nixpkgs> { };

in
  { project0 = pkgs.haskellPackages.callPackage ./project0.nix { };
  }
```

=> the difference is that the release.nix now returns a set (the Nix term for a dictionary) of derivations. This "set" only has one "attribute" (i.e. key) named project0 whose value is the derivation to build our Haskell project.The main motivation for this change is that Hydra (Nix's continuous integration server) requires that project build files are sets of derivations with one attribute per build product.

we can build that using this: `nix-build release2.nix` or by specifying which project using: `nix-build --attr project0 release2.nix`

to open a nix shell out of this release2.nix file we run `nix-shell --attr project0.env release2.nix`

We can also create a shell.nix file
```nix
(import ./release2.nix).project0.env
```
and just run `nix-shell`