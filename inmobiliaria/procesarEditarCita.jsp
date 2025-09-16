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
    if (rolId == null || rolId != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int usuarioId = (Integer) session.getAttribute("usuario_id");

    // Obtener datos del formulario
    String idCitaStr = request.getParameter("id_cita");
    String fecha = request.getParameter("fecha");
    String hora = request.getParameter("hora");
    String estado = request.getParameter("estado");

    if (idCitaStr == null || fecha == null || hora == null || estado == null ||
        idCitaStr.isEmpty() || fecha.isEmpty() || hora.isEmpty() || estado.isEmpty()) {
        response.sendRedirect("citas.jsp?error=datos_incompletos");
        return;
    }

    int idCita = Integer.parseInt(idCitaStr);

    try (Connection con = ConexionDB.getConnection()) {
        // Verificar que la cita pertenece a la inmobiliaria
        String sqlCheck = "SELECT c.id_cita FROM citas c " +
                          "INNER JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
                          "WHERE c.id_cita=? AND p.inmobiliaria_id=?";
        PreparedStatement psCheck = con.prepareStatement(sqlCheck);
        psCheck.setInt(1, idCita);
        psCheck.setInt(2, usuarioId);
        ResultSet rs = psCheck.executeQuery();
        if (!rs.next()) {
            rs.close();
            psCheck.close();
            response.sendRedirect("citas.jsp?error=no_autorizado");
            return;
        }
        rs.close();
        psCheck.close();

        // Actualizar cita
        String sqlUpdate = "UPDATE citas SET fecha=?, hora=?, estado=? WHERE id_cita=?";
        PreparedStatement psUpdate = con.prepareStatement(sqlUpdate);
        psUpdate.setDate(1, java.sql.Date.valueOf(fecha));
        psUpdate.setTime(2, java.sql.Time.valueOf(hora + ":00")); // segundos
        psUpdate.setString(3, estado);
        psUpdate.setInt(4, idCita);

        int filas = psUpdate.executeUpdate();
        psUpdate.close();

        if (filas > 0) {
            response.sendRedirect("citas.jsp?msg=edit_ok");
        } else {
            response.sendRedirect("citas.jsp?msg=edit_error");
        }
    } catch (SQLException e) {
        response.sendRedirect("citas.jsp?error=" + e.getMessage());
    }
%>
