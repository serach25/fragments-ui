# Build the fragments-ui web app and serve it via parcel 

# Stage 0: install the base dependencies

# FROM instruction specifies the parent (or base) image to use as a starting point for our own image
# specifying node version 16.15.0 by adding a :tag

FROM node:16.15.0-alpine3.15@sha256:1a9a71ea86aad332aa7740316d4111ee1bd4e890df47d3b5eff3e5bded3b3d10 AS dependencies

ENV NODE_ENV=production

LABEL maintainer="Serach Boes <saboes@myseneca.com>"
LABEL description="Fragments node.js microservice"

# We default to use port 1234 in our service
#ENV PORT=1234

# Reduce npm spam when installing within Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#loglevel
ENV NPM_CONFIG_LOGLEVEL=warn

# Disable colour when run inside Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#color
ENV NPM_CONFIG_COLOR=false

# define and create our app's working directory
WORKDIR /app

# Copy the package.json and package-lock.json files into the working dir (/app)
COPY package*.json ./

# Install node dependencies defined in package-lock.json
RUN npm ci --only=production

##########################################################################################
# Stage 1: build the site

FROM node:16.15.0-alpine3.15@sha256:1a9a71ea86aad332aa7740316d4111ee1bd4e890df47d3b5eff3e5bded3b3d10 AS builder

# define and create our app's working directory
WORKDIR /app

# Copy the generated dependencies(node_modules/)
COPY --chown=node:node --from=dependencies /app /app

# Copy the source code
COPY --chown=node:node . .

# Build the site, creating /build
RUN npm run build

##########################################################################################
# Stage 2: Serving the built site

FROM nginx:1.22.0-alpine@sha256:0a88a14a264f46562e2d1f318fbf0606bc87e72727528b51613a5e96f483a0f6 AS deploy

COPY --from=builder /app/dist/ /usr/share/nginx/html

EXPOSE 80

# Health check to see if the docker instance is healthy
HEALTHCHECK --interval=15s --timeout=30s --start-period=10s --retries=3 \
  CMD curl --fail localhost || exit 1