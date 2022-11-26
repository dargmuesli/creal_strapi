FROM node:18.12.1-alpine@sha256:67373bd5d90ea600cb5f0fa58d7a5a4e6ebf50b6e05c50c1d1cc22df5134db43 AS development
# Installing libvips-dev for sharp Compatability
RUN apk update && apk add build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev \
  && rm -rf /var/cache/apk/* > /dev/null 2>&1 \
  && npm install -g pnpm
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
WORKDIR /srv/
COPY ./pnpm-lock.yaml ./
ENV PATH /srv/node_modules/.bin:$PATH
RUN pnpm config set network-timeout 600000 -g && pnpm fetch
WORKDIR /srv/app
COPY ./ .
RUN pnpm install --offline && pnpm build
EXPOSE 1337
CMD pnpm && pnpm develop

FROM node:18.12.1-alpine@sha256:67373bd5d90ea600cb5f0fa58d7a5a4e6ebf50b6e05c50c1d1cc22df5134db43
RUN apk add vips-dev \
  && rm -rf /var/cache/apk/* \
  && npm install -g pnpm
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /app
COPY --from=development /srv/node_modules ./node_modules
ENV PATH /srv/node_modules/.bin:$PATH
COPY --from=development /srv/app ./
EXPOSE 1337
CMD ["pnpm", "start"]
