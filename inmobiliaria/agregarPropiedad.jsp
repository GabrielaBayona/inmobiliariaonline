<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Validación: usuario autenticado y rol = inmobiliaria
    if (session == null || session.getAttribute("usuario_id") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Integer rolId = (Integer) session.getAttribute("usuario_rol_id");
    if (rolId == null || rolId != 3) {  // 3 = Inmobiliaria
        response.sendRedirect("../login.jsp");
        return;
    }

    String nombreUsuario = (String) session.getAttribute("usuario_nombre");
    int usuarioId = (Integer) session.getAttribute("usuario_id");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Agregar Propiedad - InmoConnect</title>
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
        <a href="propiedades.jsp" class="active"><i class="fas fa-home me-2"></i>Mis Propiedades</a>
        <a href="citas.jsp"><i class="fas fa-calendar-check me-2"></i>Citas</a>
        <a href="transacciones.jsp"><i class="fas fa-money-bill-wave me-2"></i>Transacciones</a>
        <a href="perfil.jsp"><i class="fas fa-user-edit me-2"></i>Mi Perfil</a>
        <a href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a>
    </div>

    <div class="main-content">
        <h2 class="mb-4">Agregar Nueva Propiedad</h2>
        <div class="card shadow">
            <div class="card-body">
                <form method="post" action="procesarAgregarPropiedad.jsp" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label for="titulo" class="form-label">Título *</label>
                        <input type="text" class="form-control" id="titulo" name="titulo" required>
                        <div class="invalid-feedback">Ingrese un título.</div>
                    </div>

                    <div class="mb-3">
                        <label for="descripcion" class="form-label">Descripción</label>
                        <textarea class="form-control" id="descripcion" name="descripcion" rows="3"></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="precio" class="form-label">Precio *</label>
                        <input type="number" step="0.01" class="form-control" id="precio" name="precio" required>
                        <div class="invalid-feedback">Ingrese un precio válido.</div>
                    </div>

                    <div class="mb-3">
                        <label for="tipo" class="form-label">Tipo *</label>
                        <select class="form-select" id="tipo" name="tipo" required>
                            <option value="">Seleccionar...</option>
                            <option value="venta">Venta</option>
                            <option value="alquiler">Alquiler</option>
                        </select>
                        <div class="invalid-feedback">Seleccione un tipo.</div>
                    </div>

                    <div class="mb-3">
                        <label for="estado" class="form-label">Estado *</label>
                        <select class="form-select" id="estado" name="estado" required>
                            <option value="disponible">Disponible</option>
                            <option value="vendida">Vendida</option>
                            <option value="alquilada">Alquilada</option>
                        </select>
                        <div class="invalid-feedback">Seleccione un estado.</div>
                    </div>

                    <div class="mb-3">
                        <label for="ubicacion" class="form-label">Ubicación *</label>
                        <input type="text" class="form-control" id="ubicacion" name="ubicacion" required>
                        <div class="invalid-feedback">Ingrese una ubicación.</div>
                    </div>

                    <div class="text-end">
                        <a href="propiedades.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i>Cancelar</a>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i>Guardar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Bootstrap validation
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
