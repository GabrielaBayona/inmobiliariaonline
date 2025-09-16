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
    int idCita = Integer.parseInt(request.getParameter("id"));

    try (Connection conn = ConexionDB.getConnection()) {
        String sql = "UPDATE citas SET estado = 'cancelada' WHERE id_cita = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            int filas = ps.executeUpdate();

            if (filas > 0) {
                response.sendRedirect("citas.jsp?msg=cancel_ok");
            } else {
                response.sendRedirect("citas.jsp?msg=cancel_error");
            }
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cancelar cita: " + e.getMessage() + "</div>");
    }
%>
