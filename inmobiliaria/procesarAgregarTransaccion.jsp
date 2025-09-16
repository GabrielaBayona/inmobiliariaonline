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

    request.setCharacterEncoding("UTF-8");

    // Recibir datos del formulario
    int clienteId = Integer.parseInt(request.getParameter("cliente_id"));
    int propiedadId = Integer.parseInt(request.getParameter("propiedad_id"));
    String tipo = request.getParameter("tipo");
    String fecha = request.getParameter("fecha");
    double monto = Double.parseDouble(request.getParameter("monto"));
    String estado = request.getParameter("estado");

    try (Connection con = ConexionDB.getConnection()) {
        String sql = "INSERT INTO transacciones (cliente_id, propiedad_id, tipo, fecha, monto, estado) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, clienteId);
        ps.setInt(2, propiedadId);
        ps.setString(3, tipo);
        ps.setDate(4, java.sql.Date.valueOf(fecha));
        ps.setBigDecimal(5, new java.math.BigDecimal(monto));
        ps.setString(6, estado);

        ps.executeUpdate();
        ps.close();

        response.sendRedirect("transacciones.jsp");
    } catch (SQLException e) {
        // Mostrar error en página
%>
<div class="alert alert-danger">
    <strong>Error al guardar la transacción:</strong> <%= e.getMessage() %>
</div>
<a href="agregarTransaccion.jsp" class="btn btn-secondary mt-2">Volver</a>
<%
    }
%>
