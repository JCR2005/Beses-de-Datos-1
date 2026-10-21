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

/** Cita de consulta externa (tabla cita). */
@Entity
@Immutable
@Table(name = "cita")
public class Cita {

    @Id
    @Column(name = "id_cita")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_paciente")
    private Paciente paciente;

    @Column(name = "fecha_hora")
    private OffsetDateTime fechaHora;

    @Column(name = "estado")
    private String estado;

    public Integer getId() { return id; }
    public Paciente getPaciente() { return paciente; }
    public OffsetDateTime getFechaHora() { return fechaHora; }
    public String getEstado() { return estado; }
}
