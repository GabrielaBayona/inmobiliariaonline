<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>

<%
    // Validación: usuario autenticado y rol = inmobiliaria
    if (session == null || session.getAttribute("usuario_id") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
    if (rolId == null || rolId != 3) {  // 3 = Inmobiliaria
        response.sendRedirect("../login.jsp");
        return;
    }

    int usuarioId = (Integer) session.getAttribute("usuario_id");

    // Obtener datos del formulario
    request.setCharacterEncoding("UTF-8");
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String tipo = request.getParameter("tipo");
    String estado = request.getParameter("estado");
    String ubicacion = request.getParameter("ubicacion");
    String precioStr = request.getParameter("precio");

    if (titulo == null || titulo.isEmpty() || tipo == null || tipo.isEmpty() 
        || estado == null || estado.isEmpty() || ubicacion == null || ubicacion.isEmpty()
        || precioStr == null || precioStr.isEmpty()) {
        response.sendRedirect("agregarPropiedad.jsp?error=campos");
        return;
    }

    BigDecimal precio = null;
    try {
        precio = new BigDecimal(precioStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("agregarPropiedad.jsp?error=precio");
        return;
    }

    // Insertar propiedad en la base de datos
    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inmobiliaria_db","root","")) {
        String sql = "INSERT INTO propiedades (titulo, descripcion, precio, tipo, estado, ubicacion, inmobiliaria_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, titulo);
        ps.setString(2, descripcion);
        ps.setBigDecimal(3, precio);
        ps.setString(4, tipo);
        ps.setString(5, estado);
        ps.setString(6, ubicacion);
        ps.setInt(7, usuarioId);

        int filas = ps.executeUpdate();
        ps.close();

        if (filas > 0) {
            response.sendRedirect("propiedades.jsp?success=propiedad_agregada");
        } else {
            response.sendRedirect("agregarPropiedad.jsp?error=insertar");
        }
    } catch (SQLException e) {
        System.err.println("Error al agregar propiedad: " + e.getMessage());
        response.sendRedirect("agregarPropiedad.jsp?error=sql");
    }
%>
