-- =========================================
-- BASE DE DATOS: HELPDESK SMART PRIORITY
-- Sistema: MySQL con estructura profesional
-- =========================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS helpdesk_db;
USE helpdesk_db;

-- =========================================
-- TABLA 1: EMPRESAS
-- =========================================
CREATE TABLE IF NOT EXISTS empresas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    razon_social VARCHAR(150),
    nit VARCHAR(20) UNIQUE,
    email VARCHAR(100),
    telefono VARCHAR(20),
    ciudad VARCHAR(50),
    pais VARCHAR(50),
    direccion TEXT,
    logo_url VARCHAR(255),
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_empresa_nombre (nombre),
    INDEX idx_empresa_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 2: SERVICIOS/DEPARTAMENTOS
-- =========================================
CREATE TABLE IF NOT EXISTS servicios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo ENUM(
        'Micro-Informática',
        'Soporte Nivel 1',
        'Soporte Nivel 2',
        'Soporte Nivel 3',
        'Infraestructura',
        'Seguridad Informática',
        'Desarrollo',
        'Base de Datos',
        'Redes',
        'Telecomunicaciones'
    ) NOT NULL,
    responsable_email VARCHAR(100),
    telefono_contacto VARCHAR(20),
    tiempo_respuesta_minutos INT DEFAULT 60,
    sla_disponibilidad INT DEFAULT 99,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    INDEX idx_servicio_empresa (empresa_id),
    INDEX idx_servicio_tipo (tipo),
    INDEX idx_servicio_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 3: NIVELES DE SOPORTE
