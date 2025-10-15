# 📋 Comandos Útiles - Referencia Rápida

Colección de comandos útiles para desarrollo, testing y despliegue.

---

## 🔧 Desarrollo Local

### Instalar Dependencias
```bash
npm install
```

### Iniciar en Modo Desarrollo
```bash
npm run start:dev
```

### Compilar TypeScript
```bash
npm run build
```

### Iniciar en Modo Producción (Local)
```bash
npm run start:prod
```

---

## 🧪 Testing

### Tests Unitarios
```bash
# Ejecutar todos los tests
npm test

# Ejecutar tests en modo watch
npm run test:watch

# Ejecutar tests con coverage
npm run test:cov
```

### Tests E2E
```bash
# Ejecutar tests e2e
npm run test:e2e

# Ejecutar tests e2e con coverage
npm run test:e2e -- --coverage
```

### Linting
```bash
# Ejecutar linter
npm run lint

# Auto-fix problemas de linting
npm run lint -- --fix
```

### Formatear Código
```bash
npm run format
```

---

## 🐳 Docker

### Build de Imagen Local
```bash
docker build -t biblioicesi-nestjs:local .
```

### Ejecutar Contenedor Local
```bash
docker run -d \
  --name biblioicesi-api \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_DATABASE=biblio \
  -e DB_SYNCHRONIZE=true \
  -e JWT_SECRET=your_secret_key \
  -e JWT_EXPIRES_IN=24h \
  biblioicesi-nestjs:local
```

### Ver Logs del Contenedor
```bash
docker logs biblioicesi-api -f
```

### Detener y Eliminar Contenedor
```bash
docker stop biblioicesi-api
docker rm biblioicesi-api
```

### Eliminar Imagen
```bash
docker rmi biblioicesi-nestjs:local
```

### Test Completo con Script
```bash
# Ejecuta build, run y health check automáticamente
./test-docker-build.sh
```

---

## 🗄️ Base de Datos (Local con Docker Compose)

### Iniciar PostgreSQL
```bash
docker-compose up -d
```

### Ver Logs de PostgreSQL
```bash
docker-compose logs -f db
```

### Detener PostgreSQL
```bash
docker-compose down
```

### Detener y Eliminar Volúmenes
```bash
docker-compose down -v
```

### Conectar a PostgreSQL CLI
```bash
docker-compose exec db psql -U postgres -d biblio
```

### Backup de Base de Datos
```bash
docker-compose exec db pg_dump -U postgres biblio > backup.sql
```

### Restaurar Backup
```bash
docker-compose exec -T db psql -U postgres -d biblio < backup.sql
```

---

## 🔍 Validación y Testing

### Validar Variables de Entorno
```bash
./validate-env.sh
```

### Health Check Manual
```bash
curl http://localhost:3000/
```

### Probar Endpoint con JWT
```bash
# 1. Login para obtener token
TOKEN=$(curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}' \
  | jq -r '.access_token')

# 2. Usar token en request
curl http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🚀 Git y Despliegue

### Commit y Push (Trigger Deploy)
```bash
git add .
git commit -m "feat: your feature description"
git push origin main
```

### Ver Status de Git
```bash
git status
git log --oneline -10
```

### Crear Nueva Rama
```bash
git checkout -b feature/nueva-funcionalidad
```

### Merge a Main
```bash
git checkout main
git merge feature/nueva-funcionalidad
git push origin main
```

### Ver Ramas Remotas
```bash
git branch -r
```

---

## 🌐 GitHub Actions

### Ver Workflows
Ir a: `https://github.com/AIejoCastro/nestjs-carcas-deploy/actions`

### Trigger Manual de Deploy
```bash
# Desde GitHub UI:
# Actions → Deploy to Render → Run workflow

# O con GitHub CLI:
gh workflow run deploy.yml
```

### Ver Logs de Último Run
```bash
# Con GitHub CLI
gh run list --workflow=deploy.yml --limit=1
gh run view --log
```

---

## 🎯 Render

### Ver Logs en Tiempo Real
```bash
# Opción 1: Dashboard web
# https://dashboard.render.com → Service → Logs

# Opción 2: Render CLI (si la tienes instalada)
render logs biblioicesi-api --tail
```

### Trigger Deploy Manualmente
```bash
# Usando el Deploy Hook URL
curl -X POST "https://api.render.com/deploy/srv-xxxxx?key=yyyyy"
```

### Ver Servicios
```bash
# En dashboard: https://dashboard.render.com
```

---

## 🔐 Secrets y Configuración

### Generar JWT Secret Seguro
```bash
# Opción 1: OpenSSL
openssl rand -base64 32

# Opción 2: Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Opción 3: pwgen (si está instalado)
pwgen -s 32 1
```

