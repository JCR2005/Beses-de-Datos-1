package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Consulta realizada en una cita (tabla consulta). */
@Entity
@Immutable
@Table(name = "consulta")
public class Consulta {

    @Id
    @Column(name = "id_consulta")
    private Integer id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_cita")
    private Cita cita;

    public Integer getId() { return id; }
    public Cita getCita() { return cita; }
}
