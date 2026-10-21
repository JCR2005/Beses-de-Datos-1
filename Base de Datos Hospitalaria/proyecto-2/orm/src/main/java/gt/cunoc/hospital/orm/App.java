package gt.cunoc.hospital.orm;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;

import java.time.LocalDate;

/**
 * Ejecuta con JPA los objetivos 8, 11 y 18 e imprime su resultado.
 *
 * Uso: mvn -q compile exec:java -Dexec.args="2026-01-01 2026-10-31"
 * Requiere la variable de entorno HOSPITAL_DB_PASSWORD (clave del rol visor).
 * Con -Dmostrar.sql=true se imprimen las sentencias preparadas que envia Hibernate.
 */
public class App {

    public static void main(String[] args) {
        LocalDate desde = LocalDate.parse(args.length > 0 ? args[0] : "2026-01-01");
        LocalDate hasta = LocalDate.parse(args.length > 1 ? args[1] : "2026-10-31");
        boolean mostrarSql = Boolean.getBoolean("mostrar.sql");

        try (EntityManagerFactory emf = Conexion.crear(mostrarSql); EntityManager em = emf.createEntityManager()) {
            ConsultasOrm consultas = new ConsultasOrm(em);

            System.out.printf("%nObjetivo 8 - pagos por metodo, del %s al %s%n", desde, hasta);
            System.out.printf("%-36s %-17s %12s %16s %15s%n", "Hospital", "Unidad", "Efectivo", "Tarjeta credito", "Tarjeta debito");
            consultas.objetivo08(desde, hasta).forEach(f -> System.out.printf("%-36s %-17s %12s %16s %15s%n",
                    f.hospital(), f.unidad(), f.efectivo(), f.tarjetaCredito(), f.tarjetaDebito()));

            System.out.printf("%nObjetivo 11 - ingresos por hospital, del %s al %s%n", desde, hasta);
            System.out.printf("%-36s %9s %16s %14s %14s%n", "Hospital", "Facturas", "Facturado", "Cobrado", "Pendiente");
            consultas.objetivo11(desde, hasta).forEach(f -> System.out.printf("%-36s %9d %16s %14s %14s%n",
                    f.hospital(), f.facturas(), f.totalFacturado(), f.totalCobrado(), f.pendienteDeCobro()));

            System.out.printf("%nObjetivo 18 - pacientes atendidos en las 4 unidades, del %s al %s%n", desde, hasta);
            System.out.printf("%4s %-10s %-28s %5s %-10s%n", "Id", "Expediente", "Paciente", "Edad", "Sexo");
            consultas.objetivo18(desde, hasta).forEach(f -> System.out.printf("%4d %-10s %-28s %5d %-10s%n",
                    f.idPaciente(), f.numeroExpediente(), f.paciente(), f.edad(), f.sexo()));
        }
    }
}
