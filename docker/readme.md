## Docker


Following from this: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

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