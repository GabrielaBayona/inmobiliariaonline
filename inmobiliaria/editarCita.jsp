<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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

    // Obtener ID de la cita
    String idCitaStr = request.getParameter("id");
    if (idCitaStr == null) {
        response.sendRedirect("citas.jsp?error=no_id");
        return;
    }
    int idCita = Integer.parseInt(idCitaStr);

    // Obtener datos de la cita
    Map<String, Object> cita = new HashMap<>();
    try (Connection con = ConexionDB.getConnection()) {
        String sql = "SELECT c.id_cita, c.fecha, c.hora, c.estado, u.nombre AS cliente, p.titulo AS propiedad " +
                     "FROM citas c " +
                     "INNER JOIN usuarios u ON c.cliente_id = u.id_usuario " +
                     "INNER JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
                     "WHERE c.id_cita=? AND p.inmobiliaria_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, idCita);
        ps.setInt(2, usuarioId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            cita.put("id_cita", rs.getInt("id_cita"));
            cita.put("fecha", rs.getDate("fecha"));
            cita.put("hora", rs.getTime("hora"));
            cita.put("estado", rs.getString("estado"));
            cita.put("cliente", rs.getString("cliente"));
            cita.put("propiedad", rs.getString("propiedad"));
        } else {
            response.sendRedirect("citas.jsp?error=no_autorizado");
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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Editar Cita - InmoConnect</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    body { background: #f8f9fa; font-family: Arial, sans-serif; }
    .sidebar { background: #2c3e50; color: white; position: fixed; top:0; left:0; width:250px; height:100vh; }
    .sidebar a { color: rgba(255,255,255,0.8); display:block; padding:15px; text-decoration:none; }
    .sidebar a:hover { background: rgba(255,255,255,0.1); color:white; }
    .main-content { margin-left:250px; padding:20px; }
    .badge { font-size: 0.85rem; }
</style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <h3 class="text-center py-3"><i class="fas fa-building me-2"></i>InmoConnect</h3>
    <a href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
    <a href="propiedades.jsp"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
    <a href="citas.jsp" class="active"><i class="fas fa-calendar-check me-2"></i>Mis Citas</a>
    <a href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
    <a href="perfil.jsp"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
    <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
</div>

<!-- Contenido principal -->
<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Editar Cita</h2>
    </div>

    <div class="card shadow">
        <div class="card-header bg-warning text-dark">
            <h5 class="mb-0"><i class="fas fa-edit me-2"></i>Cita de <%= cita.get("cliente") %> - <%= cita.get("propiedad") %></h5>
        </div>
        <div class="card-body">
            <form method="post" action="procesarEditarCita.jsp" class="needs-validation" novalidate>
                <input type="hidden" name="id_cita" value="<%= cita.get("id_cita") %>">

                <div class="mb-3">
                    <label for="fecha" class="form-label">Fecha</label>
                    <input type="date" id="fecha" name="fecha" class="form-control" 
                           value="<%= cita.get("fecha") %>" required>
                    <div class="invalid-feedback">Ingrese una fecha válida.</div>
                </div>

                <div class="mb-3">
                    <label for="hora" class="form-label">Hora</label>
                    <input type="time" id="hora" name="hora" class="form-control" 
                           value="<%= cita.get("hora").toString().substring(0,5) %>" required>
                    <div class="invalid-feedback">Ingrese una hora válida.</div>
                </div>

                <div class="mb-3">
                    <label for="estado" class="form-label">Estado</label>
                    <select id="estado" name="estado" class="form-select" required>
                        <option value="pendiente" <%= "pendiente".equals(cita.get("estado")) ? "selected" : "" %>>Pendiente</option>
                        <option value="confirmada" <%= "confirmada".equals(cita.get("estado")) ? "selected" : "" %>>Confirmada</option>
                        <option value="cancelada" <%= "cancelada".equals(cita.get("estado")) ? "selected" : "" %>>Cancelada</option>
                    </select>
                    <div class="invalid-feedback">Seleccione un estado.</div>
                </div>

                <div class="text-end">
                    <a href="citas.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i>Cancelar</a>
                    <button type="submit" class="btn btn-warning"><i class="fas fa-save me-1"></i>Guardar Cambios</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function () {
    'use strict';
    const forms = document.querySelectorAll('.needs-validation');
    Array.from(forms).forEach(function(form){
        form.addEventListener('submit', function(event){
            if(!form.checkValidity()){
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
