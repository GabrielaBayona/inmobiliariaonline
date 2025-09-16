// =====================================================
// SCRIPTS DEL DASHBOARD ADMINISTRATIVO - INMOCONNECT
// =====================================================

// Clase para manejar notificaciones
class NotificationManager {
    static show(message, type = 'info', duration = 5000) {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // Mostrar notificación
        setTimeout(() => {
            notification.classList.add('show');
        }, 100);
        
        // Ocultar y remover notificación
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, duration);
    }
    
    static success(message, duration) {
        this.show(message, 'success', duration);
    }
    
    static error(message, duration) {
        this.show(message, 'error', duration);
    }
    
    static warning(message, duration) {
        this.show(message, 'warning', duration);
    }
    
    static info(message, duration) {
        this.show(message, 'info', duration);
    }
}

// Clase para manejar el sidebar móvil
class SidebarManager {
    constructor() {
        this.sidebar = document.querySelector('.sidebar');
        this.toggleButton = document.querySelector('.sidebar-toggle');
        this.init();
    }
    
    init() {
        if (this.toggleButton) {
            this.toggleButton.addEventListener('click', () => {
                this.toggle();
            });
        }
        
        // Cerrar sidebar al hacer clic fuera en móvil
        document.addEventListener('click', (e) => {
            if (window.innerWidth <= 768 && 
                !this.sidebar.contains(e.target) && 
                !this.toggleButton?.contains(e.target)) {
                this.hide();
            }
        });
    }
    
    toggle() {
        this.sidebar.classList.toggle('show');
    }
    
    show() {
        this.sidebar.classList.add('show');
    }
    
    hide() {
        this.sidebar.classList.remove('show');
    }
}

// Clase para manejar las tarjetas de estadísticas
class StatsManager {
    constructor() {
        this.cards = document.querySelectorAll('.card');
        this.init();
    }
    
    init() {
        this.animateCards();
        this.setupRefresh();
    }
    
    animateCards() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, { threshold: 0.1 });
        
        this.cards.forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(card);
        });
    }
    
    setupRefresh() {
        // Actualizar estadísticas cada 30 segundos
        setInterval(() => {
            this.refreshStats();
        }, 30000);
    }
    
    async refreshStats() {
        try {
            const response = await fetch('get-stats.jsp');
            if (response.ok) {
                const stats = await response.json();
                this.updateStatsDisplay(stats);
            }
        } catch (error) {
            console.error('Error al actualizar estadísticas:', error);
        }
    }
    
    updateStatsDisplay(stats) {
        // Actualizar números en las tarjetas
        if (stats.totalUsuarios !== undefined) {
            const element = document.querySelector('[data-stat="usuarios"]');
            if (element) {
                element.textContent = stats.totalUsuarios;
            }
        }
        
        if (stats.totalPropiedades !== undefined) {
            const element = document.querySelector('[data-stat="propiedades"]');
            if (element) {
                element.textContent = stats.totalPropiedades;
            }
        }
        
        if (stats.totalCitas !== undefined) {
            const element = document.querySelector('[data-stat="citas"]');
            if (element) {
                element.textContent = stats.totalCitas;
            }
        }
        
        if (stats.totalTransacciones !== undefined) {
            const element = document.querySelector('[data-stat="transacciones"]');
            if (element) {
                element.textContent = stats.totalTransacciones;
            }
        }
    }
}

// Clase para manejar la exportación de reportes
class ReportExporter {
    static async exportDashboard() {
        try {
            const response = await fetch('export-dashboard.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const blob = await response.blob();
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `dashboard-reporte-${new Date().toISOString().split('T')[0]}.pdf`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
                
                NotificationManager.success('Reporte exportado exitosamente');
            } else {
                throw new Error('Error al exportar reporte');
            }
        } catch (error) {
            console.error('Error en exportación:', error);
            NotificationManager.error('Error al exportar reporte');
        }
    }
    
    static async exportCSV(tableId, filename) {
        try {
            const table = document.getElementById(tableId);
            if (!table) {
                throw new Error('Tabla no encontrada');
            }
            
            const csv = this.tableToCSV(table);
            const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename || 'export.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
            
            NotificationManager.success('CSV exportado exitosamente');
        } catch (error) {
            console.error('Error al exportar CSV:', error);
            NotificationManager.error('Error al exportar CSV');
        }
    }
    
    static tableToCSV(table) {
        const rows = table.querySelectorAll('tr');
        const csv = [];
        
        for (let i = 0; i < rows.length; i++) {
            const row = [];
            const cols = rows[i].querySelectorAll('td, th');
            
            for (let j = 0; j < cols.length; j++) {
                let text = cols[j].innerText;
                text = text.replace(/"/g, '""');
                row.push('"' + text + '"');
            }
            
            csv.push(row.join(','));
        }
        
        return csv.join('\n');
    }
}

// Clase para manejar la validación de formularios
class FormValidator {
    static validateRequired(field, message = 'Este campo es requerido') {
        if (!field.value.trim()) {
            this.showError(field, message);
            return false;
        }
        this.hideError(field);
        return true;
    }
    
    static validateEmail(field, message = 'Email inválido') {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(field.value)) {
            this.showError(field, message);
            return false;
        }
        this.hideError(field);
        return true;
    }
    
