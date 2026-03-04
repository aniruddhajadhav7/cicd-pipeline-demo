FROM node:18-alpine AS deps
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev

FROM node:18-alpine AS builder
WORKDIR /app
COPY app/package*.json ./
RUN npm ci
COPY app/ .
RUN npm test

FROM node:18-alpine AS production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=deps    --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/src          ./src
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "src/index.js"]
