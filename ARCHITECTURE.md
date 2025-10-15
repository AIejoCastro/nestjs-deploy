# 🏗️ Arquitectura de Despliegue en Render

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                           GITHUB                                     │
│  ┌───────────────────────────────────────────────────────────┐     │
│  │  Repository: nestjs-carcas-deploy                          │     │
│  │  Branch: main                                              │     │
│  └───────────────────────────────────────────────────────────┘     │
│                              │                                       │
│                              │ git push                              │
│                              ▼                                       │
│  ┌───────────────────────────────────────────────────────────┐     │
│  │              GitHub Actions CI/CD                          │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                │     │
│  │  │  Lint    │→ │  Tests   │→ │  Deploy  │                │     │
│  │  └──────────┘  └──────────┘  └──────────┘                │     │
│  └───────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               │ Deploy Hook (HTTPS POST)
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           RENDER.COM                                 │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              Blueprint: render.yaml                          │   │
│  │              Infrastructure as Code                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │         Web Service: biblioicesi-api                         │   │
│  │  ┌───────────────────────────────────────────────────┐      │   │
│  │  │  Docker Container                                 │      │   │
│  │  │  ┌─────────────────────────────────────────┐     │      │   │
│  │  │  │  NestJS Application                     │     │      │   │
│  │  │  │  - Node.js 20 Alpine                   │     │      │   │
│  │  │  │  - Port: 3000                          │     │      │   │
│  │  │  │  - Multi-stage build                   │     │      │   │
│  │  │  │  - Health check enabled                │     │      │   │
│  │  │  └─────────────────────────────────────────┘     │      │   │
│  │  └───────────────────────────────────────────────────┘      │   │
│  │                         │                                    │   │
│  │                         │ Internal network                   │   │
│  │                         │                                    │   │
│  │  Environment Variables: ▼                                   │   │
│  │  ┌──────────────────────────────────────────────┐          │   │
│  │  │  NODE_ENV=production                         │          │   │
│  │  │  PORT=3000                                   │          │   │
│  │  │  DB_HOST=<from database service>            │          │   │
│  │  │  DB_PORT=<from database service>            │          │   │
│  │  │  DB_USERNAME=<from database service>        │          │   │
│  │  │  DB_PASSWORD=<from database service>        │          │   │
│  │  │  DB_DATABASE=<from database service>        │          │   │
│  │  │  DB_SYNCHRONIZE=false                       │          │   │
│  │  │  JWT_SECRET=<auto-generated>                │          │   │
│  │  │  JWT_EXPIRES_IN=7d                          │          │   │
│  │  └──────────────────────────────────────────────┘          │   │
│  │                                                              │   │
│  │  Public URL: https://biblioicesi-api.onrender.com          │   │
│  │  SSL/HTTPS: ✅ Included (automatic)                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                         │                                            │
│                         │ PostgreSQL connection                      │
│                         │ (Internal network, encrypted)              │
│                         ▼                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │       Database: biblioicesi-db (PostgreSQL 15)              │   │
│  │  ┌───────────────────────────────────────────────────┐      │   │
│  │  │  Managed PostgreSQL Instance                     │      │   │
│  │  │  - Version: 15                                   │      │   │
│  │  │  - RAM: 256 MB (free tier)                       │      │   │
│  │  │  - Storage: 1 GB (free tier)                     │      │   │
│  │  │  - Backups: Manual only (free tier)              │      │   │
│  │  │  - Region: Oregon                                │      │   │
│  │  └───────────────────────────────────────────────────┘      │   │
│  │                                                              │   │
│  │  Internal connection: postgres://...                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               │ HTTPS
                               ▼
                    ┌──────────────────────┐
                    │      End Users       │
                    │   (Web, Mobile, API) │
                    └──────────────────────┘
```

---

## Flujo de Despliegue Completo

### 1. Developer Workflow

```
Developer → Git Commit → Git Push (main branch)
```

### 2. CI/CD Pipeline (GitHub Actions)

```
┌─────────────────┐
│   Trigger       │  Push to main branch
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Checkout      │  Clone repository code
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Setup Node 20   │  Install Node.js environment
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Install Deps    │  npm ci
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Run Linter    │  npm run lint
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Unit Tests     │  npm run test
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   E2E Tests     │  npm run test:e2e
└────────┬────────┘
         │
         ├─── ❌ Tests Failed → Stop (no deploy)
         │
         └─── ✅ Tests Passed
                  │
                  ▼
         ┌─────────────────┐
         │ Trigger Deploy  │  POST to Render Deploy Hook
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │   Notify        │  Show success/failure
         └─────────────────┘
