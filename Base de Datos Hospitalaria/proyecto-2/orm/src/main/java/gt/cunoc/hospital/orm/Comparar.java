package gt.cunoc.hospital.orm;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Demuestra que el ORM y el SQL producen el mismo resultado: ejecuta cada objetivo con JPA y con
 * su funcion SQL (tambien con parametros enlazados, ?1 y ?2) y compara fila por fila.
 *
 * Uso: mvn -q compile exec:java -Dexec.mainClass=gt.cunoc.hospital.orm.Comparar -Dexec.args="2026-01-01 2026-10-31"
 */
public class Comparar {

    public static void main(String[] args) {
        LocalDate desde = LocalDate.parse(args.length > 0 ? args[0] : "2026-01-01");
        LocalDate hasta = LocalDate.parse(args.length > 1 ? args[1] : "2026-10-31");
        boolean todosIguales = true;

        try (EntityManagerFactory emf = Conexion.crear(false); EntityManager em = emf.createEntityManager()) {
            ConsultasOrm orm = new ConsultasOrm(em);

            List<List<String>> orm08 = new ArrayList<>();
            orm.objetivo08(desde, hasta).forEach(f -> orm08.add(fila(f.hospital(), f.unidad(), f.efectivo(),
                    f.tarjetaCredito(), f.tarjetaDebito())));
            todosIguales &= comparar("Objetivo 8", orm08, sql(em, "select * from fn_objetivo_08(?1, ?2)", desde, hasta));

            List<List<String>> orm11 = new ArrayList<>();
            orm.objetivo11(desde, hasta).forEach(f -> orm11.add(fila(f.hospital(), f.facturas(), f.totalFacturado(),
                    f.totalCobrado(), f.pendienteDeCobro())));
            todosIguales &= comparar("Objetivo 11", orm11, sql(em, "select * from fn_objetivo_11(?1, ?2)", desde, hasta));

            List<List<String>> orm18 = new ArrayList<>();
            orm.objetivo18(desde, hasta).forEach(f -> orm18.add(fila(f.idPaciente(), f.numeroExpediente(),
                    f.paciente(), f.edad(), f.sexo())));
            todosIguales &= comparar("Objetivo 18", orm18, sql(em, "select * from fn_objetivo_18(?1, ?2)", desde, hasta));
        }
        System.exit(todosIguales ? 0 : 1);
    }

    /** Ejecuta la funcion SQL con las fechas como parametros enlazados. */
    @SuppressWarnings("unchecked")
    private static List<List<String>> sql(EntityManager em, String consulta, LocalDate desde, LocalDate hasta) {
        List<List<String>> filas = new ArrayList<>();
        for (Object[] f : (List<Object[]>) em.createNativeQuery(consulta)
                .setParameter(1, desde)
                .setParameter(2, hasta)
                .getResultList()) {
            filas.add(fila(f));
        }
        return filas;
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
