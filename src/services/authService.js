const pool = require('../data/mysql');

// Sesiones activas
const sessions = new Map();

// Generar token simple
function generateToken() {
  return Math.random().toString(36).substring(2, 15) + 
         Math.random().toString(36).substring(2, 15);
}

// Validar credenciales contra la BD
async function validateCredentials(username, password) {
  try {
    if (!username || !password) {
      return {
        valid: false,
        message: 'Usuario y contraseña son requeridos'
      };
    }

    if (username.trim() === '') {
      return {
        valid: false,
        message: 'Ingrese nombre de usuario correcto'
      };
    }

    if (password.trim() === '') {
      return {
        valid: false,
        message: 'Ingrese contraseña correcta'
      };
    }

    // Buscar usuario en BD
    const connection = await pool.getConnection();
    const [users] = await connection.query(
      'SELECT id, username, email, nombre, apellido, rol, empresa_id FROM usuarios WHERE username = ? AND password = ? AND estado = "activo"',
      [username, password]
    );
    connection.release();

    if (users.length === 0) {
      return {
        valid: false,
        message: 'Ingrese nombre de usuario correcto'
      };
    }

    const user = users[0];

    return {
      valid: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        nombre: user.nombre,
        apellido: user.apellido,
        rol: user.rol,
        empresa_id: user.empresa_id
      }
    };

  } catch (error) {
    console.error('Error en validateCredentials:', error);
    return {
      valid: false,
      message: 'Error al validar credenciales'
    };
  }
}

// Crear sesión
function createSession(user) {
  const token = generateToken();
  const sessionData = {
    userId: user.id,
    username: user.username,
    createdAt: new Date(),
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 horas
  };
  
  sessions.set(token, sessionData);
  return token;
}

// Verificar sesión
function verifySession(token) {
  if (!token || !sessions.has(token)) {
    return null;
  }

  const session = sessions.get(token);
  
  if (new Date() > session.expiresAt) {
    sessions.delete(token);
    return null;
  }

  return session;
}

// Cerrar sesión
function destroySession(token) {
  sessions.delete(token);
}

module.exports = {
  validateCredentials,
  createSession,
  verifySession,
  destroySession
};
