import {
  Column,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  type Relation,
} from 'typeorm';
import { Clase } from './clase.entity.js';

@Entity('entrenador')
export class Entrenador {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  nombre: string;

  @Column({ length: 80 })
  especialidad: string;

  // Uno a muchos: un entrenador dirige muchas clases
  @OneToMany(() => Clase, (c) => c.entrenador)
  clases: Relation<Clase[]>;
}
