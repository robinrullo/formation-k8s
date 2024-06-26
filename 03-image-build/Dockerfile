ARG NODE_TAG=22-alpine

FROM docker.io/node:${NODE_TAG}

WORKDIR /app


COPY package*.json .

RUN npm clean-install

COPY . .

ENTRYPOINT [ "node" ]
CMD [ "index.js" ]
