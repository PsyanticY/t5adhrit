## Docker


Resources:

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
https://www.digitalocean.com/community/tutorials/the-docker-ecosystem-an-overview-of-containerization
https://www.digitalocean.com/community/tutorials/the-docker-ecosystem-an-introduction-to-common-components
https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04


So after all the repository stuff, we install Docker

- Install Docker:

        apt install docker-ce

- Start it and enable it to start at boot

        systemctl start docker
        systemctl enable docker


-- By default, the docker command can only be run the `root` user or by a user in the `docker` group


- To check whether you can access and download images from Docker Hub

        docker run hello-world

- Search for a given docker image:

        docker search ubuntu

- To download the Image:

        docker pull ubuntu

- To see downloaded image:

        docker images

Depending on the image the container running the docker image can complete the task and exit and can run in daemon mode.

- To access the container in interactive mode:

        docker run -it ubuntu

### Managing Docker Containers

- To check active containers:

        docker ps

* Add `-a` to check all containers active and not
* Add `-l` to check for latest created container

Various commands

- `docker start --containerID--`
- `docker stop --containerID--`
- `docker rm --containerID--`

###  Committing Changes in a Container to a Docker Image

after changing what you want in a container  you can commit that to a new docker image: `docker commit -m "What you did to the image" -a "psyanticy" container_id repository/new_image_name`

### Pushing Docker Images to a Docker Repository

After commiting, we need to login to the docker repository

        docker login -u docker-registry-username

Then we push

        docker push docker-registry-username/docker-image-name

## Docker Architecture
[origin post](https://jstobigdata.com/docker-architecture-2/)

#### Docker Daemon

Docker Engine and Docker daemon (dockerd) can be used interchangeably. Docker Daemon is the boss and it is a background process that manages Docker images, containers, networks, and storage volumes. One dockerd can communicate with other daemons to manage docker services. Docker daemon exposes REST api using which other daemons and docker cli communicate with it.

#### Docker Client (CLI)

A user interacts with Docker Engine (dockerd) Using Docker CLI (Docker client). The client uses REST API to talk to dockerd.

#### Docker RegistriesDocker image in depth


Docker registry is the central repo where Docker images are stored. Docker hub is a public docker repo

#### Docker Images

Images are the read-only template with instructions for creating a Docker container.

#### Docker Container

Docker container is a runnable instance of the Docker image. 

By default, a docker container runs in isolation of other containers and host. However, you can configure Dockerfile or pass certain params while running Docker container to open up ports, to make it communicate with other containers, to attach a Volume (storage) and much more.

#### Docker Host

The Docker host is the machine that has docker installed. It comprises of the Docker daemon, Images, Containers, Networks, and Storage.

#### Other Docker components

- Docker Compose: Docker compose is loved by developers, to define and run multi-container docker applications.
- Docker Machine: Docker Machine is a tool for provisioning and managing your Dockerized hosts (hosts with Docker Engine on them).
- Docker Swarm Mode: Docker uses swarm mode to manage clusters of docker-engines. Cluster is also known as Swarm. (assassinated by kubernetes RIP)


### Docker ecosystem

Docker’s main advantages are:

- *Lightweight resource utilization*: instead of virtualizing an entire operating system, containers isolate at the process level and use the host’s kernel.
- *Portability*: all of the dependencies for a containerized application are bundled inside of the container, allowing it to run on any Docker host.
- *Predictability*: The host does not care about what is running inside of the container and the container does not care about which host it is running on.  The interfaces are standardized and the interactions are predictable.
Docker image in depth

Typically, when designing an application or service to use Docker, it works best to break out functionality into individual containers, a design decision known as service-oriented architecture.

The Architecture of Containerized Applications:

Generally, containerized applications work best when implementing a service-oriented design.

Service-oriented applications break the functionality of a system into discrete components that communicate with each other over well-defined interfaces. Container technology itself encourages this type of design because it allows each component to scale out or upgrade independently.


Applications implementing this type of design should have the following qualities:

* They should not care about or rely on any specifics of the host system
* Each component should provide consistent APIs that consumers can use to access the service
* Each service should take cues from environmental variables during initial configuration
* Application data should be stored outside of the container on mounted volumes or in data containers


Using a Docker Registry for Container Management

Once your application is split into functional components and configured to respond appropriately to other containers and configuration flags within the environment, the next step is usually to make your container images available through a registry


## Docker image

__How multilayered implementation works:__ In docker, each image is made up of multiple layers. Docker uses Union FS to combine these layers into one final image.




- show all top-level images, their repository, tags, and their size.

                docker images

- build an image from a Dockerfile

                docker build

- learn more about an image layers

                docker history

- get the system level information on Docker objects

                docker inspect

- remove one or more images

                docker rmi


To pull an image for docker hub use

                docker pull nginx:latest

For custom docker registry, use: 

                docker pull myregistry.local:5000/testing/test-image

run the image in an interactive mode inside a bash shell

                docker run -it --rm nginx:latest bash

List already pulled images

                docker image ls

To list out the dangling image specifically

                docker image ls -f dangling=true

To list all image  – including dangling and the middle layers

                docker image ls -a

List similar images

                docker image ls alpine

To delete an image locally

                docker image rm centos:latest
                or
                docker rmi centos:latest


## Docker container

start/stop a stopped/running container

                docker start centos-container
                or
                docker stop centos-container

Pause a running container and Unpause it

                docker pause centos-container
                or
                docker unpause centos-container

Connecting to a running container (As the official documentation says, use docker exec to run a command in a running container. Command runs in the default directory of the running container. The default directory is specified as the WORKDIR in Dockerfile.)

                docker attach
                or
                docker attach

Use `docker export` or `docker container` export command to export a container’s filesystem as a tar archive

                docker run --name export-import-container -d -it debian
                docker export export-import-container > centos:7.tar

To import it 

                cat centsos:7.tar | docker import - test/imported-centos
                or
                docker import http://example.com/exampleimage.tgz example/imagerepo

Clean up containers (you can only delete a terminated container. Use -f to forcefully delete a running container)

                docker rm container_id

To clean up all terminated containers

                docker container prune

