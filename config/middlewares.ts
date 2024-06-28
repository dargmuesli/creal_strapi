export default [
  'strapi::errors',
  {
    name: 'strapi::security',
    config: {
      crossOriginResourcePolicy: true,
    },
  },
  'strapi::cors',
  'strapi::poweredBy',
  'strapi::logger',
  'strapi::query',
  'strapi::body',
  'strapi::session',
  'strapi::favicon',
  'strapi::public',
]
