<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.BufferedReader" %>

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
        // Leer el cuerpo de la petición JSON
        BufferedReader reader = request.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        
        // Parsear JSON del cuerpo de la petición
        String requestBody = sb.toString();
        JSONObject requestData = new JSONObject(requestBody);
        
        // Obtener el ID del usuario a eliminar
        int userId = requestData.getInt("id");
        
        // Validar que el ID sea válido
        if (userId <= 0) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "ID de usuario inválido");
            out.print(jsonResponse.toString());
            return;
        }
        
        // Conectar a la base de datos
        try (Connection conn = ConexionDB.getConnection()) {
            // Verificar que el usuario existe
            String sqlCheckUser = "SELECT u.*, r.nombre as nombre_rol FROM usuarios u " +
                                "JOIN roles r ON u.rol_id = r.id_rol " +
                                "WHERE u.id_usuario = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckUser)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "El usuario no existe");
                        out.print(jsonResponse.toString());
                        return;
                    }
                    
                    // Verificar que no se esté eliminando al administrador principal
                    String nombreRol = rs.getString("nombre_rol");
                    String correo = rs.getString("correo");
                    
                    if ("Administrador".equals(nombreRol) && "admin@admin.com".equals(correo)) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar al administrador principal del sistema");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Verificar si el usuario tiene propiedades asociadas
            String sqlCheckPropiedades = "SELECT COUNT(*) FROM propiedades WHERE inmobiliaria_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckPropiedades)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar el usuario porque tiene propiedades asociadas");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Verificar si el usuario tiene citas asociadas
            String sqlCheckCitas = "SELECT COUNT(*) FROM citas WHERE cliente_id = ? OR inmobiliaria_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckCitas)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && (rs.getInt(1) > 0 || rs.getInt(2) > 0)) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar el usuario porque tiene citas asociadas");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Verificar si el usuario tiene transacciones asociadas
            String sqlCheckTransacciones = "SELECT COUNT(*) FROM transacciones WHERE cliente_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckTransacciones)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar el usuario porque tiene transacciones asociadas");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Verificar si el usuario tiene reportes asociados
            String sqlCheckReportes = "SELECT COUNT(*) FROM reportes WHERE generado_por = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlCheckReportes)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar el usuario porque tiene reportes asociados");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            // Iniciar transacción para eliminar el usuario
            conn.setAutoCommit(false);
            
            try {
                // Eliminar el usuario
                String sqlDelete = "DELETE FROM usuarios WHERE id_usuario = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sqlDelete)) {
                    stmt.setInt(1, userId);
                    int affectedRows = stmt.executeUpdate();
                    
                    if (affectedRows > 0) {
                        // Confirmar transacción
                        conn.commit();
                        
                        jsonResponse.put("success", true);
                        jsonResponse.put("message", "Usuario eliminado exitosamente");
                        jsonResponse.put("userId", userId);
                    } else {
                        // Revertir transacción
                        conn.rollback();
                        
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se pudo eliminar el usuario");
                    }
                }
                
            } catch (SQLException e) {
                // Revertir transacción en caso de error
                conn.rollback();
                throw e;
            } finally {
                // Restaurar auto-commit
                conn.setAutoCommit(true);
            }
            
        } catch (SQLException e) {
            // Log del error
            System.err.println("Error SQL al eliminar usuario: " + e.getMessage());
            e.printStackTrace();
            
            // Determinar el tipo de error
            if (e.getSQLState() != null) {
                switch (e.getSQLState()) {
                    case "23000": // Violación de restricción de clave foránea
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar el usuario porque tiene registros asociados en el sistema");
                        break;
                    case "23503": // Violación de restricción de clave foránea (PostgreSQL)
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No se puede eliminar el usuario porque tiene registros asociados en el sistema");
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
        
    } catch (JSONException e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Formato de datos inválido");
    } catch (NumberFormatException e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "ID de usuario inválido");
    } catch (Exception e) {
        // Log del error general
        System.err.println("Error general al eliminar usuario: " + e.getMessage());
        e.printStackTrace();
        
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error interno del servidor");
    }
    
    // Enviar respuesta JSON
    out.print(jsonResponse.toString());
%>
