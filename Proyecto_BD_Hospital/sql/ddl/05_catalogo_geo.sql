-- ============================================================
-- 05_catalogo_geo.sql : CATALOGOS GEOGRAFICOS (3FN)
-- Normaliza municipio/departamento (repetidos como texto en
-- paciente, medico, encargado) subiendolos a catalogos.
-- Aplicado en vivo y replicado en los archivos de la entrega.
-- ============================================================
CREATE TABLE departamento (
    id_departamento       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(80)   NOT NULL UNIQUE
);
COMMENT ON TABLE departamento IS 'Catalogo de los 22 departamentos de Guatemala.';

CREATE TABLE municipio (
    id_municipio          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    departamento_id       INTEGER       NOT NULL REFERENCES departamento(id_departamento)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    nombre                VARCHAR(80)   NOT NULL,
    CONSTRAINT uq_municipio_departamento UNIQUE (departamento_id, nombre)
);
COMMENT ON TABLE municipio IS 'Catalogo de municipios por departamento (340 reales de GT).';

INSERT INTO departamento (nombre) VALUES ('Alta Verapaz'),('Baja Verapaz'),('Chimaltenango'),
 ('Chiquimula'),('El Progreso'),('Escuintla'),('Guatemala'),('Huehuetenango'),('Izabal'),
 ('Jalapa'),('Jutiapa'),('Petén'),('Quetzaltenango'),('Quiché'),('Retalhuleu'),
 ('Sacatepéquez'),('San Marcos'),('Santa Rosa'),('Sololá'),('Suchitepéquez'),
 ('Totonicapán'),('Zacapa');

INSERT INTO municipio (departamento_id, nombre) VALUES
 ((SELECT id_departamento FROM departamento WHERE nombre='Quetzaltenango'),'Quetzaltenango'),
 ((SELECT id_departamento FROM departamento WHERE nombre='Quetzaltenango'),'Coatepeque'),
 ((SELECT id_departamento FROM departamento WHERE nombre='Quetzaltenango'),'Olintepeque'),
 ((SELECT id_departamento FROM departamento WHERE nombre='Quetzaltenango'),'Zunil'),
 ((SELECT id_departamento FROM departamento WHERE nombre='Quetzaltenango'),'Cantel'),
 ((SELECT id_departamento FROM departamento WHERE nombre='San Marcos'),'San Marcos'),
 ((SELECT id_departamento FROM departamento WHERE nombre='Totonicapán'),'Totonicapán');
