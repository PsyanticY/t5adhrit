# Compiling open source Software manually:

#### This is done for various reason

To compile Stuff you need `make` `c++` ...
These can be installed via:
* Debian/Ubuntu: apt-get install build-essential
* RHEL         : yum groupinstall "development tools"


After downloading and extracting the tar/gz file, Always check if there is any INSTALL file where you can find instruction on how to compile the program

Always pay attention to choose a `--prefix` when running the configuration step or something similar to that. The prefix allow us to specify where to install the binaries, doc, etc

Sometimes the configuration/something similar fail and it is usually due to a missing configuration library/program

when using `make all` or something similar we can specify `-j 32` to allow the compiling process to use your 32 cores instead of a single one.

`make install` generally take all the folders and files and put them in their proper location.

Shutout to the creator of [this video](https://www.youtube.com/watch?v=G4lHVdGX6LI).
