-- SCRIPT PARA EL MÓDULO DE VIGILANCIA Y MONITOREO
-- 1. Creación de tablas relacionadas con Vigilancia y Monitoreo

-- Tabla para cámaras de seguridad (CCTV)
CREATE TABLE CCTV_CAMERAS (
    CAMERA_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    CAMERA_NAME VARCHAR2(100) NOT NULL,
    LOCATION VARCHAR2(255),
    STATUS VARCHAR2(20) DEFAULT 'ACTIVE',
    INSTALLATION_DATE DATE,
    LAST_MAINTENANCE_DATE DATE
);

-- Tabla para almacenamiento de grabaciones
CREATE TABLE CCTV_RECORDINGS (
    RECORDING_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    CAMERA_ID NUMBER NOT NULL REFERENCES CCTV_CAMERAS(CAMERA_ID),
    RECORDING_START_TIME TIMESTAMP NOT NULL,
    RECORDING_END_TIME TIMESTAMP NOT NULL,
    FILE_PATH VARCHAR2(500) NOT NULL,
    STORAGE_SIZE_MB NUMBER,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para análisis de video
CREATE TABLE VIDEO_ANALYSIS (
    ANALYSIS_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    RECORDING_ID NUMBER NOT NULL REFERENCES CCTV_RECORDINGS(RECORDING_ID),
    ANALYSIS_TYPE VARCHAR2(50), -- Ejemplo: 'Motion Detection', 'Facial Recognition'
    RESULT VARCHAR2(500),
    DETECTED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para monitoreo remoto de áreas críticas
CREATE TABLE CRITICAL_AREAS (
    AREA_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    AREA_NAME VARCHAR2(100) NOT NULL,
    DESCRIPTION VARCHAR2(500),
    LOCATION VARCHAR2(255),
    MONITORED_BY NUMBER REFERENCES CCTV_CAMERAS(CAMERA_ID)
);

-- Tabla para registros de eventos relacionados con el monitoreo
CREATE TABLE MONITORING_EVENTS (
    EVENT_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    CAMERA_ID NUMBER REFERENCES CCTV_CAMERAS(CAMERA_ID),
    AREA_ID NUMBER REFERENCES CRITICAL_AREAS(AREA_ID),
    EVENT_TYPE VARCHAR2(50), -- Ejemplo: 'Unauthorized Access', 'Suspicious Activity'
    EVENT_DESCRIPTION VARCHAR2(500),
    DETECTED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para auditorías
CREATE TABLE MONITORING_AUDIT_LOG (
    AUDIT_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    EVENT_ID NUMBER REFERENCES MONITORING_EVENTS(EVENT_ID),
    ACTION_PERFORMED VARCHAR2(255),
    PERFORMED_BY VARCHAR2(100),
    ACTION_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para notificaciones
CREATE TABLE MONITORING_NOTIFICATIONS (
    NOTIFICATION_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    EVENT_ID NUMBER REFERENCES MONITORING_EVENTS(EVENT_ID),
    RECIPIENT VARCHAR2(100),
    NOTIFICATION_TYPE VARCHAR2(50), -- Ejemplo: 'Email', 'SMS'
    STATUS VARCHAR2(20) DEFAULT 'PENDING',
    SENT_AT TIMESTAMP
);

-- 2. Creación de índices para optimización
CREATE INDEX IDX_CAMERA_LOCATION ON CCTV_CAMERAS(LOCATION);
CREATE INDEX IDX_EVENT_TYPE ON MONITORING_EVENTS(EVENT_TYPE);

-- 3. Creación de triggers para automatización
-- Trigger para agregar un registro de auditoría cada vez que se detecte un evento
CREATE OR REPLACE TRIGGER TRG_MONITORING_EVENT_AUDIT
AFTER INSERT ON MONITORING_EVENTS
FOR EACH ROW
BEGIN
    INSERT INTO MONITORING_AUDIT_LOG (EVENT_ID, ACTION_PERFORMED, PERFORMED_BY, ACTION_TIMESTAMP)
    VALUES (:NEW.EVENT_ID, 'Event detected: ' || :NEW.EVENT_TYPE, 'System', SYSTIMESTAMP);
END;
/

-- Trigger para enviar notificaciones automáticamente
CREATE OR REPLACE TRIGGER TRG_MONITORING_EVENT_NOTIFICATION
AFTER INSERT ON MONITORING_EVENTS
FOR EACH ROW
BEGIN
    INSERT INTO MONITORING_NOTIFICATIONS (EVENT_ID, RECIPIENT, NOTIFICATION_TYPE, STATUS)
    VALUES (:NEW.EVENT_ID, 'admin@example.com', 'Email', 'PENDING');
END;
/

-- 4. Procedimientos almacenados para tareas comunes
-- Procedimiento para registrar un nuevo evento
CREATE OR REPLACE PROCEDURE SP_REGISTER_EVENT (
    P_CAMERA_ID NUMBER,
    P_AREA_ID NUMBER,
    P_EVENT_TYPE VARCHAR2,
    P_EVENT_DESCRIPTION VARCHAR2
) AS
BEGIN
    INSERT INTO MONITORING_EVENTS (CAMERA_ID, AREA_ID, EVENT_TYPE, EVENT_DESCRIPTION)
    VALUES (P_CAMERA_ID, P_AREA_ID, P_EVENT_TYPE, P_EVENT_DESCRIPTION);
END;
/

-- Procedimiento para actualizar el estado de una notificación
CREATE OR REPLACE PROCEDURE SP_UPDATE_NOTIFICATION_STATUS (
    P_NOTIFICATION_ID NUMBER,
    P_STATUS VARCHAR2
) AS
BEGIN
    UPDATE MONITORING_NOTIFICATIONS
    SET STATUS = P_STATUS,
        SENT_AT = SYSTIMESTAMP
    WHERE NOTIFICATION_ID = P_NOTIFICATION_ID;
END;
/

-- 5. Vistas para reportes
-- Vista para eventos recientes
CREATE OR REPLACE VIEW VW_RECENT_EVENTS AS
SELECT E.EVENT_ID, C.CAMERA_NAME, A.AREA_NAME, E.EVENT_TYPE, E.EVENT_DESCRIPTION, E.DETECTED_AT
FROM MONITORING_EVENTS E
JOIN CCTV_CAMERAS C ON E.CAMERA_ID = C.CAMERA_ID
LEFT JOIN CRITICAL_AREAS A ON E.AREA_ID = A.AREA_ID
WHERE E.DETECTED_AT >= SYSDATE - 7;

-- Vista para auditorías recientes
CREATE OR REPLACE VIEW VW_RECENT_AUDITS AS
SELECT A.AUDIT_ID, A.ACTION_PERFORMED, A.PERFORMED_BY, A.ACTION_TIMESTAMP, E.EVENT_TYPE
FROM MONITORING_AUDIT_LOG A
JOIN MONITORING_EVENTS E ON A.EVENT_ID = E.EVENT_ID
WHERE A.ACTION_TIMESTAMP >= SYSDATE - 30;