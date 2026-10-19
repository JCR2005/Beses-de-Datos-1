import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  type Relation,
} from 'typeorm';
import { TipoMembresia } from './tipo-membresia.entity.js';
import { Inscripcion } from './inscripcion.entity.js';

@Entity('socio')
export class Socio {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  nombre: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  telefono: string | null;

  @Column({
    name: 'fecha_ingreso',
    type: 'date',
    default: () => 'CURRENT_DATE',
  })
  fechaIngreso: string;

  // Muchos a uno: cada socio tiene un tipo de membresía
  @ManyToOne(() => TipoMembresia, (t) => t.socios, { nullable: false })
  @JoinColumn({
    name: 'tipo_membresia_id',
    foreignKeyConstraintName: 'socio_tipo_membresia_id_fkey',
  })
  tipoMembresia: Relation<TipoMembresia>;

  @OneToMany(() => Inscripcion, (i) => i.socio)
  inscripciones: Relation<Inscripcion[]>;
}
