# Build image

## Package an application

To package a node.js application, create a `Dockerfile` starting from the node base image.

```Dockerfile
FROM docker.io/node:22-slim
```

Set the current working directory
```Dockerfile
WORKDIR /app
```

Copy the `package.json` and `package-lock.json` files to the image
```Dockerfile
COPY package.json package.json
COPY package-lock.json package-lock.json
```

Install dependencies
```Dockerfile
RUN npm install
```

Copy source files
```Dockerfile
COPY . .
```

Set the entrypoint 
```Dockerfile
ENTRYPOINT [ "node" ]
```

Set the command
```Dockerfile
CMD [ "index.js" ]
```

Explain difference between entrypoint and cmd

Build the image
```bash
docker build -t myapp:0.1.0 .
```

Run the image
```bash
docker run --rm -it myapp:0.1.0
```

Try to exit the container with `ctrl+c`.  
Try to stop the container with `docker stop`  
Show that container is not stopping with `docker ps -a`  
Kill the container with `docker kill`  

Explain why `ctrl+c` and `docker stop` are not working.  
Talk about signal handling, `SIGINT` and `SIGTERM`.

Add code to handle signals.
```js
process.on('SIGINT', () => {
    console.log('Received SIGINT. Exiting.');
    process.exit()
})

process.on('SIGTERM', () => {
    console.log('Received SIGTERM. Exiting.');
    process.exit()
})
```

Rebuild the image and run.
```bash
docker build -t myapp:0.1.0 .
docker run --rm -it myapp:0.1.0
```

Show that `SIGINT` and `SIGTERM` are now working.

Talk about entrypoints and PID1.  
Show `entrypoint.sh` and how to replace the entrypoint script with the main process.

## Push to container registry

Login to scaleway container registry created in module `02-tf-kubernetes`.
```bash
scw registry login
```

Tag the image with the correct URL.
```bash
docker tag myapp:0.1.0 rg.fr-par.scw.cloud/learn_k8s_staging/myapp:0.1.0
```

## Best practices

- Group operations on the same files in the same `RUN` instruction to prevent data duplication
- If using an entrypoint, make sure to replace the PID1 by the application process with `exec` (or equivalent depending on entrypoint language)
- Handle SIGTERM and SIGINT signals properly
- Use the multi-stage build feature

