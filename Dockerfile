FROM node:19.6.0-alpine@sha256:ebd018afea26341e981ce1b01d6859a5d185b2d840f89c075239e3b7e6e92715 AS development

RUN npm install -g pnpm

COPY ./docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /srv/app

VOLUME /srv/.pnpm-store
VOLUME /srv/app

EXPOSE 1337

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "develop"]


################################################################################
# Build

# Should be the specific version of `node:alpine`.
FROM node:19.6.0-alpine@sha256:ebd018afea26341e981ce1b01d6859a5d185b2d840f89c075239e3b7e6e92715 AS build

# Installing libvips-dev for sharp Compatability
RUN apk update && apk add build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev \
  && rm -rf /var/cache/apk/* > /dev/null 2>&1 \
  && npm install -g pnpm

WORKDIR /srv/app/

COPY ./pnpm-lock.yaml ./

RUN npm install -g pnpm && \
    pnpm fetch

COPY ./ ./

RUN pnpm install --offline \
  && pnpm build

ENV NODE_ENV=production

RUN pnpm install --offline


################################################################################
FROM node:19.6.0-alpine@sha256:ebd018afea26341e981ce1b01d6859a5d185b2d840f89c075239e3b7e6e92715

RUN apk add vips-dev \
  && rm -rf /var/cache/apk/* \
  && npm install -g pnpm

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PATH /srv/node_modules/.bin:$PATH

WORKDIR /srv/app

COPY --from=build /srv/app ./

EXPOSE 1337

CMD ["pnpm", "start"]
