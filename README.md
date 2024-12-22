# IntegratedPhysicalSecurity

## Descripción del Proyecto

El proyecto **IntegratedPhysicalSecurity** es una solución integral de seguridad física basada en una arquitectura de microservicios. Los microservicios permiten gestionar distintos aspectos de la seguridad física, como control de acceso, vigilancia, supervisión perimetral, gestión de emergencias, entre otros. 

La aplicación está diseñada para manejar grandes volúmenes de tráfico en tiempo real y ofrece una arquitectura escalable y resiliente. Los servicios se comunican entre sí de manera eficiente utilizando **RESTful APIs** o **mensajería asíncrona** mediante **RabbitMQ**. 

## Microservicios

Los siguientes microservicios están definidos en el proyecto:

1. **Control de Acceso**
2. **Vigilancia y Monitoreo**
3. **Supervisión Perimetral**
4. **Alarmas y Respuesta**
5. **Gestión de Emergencias**
6. **Reportes y Auditoría**
7. **Gestión de Personal de Seguridad**
8. **Integración Tecnológica**
9. **Detección y Prevención**
10. **Comunicación y Notificaciones**
11. **Detección de Amenazas Usando Inteligencia Artificial**

## Características Clave

- **Arquitectura de Microservicios**: Utiliza Spring Boot para cada microservicio, desplegados mediante Docker Compose.
- **Persistencia de Datos**: Utiliza Oracle para bases de datos relacionales y MongoDB para datos no estructurados.
- **Escalabilidad Horizontal**: Soporta autoescalado mediante Docker Compose y balanceo de carga.
- **Manejo de Fallos**: Implementación de patrones de tolerancia a fallos (Circuit Breaker y Retry) con Resilience4j.
- **Seguridad**: Autenticación mediante **JWT** para proteger las comunicaciones entre microservicios.
- **Monitoreo y Logging**: Monitoreo de métricas y trazabilidad de logs centralizados.
- **Pruebas y Validación**: Pruebas unitarias, integración, stress testing, y load testing con Gatling.
- **Documentación de API**: Generación de documentación interactiva usando OpenAPI.

## Requisitos

- **JDK 11** o superior
- **Docker** y **Docker Compose** para orquestar los microservicios
- **Oracle Database** (se utiliza imagen oficial de Docker para la base de datos)
- **RabbitMQ** (opcional para mensajería asíncrona)
  
## Instalación

Sigue estos pasos para poner en marcha el proyecto:

### Clonar el repositorio

Primero, clona el repositorio en tu máquina local:

```bash
git clone https://github.com/tu-usuario/integrated-physical-security.git
cd integrated-physical-security

# Contributing  
Contributions are welcome! Please fork the repository and submit a pull request with detailed notes.

# License  
This project is licensed under the MIT License.

---  
For more information, contact jerry.felipe@gmail.com.
