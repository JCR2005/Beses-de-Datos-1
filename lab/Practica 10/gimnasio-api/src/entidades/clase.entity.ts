import {
  Check,
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  type Relation,
} from 'typeorm';
import { Entrenador } from './entrenador.entity.js';
import { Inscripcion } from './inscripcion.entity.js';

// Se declaran los CHECK con el mismo nombre que ya tienen en PostgreSQL
// para que synchronize: true no los elimine.
@Entity('clase')
@Check('clase_cupo_maximo_check', '"cupo_maximo" > 0')
@Check('clase_cupo_disponible_check', '"cupo_disponible" >= 0')
@Check('clase_check', '"cupo_disponible" <= "cupo_maximo"')
export class Clase {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 80 })
  nombre: string;

  @Column({ length: 40 })
  horario: string;

  @Column({ name: 'cupo_maximo', type: 'int' })
  cupoMaximo: number;

  @Column({ name: 'cupo_disponible', type: 'int' })
  cupoDisponible: number;

  // Muchos a uno: cada clase la dirige un entrenador
  @ManyToOne(() => Entrenador, (e) => e.clases, { nullable: false })
  @JoinColumn({
    name: 'entrenador_id',
    foreignKeyConstraintName: 'clase_entrenador_id_fkey',
  })
  entrenador: Relation<Entrenador>;

  @OneToMany(() => Inscripcion, (i) => i.clase)
  inscripciones: Relation<Inscripcion[]>;
}
