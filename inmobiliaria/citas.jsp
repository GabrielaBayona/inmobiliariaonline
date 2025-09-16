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

    String nombreUsuario = (String) session.getAttribute("usuario_nombre");
    int usuarioId = (Integer) session.getAttribute("usuario_id");

    // Lista de citas para propiedades de la inmobiliaria logueada
    List<Map<String, Object>> citas = new ArrayList<>();
    try (Connection con = ConexionDB.getConnection()) {
        String sql = "SELECT c.id_cita, u.nombre AS cliente, p.titulo AS propiedad, c.fecha, c.hora, c.estado " +
                     "FROM citas c " +
                     "INNER JOIN usuarios u ON c.cliente_id = u.id_usuario " +
                     "INNER JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
                     "WHERE p.inmobiliaria_id = ? " +
                     "ORDER BY c.fecha DESC, c.hora DESC";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, usuarioId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> cita = new HashMap<>();
            cita.put("id_cita", rs.getInt("id_cita"));
            cita.put("cliente", rs.getString("cliente"));
            cita.put("propiedad", rs.getString("propiedad"));
            cita.put("fecha", rs.getDate("fecha"));
            cita.put("hora", rs.getTime("hora"));
            cita.put("estado", rs.getString("estado"));
            citas.add(cita);
        }
        rs.close();
        ps.close();
    } catch(SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar citas: "+e.getMessage()+"</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mis Citas - InmoConnect</title>
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

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Citas</h2>
        </div>

        <div class="card shadow">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><i class="fas fa-calendar-check me-2"></i>Listado de Citas</h5>
            </div>
            <div class="card-body table-responsive">
                <table class="table table-bordered align-middle text-center">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Cliente</th>
                            <th>Propiedad</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (citas.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="text-center text-muted">No hay citas programadas</td>
                            </tr>
                        <% } else {
                            for (Map<String,Object> cita : citas) {
                                String estado = (String) cita.get("estado");
                                String colorEstado = "secondary";
                                if ("confirmada".equals(estado)) colorEstado = "success";
                                else if ("pendiente".equals(estado)) colorEstado = "warning";
                                else if ("cancelada".equals(estado)) colorEstado = "danger";
                        %>
                        <tr>
                            <td><%= cita.get("id_cita") %></td>
                            <td><%= cita.get("cliente") %></td>
                            <td><%= cita.get("propiedad") %></td>
                            <td><%= cita.get("fecha") %></td>
                            <td><%= cita.get("hora") %></td>
                            <td><span class="badge bg-<%= colorEstado %>"><%= estado %></span></td>
                            <td>
                                <a href="editarCita.jsp?id=<%= cita.get("id_cita") %>" class="btn btn-sm btn-warning me-1">
                                    <i class="fas fa-edit"></i> Editar
                                </a>
                                <a href="cancelarCita.jsp?id=<%= cita.get("id_cita") %>" class="btn btn-sm btn-danger">
                                    <i class="fas fa-times"></i> Cancelar
                                </a>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
