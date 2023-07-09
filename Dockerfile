# ================
# == BASE STAGE ==
# ================
FROM node:18-alpine as base

WORKDIR /nuxt

COPY package.json yarn.lock* ./

# =============
# == BUILDER ==
# =============
FROM base as builder

# Install all depencies to build
RUN yarn install --production=false

COPY . /nuxt/

RUN yarn build

# ======================
# == PRODUCTION STAGE ==
# ======================
FROM base as production

ENV NODE_ENV=production

# Install pm2 to run app in production:
RUN npm install pm2 -g

# Add pm2 configuration:
COPY --chown=node:node ./ecosystem.config.js /nuxt/

# Install only production packages
RUN yarn --frozen-lockfile --production

# To have lightest as possible, take only built files:
COPY --from=builder --chown=node:node /nuxt/.output/ /nuxt/.output

# Change user to "node" to improve security in production:
USER node

CMD [ "yarn", "start" ]
