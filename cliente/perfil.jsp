<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String nombreUsuario = (String) session.getAttribute("usuario_nombre");
    Integer idUsuario = (Integer) session.getAttribute("usuario_id");
    if (idUsuario == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String correo = "";
    String nombre = "";
    String password = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); 
        conn = DriverManager.getConnection("jdbc:mysql://bh9ql2bgqfzvkekmokbm-mysql.services.clever-cloud.com:3306/bh9ql2bgqfzvkekmokbm", "ugpnqduxkl6tu1pg", "0mRih6Kppo5IdNtaLq1M");

        String sql = "SELECT correo, nombre, password FROM usuarios WHERE id_usuario = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();

        if (rs.next()) {
            correo = rs.getString("correo");
            nombre = rs.getString("nombre");
            password = rs.getString("password");
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>InmoConnect - Tu hogar ideal te está esperando</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
            --light-bg: #f8f9fa;
            --dark-text: #2c3e50;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--dark-text);
        }

        .navbar-custom {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 1rem 0;
        }

        .hero-section {
            background: linear-gradient(rgba(44, 62, 80, 0.8), rgba(52, 152, 219, 0.8)), 
                        url('https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1973&q=80') center/cover;
            min-height: 100vh;
            display: flex;
            align-items: center;
            position: relative;
        }

        .hero-content {
            color: white;
            text-align: center;
        }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }

        .hero-subtitle {
            font-size: 1.3rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }

        .btn-custom {
            padding: 12px 30px;
            font-size: 1.1rem;
            border-radius: 50px;
            transition: all 0.3s ease;
        }

        .btn-primary-custom {
            background: var(--accent-color);
            border: none;
            color: white;
        }

        .btn-primary-custom:hover {
            background: #c0392b;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(231, 76, 60, 0.3);
        }

        .btn-outline-custom {
            border: 2px solid white;
            color: white;
            background: transparent;
        }

        .btn-outline-custom:hover {
            background: white;
            color: var(--primary-color);
            transform: translateY(-2px);
        }

        .section-padding {
            padding: 80px 0;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 3rem;
            color: var(--primary-color);
            position: relative;
        }

        .section-title::after {
            content: '';
            width: 60px;
            height: 4px;
            background: var(--secondary-color);
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
        }

        /* Filtros de búsqueda */
        .filters-container {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 3rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .filter-select {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem;
            font-size: 0.95rem;
        }

        .filter-select:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.15);
        }

        .property-card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            height: 100%;
            margin-bottom: 2rem;
        }

        .property-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.2);
        }

        .property-image {
            height: 250px;
            object-fit: cover;
            width: 100%;
        }

        .property-price {
            color: var(--accent-color);
            font-size: 1.4rem;
            font-weight: 700;
        }

        .property-location {
            color: #6c757d;
            font-size: 0.9rem;
        }

        .property-features {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            margin: 1rem 0;
            font-size: 0.85rem;
            color: #6c757d;
        }

        .property-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-venta {
            background: #38a169;
            color: white;
        }

        .badge-alquiler {
            background: #3182ce;
            color: white;
        }

        .stats-section {
            background: var(--light-bg);
        }

        .stat-card {
            text-align: center;
            padding: 2rem 1rem;
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 700;
            color: var(--secondary-color);
        }

        .stat-label {
            font-size: 1.1rem;
            color: var(--dark-text);
            margin-top: 0.5rem;
        }

        .service-icon {
            font-size: 3rem;
            color: var(--secondary-color);
            margin-bottom: 1rem;
        }

        .contact-section {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
        }

        .contact-info {
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
        }

        .footer {
            background: var(--primary-color);
            color: white;
            text-align: center;
            padding: 2rem 0;
        }

        /* Modal styles */
        .modal-lg {
            max-width: 900px;
        }

        .property-detail-image {
            height: 300px;
            object-fit: cover;
            width: 100%;
            border-radius: 10px;
        }

        .detail-feature {
            display: flex;
            align-items: center;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .detail-feature i {
            margin-right: 0.5rem;
            color: var(--secondary-color);
            width: 20px;
        }

        .amenity-list {
            list-style: none;
            padding: 0;
        }

        .amenity-list li {
            padding: 0.25rem 0;
            border-bottom: 1px solid #eee;
        }

        .amenity-list li:last-child {
            border-bottom: none;
        }

        .hidden {
            display: none !important;
        }

        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }
            
            .hero-subtitle {
                font-size: 1.1rem;
            }
            
            .section-title {
                font-size: 2rem;
            }

            .filters-container {
                padding: 1rem;
            }
        }
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
                    <a class="nav-link" href="dashboard.jsp">
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
                    <a class="nav-link active" href="perfil.jsp">
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

        <div class="content-section">
            <h4 class="section-title"><i class="fas fa-user-edit"></i> Editar Perfil</h4>
        </div>

        <form action="actualizarPerfil.jsp" method="post">
                <div class="mb-3">
                    <label for="correo" class="form-label">Correo electrónico</label>
                    <input type="email" class="form-control" id="correo" name="correo" value="<%= correo %>" readonly>
                </div>

                <div class="mb-3">
                    <label for="nombre" class="form-label">Nombre</label>
                    <input type="text" class="form-control" id="nombre" name="nombre" value="<%= nombre %>" required>
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

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Guardar Cambios
                </button>
        </form>
        
    </div>

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