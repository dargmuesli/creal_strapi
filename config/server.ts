import { getSecret } from './util'

export default ({ env }) => ({
  app: {
    keys: getSecret({ env, name: 'APP_KEYS' })?.split(','),
  },
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  webhooks: {
    populateRelations: env.bool('WEBHOOKS_POPULATE_RELATIONS', false),
  },
})
