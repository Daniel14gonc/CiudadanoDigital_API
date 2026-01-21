# API Flow para Aplicación Web - Ciudadano Digital

Este documento describe el flujo de llamadas al API para implementar las funcionalidades de Ciudadano Digital en una aplicación web, extrapolado del uso en la aplicación Android.

## Configuración Base

### URL Base
```
https://api.ciudadanodigital.com/api/
```

### Headers Estándar (todas las peticiones)
```javascript
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "Accept-Language": "es-ES,es;q=0.9"
}
```

### Header de Autenticación (peticiones autenticadas)
```javascript
{
  "Authorization": "Bearer <JWT_TOKEN>"
}
```

---

## 1. Flujo de Autenticación

### 1.1 Registro de Usuario

**Secuencia de llamadas:**

```
1. POST /api/user (crear cuenta)
   ↓
2. GET /api/user/logged (obtener datos del usuario)
```

**Paso 1: Crear cuenta**

```http
POST /api/user
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "names": "Juan Carlos",
  "lastnames": "Pérez López",
  "phoneCode": "+502",
  "phoneNumber": "12345678",
  "password": "contraseñaSegura123",
  "birthdate": "1990-05-15",
  "deviceId": "web-browser-unique-id"
}
```

**Respuesta exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": 1735689600,
  "refreshToken": "eyJhbGciOiJIUzI1Ni...",
  "refreshExpiresAt": 1738281600
}
```

**Paso 2: Obtener datos del usuario**

```http
GET /api/user/logged
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "userid": 123,
  "email": "usuario@ejemplo.com",
  "names": "Juan Carlos",
  "lastnames": "Pérez López",
  "birthdate": "1990-05-15",
  "phonecode": "+502",
  "phonenumber": "12345678",
  "role": "user"
}
```

**Implementación Web:**
```javascript
async function registrarUsuario(datos) {
  // Generar deviceId único para web
  const deviceId = localStorage.getItem('deviceId') || crypto.randomUUID();
  localStorage.setItem('deviceId', deviceId);

  // 1. Crear cuenta
  const authResponse = await fetch('/api/user', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...datos, deviceId })
  });

  if (!authResponse.ok) {
    const error = await authResponse.json();
    throw new Error(error.error);
  }

  const auth = await authResponse.json();

  // Guardar tokens
  localStorage.setItem('token', auth.token);
  localStorage.setItem('refreshToken', auth.refreshToken);
  localStorage.setItem('tokenExpires', auth.expiresAt);

  // 2. Obtener datos del usuario
  const userResponse = await fetch('/api/user/logged', {
    headers: { 'Authorization': `Bearer ${auth.token}` }
  });

  const user = await userResponse.json();
  localStorage.setItem('user', JSON.stringify(user));

  return { auth, user };
}
```

---

### 1.2 Inicio de Sesión

**Secuencia de llamadas:**

```
1. POST /api/auth/login
   ↓
2. GET /api/user/logged
```

**Paso 1: Login**

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "password": "contraseñaSegura123",
  "deviceId": "web-browser-unique-id"
}
```

**Respuesta exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": 1735689600,
  "refreshToken": "eyJhbGciOiJIUzI1Ni...",
  "refreshExpiresAt": 1738281600
}
```

**Errores comunes:**
| Código | Significado |
|--------|-------------|
| 401 | Credenciales inválidas |
| 400 | Parámetros faltantes |

**Implementación Web:**
```javascript
async function iniciarSesion(email, password) {
  const deviceId = localStorage.getItem('deviceId') || crypto.randomUUID();
  localStorage.setItem('deviceId', deviceId);

  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, deviceId })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error);
  }

  const auth = await response.json();
  guardarTokens(auth);

  // Obtener datos del usuario
  const user = await obtenerUsuarioActual(auth.token);
  return { auth, user };
}
```

---

### 1.3 Refresh Token

**Llamar antes de cada petición autenticada si el token está expirado:**

```http
POST /api/auth/refresh
Authorization: Bearer <TOKEN_ACTUAL>
Content-Type: application/json

