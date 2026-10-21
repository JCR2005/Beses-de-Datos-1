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
import java.time.LocalDate;

/** Pago de una cuota de una factura (tabla pago). */
@Entity
@Immutable
@Table(name = "pago")
public class Pago {

    @Id
    @Column(name = "id_pago")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_factura")
    private Factura factura;

    @Column(name = "monto")
    private BigDecimal monto;

    @Column(name = "fecha_pago")
    private LocalDate fechaPago;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_metodo_pago")
    private MetodoPago metodoPago;

    public Integer getId() { return id; }
    public Factura getFactura() { return factura; }
    public BigDecimal getMonto() { return monto; }
    public LocalDate getFechaPago() { return fechaPago; }
    public MetodoPago getMetodoPago() { return metodoPago; }
}
