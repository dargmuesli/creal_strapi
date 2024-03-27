#############
# Create base image.

FROM node:20.12.0-alpine AS base-image

# The `CI` environment variable must be set for pnpm to run in headless mode
ENV CI=true

WORKDIR /srv/app/

RUN corepack enable


#############
# Serve Strapi in development mode.

FROM base-image AS development

COPY ./docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

VOLUME /srv/.pnpm-store
VOLUME /srv/app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "develop"]
EXPOSE 1337


################################################################################
# Prepare

FROM base-image AS prepare

COPY ./pnpm-lock.yaml ./

RUN pnpm fetch

COPY ./ ./

RUN pnpm install --offline

################################################################################
# Lint

FROM prepare AS lint

RUN pnpm run lint


################################################################################
# Build

FROM prepare AS build

ENV NODE_ENV=production

RUN pnpm run build \
  && pnpm install --ignore-scripts


################################################################################
FROM build AS production

RUN apk add --no-cache vips-dev

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PATH /srv/node_modules/.bin:$PATH

COPY --from=lint /srv/app/package.json /tmp/package.json

EXPOSE 1337

CMD ["pnpm", "run", "start"]