{
  "refreshToken": "<REFRESH_TOKEN>"
}
```

**Respuesta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": 1735689600,
  "refreshToken": "eyJhbGciOiJIUzI1Ni...",
  "refreshExpiresAt": 1738281600
}
```

**Implementación Web (Interceptor):**
```javascript
async function fetchConAuth(url, options = {}) {
  // Verificar si el token está expirado
  const tokenExpires = parseInt(localStorage.getItem('tokenExpires'));
  const ahora = Math.floor(Date.now() / 1000);

  if (tokenExpires && ahora >= tokenExpires) {
    // Refrescar token
    const refreshToken = localStorage.getItem('refreshToken');
    const token = localStorage.getItem('token');

    const refreshResponse = await fetch('/api/auth/refresh', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ refreshToken })
    });

    if (refreshResponse.ok) {
      const newAuth = await refreshResponse.json();
      guardarTokens(newAuth);
    } else {
      // Token inválido - cerrar sesión
      cerrarSesion();
      throw new Error('Sesión expirada');
    }
  }

  // Realizar petición con token actualizado
  const token = localStorage.getItem('token');
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
}
```

---

### 1.4 Cerrar Sesión

```http
POST /api/auth/logout
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "refreshToken": "<REFRESH_TOKEN>"
}
```

**Implementación Web:**
```javascript
async function cerrarSesion() {
  try {
    await fetchConAuth('/api/auth/logout', {
      method: 'POST',
      body: JSON.stringify({
        refreshToken: localStorage.getItem('refreshToken')
      })
    });
  } finally {
    // Limpiar almacenamiento local
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('tokenExpires');
    localStorage.removeItem('user');
    // Redirigir a login
    window.location.href = '/login';
  }
}
```

---

## 2. Flujo de Recuperación de Contraseña

**Secuencia completa:**

```
1. POST /api/auth/sendRecovery (enviar código)
   ↓
2. POST /api/auth/verifyCode (verificar código)
   ↓
3. POST /api/auth/recoverPassword (establecer nueva contraseña)
```

### 2.1 Solicitar Código de Recuperación

```http
POST /api/auth/sendRecovery
Content-Type: application/json

{
  "email": "usuario@ejemplo.com"
}
```

**Respuesta:**
```json
{
  "message": "Código de recuperación enviado"
}
```

### 2.2 Verificar Código

```http
POST /api/auth/verifyCode
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "code": 123456
}
```

**Respuesta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": 1735689600,
  "message": "Código verificado"
}
```

> **Nota:** El token retornado es temporal y solo sirve para restablecer la contraseña.

### 2.3 Establecer Nueva Contraseña

```http
POST /api/auth/recoverPassword
Authorization: Bearer <RECOVERY_TOKEN>
Content-Type: application/json

{
  "password": "nuevaContraseñaSegura456"
}
```

**Implementación Web Completa:**
```javascript
class RecuperacionPassword {
  constructor() {
    this.email = null;
    this.recoveryToken = null;
  }

