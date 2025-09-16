<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Verificar autenticación de administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String adminName = AdminAuth.getAdminName(session);

    // Lista de citas
    List<Map<String, Object>> citas = new ArrayList<>();

    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "SELECT c.id_cita, u.nombre AS cliente, p.titulo AS propiedad, c.fecha, c.hora, c.estado " +
                     "FROM citas c " +
                     "INNER JOIN usuarios u ON c.cliente_id = u.id_usuario " +
                     "INNER JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
                     "ORDER BY c.fecha DESC, c.hora DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
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
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar citas: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Citas - InmoConnect</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="admin-styles.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-building me-2"></i>InmoConnect Admin
            </a>
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
                        <li class="nav-item"><a class="nav-link active" href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Gestión de Citas</a></li>
                        <li class="nav-item"><a class="nav-link" href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a></li>
                    </ul>
                </div>
            </nav>

            <!-- Contenido -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Gestión de Citas</h1>
                </div>

                <!-- Tabla de Citas -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Listado de Citas Programadas</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
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
                                        for (Map<String, Object> cita : citas) {
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
            </main>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="admin-scripts.js"></script>
</body>
</html>
