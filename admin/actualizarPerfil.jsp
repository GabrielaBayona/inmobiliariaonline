<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.util.*" %>

<%
    // -----------------------------
    // 1. Validar sesión de administrador
    // -----------------------------
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String adminName = AdminAuth.getAdminName(session);

    // -----------------------------
    // 2. Obtener ID del usuario a actualizar
    // -----------------------------
    Integer idUsuario = (Integer) session.getAttribute("usuario_id");
    if (idUsuario == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String mensaje = "";

    // -----------------------------
    // 3. Procesar actualización si es POST
    // -----------------------------
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nuevoNombre = request.getParameter("nombre");
        String nuevaPassword = request.getParameter("password");

        // Validar que al menos un campo tenga valor
        if ((nuevoNombre != null && !nuevoNombre.isEmpty()) || 
            (nuevaPassword != null && !nuevaPassword.isEmpty())) {

            try (Connection conn = ConexionDB.getConnection()) {

                // Construir SQL dinámico según los campos llenos
                StringBuilder sql = new StringBuilder("UPDATE usuarios SET ");
                List<String> campos = new ArrayList<>();
                if (nuevoNombre != null && !nuevoNombre.isEmpty()) campos.add("nombre = ?");
                if (nuevaPassword != null && !nuevaPassword.isEmpty()) campos.add("password = ?");
                sql.append(String.join(", ", campos));
                sql.append(" WHERE id_usuario = ?");

                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    int index = 1;
                    if (nuevoNombre != null && !nuevoNombre.isEmpty()) ps.setString(index++, nuevoNombre);
                    if (nuevaPassword != null && !nuevaPassword.isEmpty()) ps.setString(index++, nuevaPassword);
                    ps.setInt(index, idUsuario);

                    int filas = ps.executeUpdate();
                    if (filas > 0) {
                        mensaje = "Perfil actualizado correctamente.";
                        if (nuevoNombre != null && !nuevoNombre.isEmpty()) {
                            session.setAttribute("usuario_nombre", nuevoNombre);
                        }
                    } else {
                        mensaje = "No se pudo actualizar el perfil.";
                    }
                }

            } catch (Exception e) {
                mensaje = "Error al actualizar: " + e.getMessage();
                e.printStackTrace();
            }

        } else {
            mensaje = "Debe ingresar al menos un valor para actualizar.";
        }
    }

    // -----------------------------
    // 4. Recuperar datos actuales del usuario
    // -----------------------------
    String correo = "", nombre = "", password = "";
    try (Connection conn = ConexionDB.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT correo, nombre, password FROM usuarios WHERE id_usuario = ?")) {

        ps.setInt(1, idUsuario);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                correo = rs.getString("correo");
                nombre = rs.getString("nombre");
                password = rs.getString("password");
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>
