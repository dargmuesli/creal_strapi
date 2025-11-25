export default [
  'strapi::logger',
  'strapi::errors',
  {
    name: 'strapi::security',
    config: {
      crossOriginEmbedderPolicy: true,
      crossOriginResourcePolicy: {
        policy: 'cross-origin', // TODO: proxy uploads and set to `same-origing` / `true`
      },
    },
  },
  'strapi::cors',
  'strapi::poweredBy',
  'strapi::query',
  'strapi::body',
  'strapi::session',
  'strapi::favicon',
  'strapi::public',
]
