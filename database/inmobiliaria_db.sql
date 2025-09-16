-- =====================================================
-- SCRIPT DE BASE DE DATOS - INMOCONNECT
-- Sistema Inmobiliario Universitario
-- =====================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS inmobiliaria_db;
USE inmobiliaria_db;

-- ==============================
-- TABLA DE ROLES
-- ==============================
CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- ==============================
-- TABLA DE USUARIOS
-- ==============================
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    rol_id INT NOT NULL,
    creado_por_admin BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (rol_id) REFERENCES roles(id_rol)
);

-- ==============================
-- TABLA DE PROPIEDADES
-- ==============================
CREATE TABLE IF NOT EXISTS propiedades (
    id_propiedad INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(12,2) NOT NULL,
    tipo ENUM('venta', 'alquiler') NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    estado ENUM('disponible', 'vendida', 'alquilada') DEFAULT 'disponible',
    inmobiliaria_id INT NOT NULL,
    FOREIGN KEY (inmobiliaria_id) REFERENCES usuarios(id_usuario)
);

-- ==============================
-- TABLA DE CITAS
-- ==============================
CREATE TABLE IF NOT EXISTS citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    propiedad_id INT NOT NULL,
    inmobiliaria_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado ENUM('pendiente','confirmada','cancelada') DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (propiedad_id) REFERENCES propiedades(id_propiedad),
    FOREIGN KEY (inmobiliaria_id) REFERENCES usuarios(id_usuario)
);
    
-- ==============================
-- TABLA DE TRANSACCIONES
-- ==============================
CREATE TABLE IF NOT EXISTS transacciones (
    id_transaccion INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    propiedad_id INT NOT NULL,
    tipo ENUM('compra','alquiler') NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (propiedad_id) REFERENCES propiedades(id_propiedad)
);

-- ==============================
-- TABLA DE REPORTES
-- ==============================
CREATE TABLE IF NOT EXISTS reportes (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    generado_por INT NOT NULL,
    FOREIGN KEY (generado_por) REFERENCES usuarios(id_usuario)
);

-- ==============================
-- DATOS INICIALES
-- ==============================

-- Insertar roles
INSERT INTO roles (nombre) VALUES 
('Administrador'),
('Cliente'),
('Inmobiliaria');

-- Usuario administrador inicial
INSERT INTO usuarios (nombre, correo, password, telefono, direccion, rol_id, creado_por_admin)
VALUES ('Admin Principal', 'admin@admin.com', 'admin123', '3000000000', 'Oficina Central', 1, TRUE);

-- Usuario inmobiliaria de ejemplo
INSERT INTO usuarios (nombre, correo, password, telefono, direccion, rol_id, creado_por_admin)
VALUES ('Inmobiliaria Ejemplo', 'inmobiliaria@ejemplo.com', 'inmo123', '3001111111', 'Calle Principal #123', 3, TRUE);

-- Usuario cliente de ejemplo
INSERT INTO usuarios (nombre, correo, password, telefono, direccion, rol_id, creado_por_admin)
VALUES ('Cliente Ejemplo', 'cliente@ejemplo.com', 'cliente123', '3002222222', 'Avenida Central #456', 2, TRUE);

