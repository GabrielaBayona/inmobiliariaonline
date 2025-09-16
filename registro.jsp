<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
// Procesar el formulario de registro
String mensaje = null;
String tipoMensaje = "info";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nombre = request.getParameter("nombre");
    String correo = request.getParameter("correo");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    
    // Validaciones básicas
    if (nombre == null || nombre.trim().isEmpty() ||
        correo == null || correo.trim().isEmpty() ||
        password == null || password.trim().isEmpty() ||
        confirmPassword == null || confirmPassword.trim().isEmpty()) {
        mensaje = "Por favor complete todos los campos obligatorios.";
        tipoMensaje = "danger";
    } else if (!password.equals(confirmPassword)) {
        mensaje = "Las contraseñas no coinciden.";
        tipoMensaje = "danger";
    } else if (password.length() < 6) {
        mensaje = "La contraseña debe tener al menos 6 caracteres.";
        tipoMensaje = "danger";
    } else {
        // Verificar si el correo ya existe
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
            
            // Verificar si el correo ya existe
            String sqlCheck = "SELECT COUNT(*) as total FROM usuarios WHERE correo = ?";
            pstmt = conn.prepareStatement(sqlCheck);
            pstmt.setString(1, correo);
            rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt("total") > 0) {
                mensaje = "El correo electrónico ya está registrado. Use otro correo o inicie sesión.";
                tipoMensaje = "warning";
            } else {
                // Crear el nuevo usuario (solo cliente - rol_id = 2)
                String sqlInsert = "INSERT INTO usuarios (nombre, correo, password, telefono, direccion, rol_id, creado_por_admin) VALUES (?, ?, ?, ?, ?, 2, FALSE)";
                pstmt = conn.prepareStatement(sqlInsert);
                pstmt.setString(1, nombre);
                pstmt.setString(2, correo);
                pstmt.setString(3, password);
                pstmt.setString(4, telefono != null ? telefono : "");
                pstmt.setString(5, direccion != null ? direccion : "");
                
                int resultado = pstmt.executeUpdate();
                if (resultado > 0) {
                    mensaje = "¡Registro exitoso! Tu cuenta de cliente ha sido creada. Ahora puedes iniciar sesión.";
                    tipoMensaje = "success";
                    
                    // Limpiar el formulario después del registro exitoso
                    request.setAttribute("registroExitoso", true);
                } else {
                    mensaje = "Error al crear la cuenta. Intente nuevamente.";
                    tipoMensaje = "danger";
                }
            }
            
        } catch (ClassNotFoundException e) {
            mensaje = "Error: Driver de MySQL no encontrado.";
            tipoMensaje = "danger";
            e.printStackTrace();
        } catch (SQLException e) {
            mensaje = "Error en la base de datos: " + e.getMessage();
            tipoMensaje = "danger";
            e.printStackTrace();
        } catch (Exception e) {
            mensaje = "Error interno del sistema: " + e.getMessage();
            tipoMensaje = "danger";
            e.printStackTrace();
        } finally {
            // Cerrar conexiones
            if (rs != null) try { rs.close(); } catch (SQLException e) { }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
            if (conn != null) try { conn.close(); } catch (SQLException e) { }
        }
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro - InmoConnect</title>
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

        .register-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 500px;
            width: 100%;
        }

        .register-header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .register-header h2 {
            margin: 0;
            font-weight: 700;
        }

        .register-body {
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

        .btn-register {
            background: var(--accent-color);
            border: none;
            border-radius: 10px;
            padding: 0.75rem;
            font-size: 1.1rem;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }

        .btn-register:hover {
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

        .login-link {
            text-align: center;
            margin-top: 1rem;
            padding-top: 1rem;
            border-top: 1px solid #e2e8f0;
        }

        .login-link a {
            color: var(--secondary-color);
            text-decoration: none;
            font-weight: 500;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        .form-label.required::after {
            content: " *";
            color: var(--accent-color);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="register-container">
                    <div class="register-header">
                        <h2><i class="fas fa-user-plus me-2"></i>Crear Cuenta</h2>
                        <p class="mb-0">Regístrate como cliente en InmoConnect</p>
                    </div>
                    
                    <div class="register-body">
                        <% if (mensaje != null) { %>
                            <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert">
                                <i class="fas fa-info-circle me-2"></i><%= mensaje %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        <% } %>
                        
                        <% if (request.getAttribute("registroExitoso") != null) { %>
                            <!-- Formulario oculto después del registro exitoso -->
                            <div class="text-center py-4">
                                <i class="fas fa-check-circle text-success fa-3x mb-3"></i>
                                <h4 class="text-success">¡Registro Completado!</h4>
                                <p class="text-muted">Tu cuenta de cliente ha sido creada exitosamente.</p>
                                <a href="login.jsp" class="btn btn-primary">
                                    <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
                                </a>
                            </div>
                        <% } else { %>
                            <!-- Formulario de registro -->
                            <form method="post" id="registroForm">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="nombre" class="form-label required">Nombre Completo</label>
                                        <input type="text" class="form-control" id="nombre" name="nombre" 
                                               value="<%= request.getParameter("nombre") != null ? request.getParameter("nombre") : "" %>"
                                               required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="correo" class="form-label required">Correo Electrónico</label>
                                        <input type="email" class="form-control" id="correo" name="correo" 
                                               value="<%= request.getParameter("correo") != null ? request.getParameter("correo") : "" %>"
                                               required>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="password" class="form-label required">Contraseña</label>
                                        <input type="password" class="form-control" id="password" name="password" 
                                               minlength="6" required>
                                        <small class="text-muted">Mínimo 6 caracteres</small>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="confirmPassword" class="form-label required">Confirmar Contraseña</label>
                                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                               minlength="6" required>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="telefono" class="form-label">Teléfono</label>
                                        <input type="tel" class="form-control" id="telefono" name="telefono" 
                                               value="<%= request.getParameter("telefono") != null ? request.getParameter("telefono") : "" %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="direccion" class="form-label">Dirección</label>
                                        <input type="text" class="form-control" id="direccion" name="direccion" 
                                               value="<%= request.getParameter("direccion") != null ? request.getParameter("direccion") : "" %>">
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="terminos" required>
                                        <label class="form-check-label" for="terminos">
                                            Acepto los <a href="#" class="text-decoration-none">términos y condiciones</a> 
                                            y la <a href="#" class="text-decoration-none">política de privacidad</a>
                                        </label>
                                    </div>
                                </div>
                                
                                <button type="submit" class="btn btn-register text-white">
                                    <i class="fas fa-user-plus me-2"></i>Crear Cuenta
                                </button>
                            </form>
                            
                            <div class="login-link">
                                <p class="mb-0">¿Ya tienes cuenta? 
                                    <a href="login.jsp">
                                        <i class="fas fa-sign-in-alt me-1"></i>Inicia Sesión
                                    </a>
                                </p>
                            </div>
                        <% } %>
                        
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
    <script>
        // Validación del formulario en el frontend
        document.getElementById('registroForm').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const terminos = document.getElementById('terminos').checked;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Las contraseñas no coinciden.');
                return false;
            }
            
            if (password.length < 6) {
                e.preventDefault();
                alert('La contraseña debe tener al menos 6 caracteres.');
                return false;
            }
            
            if (!terminos) {
                e.preventDefault();
                alert('Debes aceptar los términos y condiciones.');
                return false;
            }
        });
        
        // Validación en tiempo real de la confirmación de contraseña
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (confirmPassword !== '' && password !== confirmPassword) {
                this.setCustomValidity('Las contraseñas no coinciden');
            } else {
                this.setCustomValidity('');
            }
        });
    </script>
</body>
</html>
