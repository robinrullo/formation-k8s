ARG NODE_TAG=22-alpine

FROM docker.io/node:${NODE_TAG}

WORKDIR /app


COPY package*.json .

RUN npm clean-install

COPY . .

RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD [ "index.js" ]
