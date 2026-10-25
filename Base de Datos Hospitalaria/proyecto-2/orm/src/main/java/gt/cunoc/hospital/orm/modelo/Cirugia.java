package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Cirugia realizada en un quirofano (tabla cirugia). */
@Entity
@Immutable
@Table(name = "cirugia")
public class Cirugia {

    @Id
    @Column(name = "id_cirugia")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_quirofano")
    private Quirofano quirofano;

    public Integer getId() { return id; }
    public Quirofano getQuirofano() { return quirofano; }
}
