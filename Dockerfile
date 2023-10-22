FROM node:20.8.1-alpine@sha256:002b6ee25b63b81dc4e47c9378ffe20915c3fa0e98e834c46584438468b1d0b5 AS development

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

FROM node:20.8.1-alpine@sha256:002b6ee25b63b81dc4e47c9378ffe20915c3fa0e98e834c46584438468b1d0b5 AS prepare

ENV CI=true

RUN corepack enable

WORKDIR /srv/app/

COPY ./.yarnrc.yml ./package.json ./yarn.lock ./

RUN yarn install --frozen-lockfile

COPY ./ ./


################################################################################
# Lint

FROM node:20.8.1-alpine@sha256:002b6ee25b63b81dc4e47c9378ffe20915c3fa0e98e834c46584438468b1d0b5 AS lint

ENV CI=true

RUN corepack enable

WORKDIR /srv/app/

COPY --from=prepare /srv/app ./

RUN yarn run lint


################################################################################
# Build

FROM node:20.8.1-alpine@sha256:002b6ee25b63b81dc4e47c9378ffe20915c3fa0e98e834c46584438468b1d0b5 AS build

ENV CI=true

RUN corepack enable

WORKDIR /srv/app/

COPY --from=prepare /srv/app ./

RUN yarn run build

ENV NODE_ENV=production

RUN yarn install


################################################################################
FROM node:20.8.1-alpine@sha256:002b6ee25b63b81dc4e47c9378ffe20915c3fa0e98e834c46584438468b1d0b5 AS production

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
