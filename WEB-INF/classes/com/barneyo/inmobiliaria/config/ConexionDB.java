package com.barneyo.inmobiliaria.config;

import java.sql.*;
import java.util.logging.Logger;
import java.util.logging.Level;

public class ConexionDB {

    /* private static final String URL = "jdbc:mysql://localhost:3306/inmobiliaria_db";
    private static final String USER = "root";
    private static final String PASSWORD = ""; /**/

    private static final String URL = "jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm";
    private static final String USER = "ugpnqduxkl6tu1pg";
    private static final String PASSWORD = "0mRih6Kppo5IdNtaLq1M";

    private static final Logger LOGGER = Logger.getLogger(ConexionDB.class.getName());
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error: Driver MySQL no encontrado", e);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error de conexión a la base de datos", e);
            throw e;
        }
    }
    
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error al cerrar la conexión", e);
            }
        }
    }
    
    public static void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error al cerrar el statement", e);
            }
        }
    }
    
    public static void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error al cerrar el ResultSet", e);
            }
        }
    }
}
