<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>

<%
    // Verificar sesión de administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }

    String adminName = AdminAuth.getAdminName(session);
    Integer idUsuario = (Integer) session.getAttribute("usuario_id");
    if (idUsuario == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String mensaje = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nuevoNombre = request.getParameter("nombre");
        String nuevaPassword = request.getParameter("password");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");
             PreparedStatement ps = conn.prepareStatement("UPDATE usuarios SET nombre = ?, password = ? WHERE id_usuario = ?")) {

            ps.setString(1, nuevoNombre);
            ps.setString(2, nuevaPassword);
            ps.setInt(3, idUsuario);

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
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");
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

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actualizar Perfil - InmoConnect Admin</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="admin-styles.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-building me-2"></i>InmoConnect Admin
            </a>
            <div class="navbar-nav ms-auto">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i><%= adminName %>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="perfil.jsp"><i class="fas fa-user me-2"></i>Mi Perfil</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-3 col-lg-2 d-md-block bg-light sidebar">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link active" href="dashboard.jsp">
                                <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="usuarios.jsp">
                                <i class="fas fa-users me-2"></i>Gestión de Usuarios
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="propiedades.jsp">
                                <i class="fas fa-home me-2"></i>Gestión de Propiedades
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="citas.jsp">
                                <i class="fas fa-calendar-check me-2"></i>Gestión de Citas
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="transacciones.jsp">
                                <i class="fas fa-money-bill-wave me-2"></i>Transacciones
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Contenido principal -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Actualizar Perfil</h1>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Actualizar Perfil</h6>
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
                                    <input type="password" class="form-control" id="password" name="password" value="<%= password %>">
                                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                        </form>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="admin-scripts.js"></script>
    <script>
    const togglePassword = document.querySelector('#togglePassword');
    const passwordInput = document.querySelector('#password');

    togglePassword.addEventListener('click', function () {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);

        // Cambiar icono
        this.querySelector('i').classList.toggle('fa-eye');
        this.querySelector('i').classList.toggle('fa-eye-slash');
    });
    </script>

</body>
</html>
