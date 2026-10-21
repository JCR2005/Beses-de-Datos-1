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
 * Factura con su hospital y unidad. Se mapea a la vista v_factura, que obtiene el hospital y la
 * unidad a partir del origen de la factura (cita, ingreso o cirugia); por eso es de solo lectura.
 */
@Entity
@Immutable
@Table(name = "v_factura")
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
    @JoinColumn(name = "id_hospital")
    private Hospital hospital;

    @Column(name = "tipo_unidad")
    private String tipoUnidad;

    public Integer getId() { return id; }
    public OffsetDateTime getFechaEmision() { return fechaEmision; }
    public BigDecimal getTotal() { return total; }
    public Short getNumeroCuotas() { return numeroCuotas; }
    public Hospital getHospital() { return hospital; }
    public String getTipoUnidad() { return tipoUnidad; }
}
