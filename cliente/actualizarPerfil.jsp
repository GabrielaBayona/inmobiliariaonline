    <%@ page contentType="text/html; charset=UTF-8" language="java" %>
    <%@ page import="java.sql.*" %>
    <%
        request.setCharacterEncoding("UTF-8");
        Integer idUsuario = (Integer) session.getAttribute("usuario_id");
        if (idUsuario == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String nuevoNombre = request.getParameter("nombre");
        String nuevaPassword = request.getParameter("password");

        Connection conn = null;
        PreparedStatement ps = null;
        boolean actualizado = false;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");

        StringBuilder sql = new StringBuilder("UPDATE usuarios SET ");
        boolean primero = true;

        if (nuevoNombre != null && !nuevoNombre.trim().isEmpty()) {
            sql.append("nombre = ?");
            primero = false;
        }

        if (nuevaPassword != null && !nuevaPassword.trim().isEmpty()) {
            if (!primero) sql.append(", ");
            sql.append("password = ?");
        }

        sql.append(" WHERE id_usuario = ?");

        ps = conn.prepareStatement(sql.toString());

        int index = 1;
        if (nuevoNombre != null && !nuevoNombre.trim().isEmpty()) {
            ps.setString(index++, nuevoNombre);
        }
        if (nuevaPassword != null && !nuevaPassword.trim().isEmpty()) {
            ps.setString(index++, nuevaPassword);
        }
        ps.setInt(index, idUsuario);

        int filas = ps.executeUpdate();
        if (filas > 0) {
            actualizado = true;
            if (nuevoNombre != null && !nuevoNombre.trim().isEmpty()) {
                session.setAttribute("usuario_nombre", nuevoNombre);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Actualizar Perfil</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="p-4">
    <div class="container">
        <% if (actualizado) { %>
            <div class="alert alert-success" role="alert">
                ✅ Tu perfil se actualizó correctamente.
            </div>
        <% } else { %>
            <div class="alert alert-danger" role="alert">
                ⚠️ Hubo un error al actualizar tu perfil. Intenta nuevamente.
            </div>
        <% } %>

        <a href="perfil.jsp" class="btn btn-primary mt-3">Volver al Perfil</a>
    </div>
</body>
</html>
