# Python packaging in NixOS

For more in-depth stuff check: [nixpkgs/doc/languages-frameworks/python.section.md](https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md)


## Installing Python and packages

The Nix and NixOS manuals explain how packages are generally installed. In the case of Python and Nix, it is important to make a distinction between whether the package is considered an application or a library.

Applications on Nix are typically installed into your user profile imperatively using nix-env -i, and on NixOS declaratively by adding the package name to environment.systemPackages in /etc/nixos/configuration.nix. Dependencies such as libraries are automatically installed and should not be installed explicitly.

## Environment defined in separate .nix file
Create a file, e.g. build.nix, with the following expression
  ```
    with import <nixpkgs> {};
    python35.withPackages (ps: with ps; [ numpy toolz ])
  ```
and install it in your profile with
  ```
  nix-env -if build.nix
  ```
If you prefer to, you could also add the environment as a package override to the Nixpkgs set, e.g. using config.nix
```nix
    { # ...

      packageOverrides = pkgs: with pkgs; {
        myEnv = python35.withPackages (ps: with ps; [ numpy toolz ]);
      };
    }
```
and install it in your profile with
```shell
  nix-env -iA nixpkgs.myEnv
```

here's another example how to install the environment system-wide
```nix
    { # ...

      environment.systemPackages = with pkgs; [
        (python35.withPackages(ps: with ps; [ numpy toolz ]))
      ];
    }
```

## Temporary Python environment with nix-shell

nix-shell gives the possibility to temporarily load another environment, akin to virtualenv.

The first and recommended method is to create an environment with `python.buildEnv` or `python.withPackages`:
```bash
  $ nix-shell -p 'python35.withPackages(ps: with ps; [ numpy toolz ])'
```

The other method, which is not recommended, does not create an environment and requires you to list the packages directly,
```bash
$ nix-shell -p python35.pkgs.numpy python35.pkgs.toolz
```

nix-shell can also load an expression from a .nix file.
```nix
with import <nixpkgs> {};

  (python35.withPackages (ps: [ps.numpy ps.toolz])).env
```

`with` statement brings all attributes of `nixpkgs` in the local scope. we create a Python 3.5 environment with the `withPackages` function.

The `withPackages` function expects us to provide a function as an argument that takes the set of all python packages and returns a list of packages to include in the environment. Here, we select the packages `numpy` and `toolz` from the package set.

Execute command with `--run`
A convenient option with `nix-shell` is the `--run` option, with which you can execute a command in the nix-shell. We can e.g. directly open a Python shell
```bash
$ nix-shell -p python35Packages.numpy python35Packages.toolz --run "python3"
```

## Developing with Python

 The function buildPythonPackage is called and as argument it accepts a set. In this case the set is a recursive set, rec. One of the arguments is the name of the package, which consists of a basename (generally following the name on PyPi) and a version. Another argument, src specifies the source, which in this case is fetched from PyPI using the helper function fetchPypi.The output of the function is a derivation.

 If something is exclusively a build-time dependency, then the dependency should be included as a `buildInput`, but if it is (also) a runtime dependency, then it should be added to `propagatedBuildInputs`. Test dependencies are considered build-time dependencies.

Occasionally you have also system libraries to consider (alongside python packages). E.g., lxml provides Python bindings to libxml2 and libxslt. These libraries are only required when building the bindings and are therefore added as `buildInputs`.

## Building packages and applications

Python libraries and applications that use setuptools or distutils are typically build with respectively the buildPythonPackage and buildPythonApplication functions. These two functions also support installing a wheel.

## `buildPythonPackage` function

* The `buildPythonPackage` function is implemented in `pkgs/development/interpreters/python/build-python-package.nix`
* The `buildPythonPackage` mainly does four things:
* In the `buildPhase`, it calls ${python.interpreter} setup.py bdist_wheel to build a wheel binary zipfile.
* In the `installPhase`, it installs the wheel file using pip install `*.whl`.
* In the `postFixup` phase, the `wrapPythonPrograms` bash function is called to wrap all programs in the `$out/bin/*` directory to include `$PATH` environment variable and add dependent libraries to script's `sys.path`.
* In the `installCheck` phase, `${python.interpreter} setup.py test` is ran.

## `buildPythonPackage` parameters
* `namePrefix`: Prepended text to ${name} parameter.
* `disabled`: If true, package is not build for particular python interpreter version.
* `setupPyBuildFlags`: List of flags passed to setup.py build_ext command
* `pythonPath`: List of packages to be added into $PYTHONPATH. Packages in `pythonPath` are not propagated (contrary to `propagatedBuildInputs`).
* `preShellHook`: Hook to execute commands before shellHook
* `postShellHook`: Hook to execute commands after shellHook
* `makeWrapperArgs`: A list of strings. Arguments to be passed to makeWrapper, which wraps generated binaries. By default, the arguments to makeWrapper set PATH and PYTHONPATH environment variables before calling the binary. Additional arguments here can allow a developer to set environment variables which will be available when the binary is run. For example, `makeWrapperArgs = ["--set FOO BAR" "--set BAZ QUX"]`. (real example: `makeWrapperArgs = ["--prefix" "PATH" ":" "${stdenv.lib.makeBinPath [ imagemagick xpdf tesseract ]}" ];` ) other example : ``makeWrapperArgs = ["--prefix" "PATH" ":" "${openssl}/bin" "--set" "PYTHONPATH" ":"];``
* `installFlags`: A list of strings. Arguments to be passed to pip install. To pass options to python setup.py install, use --install-option. E.g., installFlags=["--install-option='--cpp_implementation'"].
* `format`: Format of the source. Valid options are setuptools (default), flit, wheel, and other
* `catchConflicts` If true, abort package build if a package name appears more than once in dependency tree. Default is true
* `checkInputs` Dependencies needed for running the checkPhase. These are added to `buildInputs` when `doCheck = true`.

# Automatic tests

By default the command python setup.py test is run as part of the `checkPhase`, but often it is necessary to pass a custom checkPhase. An example of such a situation is when py.test is used.

Most python modules follows the standard test protocol where the pytest runner can be used instead. `py.test` supports a -k parameter to ignore test methods or classes:

```nix
buildPythonPackage {
  # ...
  # assumes the tests are located in tests
  checkInputs = [ pytest ];
  checkPhase = ''
    py.test -k 'not function_name and not other_function' tests
  '';
}
```

## Notes

Unicode issues can typically be fixed by including glibcLocales in buildInputs and exporting `LC_ALL=en_US.utf-8`.

Tests that attempt to access $HOME can be fixed by using the following work-around before running tests (e.g. preCheck): export HOME=$(mktemp -d)
