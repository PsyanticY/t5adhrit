# Standard Nix project structure

[This was taken from this reddit post](https://www.reddit.com/r/NixOS/comments/8tkllx/standard_project_structure/)

* `nixpkgs.nix`: used to pin nixpkgs to a specific version. If this is not needed, you may import <nixpkgs> in subsequent files instead.

```nix
let
  nixpkgs = builtins.fetchTarball {
    url = "https://d3g5gsiof5omrk.cloudfront.net/nixos/18.03/nixos-18.03.132008.ad771371fb2/nixexprs.tar.xz";
    sha256 = "0kkvbglvjc3qw3170dcy18vq7fj6q0n7liir6vfymjgwb0vdmina";
  };
in nixpkgs
```

* `derivation.nix`: This is a nixpkgs compatible derivation, ready to be added as a PR and used via callPackage.

```nix
{stdenv, pkgconfig, cmake, cppunit, boost, ... }:
stdenv.mkDerivation rec {
  name = "my-project-${version}";
  version = "0.0.1";

  src = ./. ;
  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ boost ];

  enableParallelBuilding = true;
  releaseName = name;

  meta = with stdenv.lib; {
    description = "Some Project in C++";
    homepage = https://example.org/my-project;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ "me@example.org" ];
  };
}
```

* `overlay.nix`: This allows for easy inclusion into a custom nixpkgs via the overlay system. Sometime I add multiple versions here with different options or inputs.

```nix
self: super: {
  my-project = self.callPackage ./derivation.nix{};
}
```

* `default.nix`: This allows for nix-build and nix-shell to automatically do TheRightThing. This can also allow importing other overlays and custom nixpkgs. This file will NOT work for inclusion into the Nixpkgs repo as default.nix, use the derivation.nix for that instead.

```nix
let
  nixpkgs = import ./nixpkgs.nix;
  pkgs = import nixpkgs {
    config = {};
    overlays = [
      (import ./overlay.nix)
    ];
  };

in pkgs.my-project
```

* `release.nix`: This is for additional build and packaging as needed. Also used by hydra to specify builds. This allows me to build specific releases, for example `nix build -f release.nix nix-build-arm` or `nix build -f release.nix deb-installer`.

```nix
{ nixpkgs ? (import ./nixpkgs.nix), ... } :
let
  pkgs = import nixpkgs {config={};};
  pkgs-arm = import nixpkgs {system="armv7l-linux";config={};};

  nixBuild = drv : extraAttrs :drv.overrideAttrs (old:{
    initPhase = ''
      mkdir -p $out/nix-support
      echo "$system" > $out/nix-support/system
    '';
    prePhases  = ["initPhase"] ++ (if builtins.hasAttr "prePhases" old then old.prePhases else []);
    postPhases = (if builtins.hasAttr "postPhases" old then old.postPhases else []) ++ ["finalPhase"];
    finalPhase = ''
      if test -e $src/nix-support/hydra-release-name; then
        cp $src/nix-support/hydra-release-name $out/nix-support/hydra-release-name
      fi
    '';
  }//extraAttrs);

  jobs = rec {
    nix-build = { system ? builtins.currentSystem }:
                    nixBuild (pkgs.callPackage ./derivation.nix {}) {};

    nix-build-arm = { system ? builtins.currentSystem }:
                    with pkgs-arm;
                    (nixBuild (pkgs-arm.callPackage ./derivation.nix {
                        stdenv = pkgs-arm.stdenv;
                        system = "armv7l-linux";
                    }){});
  };
in
  jobs
```

* `spec.nix`: used by hydra to specify build sets.

```nix
{ nixpkgs ? (import ./nixpkgs.nix), declInput }:
let pkgs = import nixpkgs {config = {};}; in {
  jobsets = pkgs.runCommand "spec.json" {} ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF
    cat > $out <<EOF
    {
      "master": {
        "enabled": 1,
        "hidden": false,
        "description": "my-project",
        "nixexprinput": "src",
        "nixexprpath": "release.nix",
        "checkinterval": 90,
        "schedulingshares": 100,
        "enableemail": true,
        "emailoverride": "",
        "keepnr": 10,
        "inputs": {
            "src": { "type": "git", "value": "file:///repo.git", "emailresponsible": true },
            "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs.git e797e0091356c25282fba4d19690666d4b6f6d0b", "emailresponsible": false }
        }
      },
      "staging": {
        "enabled": 1,
        "hidden": false,
        "description": "my-project",
        "nixexprinput": "src",
        "nixexprpath": "release.nix",
        "checkinterval": 90,
        "schedulingshares": 100,
        "enableemail": false,
        "emailoverride": "",
        "keepnr": 10,
        "inputs": {
            "src": { "type": "git", "value": "file:///repo.git", "emailresponsible": true },
            "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs.git e797e0091356c25282fba4d19690666d4b6f6d0b", "emailresponsible": false }
        }
      }
    }
    EOF
    '';
}
```

* `spec.json`: declarative jobset used in hydra, basically just points to the above spec.nix.

```json
{
    "enabled": 1,
    "hidden": true,
    "description": "Jobsets",
    "nixexprinput": "src",
    "nixexprpath": "spec.nix",
    "checkinterval": 300,
    "schedulingshares": 10,
    "enableemail": false,
    "emailoverride": "",
    "keepnr": 3,
    "inputs": {
        "src": { "type": "git", "value": "file:///repo.git", "emailresponsible": true },
        "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs.git e797e0091356c25282fba4d19690666d4b6f6d0b", "emailresponsible": false }
    }
}
```
