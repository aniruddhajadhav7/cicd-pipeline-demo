# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Dependencies
# Install only production dependencies in a clean layer.
# Using a pinned LTS Alpine image keeps the final image small and secure.
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-alpine AS deps

# Set working directory inside the container
WORKDIR /app

# Copy only package manifests first.
# Docker layer-caches this step — npm install only re-runs when
# package.json or package-lock.json actually changes.
COPY app/package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev


# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Build / Test
# Run linting and tests inside the build stage so a failing test
# will abort the Docker build before any image is pushed.
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package manifests and install ALL dependencies (including devDeps)
COPY app/package*.json ./
RUN npm ci

# Copy the full application source
COPY app/ .

# Run tests — the build fails here if any test fails
RUN npm test


# ─────────────────────────────────────────────────────────────────────────────
# Stage 3 — Production
# Copy only the production deps and source into a lean final image.
# No dev tools, no test files, no secrets.
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-alpine AS production

# Security best practice: do NOT run as root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production node_modules from the deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source from the builder stage
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

# Switch to the non-root user
USER appuser

# Document the port the app listens on
EXPOSE 3000

# Metadata labels (OCI standard)
LABEL maintainer="your-email@example.com" \
      version="1.0.0" \
      description="CI/CD Pipeline Demo — Node.js Express App"

# Healthcheck — Docker / Kubernetes will poll this to determine container health
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "src/index.js"]
