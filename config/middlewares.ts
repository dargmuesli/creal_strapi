export default [
  'strapi::errors',
  {
    name: 'strapi::security',
    config: {
      crossOriginResourcePolicy: { policy: 'same-site' },
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
