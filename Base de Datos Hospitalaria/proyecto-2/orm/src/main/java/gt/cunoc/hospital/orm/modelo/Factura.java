package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

/**
 * Factura (tabla factura). Su origen es una cita, un ingreso o una cirugia (solo uno de los tres);
 * de ese origen se obtiene la unidad y el hospital de la factura.
 */
@Entity
@Immutable
@Table(name = "factura")
public class Factura {

    @Id
    @Column(name = "id_factura")
    private Integer id;

    @Column(name = "fecha_emision")
    private OffsetDateTime fechaEmision;

    @Column(name = "total")
    private BigDecimal total;

    @Column(name = "numero_cuotas")
    private Short numeroCuotas;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_cita")
    private Cita cita;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_ingreso")
    private Ingreso ingreso;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_cirugia")
    private Cirugia cirugia;

    public Integer getId() { return id; }
    public OffsetDateTime getFechaEmision() { return fechaEmision; }
    public BigDecimal getTotal() { return total; }
    public Short getNumeroCuotas() { return numeroCuotas; }
    public Cita getCita() { return cita; }
    public Ingreso getIngreso() { return ingreso; }
    public Cirugia getCirugia() { return cirugia; }
}
