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

    String idPropiedadStr = request.getParameter("id_propiedad");
    if (idPropiedadStr == null || idPropiedadStr.isEmpty()) {
        response.sendRedirect("propiedades.jsp?error=id_invalido");
        return;
    }

    int idPropiedad = Integer.parseInt(idPropiedadStr);

    try (Connection con = ConexionDB.getConnection()) {
        String sql = "DELETE FROM propiedades WHERE id_propiedad=? AND inmobiliaria_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, idPropiedad);
        ps.setInt(2, usuarioId); // Solo permite eliminar propiedades propias

        int filas = ps.executeUpdate();
        ps.close();

        if (filas > 0) {
            response.sendRedirect("propiedades.jsp?success=eliminado");
        } else {
            response.sendRedirect("propiedades.jsp?error=no_encontrado");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("propiedades.jsp?error=" + e.getMessage());
    }
%>
