<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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

    // Obtener datos del formulario
    String idPropiedadStr = request.getParameter("id_propiedad");
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String precioStr = request.getParameter("precio");
    String tipo = request.getParameter("tipo");
    String estado = request.getParameter("estado");
    String ubicacion = request.getParameter("ubicacion");

    if (idPropiedadStr == null || titulo == null || precioStr == null || tipo == null || estado == null || ubicacion == null) {
        response.sendRedirect("propiedades.jsp?error=campos_vacios");
        return;
    }

    int idPropiedad = Integer.parseInt(idPropiedadStr);
    java.math.BigDecimal precio = new java.math.BigDecimal(precioStr);

    // Actualizar propiedad en la base de datos
    try (Connection con = ConexionDB.getConnection()) {
        String sql = "UPDATE propiedades SET titulo=?, descripcion=?, precio=?, tipo=?, estado=?, ubicacion=? " +
                     "WHERE id_propiedad=? AND inmobiliaria_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, titulo);
        ps.setString(2, descripcion);
        ps.setBigDecimal(3, precio);
        ps.setString(4, tipo);
        ps.setString(5, estado);
        ps.setString(6, ubicacion);
        ps.setInt(7, idPropiedad);
        ps.setInt(8, usuarioId); // asegura que solo se edite propiedad de la inmobiliaria logueada

        int filas = ps.executeUpdate();
        ps.close();

        if (filas > 0) {
            response.sendRedirect("propiedades.jsp?success=editado");
        } else {
            response.sendRedirect("propiedades.jsp?error=no_actualizado");
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al actualizar: " + e.getMessage() + "</div>");
    }
%>
