package gt.cunoc.hospital.orm;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.util.HashMap;
import java.util.Map;

/** Crea la fabrica de EntityManager con la contraseña tomada del entorno, no del codigo. */
public final class Conexion {

    private Conexion() {
    }

    /**
     * @param mostrarSql si es true, Hibernate imprime cada sentencia que envia; en ella se ven
     *                   los parametros enlazados como "?" en lugar de los valores
     */
    public static EntityManagerFactory crear(boolean mostrarSql) {
        String clave = System.getenv("HOSPITAL_DB_PASSWORD");
        if (clave == null || clave.isBlank()) {
            throw new IllegalStateException("Defina la variable de entorno HOSPITAL_DB_PASSWORD con la clave del rol visor");
        }
        Map<String, Object> propiedades = new HashMap<>();
        propiedades.put("jakarta.persistence.jdbc.password", clave);
        propiedades.put("hibernate.show_sql", String.valueOf(mostrarSql));
        propiedades.put("hibernate.format_sql", "true");
        return Persistence.createEntityManagerFactory("hospital", propiedades);
    }
}
