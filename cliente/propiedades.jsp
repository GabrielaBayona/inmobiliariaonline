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
                    <a class="nav-link active" href="propiedades.jsp">
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

    <!-- Properties Section -->
    <section id="propiedades" class="section-padding">
        <div class="container">
            <h2 class="section-title">Propiedades Destacadas</h2>

            <!-- Filters -->
            <div class="filters-container">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Municipio</label>
                        <select class="form-select filter-select" id="municipioFilter">
                            <option value="">Todos los municipios</option>
                            <option value="bucaramanga">Bucaramanga</option>
                            <option value="floridablanca">Floridablanca</option>
                            <option value="giron">Girón</option>
                            <option value="piedecuesta">Piedecuesta</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Tipo de Propiedad</label>
                        <select class="form-select filter-select" id="tipoFilter">
                            <option value="">Todos los tipos</option>
                            <option value="casa">Casa</option>
                            <option value="apartamento">Apartamento</option>
                            <option value="apartaestudio">Apartaestudio</option>
                            <option value="oficina">Oficina</option>
                            <option value="local">Local Comercial</option>
                            <option value="finca">Finca</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Modalidad</label>
                        <select class="form-select filter-select" id="modalidadFilter">
                            <option value="">Venta y Alquiler</option>
                            <option value="venta">Venta</option>
                            <option value="alquiler">Alquiler</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button class="btn btn-outline-secondary w-100" id="clearFiltersBtn">
                            <i class="fas fa-times me-2"></i>Limpiar Filtros
                        </button>
                    </div>
                </div>
            </div>

            <div class="row" id="propertiesContainer">
                <!-- Properties will be populated by JavaScript -->
            </div>
            
            <div class="text-center mt-4">
                <button class="btn btn-primary-custom btn-custom" id="showMoreBtn">
                    <i class="fas fa-plus me-2"></i>Ver Más Propiedades
                </button>
                <button class="btn btn-outline-secondary btn-custom ms-2" id="showLessBtn" style="display: none;">
                    <i class="fas fa-minus me-2"></i>Ver Menos
                </button>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <p>&copy; 2025 InmoConnect. Todos los derechos reservados.</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <div class="social-links">
                        <a href="#" class="text-white me-3"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="text-white me-3"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="text-white me-3"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="text-white"><i class="fab fa-whatsapp"></i></a>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- Property Details Modal -->
    <div class="modal fade" id="propertyDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="propertyTitle">Detalles de la Propiedad</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <img id="propertyModalImage" src="" alt="Propiedad" class="property-detail-image">
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <h4 id="propertyModalTitle" class="text-primary"></h4>
                                <p id="propertyModalLocation" class="text-muted"></p>
                            </div>
                            
                            <div class="mb-3">
                                <h5 id="propertyModalPrice" class="text-danger fw-bold"></h5>
                                <span id="propertyModalBadge" class="badge"></span>
                            </div>
                            
                            <div class="mb-3">
                                <h6>Características:</h6>
                                <div id="propertyFeatures"></div>
                            </div>
                            
                            <div class="mb-3">
                                <h6>Descripción:</h6>
                                <p id="propertyDescription" class="text-muted"></p>
                            </div>
                            
                            <div class="mb-3">
                                <h6>Amenidades:</h6>
                                <ul id="propertyAmenities" class="amenity-list"></ul>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                    <a href="citas.jsp">
                    <button type="button" class="btn btn-primary-custom">
                        <i class="fas fa-calendar-alt me-2" href="login.jsp"></i>Agendar Cita
                    </button>
                    </a>
                    <button type="button" class="btn btn-primary-custom">
                        <i class="fas fa-phone me-2"></i>Contactar
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    <script>
        // Base de datos de propiedades
        const properties = [
            {
                id: 1,
                title: "Casa Moderna en Cabecera",
                location: "Cabecera del Llano, Bucaramanga",
                price: 450000000,
                type: "venta",
                propertyType: "casa",
                municipio: "bucaramanga",
                image: "https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 3,
                bathrooms: 3,
                area: 180,
                garages: 2,
                description: "Hermosa casa moderna ubicada en el exclusivo sector de Cabecera del Llano, con acabados de primera, amplios espacios y excelente ubicación cerca a centros comerciales y universidades.",
                amenities: ["Zona verde privada", "Closets empotrados", "Cocina integral", "Aire acondicionado", "Piso en porcelanato", "Vigilancia 24 horas"]
            },
            {
                id: 2,
                title: "Apartamento Centro Histórico",
                location: "Centro, Bucaramanga",
                price: 1200000,
                type: "alquiler",
                propertyType: "apartamento",
                municipio: "bucaramanga",
                image: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 2,
                bathrooms: 2,
                area: 85,
                garages: 1,
                description: "Acogedor apartamento en el corazón histórico de Bucaramanga, ideal para profesionales. Cerca a entidades bancarias, notarías y transporte público.",
                amenities: ["Internet incluido", "Administración incluida", "Balcón", "Cocina equipada", "Portería", "Ascensor"]
            },
            {
                id: 3,
                title: "Penthouse Torre Premium",
                location: "Cabecera del Llano, Bucaramanga",
                price: 800000000,
                type: "venta",
                propertyType: "apartamento",
                municipio: "bucaramanga",
                image: "https://images.unsplash.com/photo-1613977257363-707ba9348227?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 4,
                bathrooms: 3,
                area: 220,
                garages: 2,
                description: "Exclusivo penthouse en torre premium con vista panorámica de la ciudad. Ubicado en el sector más exclusivo de Cabecera con amenidades de lujo.",
                amenities: ["Piscina", "Gimnasio", "Salón social", "BBQ", "Terraza privada", "Jacuzzi", "Vista panorámica", "Doble ascensor"]
            },
            {
                id: 4,
                title: "Casa Familiar Lagos del Cacique",
                location: "Lagos del Cacique, Floridablanca",
                price: 2800000,
                type: "alquiler",
                propertyType: "casa",
                municipio: "floridablanca",
                image: "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3&auto=format&fit=crop&w=2053&q=80",
                rooms: 4,
                bathrooms: 3,
                area: 200,
                garages: 2,
                description: "Espaciosa casa familiar en el exclusivo conjunto Lagos del Cacique, con amplio jardín y zona social. Ideal para familias que buscan tranquilidad y seguridad.",
                amenities: ["Piscina del conjunto", "Zona de juegos infantiles", "Cancha múltiple", "Salón comunal", "Jardín privado", "Zona de lavandería", "Cuarto de servicio"]
            },
            {
                id: 5,
                title: "Apartaestudio Zona Rosa",
                location: "Zona Rosa, Bucaramanga",
                price: 900000,
                type: "alquiler",
                propertyType: "apartaestudio",
                municipio: "bucaramanga",
                image: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?ixlib=rb-4.0.3&auto=format&fit=crop&w=2058&q=80",
                rooms: 1,
                bathrooms: 1,
                area: 35,
                garages: 0,
                description: "Moderno apartaestudio completamente amoblado en la Zona Rosa, ideal para estudiantes universitarios o profesionales jóvenes. Excelente ubicación comercial.",
                amenities: ["Completamente amoblado", "Internet incluido", "Servicios incluidos", "Cocina integral", "Aire acondicionado", "Vigilancia privada"]
            },
            {
                id: 6,
                title: "Local Comercial Centro Comercial",
                location: "Centro Comercial Cacique, Floridablanca",
                price: 3500000,
                type: "alquiler",
                propertyType: "local",
                municipio: "floridablanca",
                image: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 0,
                bathrooms: 1,
                area: 80,
                garages: 0,
                description: "Local comercial en excelente ubicación dentro del Centro Comercial Cacique, con alto flujo de personas y excelente visibilidad para cualquier tipo de negocio.",
                amenities: ["Aire acondicionado central", "Vitrina amplia", "Bodega incluida", "Parqueadero visitantes", "Seguridad 24/7", "Zona de comidas cercana"]
            },
            {
                id: 7,
                title: "Finca El Refugio",
                location: "Ruitoque, Piedecuesta",
                price: 1200000000,
                type: "venta",
                propertyType: "finca",
                municipio: "piedecuesta",
                image: "https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 6,
                bathrooms: 4,
                area: 5000,
                garages: 3,
                description: "Hermosa finca de recreo en el sector de Ruitoque, con clima templado, casa principal, cabaña de huéspedes y amplias zonas verdes. Ideal para descanso familiar.",
                amenities: ["Piscina", "BBQ", "Zona de camping", "Cultivos frutales", "Cabaña huéspedes", "Pozo de agua", "Energía trifásica", "Acceso pavimentado"]
            },
            {
                id: 8,
                title: "Apartamento Villa Country",
                location: "Villa Country, Girón",
                price: 320000000,
                type: "venta",
                propertyType: "apartamento",
                municipio: "giron",
                image: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 3,
                bathrooms: 2,
                area: 95,
                garages: 1,
                description: "Cómodo apartamento en Villa Country, conjunto cerrado con excelentes amenidades y ubicación estratégica cerca al centro comercial y vías principales.",
                amenities: ["Piscina adultos y niños", "Gimnasio", "Cancha tenis", "Zona BBQ", "Parque infantil", "Sendero ecológico", "Portería 24h"]
            },
            {
                id: 9,
                title: "Casa Lote San Gil",
                location: "San Gil, Piedecuesta",
                price: 2200000,
                type: "alquiler",
                propertyType: "casa",
                municipio: "piedecuesta",
                image: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 3,
                bathrooms: 2,
                area: 120,
                garages: 2,
                description: "Casa independiente con amplio lote en el tradicional barrio San Gil de Piedecuesta, ideal para familias que buscan tranquilidad y espacios amplios.",
                amenities: ["Patio amplio", "Zona de ropas", "Jardín", "Garaje cubierto", "Cocina independiente", "Sala comedor amplia"]
            },
            {
                id: 10,
                title: "Oficina Empresarial Centro",
                location: "Carrera 19, Bucaramanga",
                price: 1800000,
                type: "alquiler",
                propertyType: "oficina",
                municipio: "bucaramanga",
                image: "https://images.unsplash.com/photo-1497366216548-37526070297c?ixlib=rb-4.0.3&auto=format&fit=crop&w=2069&q=80",
                rooms: 0,
                bathrooms: 2,
                area: 65,
                garages: 1,
                description: "Oficina ejecutiva en edificio empresarial del centro de Bucaramanga, ideal para consultorios, bufetes o empresas de servicios.",
                amenities: ["Recepción", "Sala de juntas", "Aire acondicionado", "Internet fibra óptica", "Parqueadero asignado", "Vigilancia", "Ascensor"]
            },
            {
                id: 11,
                title: "Casa Condominio Rincón del Bosque",
                location: "Rincón del Bosque, Floridablanca",
                price: 650000000,
                type: "venta",
                propertyType: "casa",
                municipio: "floridablanca",
                image: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=2075&q=80",
                rooms: 4,
                bathrooms: 3,
                area: 165,
                garages: 2,
                description: "Elegante casa en condominio cerrado Rincón del Bosque, con arquitectura moderna y acabados de alta calidad en zona de valorización.",
                amenities: ["Piscina comunitaria", "Vigilancia 24h", "Zona verde", "Cancha múltiple", "Salón eventos", "Citófono", "Cocina isla"]
            },
            {
                id: 12,
                title: "Apartamento Torres del Parque",
                location: "Parque García Rovira, Bucaramanga",
                price: 280000000,
                type: "venta",
                propertyType: "apartamento",
                municipio: "bucaramanga",
                image: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 2,
                bathrooms: 2,
                area: 78,
                garages: 1,
                description: "Apartamento con vista al Parque García Rovira, en edificio clásico renovado con todas las comodidades modernas y ubicación céntrica privilegiada.",
                amenities: ["Vista al parque", "Balcón", "Cocina remodelada", "Pisos laminados", "Closets empotrados", "Portería"]
            },
            {
                id: 13,
                title: "Casa Campestre Cañaveral",
                location: "Cañaveral, Floridablanca",
                price: 4500000,
                type: "alquiler",
                propertyType: "casa",
                municipio: "floridablanca",
                image: "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3&auto=format&fit=crop&w=2053&q=80",
                rooms: 5,
                bathrooms: 4,
                area: 300,
                garages: 3,
                description: "Espectacular casa campestre en Cañaveral con diseño colonial, amplias zonas sociales, piscina y jardines. Perfecta para eventos familiares.",
                amenities: ["Piscina privada", "BBQ", "Zona de hamacas", "Jardín amplio", "Kiosco", "Cocina campestre", "Chimenea", "Parqueadero 6 carros"]
            },
            {
                id: 14,
                title: "Apartamento Nuevo Girón",
                location: "Las Mercedes, Girón",
                price: 1600000,
                type: "alquiler",
                propertyType: "apartamento",
                municipio: "giron",
                image: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 3,
                bathrooms: 2,
                area: 85,
                garages: 1,
                description: "Moderno apartamento en el tradicional municipio de Girón, cerca al parque principal y con fácil acceso al transporte público hacia Bucaramanga.",
                amenities: ["Balcón con vista", "Cocina integral", "Closets empotrados", "Piso cerámico", "Lavadero cubierto", "Portería"]
            },
            {
                id: 15,
                title: "Local Comercial Piedecuesta Centro",
                location: "Parque Principal, Piedecuesta",
                price: 2500000,
                type: "alquiler",
                propertyType: "local",
                municipio: "piedecuesta",
                image: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80",
                rooms: 0,
                bathrooms: 1,
                area: 60,
                garages: 0,
                description: "Local comercial en pleno centro de Piedecuesta, frente al parque principal con excelente flujo peatonal y vehicular. Ideal para cualquier negocio.",
                amenities: ["Vitrina amplia", "Dos niveles", "Bodega", "Punto de agua", "Contador independiente", "Fácil acceso"]
            }
        ];


        let currentPage = 1;
        const propertiesPerPage = 6;
        let filteredProperties = [...properties];

        // Función para renderizar propiedades
        function renderProperties() {
            const container = document.getElementById('propertiesContainer');
            const startIndex = (currentPage - 1) * propertiesPerPage;
            const endIndex = startIndex + propertiesPerPage;
            const propertiesToShow = filteredProperties.slice(0, endIndex);

            container.innerHTML = '';

            propertiesToShow.forEach(property => {
                const propertyCard = createPropertyCard(property);
                container.appendChild(propertyCard);
            });

            // Mostrar/ocultar botones "Ver más" y "Ver menos"
            const showMoreBtn = document.getElementById('showMoreBtn');
            const showLessBtn = document.getElementById('showLessBtn');
            
            if (endIndex >= filteredProperties.length) {
                showMoreBtn.style.display = 'none';
                if (currentPage > 1) {
                    showLessBtn.style.display = 'inline-block';
                }
            } else {
                showMoreBtn.style.display = 'inline-bloc    k';
                if (currentPage > 1) {
                    showLessBtn.style.display = 'inline-block';
                } else {
                    showLessBtn.style.display = 'none';
                }
            }
        }

        // Función para crear tarjeta de propiedad
        function createPropertyCard(property) {
            const col = document.createElement('div');
            col.className = 'col-lg-4 col-md-6 mb-4';
            
            const formatPrice = (price, type) => {
                if (type === 'alquiler') {
                    return `${price.toLocaleString()}`;
                } else {
                    return `${price.toLocaleString()}`;
                }
            };

            const badgeClass = property.type === 'venta' ? 'badge-venta' : 'badge-alquiler';
            const badgeText = property.type === 'venta' ? 'VENTA' : 'ALQUILER';

            col.innerHTML = `
                <div class="card property-card" data-id="` + property.id + `">
                    <div style="position: relative;">
                        <img src="` + property.image + `" class="property-image" alt="` + property.title + `">
                        <div class="property-badge ` + badgeClass + `">` + badgeText + `</div>
                    </div>
                    <div class="card-body">
                        <h5 class="card-title">` + property.title + `</h5>
                        <p class="property-location mb-2">
                            <i class="fas fa-map-marker-alt me-1"></i>` + property.location + `
                        </p>
                        <div class="property-features">
                                <c:choose>
                                    <c:when test="` + (property.propertyType != 'local' && property.propertyType != 'oficina') + `">
                                        <span><i class="fas fa-bed me-1"></i>` + property.rooms + ` hab.</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span><i class="fas fa-building me-1"></i>` + property.propertyType + `</span>
                                    </c:otherwise>
                                </c:choose>

                                <span><i class="fas fa-bath me-1"></i>` + property.bathrooms + ` baños</span>
                                <span><i class="fas fa-expand-arrows-alt me-1"></i>` + property.area + `m²</span>

                                <c:if test="` + (property.garages > 0) + `">
                                    <span><i class="fas fa-car me-1"></i>` + property.garages + ` garajes</span>
                                </c:if>
                            </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="property-price">` + property.price + `/mes</span>
                        </div>
                        <button class="btn btn-primary w-100 mt-3 view-details-btn" data-id="` + property.id + `">Ver Detalles</button>
                        
                    </div>
                </div>
            `;
            return col;
        }
         // Función para limpiar filtros
        function clearFilters() {
            document.getElementById('municipioFilter').value = '';
            document.getElementById('tipoFilter').value = '';
            document.getElementById('modalidadFilter').value = '';
            
            filteredProperties = [...properties];
            currentPage = 1;
            renderProperties();
        }

        // Función para aplicar filtros
        function applyFilters() {
            const municipio = document.getElementById('municipioFilter').value;
            const tipo = document.getElementById('tipoFilter').value;
            const modalidad = document.getElementById('modalidadFilter').value;

            filteredProperties = properties.filter(property => {
                const matchesMunicipio = !municipio || property.municipio === municipio;
                const matchesTipo = !tipo || property.propertyType === tipo;
                const matchesModalidad = !modalidad || property.type === modalidad;

                return matchesMunicipio && matchesTipo && matchesModalidad;
            });

            currentPage = 1;
            renderProperties();
        }
        // Event listeners para filtros
        document.getElementById('municipioFilter').addEventListener('change', applyFilters);
        document.getElementById('tipoFilter').addEventListener('change', applyFilters);
        document.getElementById('modalidadFilter').addEventListener('change', applyFilters);

        // Event listener para limpiar filtros
        document.getElementById('clearFiltersBtn').addEventListener('click', clearFilters);

        // Event listener para "Ver más"
        document.getElementById('showMoreBtn').addEventListener('click', function() {
            currentPage++;
            renderProperties();
        });

        // Event listener para "Ver menos"
        document.getElementById('showLessBtn').addEventListener('click', function() {
            currentPage = 1;
            renderProperties();
        });

        // Función para mostrar detalles de propiedad
        function showPropertyDetails(propertyId) {
            const property = properties.find(p => p.id === propertyId);
            if (!property) return;

            // Llenar el modal con los datos
            document.getElementById('propertyTitle').textContent = 'Detalles de la Propiedad';
            document.getElementById('propertyModalImage').src = property.image;
            document.getElementById('propertyModalTitle').textContent = property.title;
            document.getElementById('propertyModalLocation').innerHTML = `<i class="fas fa-map-marker-alt me-1"></i>` + property.location;
            
            const formatPrice = (price, type) => {
                if (type === 'alquiler') {
                    return `${price.toLocaleString()}`;
                } else {
                    return `${price.toLocaleString()}`;
                }
            };

            document.getElementById('propertyModalPrice').textContent = property.price;
            
            const badge = document.getElementById('propertyModalBadge');
            badge.textContent = property.type.toUpperCase();
            badge.className = `badge ${(property.type eq 'venta') ? 'bg-success' : 'bg-info'}`;


            // Características
            const featuresContainer = document.getElementById('propertyFeatures');
            featuresContainer.innerHTML = '';
            
            if (property.propertyType !== 'local' && property.propertyType !== 'oficina') {
                featuresContainer.innerHTML += `<div class="detail-feature"><i class="fas fa-bed"></i>` + property.rooms + ` Habitaciones</div>`;
            }
            featuresContainer.innerHTML += `<div class="detail-feature"><i class="fas fa-bath"></i> ` + property.bathrooms + ` Baños</div>`;
            featuresContainer.innerHTML += `<div class="detail-feature"><i class="fas fa-expand-arrows-alt"></i> ` + property.area + ` m²</div>`;
            if (property.garages > 0) {
                featuresContainer.innerHTML += `<div class="detail-feature"><i class="fas fa-car"></i> ` + property.garages + ` Garajes</div>`;
            }

            // Descripción
            document.getElementById('propertyDescription').textContent = property.description;

            // Amenidades
            const amenitiesContainer = document.getElementById('propertyAmenities');
            amenitiesContainer.innerHTML = '';
            property.amenities.forEach(amenity => {
                const li = document.createElement('li');
                li.innerHTML = `<i class="fas fa-check text-success me-2"></i>` + amenity ;
                amenitiesContainer.appendChild(li);
            });

            // Mostrar el modal
            const modal = new bootstrap.Modal(document.getElementById('propertyDetailModal'));
            modal.show();
        }

        // Event listener para botones de "Ver Detalles"
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('view-details-btn')) {
                const propertyId = parseInt(e.target.getAttribute('data-id'));
                showPropertyDetails(propertyId);
            }
        });

        // Smooth scrolling para los enlaces de navegación
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
        
        // Inicializar propiedades al cargar la página
        document.addEventListener('DOMContentLoaded', function() {
            renderProperties();
        });
    </script>

</body>
</html>