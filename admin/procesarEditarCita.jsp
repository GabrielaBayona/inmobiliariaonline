<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    int idCita = Integer.parseInt(request.getParameter("id_cita"));
    String nuevoEstado = request.getParameter("estado");

    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "UPDATE citas SET estado = ? WHERE id_cita = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);
            int filas = ps.executeUpdate();

            if (filas > 0) {
                response.sendRedirect("citas.jsp?msg=edit_ok");
            } else {
                response.sendRedirect("citas.jsp?msg=edit_error");
            }
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al actualizar cita: " + e.getMessage() + "</div>");
    }
%>
