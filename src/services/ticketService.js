const pool = require('../data/mysql');

// Calcular prioridad según el algoritmo
function calculatePriority(impacto, urgencia, categoria, tiempoEstimado) {
  let puntaje = 0;

  const impactoMap = { bajo: 1, medio: 2, alto: 3 };
  puntaje += impactoMap[impacto] || 0;

  const urgenciaMap = { baja: 1, media: 2, alta: 3 };
  puntaje += urgenciaMap[urgencia] || 0;

  if (categoria === 'red' || categoria === 'cuenta') {
    puntaje += 1;
  }

  if (tiempoEstimado > 4) {
    puntaje += 1;
  }

  if (puntaje <= 3) return 'Baja';
  if (puntaje <= 5) return 'Media';
  if (puntaje === 6) return 'Alta';
  return 'Crítica';
}

// Generar número de ticket único
async function generarNumeroTicket() {
  try {
    const connection = await pool.getConnection();
    const [result] = await connection.query(
      'SELECT COUNT(*) as count FROM tickets WHERE DATE(fecha_creacion) = CURDATE()'
    );
    connection.release();

    const count = result[0].count + 1;
    const fecha = new Date().toISOString().split('T')[0].replace(/-/g, '');
    return `TKT-${fecha}-${String(count).padStart(4, '0')}`;
  } catch (error) {
    console.error('Error generando número de ticket:', error);
    return `TKT-${Date.now()}`;
  }
}

// Crear ticket
async function createTicket(ticketData) {
  try {
    const numeroTicket = await generarNumeroTicket();
    const prioridad = calculatePriority(
      ticketData.impacto,
      ticketData.urgencia,
      ticketData.categoria,
      ticketData.tiempoEstimado
    );

    const connection = await pool.getConnection();
    const [result] = await connection.query(
      `INSERT INTO tickets 
       (empresa_id, servicio_id, numero_ticket, nombre_solicitante, correo_solicitante, 
        telefono_solicitante, categoria_id, descripcion, impacto, urgencia, 
        tiempo_estimado_horas, prioridad, estado) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        ticketData.empresa_id || 1,
        ticketData.servicio_id || 1,
        numeroTicket,
        ticketData.nombreSolicitante,
        ticketData.correo,
        ticketData.telefonoSolicitante || null,
        ticketData.categoria_id || 1,
        ticketData.descripcion,
        ticketData.impacto,
        ticketData.urgencia,
        ticketData.tiempoEstimado,
        prioridad,
        'pendiente'
      ]
    );

    const ticketId = result.insertId;
    const newTicket = await getTicketById(ticketId);
    connection.release();

    return newTicket;
  } catch (error) {
    console.error('Error creando ticket:', error);
    throw error;
  }
}

// Obtener todos los tickets
async function getAllTickets() {
  try {
    const connection = await pool.getConnection();
    const [tickets] = await connection.query(
      `SELECT t.*, c.nombre as categoria_nombre, u.nombre as asignado_nombre
       FROM tickets t
       LEFT JOIN categorias c ON t.categoria_id = c.id
       LEFT JOIN usuarios u ON t.asignado_a = u.id
       ORDER BY t.fecha_creacion DESC`
    );
    connection.release();

    return tickets || [];
  } catch (error) {
    console.error('Error obteniendo tickets:', error);
    return [];
  }
}

// Obtener ticket por ID
async function getTicketById(id) {
  try {
    const connection = await pool.getConnection();
    const [tickets] = await connection.query(
      `SELECT t.*, c.nombre as categoria_nombre, u.nombre as asignado_nombre
       FROM tickets t
       LEFT JOIN categorias c ON t.categoria_id = c.id
       LEFT JOIN usuarios u ON t.asignado_a = u.id
       WHERE t.id = ?`,
      [id]
    );
    connection.release();

    return tickets.length > 0 ? tickets[0] : null;
  } catch (error) {
    console.error('Error obteniendo ticket:', error);
    return null;
  }
}

// Actualizar ticket
async function updateTicket(id, updateData) {
  try {
    const ticket = await getTicketById(id);
    if (!ticket) {
      return null;
    }

    const connection = await pool.getConnection();
    
    let query = 'UPDATE tickets SET ';
    const values = [];

    if (updateData.estado) {
      query += 'estado = ?, ';
      values.push(updateData.estado);
    }
    if (updateData.descripcion) {
      query += 'descripcion = ?, ';
      values.push(updateData.descripcion);
    }
    if (updateData.impacto || updateData.urgencia) {
      const newPriority = calculatePriority(
        updateData.impacto || ticket.impacto,
        updateData.urgencia || ticket.urgencia,
        ticket.categoria,
        ticket.tiempo_estimado_horas
      );
      query += 'prioridad = ?, ';
      values.push(newPriority);
    }
    if (updateData.asignado_a) {
      query += 'asignado_a = ?, ';
      values.push(updateData.asignado_a);
    }
    if (updateData.solucion) {
      query += 'solucion = ?, fecha_resolucion = NOW(), ';
      values.push(updateData.solucion);
    }

    query += 'fecha_actualizacion = NOW() WHERE id = ?';
    values.push(id);

    await connection.query(query, values);
    connection.release();

    return await getTicketById(id);
  } catch (error) {
    console.error('Error actualizando ticket:', error);
    return null;
  }
}

// Eliminar ticket
async function deleteTicket(id) {
  try {
    const connection = await pool.getConnection();
    const [result] = await connection.query('DELETE FROM tickets WHERE id = ?', [id]);
    connection.release();

    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error eliminando ticket:', error);
    return false;
  }
}

module.exports = {
  createTicket,
  getAllTickets,
  getTicketById,
  updateTicket,
  deleteTicket,
  calculatePriority
};