### Exportar Variables de Entorno (Local)
```bash
# Desde archivo .env
export $(cat .env | xargs)

# O cargar .env en tu shell
source .env
```

### Ver Variables de Entorno Actuales
```bash
env | grep -E 'DB_|JWT_|NODE_ENV|PORT'
```

---

## 📊 Monitoring y Debug

### Ver Uso de Recursos (Container)
```bash
docker stats biblioicesi-api
```

### Inspeccionar Container
```bash
docker inspect biblioicesi-api
```

### Ejecutar Shell en Container
```bash
docker exec -it biblioicesi-api sh
```

### Ver Procesos en Container
```bash
docker top biblioicesi-api
```

### Network Diagnostics
```bash
# Verificar que el puerto está escuchando
lsof -i :3000

# Test de conectividad
nc -zv localhost 3000

# Curl con verbose
curl -v http://localhost:3000/
```

---

## 🧹 Limpieza

### Limpiar Node Modules
```bash
rm -rf node_modules package-lock.json
npm install
```

### Limpiar Build Artifacts
```bash
rm -rf dist
npm run build
```

### Limpiar Docker
```bash
# Eliminar contenedores detenidos
docker container prune -f

# Eliminar imágenes sin usar
docker image prune -f

# Eliminar volúmenes sin usar
docker volume prune -f

# Limpieza completa (¡CUIDADO!)
docker system prune -af --volumes
```

### Limpiar Logs Locales
```bash
rm -f *.log npm-debug.log*
```

---

## 📦 Package Management

### Actualizar Dependencias
```bash
# Ver outdated packages
npm outdated

# Actualizar a minor versions
npm update

# Actualizar a latest versions (CUIDADO)
npm install <package>@latest
```

### Instalar Nueva Dependencia
```bash
# Producción
npm install <package>

# Desarrollo
npm install --save-dev <package>
```

### Remover Dependencia
```bash
npm uninstall <package>
```

### Auditoría de Seguridad
```bash
npm audit

# Auto-fix vulnerabilities
npm audit fix
```

---

## 🎨 Postman / API Testing

### Importar Colección
1. Abrir Postman
2. Import → File → `postman/BiblioIcesi Nest Test.postman_collection.json`
3. Import environment → `postman/BiblioIcesi Nest Environment.postman_environment.json`

### Ejecutar Tests con Newman
```bash
# Instalar Newman globalmente
npm install -g newman

# Ejecutar colección
newman run postman/BiblioIcesi\ Nest\ Test.postman_collection.json \
  -e postman/BiblioIcesi\ Nest\ Environment.postman_environment.json
```

---

## 🔄 CI/CD Troubleshooting

### Ver GitHub Actions Logs
```bash
# Con GitHub CLI
gh run list --limit=5
gh run view <run-id> --log
```

### Re-run Failed Workflow
```bash
# Con GitHub CLI
gh run rerun <run-id>
```

### Ver Secrets Configurados
```bash
# Con GitHub CLI
gh secret list
```

---

## 📚 Recursos Rápidos

| Recurso | Comando/Link |
|---------|-------------|
| Docs API Local | http://localhost:3000/api/docs |
| Health Check | `curl http://localhost:3000/` |
| PostgreSQL CLI | `docker-compose exec db psql -U postgres -d biblio` |
| View Logs | `docker-compose logs -f` |
| Render Dashboard | https://dashboard.render.com |
| GitHub Actions | https://github.com/AIejoCastro/nestjs-carcas-deploy/actions |

---

## 💡 Tips

### Alias Útiles (Agregar a ~/.zshrc o ~/.bashrc)

```bash
# Alias para este proyecto
alias nest-dev="npm run start:dev"
alias nest-test="npm test"
alias nest-build="npm run build && npm run start:prod"
alias db-up="docker-compose up -d"
alias db-down="docker-compose down"
alias db-logs="docker-compose logs -f db"
alias deploy="git push origin main"
```

Después de agregar, recarga tu shell:
```bash
source ~/.zshrc  # o source ~/.bashrc
```

---

## 🆘 Emergency Commands

### App No Responde
```bash
# Reiniciar contenedor local
docker restart biblioicesi-api

# O con docker-compose
docker-compose restart

# Ver qué está usando el puerto
lsof -ti:3000 | xargs kill -9
```

### Base de Datos Corrupta (Local)
```bash
# Eliminar y recrear
docker-compose down -v
docker-compose up -d
```

### Rollback en Render
1. Ve a dashboard.render.com
2. Click en tu service
3. "Manual Deploy" → Selecciona deploy anterior
4. "Deploy selected version"

---

**¿Falta algún comando?** Edita este archivo y agrega lo que necesites.

**Documentación completa**: Ver [INDEX.md](./INDEX.md)
