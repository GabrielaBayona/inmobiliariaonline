<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // Validación: usuario autenticado y rol = inmobiliaria
    if (session == null || session.getAttribute("usuario_id") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
    if (rolId == null || rolId != 3) {  // 3 = Inmobiliaria
        response.sendRedirect("../login.jsp");
        return;
    }

    String nombreUsuario = (String) session.getAttribute("usuario_nombre");
    int usuarioId = (Integer) session.getAttribute("usuario_id");

    // Lista de propiedades de la inmobiliaria logueada
    List<Map<String, Object>> propiedades = new ArrayList<>();
    try (Connection con = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M")) {
        String sql = "SELECT id_propiedad, titulo, descripcion, precio, tipo, ubicacion, estado FROM propiedades WHERE inmobiliaria_id = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, usuarioId);
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
            propiedades.add(propiedad);
        }
        rs.close();
        ps.close();
    } catch(SQLException e) {
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mis Propiedades - InmoConnect</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    body { background: #f8f9fa; font-family: Arial, sans-serif; }
    .sidebar { background: #2c3e50; color: white; position: fixed; top:0; left:0; width:250px; height:100vh; }
    .sidebar a { color: rgba(255,255,255,0.8); display:block; padding:15px; text-decoration:none; }
    .sidebar a:hover { background: rgba(255,255,255,0.1); color:white; }
    .main-content { margin-left:250px; padding:20px; }
    .card-propiedad { border-radius:10px; box-shadow:0 3px 6px rgba(0,0,0,0.1); transition: transform 0.2s; }
    .card-propiedad:hover { transform: translateY(-5px); }
    .badge { font-size: 0.85rem; }
</style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <h3 class="text-center py-3"><i class="fas fa-building me-2"></i>InmoConnect</h3>
        <a href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
        <a href="propiedades.jsp" class="active"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
        <a href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Citas</a>
        <a href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
        <a href="perfil.jsp"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
        <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Mis Propiedades</h2>
            <a href="agregarPropiedad.jsp" class="btn btn-success">
                <i class="fas fa-plus me-1"></i>Agregar Propiedad
            </a>
        </div>

        <div class="row">
            <% if (propiedades.isEmpty()) { %>
                <div class="col-12 text-center text-muted">
                    <h5>No tienes propiedades registradas</h5>
                </div>
            <% } else {
                for (Map<String,Object> propiedad : propiedades) {
                    String tipo = (String) propiedad.get("tipo");
                    String estado = (String) propiedad.get("estado");

                    String tipoColor = "info";
                    if ("venta".equals(tipo)) tipoColor = "success";

                    String estadoColor = "secondary";
                    String estadoTexto = "Otro";
                    if ("disponible".equals(estado)) { estadoColor="success"; estadoTexto="Disponible"; }
                    else if ("vendida".equals(estado)) { estadoColor="danger"; estadoTexto="Vendida"; }
                    else if ("alquilada".equals(estado)) { estadoColor="warning"; estadoTexto="Alquilada"; }
            %>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card card-propiedad p-3 h-100">
                    <h5><%= propiedad.get("titulo") %></h5>
                    <p style="white-space: pre-wrap;"><%= propiedad.get("descripcion") %></p>
                    <div class="mb-2">
                        <span class="badge bg-<%= tipoColor %>"><%= tipo %></span>
                        <span class="badge bg-<%= estadoColor %>"><%= estadoTexto %></span>
                    </div>
                    <p><strong>Ubicación:</strong> <%= propiedad.get("ubicacion") %></p>
                    <p><strong>Precio:</strong> $<%= String.format("%,.0f", (BigDecimal) propiedad.get("precio")) %></p>
                    <div class="d-flex justify-content-between">
                        <form action="editarPropiedad.jsp" method="get">
                            <input type="hidden" name="id_propiedad" value="<%= propiedad.get("id_propiedad") %>">
                            <button class="btn btn-warning btn-sm"><i class="fas fa-edit"></i> Editar</button>
                        </form>
                        <form action="eliminarPropiedad.jsp" method="post">
                            <input type="hidden" name="id_propiedad" value="<%= propiedad.get("id_propiedad") %>">
                            <button class="btn btn-danger btn-sm"><i class="fas fa-trash-alt"></i> Eliminar</button>
                        </form>
                    </div>
                </div>
            </div>
            <% } } %>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
    