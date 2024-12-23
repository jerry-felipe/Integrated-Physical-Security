-- 1. CREACIÓN DE TABLAS PARA COMUNICACIÓN Y NOTIFICACIONES

-- Tabla para notificaciones generadas\CREATE TABLE Notificaciones (
    NotificacionID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    TipoNotificacion VARCHAR2(50),
    FechaHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Destinatario VARCHAR2(100),
    Mensaje CLOB,
    MetodoEnvio VARCHAR2(50), -- Ejemplo: 'Email', 'SMS', 'Aplicación'
    Estado VARCHAR2(20), -- Ejemplo: 'Enviado', 'Error', 'Pendiente'
    EventoID NUMBER, -- Relacionado con la tabla de eventos
    FOREIGN KEY (EventoID) REFERENCES Eventos(EventoID)
);

-- Tabla para el registro de comunicación con el personal
CREATE TABLE ComunicacionPersonal (
    ComunicacionID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Remitente VARCHAR2(100),
    Destinatario VARCHAR2(100),
    FechaHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Mensaje CLOB,
    MetodoEnvio VARCHAR2(50),
    Estado VARCHAR2(20)
);

-- Tabla para coordinación con entidades externas
CREATE TABLE CoordinacionEntidadesExternas (
    CoordinacionID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    EntidadExterna VARCHAR2(100),
    FechaHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Mensaje CLOB,
    RespuestaEsperada VARCHAR2(200),
    Estado VARCHAR2(20)
);

-- 2. PROCEDIMIENTOS ALMACENADOS

-- Procedimiento para generar una notificación
CREATE OR REPLACE PROCEDURE GenerarNotificacion (
    p_TipoNotificacion IN VARCHAR2,
    p_Destinatario IN VARCHAR2,
    p_Mensaje IN CLOB,
    p_MetodoEnvio IN VARCHAR2,
    p_EventoID IN NUMBER
) AS
BEGIN
    INSERT INTO Notificaciones (TipoNotificacion, Destinatario, Mensaje, MetodoEnvio, EventoID, Estado)
    VALUES (p_TipoNotificacion, p_Destinatario, p_Mensaje, p_MetodoEnvio, p_EventoID, 'Pendiente');
END;
/

-- Procedimiento para registrar comunicación con el personal
CREATE OR REPLACE PROCEDURE RegistrarComunicacion (
    p_Remitente IN VARCHAR2,
    p_Destinatario IN VARCHAR2,
    p_Mensaje IN CLOB,
    p_MetodoEnvio IN VARCHAR2
) AS
BEGIN
    INSERT INTO ComunicacionPersonal (Remitente, Destinatario, Mensaje, MetodoEnvio, Estado)
    VALUES (p_Remitente, p_Destinatario, p_Mensaje, p_MetodoEnvio, 'Enviado');
END;
/

-- Procedimiento para registrar coordinación con entidades externas
CREATE OR REPLACE PROCEDURE RegistrarCoordinacion (
    p_EntidadExterna IN VARCHAR2,
    p_Mensaje IN CLOB,
    p_RespuestaEsperada IN VARCHAR2
) AS
BEGIN
    INSERT INTO CoordinacionEntidadesExternas (EntidadExterna, Mensaje, RespuestaEsperada, Estado)
    VALUES (p_EntidadExterna, p_Mensaje, p_RespuestaEsperada, 'Pendiente');
END;
/

-- 3. TRIGGERS

-- Trigger para cambiar el estado de una notificación al enviarse
CREATE OR REPLACE TRIGGER NotificacionEnvioTrigger
AFTER INSERT OR UPDATE ON Notificaciones
FOR EACH ROW
WHEN (NEW.Estado = 'Enviado')
BEGIN
    -- Lógica adicional, como registro en auditoría
    INSERT INTO Auditoria (Evento, Detalle, FechaHora)
    VALUES ('Notificacion Enviada', 'ID: ' || :NEW.NotificacionID, CURRENT_TIMESTAMP);
END;
/

-- 4. VISTAS PARA CONSULTAS

-- Vista de notificaciones pendientes
CREATE OR REPLACE VIEW VistaNotificacionesPendientes AS
SELECT *
FROM Notificaciones
WHERE Estado = 'Pendiente';

-- Vista de comunicación reciente con el personal
CREATE OR REPLACE VIEW VistaComunicacionReciente AS
SELECT *
FROM ComunicacionPersonal
WHERE FechaHora >= SYSDATE - 7; -- Últimos 7 días

-- Vista de coordinación activa con entidades externas
CREATE OR REPLACE VIEW VistaCoordinacionActiva AS
SELECT *
FROM CoordinacionEntidadesExternas
WHERE Estado = 'Pendiente';

-- 5. INTEGRACIÓN CON OTROS MÓDULOS

-- Ejemplo: Relación con el módulo de detección y prevención
ALTER TABLE Notificaciones ADD CONSTRAINT fk_notificacion_deteccion FOREIGN KEY (EventoID) REFERENCES DeteccionEventos(EventoID);
