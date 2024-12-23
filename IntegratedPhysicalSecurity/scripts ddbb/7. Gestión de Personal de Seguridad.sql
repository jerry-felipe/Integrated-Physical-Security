-- SCRIPT DE CREACIÓN DE TABLAS PARA GESTIÓN DE PERSONAL DE SEGURIDAD

-- Tabla para registrar el personal de seguridad
CREATE TABLE SEGURIDAD_PERSONAL (
    ID_PERSONAL NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    NOMBRE VARCHAR2(100) NOT NULL,
    APELLIDO VARCHAR2(100) NOT NULL,
    CEDULA VARCHAR2(15) UNIQUE NOT NULL,
    FECHA_INGRESO DATE DEFAULT SYSDATE NOT NULL,
    ESTADO VARCHAR2(20) DEFAULT 'ACTIVO' CHECK (ESTADO IN ('ACTIVO', 'INACTIVO')),
    CONTACTO VARCHAR2(50),
    ID_SUPERVISOR NUMBER,
    FOREIGN KEY (ID_SUPERVISOR) REFERENCES SEGURIDAD_PERSONAL(ID_PERSONAL) ON DELETE SET NULL
);

-- Tabla para registrar rondas de vigilancia
CREATE TABLE RONDAS_VIGILANCIA (
    ID_RONDA NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ID_PERSONAL NUMBER NOT NULL,
    FECHA_HORA_INICIO TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FECHA_HORA_FIN TIMESTAMP,
    ZONA_ASIGNADA VARCHAR2(100),
    COMENTARIOS VARCHAR2(255),
    FOREIGN KEY (ID_PERSONAL) REFERENCES SEGURIDAD_PERSONAL(ID_PERSONAL) ON DELETE CASCADE
);

-- Tabla para registrar geolocalización de rondas
CREATE TABLE GEOLOCALIZACION_RONDAS (
    ID_GEO NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ID_RONDA NUMBER NOT NULL,
    FECHA_HORA TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    LATITUD NUMBER(10, 6) NOT NULL,
    LONGITUD NUMBER(10, 6) NOT NULL,
    FOREIGN KEY (ID_RONDA) REFERENCES RONDAS_VIGILANCIA(ID_RONDA) ON DELETE CASCADE
);

-- Tabla para registrar entrenamiento y capacitación
CREATE TABLE CAPACITACION_PERSONAL (
    ID_CAPACITACION NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ID_PERSONAL NUMBER NOT NULL,
    TIPO_CAPACITACION VARCHAR2(100) NOT NULL,
    FECHA_CAPACITACION DATE DEFAULT SYSDATE NOT NULL,
    DETALLES VARCHAR2(255),
    FOREIGN KEY (ID_PERSONAL) REFERENCES SEGURIDAD_PERSONAL(ID_PERSONAL) ON DELETE CASCADE
);

-- Tabla para evaluaciones de desempeño
CREATE TABLE EVALUACIONES_DESEMPENO (
    ID_EVALUACION NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ID_PERSONAL NUMBER NOT NULL,
    FECHA_EVALUACION DATE DEFAULT SYSDATE NOT NULL,
    INCIDENTES_GESTIONADOS NUMBER DEFAULT 0,
    RESPUESTA_PROMEDIO_MINUTOS NUMBER(5, 2),
    CALIFICACION VARCHAR2(10) CHECK (CALIFICACION IN ('EXCELENTE', 'BUENO', 'REGULAR', 'DEFICIENTE')),
    COMENTARIOS VARCHAR2(255),
    FOREIGN KEY (ID_PERSONAL) REFERENCES SEGURIDAD_PERSONAL(ID_PERSONAL) ON DELETE CASCADE
);

-- Tabla para notificaciones relacionadas con el personal
CREATE TABLE NOTIFICACIONES_PERSONAL (
    ID_NOTIFICACION NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ID_PERSONAL NUMBER NOT NULL,
    TIPO_NOTIFICACION VARCHAR2(50) NOT NULL,
    FECHA_HORA TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    MENSAJE VARCHAR2(255),
    ESTADO VARCHAR2(20) DEFAULT 'PENDIENTE' CHECK (ESTADO IN ('PENDIENTE', 'ENVIADO', 'LEIDO')),
    FOREIGN KEY (ID_PERSONAL) REFERENCES SEGURIDAD_PERSONAL(ID_PERSONAL) ON DELETE CASCADE
);

-- Tabla para registro de auditoría
CREATE TABLE AUDITORIA_PERSONAL (
    ID_AUDITORIA NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    FECHA_HORA TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ID_USUARIO NUMBER,
    ACCION VARCHAR2(100) NOT NULL,
    DETALLES VARCHAR2(255)
);

-- TRIGGERS PARA REGISTRO AUTOMÁTICO EN AUDITORÍA
CREATE OR REPLACE TRIGGER TRG_AUDITORIA_SEGURIDAD_PERSONAL
AFTER INSERT OR UPDATE OR DELETE ON SEGURIDAD_PERSONAL
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_PERSONAL (ID_USUARIO, ACCION, DETALLES)
    VALUES (
        USER,
        CASE WHEN INSERTING THEN 'INSERCIÓN'
             WHEN UPDATING THEN 'ACTUALIZACIÓN'
             WHEN DELETING THEN 'ELIMINACIÓN' END,
        'Tabla SEGURIDAD_PERSONAL, ID_PERSONAL=' || :OLD.ID_PERSONAL || ' o ' || :NEW.ID_PERSONAL
    );
END;
/

-- PROCEDIMIENTOS PARA NOTIFICACIONES
CREATE OR REPLACE PROCEDURE ENVIAR_NOTIFICACION_PERSONAL (
    p_id_personal NUMBER,
    p_tipo_notificacion VARCHAR2,
    p_mensaje VARCHAR2
) AS
BEGIN
    INSERT INTO NOTIFICACIONES_PERSONAL (ID_PERSONAL, TIPO_NOTIFICACION, MENSAJE)
    VALUES (p_id_personal, p_tipo_notificacion, p_mensaje);
END;
/

-- VISTAS PARA REPORTES
CREATE OR REPLACE VIEW REPORTE_EVALUACIONES AS
SELECT 
    P.NOMBRE || ' ' || P.APELLIDO AS NOMBRE_COMPLETO,
    E.FECHA_EVALUACION,
    E.INCIDENTES_GESTIONADOS,
    E.RESPUESTA_PROMEDIO_MINUTOS,
    E.CALIFICACION,
    E.COMENTARIOS
FROM 
    SEGURIDAD_PERSONAL P
    JOIN EVALUACIONES_DESEMPENO E ON P.ID_PERSONAL = E.ID_PERSONAL;

CREATE OR REPLACE VIEW REPORTE_RONDAS AS
SELECT 
    P.NOMBRE || ' ' || P.APELLIDO AS NOMBRE_COMPLETO,
    R.FECHA_HORA_INICIO,
    R.FECHA_HORA_FIN,
    R.ZONA_ASIGNADA,
    R.COMENTARIOS
FROM 
    SEGURIDAD_PERSONAL P
    JOIN RONDAS_VIGILANCIA R ON P.ID_PERSONAL = R.ID_PERSONAL;
