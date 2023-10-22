import { getSecret } from './util'

export default ({ env }) => ({
  apiToken: {
    salt: getSecret({ env, name: 'API_TOKEN_SALT' }),
  },
  auth: {
    secret: getSecret({ env, name: 'ADMIN_JWT' }),
  },
  flags: {
    nps: env.bool('FLAG_NPS', true),
  },
  transfer: {
    token: {
      salt: getSecret({ env, name: 'TRANSFER_TOKEN_SALT' }),
    },
  },
  watchIgnoreFiles: ['**/config/sync/**'],
})
