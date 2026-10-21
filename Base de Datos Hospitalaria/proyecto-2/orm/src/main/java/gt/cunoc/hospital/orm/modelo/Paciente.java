package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

import java.time.LocalDate;

/** Paciente de la red (tabla paciente). */
@Entity
@Immutable
@Table(name = "paciente")
public class Paciente {

    @Id
    @Column(name = "id_paciente")
    private Integer id;

    @Column(name = "numero_expediente")
    private String numeroExpediente;

    @Column(name = "nombres")
    private String nombres;

    @Column(name = "apellidos")
    private String apellidos;

    @Column(name = "fecha_nacimiento")
    private LocalDate fechaNacimiento;

    @Column(name = "sexo")
    private String sexo;

    public Integer getId() { return id; }
    public String getNumeroExpediente() { return numeroExpediente; }
    public String getNombres() { return nombres; }
    public String getApellidos() { return apellidos; }
    public LocalDate getFechaNacimiento() { return fechaNacimiento; }
    public String getSexo() { return sexo; }
}
