<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.barneyo.inmobiliaria.config.AdminAuth" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Verificar autenticación del administrador
    if (!AdminAuth.validateAdminSession(session)) {
        response.sendRedirect("../login.jsp?error=no_admin");
        return;
    }
    
    String adminName = AdminAuth.getAdminName(session);
    
    // Obtener estadísticas del dashboard
    int totalUsuarios = 0;
    int totalPropiedades = 0;
    int totalCitas = 0;
    int totalTransacciones = 0;
    
    try (Connection conn = ConexionDB.getConnection()) {
        // Contar usuarios
        String sqlUsuarios = "SELECT COUNT(*) FROM usuarios";
        try (PreparedStatement stmt = conn.prepareStatement(sqlUsuarios);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                totalUsuarios = rs.getInt(1);
            }
        }
        
        // Contar propiedades
        String sqlPropiedades = "SELECT COUNT(*) FROM propiedades";
        try (PreparedStatement stmt = conn.prepareStatement(sqlPropiedades);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                totalPropiedades = rs.getInt(1);
            }
        }
        
        // Contar citas
        String sqlCitas = "SELECT COUNT(*) FROM citas";
        try (PreparedStatement stmt = conn.prepareStatement(sqlCitas);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                totalCitas = rs.getInt(1);
            }
        }
        
        // Contar transacciones
        String sqlTransacciones = "SELECT COUNT(*) FROM transacciones";
        try (PreparedStatement stmt = conn.prepareStatement(sqlTransacciones);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                totalTransacciones = rs.getInt(1);
            }
        }
        
    } catch (SQLException e) {
        // Log del error
        System.err.println("Error en dashboard: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Administrador - InmoConnect</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="admin-styles.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar del Administrador -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-building me-2"></i>
                InmoConnect Admin
            </a>
            
            <div class="navbar-nav ms-auto">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i>
                        <%= adminName %>
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
                                <i class="fas fa-tachometer-alt me-2"></i>
                                Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="usuarios.jsp">
                                <i class="fas fa-users me-2"></i>
                                Gestión de Usuarios
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="propiedades.jsp">
                                <i class="fas fa-home me-2"></i>
                                Gestión de Propiedades
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="citas.jsp">
                                <i class="fas fa-calendar-check me-2"></i>
                                Gestión de Citas
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="transacciones.jsp">
                                <i class="fas fa-money-bill-wave me-2"></i>
                                Transacciones
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Contenido principal -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Dashboard Administrativo</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <div class="btn-group me-2">
                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="exportarReporte()">
                                <i class="fas fa-download me-1"></i>Exportar
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Tarjetas de estadísticas -->
                <div class="row mb-4">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                            Total Usuarios
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><%= totalUsuarios %></div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-users fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                            Total Propiedades
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><%= totalPropiedades %></div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-home fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-info shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                            Citas Pendientes
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><%= totalCitas %></div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-calendar-check fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                            Transacciones
                                        </div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><%= totalTransacciones %></div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="fas fa-money-bill-wave fa-2x text-gray-300"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Gráficos y tablas -->
                <div class="row">
                    <div class="col-lg-8">
                        <div class="card shadow mb-4">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">Actividad Reciente</h6>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-bordered" width="100%" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th>Usuario</th>
                                                <th>Acción</th>
                                                <th>Fecha</th>
                                                <th>Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>Cliente Ejemplo</td>
                                                <td>Nueva cita programada</td>
                                                <td>2024-01-15</td>
                                                <td><span class="badge bg-warning">Pendiente</span></td>
                                            </tr>
                                            <tr>
                                                <td>Inmobiliaria Ejemplo</td>
                                                <td>Propiedad agregada</td>
                                                <td>2024-01-14</td>
                                                <td><span class="badge bg-success">Completado</span></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card shadow mb-4">
                            <div class="card-header py-3">
                                <h6 class="m-0 font-weight-bold text-primary">Acciones Rápidas</h6>
                            </div>
                            <div class="card-body">
                                <div class="d-grid gap-2">
                                    <a href="usuarios.jsp" class="btn btn-primary btn-sm">
                                        <i class="fas fa-user-plus me-1"></i>Crear Usuario
                                    </a>
                                    <a href="propiedades.jsp" class="btn btn-success btn-sm">
                                        <i class="fas fa-home me-1"></i>Agregar Propiedad
                                    </a>
                                    <a href="citas.jsp" class="btn btn-info btn-sm">
                                        <i class="fas fa-chart-line me-1"></i>Administrar Citas
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="admin-scripts.js"></script>
    
    <script>
        function exportarReporte() {
            // Implementar exportación de reportes
            alert('Función de exportación en desarrollo');
        }
        
        // Actualizar dashboard cada 30 segundos
        setInterval(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
