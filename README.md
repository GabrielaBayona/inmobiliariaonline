# 🏠 InmoConnect - Sistema Inmobiliario

Sistema web inmobiliario desarrollado en **JSP**, **HTML**, **Bootstrap** y **MySQL** para la gestión de propiedades, usuarios y transacciones.

## 🎯 Características Principales

- **Sistema de Autenticación** con roles (Administrador, Cliente, Inmobiliaria)
- **Dashboard Administrativo** con estadísticas en tiempo real
- **Gestión de Usuarios** completa (CRUD)
- **Interfaz Responsive** con Bootstrap 5
- **Conexión Directa** a MySQL sin servlets

## 🛠️ Tecnologías Utilizadas

- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5
- **Backend**: JSP (Java Server Pages)
- **Base de Datos**: MySQL
- **Servidor**: Apache Tomcat o XAMPP
- **Driver**: MySQL Connector/J

## 📋 Requisitos Previos

- **Java JDK 8** o superior
- **Apache Tomcat 9** o **XAMPP**
- **MySQL 5.7** o superior
- **MySQL Connector/J** (driver JDBC)

## 🚀 Instalación y Configuración

### 1. Configurar la Base de Datos

```sql
-- Crear base de datos
CREATE DATABASE inmobiliaria_db;
USE inmobiliaria_db;

-- Ejecutar el script SQL que se encuentra en la carpeta database/
-- O ejecutar directamente desde phpMyAdmin en XAMPP
```

### 2. Configurar XAMPP

1. **Iniciar XAMPP Control Panel**
2. **Activar Apache y MySQL**
3. **Abrir phpMyAdmin** (http://localhost/phpmyadmin)
4. **Crear la base de datos** `inmobiliaria_db`
5. **Importar el script SQL** de la base de datos

### 3. Configurar el Proyecto

1. **Clonar o descargar** el proyecto
2. **Colocar en la carpeta** `htdocs` de XAMPP
3. **Configurar la conexión** en los archivos JSP si es necesario

### 4. Configurar la Conexión a la Base de Datos

Los archivos JSP ya tienen configurada la conexión para XAMPP:

```java
String url = "jdbc:mysql://localhost:3306/inmobiliaria_db";
String user = "root";
String pass = "";
```

Si cambias la configuración, modifica estos valores en los archivos JSP.

## 🔐 Acceso al Sistema

### Usuario Administrador por Defecto

- **Correo**: admin@admin.com
- **Contraseña**: admin123
- **Rol**: Administrador

### URL de Acceso

- **Portal Principal**: `http://localhost/inmoconnect/inicio.html`
- **Sistema de Login**: `http://localhost/inmoconnect/login.jsp`
- **Dashboard Admin**: `http://localhost/inmoconnect/admin/dashboard.jsp`

## 📁 Estructura del Proyecto

```
inmoconnect/
├── inicio.html                 # Portal principal
├── login.jsp                   # Sistema de autenticación
├── logout.jsp                  # Cerrar sesión
├── admin/                      # Panel de administrador
│   ├── dashboard.jsp          # Dashboard principal
│   ├── usuarios.jsp           # Gestión de usuarios
│   ├── propiedades.jsp        # Gestión de propiedades
│   ├── citas.jsp             # Gestión de citas
│   ├── transacciones.jsp     # Transacciones
│   ├── reportes.jsp          # Reportes
│   └── configuracion.jsp     # Configuración
├── cliente/                    # Panel de cliente
├── inmobiliaria/              # Panel de inmobiliaria
└── database/                   # Scripts de base de datos
    └── inmobiliaria_db.sql    # Estructura y datos iniciales
```

## 🔧 Funcionalidades Implementadas

### ✅ Scrum 1 - Base del Sistema

- [x] **Sistema de Login** con JSP y MySQL
- [x] **Dashboard del Administrador** con estadísticas
- [x] **Gestión de Usuarios** (crear, listar)
- [x] **Verificación de Sesiones** y roles
- [x] **Conexión a Base de Datos** MySQL
- [x] **Interfaz Responsive** con Bootstrap

### 🚧 En Desarrollo

- [ ] Gestión de Propiedades
- [ ] Sistema de Citas
- [ ] Transacciones
- [ ] Reportes
- [ ] Dashboard de Cliente
- [ ] Dashboard de Inmobiliaria

## 🐛 Solución de Problemas

### Error de Conexión a la Base de Datos

1. **Verificar que MySQL esté activo** en XAMPP
2. **Confirmar credenciales** (usuario: root, contraseña: vacía)
3. **Verificar puerto** (por defecto 3306)
4. **Comprobar nombre de la base de datos** (`inmobiliaria_db`)

### Error de Driver MySQL

1. **Descargar MySQL Connector/J** desde MySQL
2. **Colocar el archivo .jar** en la carpeta `WEB-INF/lib/`
3. **Verificar la ruta del driver** en los archivos JSP

### Error de Permisos

1. **Verificar permisos** de la carpeta del proyecto
2. **Confirmar que Apache** tenga acceso a los archivos
3. **Revisar logs** de Apache y MySQL

## 📱 Características de la Interfaz

- **Diseño Responsive** para móviles y tablets
- **Sidebar de Navegación** con menú desplegable
- **Tarjetas de Estadísticas** con animaciones
- **Tablas Interactivas** con Bootstrap
- **Modales para Formularios** de creación/edición
- **Sistema de Alertas** para mensajes del usuario

## 🔒 Seguridad

- **Verificación de Sesiones** en cada página
- **Control de Acceso** por roles de usuario
- **Validación de Formularios** en frontend y backend
- **Prevención de SQL Injection** con PreparedStatements
- **Manejo de Errores** sin exponer información sensible

## 📊 Base de Datos

### Tablas Principales

- **roles**: Definición de roles del sistema
- **usuarios**: Información de usuarios registrados
- **propiedades**: Catálogo de propiedades inmobiliarias
- **citas**: Agendamiento de visitas y citas
- **transacciones**: Registro de compras y alquileres
- **reportes**: Generación de reportes del sistema

## 🚀 Próximos Pasos

### Scrum 2 (Días 8-14)
- [ ] CRUD completo de propiedades
- [ ] Sistema de citas con calendario
- [ ] Gestión de usuarios avanzada
- [ ] Validaciones de formularios

### Scrum 3 (Días 15-21)
- [ ] Simulación de transacciones
- [ ] Reportes con gráficos
- [ ] Dashboard de cliente e inmobiliaria
- [ ] Pruebas y documentación final

## 📞 Soporte

Para soporte técnico o consultas sobre el proyecto:

- **Email**: soporte@inmoconnect.com
- **Documentación**: Ver archivos de código comentados
- **Issues**: Reportar problemas en el repositorio

## 📄 Licencia

Este proyecto es desarrollado con fines educativos y de práctica. Todos los derechos reservados.

---

**Desarrollado con ❤️ para el curso de Desarrollo Web**
