# ---- Builder ----
FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci --ignore-scripts || npm install --ignore-scripts
COPY . .
RUN npm run build

# ---- Runtime ----
FROM node:20-alpine AS runtime
# non-root пользователь
RUN addgroup -g 10001 -S app && adduser -S -u 10001 -G app app
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
USER 10001:10001
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=20s CMD wget -qO- http://127.0.0.1:3000/redis || exit 1
CMD ["node", "dist/main.js"]
