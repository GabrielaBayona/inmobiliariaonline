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

        // Obtener lista de inmobiliarias (usuarios con rol inmobiliaria)
        List<Map<String, Object>> inmobiliarias = new ArrayList<>();
        try (Connection conn = ConexionDB.getConnection()) {
            String sql = "SELECT id_usuario, nombre FROM usuarios WHERE rol_id = 3 ORDER BY nombre"; // Asumiendo rol_id=2 es inmobiliaria
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> inmobiliaria = new HashMap<>();
                    inmobiliaria.put("id", rs.getInt("id_usuario"));
                    inmobiliaria.put("nombre", rs.getString("nombre"));
                    inmobiliarias.add(inmobiliaria);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener inmobiliarias: " + e.getMessage());
        }
    %>

    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Nueva Propiedad - InmoConnect Admin</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="admin-styles.css" rel="stylesheet">
    </head>
    <body>
        <!-- Navbar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <div class="container-fluid">
                <a class="navbar-brand" href="dashboard.jsp">
                    <i class="fas fa-building me-2"></i>InmoConnect Admin
                </a>
                <div class="navbar-nav ms-auto">
                    <div class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle me-1"></i> <%= adminName %>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="perfil.jsp"><i class="fas fa-user me-2"></i>Mi Perfil</a></li>
                            <li><a class="dropdown-item" href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Contenido principal -->
        <div class="container mt-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-home me-2"></i>Nueva Propiedad</h5>
                </div>
                <div class="card-body">
                    <form id="formNuevaPropiedad" class="needs-validation" method="post" action="procesarAgregarPropiedad.jsp" novalidate>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="titulo" class="form-label">Título *</label>
                                <input type="text" class="form-control" id="titulo" name="titulo" required>
                                <div class="invalid-feedback">Ingrese un título.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="precio" class="form-label">Precio *</label>
                                <input type="number" step="0.01" class="form-control" id="precio" name="precio" required>
                                <div class="invalid-feedback">Ingrese un precio válido.</div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="descripcion" class="form-label">Descripción</label>
                            <textarea class="form-control" id="descripcion" name="descripcion" rows="3"></textarea>
                        </div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label for="tipo" class="form-label">Tipo *</label>
                                <select class="form-select" id="tipo" name="tipo" required>
                                    <option value="">Seleccionar...</option>
                                    <option value="venta">Venta</option>
                                    <option value="alquiler">Alquiler</option>
                                </select>
                                <div class="invalid-feedback">Seleccione un tipo.</div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="estado" class="form-label">Estado *</label>
                                <select class="form-select" id="estado" name="estado" required>
                                    <option value="disponible">Disponible</option>
                                    <option value="vendida">Vendida</option>
                                    <option value="alquilada">Alquilada</option>
                                </select>
                                <div class="invalid-feedback">Seleccione un estado.</div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="inmobiliaria" class="form-label">Inmobiliaria *</label>
                                <select class="form-select" id="inmobiliaria" name="inmobiliaria_id" required>
                                    <option value="">Seleccionar...</option>
                                    <% for (Map<String, Object> inmo : inmobiliarias) { %>
                                        <option value="<%= inmo.get("id") %>"><%= inmo.get("nombre") %></option>
                                    <% } %>
                                </select>
                                <div class="invalid-feedback">Seleccione una inmobiliaria.</div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="ubicacion" class="form-label">Ubicación *</label>
                            <input type="text" class="form-control" id="ubicacion" name="ubicacion" required>
                            <div class="invalid-feedback">Ingrese una ubicación.</div>
                        </div>

                        <div class="text-end">
                            <a href="propiedades.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i>Cancelar</a>
                            <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i>Guardar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Bootstrap validation
            (function () {
                'use strict';
                const forms = document.querySelectorAll('.needs-validation');
                Array.from(forms).forEach(function (form) {
                    form.addEventListener('submit', function (event) {
                        if (!form.checkValidity()) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            })();
        </script>
    </body>
    </html>
