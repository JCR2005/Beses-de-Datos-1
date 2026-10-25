package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Quirofano de la unidad de cirugia (tabla quirofano). */
@Entity
@Immutable
@Table(name = "quirofano")
public class Quirofano {

    @Id
    @Column(name = "id_quirofano")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_unidad")
    private UnidadMedica unidad;

    public Integer getId() { return id; }
    public UnidadMedica getUnidad() { return unidad; }
}
