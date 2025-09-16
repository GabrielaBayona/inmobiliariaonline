<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>

<%
    // Verificar sesión de administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    // Obtener parámetros del formulario
    String idPropiedadStr = request.getParameter("id_propiedad");
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String precioStr = request.getParameter("precio");
    String tipo = request.getParameter("tipo");
    String ubicacion = request.getParameter("ubicacion");
    String estado = request.getParameter("estado");
    String inmobiliariaIdStr = request.getParameter("inmobiliaria_id");

    if (idPropiedadStr == null || titulo == null || precioStr == null || tipo == null || ubicacion == null || estado == null || inmobiliariaIdStr == null) {
        response.sendRedirect("propiedades.jsp?error=faltan_datos");
        return;
    }

    int idPropiedad = Integer.parseInt(idPropiedadStr);
    double precio = Double.parseDouble(precioStr);
    int inmobiliariaId = Integer.parseInt(inmobiliariaIdStr);

    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "UPDATE propiedades SET titulo = ?, descripcion = ?, precio = ?, tipo = ?, ubicacion = ?, estado = ?, inmobiliaria_id = ? WHERE id_propiedad = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setDouble(3, precio);
            ps.setString(4, tipo);
            ps.setString(5, ubicacion);
            ps.setString(6, estado);
            ps.setInt(7, inmobiliariaId);
            ps.setInt(8, idPropiedad);

            int filas = ps.executeUpdate();
            if (filas > 0) {
                response.sendRedirect("propiedades.jsp?success=editado");
            } else {
                response.sendRedirect("propiedades.jsp?error=no_editado");
            }
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>
