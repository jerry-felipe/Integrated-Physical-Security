# Imagen oficial de Tomcat como base
FROM tomcat:9.0-jdk11-openjdk-slim

# Directorio de trabajo
WORKDIR /usr/local/tomcat/webapps

# Copiar el archivo WAR a la carpeta webapps de Tomcat
COPY target/IntegratedPhysicalSecurity.war /usr/local/tomcat/webapps/

# Puerto 8080 para que el contenedor sea accesible
EXPOSE 8080

# Comando para iniciar Tomcat
CMD ["catalina.sh", "run"]
