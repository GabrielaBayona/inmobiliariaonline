<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>

<%
    // Validar sesión y rol inmobiliaria
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
    String nombreUsuario = (String) session.getAttribute("usuario_nombre");
    String mensaje = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nuevoNombre = request.getParameter("nombre");
        String nuevaPassword = request.getParameter("password");

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE usuarios SET nombre = ?, password = ? WHERE id_usuario = ?")) {

            ps.setString(1, nuevoNombre);
            ps.setString(2, nuevaPassword);
            ps.setInt(3, usuarioId);

            int filas = ps.executeUpdate();
            if (filas > 0) {
                mensaje = "Perfil actualizado correctamente.";
                session.setAttribute("usuario_nombre", nuevoNombre);
            } else {
                mensaje = "No se pudo actualizar el perfil.";
            }

        } catch (Exception e) {
            mensaje = "Error al actualizar: " + e.getMessage();
            e.printStackTrace();
        }
    }

    // Recuperar datos actualizados
    String correo = "", nombre = "", password = "";
    try (Connection conn = ConexionDB.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT correo, nombre, password FROM usuarios WHERE id_usuario = ?")) {

        ps.setInt(1, usuarioId);
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

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Actualizar Perfil - InmoConnect</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    body { font-family: Arial, sans-serif; background: #f8f9fa; }
    .sidebar { background: #2c3e50; color: white; position: fixed; top:0; left:0; width:250px; height:100vh; }
    .sidebar a { color: rgba(255,255,255,0.8); display:block; padding:15px; text-decoration:none; }
    .sidebar a:hover { background: rgba(255,255,255,0.1); color:white; }
    .main-content { margin-left:250px; padding:20px; }
</style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <h3 class="text-center py-3"><i class="fas fa-building me-2"></i>InmoConnect</h3>
        <a href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
        <a href="propiedades.jsp"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
        <a href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Mis Citas</a>
        <a href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
        <a href="perfil.jsp" class="active"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
        <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
    </div>

    <div class="main-content">
        <h2>Actualizar Perfil</h2>

        <div class="card shadow mt-3">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Editar Información</h5>
            </div>
            <div class="card-body">
                <% if (!mensaje.isEmpty()) { %>
                    <div class="alert alert-success"><%= mensaje %></div>
                <% } %>

                <form method="post" action="">
                    <div class="mb-3">
                        <label for="correo" class="form-label">Correo electrónico</label>
                        <input type="email" class="form-control" id="correo" value="<%= correo %>" readonly>
                    </div>

                    <div class="mb-3">
                        <label for="nombre" class="form-label">Nombre</label>
                        <input type="text" class="form-control" id="nombre" name="nombre" value="<%= nombre %>">
                    </div>

                    <div class="mb-3">
                        <label for="password" class="form-label">Contraseña</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="password" name="password" value="<%= password %>">
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                <i class="fas fa-eye-slash"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                </form>
            </div>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const togglePassword = document.querySelector('#togglePassword');
const passwordInput = document.querySelector('#password');

togglePassword.addEventListener('click', function () {
    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordInput.setAttribute('type', type);
    this.querySelector('i').classList.toggle('fa-eye');
    this.querySelector('i').classList.toggle('fa-eye-slash');
});
</script>
</body>
</html>
