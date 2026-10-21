package gt.cunoc.hospital.orm.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

/** Hospital de la cadena (tabla hospital). */
@Entity
@Immutable
@Table(name = "hospital")
public class Hospital {

    @Id
    @Column(name = "id_hospital")
    private Integer id;

    @Column(name = "nombre")
    private String nombre;

    public Integer getId() { return id; }
    public String getNombre() { return nombre; }
}
