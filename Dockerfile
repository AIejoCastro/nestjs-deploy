# ============================================
# Multi-stage Dockerfile para NestJS en Producción
# ============================================

# -------------------- STAGE 1: Build --------------------
FROM node:20-alpine AS builder

# Instalar dependencias necesarias para compilación (bcrypt, etc.)
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias (incluyendo devDependencies para build)
RUN npm ci

# Copiar código fuente
COPY . .

# Compilar aplicación TypeScript
RUN npm run build

# Limpiar devDependencies para reducir tamaño
RUN npm prune --production

# -------------------- STAGE 2: Production --------------------
FROM node:20-alpine AS production

# Crear usuario no-root por seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

WORKDIR /app

# Copiar node_modules y código compilado desde builder
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/package*.json ./

# Cambiar a usuario no-root
USER nestjs

# Exponer puerto (Render usa variable PORT)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node -e "require('http').get('http://localhost:3000/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando de inicio
CMD ["node", "dist/main"]
