# rstudio-server-docker

[![docker image with rstudio-server daily version --> docker hub](https://github.com/aheinzel/rstudio-server-docker/actions/workflows/build-and-push-docker-image_with_daily_build.yml/badge.svg)](https://github.com/aheinzel/rstudio-server-docker/actions/workflows/build-and-push-docker-image_with_daily_build.yml)
[![docker image with rstudio-server release version --> docker hub](https://github.com/aheinzel/rstudio-server-docker/actions/workflows/build-and-push-docker-image_with_stable_build.yml/badge.svg)](https://github.com/aheinzel/rstudio-server-docker/actions/workflows/build-and-push-docker-image_with_stable_build.yml)
[![docker image with rstudio-server release version for non root users --> docker hub](https://github.com/aheinzel/rstudio-server-docker/actions/workflows/build-and-push-docker-image_non_root_with_stable_build.yml/badge.svg)](https://github.com/aheinzel/rstudio-server-docker/actions/workflows/build-and-push-docker-image_non_root_with_stable_build.yml)

## Availability
Docker images are available from docker hub ([ah3inz3l/rstudio-server](https://hub.docker.com/r/ah3inz3l/rstudio-server)).

## Usage
### Run (Single User)
```
docker run \
   -d \
   -p8787:8787 \
   -e RUSER="user:pass" \
   -v XXX:/home/user \
   ah3inz3l/rstudio-server notimeout
```

### Run (Multiple Users)
Run container with a single user named *user* with password *pass*. See section
```
docker run \
   -i \
   --rm \
   -p8787:8787 \
   -v XXX:/home/user1 \
   -v XXX:/home/user2 \
   -v XXX:/home/user3 \
   ah3inz3l/rstudio-server notimeout <<USERS
user1:pass1
2000:user2:pass2
2001:3000:user3:pass3
USERS
```

Run container with multiple users (*user1*, *user2*, *user3*) with passwords (*pass1*, *pass2* etc).
```
docker run \
   -d \
   -p8787:8787 \
   -e RUSER="$(cat <<USERS
user1:pass1
2000:user2:pass2
2001:3000:user3:pass3
USERS
)" \
   -v XXX:/home/user1 \
   -v XXX:/home/user2 \
   -v XXX:/home/user3 \
   ah3inz3l/rstudio-server notimeout
```

```
docker run \
   -d \
   -p8787:8787 \
   -e RUSER="$(cat <<USERS
user1:pass1
2000:user2:pass2
2001:3000:user3:pass3
USERS
)" \
   ah3inz3l/rstudio-server notimeout
```

### Run (Single User with Pyxis on Slurm)
Submit a new job launching rstudio-server in single user mode. Only a single user for rstudio-server is support. Password for rstudio-server must be provided via the environment variable *RPASS* (replace *pass* in the example with a password of your choice). Use your container users' user name with the password provided via *RPASS* to login into rstudio-server. Adapt *XXX* to your environment to bind a local folder into the container as the users home-directory. Server address and listening port will be written to stdout.
```
sbatch \
   --ntasks=1 \
   -c 4 \
   --mem=32G \
   --export="RPASS=pass" \
   --wrap='srun \
      --container-image=docker://ah3inz3l/rstudio-server:latest-release-singularity \
      --no-container-mount-home \
      --no-container-entrypoint \
      --container-mounts="./XXX:/root" \
      /entrypoint.sh \
   '
```

### Run (non-root user)
Run container with non-root user (singularity without fakeroot and similar). Launches rstudio-server under the non-root user used in the container. Only a single user for rstudio-server is support. Password for rstudio-server must be provided via the environment variable *RPASS* (replace *pass* in the example with a password of your choice). Use your container users' user name with the password provided via *RPASS* to login into rstudio-server. Adapt *XXX* and *CONTAINER-USER* to your environment to bind a local folder into the container as the users home-directory. 
```
singularity run \
   --contain \
   --ipc \
   --cleanenv \
   --writable-tmpfs \
   --bind XXX:/home/CONTAINER-USER \
   --env RPASS=pass \
   "docker://ah3inz3l/rstudio-server:latest-release-singularity"
```

### User Creation (only for images running as root)
User info can be provided via the environment variable (`-e`) RUSER or STDIN (only in interactive mode). Both options support multiple users whereby data for each user must be provided on a single line. The following formats are supported:
* **`user:pass`** A user named *user* with password *pass*; The user will be mapped to the next free uid and a new primary group will be generated for the user.
* **`1000:user:pass`** A user named *user* mapped to user id *1000* with password *pass*; A new primary group will be generated for the user.
* **`1000:2000:user:pass`** A user named *user* with password *pass*. The user will be mapped to user id *1000* and its primary group will be set to group id *2000*. In case no group with group id *2000* exists a new group named *user* will be automatically created.
