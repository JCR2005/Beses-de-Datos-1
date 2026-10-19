import {
  Check,
  Column,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  type Relation,
} from 'typeorm';
import { Socio } from './socio.entity.js';

@Entity('tipo_membresia')
@Check('tipo_membresia_precio_mensual_check', '"precio_mensual" > 0')
export class TipoMembresia {
  @PrimaryGeneratedColumn() // SERIAL
  id: number;

  @Column({ length: 50, unique: true })
  nombre: string;

  @Column({ name: 'precio_mensual', type: 'numeric', precision: 8, scale: 2 })
  precioMensual: string; // numeric llega como string desde PostgreSQL

  // Uno a muchos: un tipo de membresía tiene muchos socios
  @OneToMany(() => Socio, (s) => s.tipoMembresia)
  socios: Relation<Socio[]>;
}
