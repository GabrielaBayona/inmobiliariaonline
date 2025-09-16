<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.barneyo.inmobiliaria.config.ConexionDB" %>

<%
    // Validación: usuario autenticado y rol = inmobiliaria
    if (session == null || session.getAttribute("usuario_id") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
    if (rolId == null || rolId != 3) { // 3 = Inmobiliaria
        response.sendRedirect("../login.jsp");
        return;
    }

    int usuarioId = (Integer) session.getAttribute("usuario_id");
    String nombreUsuario = (String) session.getAttribute("usuario_nombre");

    // Listado de clientes
    List<Map<String, Object>> clientes = new ArrayList<>();
    try (Connection con = ConexionDB.getConnection()) {
        String sql = "SELECT id_usuario, nombre FROM usuarios WHERE rol_id = 2"; // 2 = Cliente
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> cliente = new HashMap<>();
            cliente.put("id_usuario", rs.getInt("id_usuario"));
            cliente.put("nombre", rs.getString("nombre"));
            clientes.add(cliente);
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar clientes: " + e.getMessage() + "</div>");
    }

    // Listado de propiedades de la inmobiliaria logueada
    List<Map<String, Object>> propiedades = new ArrayList<>();
    try (Connection con = ConexionDB.getConnection()) {
        String sql = "SELECT id_propiedad, titulo FROM propiedades WHERE inmobiliaria_id = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, usuarioId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> propiedad = new HashMap<>();
            propiedad.put("id_propiedad", rs.getInt("id_propiedad"));
            propiedad.put("titulo", rs.getString("titulo"));
            propiedades.add(propiedad);
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Error al cargar propiedades: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Añadir Transacción - InmoConnect</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    body { background: #f8f9fa; font-family: Arial, sans-serif; }
    .sidebar { background: #2c3e50; color: white; position: fixed; top:0; left:0; width:250px; height:100vh; }
    .sidebar a { color: rgba(255,255,255,0.8); display:block; padding:15px; text-decoration:none; }
    .sidebar a:hover { background: rgba(255,255,255,0.1); color:white; }
    .main-content { margin-left:250px; padding:20px; }
</style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <h3 class="text-center py-3"><i class="fas fa-building me-2"></i>InmoConnect</h3>
        <a href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
        <a href="propiedades.jsp"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
        <a href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Mis Citas</a>
        <a href="transacciones.jsp" class="active"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
        <a href="perfil.jsp"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
        <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Añadir Transacción</h2>
        </div>

        <div class="card shadow">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Registrar Nueva Transacción</h5>
            </div>
            <div class="card-body">
                <form action="procesarAgregarTransaccion.jsp" method="post" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label for="cliente" class="form-label">Cliente *</label>
                        <select class="form-select" id="cliente" name="cliente_id" required>
                            <option value="">Seleccione un cliente</option>
                            <% for (Map<String,Object> c : clientes) { %>
                                <option value="<%= c.get("id_usuario") %>"><%= c.get("nombre") %></option>
                            <% } %>
                        </select>
                        <div class="invalid-feedback">Seleccione un cliente.</div>
                    </div>

                    <div class="mb-3">
                        <label for="propiedad" class="form-label">Propiedad *</label>
                        <select class="form-select" id="propiedad" name="propiedad_id" required>
                            <option value="">Seleccione una propiedad</option>
                            <% for (Map<String,Object> p : propiedades) { %>
                                <option value="<%= p.get("id_propiedad") %>"><%= p.get("titulo") %></option>
                            <% } %>
                        </select>
                        <div class="invalid-feedback">Seleccione una propiedad.</div>
                    </div>

                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label for="tipo" class="form-label">Tipo *</label>
                            <select class="form-select" id="tipo" name="tipo" required>
                                <option value="venta">Venta</option>
                                <option value="alquiler">Alquiler</option>
                            </select>
                            <div class="invalid-feedback">Seleccione un tipo.</div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="fecha" class="form-label">Fecha *</label>
                            <input type="date" class="form-control" id="fecha" name="fecha" required>
                            <div class="invalid-feedback">Ingrese una fecha.</div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="monto" class="form-label">Monto *</label>
                            <input type="number" step="0.01" class="form-control" id="monto" name="monto" required>
                            <div class="invalid-feedback">Ingrese un monto válido.</div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="estado" class="form-label">Estado *</label>
                        <select class="form-select" id="estado" name="estado" required>
                            <option value="pendiente">Pendiente</option>
                            <option value="pagada">Pagada</option>
                            <option value="demorada">Demorada</option>
                            <option value="verificar">Verificar</option>
                        </select>
                        <div class="invalid-feedback">Seleccione un estado.</div>
                    </div>

                    <div class="text-end">
                        <a href="transacciones.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i>Cancelar</a>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i>Guardar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        'use strict';
        const forms = document.querySelectorAll('.needs-validation');
        Array.from(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    })();
</script>
</body>
</html>
