<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Obtener la sesión actual
if (session != null) {
    // Invalidar la sesión
    session.invalidate();
}

// Redirigir al login
response.sendRedirect("login.jsp");
%>