```

### 3. Render Build Process

```
┌─────────────────┐
│ Receive Webhook │  GitHub Actions triggers deploy
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Clone Repo      │  Fetch latest code from main
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Read Blueprint  │  Parse render.yaml
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Build Docker    │  Execute Dockerfile
│                 │  Stage 1: Build (npm ci, npm run build)
│                 │  Stage 2: Production (copy dist + node_modules)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Push to Registry│  Store Docker image
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Deploy Image    │  Run container with env vars
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Health Check    │  GET / (must return 200)
└────────┬────────┘
         │
         ├─── ❌ Failed → Rollback to previous version
         │
         └─── ✅ Success → Update live service
                  │
                  ▼
         ┌─────────────────┐
         │  Service Live   │  https://biblioicesi-api.onrender.com
         └─────────────────┘
```

---

## Componentes de la Arquitectura

### 1. **GitHub Repository**

- **Función**: Control de versiones y código fuente
- **Archivos clave**:
  - `Dockerfile`: Define la imagen Docker
  - `render.yaml`: Blueprint de infraestructura
  - `.github/workflows/deploy.yml`: Pipeline CI/CD
  - `src/`: Código fuente NestJS

### 2. **GitHub Actions**

- **Función**: Automatización de CI/CD
- **Jobs**:
  - **Test Job**: Ejecuta linter y tests
  - **Deploy Job**: Trigger de despliegue si tests pasan
  - **Notify Job**: Muestra resultado
- **Secrets**:
  - `RENDER_DEPLOY_HOOK_URL`: URL del webhook de Render

### 3. **Render Web Service**

- **Función**: Hosting de la aplicación NestJS
- **Características**:
  - Runtime: Docker
  - Auto-scaling (según plan)
  - SSL/HTTPS automático
  - Health checks
  - Logs centralizados
  - Métricas básicas

### 4. **Render PostgreSQL**

- **Función**: Base de datos relacional gestionada
- **Características**:
  - PostgreSQL 15
  - Backups (en planes de pago)
  - Alta disponibilidad (en planes de pago)
  - Encriptación en tránsito
  - Conexión interna segura

### 5. **Docker Container**

- **Función**: Encapsulación de la aplicación
- **Beneficios**:
  - Consistencia entre entornos
  - Aislamiento de dependencias
  - Escalabilidad horizontal
  - Rollbacks rápidos

---

## Comunicación entre Servicios

### Web Service ↔ PostgreSQL

```
┌─────────────────┐              ┌─────────────────┐
│  NestJS App     │              │  PostgreSQL     │
│  (Port 3000)    │              │  (Port 5432)    │
└────────┬────────┘              └────────┬────────┘
         │                                 │
         │  Connection via TypeORM         │
         │  Protocol: PostgreSQL wire      │
         │  Encryption: SSL/TLS            │
         │  Network: Internal (private)    │
         │                                 │
         │  Environment variables:         │
         │  - DB_HOST                      │
         │  - DB_PORT                      │
         │  - DB_USERNAME                  │
         │  - DB_PASSWORD                  │
         │  - DB_DATABASE                  │
         └─────────────────────────────────┘
```

### GitHub Actions → Render

```
┌─────────────────┐              ┌─────────────────┐
│ GitHub Actions  │              │  Render API     │
└────────┬────────┘              └────────┬────────┘
         │                                 │
         │  POST request                   │
         │  URL: Deploy Hook               │
         │  Auth: Hook key in URL          │
         │  Payload: Optional metadata     │
         │  Response: 200 OK               │
         │                                 │
         └─────────────────────────────────┘
```

### Clients → Web Service

```
┌─────────────────┐              ┌─────────────────┐
│   End Users     │              │  NestJS API     │
│  (Browsers,     │              │  (Docker)       │
│   Mobile apps)  │              │                 │
└────────┬────────┘              └────────┬────────┘
         │                                 │
         │  HTTPS Requests                 │
         │  URL: biblioicesi-api.onrender.com
         │  Protocol: HTTPS (TLS 1.3)      │
         │  Auth: JWT Bearer token         │
         │  CORS: Configured               │
         │                                 │
         └─────────────────────────────────┘
