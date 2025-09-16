<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String idPropiedadStr = request.getParameter("id_propiedad");

    if (idPropiedadStr != null && !idPropiedadStr.isEmpty()) {
        int idPropiedad = Integer.parseInt(idPropiedadStr);

        try (Connection con = ConexionDB.getConnection()) {
            String sql = "DELETE FROM propiedades WHERE id_propiedad = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, idPropiedad);

            int filas = ps.executeUpdate();

            if (filas > 0) {
                // Eliminación exitosa
                response.sendRedirect("propiedades.jsp?msg=eliminado");
            } else {
                response.sendRedirect("propiedades.jsp?error=no_encontrado");
            }

            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("propiedades.jsp?error=" + e.getMessage());
        }
    } else {
        response.sendRedirect("propiedades.jsp?error=id_invalido");
    }
%>
