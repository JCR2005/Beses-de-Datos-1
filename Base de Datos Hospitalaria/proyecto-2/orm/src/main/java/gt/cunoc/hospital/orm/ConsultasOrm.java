package gt.cunoc.hospital.orm;

import jakarta.persistence.EntityManager;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.Period;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Objetivos 8, 11 y 18 escritos con JPA (JPQL), equivalentes a las funciones SQL
 * fn_objetivo_08, fn_objetivo_11 y fn_objetivo_18.
 *
 * Todos los valores que vienen de afuera (fechas, nombres de metodo de pago) se pasan como
 * parametros con nombre (:desde, :hasta, ...). Hibernate los envia en una sentencia preparada,
 * nunca concatenados al texto de la consulta, por lo que no hay riesgo de inyeccion SQL.
 */
public class ConsultasOrm {

    private static final ZoneId GUATEMALA = ZoneId.of("America/Guatemala");

    private final EntityManager em;

    public ConsultasOrm(EntityManager em) {
        this.em = em;
    }

    /** Fila del objetivo 8: pagos por metodo en una unidad de un hospital. */
    public record PagosPorMetodo(String hospital, String unidad, BigDecimal efectivo,
                                 BigDecimal tarjetaCredito, BigDecimal tarjetaDebito) {
    }

    /** Fila del objetivo 11: ingresos de un hospital. */
    public record IngresosHospital(String hospital, long facturas, BigDecimal totalFacturado,
                                   BigDecimal totalCobrado, BigDecimal pendienteDeCobro) {
    }

    /** Fila del objetivo 18: paciente atendido en las 4 unidades. */
    public record PacienteFiel(int idPaciente, String numeroExpediente, String paciente, int edad, String sexo) {
    }

    /** Objetivo 8: total pagado en efectivo, credito y debito por hospital y unidad. */
    public List<PagosPorMetodo> objetivo08(LocalDate desde, LocalDate hasta) {
        List<Object[]> filas = em.createQuery("""
                select h.nombre, f.tipoUnidad,
                       sum(case when m.nombre = :efectivo then p.monto else 0 end),
                       sum(case when m.nombre = :credito then p.monto else 0 end),
                       sum(case when m.nombre = :debito then p.monto else 0 end)
                  from Pago p
                  join p.metodoPago m
                  join p.factura f
                  join f.hospital h
                 where p.fechaPago between :desde and :hasta
                 group by h.id, h.nombre, f.tipoUnidad
                 order by h.id, f.tipoUnidad
                """, Object[].class)
                .setParameter("efectivo", "Efectivo")
                .setParameter("credito", "Tarjeta de crédito")
                .setParameter("debito", "Tarjeta de débito")
                .setParameter("desde", desde)
                .setParameter("hasta", hasta)
                .getResultList();
        List<PagosPorMetodo> resultado = new ArrayList<>();
        for (Object[] f : filas) {
            resultado.add(new PagosPorMetodo((String) f[0], (String) f[1], decimal(f[2]), decimal(f[3]), decimal(f[4])));
        }
        return resultado;
    }

    /** Objetivo 11: total facturado y cobrado por hospital. */
    public List<IngresosHospital> objetivo11(LocalDate desde, LocalDate hasta) {
        Map<Integer, Object[]> facturado = new HashMap<>();
        for (Object[] f : em.createQuery("""
                select f.hospital.id, count(f), sum(f.total)
                  from Factura f
                 where f.fechaEmision >= :desde and f.fechaEmision < :hasta
                 group by f.hospital.id
                """, Object[].class)
                .setParameter("desde", inicioDelDia(desde))
                .setParameter("hasta", inicioDelDia(hasta.plusDays(1)))
                .getResultList()) {
            facturado.put((Integer) f[0], f);
        }
        Map<Integer, BigDecimal> cobrado = new HashMap<>();
        for (Object[] f : em.createQuery("""
                select p.factura.hospital.id, sum(p.monto)
                  from Pago p
                 where p.fechaPago between :desde and :hasta
                 group by p.factura.hospital.id
                """, Object[].class)
                .setParameter("desde", desde)
                .setParameter("hasta", hasta)
                .getResultList()) {
            cobrado.put((Integer) f[0], decimal(f[1]));
        }
        List<IngresosHospital> resultado = new ArrayList<>();
        for (Object[] h : em.createQuery("select h.id, h.nombre from Hospital h", Object[].class).getResultList()) {
            Object[] f = facturado.get((Integer) h[0]);
            long facturas = f == null ? 0 : ((Number) f[1]).longValue();
            BigDecimal total = f == null ? BigDecimal.ZERO : decimal(f[2]);
            BigDecimal pagado = cobrado.getOrDefault((Integer) h[0], BigDecimal.ZERO);
            resultado.add(new IngresosHospital((String) h[1], facturas, total, pagado, total.subtract(pagado)));
        }
        resultado.sort(Comparator.comparing(IngresosHospital::totalFacturado).reversed());
        return resultado;
    }

    /**
     * Objetivo 18: division relacional. Pacientes con consulta externa en el lapso y para los
     * que no existe una unidad con ficha de ingreso (emergencias, cirugia, hospitalizacion)
     * en la que no hayan sido atendidos.
     */
    public List<PacienteFiel> objetivo18(LocalDate desde, LocalDate hasta) {
        OffsetDateTime inicio = inicioDelDia(desde);
        OffsetDateTime fin = inicioDelDia(hasta.plusDays(1));
        List<Object[]> filas = em.createQuery("""
                select p.id, p.numeroExpediente, p.nombres, p.apellidos, p.fechaNacimiento, p.sexo
                  from Paciente p
                 where exists (select co.id from Consulta co
                                where co.cita.paciente = p
                                  and co.cita.fechaHora >= :inicio and co.cita.fechaHora < :fin)
                   and not exists (select u.id from UnidadMedica u
                                    where u.tipoUnidad <> :consultaExterna
                                      and not exists (select i.id from Ingreso i
                                                       where i.paciente = p
                                                         and i.unidad.tipoUnidad = u.tipoUnidad
                                                         and i.fechaHoraIngreso >= :inicio
                                                         and i.fechaHoraIngreso < :fin))
                 order by p.id
                """, Object[].class)
                .setParameter("inicio", inicio)
                .setParameter("fin", fin)
                .setParameter("consultaExterna", "Consulta Externa")
                .getResultList();
        LocalDate hoy = LocalDate.now(GUATEMALA);
        List<PacienteFiel> resultado = new ArrayList<>();
        for (Object[] f : filas) {
            int edad = Period.between((LocalDate) f[4], hoy).getYears();
            resultado.add(new PacienteFiel((Integer) f[0], (String) f[1], f[2] + " " + f[3], edad, (String) f[5]));
        }
        return resultado;
    }

    private static OffsetDateTime inicioDelDia(LocalDate fecha) {
        return fecha.atStartOfDay(GUATEMALA).toOffsetDateTime();
    }

    private static BigDecimal decimal(Object valor) {
        if (valor == null) {
            return BigDecimal.ZERO;
        }
        return valor instanceof BigDecimal b ? b : new BigDecimal(valor.toString());
    }
}
