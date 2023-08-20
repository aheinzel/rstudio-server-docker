# rstudio-server-docker

## usage
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

### User Creation
User info can be provided via the environment variable (`-e`) RUSER or STDIN (only in interactive mode). Both options support multiple users whereby data for each user must be provided on a single line. The following formats are supported:
* **`user:pass`** A user named *user* with password *pass*; The user will be mapped to the next free uid and a new primary group will be generated for the user.
* **`1000:user:pass`** A user named *user* mapped to user id *1000* with password *pass*; A new primary group will be generated for the user.
* **`1000:2000:user:pass`** A user named *user* with password *pass*. The user will be mapped to user id *1000* and its primary group will be set to group id *2000*. In case no group with group id *2000* exists a new group named *user* will be automatically created.
