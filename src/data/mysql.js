const mysql = require('mysql2/promise');
require('dotenv').config();

// Pool de conexiones para mejor rendimiento
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'helpdesk_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelayMs: 0,
});

// Verificar conexión
pool.getConnection()
  .then(conn => {
    console.log('✅ Conectado a MySQL - Base de datos: ' + process.env.DB_NAME);
    conn.release();
  })
  .catch(err => {
    console.error('❌ Error de conexión a MySQL:', err.message);
    console.error('   Host:', process.env.DB_HOST);
    console.error('   Usuario:', process.env.DB_USER);
    console.error('   Base de datos:', process.env.DB_NAME);
  });

module.exports = pool;
