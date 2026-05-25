const ticketService = require('../services/ticketService');

// Validar datos del ticket
function validateTicketData(data) {
  const errors = [];

  if (!data.nombreSolicitante || data.nombreSolicitante.trim() === '') {
    errors.push('Nombre del solicitante es requerido');
  }

  if (!data.correo || data.correo.trim() === '') {
    errors.push('Correo es requerido');
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.correo)) {
    errors.push('Formato de correo inválido');
  }

  if (!data.categoria) {
    errors.push('Categoría es requerida');
  }

  if (!data.descripcion || data.descripcion.trim() === '') {
    errors.push('Descripción es requerida');
  }

  if (!data.impacto || !['bajo', 'medio', 'alto'].includes(data.impacto)) {
    errors.push('Impacto inválido (debe ser: bajo, medio o alto)');
  }

  if (!data.urgencia || !['baja', 'media', 'alta'].includes(data.urgencia)) {
    errors.push('Urgencia inválida (debe ser: baja, media o alta)');
  }

  if (!data.tiempoEstimado || data.tiempoEstimado <= 0) {
    errors.push('Tiempo estimado debe ser mayor a 0');
  }

  return errors;
}

// Crear ticket
async function create(req, res) {
  try {
    const errors = validateTicketData(req.body);

    if (errors.length > 0) {
      return res.status(400).json({
        error: 'Error de validación',
        messages: errors
      });
    }

    const ticket = await ticketService.createTicket(req.body);

    return res.status(201).json({
      message: 'Ticket creado exitosamente',
      ticket: ticket
    });

  } catch (error) {
    console.error('Error al crear ticket:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

// Obtener todos los tickets
async function getAll(req, res) {
  try {
    const tickets = await ticketService.getAllTickets();

    return res.status(200).json({
      count: tickets.length,
      tickets: tickets
    });

  } catch (error) {
    console.error('Error al obtener tickets:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

// Obtener ticket por ID
async function getById(req, res) {
  try {
    const { id } = req.params;
    const ticket = await ticketService.getTicketById(id);

    if (!ticket) {
      return res.status(404).json({
        error: 'Ticket no encontrado',
        message: `No existe ticket con ID ${id}`
      });
    }

    return res.status(200).json({
      ticket: ticket
    });

  } catch (error) {
    console.error('Error al obtener ticket:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

// Actualizar ticket
async function update(req, res) {
  try {
    const { id } = req.params;
    const ticket = await ticketService.getTicketById(id);

    if (!ticket) {
      return res.status(404).json({
        error: 'Ticket no encontrado',
        message: `No existe ticket con ID ${id}`
      });
    }

    const updatedTicket = await ticketService.updateTicket(id, req.body);

    return res.status(200).json({
      message: 'Ticket actualizado exitosamente',
      ticket: updatedTicket
    });

  } catch (error) {
    console.error('Error al actualizar ticket:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

// Eliminar ticket
async function deleteTicket(req, res) {
  try {
    const { id } = req.params;

    const deleted = await ticketService.deleteTicket(id);

    if (!deleted) {
      return res.status(404).json({
        error: 'Ticket no encontrado',
        message: `No existe ticket con ID ${id}`
      });
    }

    return res.status(200).json({
      message: 'Ticket eliminado exitosamente'
    });

  } catch (error) {
    console.error('Error al eliminar ticket:', error);
    res.status(500).json({
      error: 'Error interno',
      message: error.message
    });
  }
}

module.exports = {
  create,
  getAll,
  getById,
  update,
  deleteTicket
};
