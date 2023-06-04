FROM node:20.2.0-alpine@sha256:31ec13908b942ca8b2b05e523c4e4a0f303a89bd75e57a81a241b5fd35677f60 AS development

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

FROM node:20.2.0-alpine@sha256:31ec13908b942ca8b2b05e523c4e4a0f303a89bd75e57a81a241b5fd35677f60 AS build

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
FROM node:20.2.0-alpine@sha256:31ec13908b942ca8b2b05e523c4e4a0f303a89bd75e57a81a241b5fd35677f60

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