    static validateLength(field, min, max, message = 'Longitud inválida') {
        const length = field.value.length;
        if (length < min || length > max) {
            this.showError(field, `${message} (${min}-${max} caracteres)`);
            return false;
        }
        this.hideError(field);
        return true;
    }
    
    static showError(field, message) {
        this.hideError(field);
        
        const errorDiv = document.createElement('div');
        errorDiv.className = 'invalid-feedback';
        errorDiv.textContent = message;
        
        field.classList.add('is-invalid');
        field.parentNode.appendChild(errorDiv);
    }
    
    static hideError(field) {
        field.classList.remove('is-invalid');
        const errorDiv = field.parentNode.querySelector('.invalid-feedback');
        if (errorDiv) {
            errorDiv.remove();
        }
    }
    
    static validateForm(form) {
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;
        
        requiredFields.forEach(field => {
            if (!this.validateRequired(field)) {
                isValid = false;
            }
        });
        
        return isValid;
    }
}

// Clase para manejar las tablas de datos
class DataTableManager {
    constructor(tableId, options = {}) {
        this.table = document.getElementById(tableId);
        this.options = {
            searchable: true,
            sortable: true,
            pagination: true,
            pageSize: 10,
            ...options
        };
        
        if (this.table) {
            this.init();
        }
    }
    
    init() {
        if (this.options.searchable) {
            this.addSearch();
        }
        
        if (this.options.sortable) {
            this.addSorting();
        }
        
        if (this.options.pagination) {
            this.addPagination();
        }
    }
    
    addSearch() {
        const searchContainer = document.createElement('div');
        searchContainer.className = 'mb-3';
        searchContainer.innerHTML = `
            <div class="input-group">
                <span class="input-group-text"><i class="fas fa-search"></i></span>
                <input type="text" class="form-control" placeholder="Buscar..." id="search-${this.table.id}">
            </div>
        `;
        
        this.table.parentNode.insertBefore(searchContainer, this.table);
        
        const searchInput = searchContainer.querySelector('input');
        searchInput.addEventListener('input', (e) => {
            this.filterTable(e.target.value);
        });
    }
    
    filterTable(searchTerm) {
        const rows = this.table.querySelectorAll('tbody tr');
        const term = searchTerm.toLowerCase();
        
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(term) ? '' : 'none';
        });
    }
    
    addSorting() {
        const headers = this.table.querySelectorAll('th[data-sortable]');
        
        headers.forEach(header => {
            header.style.cursor = 'pointer';
            header.addEventListener('click', () => {
                this.sortTable(header);
            });
        });
    }
    
    sortTable(header) {
        const column = Array.from(header.parentNode.children).indexOf(header);
        const tbody = this.table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        const isAscending = header.classList.contains('sort-asc');
        
        rows.sort((a, b) => {
            const aValue = a.children[column].textContent;
            const bValue = b.children[column].textContent;
            
            if (isAscending) {
                return bValue.localeCompare(aValue);
            } else {
                return aValue.localeCompare(bValue);
            }
        });
        
        // Limpiar clases de ordenamiento
        header.parentNode.querySelectorAll('th').forEach(th => {
            th.classList.remove('sort-asc', 'sort-desc');
        });
        
        // Agregar clase de ordenamiento
        header.classList.add(isAscending ? 'sort-desc' : 'sort-asc');
        
        // Reordenar filas
        rows.forEach(row => tbody.appendChild(row));
    }
    
    addPagination() {
        // Implementar paginación si es necesario
    }
}

// Inicialización cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', function() {
    // Inicializar managers
    new SidebarManager();
    new StatsManager();
    
    // Configurar tooltips de Bootstrap
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Configurar popovers de Bootstrap
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
    
    // Configurar validación de formularios
    const forms = document.querySelectorAll('.needs-validation');
    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            if (!FormValidator.validateForm(form)) {
                event.preventDefault();
                event.stopPropagation();
            }
        });
    });
    
    // Configurar tablas de datos
    const tables = document.querySelectorAll('table[data-datatable]');
    tables.forEach(table => {
        new DataTableManager(table.id, {
            searchable: true,
            sortable: true,
            pagination: false
        });
    });
    
    // Configurar confirmaciones de eliminación
    const deleteButtons = document.querySelectorAll('[data-confirm-delete]');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            const message = this.getAttribute('data-confirm-delete') || '¿Está seguro de que desea eliminar este elemento?';
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });
    
    // Configurar auto-hide para alertas
    const alerts = document.querySelectorAll('.alert-auto-hide');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });
    
    // Configurar actualización automática
    if (document.querySelector('[data-auto-refresh]')) {
        const refreshInterval = setInterval(() => {
            // Verificar si la página sigue activa
            if (document.hidden) {
                return;
            }
            
            // Recargar página
            location.reload();
        }, 300000); // 5 minutos
        
        // Limpiar intervalo cuando se abandone la página
        window.addEventListener('beforeunload', () => {
            clearInterval(refreshInterval);
        });
    }
});

// Función global para mostrar notificaciones
window.showNotification = function(message, type, duration) {
    NotificationManager.show(message, type, duration);
};

// Función global para exportar reportes
window.exportReport = function() {
    ReportExporter.exportDashboard();
};

// Función global para exportar CSV
window.exportCSV = function(tableId, filename) {
    ReportExporter.exportCSV(tableId, filename);
};
