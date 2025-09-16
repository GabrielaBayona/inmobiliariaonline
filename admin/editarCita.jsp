<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String adminName = AdminAuth.getAdminName(session);

    int idCita = Integer.parseInt(request.getParameter("id"));
    String estadoActual = "";

    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "SELECT estado FROM citas WHERE id_cita = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    estadoActual = rs.getString("estado");
                }
            }
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar cita: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Cita - InmoConnect Admin</title>
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
                        <i class="fas fa-user-circle me-1"></i><%= adminName %>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="perfil.jsp"><i class="fas fa-user me-2"></i>Mi Perfil</a></li>
                        <li><a class="dropdown-item" href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <!-- Contenido -->
    <div class="container mt-4">
        <div class="card shadow">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><i class="fas fa-edit me-2"></i>Editar Estado de la Cita</h5>
            </div>
            <div class="card-body">
                <form method="post" action="procesarEditarCita.jsp">
                    <input type="hidden" name="id_cita" value="<%= idCita %>">

                    <div class="mb-3">
                        <label for="estado" class="form-label">Estado *</label>
                        <select class="form-select" id="estado" name="estado" required>
                            <option value="pendiente" <%= "pendiente".equals(estadoActual) ? "selected" : "" %>>Pendiente</option>
                            <option value="confirmada" <%= "confirmada".equals(estadoActual) ? "selected" : "" %>>Confirmada</option>
                            <option value="cancelada" <%= "cancelada".equals(estadoActual) ? "selected" : "" %>>Cancelada</option>
                        </select>
                    </div>

                    <div class="text-end">
                        <a href="citas.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i>Cancelar</a>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i>Guardar Cambios</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
