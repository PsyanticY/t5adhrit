## Docker file

https://rominirani.com/docker-tutorial-series-writing-a-dockerfile-ce5746617cd


Dockerfile is a more consistent and repeatable way to build images rather then running a container, adding changes then saving it to a new image.

Used for Repeatable, Consistent Builds

Dockerfiles are simple build files that describe how to create a container image from a known starting point. They provide:

* Can be version controlled
* Accountability: If you plan on sharing your images, it is often a good idea to provide the Dockerfile that created the image as a way for other users to audit the process.
* Flexibility: Creating images from a Dockerfile allows you to override the defaults that interactive builds are given.

A Dockerfile provides a series of instructions on how to build docker image.

* The overall flow:
    1. Create a Dockerfile with the required instructions.
    2. Use the docker build command to create a Docker image based on that Dockerfile

----

            FROM ubuntu:latest
            MAINTAINER Dovah Kin (dovah.kin@skyrim.home)
            LABEL com.example.label-with-value="foo"
            LABEL version="1.0"
            ENV myName John Doe
            ENV myDog Rex The Dog
            ENV myCat fluffy
            RUN apt-get update
            USER patrick
            ADD test relativeDir/          # adds "test" to `WORKDIR`/relativeDir/
            ADD test /absoluteDir/         # adds "test" to /absoluteDir/
            EXPOSE 80/tcp
            EXPOSE 80/udp
            ENTRYPOINT ["/bin/cat"]
            CMD ["/etc/passwd"]
            EXPOSE 80/tcp
            EXPOSE 80/udp

- `FROM`: Since, a Docker image is nothing but a series of layers built on top of each other, we start with a base image. The FROM command sets the base image for the rest of the instructions. Dockerfile always starts with a FROM instruction
- `MAINTAINER`: The MAINTAINER command tells who is the author of the generated images
- `ENTRYPOINT`: form: `ENTRYPOINT ["executable", "param1", "param2"]`. An `ENTRYPOINT` allows you to configure a container that will run as an executable.
- `CMD`: There can only be one CMD instruction in a Dockerfile. If you list more than one CMD then only the last CMD will take effect. The main purpose of a CMD is to provide defaults for an executing container. These defaults can include an executable, or they can omit the executable, in which case you must specify an ENTRYPOINT instruction as well. 
    * CMD ["executable","param1","param2"] (exec form, this is the preferred form)
    * CMD ["param1","param2"] (as default parameters to ENTRYPOINT)

In the second case, we can override CMD by smething like that : `docker run -it myimage somefile.txt`

- `RUN`: The RUN instruction will execute any commands in a new layer on top of the current image and commit the results. The resulting committed image will be used for the next step in the Dockerfile
- `EXPOSE`: The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime. You can specify whether the port listens on TCP or UDP, and the default is TCP if the protocol is not specified.
- `LABEL`: The LABEL instruction adds metadata to an image. A LABEL is a key-value pair.
- `ENV`: The ENV instruction sets the environment variable <key> to the value <value>. This value will be in the environment for all subsequent instructions in the build stage and can be replaced inline in many as well.
- `ADD`: The ADD instruction copies new files, directories or remote file URLs from <src> and adds them to the filesystem of the image at the path <dest>.
    * `ADD [--chown=<user>:<group>] <src>... <dest>`
- `COPY`: The COPY instruction copies new files or directories from <src> and adds them to the filesystem of the container at the path <dest>.
    * `COPY [--chown=<user>:<group>] <src>... <dest>`
- `USER`: The USER instruction sets the user name (or UID) and optionally the user group (or GID) to use when running the image and for any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
- `WORKDIR`: The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile. If the WORKDIR doesn’t exist, it will be created even if it’s not used in any subsequent Dockerfile instruction.

 ------
 Advanced instructions to check later:
- `VOLUME`
- `ARG`
- `ONBUILD`
- `STOPSIGNAL`
- `HEALTHCHECK`
- `SHELL`