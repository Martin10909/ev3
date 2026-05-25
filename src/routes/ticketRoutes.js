const express = require('express');
const ticketController = require('../controllers/ticketController');
const { authMiddleware } = require('../middlewares/authMiddleware');

const router = express.Router();

// Todas las rutas de tickets requieren autenticación
router.use(authMiddleware);

// Rutas CRUD
router.post('/tickets', ticketController.create);
router.get('/tickets', ticketController.getAll);
router.get('/tickets/:id', ticketController.getById);
router.put('/tickets/:id', ticketController.update);
router.patch('/tickets/:id', ticketController.update);
router.delete('/tickets/:id', ticketController.deleteTicket);

module.exports = router;
