import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  type Relation,
} from 'typeorm';
import { Socio } from './socio.entity.js';
import { Clase } from './clase.entity.js';

// Resuelve la relación M:N entre socio y clase
@Entity('inscripcion')
@Unique('inscripcion_socio_id_clase_id_key', ['socioId', 'claseId'])
export class Inscripcion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'socio_id', type: 'int' })
  socioId: number;

  @Column({ name: 'clase_id', type: 'int' })
  claseId: number;

  @Column({
    name: 'fecha_inscripcion',
    type: 'date',
    default: () => 'CURRENT_DATE',
  })
  fechaInscripcion: string;

  @ManyToOne(() => Socio, (s) => s.inscripciones, { nullable: false })
  @JoinColumn({
    name: 'socio_id',
    foreignKeyConstraintName: 'inscripcion_socio_id_fkey',
  })
  socio: Relation<Socio>;

  @ManyToOne(() => Clase, (c) => c.inscripciones, { nullable: false })
  @JoinColumn({
    name: 'clase_id',
    foreignKeyConstraintName: 'inscripcion_clase_id_fkey',
  })
  clase: Relation<Clase>;
}
