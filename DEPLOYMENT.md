# 🚀 Guía de Despliegue en Render con CI/CD

Esta guía te llevará paso a paso para desplegar **BiblioIcesi NestJS API** en Render con PostgreSQL y GitHub Actions para CI/CD automático.

---

## 📋 Pre-requisitos

- [ ] Cuenta en [Render](https://render.com) (gratis)
- [ ] Repositorio en GitHub con este código
- [ ] Acceso de administrador al repositorio (para configurar secrets)

---

## 🗂️ Estructura de Archivos de Despliegue

Este proyecto ya incluye todos los archivos necesarios:

```
nestjs-carcas-deploy/
├── Dockerfile                    # Imagen Docker multi-stage optimizada
├── .dockerignore                 # Archivos excluidos del build
├── render.yaml                   # Blueprint de Render (IaC)
├── .github/workflows/deploy.yml  # Pipeline CI/CD de GitHub Actions
└── DEPLOYMENT.md                 # Esta guía
```

---

## 🎯 Parte 1: Configurar Render

### Paso 1: Crear cuenta y conectar GitHub

1. Ve a [render.com](https://render.com) y crea una cuenta (puedes usar GitHub OAuth)
2. En el dashboard, haz clic en **"New +"** → **"Blueprint"**
3. Selecciona **"Connect a repository"**
4. Autoriza a Render para acceder a tu repositorio de GitHub
5. Busca y selecciona el repositorio `nestjs-carcas-deploy`

### Paso 2: Configurar el Blueprint

Render detectará automáticamente el archivo `render.yaml` y creará:

- ✅ **Servicio Web**: `biblioicesi-api` (tu API NestJS)
- ✅ **Base de datos**: `biblioicesi-db` (PostgreSQL 15)

**Configuración que se aplicará automáticamente:**

| Servicio | Plan | Región | Configuración |
|----------|------|--------|---------------|
| API Web | Free | Oregon | Docker, puerto 3000 |
| PostgreSQL | Free | Oregon | 256 MB RAM, 1 GB storage |

> ⚠️ **Importante**: El plan free de la base de datos expira después de 90 días. Necesitarás hacer upgrade a un plan de pago.

### Paso 3: Revisar y aplicar Blueprint

1. Render mostrará un resumen de los servicios a crear
2. Revisa que todo esté correcto
3. Haz clic en **"Apply"**
4. Espera 5-10 minutos mientras Render:
   - Crea la base de datos PostgreSQL
   - Construye la imagen Docker
   - Despliega tu aplicación
   - Conecta automáticamente la API con la base de datos

### Paso 4: Configurar JWT_SECRET (Manual)

El `JWT_SECRET` se genera automáticamente, pero puedes verificarlo:

1. Ve a tu servicio `biblioicesi-api` en el dashboard
2. Click en **"Environment"** en el menú lateral
3. Verifica que `JWT_SECRET` tenga un valor
4. Si está vacío, agrega uno manualmente (genera uno seguro):

```bash
# Genera un secreto seguro en tu terminal:
openssl rand -base64 32
```

---

## 🔄 Parte 2: Configurar CI/CD con GitHub Actions

### Paso 1: Obtener Deploy Hook de Render

1. En tu servicio `biblioicesi-api` en Render
2. Ve a **"Settings"** en el menú lateral
3. Busca la sección **"Deploy Hook"**
4. Copia la URL completa (algo como: `https://api.render.com/deploy/srv-xxxxxxxxxxxxx?key=yyyyyyyyyyy`)

### Paso 2: Configurar Secret en GitHub

1. Ve a tu repositorio en GitHub
2. Click en **"Settings"** → **"Secrets and variables"** → **"Actions"**
3. Click en **"New repository secret"**
4. Configura:
   - **Name**: `RENDER_DEPLOY_HOOK_URL`
   - **Value**: Pega la URL del Deploy Hook que copiaste
5. Click en **"Add secret"**

### Paso 3: Verificar el Workflow

El workflow ya está configurado en `.github/workflows/deploy.yml` y se ejecutará automáticamente cuando:

- ✅ Hagas `push` a la rama `main`
- ✅ Lo ejecutes manualmente desde GitHub (pestaña "Actions")

**¿Qué hace el pipeline?**

1. **Test Job**:
   - Instala dependencias
   - Ejecuta linter (`npm run lint`)
   - Ejecuta tests unitarios (`npm run test`)
   - Ejecuta tests e2e (`npm run test:e2e`)

2. **Deploy Job** (solo si los tests pasan):
   - Trigger de despliegue en Render vía Deploy Hook
   - Notifica el resultado

3. **Notify Job**:
   - Muestra mensaje de éxito o fallo

---

## 🧪 Parte 3: Probar el Despliegue

### Opción A: Trigger automático

1. Haz un cambio en tu código (ej: actualiza el README)
2. Commit y push a `main`:

```bash
git add .
git commit -m "test: trigger deploy"
git push origin main
```

3. Ve a GitHub → pestaña **"Actions"**
4. Verás el workflow ejecutándose en tiempo real
5. Una vez completado, ve al dashboard de Render para ver el despliegue

### Opción B: Trigger manual

1. Ve a GitHub → pestaña **"Actions"**
2. Click en **"Deploy to Render"** en el menú lateral
3. Click en **"Run workflow"** → selecciona `main` → **"Run workflow"**

### Verificar que funciona

Una vez desplegado, Render te dará una URL pública como:

```
https://biblioicesi-api.onrender.com
```

Prueba los endpoints:

```bash
# Health check
curl https://biblioicesi-api.onrender.com/

# Swagger docs (si está habilitado)
open https://biblioicesi-api.onrender.com/api
```

---

## 📊 Monitoreo y Logs

### Ver logs en tiempo real

1. En el dashboard de Render
2. Click en tu servicio `biblioicesi-api`
3. Ve a la pestaña **"Logs"**
4. Verás logs en tiempo real de tu aplicación

### Métricas

Render ofrece métricas básicas gratis:
- CPU usage
- Memory usage
- Response time
- Request count

---

## 🔧 Configuración Avanzada

### Variables de Entorno Adicionales

Si necesitas agregar más variables:

1. Ve a `biblioicesi-api` → **"Environment"**
2. Click en **"Add Environment Variable"**
3. Ejemplos útiles:

```env
# Rate limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=10

# CORS
CORS_ORIGIN=https://tu-frontend.com

# Logging
LOG_LEVEL=info
```

### Actualizar DB_SYNCHRONIZE en Producción

⚠️ **IMPORTANTE**: El archivo `render.yaml` establece `DB_SYNCHRONIZE=false` por seguridad.

En producción deberías usar **migraciones** en lugar de `synchronize`:

```bash
# Crear una migración
npm run typeorm migration:create src/migrations/InitialSchema

# Generar migración desde entities
npm run typeorm migration:generate src/migrations/InitialSchema -d src/config/database.config.ts

# Ejecutar migraciones
npm run typeorm migration:run -d src/config/database.config.ts
```

Si necesitas `synchronize=true` temporalmente (solo para desarrollo):

1. Ve a `biblioicesi-api` → **"Environment"**
2. Cambia `DB_SYNCHRONIZE` a `true`
3. Guarda y redespliega

### Custom Domain

Para usar tu propio dominio:

1. Ve a `biblioicesi-api` → **"Settings"**
2. Busca **"Custom Domain"**
3. Sigue las instrucciones para agregar registros DNS

---

## 🐛 Troubleshooting

### Error: "Application failed to start"

**Causa**: La base de datos no está lista o las variables de entorno son incorrectas.

**Solución**:
1. Verifica en Render que `biblioicesi-db` esté en estado "Available"
2. Revisa los logs del servicio web
3. Verifica que todas las variables `DB_*` estén correctamente conectadas

### Error: "Deployment timed out"

**Causa**: El build de Docker está tardando demasiado (límite 15 min en plan free).

**Solución**:
1. El Dockerfile ya está optimizado con multi-stage builds
2. Si persiste, considera usar una imagen base más liviana o pre-compilar assets

### Error: "Tests failing in GitHub Actions"

**Causa**: Los tests usan configuración diferente en CI.

**Solución**:
1. Verifica que `NODE_ENV=test` esté configurado en el workflow
2. Los tests usan SQLite in-memory automáticamente (ver `database.config.ts`)
3. Revisa logs en GitHub Actions para más detalles

### Base de datos se desconecta

**Causa**: Plan free de Render pone servicios en "sleep" después de 15 min de inactividad.

**Solución**:
- Upgrade a un plan de pago (desde $7/mes para el servicio web)
- O usa un servicio externo como [Railway](https://railway.app) o [Supabase](https://supabase.com) para PostgreSQL

---

## 💰 Costos

### Plan Free (Actual)

| Recurso | Límite | Costo |
|---------|--------|-------|
| Servicio Web | 750 horas/mes | $0 |
| PostgreSQL | 90 días trial | $0 |
| Build minutes | Ilimitado | $0 |
| **Total** | | **$0/mes** |

**Limitaciones**:
- Servicios entran en "sleep" después de 15 min sin actividad
- Base de datos expira después de 90 días
- 512 MB RAM para web service

### Upgrade Recomendado (Producción)

| Recurso | Plan | Costo |
|---------|------|-------|
| Servicio Web | Starter | $7/mes |
| PostgreSQL | Starter | $7/mes |
| **Total** | | **$14/mes** |

**Beneficios**:
- Sin "sleep" automático
- 512 MB RAM para web
- 1 GB RAM para DB
- Backups automáticos
- SSL incluido

---

## 📚 Recursos Adicionales

- [Render Documentation](https://render.com/docs)
- [Render Blueprint Spec](https://render.com/docs/blueprint-spec)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [NestJS Deployment Guide](https://docs.nestjs.com/recipes/deployment)

---

## ✅ Checklist Final

Antes de considerar el despliegue completado, verifica:

- [ ] Servicio web desplegado y respondiendo en la URL de Render
- [ ] Base de datos PostgreSQL creada y conectada
- [ ] Variables de entorno configuradas correctamente
- [ ] JWT_SECRET generado y seguro
- [ ] Deploy Hook configurado en GitHub Secrets
- [ ] GitHub Actions ejecutándose correctamente
- [ ] Tests pasando en CI/CD
- [ ] Logs accesibles y sin errores críticos
- [ ] Endpoints principales funcionando (prueba con Postman)
- [ ] Documentación actualizada con URL de producción

---

## 🎉 ¡Felicidades!

Tu aplicación NestJS con PostgreSQL está desplegada en Render con CI/CD automático. Cada vez que hagas push a `main`, GitHub Actions ejecutará los tests y desplegará automáticamente si todo está bien.

**Próximos pasos sugeridos:**

1. Configura un dominio personalizado
2. Implementa migraciones de base de datos
3. Agrega monitoreo con Sentry o LogRocket
4. Configura backups automáticos de la base de datos
5. Upgrade a planes de pago antes de que expire la trial de PostgreSQL

---

**¿Necesitas ayuda?** Abre un issue en el repositorio o consulta la documentación oficial de Render.
