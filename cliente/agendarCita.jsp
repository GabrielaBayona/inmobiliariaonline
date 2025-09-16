<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // Verificar sesión
    Integer idUsuario = (Integer) session.getAttribute("usuario_id");
    if (idUsuario == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    // Capturar datos del formulario
    String propiedadId = request.getParameter("propiedad_id");
    String fecha = request.getParameter("fecha");
    String hora = request.getParameter("hora");

    // ⚠️ Aquí definimos la inmobiliaria por defecto.
    // Podrías mejorarlo para que venga de la propiedad.
    int inmobiliariaId = 1; // Asumimos que es el admin principal

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");

        String sql = "INSERT INTO citas (cliente_id, propiedad_id, inmobiliaria_id, fecha, hora, estado) " +
                     "VALUES (?, ?, ?, ?, ?, 'pendiente')";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, idUsuario);
        ps.setInt(2, Integer.parseInt(propiedadId));
        ps.setInt(3, inmobiliariaId);
        ps.setDate(4, java.sql.Date.valueOf(fecha));
        ps.setTime(5, java.sql.Time.valueOf(hora + ":00"));

        int filas = ps.executeUpdate();

        if (filas > 0) {
            // Redirigir a citas.jsp después de guardar
            response.sendRedirect("citas.jsp");
        } else {
            out.println("<script>alert('❌ No se pudo guardar la cita'); window.location='citas.jsp';</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('⚠️ Error: " + e.getMessage() + "'); window.location='citas.jsp';</script>");
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
