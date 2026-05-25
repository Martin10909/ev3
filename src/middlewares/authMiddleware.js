const authService = require('../services/authService');

// Middleware de autenticación
function authMiddleware(req, res, next) {
  const token = req.cookies.authToken || req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      error: 'Acceso denegado',
      message: 'Token no proporcionado'
    });
  }

  const session = authService.verifySession(token);

  if (!session) {
    return res.status(401).json({
      error: 'Acceso denegado',
      message: 'Token inválido o expirado'
    });
  }

  req.user = session;
  next();
}

// Middleware de manejo de errores de validación
function errorHandler(err, req, res, next) {
  console.error('Error:', err);
  
  if (err.status === 400) {
    return res.status(400).json({
      error: 'Error de validación',
      message: err.message
    });
  }

  res.status(500).json({
    error: 'Error interno del servidor',
    message: err.message || 'Algo salió mal'
  });
}

module.exports = {
  authMiddleware,
  errorHandler
};
