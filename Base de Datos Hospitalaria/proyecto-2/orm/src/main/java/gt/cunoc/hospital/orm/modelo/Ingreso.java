package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

import java.time.OffsetDateTime;

/** Ficha de ingreso a emergencias, cirugia u hospitalizacion (tabla ingreso). */
@Entity
@Immutable
@Table(name = "ingreso")
public class Ingreso {

    @Id
    @Column(name = "id_ingreso")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_paciente")
    private Paciente paciente;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_unidad")
    private UnidadMedica unidad;

    @Column(name = "fecha_hora_ingreso")
    private OffsetDateTime fechaHoraIngreso;

    public Integer getId() { return id; }
    public Paciente getPaciente() { return paciente; }
    public UnidadMedica getUnidad() { return unidad; }
    public OffsetDateTime getFechaHoraIngreso() { return fechaHoraIngreso; }
}
