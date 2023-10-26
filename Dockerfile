FROM node:20.9.0-alpine@sha256:8e015de364a2eb2ed7c52a558e9f716dcb615560ffd132234087c10ccc1f2c63 AS development

ENV CI=true

RUN corepack enable

COPY ./docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /srv/app

VOLUME /srv/app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["yarn", "run", "develop"]
EXPOSE 1337


################################################################################
# Prepare

FROM node:20.9.0-alpine@sha256:8e015de364a2eb2ed7c52a558e9f716dcb615560ffd132234087c10ccc1f2c63 AS prepare

ENV CI=true

RUN corepack enable

WORKDIR /srv/app/

COPY ./.yarnrc.yml ./package.json ./yarn.lock ./

RUN yarn install --frozen-lockfile

COPY ./ ./


################################################################################
# Lint

FROM node:20.9.0-alpine@sha256:8e015de364a2eb2ed7c52a558e9f716dcb615560ffd132234087c10ccc1f2c63 AS lint

ENV CI=true

RUN corepack enable

WORKDIR /srv/app/

COPY --from=prepare /srv/app ./

RUN yarn run lint


################################################################################
# Build

FROM node:20.9.0-alpine@sha256:8e015de364a2eb2ed7c52a558e9f716dcb615560ffd132234087c10ccc1f2c63 AS build

ENV CI=true

RUN corepack enable

WORKDIR /srv/app/

COPY --from=prepare /srv/app ./

RUN yarn run build

ENV NODE_ENV=production

RUN yarn install


################################################################################
FROM node:20.9.0-alpine@sha256:8e015de364a2eb2ed7c52a558e9f716dcb615560ffd132234087c10ccc1f2c63 AS production

ENV CI=true

RUN apk add vips-dev \
  && rm -rf /var/cache/apk/* \
  && corepack enable

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PATH /srv/node_modules/.bin:$PATH

WORKDIR /srv/app

COPY --from=lint /srv/app/package.json /tmp/package.json
COPY --from=build /srv/app ./

EXPOSE 1337

CMD ["yarn", "run", "start"]
