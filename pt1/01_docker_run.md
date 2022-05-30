# Docker run

In this hands-on lab we're going to use some community images
to demonstrate features you can leverage while implementing
Docker to your workflow.

## Run container as "blocking process"

This is the easiest possible way to run container. All the
standard output is written to your console so you don't have
to search for logs.

```bash
docker run nginx
```

Open another terminal window / tab and list the containers
managed by the Docker engine.

```bash
docker ps
```

you should see similar output

```
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
2cd84f51e21d   nginx     "/docker-entrypoint.…"   24 seconds ago   Up 23 seconds   80/tcp    condescending_mirzakhani
```

go back to the previous window / tab and press ctrl + c.

## Run container as "daemon"

Use command from the previous example but add `-d` right
after the run keyword.

> `-d` stands for daemon, it means [background process](https://en.wikipedia.org/wiki/Daemon_(computing))

```bash
docker run -d nginx
```

Command will return the full id of the created container.
Copy this id and use it in `docker inspect` command e.g.

```bash
docker inspect c5b796e4560f506556b13edb8c70f8c36e8379583fe9d720cff32cc4f6bc8c7b
```

> `docker inspect` is good the get some low-level infromation
> about the container. 

Now can go through all the topics we were talking about it
the theoretical session:

- entrypoints
- configuration of mounts
- environment variables
- configured memory limits
- ...

Let's kill this container for now

```bash
docker kill c5b796e4560f
```

## Introduce memory limit

Let's try to add some memory limit and check the configuration again.

> Memory limit effectively configured control group so container
> can't use any memory beyond this limit. This is useful in case
> you don't want to endanger other processes with possible usage peaks

```bash
docker run -d --memory 100Mi nginx
docker inspect <ID>
```

> Look for the `.HostConfig.Memory` property.

How does it look from the container point of view? Let's
open a new shell in out nginx container.

```bash
docker exec -it <ID> bash
```

And check configuration of cgroups

```bash
cat /sys/fs/cgroup/memory.max
```

So if the application runtime is aware of cgroups - it can
easily read the limits and behave accordingly.

> For instance, Nodejs and Java applications are able to
> configure heap size based on the control group config.

## expose container's port to you host

This container is running Nginx on port 80. But when you try to
send request to `localhost:80` - it won't work. Container's port
is not exposed.

Kill the previosly created container

```bash
docker kill <ID>
```

and start a new one with additional flag `-p 8080:80`.

```bash
docker run -d -p 8080:80 nginx
```

> please note that `-p` stands for `publish`, the first number
> is the host's port, the second number is the container's port.
> So in this particular case, container's port 80 will be accessible
> on localhost port 8080.

List running containers

```bash
docker ps
```

you should see something like

```
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                  NAMES
e01ecd1b2636   nginx     "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp   thirsty_thompson
```

The interesting part is `PORTS`, you can see there the host's
port 8080 is mapped to container's port 80.

Try to send a http requests to localhost:8080

```bash
curl localhost:8080
```

Now you can view the logs

```bash
docker logs <ID>
```

## View the performance "metrics"

Containers consume your host's resources. You can simply
view it with `stats` command.

```bash
docker stats <ID>
```

If there are limits configured, stats will display them as well.
This is a very convenient way to tune up your containers.

When finished, kill this container.

```bash
docker kill <ID>
```

## Cleanup

List **all** containers

```bash
docker ps -a
```

Do you see all the killed containers? These are actually still
living on yout hard drive. So remove all of them so they don't
eat your disk space.

```bash
docker rm <id>
```

But this is kinda boring... try this instead

```bash
docker container prune
```

And list **all** containers again.

```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## Orchestration

Create `docker-compose.yaml` file with following contents

```yaml
version: "3.9"
services:
  web:
    image: nginx:alpine
    ports:
      - "8000:80"
  redis:
    image: redis
```

and run `docker compose up`. This command will be blocking and all
the logs from both containers will be written to your console.

Open another terminal and list the running containers

```bash
docker ps
```

Get the id of `nginx` container e.g. `169b85f66ecf` and open a new
shell in this container

```bash
docker exec -it <nginx id> sh
```

In the container, install `nmap`

> `nmap` is very useful tool for port scanning and similar tasks.
> In this example we'll just check if the port is open.

```bash
apk add nmap
```

and try if the redis port is open

```bash
nmap -Pn redis -p 6379
```

> With this command we're checking if the port is open.
> This will efectively verify if the name resolution works
> or not.

Please note that we was able to use container name as the dns name.
That's brilliant!

Type `exit` to exit the container shell and list the containers again.

```bash
docker ps
```

Get the id of nginx container and inspect properties of this container

```bash
docker inspect <nginx id>
```

In the very bottom of the output you're gonna see that container
has been connected to some sort of network and it has 3 aliases -
network names.

Inspect also the redis container

```bash
docker inspect <redis id>
```

Here you can see that redis container has `redis` network alias
so that's why we were able to use this name while opening
connection with `nmap` command.

Go to the previous terminal window and terminate both containers
by pressing ctrl+c.

## Diffing the changes made in the container

Now let's try some fun. Run a new interactive `busybox` container

```bash
docker run -it --rm busybox
```

And get its id in the other terminal. Now let's see the changes in
the running container. You should see nothing.

```bash
docker diff <id>
```

Go back to the shell opened in the container and create a dummy file

```bash
echo bla > /test
```

And execute the diff again

```bash
docker diff <id>
```

Now you should see changes made in the container.