```

---

## Seguridad

### Capas de Seguridad

1. **Transport Layer**:
   - ✅ HTTPS obligatorio (TLS 1.3)
   - ✅ SSL certificates automáticos (Let's Encrypt)

2. **Application Layer**:
   - ✅ JWT authentication
   - ✅ Role-based access control (RBAC)
   - ✅ Input validation (class-validator)
   - ✅ CORS configurado

3. **Database Layer**:
   - ✅ Conexión interna (no expuesta públicamente)
   - ✅ SSL/TLS en conexión
   - ✅ Credenciales en variables de entorno
   - ✅ No hardcoded passwords

4. **Container Layer**:
   - ✅ Usuario no-root
   - ✅ Imagen base oficial (node:20-alpine)
   - ✅ Multi-stage build (sin dev dependencies)

5. **CI/CD Layer**:
   - ✅ Tests obligatorios antes de deploy
   - ✅ Secrets en GitHub Secrets
   - ✅ Deploy hook con key única

---

## Escalabilidad

### Vertical Scaling (Upgrade de Plan)

```
Free → Starter → Standard → Pro → Enterprise

$0     $7        $25        $85     Custom
512MB  512MB     2GB        4GB     Custom RAM
```

### Horizontal Scaling (Multiple Instances)

Disponible en planes Standard y superiores:

```
┌─────────────────┐
│  Load Balancer  │  (Render automático)
└────────┬────────┘
         │
    ┌────┴────┬────────────┬──────────┐
    │         │            │          │
    ▼         ▼            ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ Inst 1 │ │ Inst 2 │ │ Inst 3 │ │ Inst N │
└────────┘ └────────┘ └────────┘ └────────┘
    │         │            │          │
    └────┬────┴────────────┴──────────┘
         │
         ▼
┌─────────────────┐
│  PostgreSQL     │  (Shared)
└─────────────────┘
```

---

## Monitoreo y Observabilidad

### Logs

```
Render Dashboard → Service → Logs
- Real-time streaming
- Search/filter capability
- Download option
```

### Métricas (Built-in)

```
Render Dashboard → Service → Metrics
- CPU usage
- Memory usage
- Request count
- Response time (p50, p95, p99)
- HTTP status codes
```

### Health Checks

```
Dockerfile:
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s
  CMD node -e "require('http').get('http://localhost:3000/', ...)"

Render checks: GET / every 30s
- Response 200 → Healthy
- Response != 200 or timeout → Unhealthy → Auto-restart
```

---

## Disaster Recovery

### Rollback Strategy

Si un deploy falla:

1. **Automatic**: Render mantiene la versión anterior activa
2. **Manual**: Puedes hacer rollback a cualquier deploy previo en el dashboard
3. **Git**: Revert del commit y push para re-deploy

### Database Backups

**Plan Free**: Solo backups manuales
**Planes de Pago**:
- Backups diarios automáticos
- Retención de 7 días (Starter)
- Point-in-time recovery (Pro+)

### Disaster Scenarios

| Scenario | Impact | Recovery |
|----------|--------|----------|
| Container crash | Auto-restart (30s) | Automatic |
| Failed deploy | Previous version stays | Automatic |
| Database corruption | Data loss risk | Restore from backup |
| Region outage | Service down | Wait or migrate |

---

## Costos Proyectados

### Año 1

```
Mes 1-3: $0/mes     (Free tier + DB trial)
Mes 4-12: $14/mes   (Starter plans)
Total Año 1: $126
```

### Año 2+ (Crecimiento)

```
Si necesitas escalar:
- Standard plan: $40/mes (web + DB)
- Pro plan: $110/mes (web + DB)
- Enterprise: Custom pricing
```

---

## Próximos Pasos

1. **Leer guía completa**: [`DEPLOYMENT.md`](./DEPLOYMENT.md)
2. **Aplicar Blueprint en Render**
3. **Configurar Deploy Hook**
4. **Probar despliegue**
5. **Monitorear logs y métricas**

---

**Arquitectura diseñada para**: Producción-ready, escalable, segura y con CI/CD automático. 🚀
