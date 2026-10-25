package gt.cunoc.hospital.orm;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Query;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Demuestra que el ORM y el SQL producen el mismo resultado: ejecuta cada objetivo con JPA y con la
 * consulta SQL de su archivo (sql/consultas/objetivo_XX.sql) y compara fila por fila.
 *
 * Las fechas del archivo se reemplazan por parametros con nombre (:desde, :hasta, :hastaFin) y sus
 * valores se envian enlazados, no pegados al texto de la consulta.
 *
 * Uso: mvn -q compile exec:java -Dexec.mainClass=gt.cunoc.hospital.orm.Comparar -Dexec.args="2026-01-01 2026-10-31"
 */
public class Comparar {

    private static final Path CONSULTAS = Path.of("..", "sql", "consultas");

    public static void main(String[] args) {
        LocalDate desde = LocalDate.parse(args.length > 0 ? args[0] : "2026-01-01");
        LocalDate hasta = LocalDate.parse(args.length > 1 ? args[1] : "2026-10-31");
        boolean todosIguales = true;

        try (EntityManagerFactory emf = Conexion.crear(false); EntityManager em = emf.createEntityManager()) {
            ConsultasOrm orm = new ConsultasOrm(em);

            List<List<String>> orm08 = new ArrayList<>();
            orm.objetivo08(desde, hasta).forEach(f -> orm08.add(fila(f.hospital(), f.unidad(), f.efectivo(),
                    f.tarjetaCredito(), f.tarjetaDebito())));
            todosIguales &= comparar("Objetivo 8", orm08, sql(em, 8, desde, hasta));

            List<List<String>> orm11 = new ArrayList<>();
            orm.objetivo11(desde, hasta).forEach(f -> orm11.add(fila(f.hospital(), f.facturas(), f.totalFacturado(),
                    f.totalCobrado(), f.pendienteDeCobro())));
            todosIguales &= comparar("Objetivo 11", orm11, sql(em, 11, desde, hasta));

            List<List<String>> orm18 = new ArrayList<>();
            orm.objetivo18(desde, hasta).forEach(f -> orm18.add(fila(f.idPaciente(), f.numeroExpediente(),
                    f.nombres(), f.apellidos(), f.sexo())));
            todosIguales &= comparar("Objetivo 18", orm18, sql(em, 18, desde, hasta));
        }
        System.exit(todosIguales ? 0 : 1);
    }

    /** Ejecuta la primera consulta del archivo del objetivo, con las fechas como parametros enlazados. */
    @SuppressWarnings("unchecked")
    private static List<List<String>> sql(EntityManager em, int objetivo, LocalDate desde, LocalDate hasta) {
        String consulta = consultaDelArchivo(objetivo);
        Query query = em.createNativeQuery(consulta);
        // solo se asignan los parametros que aparecen en la consulta
        if (consulta.contains(":desde")) {
            query.setParameter("desde", desde);
        }
        if (consulta.contains(":hastaFin")) {
            query.setParameter("hastaFin", hasta.atTime(LocalTime.of(23, 59, 59)));
        }
        if (consulta.matches("(?s).*:hasta\\b.*")) {
            query.setParameter("hasta", hasta);
        }
        List<List<String>> filas = new ArrayList<>();
        for (Object[] f : (List<Object[]>) query.getResultList()) {
            filas.add(fila(f));
        }
        return filas;
    }

    /** Lee la consulta del archivo y cambia las fechas escritas en ella por parametros con nombre. */
    private static String consultaDelArchivo(int objetivo) {
        try {
            String texto = Files.readAllLines(CONSULTAS.resolve(String.format("objetivo_%02d.sql", objetivo))).stream()
                    .filter(linea -> !linea.trim().startsWith("--"))
                    .collect(Collectors.joining("\n"));
            String consulta = texto.substring(0, texto.indexOf(';'));
            return consulta.replace("'2026-10-31 23:59:59'", ":hastaFin")
                    .replace("'2026-10-31'", ":hasta")
                    .replace("'2026-01-01'", ":desde");
        } catch (IOException e) {
            throw new IllegalStateException("No se pudo leer la consulta del objetivo " + objetivo, e);
        }
    }

    /** Convierte una fila a texto comparable (los numeros sin ceros sobrantes). */
    private static List<String> fila(Object... valores) {
        List<String> texto = new ArrayList<>();
        for (Object v : valores) {
            if (v instanceof Number n) {
                texto.add(new BigDecimal(n.toString()).stripTrailingZeros().toPlainString());
            } else {
                texto.add(String.valueOf(v));
            }
        }
        return texto;
    }

    private static boolean comparar(String objetivo, List<List<String>> orm, List<List<String>> sql) {
        boolean iguales = orm.equals(sql);
        System.out.printf("%-12s ORM: %3d filas | SQL: %3d filas -> %s%n", objetivo, orm.size(), sql.size(),
                iguales ? "iguales" : "DIFERENTES");
        if (!iguales) {
            for (int i = 0; i < Math.max(orm.size(), sql.size()); i++) {
                List<String> a = i < orm.size() ? orm.get(i) : null;
                List<String> b = i < sql.size() ? sql.get(i) : null;
                if (a == null || !a.equals(b)) {
                    System.out.printf("   fila %d%n     ORM %s%n     SQL %s%n", i + 1, a, b);
                }
            }
        }
        return iguales;
    }
}
