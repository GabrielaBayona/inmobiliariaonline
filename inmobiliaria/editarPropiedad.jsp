<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>

<%
    // Validación: usuario autenticado y rol = inmobiliaria
    if (session == null || session.getAttribute("usuario_id") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
    if (rolId == null || rolId != 3) { // 3 = Inmobiliaria
        response.sendRedirect("../login.jsp");
        return;
    }

    int usuarioId = (Integer) session.getAttribute("usuario_id");
    String nombreUsuario = (String) session.getAttribute("usuario_nombre");

    // Obtener ID de la propiedad
    String idPropiedadStr = request.getParameter("id_propiedad");
    if (idPropiedadStr == null) {
        response.sendRedirect("propiedades.jsp?error=no_id");
        return;
    }

    int idPropiedad = Integer.parseInt(idPropiedadStr);

    // Datos de la propiedad
    Map<String, Object> propiedad = new HashMap<>();

    try (Connection con = ConexionDB.getConnection()) {
        String sql = "SELECT id_propiedad, titulo, descripcion, precio, tipo, estado, ubicacion, inmobiliaria_id " +
                     "FROM propiedades WHERE id_propiedad=? AND inmobiliaria_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, idPropiedad);
        ps.setInt(2, usuarioId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            propiedad.put("id_propiedad", rs.getInt("id_propiedad"));
            propiedad.put("titulo", rs.getString("titulo"));
            propiedad.put("descripcion", rs.getString("descripcion"));
            propiedad.put("precio", rs.getBigDecimal("precio"));
            propiedad.put("tipo", rs.getString("tipo"));
            propiedad.put("estado", rs.getString("estado"));
            propiedad.put("ubicacion", rs.getString("ubicacion"));
            propiedad.put("inmobiliaria_id", rs.getInt("inmobiliaria_id"));
        } else {
            response.sendRedirect("propiedades.jsp?error=no_exist");
            return;
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Propiedad - InmoConnect</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="dashboard.jsp">
                <i class="fas fa-building me-2"></i>InmoConnect
            </a>
            <div class="navbar-nav ms-auto">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i> <%= nombreUsuario %>
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
            <div class="card-header bg-warning text-dark">
                <h5 class="mb-0"><i class="fas fa-edit me-2"></i>Editar Propiedad</h5>
            </div>
            <div class="card-body">
                <form id="formEditarPropiedad" class="needs-validation" method="post" action="procesarEditarPropiedad.jsp" novalidate>
                    <input type="hidden" name="id_propiedad" value="<%= propiedad.get("id_propiedad") %>">

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="titulo" class="form-label">Título *</label>
                            <input type="text" class="form-control" id="titulo" name="titulo" value="<%= propiedad.get("titulo") %>" required>
                            <div class="invalid-feedback">Ingrese un título.</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="precio" class="form-label">Precio *</label>
                            <input type="number" step="0.01" class="form-control" id="precio" name="precio" value="<%= propiedad.get("precio") %>" required>
                            <div class="invalid-feedback">Ingrese un precio válido.</div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="descripcion" class="form-label">Descripción</label>
                        <textarea class="form-control" id="descripcion" name="descripcion" rows="3"><%= propiedad.get("descripcion") %></textarea>
                    </div>

                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label for="tipo" class="form-label">Tipo *</label>
                            <select class="form-select" id="tipo" name="tipo" required>
                                <option value="venta" <%= "venta".equals(propiedad.get("tipo")) ? "selected" : "" %>>Venta</option>
                                <option value="alquiler" <%= "alquiler".equals(propiedad.get("tipo")) ? "selected" : "" %>>Alquiler</option>
                            </select>
                            <div class="invalid-feedback">Seleccione un tipo.</div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="estado" class="form-label">Estado *</label>
                            <select class="form-select" id="estado" name="estado" required>
                                <option value="disponible" <%= "disponible".equals(propiedad.get("estado")) ? "selected" : "" %>>Disponible</option>
                                <option value="vendida" <%= "vendida".equals(propiedad.get("estado")) ? "selected" : "" %>>Vendida</option>
                                <option value="alquilada" <%= "alquilada".equals(propiedad.get("estado")) ? "selected" : "" %>>Alquilada</option>
                            </select>
                            <div class="invalid-feedback">Seleccione un estado.</div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="ubicacion" class="form-label">Ubicación *</label>
                            <input type="text" class="form-control" id="ubicacion" name="ubicacion" value="<%= propiedad.get("ubicacion") %>" required>
                            <div class="invalid-feedback">Ingrese una ubicación.</div>
                        </div>
                    </div>

                    <div class="text-end">
                        <a href="propiedades.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i>Cancelar</a>
                        <button type="submit" class="btn btn-warning"><i class="fas fa-save me-1"></i>Guardar Cambios</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
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
