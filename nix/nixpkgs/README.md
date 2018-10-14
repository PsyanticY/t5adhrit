# Packaging with nix.  

*notes taken from nixpkgs manual: https://nixos.org/nixpkgs/manual/*

### Phases

Using stdenv:
To build a package with the standard environment, you use the function stdenv.mkDerivation
Specifying a name and a src is the absolute minimum you need to do.
Many packages have dependencies that are not provided in the standard environment. It’s usually sufficient to specify those dependencies in the buildInputs:
This attribute ensures that the bin subdirectories of these packages appear in the PATH environment variable during the build, that their include subdirectories are searched by the C compiler, and so on

Often it is necessary to override or modify some aspect of the build. To make this easier, the standard environment breaks the package build into a number of phases,all of which can be overridden or modified individually, the main phases are:
* unpacking the sources
* applying patches
* configuring
* building
* installing

__controlling Phases__

There are a number of variables that control what phases are executed and in what order:
Variables affecting phase control:
phases: can change the order in which phases are executed, or add new phases. default phases:
...* prePhases
...* unpackPhase
...* patchPhase
...* preConfigurePhases
...* configurePhase
...* preBuildPhases
...* buildPhase
...* checkPhase
...* preInstallPhases
...* installPhase
...* fixupPhase
...* preDistPhases
...* distPhase
...* postPhases


* prePhases: Additional phases executed before any of the default phases.
* preConfigurePhases: Additional phases executed just before the configure phase.
* preBuildPhases: Additional phases executed just before the build phase.
* preInstallPhases: Additional phases executed just before the install phase.
* preFixupPhases: Additional phases executed just before the fixup phase.
* preDistPhases: Additional phases executed just before the distribution phase.
* postPhases: Additional phases executed after any of the default phases.

--- The unpack phase ---
Variables controlling the unpack phase:
* srcs / src
* sourceRoot
* setSourceRoot
* preUnpack
* postUnpack
* dontMakeSourcesWritable
* unpackCmd


--- The patch phase ---

Variables controlling the patch phase:
* patches: The list of patches. They must be in the format accepted by the patch command.
* patchFlags
* prePatch
* postPatch
--- The configure phase ---


The configure phase prepares the source tree for building. The default configurePhase runs ./configure
Variables controlling the configure phase:
* configureScript: The name of the configure script. It defaults to ./configure if it exists; otherwise, the configure phase is skipped.  (it can also be a command)
* configureFlags
* configureFlagsArray
* dontAddPrefix: By default, the flag --prefix=$prefix is added to the configure flags. If this is undesirable, set this variable to true.
* prefix: The prefix under which the package must be installed, passed via the --prefix option to the configure script. It defaults to $out.
* dontAddDisableDepTrack
* dontFixLibtool: By default, the configure phase applies some special hackery to all files called ltmain.sh before running the configure script in order to improve the purity of Libtool-based packages . If this is undesirable, set this variable to true.
* dontDisableStatic
* configurePlatforms
* preConfigure: Hook executed at the start of the configure phase.
* postConfigure: Hook executed at the end of the configure phase.

--- The build phase ---

The build phase is responsible for actually building the package (e.g. compiling it). The default buildPhase simply calls make if a file named Makefile, makefile or GNUmakefile exists in the current directory

Variables controlling the build phase:
* dontBuild: Set to true to skip the build phase.
* makefile: The file name of the Makefile.
* makeFlags: A list of strings passed as additional flags to make. These flags are also used by the default install and check phase. For setting make flags specific to the build phase, use buildFlags
* makeFlagsArray
* buildFlags / buildFlagsArray
* preBuild
* postBuild

--- The check phase ---

The check phase checks whether the package was built correctly by running its test suite.

Variables controlling the check phase
* doCheck: Controls whether the check phase is executed. By default it is skipped
* makeFlags / makeFlagsArray / makefile
* checkTarget: The make target that runs the tests. Defaults to check.
* checkFlags / checkFlagsArray
* preCheck and postCheck

--- The install phase ---

The install phase is responsible for installing the package in the Nix store under out. The default installPhase creates the directory $out and calls make install.

Variables controlling the install phase:
* makeFlags / makeFlagsArray / makefile
* installTargets: The make targets that perform the installation. Defaults to install.
* installFlags / installFlagsArray
* preInstall / postInstall

--- The fixup phase ---

The fixup phase performs some (Nix-specific) post-processing actions on the files installed under $out by the install phase. The default fixupPhase does the following:
* It moves the man/, doc/ and info/ subdirectories of $out to share/.
* It strips libraries and executables of debug information.
* On Linux, it applies the patchelf command to ELF executables and libraries to remove unused directories from the RPATH in order to prevent unnecessary runtime dependencies.
* It rewrites the interpreter paths of shell scripts to paths found in PATH. E.g., /usr/bin/perl will be rewritten to /nix/store/some-perl/bin/perl found in PATH.

