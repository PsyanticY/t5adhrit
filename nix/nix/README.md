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


