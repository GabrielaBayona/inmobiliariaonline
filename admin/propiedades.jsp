<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String adminName = AdminAuth.getAdminName(session);

    // Lista de propiedades
    List<Map<String, Object>> propiedades = new ArrayList<>();

    try (Connection con = ConexionDB.getConnection()) {
        String sql = "SELECT id_propiedad, titulo, descripcion, precio, tipo, ubicacion, estado, inmobiliaria_id FROM propiedades";
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> propiedad = new HashMap<>();
            propiedad.put("id_propiedad", rs.getInt("id_propiedad"));
            propiedad.put("titulo", rs.getString("titulo"));
            propiedad.put("descripcion", rs.getString("descripcion"));
            propiedad.put("precio", rs.getBigDecimal("precio"));
            propiedad.put("tipo", rs.getString("tipo"));
            propiedad.put("ubicacion", rs.getString("ubicacion"));
            propiedad.put("estado", rs.getString("estado"));
            propiedad.put("inmobiliaria_id", rs.getInt("inmobiliaria_id"));

            propiedades.add(propiedad);
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
    <title>Gestión de Propiedades - InmoConnect</title>
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
                        <li class="nav-item"><a class="nav-link active" href="propiedades.jsp"><i class="fas fa-home me-2"></i>Gestión de Propiedades</a></li>
                        <li class="nav-item"><a class="nav-link" href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Gestión de Citas</a></li>
                        <li class="nav-item"><a class="nav-link" href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a></li>
                    </ul>
                </div>
            </nav>

            <!-- Contenido -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Gestión de Propiedades</h1>
                    <a href="agregarPropiedad.jsp" class="btn btn-success btn-sm">
                        <i class="fas fa-plus me-1"></i>Agregar Propiedad
                    </a>
                </div>

                <!-- Tabla de propiedades -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Listado de Propiedades</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle text-center">
                                <thead class="table-dark">
                                    <tr>
                                        <th>ID</th>
                                        <th>Título</th>
                                        <th>Descripción</th>
                                        <th>Precio</th>
                                        <th>Tipo</th>
                                        <th>Ubicación</th>
                                        <th>Estado</th>
                                        <th>Inmobiliaria ID</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (propiedades.isEmpty()) { %>
                                        <tr>
                                            <td colspan="9" class="text-center text-muted">No hay propiedades registradas</td>
                                        </tr>
                                    <% } else { 
                                        for (Map<String, Object> propiedad : propiedades) { 
                                            String tipo = (String) propiedad.get("tipo");
                                            String estado = (String) propiedad.get("estado");

                                            String tipoColor = "info";
                                            if ("venta".equals(tipo)) tipoColor = "success";

                                            String estadoColor = "secondary";
                                            String estadoTexto = "Otro";
                                            if ("disponible".equals(estado)) { estadoColor = "success"; estadoTexto = "Disponible"; }
                                            else if ("vendida".equals(estado)) { estadoColor = "danger"; estadoTexto = "Vendida"; }
                                            else if ("alquilada".equals(estado)) { estadoColor = "warning"; estadoTexto = "Alquilada"; }
                                    %>
                                            <tr>
                                                <td><%= propiedad.get("id_propiedad") %></td>
                                                <td><%= propiedad.get("titulo") %></td>
                                                <td style="white-space: pre-wrap;"><%= propiedad.get("descripcion") %></td>
                                                <td>$<%= String.format("%,.0f", (BigDecimal) propiedad.get("precio")) %></td>
                                                <td><span class="badge bg-<%= tipoColor %>"><%= tipo %></span></td>
                                                <td><%= propiedad.get("ubicacion") %></td>
                                                <td><span class="badge bg-<%= estadoColor %>"><%= estadoTexto %></span></td>
                                                <td><%= propiedad.get("inmobiliaria_id") %></td>
                                                <td>
                                                    <form action="eliminarPropiedad.jsp" method="post" style="display:inline;">
                                                        <input type="hidden" name="id_propiedad" value="<%= propiedad.get("id_propiedad") %>">
                                                        <button type="submit" class="btn btn-danger btn-sm">
                                                            <i class="fas fa-trash-alt"></i> Eliminar
                                                        </button>
                                                    </form>
                                                    <form action="editarPropiedad.jsp" method="get" style="display:inline;">
                                                        <input type="hidden" name="id_propiedad" value="<%= propiedad.get("id_propiedad") %>">
                                                        <button type="submit" class="btn btn-warning btn-sm">
                                                            <i class="fas fa-edit"></i> Editar
                                                        </button>
                                                    </form>
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
