<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    // Validar sesión de administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    // Capturar parámetros del formulario
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String precioStr = request.getParameter("precio");
    String tipo = request.getParameter("tipo");
    String estado = request.getParameter("estado");
    String ubicacion = request.getParameter("ubicacion");
    String inmobiliariaIdStr = request.getParameter("inmobiliaria_id");

    boolean exito = false;
    String mensaje = "";

    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "INSERT INTO propiedades (titulo, descripcion, precio, tipo, estado, ubicacion, inmobiliaria_id) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, titulo);
            stmt.setString(2, descripcion);
            stmt.setBigDecimal(3, new java.math.BigDecimal(precioStr));
            stmt.setString(4, tipo);
            stmt.setString(5, estado);
            stmt.setString(6, ubicacion);
            stmt.setInt(7, Integer.parseInt(inmobiliariaIdStr));

            int filas = stmt.executeUpdate();
            if (filas > 0) {
                exito = true;
                mensaje = "Propiedad registrada exitosamente.";
            } else {
                mensaje = "No se pudo registrar la propiedad.";
            }
        }
    } catch (Exception e) {
        mensaje = "Error al registrar propiedad: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Procesar Propiedad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container mt-5">
    <div class="card shadow">
        <div class="card-body text-center">
            <% if (exito) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle me-2"></i> <%= mensaje %>
                </div>
                <a href="propiedades.jsp" class="btn btn-primary">Volver al listado</a>
            <% } else { %>
                <div class="alert alert-danger">
                    <i class="fas fa-times-circle me-2"></i> <%= mensaje %>
                </div>
                <a href="agregarPropiedad.jsp" class="btn btn-secondary">Volver al formulario</a>
            <% } %>
        </div>
    </div>
</div>

<script src="https://kit.fontawesome.com/a2e0e9a65b.js" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
