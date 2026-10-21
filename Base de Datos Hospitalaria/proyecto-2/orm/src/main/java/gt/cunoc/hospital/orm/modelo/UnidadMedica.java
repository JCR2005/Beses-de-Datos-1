package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Unidad de atencion de un hospital (tabla unidad_medica). */
@Entity
@Immutable
@Table(name = "unidad_medica")
public class UnidadMedica {

    @Id
    @Column(name = "id_unidad")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_hospital")
    private Hospital hospital;

    @Column(name = "tipo_unidad")
    private String tipoUnidad;

    public Integer getId() { return id; }
    public Hospital getHospital() { return hospital; }
    public String getTipoUnidad() { return tipoUnidad; }
}
