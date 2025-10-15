#!/bin/bash
# Script para validar que todas las variables de entorno necesarias estén configuradas

set -e

echo "🔍 Validating environment variables for deployment..."
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables requeridas
REQUIRED_VARS=(
    "NODE_ENV"
    "PORT"
    "DB_HOST"
    "DB_PORT"
    "DB_USERNAME"
    "DB_PASSWORD"
    "DB_DATABASE"
    "JWT_SECRET"
    "JWT_EXPIRES_IN"
)

# Contador de errores
MISSING=0
VALID=0

echo "📋 Checking required environment variables:"
echo ""

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${RED}❌ $var is NOT set${NC}"
        MISSING=$((MISSING + 1))
    else
        # Ocultar valores sensibles
        if [[ "$var" == *"PASSWORD"* ]] || [[ "$var" == *"SECRET"* ]]; then
            VALUE="***HIDDEN***"
        else
            VALUE="${!var}"
        fi
        echo "${GREEN}✅ $var${NC} = $VALUE"
        VALID=$((VALID + 1))
    fi
done

# Variables opcionales
echo ""
echo "📋 Optional environment variables:"
echo ""

OPTIONAL_VARS=(
    "DB_SYNCHRONIZE"
    "DB_TYPE"
    "GOOGLE_BOOKS_API_KEY"
    "TWO_FACTOR_AUTHENTICATION_APP_NAME"
)

for var in "${OPTIONAL_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${YELLOW}⚠️  $var is not set (optional)${NC}"
    else
        if [[ "$var" == *"KEY"* ]] || [[ "$var" == *"SECRET"* ]]; then
            VALUE="***HIDDEN***"
        else
            VALUE="${!var}"
        fi
        echo "${GREEN}✅ $var${NC} = $VALUE"
    fi
done

# Resumen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $MISSING -eq 0 ]; then
    echo "${GREEN}✅ All required variables are set! ($VALID/$VALID)${NC}"
    echo ""
    echo "🚀 Your environment is ready for deployment!"
    exit 0
else
    echo "${RED}❌ Missing $MISSING required variable(s)!${NC}"
    echo ""
    echo "💡 Tips:"
    echo "  1. Copy .env.example to .env:"
    echo "     ${YELLOW}cp .env.example .env${NC}"
    echo ""
    echo "  2. Edit .env and fill in the values"
    echo ""
    echo "  3. Load environment variables:"
    echo "     ${YELLOW}source .env${NC} or ${YELLOW}export \$(cat .env | xargs)${NC}"
    echo ""
    exit 1
fi
