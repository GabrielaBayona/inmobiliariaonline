FROM tomcat:8.5-jdk8

# Directorio de trabajo
WORKDIR /usr/local/tomcat/webapps/

# Copiar el proyecto
COPY . /usr/local/tomcat/webapps/InmobiliariaOnline/

# Copiar todas las librerías necesarias al Tomcat/lib
COPY ./WEB-INF/lib/*.jar /usr/local/tomcat/lib/

# Render asigna el puerto en la variable de entorno $PORT
# En lugar de modificar server.xml, usamos CATALINA_OPTS
ENV CATALINA_OPTS="-Dserver.port=${PORT:8080}"

# Exponer el puerto por defecto (Render lo ignora, pero es buena práctica)
EXPOSE 8080

# Comando de inicio de Tomcat
CMD ["catalina.sh", "run"]
