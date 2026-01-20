# 🧠 CiudadanoDigital_API

API REST para el proyecto Compañero Digital. Sistema de asistente digital para ciudadanía con autenticación segura, gestión de conversaciones, procesamiento de documentos e integración con IA.

## 📋 Tabla de Contenidos

- [Características Principales](#-características-principales)
- [Tecnologías](#-tecnologías)
- [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
- [Configuración del Entorno](#-configuración-del-entorno)
- [Ejecución del Servidor](#%EF%B8%8F-ejecución-del-servidor)
- [Modelos de Base de Datos](#-modelos-de-base-de-datos)
- [Seguridad y Autenticación](#-seguridad-y-autenticación)
- [Servicios Externos](#-servicios-externos)
- [Variables de Entorno](#-variables-de-entorno)
- [Despliegue](#-despliegue)
- [Logging](#-logging)
- [Testing](#-testing)
- [Contribución](#-contribución)

---

## ✨ Características Principales

- 🔐 **Autenticación JWT**: Sistema seguro con Access Tokens y Refresh Tokens
- 💬 **Chat Multi-conversación**: Gestión de múltiples chats por usuario con historial
- 🤖 **Integración con IA**: Respuestas automáticas basadas en contexto y documentos
- 📄 **Procesamiento de Documentos**: Upload, procesamiento asincrónico e indexación
- 📱 **Multi-dispositivo**: Soporte para múltiples sesiones simultáneas
- 🔄 **Recuperación de Contraseña**: Sistema de códigos por email
- 🪣 **Almacenamiento S3**: Gestión de archivos en AWS S3
- 📧 **Notificaciones Email**: Sistema de emails transaccionales
- 🐳 **Docker**: Contenedorización completa con Docker Compose

---

## 🧩 Tecnologías

### Backend
- **Node.js** (v18+) – Runtime de JavaScript
- **Express.js** (v5.1) – Framework web
- **PostgreSQL** – Base de datos relacional
- **Python** (v3.11+) – Servicios de procesamiento

### Autenticación y Seguridad
- **JWT** (jsonwebtoken) – Tokens de autenticación
- **bcryptjs** – Hash de contraseñas
- **Joi** – Validación de schemas

### Servicios Externos
- **AWS S3** – Almacenamiento de documentos
- **Pinecone** – Base de datos vectorial
- **OpenAI API** – Procesamiento de lenguaje y embeddings
- **Gmail SMTP** – Envío de emails

### DevOps
- **Docker & Docker Compose** – Contenedorización
- **Terraform** – Infraestructura como código
- **AWS EC2** – Hosting

---

## 🏗 Arquitectura del Proyecto

```
CiudadanoDigital_API/
├── apiServices/              # Servicios de API modulares
│   ├── auth/                 # Autenticación y autorización
│   │   ├── auth.route.js
│   │   ├── auth.controller.js
│   │   ├── auth.model.js
│   │   └── validationSchemas/
│   ├── user/                 # Gestión de usuarios
│   ├── chat/                 # Gestión de chats
│   ├── message/              # Gestión de mensajes
│   └── document/             # Gestión de documentos
├── middlewares/              # Middlewares de Express
│   ├── verifyAccessToken.middleware.js
│   ├── verifyRefreshAccess.middleware.js
│   ├── validateBody.js
│   └── upload.file.js
├── services/                 # Servicios de negocio
│   ├── email.service.js      # Envío de correos
│   ├── s3.service.js         # Integración con AWS S3
│   ├── processDocumentService/  # Procesamiento de documentos (Python)
│   └── questionsService/     # Generación de respuestas (Python)
├── db/                       # Base de datos
│   ├── connection.js
│   ├── tables.sql
│   └── queries.sql
├── config/                   # Configuración por ambiente
│   ├── default.cjs
│   ├── production.cjs
│   └── testing.cjs
├── utils/                    # Utilidades
│   ├── consts.js
│   ├── customError.js
│   └── logger.js
├── migrations/               # Migraciones de BD
├── terraform/                # Infraestructura IaC
├── bin/
│   └── www.js                # Punto de entrada
├── app.js                    # Configuración de Express
├── Dockerfile
├── docker-compose.yml
└── package.json
```

### Patrón de Estructura por Servicio

Cada módulo sigue el patrón MVC:

```
serviceName/
├── serviceName.route.js          # Definición de rutas
├── serviceName.controller.js     # Lógica de negocio
├── serviceName.model.js          # Interacción con BD
└── validationSchemas/            # Validación de entrada
    └── serviceName.*.schema.js
```

---

## 🚀 Configuración del Entorno

### 1. Requisitos Previos

- Node.js v18 o superior
- Python 3.11 o superior
- PostgreSQL 15 o superior
- npm o yarn

### 2. Clonar Repositorio

```bash
git clone https://github.com/erickguerra22/CiudadanoDigital_API
cd CiudadanoDigital_API
```

### 3. Instalar Dependencias de Node.js

```bash
npm install
```

### 4. Configurar Entorno Virtual de Python

**Linux / macOS:**
```bash
python3 -m venv ciudadano_digital
source ciudadano_digital/bin/activate
pip install -r requirements.txt
```

**Windows (PowerShell):**
```bash
python -m venv ciudadano_digital
.\ciudadano_digital\Scripts\activate
pip install -r requirements.txt
```

### 5. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
# Base de Datos
DATABASE_URL=postgresql://usuario:contraseña@localhost:5432/ciudadano_digital

# JWT
JWT_KEY=tu_clave_secreta_jwt_super_segura

# AWS S3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key
S3_BUCKET=nombre-del-bucket

# OpenAI
OPENAI_API_KEY=sk-...
OPENAI_EMBEDDINGS_MODEL=text-embedding-3-small
OPENAI_MODEL=gpt-4o-mini

# Pinecone
PINECONE_API_KEY=tu_pinecone_api_key
PINECONE_REGION=us-east-1
PINECONE_INDEX=ciudadano-digital

# Email (Gmail SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_APP_PASS=tu_contraseña_de_aplicacion

# Python
VENV_PYTHON=/ruta/absoluta/ciudadano_digital/bin/python

# Logs
ROUTE_LOG=/ruta/absoluta/logs
```

### 6. Inicializar la Base de Datos

Ejecuta el script de creación de tablas:

```bash
psql -U usuario -d ciudadano_digital -f db/tables.sql
```

---

## ⚙️ Ejecución del Servidor

### Modo Desarrollo

Con detección automática de cambios:

```bash
npm run dev
```

### Modo Producción

```bash
npm run start
```

### Con Docker

```bash
# Desarrollo
docker-compose up

# Producción
docker-compose -f docker-compose.prod.yml up -d
```

El servidor estará disponible en `http://localhost:3000`

---

## 💾 Modelos de Base de Datos

### Tabla: `usuario`

```sql
CREATE TABLE usuario (
    userId SERIAL PRIMARY KEY,
    email VARCHAR(254) UNIQUE NOT NULL,
    names VARCHAR(100) NOT NULL,
    lastnames VARCHAR(100) NOT NULL,
    birthdate DATE,
    phoneCode VARCHAR(10),
    phoneNumber VARCHAR(12),
    password VARCHAR(128) NOT NULL,
    role VARCHAR(100) DEFAULT 'user'
);
```

**Roles:**
- `user` - Usuario regular
- `admin` - Administrador con acceso a documentos

---

### Tabla: `chat`

```sql
CREATE TABLE chat (
    chatId SERIAL PRIMARY KEY,
    userId INT NOT NULL REFERENCES usuario(userId) ON DELETE CASCADE,
    fechaInicio TIMESTAMPTZ DEFAULT NOW(),
    nombre VARCHAR(100)
);
```

---

### Tabla: `mensaje`

```sql
CREATE TABLE mensaje (
    messageId SERIAL PRIMARY KEY,
    chatId INT REFERENCES chat(chatId) ON DELETE CASCADE,
    source VARCHAR(20) CHECK (source IN ('user', 'assistant')) NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    assigned BOOLEAN DEFAULT false,
    reference TEXT,
    responseTime BIGINT
);
```

**Campos:**
- `source`: Indica si el mensaje es del usuario o asistente
- `assigned`: Indica si el mensaje está asignado a un chat
- `reference`: Referencia al documento fuente de la respuesta
- `responseTime`: Tiempo de respuesta en milisegundos

---

### Tabla: `sesion`

```sql
CREATE TABLE sesion (
    refreshId UUID PRIMARY KEY,
    userId INT NOT NULL REFERENCES usuario(userId) ON DELETE CASCADE,
    deviceId VARCHAR(255) NOT NULL,
    refreshToken VARCHAR(255) NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT NOW(),
    expiresAt TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN DEFAULT false,
    revokedAt TIMESTAMP
);
```

**Funcionalidad:**
- Almacena refresh tokens hasheados
- Soporte multi-dispositivo
- Revocación de tokens

---

### Tabla: `codigorecuperacion`

```sql
CREATE TABLE codigorecuperacion (
    userId INT PRIMARY KEY REFERENCES usuario(userId) ON DELETE CASCADE,
    codeHash VARCHAR(255) NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT NOW(),
    expiresAt TIMESTAMPTZ NOT NULL
);
```

**Funcionalidad:**
- Códigos de 6 dígitos hasheados con bcrypt
- Válidos por 15 minutos
- Un código por usuario (se sobrescribe)

---

### Tabla: `categoria`

```sql
CREATE TABLE categoria (
    categoryId SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
);
```

**Categorías comunes:**
- Identificación
- Licencias
- Trámites
- Impuestos
- Salud
- Educación

---

### Tabla: `documento`

```sql
CREATE TABLE documento (
    documentId SERIAL PRIMARY KEY,
    userId INT NOT NULL REFERENCES usuario(userId),
    category INT REFERENCES categoria(categoryId),
    document_url TEXT NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(200),
    year INT
);
```

---

### Tabla: `resumenchat`

```sql
CREATE TABLE resumenchat (
    userId INT NOT NULL REFERENCES usuario(userId) ON DELETE CASCADE,
    chatId INT NOT NULL REFERENCES chat(chatId) ON DELETE CASCADE,
    content TEXT NOT NULL,
    PRIMARY KEY (userId, chatId)
);
```

**Funcionalidad:**
- Resumen del contexto de conversación
- Usado por IA para mantener coherencia
- Se actualiza con cada interacción

---

## 🔐 Seguridad y Autenticación

### Sistema de Tokens JWT

#### Access Token
- **Duración:** 1 hora
- **Uso:** Autenticación de requests a la API
- **Contenido:**
  ```json
  {
    "userId": 1,
    "deviceId": "abc123",
    "email": "usuario@ejemplo.com",
    "names": "Juan",
    "lastnames": "Pérez",
    "refreshId": "uuid-refresh-token",
    "role": "user",
    "iat": 1234567890,
    "exp": 1234571490
  }
  ```

#### Refresh Token
- **Duración:** 3 días
- **Uso:** Obtener nuevo Access Token
- **Formato:** UUID v4
- **Almacenamiento:** Hash SHA256 en base de datos
- **Web:** Cookie httpOnly
- **Mobile:** JSON response

#### Recovery Token
- **Duración:** 15 minutos
- **Uso:** Reestablecimiento de contraseña
- **Contenido:**
  ```json
  {
    "userId": 1,
    "email": "usuario@ejemplo.com",
    "purpose": "password_recovery"
  }
  ```

---

### Flujo de Autenticación

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB

    Client->>API: POST /auth/login (email, password, deviceId)
    API->>DB: Verificar credenciales
    DB-->>API: Usuario válido
    API->>API: Generar Access Token (1h)
    API->>API: Generar Refresh Token (UUID)
    API->>DB: Guardar Refresh Token (hash)
    API-->>Client: Access Token + Refresh Token

    Note over Client,API: Access Token expira después de 1 hora

    Client->>API: POST /auth/refresh (Refresh Token)
    API->>DB: Verificar Refresh Token
    DB-->>API: Token válido
    API->>API: Generar nuevo Access Token
    API->>API: Generar nuevo Refresh Token
    API->>DB: Actualizar Refresh Token
    API-->>Client: Nuevo Access Token + Refresh Token
```

---

### Seguridad de Contraseñas

- **Hash:** bcryptjs con salt de 10 rounds
- **Requisitos mínimos:** 8 caracteres (validación en backend)
- **Nunca** se devuelven contraseñas en responses
- **Recuperación:** Sistema de códigos por email (6 dígitos, 15 min)

---

### Middleware de Autenticación

#### `verifyAccessToken.middleware.js`
1. Extrae token del header `Authorization: Bearer <token>`
2. Verifica validez del JWT
3. Verifica que el refresh token asociado sea válido
4. Adjunta usuario a `req.user`
5. Permite continuar o rechaza con 401/403

#### `verifyRefreshAccess.middleware.js`
1. Extrae refresh token (cookie o body)
2. Verifica que exista en BD
3. Verifica que no esté revocado
4. Verifica que no haya expirado
5. Permite continuar o rechaza

---

### Autorización por Roles

```javascript
// Middleware de ejemplo para admin
const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      error: 'Acceso denegado. Se requiere rol de administrador.'
    });
  }
  next();
};
```

**Endpoints protegidos por rol admin:**
- `POST /api/document/`
- `GET /api/document/`
- `DELETE /api/document/:documentId`

---

## 🔌 Servicios Externos

### AWS S3

**Configuración:**
```javascript
{
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
}
```

**Operaciones:**
- `uploadFile(file, key)` - Subir archivo
- `getPresignedUrl(key)` - Generar URL presignada (1 hora)
- `deleteFile(key)` - Eliminar archivo

**Ubicación de archivos:**
```
s3://bucket-name/documents/[filename]
```

---

### Pinecone (Base de Datos Vectorial)

**Configuración:**
```python
{
  'api_key': os.getenv('PINECONE_API_KEY'),
  'region': os.getenv('PINECONE_REGION'),
  'index': os.getenv('PINECONE_INDEX')
}
```

**Operaciones:**
- Indexación de documentos con embeddings
- Búsqueda semántica por similitud
- Filtrado por metadata (categoría, edad)

**Metadata almacenada:**
```python
{
  'documentId': int,
  'title': str,
  'author': str,
  'year': int,
  'category': int,
  'minAge': int,
  'maxAge': int,
  'chunk': int
}
```

---

### OpenAI API

**Modelos utilizados:**
- **Embeddings:** `text-embedding-3-small`
- **Chat:** `gpt-4o-mini`

**Operaciones:**
1. Generación de embeddings para documentos
2. Búsqueda semántica en Pinecone
3. Generación de respuestas contextuales
4. Consideración de historial de chat
5. Respuestas apropiadas por edad

---

### Gmail SMTP

**Configuración:**
```javascript
{
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_APP_PASS  // Contraseña de aplicación
  }
}
```

**Tipos de emails:**
- Código de recuperación de contraseña
- Confirmación de registro
- Notificación de procesamiento de documentos
- Notificación de eliminación de documentos

---

## 🌍 Variables de Entorno

### Base de Datos

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `DATABASE_URL` | URL de conexión PostgreSQL | `postgresql://user:pass@localhost:5432/db` |

### JWT

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `JWT_KEY` | Clave secreta para firmar JWT | `super_secret_key_change_in_production` |

### AWS S3

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `AWS_REGION` | Región de AWS | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | Access Key de IAM | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de IAM | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `S3_BUCKET` | Nombre del bucket | `ciudadano-digital-docs` |

### OpenAI

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `OPENAI_API_KEY` | API Key de OpenAI | `sk-...` |
| `OPENAI_EMBEDDINGS_MODEL` | Modelo de embeddings | `text-embedding-3-small` |
| `OPENAI_MODEL` | Modelo de chat | `gpt-4o-mini` |

### Pinecone

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `PINECONE_API_KEY` | API Key de Pinecone | `abc123...` |
| `PINECONE_REGION` | Región de Pinecone | `us-east-1` |
| `PINECONE_INDEX` | Nombre del índice | `ciudadano-digital` |

### Email (SMTP)

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `SMTP_HOST` | Host SMTP | `smtp.gmail.com` |
| `SMTP_PORT` | Puerto SMTP | `587` |
| `SMTP_USER` | Email del remitente | `noreply@ejemplo.com` |
| `SMTP_APP_PASS` | Contraseña de aplicación | `abcd efgh ijkl mnop` |

### Python

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `VENV_PYTHON` | Ruta al Python del venv | `/path/to/venv/bin/python` |

### Logging

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `ROUTE_LOG` | Directorio de logs | `/var/log/ciudadano-digital` |

---

## 🚀 Despliegue

### Docker

El proyecto incluye configuración completa para Docker:

**Desarrollo:**
```bash
docker-compose up
```

**Producción:**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Terraform (AWS)

El proyecto incluye infraestructura como código para despliegue en AWS EC2:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Recursos creados:**
- EC2 instance
- Security groups
- S3 bucket
- RDS PostgreSQL (opcional)

### Manualmente en Servidor

1. **Instalar dependencias:**
   ```bash
   npm install --production
   pip install -r requirements.txt
   ```

2. **Configurar variables de entorno:**
   ```bash
   cp .env.example .env.prod
   # Editar .env.prod con valores de producción
   ```

3. **Inicializar base de datos:**
   ```bash
   psql -U usuario -d ciudadano_digital -f db/tables.sql
   ```

4. **Ejecutar migraciones (si existen):**
   ```bash
   # Ejecutar scripts en carpeta migrations/
   ```

5. **Iniciar servidor:**
   ```bash
   NODE_ENV=production npm start
   ```

### Recomendaciones de Producción

- ✅ Usar **HTTPS** con certificados SSL
- ✅ Configurar **nginx** como reverse proxy
- ✅ Usar **PM2** para gestión de procesos Node.js
- ✅ Configurar **logrotate** para logs
- ✅ Habilitar **rate limiting** para prevenir abuso
- ✅ Configurar **CORS** restrictivo (solo dominios permitidos)
- ✅ Usar **variables de entorno** desde secretos (AWS Secrets Manager, etc.)
- ✅ Habilitar **monitoreo** (CloudWatch, Datadog, etc.)
- ✅ Configurar **backups automáticos** de base de datos
- ✅ Implementar **health checks** (`/health` endpoint)

---

## 📝 Logging

El sistema incluye logger personalizado con las siguientes características:

- **Rotación automática** cuando el archivo excede 5MB
- **Organización por fecha:** `logs/YYYY-MM-DD/`
- **Niveles:** ERROR, WARN, INFO, DEBUG, SUCCESS
- **Detección automática** del archivo que generó el log
- **Formato:**
  ```
  [2026-01-12T10:30:45.123Z] [ERROR] [auth.controller.js] Login failed
  Detalles del error...
  ```

**Uso:**
```javascript
import Logger from './utils/logger.js';
const logger = new Logger();

logger.error('Login failed', error);
logger.info('User logged in', { userId: 1 });
logger.success('Document processed');
```

---

## 🧪 Testing

### Ejecutar Tests

```bash
# Tests unitarios
npm test

# Tests con coverage
npm run test:coverage

# Tests en modo watch
npm run test:watch
```

### Estructura de Tests

```
tests/
├── unit/
│   ├── auth.test.js
│   ├── user.test.js
│   └── chat.test.js
├── integration/
│   ├── api.test.js
│   └── database.test.js
└── helpers/
    └── testHelper.js
```

---

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto es privado y propiedad de la Universidad del Valle de Guatemala.

---

## 👥 Equipo de Desarrollo

- **Backend Lead:** [Nombre]
- **DevOps:** [Nombre]
- **IA/ML:** [Nombre]

---

## 📞 Soporte

Para reportar bugs o solicitar features, crear un issue en el repositorio.

---

## 📚 Recursos Adicionales

- [Documentación de Express.js](https://expressjs.com/)
- [Documentación de PostgreSQL](https://www.postgresql.org/docs/)
- [Documentación de OpenAI API](https://platform.openai.com/docs)
- [Documentación de Pinecone](https://docs.pinecone.io/)
- [Documentación de AWS S3](https://docs.aws.amazon.com/s3/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

## 🔄 Changelog

### v1.0.0 (2026-01-12)
- ✨ Sistema de autenticación JWT completo
- ✨ Gestión de chats y mensajes
- ✨ Integración con OpenAI y Pinecone
- ✨ Sistema de carga y procesamiento de documentos
- ✨ Recuperación de contraseña por email
- ✨ Soporte multi-dispositivo
- ✨ Dockerización completa
- ✨ Infraestructura Terraform para AWS

---

**Made with ❤️ by the Ciudadano Digital Team**
