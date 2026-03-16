ARG BUILDER_IMAGE=registry.access.redhat.com/ubi9/nodejs-20:latest
ARG RUNTIME_IMAGE=quay.io/hummingbird-hatchling/nodejs:20

# Stage 1: Install dependencies with UBI Node.js
FROM ${BUILDER_IMAGE} AS builder

WORKDIR /build
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Stage 2: Runtime on Hummingbird Node.js
FROM ${RUNTIME_IMAGE}

WORKDIR /app
COPY --from=builder /build ./

USER 65532

EXPOSE 8080

CMD ["node", "server.js"]
