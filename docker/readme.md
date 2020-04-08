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


### Docker ecosystem

Docker’s main advantages are:

- *Lightweight resource utilization*: instead of virtualizing an entire operating system, containers isolate at the process level and use the host’s kernel.
- *Portability*: all of the dependencies for a containerized application are bundled inside of the container, allowing it to run on any Docker host.
- *Predictability*: The host does not care about what is running inside of the container and the container does not care about which host it is running on.  The interfaces are standardized and the interactions are predictable.

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
