# HelpDesk Smart Priority

Sistema de gestión de tickets de soporte técnico con priorización automática desarrollado con Node.js y Express.

## 📋 Descripción del Proyecto

HelpDesk Smart Priority es una aplicación web que permite a instituciones educativas gestionar solicitudes de soporte técnico de estudiantes, docentes y funcionarios. El sistema calcula automáticamente la prioridad de cada ticket basándose en criterios como impacto, urgencia, categoría y tiempo estimado.

## 🛠️ Tecnologías Utilizadas

- **Backend:** Node.js, Express.js
- **Frontend:** HTML5, CSS3, JavaScript (Fetch API)
- **Persistencia:** JSON (actualmente en memoria)
- **Seguridad:** Cookies, Tokens de sesión

## 📦 Instalación

### Requisitos Previos
- Node.js (v14 o superior)
- npm (incluido con Node.js)

### Pasos

1. **Clonar o descargar el proyecto**
   ```bash
   cd STF
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Iniciar el servidor**
   ```bash
   npm start
   ```
   O en modo desarrollo con nodemon:
   ```bash
   npm run dev
   ```

El servidor estará disponible en `http://localhost:3000`

## 🚀 Ejecución

```bash
# Inicio normal
npm start

# Modo desarrollo (con auto-reload)
npm run dev
```

## 🔑 Credenciales de Prueba

- **Usuario:** admin
- **Contraseña:** 1234

## 📡 Endpoints

### Autenticación

#### Login
```
POST /api/login
Content-Type: application/json

{
  "username": "admin",
  "password": "1234"
}
```

**Respuesta exitosa (200):**
```json
{
  "message": "Login exitoso",
  "user": {
    "id": 1,
    "username": "admin"
  },
  "token": "abc123..."
}
```

#### Logout
```
POST /api/logout
```

#### Verificar Sesión
```
GET /api/check-session
Authorization: Bearer <token>
```

### Tickets (Requieren autenticación)

#### Crear Ticket
```
POST /api/tickets
Authorization: Bearer <token>
Content-Type: application/json

{
  "nombreSolicitante": "Juan Pérez",
  "correo": "juan@ejemplo.com",
  "categoria": "hardware",
  "descripcion": "El monitor no enciende",
  "impacto": "alto",
  "urgencia": "alta",
  "tiempoEstimado": 2
}
```

**Respuesta (201):**
```json
{
  "message": "Ticket creado exitosamente",
  "ticket": {
    "id": 1,
    "nombreSolicitante": "Juan Pérez",
    "correo": "juan@ejemplo.com",
    "categoria": "hardware",
    "descripcion": "El monitor no enciende",
    "impacto": "alto",
    "urgencia": "alta",
    "tiempoEstimado": 2,
    "estado": "pendiente",
    "prioridad": "Crítica",
    "fechaCreacion": "2024-05-18T10:30:00.000Z"
  }
}
```

#### Listar Tickets
```
GET /api/tickets
Authorization: Bearer <token>
```

#### Obtener Ticket por ID
```
GET /api/tickets/:id
Authorization: Bearer <token>
```

#### Actualizar Ticket
```
PUT /api/tickets/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "estado": "en proceso",
  "descripcion": "Nuevo texto"
}
```

#### Eliminar Ticket
```
DELETE /api/tickets/:id
Authorization: Bearer <token>
```

## 📊 Algoritmo de Priorización

La prioridad se calcula automáticamente según:

### Puntajes Base
- **Impacto:** bajo (1), medio (2), alto (3)
- **Urgencia:** baja (1), media (2), alta (3)

### Bonificaciones
- Categoría "red" o "cuenta": +1 punto
- Tiempo estimado > 4 horas: +1 punto

### Rangos de Prioridad
- 1-3 puntos: **Baja**
- 4-5 puntos: **Media**
- 6 puntos: **Alta**
- 7+ puntos: **Crítica**

## 🔒 Seguridad

### HTTPS

**¿Qué es HTTPS?**
HTTPS (HyperText Transfer Protocol Secure) es la versión segura de HTTP que cifra la comunicación entre el cliente y el servidor usando certificados SSL/TLS.

**¿Qué riesgos ayuda a mitigar?**
- **Interceptación de datos:** Los datos viajan cifrados, impidiendo que terceros vean credenciales o información sensible.
- **Man-in-the-Middle (MITM):** El certificado verifica la identidad del servidor, previniendo ataques intermediarios.
- **Modificación de contenido:** El cifrado asegura que los datos no sean alterados durante la transmisión.

**¿Por qué es importante en aplicaciones web?**
- Protege datos de usuarios (contraseñas, emails, información personal).
- Aumenta la confianza del usuario en la aplicación.
- Mejora el SEO (Google favorece sitios HTTPS).
- Es obligatorio para el cumplimiento de estándares de seguridad (GDPR, PCI DSS).

### Implementación Actual
- Autenticación basada en tokens de sesión
- Cookies HTTPOnly para mayor seguridad
- Validaciones en lado del servidor
- Manejo de errores sin exponer información sensible

## 📂 Estructura del Proyecto

```
STF/
├── src/
│   ├── routes/              # Definición de rutas
│   │   ├── authRoutes.js
│   │   └── ticketRoutes.js
│   ├── controllers/         # Manejadores de requests
│   │   ├── authController.js
│   │   └── ticketController.js
│   ├── services/            # Lógica de negocio
│   │   ├── authService.js
│   │   └── ticketService.js
│   ├── middlewares/         # Middlewares (autenticación, validación)
│   │   └── authMiddleware.js
│   ├── data/                # Persistencia (JSON o DB)
│   ├── public/              # Archivos estáticos (HTML, CSS, JS)
│   │   └── login.html
│   └── app.js               # Archivo principal
├── package.json             # Dependencias y scripts
└── README.md                # Este archivo
```

## 📝 Validaciones Obligatorias

El sistema valida:
- ✓ Campos obligatorios
- ✓ Formato de correo
- ✓ Valores válidos para impacto y urgencia
- ✓ IDs inexistentes
- ✓ Accesos no autorizados

## 🐛 Ejemplos de Uso

### Usando Postman/Thunder Client

#### 1. Login
```
POST http://localhost:3000/api/login
Body (JSON):
{
  "username": "admin",
  "password": "1234"
}
```

#### 2. Crear Ticket (usar el token del login)
```
POST http://localhost:3000/api/tickets
Headers:
  Authorization: Bearer <token_del_login>
  Content-Type: application/json

Body (JSON):
{
  "nombreSolicitante": "Carlos López",
  "correo": "carlos@example.com",
  "categoria": "red",
  "descripcion": "La red es muy lenta",
  "impacto": "alto",
  "urgencia": "alta",
  "tiempoEstimado": 5
}
```

#### 3. Listar Tickets
```
GET http://localhost:3000/api/tickets
Headers:
  Authorization: Bearer <token_del_login>
```

## 📸 Evidencias

Se adjuntan capturas de:
- Estructura del proyecto
- Servidor ejecutándose
- Pruebas en Postman/Thunder Client
- Formulario de login funcionando
- Repositorio en GitHub

## 📝 Notas Importantes

- La base de datos está en desarrollo
- Actualmente usa almacenamiento en memoria (se pierde al reiniciar)
- La carpeta `data/` está lista para implementar JSON o conexión a BD
- Los tokens expiran en 24 horas

## 👨‍💻 Autor

Proyecto educativo - Unidad II de Programación Web

## 📄 Licencia

ISC
