ARG BUILDER_IMAGE=registry.access.redhat.com/ubi9/nodejs-20:latest
ARG RUNTIME_IMAGE=quay.io/hummingbird-hatchling/nodejs:20

# Stage 1: Install dependencies with UBI Node.js
FROM ${BUILDER_IMAGE} AS builder

USER 0
WORKDIR /build
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# Stage 2: Runtime on Hummingbird Node.js
FROM ${RUNTIME_IMAGE}

USER 0

# Remove bundled package managers (yarn, npm) -- not needed at runtime
# and they carry transitive vulnerabilities from outdated dependencies
RUN rm -rf /usr/lib/node_modules /usr/lib/node_modules_20 /usr/local/lib/node_modules && \
    rm -f /usr/bin/yarn /usr/bin/yarnpkg /usr/bin/npm /usr/bin/npx /usr/local/bin/npm /usr/local/bin/npx

WORKDIR /app
COPY --from=builder /build ./
RUN chown -R 65532:0 /app

USER 65532

EXPOSE 8080

CMD ["node", "server.js"]
