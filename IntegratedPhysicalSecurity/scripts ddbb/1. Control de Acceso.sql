-- Scripts de Oracle para el Sistema de Control de Acceso

-- CREACIÓN DE TABLAS PRINCIPALES
-- Tabla de empleados
CREATE TABLE Empleados (
    id_empleado NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    cargo VARCHAR2(50),
    departamento VARCHAR2(50),
    fecha_ingreso DATE
);

-- Tabla de visitantes
CREATE TABLE Visitantes (
    id_visitante NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    motivo_visita VARCHAR2(200),
    id_empleado_referido NUMBER,
    FOREIGN KEY (id_empleado_referido) REFERENCES Empleados(id_empleado)
);

-- Tabla de vehículos
CREATE TABLE Vehiculos (
    id_vehiculo NUMBER PRIMARY KEY,
    placa VARCHAR2(20) NOT NULL UNIQUE,
    tipo VARCHAR2(50),
    id_propietario NUMBER NOT NULL,
    tipo_propietario VARCHAR2(10) CHECK (tipo_propietario IN ('Empleado', 'Visitante')),
    FOREIGN KEY (id_propietario) REFERENCES Empleados(id_empleado),
    FOREIGN KEY (id_propietario) REFERENCES Visitantes(id_visitante)
);

-- Tabla de accesos
CREATE TABLE Accesos (
    id_acceso NUMBER PRIMARY KEY,
    tipo_acceso VARCHAR2(20) CHECK (tipo_acceso IN ('Entrada', 'Salida')),
    id_persona NUMBER NOT NULL,
    tipo_persona VARCHAR2(10) CHECK (tipo_persona IN ('Empleado', 'Visitante')),
    id_vehiculo NUMBER,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    zona_acceso VARCHAR2(50),
    FOREIGN KEY (id_persona) REFERENCES Empleados(id_empleado),
    FOREIGN KEY (id_persona) REFERENCES Visitantes(id_visitante),
    FOREIGN KEY (id_vehiculo) REFERENCES Vehiculos(id_vehiculo)
);

-- Tabla de niveles de acceso
CREATE TABLE Niveles_Acceso (
    id_nivel NUMBER PRIMARY KEY,
    nombre_nivel VARCHAR2(50) NOT NULL UNIQUE,
    descripcion VARCHAR2(200)
);

-- Tabla de permisos
CREATE TABLE Permisos (
    id_permiso NUMBER PRIMARY KEY,
    id_persona NUMBER NOT NULL,
    tipo_persona VARCHAR2(10) CHECK (tipo_persona IN ('Empleado', 'Visitante')),
    id_nivel NUMBER NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (id_persona) REFERENCES Empleados(id_empleado),
    FOREIGN KEY (id_persona) REFERENCES Visitantes(id_visitante),
    FOREIGN KEY (id_nivel) REFERENCES Niveles_Acceso(id_nivel)
);

-- Tabla de auditoría
CREATE TABLE Auditoria (
    id_evento NUMBER PRIMARY KEY,
    id_usuario NUMBER NOT NULL,
    tipo_usuario VARCHAR2(10) CHECK (tipo_usuario IN ('Empleado', 'Visitante')),
    accion VARCHAR2(200) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de notificaciones
CREATE TABLE Notificaciones (
    id_notificacion NUMBER PRIMARY KEY,
    mensaje VARCHAR2(200) NOT NULL,
    id_destinatario NUMBER NOT NULL,
    tipo_destinatario VARCHAR2(10) CHECK (tipo_destinatario IN ('Empleado', 'Visitante')),
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RELACIONES ENTRE MÓDULOS
-- Registro de eventos relacionados con accesos
CREATE TABLE Registro_Eventos (
    id_evento NUMBER PRIMARY KEY,
    id_acceso NUMBER NOT NULL,
    tipo_evento VARCHAR2(50),
    descripcion VARCHAR2(200),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_acceso) REFERENCES Accesos(id_acceso)
);

-- Scripts para otros módulos
-- Tabla de zonas de vigilancia
CREATE TABLE Zonas (
    id_zona NUMBER PRIMARY KEY,
    nombre_zona VARCHAR2(100) NOT NULL UNIQUE,
    descripcion VARCHAR2(200)
);

-- Tabla de alarmas
CREATE TABLE Alarmas (
    id_alarma NUMBER PRIMARY KEY,
    tipo_alarma VARCHAR2(50),
    id_zona NUMBER NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_zona) REFERENCES Zonas(id_zona)
);

-- Tabla de personal de seguridad
CREATE TABLE Personal_Seguridad (
    id_personal NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    turno VARCHAR2(50),
    id_zona NUMBER,
    FOREIGN KEY (id_zona) REFERENCES Zonas(id_zona)
);

-- CONFIGURACIÓN DE INTELIGENCIA ARTIFICIAL
-- Detección de amenazas usando AI
CREATE TABLE Deteccion_Amenazas (
    id_amenaza NUMBER PRIMARY KEY,
    tipo_amenaza VARCHAR2(50),
    nivel_riesgo VARCHAR2(50),
    fecha_detectada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_zona NUMBER NOT NULL,
    FOREIGN KEY (id_zona) REFERENCES Zonas(id_zona)
);

-- VISTAS Y CONSULTAS
-- Vista de actividad reciente
CREATE OR REPLACE VIEW Actividad_Reciente AS
SELECT a.id_acceso, a.tipo_acceso, a.fecha_hora, a.zona_acceso, 
       CASE a.tipo_persona 
           WHEN 'Empleado' THEN e.nombre || ' ' || e.apellido
           WHEN 'Visitante' THEN v.nombre || ' ' || v.apellido
       END AS persona
FROM Accesos a
LEFT JOIN Empleados e ON a.id_persona = e.id_empleado
LEFT JOIN Visitantes v ON a.id_persona = v.id_visitante;

-- Vistas de registros para auditoría
CREATE OR REPLACE VIEW Auditoria_Reciente AS
SELECT *
FROM Auditoria
WHERE fecha_hora >= SYSDATE - 7; -- Últimos 7 días

-- TRIGGERS PARA AUDITORÍA
-- Trigger para registrar actividades en auditoría
CREATE OR REPLACE TRIGGER trg_auditoria_accesos
AFTER INSERT OR UPDATE OR DELETE ON Accesos
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (id_usuario, tipo_usuario, accion, fecha_hora)
    VALUES (:NEW.id_persona, :NEW.tipo_persona, 'Cambio en accesos', SYSTIMESTAMP);
END;

-- TRIGGERS PARA NOTIFICACIONES
-- Trigger para enviar notificación en caso de accesos no autorizados
CREATE OR REPLACE TRIGGER trg_notificacion_acceso_no_autorizado
AFTER INSERT ON Accesos
FOR EACH ROW
WHEN (NEW.zona_acceso IS NOT NULL AND NEW.tipo_acceso = 'Entrada')
BEGIN
    INSERT INTO Notificaciones (mensaje, id_destinatario, tipo_destinatario, fecha_envio)
    VALUES ('Acceso no autorizado detectado en zona ' || NEW.zona_acceso, NEW.id_persona, NEW.tipo_persona, SYSTIMESTAMP);
END;

-- FIN DEL SCRIPT