__Variables controlling the fixup phase:__

* dontStrip
* dontStripHost
* dontStripTarget
* dontMoveSbin: If set, files in $out/sbin are not moved to $out/bin. By default, they are.
* stripAllList
* stripAllFlags
* stripDebugList List of directories to search for libraries and executables from which only debugging-related symbols should be stripped. It defaults to lib bin sbin.
* stripDebugFlags
* dontPatchELF: If set, the patchelf command is not used to remove unnecessary RPATH entries. Only applies to Linux.
* dontPatchShebangs: If set, scripts starting with #! do not have their interpreter paths rewritten to paths in the Nix store.
* forceShare
* setupHook
* preFixup and postFixup
* separateDebugInfo

--- The installCheck phase ---

The installCheck phase checks whether the package was installed correctly by running its test suite against the installed directories. The default installCheck calls make installcheck.

Variables controlling the installCheck phase
* doInstallCheck: Controls whether the installCheck phase is executed. By default it is skipped
* preInstallCheck and postInstallCheck

--- The distribution phase ---

The distribution phase is intended to produce a source distribution of the package. The default distPhase first calls make dist, then it copies the resulting source tarballs to $out/tarballs/. This phase is only executed if the attribute doDist is set.

Variables controlling the distribution phase
* distTarget: The make target that produces the distribution. Defaults to dist.
* distFlags / distFlagsArray
* tarballs:The names of the source distribution files to be copied to $out/tarballs/. It can contain shell wildcards. The default is `*.tar.gz`.
* dontCopyDist: If set, no files are copied to $out/tarballs/.
* preDist; Hook executed at the start of the distribution phase.
* postDist: Hook executed at the end of the distribution phase.

### Shell functions

substituteinfileoutfilesubs: Performs string substitution on the contents of infile, writing the result to outfile. The substitutions in subs are of the following form:
--replaces1s2
Replace every occurrence of the string s1 by s2.

--subst-varvarName
Replace every occurrence of @varName@ by the contents of the environment variable varName. This is useful for generating files from templates, using @...@ in the template as placeholders.

--subst-var-byvarNames
Replace every occurrence of @varName@ by the string s.

Example:

substitute ./foo.in ./foo.out \
    --replace /usr/bin/bar $bar/bin/bar \
    --replace "a string containing spaces" "some other text" \
    --subst-var someVar

substituteInPlacefilesubs: Like substitute, but performs the substitutions in place on the file file.
substituteAllinfileoutfile: Replaces every occurrence of @varName@, where varName is any environment variable, in infile, writing the result to outfile.
substituteAllInPlacefile: Like substituteAll, but performs the substitutions in place on the file file.
stripHashpath: Strips the directory and hash part of a store path, outputting the name part to stdout

### Package setup hooks

--------------------------------------------
some stuff i didn't understand:

--------------------------------------------

Python: Adds the lib/${python.libPrefix}/site-packages subdirectory of each build input to the PYTHONPATH environment variable.

pkg-config: Adds the lib/pkgconfig and share/pkgconfig subdirectories of each build input to the PKG_CONFIG_PATH environment variable.

paxctl: Defines the paxmark helper for setting per-executable PaX flags on Linux (where it is available by default; on all other platforms, paxmark is a no-op). For example, to disable secure memory protections on the executable foo:

      postFixup = ''
        paxmark m $out/bin/foo
      '';

The m flag is the most common flag and is typically required for applications that employ JIT compilation or otherwise need to execute code generated at run-time. Disabling PaX protections should be considered a last resort: if possible, problematic features should be disabled or patched to work with PaX.

### Hardening in Nixpkgs

There are flags available to harden packages at compile or link-time. These can be toggled using the stdenv.mkDerivation parameters hardeningDisable and hardeningEnable.

-------------------------------
someother stuff that i didnt get a clue off.
-------------------------------


## Multiple-output packages
 ----------------------
didnt understand that much !!!
-----------------------

The Nix language allows a derivation to produce multiple outputs, which is similar to what is utilized by other Linux distribution packaging systems. The outputs reside in separate nix store paths, so they can be mostly handled independently of each other, including passing to build inputs, garbage collection or binary substitution. The exception is that building from source always produces all the outputs.
The main motivation is to save disk space by reducing runtime closure sizes; consequently also sizes of substituted binaries get reduced. Splitting can be used to have more granular runtime dependencies, for example the typical reduction is to split away development-only files, as those are typically not needed during runtime. As a result, closure sizes of many packages can get reduced to a half or even much less.

Installing a split package: When installing a package via systemPackages or nix-env you have several options: ...

# [WIP]
Chapter 5. ..................
-----------------------------------------------------------------------------------------------------------------------------------




///// others

patchs : variable in the pkgs definitions looks for a file that has the patch file. something that looks like git diff
