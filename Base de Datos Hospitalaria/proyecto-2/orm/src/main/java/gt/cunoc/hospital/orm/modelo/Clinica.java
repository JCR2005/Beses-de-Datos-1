package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Clinica (consultorio) de la unidad de consulta externa (tabla clinica). */
@Entity
@Immutable
@Table(name = "clinica")
public class Clinica {

    @Id
    @Column(name = "id_clinica")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_unidad")
    private UnidadMedica unidad;

    @Column(name = "numero")
    private String numero;

    public Integer getId() { return id; }
    public UnidadMedica getUnidad() { return unidad; }
    public String getNumero() { return numero; }
}