  async solicitarCodigo(email) {
    this.email = email;
    const response = await fetch('/api/auth/sendRecovery', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email })
    });

    if (!response.ok) throw new Error('Error al enviar código');
    return await response.json();
  }

  async verificarCodigo(codigo) {
    const response = await fetch('/api/auth/verifyCode', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: this.email, code: parseInt(codigo) })
    });

    if (!response.ok) throw new Error('Código inválido');

    const data = await response.json();
    this.recoveryToken = data.token;
    return data;
  }

  async establecerNuevaPassword(password) {
    const response = await fetch('/api/auth/recoverPassword', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.recoveryToken}`
      },
      body: JSON.stringify({ password })
    });

    if (!response.ok) throw new Error('Error al cambiar contraseña');
    return await response.json();
  }
}
```

---

## 3. Flujo de Chat con Asistente IA

### 3.1 Crear Nuevo Chat

```http
POST /api/chat
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "name": "Mi consulta sobre educación"
}
```

**Respuesta:**
```json
{
  "message": "Chat creado",
  "chat": {
    "chatid": 1,
    "userid": 123,
    "fechainicio": "2024-01-15T10:30:00Z",
    "nombre": "Mi consulta sobre educación"
  }
}
```

### 3.2 Listar Chats del Usuario

```http
GET /api/chat
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "chats": [
    {
      "chatid": 1,
      "userid": 123,
      "fechainicio": "2024-01-15T10:30:00Z",
      "nombre": "Mi consulta sobre educación"
    },
    {
      "chatid": 2,
      "userid": 123,
      "fechainicio": "2024-01-14T15:45:00Z",
      "nombre": "Preguntas sobre trámites"
    }
  ]
}
```

### 3.3 Obtener Mensajes de un Chat

```http
GET /api/message/{chatId}
Authorization: Bearer <TOKEN>
```

**Parámetros Query opcionales:**
- `limit`: Número de mensajes
- `offset`: Paginación

**Respuesta:**
```json
{
  "messages": [
    {
      "messageid": 1,
      "chatid": 1,
      "source": "user",
      "content": "¿Cómo puedo inscribir a mi hijo en la escuela?",
      "reference": null,
      "timestamp": "2024-01-15T10:31:00Z",
      "assigned": true,
      "responsetime": null
    },
    {
      "messageid": 2,
      "chatid": 1,
      "source": "assistant",
      "content": "Para inscribir a su hijo...",
      "reference": "Ley de Educación Art. 45",
      "timestamp": "2024-01-15T10:31:05Z",
      "assigned": true,
      "responsetime": 5000
    }
  ]
}
```

### 3.4 Flujo de Envío de Mensaje y Respuesta IA

**Opción A: Mensaje en chat existente**

```
1. GET /api/message/response/{chatId}?question=<pregunta>
   (Esto envía la pregunta del usuario Y obtiene la respuesta de la IA en una sola llamada)
```

```http
GET /api/message/response/1?question=¿Cuáles%20son%20los%20requisitos?
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "message": "Respuesta generada",
  "newChat": false,
  "chatMessage": {
    "messageid": 3,
    "chatid": 1,
    "source": "assistant",
    "content": "Los requisitos son...",
    "reference": "Reglamento de Inscripciones",
    "timestamp": "2024-01-15T10:35:00Z",
    "assigned": true,
    "responsetime": 3500
  }
}
```

**Opción B: Mensaje sin chat asignado (nuevo usuario o primera pregunta)**

```
1. GET /api/message/response?question=<pregunta>
   ↓
2. (Opcional) PUT /api/message/{messageId}/{chatId} para asignar a chat
```

```http
GET /api/message/response?question=¿Cómo%20funciona%20esto?
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "message": "Respuesta generada",
  "newChat": true,
  "chatMessage": {
    "messageid": 10,
    "chatid": null,
    "source": "assistant",
    "content": "Bienvenido, este sistema...",
    "reference": null,
    "timestamp": "2024-01-15T11:00:00Z",
    "assigned": false,
    "responsetime": 2500
  }
}
```

### 3.5 Asignar Mensaje a Chat

Si el mensaje no está asignado (`assigned: false`), se puede asignar:

```http
PUT /api/message/{messageId}/{chatId}
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "messageid": 10,
  "chatid": 1,
  "source": "assistant",
  "content": "Bienvenido, este sistema...",
  "reference": null,
  "timestamp": "2024-01-15T11:00:00Z",
  "assigned": true,
  "responsetime": 2500
}
```

**Implementación Web del Chat:**
```javascript
class ChatService {
  async crearChat(nombre) {
    const response = await fetchConAuth('/api/chat', {
      method: 'POST',
      body: JSON.stringify({ name: nombre })
    });
    return (await response.json()).chat;
  }

  async listarChats() {
    const response = await fetchConAuth('/api/chat');
    return (await response.json()).chats;
  }

  async obtenerMensajes(chatId, limit = 50, offset = 0) {
    const response = await fetchConAuth(
      `/api/message/${chatId}?limit=${limit}&offset=${offset}`
    );
    return (await response.json()).messages;
  }

  async enviarPregunta(pregunta, chatId = null) {
    const url = chatId
      ? `/api/message/response/${chatId}?question=${encodeURIComponent(pregunta)}`
      : `/api/message/response?question=${encodeURIComponent(pregunta)}`;

    const response = await fetchConAuth(url);
    return await response.json();
  }

  async asignarMensajeAChat(messageId, chatId) {
    const response = await fetchConAuth(`/api/message/${messageId}/${chatId}`, {
      method: 'PUT'
    });
    return await response.json();
  }
}
```

---

## 4. Flujo de Gestión de Documentos

### 4.1 Listar Documentos

```http
GET /api/document
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "message": "Documentos obtenidos",
  "documents": [
    {
      "documentid": 1,
      "userid": 123,
      "category": 1,
      "title": "Guía de inscripción.pdf",
      "author": "Ministerio de Educación",
      "year": 2024,
      "presignedUrl": "https://storage.example.com/doc1.pdf?token=..."
    }
  ]
}
```

### 4.2 Subir Documento (Solo Administradores)

```http
POST /api/document
Authorization: Bearer <TOKEN>
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="filename"

mi_documento.pdf
--boundary
Content-Disposition: form-data; name="author"

Autor del Documento
--boundary
Content-Disposition: form-data; name="year"

2024
--boundary
Content-Disposition: form-data; name="minAge"

13
--boundary
Content-Disposition: form-data; name="maxAge"

65
--boundary
Content-Disposition: form-data; name="file"; filename="mi_documento.pdf"
Content-Type: application/pdf

<contenido binario del archivo>
--boundary--
```

**Implementación Web:**
```javascript
async function subirDocumento(file, metadata) {
  const formData = new FormData();
  formData.append('filename', metadata.filename);
  formData.append('author', metadata.author);
  formData.append('year', metadata.year.toString());
  formData.append('minAge', metadata.minAge.toString());
  formData.append('maxAge', metadata.maxAge.toString());
  formData.append('file', file);

  const token = localStorage.getItem('token');
  const response = await fetch('/api/document', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
      // NO incluir Content-Type, el navegador lo agrega automáticamente con boundary
    },
    body: formData
  });

  if (!response.ok) throw new Error('Error al subir documento');
  return await response.json();
}
```

### 4.3 Eliminar Documento

```http
DELETE /api/document/{documentId}
Authorization: Bearer <TOKEN>
```

**Respuesta:**
```json
{
  "message": "Documento eliminado"
}
```

---

## 5. Flujo de Actualización de Perfil

```http
PUT /api/user/{userId}
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "names": "Juan Carlos",
  "lastnames": "Pérez García",
  "phoneCode": "+502",
  "phoneNumber": "87654321"
}
```

> **Nota:** Solo enviar los campos que se desean actualizar.

**Respuesta:**
```json
{
  "userid": 123,
  "email": "usuario@ejemplo.com",
  "names": "Juan Carlos",
  "lastnames": "Pérez García",
  "birthdate": "1990-05-15",
  "phonecode": "+502",
  "phonenumber": "87654321",
  "role": "user"
}
```

---

## 6. Manejo de Errores

### Estructura de Error

```json
{
  "error": "Descripción del error",
  "code": 400
}
```

### Códigos HTTP Comunes

| Código | Significado | Acción Recomendada |
|--------|-------------|-------------------|
| 400 | Parámetros inválidos | Validar datos del formulario |
| 401 | No autorizado | Intentar refresh token o redirigir a login |
| 403 | Prohibido | Token expirado, cerrar sesión |
| 404 | No encontrado | Recurso no existe |
| 409 | Conflicto | Email ya registrado |
| 422 | Validación fallida | Mostrar errores de validación |
| 500 | Error del servidor | Mostrar mensaje genérico, reintentar |

### Implementación de Manejo de Errores:

```javascript
async function manejarRespuesta(response) {
  if (response.ok) {
    return await response.json();
  }

  const error = await response.json();

  switch (response.status) {
    case 401:
    case 403:
      // Intentar refrescar token
      const refreshed = await intentarRefreshToken();
      if (!refreshed) {
        cerrarSesion();
        throw new Error('Sesión expirada. Por favor, inicie sesión nuevamente.');
      }
      break;
    case 409:
      throw new Error('El correo electrónico ya está registrado.');
    case 422:
      throw new Error('Por favor, verifique los datos ingresados.');
    default:
      throw new Error(error.error || 'Ha ocurrido un error. Intente nuevamente.');
  }
}
```

---

## 7. Resumen de Endpoints

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| POST | `/api/auth/login` | Iniciar sesión | No |
| POST | `/api/auth/refresh` | Refrescar token | Sí |
| POST | `/api/auth/logout` | Cerrar sesión | Sí |
| POST | `/api/auth/sendRecovery` | Solicitar recuperación | No |
| POST | `/api/auth/verifyCode` | Verificar código | No |
| POST | `/api/auth/recoverPassword` | Restablecer contraseña | Sí (recovery) |
| GET | `/api/user/logged` | Obtener usuario actual | Sí |
| POST | `/api/user` | Registrar usuario | No |
| PUT | `/api/user/{userId}` | Actualizar perfil | Sí |
| POST | `/api/chat` | Crear chat | Sí |
| GET | `/api/chat` | Listar chats | Sí |
| GET | `/api/message/{chatId}` | Obtener mensajes | Sí |
| POST | `/api/message/{chatId}` | Enviar mensaje | Sí |
| POST | `/api/message` | Enviar mensaje (sin chat) | Sí |
| PUT | `/api/message/{msgId}/{chatId}` | Asignar mensaje | Sí |
| GET | `/api/message/response/{chatId}` | Obtener respuesta IA | Sí |
| GET | `/api/message/response` | Obtener respuesta IA (nuevo) | Sí |
| GET | `/api/document` | Listar documentos | Sí |
| POST | `/api/document` | Subir documento | Sí (admin) |
| DELETE | `/api/document/{docId}` | Eliminar documento | Sí (admin) |

---

## 8. Ejemplo de Implementación Completa (Clase API)

```javascript
class CiudadanoDigitalAPI {
  constructor(baseUrl = '/api') {
    this.baseUrl = baseUrl;
  }

  // === Utilidades ===

  async request(endpoint, options = {}) {
    await this.refreshTokenSiNecesario();

    const url = `${this.baseUrl}${endpoint}`;
    const token = localStorage.getItem('token');

    const config = {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
        ...(token && { 'Authorization': `Bearer ${token}` })
      }
    };

    if (options.body && typeof options.body === 'object' && !(options.body instanceof FormData)) {
      config.body = JSON.stringify(options.body);
    }

    const response = await fetch(url, config);
    return this.manejarRespuesta(response);
  }

  async refreshTokenSiNecesario() {
    const expires = parseInt(localStorage.getItem('tokenExpires'));
    const ahora = Math.floor(Date.now() / 1000);

    if (expires && ahora >= expires - 60) { // Refrescar 1 minuto antes
      const refreshToken = localStorage.getItem('refreshToken');
      const token = localStorage.getItem('token');

      const response = await fetch(`${this.baseUrl}/auth/refresh`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ refreshToken })
      });

      if (response.ok) {
        const auth = await response.json();
        this.guardarTokens(auth);
      } else {
        this.cerrarSesion();
        throw new Error('Sesión expirada');
      }
    }
  }

  guardarTokens(auth) {
    localStorage.setItem('token', auth.token);
    localStorage.setItem('refreshToken', auth.refreshToken);
    localStorage.setItem('tokenExpires', auth.expiresAt);
  }

  cerrarSesion() {
    localStorage.clear();
    window.location.href = '/login';
  }

  async manejarRespuesta(response) {
    if (response.ok) return response.json();

    const error = await response.json().catch(() => ({ error: 'Error desconocido' }));

    if (response.status === 401 || response.status === 403) {
      this.cerrarSesion();
    }

    throw new Error(error.error || `Error ${response.status}`);
  }

  // === Auth ===

  async login(email, password) {
    const deviceId = localStorage.getItem('deviceId') || crypto.randomUUID();
    localStorage.setItem('deviceId', deviceId);

    const response = await fetch(`${this.baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, deviceId })
    });

    const auth = await this.manejarRespuesta(response);
    this.guardarTokens(auth);

    const user = await this.getUsuarioActual();
    return { auth, user };
  }

  async registro(datos) {
    const deviceId = localStorage.getItem('deviceId') || crypto.randomUUID();
    localStorage.setItem('deviceId', deviceId);

    const response = await fetch(`${this.baseUrl}/user`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...datos, deviceId })
    });

    const auth = await this.manejarRespuesta(response);
    this.guardarTokens(auth);

    const user = await this.getUsuarioActual();
    return { auth, user };
  }

  async logout() {
    try {
      await this.request('/auth/logout', {
        method: 'POST',
        body: { refreshToken: localStorage.getItem('refreshToken') }
      });
    } finally {
      this.cerrarSesion();
    }
  }

  // === Password Recovery ===

  async enviarCodigoRecuperacion(email) {
    return fetch(`${this.baseUrl}/auth/sendRecovery`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email })
    }).then(this.manejarRespuesta.bind(this));
  }

  async verificarCodigo(email, code) {
    const response = await fetch(`${this.baseUrl}/auth/verifyCode`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, code: parseInt(code) })
    });
    return this.manejarRespuesta(response);
  }

  async restablecerPassword(recoveryToken, password) {
    const response = await fetch(`${this.baseUrl}/auth/recoverPassword`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${recoveryToken}`
      },
      body: JSON.stringify({ password })
    });
    return this.manejarRespuesta(response);
  }

  // === User ===

  async getUsuarioActual() {
    return this.request('/user/logged');
  }

  async actualizarPerfil(userId, datos) {
    return this.request(`/user/${userId}`, {
      method: 'PUT',
      body: datos
    });
  }

  // === Chat ===

  async crearChat(nombre) {
    const result = await this.request('/chat', {
      method: 'POST',
      body: { name: nombre }
    });
    return result.chat;
  }

  async listarChats() {
    const result = await this.request('/chat');
    return result.chats;
  }

  async obtenerMensajes(chatId, limit, offset) {
    let url = `/message/${chatId}`;
    const params = new URLSearchParams();
    if (limit) params.append('limit', limit);
    if (offset) params.append('offset', offset);
    if (params.toString()) url += `?${params}`;

    const result = await this.request(url);
    return result.messages;
  }

  async enviarPregunta(pregunta, chatId = null) {
    const endpoint = chatId
      ? `/message/response/${chatId}?question=${encodeURIComponent(pregunta)}`
      : `/message/response?question=${encodeURIComponent(pregunta)}`;
    return this.request(endpoint);
  }

  async asignarMensaje(messageId, chatId) {
    return this.request(`/message/${messageId}/${chatId}`, { method: 'PUT' });
  }

  // === Documents ===

  async listarDocumentos() {
    const result = await this.request('/document');
    return result.documents;
  }

  async subirDocumento(file, metadata) {
    await this.refreshTokenSiNecesario();

    const formData = new FormData();
    formData.append('filename', metadata.filename);
    formData.append('author', metadata.author);
    formData.append('year', metadata.year.toString());
    formData.append('minAge', metadata.minAge.toString());
    formData.append('maxAge', metadata.maxAge.toString());
    formData.append('file', file);

    const response = await fetch(`${this.baseUrl}/document`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` },
      body: formData
    });

    return this.manejarRespuesta(response);
  }

  async eliminarDocumento(documentId) {
    return this.request(`/document/${documentId}`, { method: 'DELETE' });
  }
}

// Uso:
const api = new CiudadanoDigitalAPI();
```

---

## 9. Consideraciones para Web

### Almacenamiento de Tokens
- Usar `localStorage` para persistencia entre sesiones
- Considerar `sessionStorage` si se prefiere cerrar sesión al cerrar navegador
- Para mayor seguridad, considerar httpOnly cookies (requiere cambios en backend)

### Device ID
- Generar UUID único y almacenarlo en localStorage
- Mantener consistente entre sesiones

### CORS
- Asegurar que el backend permita orígenes del frontend web
- Headers necesarios: `Authorization`, `Content-Type`

### Manejo de Conexión
- Implementar reintentos automáticos para errores de red
- Mostrar estado de conexión al usuario
- Cola de operaciones offline (opcional)
