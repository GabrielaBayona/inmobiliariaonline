<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }
    
    String adminName = AdminAuth.getAdminName(session);
    
    // Obtener lista de usuarios
    List<Map<String, Object>> usuarios = new ArrayList<>();
    List<Map<String, Object>> roles = new ArrayList<>();
    
    try (Connection conn = ConexionDB.getConnection()) {
        // Obtener roles
        String sqlRoles = "SELECT id_rol, nombre FROM roles ORDER BY nombre";
        try (PreparedStatement stmt = conn.prepareStatement(sqlRoles);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> rol = new HashMap<>();
                rol.put("id", rs.getInt("id_rol"));
                rol.put("nombre", rs.getString("nombre"));
                roles.add(rol);
            }
        }
        
        // Obtener usuarios con información de roles
        String sqlUsuarios = "SELECT u.*, r.nombre as nombre_rol FROM usuarios u " +
                           "JOIN roles r ON u.rol_id = r.id_rol " +
                           "ORDER BY u.nombre";
        try (PreparedStatement stmt = conn.prepareStatement(sqlUsuarios);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> usuario = new HashMap<>();
                usuario.put("id", rs.getInt("id_usuario"));
                usuario.put("nombre", rs.getString("nombre"));
                usuario.put("correo", rs.getString("correo"));
                usuario.put("telefono", rs.getString("telefono"));
                usuario.put("direccion", rs.getString("direccion"));
                usuario.put("rol_id", rs.getInt("rol_id"));
                usuario.put("nombre_rol", rs.getString("nombre_rol"));
                usuario.put("creado_por_admin", rs.getBoolean("creado_por_admin"));
                usuarios.add(usuario);
            }
        }
        
    } catch (SQLException e) {
        System.err.println("Error en usuarios.jsp: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios - InmoConnect Admin</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="admin-styles.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar del Administrador -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-building me-2"></i>
                InmoConnect Admin
            </a>
            
            <div class="navbar-nav ms-auto">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i>
                        <%= adminName %>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="perfil.jsp"><i class="fas fa-user me-2"></i>Mi Perfil</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-3 col-lg-2 d-md-block bg-light sidebar">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="dashboard.jsp">
                                <i class="fas fa-tachometer-alt me-2"></i>
                                Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="usuarios.jsp">
                                <i class="fas fa-users me-2"></i>
                                Gestión de Usuarios
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="propiedades.jsp">
                                <i class="fas fa-home me-2"></i>
                                Gestión de Propiedades
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="citas.jsp">
                                <i class="fas fa-calendar-check me-2"></i>
                                Gestión de Citas
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="transacciones.jsp">
                                <i class="fas fa-money-bill-wave me-2"></i>
                                Transacciones
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Contenido principal -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Gestión de Usuarios</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNuevoUsuario">
                            <i class="fas fa-user-plus me-1"></i>Nuevo Usuario
                        </button>
                    </div>
                </div>

                <!-- Filtros y búsqueda -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" id="searchUsuarios" placeholder="Buscar usuarios...">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" id="filterRol">
                            <option value="">Todos los roles</option>
                            <% for (Map<String, Object> rol : roles) { %>
                                <option value="<%= rol.get("id") %>"><%= rol.get("nombre") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button class="btn btn-outline-secondary" onclick="exportarUsuarios()">
                            <i class="fas fa-download me-1"></i>Exportar
                        </button>
                    </div>
                </div>

                <!-- Tabla de usuarios -->
                <div class="card shadow">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Lista de Usuarios</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" id="tablaUsuarios" data-datatable>
                                <thead>
                                    <tr>
                                        <th data-sortable>ID</th>
                                        <th data-sortable>Nombre</th>
                                        <th data-sortable>Correo</th>
                                        <th data-sortable>Teléfono</th>
                                        <th data-sortable>Rol</th>
                                        <th data-sortable>Estado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> usuario : usuarios) { %>
                                        <tr>
                                            <td><%= usuario.get("id") %></td>
                                            <td><%= usuario.get("nombre") %></td>
                                            <td><%= usuario.get("correo") %></td>
                                            <td><%= usuario.get("telefono") != null ? usuario.get("telefono") : "-" %></td>
                                            <td>
                                                <span class="badge bg-primary"><%= usuario.get("nombre_rol") %></span>
                                            </td>
                                            <td>
                                                <% if ((Boolean) usuario.get("creado_por_admin")) { %>
                                                    <span class="badge bg-success">Activo</span>
                                                <% } else { %>
                                                    <span class="badge bg-warning">Pendiente</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <button type="button" class="btn btn-sm btn-outline-primary" 
                                                            onclick="editarUsuario(<%= usuario.get("id") %>)" 
                                                            title="Editar">
                                                        <i class="fas fa-edit"></i>
                                                    </button>
                                                    <button type="button" class="btn btn-sm btn-outline-danger" 
                                                            onclick="eliminarUsuario(<%= usuario.get("id") %>)" 
                                                            title="Eliminar"
                                                            data-confirm-delete="¿Está seguro de que desea eliminar este usuario?">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Modal Nuevo Usuario -->
    <div class="modal fade" id="modalNuevoUsuario" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Nuevo Usuario</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="formNuevoUsuario" class="needs-validation" novalidate>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="nombre" class="form-label">Nombre completo *</label>
                                <input type="text" class="form-control" id="nombre" name="nombre" required>
                                <div class="invalid-feedback">
                                    Por favor ingrese el nombre completo.
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="correo" class="form-label">Correo electrónico *</label>
                                <input type="email" class="form-control" id="correo" name="correo" required>
                                <div class="invalid-feedback">
                                    Por favor ingrese un correo válido.
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="password" class="form-label">Contraseña *</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                                <div class="invalid-feedback">
                                    Por favor ingrese una contraseña.
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="confirmPassword" class="form-label">Confirmar contraseña *</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                                <div class="invalid-feedback">
                                    Las contraseñas no coinciden.
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="telefono" class="form-label">Teléfono</label>
                                <input type="tel" class="form-control" id="telefono" name="telefono">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="rol" class="form-label">Rol *</label>
                                <select class="form-select" id="rol" name="rol" required>
                                    <option value="">Seleccionar rol</option>
                                    <% for (Map<String, Object> rol : roles) { %>
                                        <option value="<%= rol.get("id") %>"><%= rol.get("nombre") %></option>
                                    <% } %>
                                </select>
                                <div class="invalid-feedback">
                                    Por favor seleccione un rol.
                                </div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="direccion" class="form-label">Dirección</label>
                            <textarea class="form-control" id="direccion" name="direccion" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary">Crear Usuario</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Editar Usuario -->
    <div class="modal fade" id="modalEditarUsuario" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Editar Usuario</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="formEditarUsuario" class="needs-validation" novalidate>
                    <input type="hidden" id="editId" name="id">
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="editNombre" class="form-label">Nombre completo *</label>
                                <input type="text" class="form-control" id="editNombre" name="nombre" required>
                                <div class="invalid-feedback">
                                    Por favor ingrese el nombre completo.
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="editCorreo" class="form-label">Correo electrónico *</label>
                                <input type="email" class="form-control" id="editCorreo" name="correo" required>
                                <div class="invalid-feedback">
                                    Por favor ingrese un correo válido.
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="editTelefono" class="form-label">Teléfono</label>
                                <input type="tel" class="form-control" id="editTelefono" name="telefono">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="editRol" class="form-label">Rol *</label>
                                <select class="form-select" id="editRol" name="rol" required>
                                    <option value="">Seleccionar rol</option>
                                    <% for (Map<String, Object> rol : roles) { %>
                                        <option value="<%= rol.get("id") %>"><%= rol.get("nombre") %></option>
                                    <% } %>
                                </select>
                                <div class="invalid-feedback">
                                    Por favor seleccione un rol.
                                </div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="editDireccion" class="form-label">Dirección</label>
                            <textarea class="form-control" id="editDireccion" name="direccion" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="admin-scripts.js"></script>
    
    <script>
        // Búsqueda en tiempo real
        document.getElementById('searchUsuarios').addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const rows = document.querySelectorAll('#tablaUsuarios tbody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });
        
        // Filtro por rol
        document.getElementById('filterRol').addEventListener('change', function() {
            const selectedRol = this.value;
            const rows = document.querySelectorAll('#tablaUsuarios tbody tr');
            
            rows.forEach(row => {
                if (!selectedRol || row.children[4].textContent.includes(selectedRol)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
        
        // Validación de contraseñas
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (password !== confirmPassword) {
                this.setCustomValidity('Las contraseñas no coinciden');
            } else {
                this.setCustomValidity('');
            }
        });
        
        // Crear nuevo usuario
        document.getElementById('formNuevoUsuario').addEventListener('submit', function(e) {
            e.preventDefault();
            
            if (this.checkValidity()) {
                const formData = new FormData(this);
                
                fetch('crear-usuario.jsp', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('Usuario creado exitosamente', 'success');
                        location.reload();
                    } else {
                        showNotification(data.message || 'Error al crear usuario', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showNotification('Error al crear usuario', 'error');
                });
            }
            
            this.classList.add('was-validated');
        });
        
        // Editar usuario
        function editarUsuario(id) {
            // Aquí se cargarían los datos del usuario en el modal
            // Por ahora solo se muestra el modal
            const modal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
            modal.show();
        }
        
        // Eliminar usuario
        function eliminarUsuario(id) {
            if (confirm('¿Está seguro de que desea eliminar este usuario?')) {
                fetch('eliminar-usuario.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ id: id })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('Usuario eliminado exitosamente', 'success');
                        location.reload();
                    } else {
                        showNotification(data.message || 'Error al eliminar usuario', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showNotification('Error al eliminar usuario', 'error');
                });
            }
        }
        
        // Exportar usuarios
        function exportarUsuarios() {
            exportCSV('tablaUsuarios', 'usuarios-export.csv');
        }
    </script>
</body>
</html>
