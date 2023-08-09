FROM node:20.5.0-alpine@sha256:a5efe2f6dbaeb81297af5aa576c4c86311da0cecaa4d88325d9a18b05a007c3a AS development

ENV CI=true

RUN corepack enable

COPY ./docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /srv/app

VOLUME /srv/.pnpm-store
VOLUME /srv/app

EXPOSE 1337

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "develop"]


################################################################################
# Build

FROM node:20.5.0-alpine@sha256:a5efe2f6dbaeb81297af5aa576c4c86311da0cecaa4d88325d9a18b05a007c3a AS build

# The `CI` environment variable must be set for pnpm to run in headless mode
ENV CI=true

# Installing libvips-dev for sharp Compatability
RUN apk update && apk add build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev \
  && rm -rf /var/cache/apk/* > /dev/null 2>&1 \
  && corepack enable

WORKDIR /srv/app/

COPY ./pnpm-lock.yaml ./

RUN corepack enable && \
    pnpm fetch

COPY ./ ./

RUN pnpm install --offline \
  && pnpm build

ENV NODE_ENV=production

RUN pnpm install --offline


################################################################################
FROM node:20.5.0-alpine@sha256:a5efe2f6dbaeb81297af5aa576c4c86311da0cecaa4d88325d9a18b05a007c3a

RUN apk add vips-dev \
  && rm -rf /var/cache/apk/* \
  && corepack enable

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PATH /srv/node_modules/.bin:$PATH

WORKDIR /srv/app

COPY --from=build /srv/app ./

EXPOSE 1337

CMD ["pnpm", "start"]
