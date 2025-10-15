# 🚀 Quick Start - Despliegue en Render

## ⚡ Inicio Rápido (5 pasos)

### 1️⃣ Sube tu código a GitHub

```bash
git add .
git commit -m "feat: add Render deployment configuration"
git push origin main
```

### 2️⃣ Crea cuenta en Render

1. Ve a [render.com](https://render.com)
2. Regístrate con tu cuenta de GitHub
3. Autoriza acceso al repositorio

### 3️⃣ Crea servicios con Blueprint

1. Click en **"New +"** → **"Blueprint"**
2. Selecciona el repositorio `nestjs-carcas-deploy`
3. Render detectará `render.yaml` automáticamente
4. Click en **"Apply"**
5. Espera 5-10 minutos

### 4️⃣ Configura Deploy Hook

**En Render:**
1. Ve a `biblioicesi-api` → Settings → Deploy Hook
2. Copia la URL completa

**En GitHub:**
1. Settings → Secrets and variables → Actions
2. New repository secret
3. Name: `RENDER_DEPLOY_HOOK_URL`
4. Value: [pega la URL]
5. Add secret

### 5️⃣ ¡Despliega!

```bash
# Cualquier push a main desplegará automáticamente
git add .
git commit -m "test: trigger deploy"
git push origin main
```

O ejecuta manualmente desde GitHub → Actions → Deploy to Render → Run workflow

---

## 📚 Documentación Completa

| Documento | Descripción | Cuándo leerlo |
|-----------|-------------|---------------|
| [`DEPLOYMENT_SUMMARY.md`](./DEPLOYMENT_SUMMARY.md) | Resumen ejecutivo | ⭐ **Empieza aquí** |
| [`DEPLOYMENT.md`](./DEPLOYMENT.md) | Guía paso a paso detallada | Cuando despligues |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | Diagramas y arquitectura | Para entender el sistema |
| [`README.md`](./README.md) | Documentación de la API | Desarrollo local |

---

## 🛠️ Scripts Útiles

```bash
# Validar variables de entorno
./validate-env.sh

# Probar build de Docker localmente
./test-docker-build.sh

# Build de producción
npm run build

# Iniciar en modo producción
npm run start:prod

# Tests
npm test
npm run test:e2e
```

---

## ✅ Checklist de Despliegue

- [ ] Código subido a GitHub (rama `main`)
- [ ] Cuenta de Render creada
- [ ] Blueprint aplicado (servicios creados)
- [ ] Deploy Hook configurado en GitHub Secrets
- [ ] Push a `main` para desplegar
- [ ] Verificar en Render dashboard que está "Live"
- [ ] Probar URL: `https://biblioicesi-api.onrender.com`

---

## 🎯 URLs Importantes

Después del despliegue:

| Recurso | URL |
|---------|-----|
| API | `https://biblioicesi-api.onrender.com` |
| API Docs | `https://biblioicesi-api.onrender.com/api/docs` |
| Health | `https://biblioicesi-api.onrender.com/` |
| Render Dashboard | `https://dashboard.render.com` |
| GitHub Actions | `https://github.com/AIejoCastro/nestjs-carcas-deploy/actions` |

---

## 💰 Costos

- **Primeros 90 días**: Completamente GRATIS
- **Después de 90 días**: $14/mes (o gratis con limitaciones)

Ver detalles en [`DEPLOYMENT_SUMMARY.md`](./DEPLOYMENT_SUMMARY.md#-costos)

---

## 🆘 ¿Problemas?

1. Revisa la sección Troubleshooting en [`DEPLOYMENT.md`](./DEPLOYMENT.md#-troubleshooting)
2. Verifica logs en Render Dashboard → Service → Logs
3. Revisa GitHub Actions para ver si los tests pasaron

---

## 📦 Archivos Creados

```
nestjs-carcas-deploy/
├── 📄 Dockerfile                      (1.4 KB)
├── 📄 .dockerignore                   (625 B)
├── 📄 render.yaml                     (1.7 KB)
├── 📄 DEPLOYMENT.md                   (9.7 KB)
├── 📄 DEPLOYMENT_SUMMARY.md           (8.3 KB)
├── 📄 ARCHITECTURE.md                 (21 KB)
├── 📄 QUICK_START.md                  (este archivo)
├── 🔧 test-docker-build.sh            (2.6 KB)
├── 🔧 validate-env.sh                 (2.3 KB)
└── .github/workflows/
    └── 📄 deploy.yml                  (2.0 KB)

Total: ~50 KB de configuración para despliegue completo
```

---

## 🎉 ¡Eso es todo!

Tu aplicación está lista para desplegarse en producción con:
- ✅ Base de datos PostgreSQL incluida
- ✅ CI/CD automático con GitHub Actions
- ✅ HTTPS/SSL incluido
- ✅ Logs y métricas en tiempo real
- ✅ Health checks automáticos
- ✅ Rollbacks con un click

**Siguiente paso**: Lee [`DEPLOYMENT_SUMMARY.md`](./DEPLOYMENT_SUMMARY.md) y empieza el despliegue 🚀
