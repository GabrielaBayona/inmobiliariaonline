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

    // Lista de transacciones
    List<Map<String, Object>> transacciones = new ArrayList<>();
    double totalIngresos = 0;
    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "SELECT t.id_transaccion, u.nombre AS cliente, p.titulo AS propiedad, " +
                     "t.tipo, t.fecha, t.monto, t.estado " +
                     "FROM transacciones t " +
                     "INNER JOIN usuarios u ON t.cliente_id = u.id_usuario " +
                     "INNER JOIN propiedades p ON t.propiedad_id = p.id_propiedad " +
                     "WHERE p.inmobiliaria_id=? " +
                     "ORDER BY t.fecha DESC";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, usuarioId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> trans = new HashMap<>();
            trans.put("id_transaccion", rs.getInt("id_transaccion"));
            trans.put("cliente", rs.getString("cliente"));
            trans.put("propiedad", rs.getString("propiedad"));
            trans.put("tipo", rs.getString("tipo"));
            trans.put("fecha", rs.getTimestamp("fecha"));
            trans.put("monto", rs.getBigDecimal("monto"));
            trans.put("estado", rs.getString("estado"));
            transacciones.add(trans);

            totalIngresos += rs.getBigDecimal("monto").doubleValue();
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar transacciones: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Transacciones - InmoConnect</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    body { background: #f8f9fa; font-family: Arial, sans-serif; }
    .sidebar { background: #2c3e50; color: white; position: fixed; top:0; left:0; width:250px; height:100vh; }
    .sidebar a { color: rgba(255,255,255,0.8); display:block; padding:15px; text-decoration:none; }
    .sidebar a:hover { background: rgba(255,255,255,0.1); color:white; }
    .main-content { margin-left:250px; padding:20px; }
    .card-header .badge { font-size: 1rem; }
</style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <h3 class="text-center py-3"><i class="fas fa-building me-2"></i>InmoConnect</h3>
    <a href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
    <a href="propiedades.jsp"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
    <a href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Mis Citas</a>
    <a href="transacciones.jsp" class="active"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
    <a href="perfil.jsp"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
    <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
</div>

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Transacciones</h2>
    </div>

    <!-- Cuadro de ingresos -->
    <div class="mb-4">
        <div class="card shadow-sm">
            <div class="card-body d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-dollar-sign me-2"></i>Ingresos Totales</h5>
                <span class="badge bg-success fs-5">$<%= String.format("%,.2f", totalIngresos) %></span>
            </div>
        </div>
    </div>

    <!-- Tabla de transacciones -->
    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0"><i class="fas fa-money-bill-wave me-2"></i>Listado de Transacciones</h5>
        </div>
        <div class="card-body table-responsive">
            <table class="table table-bordered align-middle text-center">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Propiedad</th>
                        <th>Tipo</th>
                        <th>Fecha</th>
                        <th>Monto</th>
                        <th>Estado</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (transacciones.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="text-center text-muted">No hay transacciones registradas</td>
                        </tr>
                    <% } else {
                        for (Map<String, Object> trans : transacciones) {
                            String estado = (String) trans.get("estado");
                            String colorEstado = "secondary";
                            if ("pendiente".equals(estado)) colorEstado = "warning";
                            else if ("pagada".equals(estado)) colorEstado = "success";
                            else if ("demorada".equals(estado)) colorEstado = "danger";
                            else if ("verificar".equals(estado)) colorEstado = "info";
                    %>
                    <tr>
                        <td><%= trans.get("id_transaccion") %></td>
                        <td><%= trans.get("cliente") %></td>
                        <td><%= trans.get("propiedad") %></td>
                        <td><%= trans.get("tipo") %></td>
                        <td><%= trans.get("fecha") %></td>
                        <td>$<%= trans.get("monto") %></td>
                        <td><span class="badge bg-<%= colorEstado %>"><%= estado %></span></td>
                        <td>
                            <a href="editarTransaccion.jsp?id=<%= trans.get("id_transaccion") %>" class="btn btn-sm btn-warning">
                                <i class="fas fa-edit me-1"></i>Editar
                            </a>
                        </td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>

            <!-- Botón Añadir Transacción -->
            <div class="mt-3 text-end">
                <a href="agregarTransaccion.jsp" class="btn btn-primary">
                    <i class="fas fa-plus-circle me-2"></i>Añadir Transacción
                </a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
