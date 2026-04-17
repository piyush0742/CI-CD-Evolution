# ── Stage 1: Base ───────────────────────────────────────────────
# Use official lightweight Node.js image
FROM node:20-alpine AS base

# Set working directory inside the container
WORKDIR /app

# Copy dependency files first (for better layer caching)
COPY package*.json ./

# ── Stage 2: Dependencies ────────────────────────────────────────
FROM base AS deps

# Install only production dependencies
RUN npm ci --only=production

# ── Stage 3: Build/Test ──────────────────────────────────────────
FROM base AS test

# Install ALL dependencies (including devDependencies for testing)
RUN npm ci

# Copy source code
COPY . .

# Run tests — if tests fail, Docker build fails too
RUN ./node_modules/.bin/jest --coverage

# ── Stage 4: Production ──────────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

# Copy production dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY src/ ./src/
COPY package*.json ./

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose the port
EXPOSE 3000

# Build metadata (injected by CI pipeline)
ARG GIT_COMMIT=local
ARG BUILD_DATE=local
ENV GIT_COMMIT=$GIT_COMMIT
ENV BUILD_DATE=$BUILD_DATE

# Start the app
CMD ["node", "src/index.js"]