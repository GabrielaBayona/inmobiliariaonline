<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // Verificar sesión
    Integer idUsuario = (Integer) session.getAttribute("usuario_id");
    if (idUsuario == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String idCitaParam = request.getParameter("id");

    if (idCitaParam != null) {
        int idCita = Integer.parseInt(idCitaParam);

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");

            String sql = "DELETE FROM citas WHERE id_cita=? AND cliente_id=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();

            // Redirigir directo a citas.jsp
            response.sendRedirect("citas.jsp");
            return;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    } else {
        // Si no llega id, regresar al listado
        response.sendRedirect("citas.jsp");
    }
%>
