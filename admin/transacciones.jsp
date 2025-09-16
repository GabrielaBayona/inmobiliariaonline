<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String adminName = AdminAuth.getAdminName(session);

    // Manejar cambio de estado vía parámetros GET y guardar en BD
    String cambioIdStr = request.getParameter("id");
    String nuevoEstado = request.getParameter("estado");
    if (cambioIdStr != null && nuevoEstado != null) {
        try (Connection conn = ConexionDB.getConnection()) {
            int cambioId = Integer.parseInt(cambioIdStr);
            String updateSql = "UPDATE transacciones SET estado = ? WHERE id_transaccion = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, nuevoEstado);
                ps.setInt(2, cambioId);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error al actualizar estado: " + e.getMessage() + "</div>");
        }
    }

    // Lista de transacciones
    List<Map<String, Object>> transacciones = new ArrayList<>();
    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "SELECT t.id_transaccion, u.nombre AS cliente, p.titulo AS propiedad, " +
                     "t.tipo, t.fecha, t.monto, t.estado " +
                     "FROM transacciones t " +
                     "INNER JOIN usuarios u ON t.cliente_id = u.id_usuario " +
                     "INNER JOIN propiedades p ON t.propiedad_id = p.id_propiedad " +
                     "ORDER BY t.fecha DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> trans = new HashMap<>();
                int id = rs.getInt("id_transaccion");
                trans.put("id_transaccion", id);
                trans.put("cliente", rs.getString("cliente"));
                trans.put("propiedad", rs.getString("propiedad"));
                trans.put("tipo", rs.getString("tipo"));
                trans.put("fecha", rs.getTimestamp("fecha"));
                trans.put("monto", rs.getBigDecimal("monto"));
                trans.put("estado", rs.getString("estado"));
                transacciones.add(trans);
            }
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar transacciones: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Gestión de Transacciones - InmoConnect</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="admin-styles.css" rel="stylesheet">
</head>
<body>
<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand" href="#"><i class="fas fa-building me-2"></i>InmoConnect Admin</a>
        <div class="navbar-nav ms-auto">
            <div class="nav-item dropdown">
                <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                    <i class="fas fa-user-circle me-1"></i><%= adminName %>
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
                    <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="usuarios.jsp"><i class="fas fa-users me-2"></i>Gestión de Usuarios</a></li>
                    <li class="nav-item"><a class="nav-link" href="propiedades.jsp"><i class="fas fa-home me-2"></i>Gestión de Propiedades</a></li>
                    <li class="nav-item"><a class="nav-link" href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Gestión de Citas</a></li>
                    <li class="nav-item"><a class="nav-link active" href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a></li>
                </ul>
            </div>
        </nav>

        <!-- Main -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Gestión de Transacciones</h1>
            </div>

            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Listado de Transacciones</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
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
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (transacciones.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted">No hay transacciones registradas</td>
                                    </tr>
                                <% } else {
                                    for (Map<String, Object> trans : transacciones) {
                                        String estado = (String) trans.get("estado");
                                        String colorEstado = "secondary";
                                        if ("verificar".equals(estado)) colorEstado = "warning";
                                        else if ("demorada".equals(estado)) colorEstado = "danger";
                                        else if ("pagada".equals(estado)) colorEstado = "success";
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
                                            <a href="transacciones.jsp?id=<%= trans.get("id_transaccion") %>&estado=verificar" class="btn btn-sm btn-warning me-1">
                                                <i class="fas fa-exclamation-circle"></i> Verificar
                                            </a>
                                            <a href="transacciones.jsp?id=<%= trans.get("id_transaccion") %>&estado=demorada" class="btn btn-sm btn-danger me-1">
                                                <i class="fas fa-times-circle"></i> Demorada
                                            </a>
                                            <a href="transacciones.jsp?id=<%= trans.get("id_transaccion") %>&estado=pagada" class="btn btn-sm btn-success">
                                                <i class="fas fa-check-circle"></i> Pagada
                                            </a>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
