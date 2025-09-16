<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"success\": false, \"message\": \"No autorizado\"}");
        return;
    }
    
    // Configurar respuesta JSON
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();
    
    try {
        // Obtener parámetros del formulario
        String nombre = request.getParameter("nombre");
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");
        String rolId = request.getParameter("rol");
        
        // Validar campos requeridos
        if (nombre == null || nombre.trim().isEmpty() ||
            correo == null || correo.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            rolId == null || rolId.trim().isEmpty()) {
            
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Todos los campos requeridos deben estar completos");
            out.print(jsonResponse.toString());
            return;
        }
        
        // Validar formato de email
        if (!correo.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Formato de email inválido");
            out.print(jsonResponse.toString());
            return;
        }
        
        // Validar longitud de contraseña
        if (password.length() < 6) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "La contraseña debe tener al menos 6 caracteres");
            out.print(jsonResponse.toString());
            return;
        }
        
        // Conectar a la base de datos
        try (Connection conn = ConexionDB.getConnection()) {
            // Verificar si el correo ya existe
            String sqlCheckEmail = "SELECT COUNT(*) FROM usuarios WHERE correo = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckEmail)) {
                stmt.setString(1, correo);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "El correo electrónico ya está registrado");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Verificar si el rol existe
            String sqlCheckRol = "SELECT COUNT(*) FROM roles WHERE id_rol = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckRol)) {
                stmt.setInt(1, Integer.parseInt(rolId));
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "El rol seleccionado no existe");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Insertar nuevo usuario
            String sqlInsert = "INSERT INTO usuarios (nombre, correo, password, telefono, direccion, rol_id, creado_por_admin) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, nombre.trim());
                stmt.setString(2, correo.trim().toLowerCase());
                stmt.setString(3, password); // En producción, debería hashearse
                stmt.setString(4, telefono != null ? telefono.trim() : null);
                stmt.setString(5, direccion != null ? direccion.trim() : null);
                stmt.setInt(6, Integer.parseInt(rolId));
                stmt.setBoolean(7, true); // Creado por administrador
                
                int affectedRows = stmt.executeUpdate();
                
                if (affectedRows > 0) {
                    // Obtener el ID del usuario creado
                    try (ResultSet rs = stmt.getGeneratedKeys()) {
                        if (rs.next()) {
                            int userId = rs.getInt(1);
                            
                            // Obtener información del usuario creado para la respuesta
                            String sqlGetUser = "SELECT u.*, r.nombre as nombre_rol FROM usuarios u " +
                                              "JOIN roles r ON u.rol_id = r.id_rol " +
                                              "WHERE u.id_usuario = ?";
                            try (PreparedStatement stmtUser = conn.prepareStatement(sqlGetUser)) {
                                stmtUser.setInt(1, userId);
                                try (ResultSet rsUser = stmtUser.executeQuery()) {
                                    if (rsUser.next()) {
                                        JSONObject userData = new JSONObject();
                                        userData.put("id", rsUser.getInt("id_usuario"));
                                        userData.put("nombre", rsUser.getString("nombre"));
                                        userData.put("correo", rsUser.getString("correo"));
                                        userData.put("telefono", rsUser.getString("telefono"));
                                        userData.put("direccion", rsUser.getString("direccion"));
                                        userData.put("rol_id", rsUser.getInt("rol_id"));
                                        userData.put("nombre_rol", rsUser.getString("nombre_rol"));
                                        userData.put("creado_por_admin", rsUser.getBoolean("creado_por_admin"));
                                        
                                        jsonResponse.put("success", true);
                                        jsonResponse.put("message", "Usuario creado exitosamente");
                                        jsonResponse.put("user", userData);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "No se pudo crear el usuario");
                }
            }
            
        } catch (SQLException e) {
            // Log del error
            System.err.println("Error SQL al crear usuario: " + e.getMessage());
            e.printStackTrace();
            
            // Determinar el tipo de error
            if (e.getSQLState() != null) {
                switch (e.getSQLState()) {
                    case "23000": // Violación de restricción única
                        if (e.getMessage().contains("correo")) {
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "El correo electrónico ya está registrado");
                        } else {
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "Error de validación en la base de datos");
                        }
                        break;
                    case "23505": // Violación de restricción única (PostgreSQL)
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "El correo electrónico ya está registrado");
                        break;
                    case "23514": // Violación de restricción de verificación
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Los datos no cumplen con las restricciones de validación");
                        break;
                    default:
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Error en la base de datos: " + e.getSQLState());
                }
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error interno del servidor");
            }
        }
        
    } catch (NumberFormatException e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "ID de rol inválido");
    } catch (Exception e) {
        // Log del error general
        System.err.println("Error general al crear usuario: " + e.getMessage());
        e.printStackTrace();
        
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error interno del servidor");
    }
    
    // Enviar respuesta JSON
    out.print(jsonResponse.toString());
%>
