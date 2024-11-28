import { getSecret } from './util'

export default ({ env }) => ({
  connection: {
    acquireConnectionTimeout: env.int('DATABASE_CONNECTION_TIMEOUT', 60000),
    client: env('DATABASE_CLIENT', 'postgres'),
    connection: {
      connectionString: env('DATABASE_URL'),
      database: env('DATABASE_NAME', 'strapi'),
      host: env('DATABASE_HOST', 'postgres'),
      password: env(
        'DATABASE_PASSWORD',
        getSecret({ env, name: 'POSTGRES_PASSWORD' }),
        'utf-8',
      ),
      port: env.int('DATABASE_PORT', 5432),
      ssl: env.bool('DATABASE_SSL', false) && {
        key: env('DATABASE_SSL_KEY', undefined),
        cert: env('DATABASE_SSL_CERT', undefined),
        ca: env('DATABASE_SSL_CA', undefined),
        capath: env('DATABASE_SSL_CAPATH', undefined),
        cipher: env('DATABASE_SSL_CIPHER', undefined),
        rejectUnauthorized: env.bool('DATABASE_SSL_REJECT_UNAUTHORIZED', true),
      },
      user: env(
        'DATABASE_USERNAME',
        getSecret({ env, name: 'POSTGRES_USER' }),
        'utf-8',
      ),
    },
    pool: {
      max: env.int('DATABASE_POOL_MAX', 10),
      min: env.int('DATABASE_POOL_MIN', 0), // not 2 as per default to prevent a 401 error (https://stackoverflow.com/a/76020890/4682621)
    },
  },
})
