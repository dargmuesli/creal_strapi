export default [
  'strapi::logger',
  'strapi::errors',
  {
    name: 'strapi::security',
    config: {
      ...(process.env.NODE_ENV === 'production'
        ? {
            crossOriginResourcePolicy: {
              policy: 'same-site',
            },
          }
        : undefined),
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
