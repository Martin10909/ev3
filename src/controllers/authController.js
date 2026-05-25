const authService = require('../services/authService');

// Login
async function login(req, res) {
  try {
    const { username, password } = req.body;

    // Validar credenciales
    const validation = await authService.validateCredentials(username, password);

    if (!validation.valid) {
      return res.status(401).json({
        error: 'Acceso denegado',
        message: validation.message
      });
    }

    // Crear sesión
    const token = authService.createSession(validation.user);

    // Enviar token en cookie y en respuesta
    res.cookie('authToken', token, {
      httpOnly: true,
      maxAge: 24 * 60 * 60 * 1000 // 24 horas
    });

    return res.status(200).json({
      message: 'Login exitoso',
      user: validation.user,
      token: token
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

// Logout
function logout(req, res) {
  try {
    const token = req.cookies.authToken || req.headers.authorization?.split(' ')[1];

    if (token) {
      authService.destroySession(token);
    }

    res.clearCookie('authToken');

    return res.status(200).json({
      message: 'Logout exitoso'
    });

  } catch (error) {
    console.error('Error en logout:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

// Verificar sesión
function checkSession(req, res) {
  try {
    const token = req.cookies.authToken || req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        authenticated: false,
        message: 'No hay sesión activa'
      });
    }

    const session = authService.verifySession(token);

    if (!session) {
      return res.status(401).json({
        authenticated: false,
        message: 'Sesión inválida o expirada'
      });
    }

    return res.status(200).json({
      authenticated: true,
      user: session
    });

  } catch (error) {
    console.error('Error al verificar sesión:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

module.exports = {
  login,
  logout,
  checkSession
};