-- Propiedades de ejemplo
INSERT INTO propiedades (titulo, descripcion, precio, tipo, ubicacion, estado, inmobiliaria_id) VALUES
('Casa Moderna en Cabecera', 'Hermosa casa moderna ubicada en el exclusivo sector de Cabecera del Llano, con acabados de primera, amplios espacios y excelente ubicación cerca a centros comerciales y universidades.', 450000000, 'venta', 'Cabecera del Llano, Bucaramanga', 'disponible', 2),
('Apartamento Centro Histórico', 'Acogedor apartamento en el corazón histórico de Bucaramanga, ideal para profesionales. Cerca a entidades bancarias, notarías y transporte público.', 1200000, 'alquiler', 'Centro, Bucaramanga', 'disponible', 2),
('Penthouse Torre Premium', 'Exclusivo penthouse en torre premium con vista panorámica de la ciudad. Ubicado en el sector más exclusivo de Cabecera con amenidades de lujo.', 800000000, 'venta', 'Cabecera del Llano, Bucaramanga', 'disponible', 2),
('Casa Familiar Lagos del Cacique', 'Espaciosa casa familiar en el exclusivo conjunto Lagos del Cacique, con amplio jardín y zona social. Ideal para familias que buscan tranquilidad y seguridad.', 2800000, 'alquiler', 'Lagos del Cacique, Floridablanca', 'disponible', 2),
('Apartaestudio Zona Rosa', 'Moderno apartaestudio completamente amoblado en la Zona Rosa, ideal para estudiantes universitarios o profesionales jóvenes. Excelente ubicación comercial.', 900000, 'alquiler', 'Zona Rosa, Bucaramanga', 'disponible', 2),
('Local Comercial Centro Comercial', 'Local comercial en excelente ubicación dentro del Centro Comercial Cacique, con alto flujo de personas y excelente visibilidad para cualquier tipo de negocio.', 3500000, 'alquiler', 'Centro Comercial Cacique, Floridablanca', 'disponible', 2),
('Finca El Refugio', 'Hermosa finca de recreo en el sector de Ruitoque, con clima templado, casa principal, cabaña de huéspedes y amplias zonas verdes. Ideal para descanso familiar.', 1200000000, 'venta', 'Ruitoque, Piedecuesta', 'disponible', 2),
('Apartamento Villa Country', 'Cómodo apartamento en Villa Country, conjunto cerrado con excelentes amenidades y ubicación estratégica cerca al centro comercial y vías principales.', 320000000, 'venta', 'Villa Country, Girón', 'disponible', 2),
('Casa Lote San Gil', 'Casa independiente con amplio lote en el tradicional barrio San Gil de Piedecuesta, ideal para familias que buscan tranquilidad y espacios amplios.', 2200000, 'alquiler', 'San Gil, Piedecuesta', 'disponible', 2),
('Oficina Empresarial Centro', 'Oficina ejecutiva en edificio empresarial del centro de Bucaramanga, ideal para consultorios, bufetes o empresas de servicios.', 1800000, 'alquiler', 'Carrera 19, Bucaramanga', 'disponible', 2),
('Casa Condominio Rincón del Bosque', 'Elegante casa en condominio cerrado Rincón del Bosque, con arquitectura moderna y acabados de alta calidad en zona de valorización.', 650000000, 'venta', 'Rincón del Bosque, Floridablanca', 'disponible', 2),
('Apartamento Torres del Parque', 'Apartamento con vista al Parque García Rovira, en edificio clásico renovado con todas las comodidades modernas y ubicación céntrica privilegiada.', 280000000, 'venta', 'Parque García Rovira, Bucaramanga', 'disponible', 2),
('Casa Campestre Cañaveral', 'Espectacular casa campestre en Cañaveral con diseño colonial, amplias zonas sociales, piscina y jardines. Perfecta para eventos familiares.', 4500000, 'alquiler', 'Cañaveral, Floridablanca', 'disponible', 2),
('Apartamento Nuevo Girón', 'Moderno apartamento en el tradicional municipio de Girón, cerca al parque principal y con fácil acceso al transporte público hacia Bucaramanga.', 1600000, 'alquiler', 'Las Mercedes, Girón', 'disponible', 2),
('Local Comercial Piedecuesta Centro', 'Local comercial en pleno centro de Piedecuesta, frente al parque principal con excelente flujo peatonal y vehicular. Ideal para cualquier negocio.', 2500000, 'alquiler', 'Parque Principal, Piedecuesta', 'disponible', 2);


-- Citas de ejemplo
INSERT INTO citas (cliente_id, propiedad_id, inmobiliaria_id, fecha, hora, estado) VALUES
(3, 1, 2, '2024-01-15', '14:00:00', 'pendiente'),
(3, 2, 2, '2024-01-16', '10:00:00', 'confirmada');

-- Transacciones de ejemplo
INSERT INTO transacciones (cliente_id, propiedad_id, tipo, monto) VALUES
(3, 2, 'alquiler', 1200000);

-- ==============================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ==============================
CREATE INDEX idx_usuarios_correo ON usuarios(correo);
CREATE INDEX idx_usuarios_rol ON usuarios(rol_id);
CREATE INDEX idx_propiedades_estado ON propiedades(estado);
CREATE INDEX idx_propiedades_tipo ON propiedades(tipo);
CREATE INDEX idx_citas_fecha ON citas(fecha);
CREATE INDEX idx_citas_estado ON citas(estado);
CREATE INDEX idx_transacciones_fecha ON transacciones(fecha);

-- ==============================
-- VERIFICACIÓN DE DATOS
-- ==============================
SELECT 'Base de datos creada exitosamente' as mensaje;
SELECT COUNT(*) as total_roles FROM roles;
SELECT COUNT(*) as total_usuarios FROM usuarios;
SELECT COUNT(*) as total_propiedades FROM propiedades;
SELECT COUNT(*) as total_citas FROM citas;
SELECT COUNT(*) as total_transacciones FROM transacciones;

ALTER TABLE transacciones
ADD COLUMN estado VARCHAR(20) NOT NULL DEFAULT 'pendiente';