-- =========================================
CREATE TABLE IF NOT EXISTS niveles_soporte (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    escalado_a_nivel_id INT,
    tiempo_respuesta_minutos INT,
    tiempo_resolucion_horas INT,
    costo_hora DECIMAL(10, 2),
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (escalado_a_nivel_id) REFERENCES niveles_soporte(id),
    INDEX idx_nivel_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 4: USUARIOS/TÉCNICOS
-- =========================================
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    cedula VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    rol ENUM('admin', 'tecnico', 'supervisor', 'usuario', 'gerente') DEFAULT 'usuario',
    nivel_soporte_id INT,
    carga_horaria INT DEFAULT 8,
    estado ENUM('activo', 'inactivo', 'licencia') DEFAULT 'activo',
    ultimo_acceso DATETIME,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (nivel_soporte_id) REFERENCES niveles_soporte(id),
    INDEX idx_usuario_email (email),
    INDEX idx_usuario_username (username),
    INDEX idx_usuario_empresa (empresa_id),
    INDEX idx_usuario_rol (rol),
    INDEX idx_usuario_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 5: CATEGORÍAS DE TICKETS
-- =========================================
CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    color_hex VARCHAR(7),
    icono VARCHAR(50),
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_categoria_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 6: TICKETS (MEJORADA)
-- =========================================
CREATE TABLE IF NOT EXISTS tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    servicio_id INT NOT NULL,
    numero_ticket VARCHAR(20) UNIQUE,
    nombre_solicitante VARCHAR(100) NOT NULL,
    correo_solicitante VARCHAR(100) NOT NULL,
    telefono_solicitante VARCHAR(20),
    categoria_id INT NOT NULL,
    descripcion LONGTEXT NOT NULL,
    impacto ENUM('bajo', 'medio', 'alto') NOT NULL,
    urgencia ENUM('baja', 'media', 'alta') NOT NULL,
    tiempo_estimado_horas INT NOT NULL,
    prioridad ENUM('Baja', 'Media', 'Alta', 'Crítica') NOT NULL,
    estado ENUM('pendiente', 'en_proceso', 'en_espera', 'resuelto', 'cerrado', 'reabierto') DEFAULT 'pendiente',
    asignado_a INT,
    nivel_soporte_requerido INT,
    equipo_afectado VARCHAR(100),
    ubicacion VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fecha_asignacion DATETIME,
    fecha_inicio_trabajo DATETIME,
    fecha_resolucion DATETIME,
    fecha_cierre DATETIME,
    solucion LONGTEXT,
    tiempo_total_minutos INT,
    evaluacion_cliente INT CHECK (evaluacion_cliente >= 1 AND evaluacion_cliente <= 5),
    comentario_evaluacion TEXT,
    costo_total DECIMAL(10, 2),
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (asignado_a) REFERENCES usuarios(id),
    FOREIGN KEY (nivel_soporte_requerido) REFERENCES niveles_soporte(id),
    INDEX idx_ticket_empresa (empresa_id),
    INDEX idx_ticket_numero (numero_ticket),
    INDEX idx_ticket_estado (estado),
    INDEX idx_ticket_prioridad (prioridad),
    INDEX idx_ticket_asignado (asignado_a),
    INDEX idx_ticket_fecha (fecha_creacion),
    INDEX idx_ticket_correo (correo_solicitante)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 7: COMENTARIOS/HISTORIAL
-- =========================================
CREATE TABLE IF NOT EXISTS comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    usuario_id INT NOT NULL,
    tipo ENUM('comentario', 'actualizacion', 'escalada', 'asignacion') DEFAULT 'comentario',
    contenido LONGTEXT NOT NULL,
    archivos_adjuntos VARCHAR(500),
    es_privado BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_comentario_ticket (ticket_id),
    INDEX idx_comentario_usuario (usuario_id),
    INDEX idx_comentario_fecha (fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 8: AUDITORÍA
-- =========================================
CREATE TABLE IF NOT EXISTS auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    registro_id INT NOT NULL,
    accion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    datos_anteriores JSON,
    datos_nuevos JSON,
    usuario_id INT,
    descripcion TEXT,
    ip_address VARCHAR(45),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_auditoria_tabla (tabla_afectada),
    INDEX idx_auditoria_registro (registro_id),
    INDEX idx_auditoria_fecha (fecha),
    INDEX idx_auditoria_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 9: MÉTRICAS Y REPORTES
-- =========================================
CREATE TABLE IF NOT EXISTS metricas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    mes INT NOT NULL,
    ano INT NOT NULL,
    total_tickets INT DEFAULT 0,
    tickets_resueltos INT DEFAULT 0,
    tickets_pendientes INT DEFAULT 0,
    tiempo_promedio_resolucion_minutos INT DEFAULT 0,
    ticket_critica INT DEFAULT 0,
    ticket_alta INT DEFAULT 0,
    ticket_media INT DEFAULT 0,
    ticket_baja INT DEFAULT 0,
    satisfaccion_promedio DECIMAL(3, 2),
    costo_total_mes DECIMAL(12, 2),
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    INDEX idx_metricas_empresa (empresa_id),
    INDEX idx_metricas_fecha (ano, mes),
    UNIQUE KEY unique_metricas (empresa_id, mes, ano)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 10: ARCHIVOS ADJUNTOS
-- =========================================
CREATE TABLE IF NOT EXISTS archivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    comentario_id INT,
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_archivo VARCHAR(500) NOT NULL,
    tipo_archivo VARCHAR(50),
    tamaño_bytes INT,
    usuario_id INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (comentario_id) REFERENCES comentarios(id) ON DELETE SET NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_archivo_ticket (ticket_id),
    INDEX idx_archivo_comentario (comentario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 11: CONOCIMIENTO BASE / KB
-- =========================================
CREATE TABLE IF NOT EXISTS conocimiento_base (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    solucion LONGTEXT NOT NULL,
    categoria_id INT,
    palabras_clave VARCHAR(500),
    veces_utilizado INT DEFAULT 0,
    calificacion DECIMAL(3, 2),
    creado_por INT NOT NULL,
    estado ENUM('borrador', 'publicado', 'archivado') DEFAULT 'publicado',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (creado_por) REFERENCES usuarios(id),
    INDEX idx_kb_titulo (titulo),
    INDEX idx_kb_categoria (categoria_id),
    FULLTEXT INDEX ft_kb_contenido (titulo, descripcion, solucion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- TABLA 12: PLANTILLAS DE RESPUESTA
-- =========================================
CREATE TABLE IF NOT EXISTS plantillas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    asunto VARCHAR(200),
    cuerpo LONGTEXT NOT NULL,
    categoria_id INT,
    creado_por INT NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (creado_por) REFERENCES usuarios(id),
    INDEX idx_plantilla_empresa (empresa_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- INSERCIONES DE DATOS INICIALES
-- =========================================

-- Empresas
INSERT INTO empresas (nombre, razon_social, nit, email, telefono, ciudad, pais, direccion) VALUES
('Stefanini Colombia', 'Stefanini International S.A.S', '900123456-7', 'info@stefanini.com.co', '3156789012', 'Bogotá', 'Colombia', 'Calle 100 #15-50'),
('TechCorp Solutions', 'TechCorp Solutions S.A.S', '900234567-8', 'soporte@techcorp.com.co', '3167890123', 'Medellín', 'Colombia', 'Carrera 45 #30-80'),
('Innovatech Systems', 'Innovatech Systems S.A.S', '900345678-9', 'contacto@innovatech.com.co', '3178901234', 'Cali', 'Colombia', 'Avenida 2N #50-100');

-- Niveles de Soporte
INSERT INTO niveles_soporte (nombre, descripcion, tiempo_respuesta_minutos, tiempo_resolucion_horas, costo_hora) VALUES
('Nivel 1 - Soporte Básico', 'Soporte técnico básico y resolver problemas simples', 30, 4, 25000),
('Nivel 2 - Soporte Técnico', 'Soporte técnico especializado para problemas complejos', 60, 8, 45000),
('Nivel 3 - Soporte Crítico', 'Soporte especializado para problemas críticos e infraestructura', 15, 2, 75000),
('Nivel 4 - Escalada Especial', 'Escalada a equipo especializado o proveedores', 120, 24, 100000);

-- Categorías
INSERT INTO categorias (nombre, descripcion, color_hex, icono) VALUES
('Hardware', 'Problemas con equipos físicos', '#FF6B6B', 'monitor'),
('Software', 'Problemas con aplicaciones y sistemas operativos', '#4ECDC4', 'code'),
('Red', 'Problemas de conectividad y red', '#45B7D1', 'wifi'),
('Cuenta', 'Problemas de acceso y credenciales', '#FFA07A', 'user'),
('Base de Datos', 'Problemas con bases de datos', '#98D8C8', 'database'),
('Infraestructura', 'Problemas de servidores e infraestructura', '#F7DC6F', 'server'),
('Seguridad', 'Incidentes y problemas de seguridad', '#BB8FCE', 'shield'),
('Soporte General', 'Otras solicitudes de soporte', '#85C1E9', 'help');

-- Usuarios (Administradores y Técnicos)
INSERT INTO usuarios (empresa_id, nombre, apellido, email, username, password, cedula, telefono, especialidad, rol, nivel_soporte_id, estado) VALUES
(1, 'Admin', 'Sistema', 'admin@stefanini.com.co', 'admin', '1234', '1234567890', '3156789012', 'Administración', 'admin', 1, 'activo'),
(1, 'Juan', 'Pérez García', 'juan.perez@stefanini.com.co', 'juanperez', '1234', '1098765432', '3167890123', 'Micro-Informática', 'tecnico', 1, 'activo'),
(1, 'María', 'González López', 'maria.gonzalez@stefanini.com.co', 'mariagonz', '1234', '1087654321', '3178901234', 'Redes', 'tecnico', 2, 'activo'),
(1, 'Carlos', 'Rodríguez Silva', 'carlos.rodriguez@stefanini.com.co', 'carlosrod', '1234', '1076543210', '3189012345', 'Infraestructura', 'tecnico', 3, 'activo'),
(2, 'Admin', 'TechCorp', 'admin@techcorp.com.co', 'admin_tech', '1234', '1065432109', '3190123456', 'Administración', 'admin', 1, 'activo'),
(2, 'Sandra', 'Martínez López', 'sandra.martinez@techcorp.com.co', 'sandramtz', '1234', '1054321098', '3101234567', 'Base de Datos', 'tecnico', 2, 'activo'),
(3, 'Admin', 'Innovatech', 'admin@innovatech.com.co', 'admin_inno', '1234', '1043210987', '3112345678', 'Administración', 'admin', 1, 'activo');

-- Servicios/Departamentos
INSERT INTO servicios (empresa_id, nombre, descripcion, tipo, responsable_email, telefono_contacto, tiempo_respuesta_minutos, sla_disponibilidad) VALUES
(1, 'Micro-Informática', 'Soporte a equipos de escritorio y portátiles', 'Micro-Informática', 'micro@stefanini.com.co', '3156789012', 60, 99),
(1, 'Soporte Nivel 1', 'Soporte técnico básico', 'Soporte Nivel 1', 'soporte1@stefanini.com.co', '3167890123', 30, 99),
(1, 'Soporte Nivel 2', 'Soporte técnico especializado', 'Soporte Nivel 2', 'soporte2@stefanini.com.co', '3178901234', 60, 99),
(1, 'Soporte Nivel 3', 'Soporte crítico e infraestructura', 'Soporte Nivel 3', 'soporte3@stefanini.com.co', '3189012345', 15, 99),
(2, 'Micro-Informática', 'Soporte a equipos de escritorio y portátiles', 'Micro-Informática', 'micro@techcorp.com.co', '3167890123', 60, 99),
(2, 'Infraestructura', 'Soporte de infraestructura y servidores', 'Infraestructura', 'infra@techcorp.com.co', '3178901234', 30, 99),
(3, 'Desarrollo', 'Soporte a desarrolladores', 'Desarrollo', 'dev@innovatech.com.co', '3189012345', 60, 99);

-- Tickets de ejemplo
INSERT INTO tickets (empresa_id, servicio_id, numero_ticket, nombre_solicitante, correo_solicitante, telefono_solicitante, categoria_id, descripcion, impacto, urgencia, tiempo_estimado_horas, prioridad, estado, asignado_a, nivel_soporte_requerido, equipo_afectado, ubicacion, fecha_creacion) VALUES
(1, 1, 'TKT-2024-001', 'Juan Mendoza', 'juan.mendoza@empresa.com', '3105551234', 1, 'Monitor no enciende después de apagón', 'alto', 'alta', 2, 'Crítica', 'en_proceso', 2, 1, 'Monitor Dell U2415', 'Oficina 101', NOW()),
(1, 2, 'TKT-2024-002', 'María Salazar', 'maria.salazar@empresa.com', '3105551235', 4, 'No puedo acceder a mi cuenta', 'medio', 'alta', 1, 'Alta', 'pendiente', 3, 1, 'Computadora Dell Latitude', 'Oficina 205', NOW()),
(1, 3, 'TKT-2024-003', 'Pedro López', 'pedro.lopez@empresa.com', '3105551236', 3, 'Internet muy lento en el piso 3', 'alto', 'alta', 3, 'Alta', 'en_proceso', 3, 2, 'Router Cisco ASR1000', 'Piso 3', NOW()),
(1, 4, 'TKT-2024-004', 'Ana García', 'ana.garcia@empresa.com', '3105551237', 6, 'Servidor de producción está caído', 'alto', 'alta', 8, 'Crítica', 'en_proceso', 4, 3, 'Servidor HP ProLiant DL380', 'Data Center', NOW()),
(2, 5, 'TKT-2024-005', 'Luis Fernando', 'luis.fernando@techcorp.com', '3105551238', 1, 'Laptop no enciende', 'medio', 'media', 2, 'Media', 'pendiente', 6, 1, 'Laptop HP EliteBook', 'Oficina A', NOW()),
(3, 7, 'TKT-2024-006', 'Sofia Contreras', 'sofia.contreras@innovatech.com', '3105551239', 2, 'Error en aplicación web de reportes', 'medio', 'media', 4, 'Media', 'resuelto', 1, 2, 'Servidor Aplicaciones', 'Cloud', NOW());

-- Comentarios/Historial
INSERT INTO comentarios (ticket_id, usuario_id, tipo, contenido, es_privado) VALUES
(1, 2, 'comentario', 'Revisando el equipo. Aparentemente es problema del cable de poder', FALSE),
(1, 2, 'actualizacion', 'Se reemplazó el cable de poder. Equipo funcionando correctamente', FALSE),
(2, 3, 'asignacion', 'Ticket asignado al equipo de cuentas', FALSE),
(3, 3, 'comentario', 'Realizando diagnóstico de red', FALSE),
(4, 4, 'escalada', 'Se requiere intervención de especialista en infraestructura', FALSE),
(6, 1, 'actualizacion', 'Problema resuelto. Actualización de certificado SSL aplicada', FALSE);

-- Variables de entorno para .env
-- NODE_ENV=development
-- PORT=3000
-- DB_HOST=localhost
-- DB_PORT=3306
-- DB_USER=root
-- DB_PASSWORD=tu_password
-- DB_NAME=helpdesk_db
-- JWT_SECRET=tu_secreto_super_seguro_aqui_2024
