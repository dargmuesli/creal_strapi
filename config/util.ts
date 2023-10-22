import { readFileSync } from 'node:fs'

export const getSecret = ({ env, name }: { env; name: string }) => {
  const secretFile = env(`${name}_SECRET_FILE`)

  if (!secretFile) {
    console.warn(`Environment variable "${name}_SECRET_FILE" is missing!`)
    return
  }

  return readFileSync(secretFile, {
    encoding: 'utf8',
  }).trim()
}
