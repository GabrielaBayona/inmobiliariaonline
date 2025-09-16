<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Conexión JDBC</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4><i class="fas fa-database me-2"></i>Test de Conexión JDBC</h4>
                    </div>
                    <div class="card-body">
                        <%
                        String mensaje = "";
                        String tipoMensaje = "info";
                        
                        try {
                            // 1. Cargar el driver
                            out.println("<div class='alert alert-info'>");
                            out.println("<strong>1. Cargando driver MySQL...</strong><br>");
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            out.println("✅ Driver cargado correctamente: com.mysql.cj.jdbc.Driver");
                            out.println("</div>");
                            
                            // 2. Establecer conexión
                            out.println("<div class='alert alert-info'>");
                            out.println("<strong>2. Estableciendo conexión...</strong><br>");
                            String url = "jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm";
                            String user = "ugpnqduxkl6tu1pg";
                            String pass = "0mRih6Kppo5IdNtaLq1M";
                            
                            out.println("URL: " + url + "<br>");
                            out.println("Usuario: " + user + "<br>");
                            out.println("Contraseña: [vacía]<br>");
                            
                            Connection conn = DriverManager.getConnection(url, user, pass);
                            out.println("✅ Conexión establecida correctamente");
                            out.println("</div>");
                            
                            // 3. Probar consulta
                            out.println("<div class='alert alert-info'>");
                            out.println("<strong>3. Probando consulta...</strong><br>");
                            String sql = "SELECT COUNT(*) as total FROM usuarios";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            ResultSet rs = pstmt.executeQuery();
                            
                            if (rs.next()) {
                                int total = rs.getInt("total");
                                out.println("✅ Consulta ejecutada correctamente<br>");
                                out.println("Total de usuarios en la BD: " + total);
                            }
                            out.println("</div>");
                            
                            // 4. Cerrar conexiones
                            rs.close();
                            pstmt.close();
                            conn.close();
                            
                            mensaje = "¡Conexión exitosa! La base de datos está funcionando correctamente.";
                            tipoMensaje = "success";
                            
                        } catch (ClassNotFoundException e) {
                            mensaje = "❌ Error: Driver MySQL no encontrado. Verifica que mysql-connector-j-8.0.33.jar esté en la carpeta lib del servidor.";
                            tipoMensaje = "danger";
                            e.printStackTrace();
                        } catch (SQLException e) {
                            mensaje = "❌ Error SQL: " + e.getMessage() + "<br><br><strong>Posibles causas:</strong><br>" +
                                     "1. MySQL no está ejecutándose en XAMPP<br>" +
                                     "2. La base de datos 'inmobiliaria_db' no existe<br>" +
                                     "3. Usuario/contraseña incorrectos<br>" +
                                     "4. Puerto 3306 bloqueado";
                            tipoMensaje = "danger";
                            e.printStackTrace();
                        } catch (Exception e) {
                            mensaje = "❌ Error inesperado: " + e.getMessage();
                            tipoMensaje = "danger";
                            e.printStackTrace();
                        }
                        %>
                        
                        <div class="alert alert-<%= tipoMensaje %>">
                            <h5><%= mensaje %></h5>
                        </div>
                        
                        <hr>
                        
                        <h5>📋 Pasos para solucionar problemas:</h5>
                        <ol>
                            <li><strong>Verificar XAMPP:</strong> MySQL debe estar ejecutándose (luz verde)</li>
                            <li><strong>Verificar base de datos:</strong> Debe existir 'inmobiliaria_db' en phpMyAdmin</li>
                            <li><strong>Verificar driver:</strong> mysql-connector-j-8.0.33.jar debe estar en la carpeta lib</li>
                            <li><strong>Verificar puerto:</strong> MySQL debe estar en puerto 3306</li>
                        </ol>
                        
                        <div class="text-center mt-4">
                            <a href="index.html" class="btn btn-primary">
                                <i class="fas fa-home me-2"></i>Volver al Portal
                            </a>
                            <a href="login.jsp" class="btn btn-outline-primary ms-2">
                                <i class="fas fa-sign-in-alt me-2"></i>Ir al Login
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
