<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
// Procesar el formulario de login
String errorMsg = null;
String successMsg = null;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String correo = request.getParameter("correo");
    String password = request.getParameter("password");
    
    if (correo != null && !correo.trim().isEmpty() && 
        password != null && !password.trim().isEmpty()) {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Cargar el driver de MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Conectar a la base de datos
            String url = "jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm";
            String user = "ugpnqduxkl6tu1pg";
            String pass = "0mRih6Kppo5IdNtaLq1M";
            
            conn = DriverManager.getConnection(url, user, pass);
            
            // Consulta para verificar credenciales
            String sql = "SELECT u.id_usuario, u.nombre, u.correo, u.rol_id, r.nombre as rol_nombre " +
                        "FROM usuarios u " +
                        "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                        "WHERE u.correo = ? AND u.password = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, correo);
            pstmt.setString(2, password);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // Login exitoso - crear sesión
                session.setAttribute("usuario_id", rs.getInt("id_usuario"));
                session.setAttribute("usuario_nombre", rs.getString("nombre"));
                session.setAttribute("usuario_correo", rs.getString("correo"));
                session.setAttribute("usuario_rol_id", rs.getInt("rol_id"));
                session.setAttribute("usuario_rol", rs.getString("rol_nombre"));
                
                // Redirigir según el rol
                int rolId = rs.getInt("rol_id");
                switch (rolId) {
                    case 1: // Administrador
                        response.sendRedirect("admin/dashboard.jsp");
                        return;
                    case 2: // Cliente
                        response.sendRedirect("cliente/dashboard.jsp");
                        return;
                    case 3: // Inmobiliaria
                        response.sendRedirect("inmobiliaria/dashboard.jsp");
                        return;
                    default:
                        response.sendRedirect("login.jsp");
                        return;
                }
                
            } else {
                // Login fallido
                errorMsg = "Credenciales incorrectas. Intente nuevamente.";
            }
            
        } catch (ClassNotFoundException e) {
            errorMsg = "Error: Driver de MySQL no encontrado.";
            e.printStackTrace();
        } catch (SQLException e) {
            errorMsg = "Error en la base de datos: " + e.getMessage();
            e.printStackTrace();
        } catch (Exception e) {
            errorMsg = "Error interno del sistema: " + e.getMessage();
            e.printStackTrace();
        } finally {
            // Cerrar conexiones
            if (rs != null) try { rs.close(); } catch (SQLException e) { }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
            if (conn != null) try { conn.close(); } catch (SQLException e) { }
        }
    } else {
        errorMsg = "Por favor complete todos los campos.";
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InmoConnect - Login</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
        }

        body {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            min-height: 100vh;
            display: flex;
            align-items: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .login-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 400px;
            width: 100%;
        }

        .login-header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .login-header h2 {
            margin: 0;
            font-weight: 700;
        }

        .login-body {
            padding: 2rem;
        }

        .form-control {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem;
            font-size: 1rem;
        }

        .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.15);
        }

        .btn-login {
            background: var(--accent-color);
            border: none;
            border-radius: 10px;
            padding: 0.75rem;
            font-size: 1.1rem;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }

        .btn-login:hover {
            background: #c0392b;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(231, 76, 60, 0.3);
        }

        .alert {
            border-radius: 10px;
            border: none;
        }

        .back-to-home {
            text-align: center;
            margin-top: 1rem;
        }

        .back-to-home a {
            color: var(--secondary-color);
            text-decoration: none;
            font-weight: 500;
        }

        .back-to-home a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-4">
                <div class="login-container">
                    <div class="login-header">
                        <h2><i class="fas fa-home me-2"></i>InmoConnect</h2>
                        <p class="mb-0">Sistema de Gestión Inmobiliaria</p>
                    </div>
                    
                    <div class="login-body">
                        <% if (errorMsg != null) { %>
                            <div class="alert alert-danger" role="alert">
                                <i class="fas fa-exclamation-triangle me-2"></i><%= errorMsg %>
                            </div>
                        <% } %>
                        
                        <% if (successMsg != null) { %>
                            <div class="alert alert-success" role="alert">
                                <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                            </div>
                        <% } %>
                        
                        <form method="post">
                            <div class="mb-3">
                                <label for="correo" class="form-label fw-semibold">
                                    <i class="fas fa-envelope me-2"></i>Correo Electrónico
                                </label>
                                <input type="email" class="form-control" id="correo" name="correo" 
                                       value="<%= request.getParameter("correo") != null ? request.getParameter("correo") : "" %>"
                                       required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" class="form-label fw-semibold">
                                    <i class="fas fa-lock me-2"></i>Contraseña
                                </label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            
                            <button type="submit" class="btn btn-login text-white">
                                <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
                            </button>
                        </form>
                        
                        <div class="back-to-home">
                            <a href="index.html">
                                <i class="fas fa-arrow-left me-2"></i>Volver al Portal Principal
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
