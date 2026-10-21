package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Catalogo de metodos de pago (tabla metodo_pago). */
@Entity
@Immutable
@Table(name = "metodo_pago")
public class MetodoPago {

    @Id
    @Column(name = "id_metodo_pago")
    private Integer id;

    @Column(name = "nombre")
    private String nombre;

    public Integer getId() { return id; }
    public String getNombre() { return nombre; }
}
