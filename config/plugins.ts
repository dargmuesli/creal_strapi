import { getSecret } from './util'

export default ({ env }) => ({
  'users-permissions': {
    config: {
      jwtSecret: getSecret({ env, name: 'ADMIN_JWT' }),
    },
  },
})
