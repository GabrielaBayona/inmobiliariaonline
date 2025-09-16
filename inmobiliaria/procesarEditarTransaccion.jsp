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

    // Recibir parámetros del formulario
    String idTransStr = request.getParameter("id_transaccion");
    String clienteStr = request.getParameter("cliente_id");
    String propiedadStr = request.getParameter("propiedad_id");
    String tipo = request.getParameter("tipo");
    String fecha = request.getParameter("fecha");
    String montoStr = request.getParameter("monto");

    if (idTransStr == null || clienteStr == null || propiedadStr == null || tipo == null || fecha == null || montoStr == null) {
        response.sendRedirect("transacciones.jsp?error=parametros_invalidos");
        return;
    }

    int idTransaccion = Integer.parseInt(idTransStr);
    int clienteId = Integer.parseInt(clienteStr);
    int propiedadId = Integer.parseInt(propiedadStr);
    double monto = Double.parseDouble(montoStr);

    // Actualizar transacción en la base de datos
    try (Connection con = ConexionDB.getConnection()) {
        String sql = "UPDATE transacciones t " +
                     "INNER JOIN propiedades p ON t.propiedad_id = p.id_propiedad " +
                     "SET t.cliente_id=?, t.propiedad_id=?, t.tipo=?, t.fecha=?, t.monto=? " +
                     "WHERE t.id_transaccion=? AND p.inmobiliaria_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, clienteId);
        ps.setInt(2, propiedadId);
        ps.setString(3, tipo);
        ps.setDate(4, java.sql.Date.valueOf(fecha));
        ps.setDouble(5, monto);
        ps.setInt(6, idTransaccion);
        ps.setInt(7, usuarioId);

        int rows = ps.executeUpdate();
        ps.close();

        if (rows > 0) {
            response.sendRedirect("transacciones.jsp?msg=edit_success");
        } else {
            response.sendRedirect("transacciones.jsp?error=no_actualizado");
        }
    } catch (Exception e) {
        response.sendRedirect("transacciones.jsp?error=" + e.getMessage());
    }
%>
