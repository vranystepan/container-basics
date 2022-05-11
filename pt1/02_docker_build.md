# Docker build

In this hands-on lab we're going to build our own container image.
We'll be using `docker build` command together with `Dockerfile`.

During this part we'll go through various techniques how
to optimize build speed and produce small, lean images.

## Development setup

Create a new directory, use any name you want.

```bash
mkdir project
cd project
```

Create `package.json` file with following contents

```json
{
  "name": "code",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "node index.js"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "aws-sdk": "^2.1127.0",
    "express": "^4.18.1",
    "firebase": "^9.7.0"
  }
}
```

Create `package-lock.json` with [following contents](../assets/pt1/package-lock.json). It's a bit long...

Create `index.js` file with following contents

```js
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
```

Now we have our "application" in place so we can move to
`docker build` part.

## Quick and dirty Dockerfile

In the same directory, create a new file `Dockerfile`

```dockerfile
FROM node:17.8.0
WORKDIR /src
COPY ./ ./
RUN npm install
CMD ["npm", "start"]
```

We're all set, try to build this image

```bash
docker build -t myapp .
```

Docker engine will pull the base image and it'll
build the image based on the instructions.

Now you can list all the image you have

```bash
docker images
```

and you can also run this image. Don't forget to expose the
application port!

```bash
docker run -it --rm -p3000:3000 myapp 
```

Press ctrl+c.

This image has some design flaws - it does not leverage Docker
Layer Cache. Add some contents to `index.js`
file.

```js
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
```

and build the image again

```bash
docker build -t myapp .
```

See? It was downloading all the dependencies again even though
we did not change dependency graph.

That's because `COPY` command changed the layer digest so
all the subsequent stages need to run again.

## Optimized Dockerfile

In the theoretical part I told you that layers that don't change too much should be put on the beggining.

In this case we're talking about npm-specific files. We can copy
them to the separate layes, run `npm install` and then copy
the rest of the files.

```dockerfile
FROM node:17.8.0
WORKDIR /src
COPY package-lock.json package.json ./
RUN npm install
COPY ./ ./
CMD ["npm", "start"]
```

Build image again

```bash
docker build -t myapp .
```

Add some contents to `index.js` file.

```js
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!!!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
```

And build the image again

```bash
docker build -t myapp .
```

Now there was no need to download dependencies again
because previous layer did not change!



## Multistage build

Sometimes you need to build some stuff and just copy that
to the final container image. For this purpose you can use
so-called multistage builds where only the last stage is exported to the image. This can drastically reduce the size
of the image and it's also easy to read such `Dockerfile`.

Update `Dockerfile` with following contents

```dockerfile
FROM golang:bullseye AS builder
RUN go install mvdan.cc/sh/v3/cmd/shfmt@latest

FROM node:17.8.0
WORKDIR /src
COPY package-lock.json package.json ./
RUN npm install
COPY ./ ./
COPY --from=builder /go/bin/shfmt ./
CMD ["npm", "start"]
```

And build the image again

```bash
docker build -t myapp .
```

Now we can inspect the image

```bash
docker run -it --rm --entrypoint bash myapp
```

And you can see that Go artifact shfmt is really there!

## Building with docker compose

Now we can try some basic developement flow with docker compose.
Create a `docker-compose.yaml` file with following contents

```yaml
version: "3.9"
services:
  web:
    build: .
    ports:
      - "3000:3000"
  redis:
    image: redis
```

And start both containers with

```bash
docker compose up --build
```

We can also try to add some database with persistence!
Stop the previous docker compose stack and extend `docker-compose.yaml` a bit

```yaml
version: "3.9"
services:
  web:
    build: .
    ports:
      - "3000:3000"
  redis:
    image: redis
  mysql:
    platform: linux/x86_64
    image: mysql
    environment:
      - MYSQL_DATABASE=trainig
      - MYSQL_ROOT_PASSWORD=password
    volumes:
      - db:/var/lib/mysql

volumes:
  db:
```

> Please note the `platform` key. Mysql images are not available for M1 computers
> so I had to explicitly specify x86_64 platform otherwise I get
> `no matching manifest for linux/arm64/v8 in the manifest list entries`

In other termimal window, get the id of mysql database and open an new shell
in this container.

```bash
docker exec -it <id> bash
```

Open session to mysql instance

```bash
mysql -u root -p"${MYSQL_ROOT_PASSWORD}"
```

And make some change there e.g.

```sql
CREATE DATABASE test1;
```

Check if the change really happened

```sql
SHOW DATABASES;
```

And escape the container for now.

Stop the docker compose stack (ctrl+c) and remove the containers

```bash
docker compose rm
```

and start it again.

```bash
docker compose up --build
```

Reopen shell in the mysql container

```bash
docker exec -it <id> bash
```

Open session to mysql instance

```bash
mysql -u root -p"${MYSQL_ROOT_PASSWORD}"
```

check if the database is still there

```sql
SHOW DATABASES;
```
