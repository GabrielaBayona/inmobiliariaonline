<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
// Verificar si el usuario está autenticado y es cliente
if (session == null || session.getAttribute("usuario_id") == null) {
    response.sendRedirect("../login.jsp");
    return;
}

Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
if (rolId == null || rolId != 2) {
    response.sendRedirect("../login.jsp");
    return;
}

String nombreUsuario = (String) session.getAttribute("usuario_nombre");
int usuarioId = (Integer) session.getAttribute("usuario_id");

// Obtener estadísticas del cliente
int citasPendientes = 0;
int citasConfirmadas = 0;
int propiedadesFavoritas = 0;

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = "jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm";
    String user = "ugpnqduxkl6tu1pg";
    String pass = "0mRih6Kppo5IdNtaLq1M";
    
    conn = DriverManager.getConnection(url, user, pass);
    
    // Contar citas pendientes del cliente
    String sqlCitasPendientes = "SELECT COUNT(*) as total FROM citas WHERE cliente_id = ? AND estado = 'pendiente'";
    pstmt = conn.prepareStatement(sqlCitasPendientes);
    pstmt.setInt(1, usuarioId);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        citasPendientes = rs.getInt("total");
    }
    
    // Contar citas confirmadas del cliente
    String sqlCitasConfirmadas = "SELECT COUNT(*) as total FROM citas WHERE cliente_id = ? AND estado = 'confirmada'";
    pstmt = conn.prepareStatement(sqlCitasConfirmadas);
    pstmt.setInt(1, usuarioId);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        citasConfirmadas = rs.getInt("total");
    }
    
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) { }
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
    if (conn != null) try { conn.close(); } catch (SQLException e) { }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Cliente - InmoConnect</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
            --success-color: #27ae60;
            --warning-color: #f39c12;
            --danger-color: #e74c3c;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
        }

        .sidebar {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            min-height: 100vh;
            color: white;
            position: fixed;
            top: 0;
            left: 0;
            width: 250px;
            z-index: 1000;
        }

        .sidebar-header {
            padding: 1.5rem;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-header h4 {
            margin: 0;
            font-weight: 700;
        }

        .sidebar-menu {
            padding: 1rem 0;
        }

        .sidebar-menu .nav-link {
            color: rgba(255,255,255,0.8);
            padding: 0.75rem 1.5rem;
            border-radius: 0;
            transition: all 0.3s ease;
        }

        .sidebar-menu .nav-link:hover,
        .sidebar-menu .nav-link.active {
            color: white;
            background-color: rgba(255,255,255,0.1);
            transform: translateX(5px);
        }

        .sidebar-menu .nav-link i {
            width: 20px;
            margin-right: 10px;
        }

        .main-content {
            margin-left: 250px;
            padding: 2rem;
        }

        .top-bar {
            background: white;
            padding: 1rem 2rem;
            margin: -2rem -2rem 2rem -2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .welcome-text {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--primary-color);
        }

        .stats-cards {
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            color: #6c757d;
            font-weight: 500;
        }

        .content-section {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }

        .section-title {
            color: var(--primary-color);
            font-weight: 700;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
        }

        .section-title i {
            margin-right: 0.75rem;
            color: var(--secondary-color);
        }

        .btn-custom {
            border-radius: 10px;
            padding: 0.5rem 1.5rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-custom:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="sidebar-header">
            <h4><i class="fas fa-home me-2"></i>InmoConnect</h4>
            <small>Panel de Cliente</small>
        </div>
        
        <nav class="sidebar-menu">
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a class="nav-link active" href="dashboard.jsp">
                        <i class="fas fa-tachometer-alt"></i>Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="propiedades.jsp">
                        <i class="fas fa-building"></i>Ver Propiedades
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="citas.jsp">
                        <i class="fas fa-calendar-alt"></i>Mis Citas
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="perfil.jsp">
                        <i class="fas fa-user-edit"></i>Mi Perfil
                    </a>
                </li>
            </ul>
        </nav>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="welcome-text">
                <i class="fas fa-user-circle me-2"></i>
                Bienvenido, <%= nombreUsuario %>
            </div>
            <div class="d-flex">
                <a href="../index.html" class="btn btn-outline-secondary me-2">
                    <i class="fas fa-home me-2"></i>Portal Principal
                </a>
                <a href="../logout.jsp" class="btn btn-outline-danger">
                    <i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión
                </a>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row stats-cards">
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-icon text-warning">
                        <i class="fas fa-calendar-clock"></i>
                    </div>
                    <div class="stat-number"><%= citasPendientes %></div>
                    <div class="stat-label">Citas Pendientes</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-icon text-success">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="stat-number"><%= citasConfirmadas %></div>
                    <div class="stat-label">Citas Confirmadas</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-icon text-danger">
                        <i class="fas fa-heart"></i>
                    </div>
                    <div class="stat-number"><%= propiedadesFavoritas %></div>
                    <div class="stat-label">Propiedades Favoritas</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="content-section">
            <h4 class="section-title">
                <i class="fas fa-bolt"></i>Acciones Rápidas
            </h4>
            <div class="row">
                <div class="col-md-3 mb-3">
                    <a href="propiedades.jsp" class="btn btn-primary btn-custom w-100">
                        <i class="fas fa-search me-2"></i>Buscar Propiedades
                    </a>
                </div>
                <div class="col-md-3 mb-3">
                    <a href="citas.jsp" class="btn btn-success btn-custom w-100">
                        <i class="fas fa-calendar-plus me-2"></i>Agendar Cita
                    </a>
                </div>
                <div class="col-md-3 mb-3">
                    <a href="favoritos.jsp" class="btn btn-warning btn-custom w-100">
                        <i class="fas fa-heart me-2"></i>Ver Favoritos
                    </a>
                </div>
                <div class="col-md-3 mb-3">
                    <a href="perfil.jsp" class="btn btn-info btn-custom w-100">
                        <i class="fas fa-user-edit me-2"></i>Editar Perfil
                    </a>
                </div>
            </div>
        </div>
        
        <!-- Welcome Message -->
        <div class="content-section">
            <h4 class="section-title">
                <i class="fas fa-star"></i>¡Bienvenido a InmoConnect!
            </h4>
            <div class="row">
                <div class="col-md-8">
                    <h5>¿Qué puedes hacer aquí?</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Explorar propiedades disponibles</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Agendar citas para ver propiedades</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Guardar propiedades en favoritos</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Gestionar tu perfil personal</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Recibir notificaciones de nuevas propiedades</li>
                    </ul>
                </div>
                <div class="col-md-4 text-center">
                    <i class="fas fa-home fa-5x text-primary mb-3"></i>
                    <p class="text-muted">Tu hogar ideal te está esperando</p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
