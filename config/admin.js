const fs = require('fs');

module.exports = ({ env }) => {
  let jwtSecret;

  if (process.env['ADMIN_JWT_SECRET_FILE']) {
    try {
      jwtSecret = fs
        .readFileSync(process.env['ADMIN_JWT_SECRET_FILE'], {
          encoding: 'utf8',
        })
        .trim();
      process.env['ADMIN_JWT_SECRET'] = jwtSecret;
    } catch (err) {
      console.log('Failed to read ADMIN_JWT_SECRET_FILE!');
      console.log(err);
    }
  }

  return {
    apiToken: {
      salt: env('ADMIN_JWT_SECRET_FILE'),
    },
    auth: {
      secret: env('ADMIN_JWT_SECRET'),
    },
    host: '0.0.0.0',
    transfer: {
      token: {
        salt: env('ADMIN_JWT_SECRET_FILE'),
      },
    },
    watchIgnoreFiles: [
      '**/config/sync/**',
    ],
  }
};
