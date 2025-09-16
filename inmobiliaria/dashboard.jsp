<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
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

    // Estadísticas
    int totalPropiedades = 0;
    int totalCitas = 0;
    double totalTransacciones = 0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm";
        String user = "ugpnqduxkl6tu1pg";
        String pass = "0mRih6Kppo5IdNtaLq1M";

        conn = DriverManager.getConnection(url, user, pass);

        // Total propiedades
        String sqlPropiedades = "SELECT COUNT(*) AS total FROM propiedades WHERE inmobiliaria_id = ?";
        pstmt = conn.prepareStatement(sqlPropiedades);
        pstmt.setInt(1, usuarioId);
        rs = pstmt.executeQuery();
        if (rs.next()) totalPropiedades = rs.getInt("total");
        rs.close(); pstmt.close();

        // Total citas
        String sqlCitas = "SELECT COUNT(*) AS total FROM citas c " +
                          "JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
                          "WHERE p.inmobiliaria_id = ?";
        pstmt = conn.prepareStatement(sqlCitas);
        pstmt.setInt(1, usuarioId);
        rs = pstmt.executeQuery();
        if (rs.next()) totalCitas = rs.getInt("total");
        rs.close(); pstmt.close();

        // Total transacciones
        String sqlTransaccionesTotal = "SELECT SUM(t.monto) AS total FROM transacciones t " +
                                       "JOIN propiedades p ON t.propiedad_id = p.id_propiedad " +
                                       "WHERE p.inmobiliaria_id = ?";
        pstmt = conn.prepareStatement(sqlTransaccionesTotal);
        pstmt.setInt(1, usuarioId);
        rs = pstmt.executeQuery();
        if (rs.next()) totalTransacciones = rs.getDouble("total");
        rs.close(); pstmt.close();

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Inmobiliaria - InmoConnect</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { font-family: Arial, sans-serif; background: #f8f9fa; }
        .sidebar { background: #2c3e50; color: white; position: fixed; top:0; left:0; width:250px; height:100vh; }
        .sidebar a { color: rgba(255,255,255,0.8); display:block; padding:15px; text-decoration:none; }
        .sidebar a:hover { background: rgba(255,255,255,0.1); color:white; }
        .main-content { margin-left:250px; padding:20px; }
        .card { border-radius:10px; box-shadow:0 3px 6px rgba(0,0,0,0.1); }
        .stat-number { font-size:2rem; font-weight:bold; }
        .activity-card { margin-bottom:10px; }
    </style>
</head>
<body>

<div class="sidebar">
    <h3 class="text-center py-3"><i class="fas fa-building me-2"></i>InmoConnect</h3>
    <a href="dashboard.jsp" class="active"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
    <a href="propiedades.jsp"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
    <a href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Citas</a>
    <a href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
    <a href="perfil.jsp"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
    <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
</div>

<div class="main-content">
    <h2>Bienvenido, <%= nombreUsuario %></h2>

    <!-- Tarjetas de estadísticas -->
    <div class="row mt-4">
        <div class="col-md-4 mb-3">
            <div class="card p-3 text-center">
                <i class="fas fa-home fa-2x text-primary mb-2"></i>
                <div class="stat-number"><%= totalPropiedades %></div>
                <div>Propiedades Registradas</div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card p-3 text-center">
                <i class="fas fa-calendar-check fa-2x text-success mb-2"></i>
                <div class="stat-number"><%= totalCitas %></div>
                <div>Citas Recibidas</div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card p-3 text-center">
                <i class="fas fa-money-bill-wave fa-2x text-warning mb-2"></i>
                <div class="stat-number">$<%= NumberFormat.getInstance(new Locale("es","CO")).format(totalTransacciones) %></div>
                <div>Total Ganado</div>
            </div>
        </div>
    </div>

    <!-- Actividad Reciente -->
    <div class="row mt-5">
        <div class="col-12">
            <h4>Actividad Reciente</h4>
            <div class="list-group">
                <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");
                        
                        // Últimas 5 transacciones
                        String sqlTransacciones = 
                            "SELECT t.fecha, t.monto, p.titulo AS propiedad, u.nombre AS cliente " +
                            "FROM transacciones t " +
                            "JOIN propiedades p ON t.propiedad_id = p.id_propiedad " +
                            "JOIN usuarios u ON t.cliente_id = u.id_usuario " +
                            "WHERE p.inmobiliaria_id = ? " +
                            "ORDER BY t.fecha DESC LIMIT 5";
                        pstmt = conn.prepareStatement(sqlTransacciones);
                        pstmt.setInt(1, usuarioId);
                        rs = pstmt.executeQuery();
                        while(rs.next()) {
                            String fecha = rs.getTimestamp("fecha").toString();
                            String propiedad = rs.getString("propiedad");
                            String cliente = rs.getString("cliente");
                            double monto = rs.getDouble("monto");
                %>
                            <div class="list-group-item d-flex justify-content-between align-items-center activity-card">
                                <div>
                                    <strong>Transacción:</strong> <%= propiedad %> <br>
                                    <small>Cliente: <%= cliente %> | Fecha: <%= fecha %></small>
                                </div>
                                <span class="badge bg-success rounded-pill">
                                    $<%= NumberFormat.getInstance(new Locale("es","CO")).format(monto) %>
                                </span>
                            </div>
                <%
                        }
                        rs.close(); pstmt.close();

                        // Últimas 5 citas
                        String sqlCitas = 
                            "SELECT c.fecha, c.hora, p.titulo AS propiedad, u.nombre AS cliente, c.estado " +
                            "FROM citas c " +
                            "JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
                            "JOIN usuarios u ON c.cliente_id = u.id_usuario " +
                            "WHERE p.inmobiliaria_id = ? " +
                            "ORDER BY c.fecha DESC, c.hora DESC LIMIT 5";
                        pstmt = conn.prepareStatement(sqlCitas);
                        pstmt.setInt(1, usuarioId);
                        rs = pstmt.executeQuery();
                        while(rs.next()) {
                            String fecha = rs.getDate("fecha").toString();
                            String hora = rs.getTime("hora").toString();
                            String propiedad = rs.getString("propiedad");
                            String cliente = rs.getString("cliente");
                            String estado = rs.getString("estado");
                %>
                            <div class="list-group-item d-flex justify-content-between align-items-center activity-card">
                                <div>
                                    <strong>Cita:</strong> <%= propiedad %> <br>
                                    <small>Cliente: <%= cliente %> | Fecha: <%= fecha %> <%= hora %></small>
                                </div>
                                <span class="badge <%= estado.equals("confirmada") ? "bg-success" : estado.equals("pendiente") ? "bg-warning" : "bg-danger" %> rounded-pill">
                                    <%= estado %>
                                </span>
                            </div>
                <%
                        }
                        rs.close(); pstmt.close();
                        conn.close();
                    } catch(Exception e) {
                        e.printStackTrace();
                    }
                %>
            </div>
        </div>
    </div>

</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>

</body>
</html>
