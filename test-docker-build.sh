#!/bin/bash
# Script para probar el build de Docker localmente antes de desplegar a Render

set -e

echo "🐳 Testing Docker build for Render deployment..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Nombre de la imagen
IMAGE_NAME="biblioicesi-nestjs"
CONTAINER_NAME="biblioicesi-test"

# Limpiar contenedores previos
echo "🧹 Cleaning up previous test containers..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# Build de la imagen
echo ""
echo "${YELLOW}📦 Building Docker image...${NC}"
docker build -t $IMAGE_NAME:test .

if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Build successful!${NC}"
else
    echo "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Verificar tamaño de la imagen
echo ""
echo "📊 Image size:"
docker images $IMAGE_NAME:test --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Ejecutar contenedor de prueba
echo ""
echo "${YELLOW}🚀 Starting test container...${NC}"
docker run -d \
    --name $CONTAINER_NAME \
    -p 3000:3000 \
    -e NODE_ENV=production \
    -e PORT=3000 \
    -e DB_HOST=host.docker.internal \
    -e DB_PORT=5432 \
    -e DB_USERNAME=postgres \
    -e DB_PASSWORD=postgres \
    -e DB_DATABASE=biblio \
    -e DB_SYNCHRONIZE=true \
    -e JWT_SECRET=test_secret_key_for_docker \
    -e JWT_EXPIRES_IN=24h \
    $IMAGE_NAME:test

# Esperar a que el contenedor inicie
echo ""
echo "⏳ Waiting for container to start..."
sleep 5

# Verificar que el contenedor está corriendo
if docker ps | grep -q $CONTAINER_NAME; then
    echo "${GREEN}✅ Container is running!${NC}"
else
    echo "${RED}❌ Container failed to start!${NC}"
    echo ""
    echo "📋 Container logs:"
    docker logs $CONTAINER_NAME
    docker rm -f $CONTAINER_NAME
    exit 1
fi

# Verificar health check
echo ""
echo "🏥 Testing health endpoint..."
sleep 3

if curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "${GREEN}✅ Health check passed!${NC}"
else
    echo "${RED}❌ Health check failed!${NC}"
    echo ""
    echo "📋 Container logs:"
    docker logs $CONTAINER_NAME
    docker rm -f $CONTAINER_NAME
    exit 1
fi

# Mostrar logs
echo ""
echo "📋 Container logs:"
docker logs $CONTAINER_NAME --tail 20

# Información de limpieza
echo ""
echo "${GREEN}🎉 Docker build test completed successfully!${NC}"
echo ""
echo "ℹ️  Your container is running at: http://localhost:3000"
echo ""
echo "To stop and remove the test container, run:"
echo "  ${YELLOW}docker rm -f $CONTAINER_NAME${NC}"
echo ""
echo "To clean up the test image, run:"
echo "  ${YELLOW}docker rmi $IMAGE_NAME:test${NC}"
