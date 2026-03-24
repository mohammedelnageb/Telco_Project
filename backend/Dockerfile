# builder stage installs dependencies
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build --if-present

# runtime stage runs only necessary artifacts
# to ensure smaller final image
FROM node:18-alpine AS runtime

WORKDIR /app
ENV NODE_ENV=production

# Create non-root user for better security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/server.js ./
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000
CMD ["node", "server.js"]
