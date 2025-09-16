package com.barneyo.inmobiliaria.config;

import javax.servlet.http.HttpSession;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminAuth {
    private static final Logger LOGGER = Logger.getLogger(AdminAuth.class.getName());
    
    public static boolean isAdmin(HttpSession session) {
        try {
            if (session == null) {
                LOGGER.warning("Sesión nula en verificación de admin");
                return false;
            }
            
            Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
            String correo = (String) session.getAttribute("usuario_correo");
            
            if (rolId == null || correo == null) {
                LOGGER.warning("Atributos de sesión faltantes: usuario_rol_id=" + rolId + ", usuario_correo=" + correo);
                return false;
            }
            
            // Verificar que sea rol de administrador (id_rol = 1)
            return rolId == 1;
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error al verificar si es administrador", e);
            return false;
        }
    }
    
    public static boolean validateAdminSession(HttpSession session) {
        try {
            if (session == null) {
                LOGGER.warning("Sesión nula en validación de admin");
                return false;
            }
            
            // Verificar si la sesión no ha expirado
            long lastAccess = session.getLastAccessedTime();
            long currentTime = System.currentTimeMillis();
            long sessionTimeout = 30 * 60 * 1000; // 30 minutos
            
            if (currentTime - lastAccess > sessionTimeout) {
                LOGGER.warning("Sesión expirada para usuario: " + session.getAttribute("correo"));
                session.invalidate();
                return false;
            }
            
            return isAdmin(session);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error al validar sesión de administrador", e);
            return false;
        }
    }
    
    public static String getAdminName(HttpSession session) {
        try {
            if (session != null) {
                return (String) session.getAttribute("usuario_nombre");
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error al obtener nombre del administrador", e);
        }
        return "Administrador";
    }
}

