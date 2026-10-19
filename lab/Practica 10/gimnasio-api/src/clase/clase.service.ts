import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Clase } from '../entidades/clase.entity.js';
import { Entrenador } from '../entidades/entrenador.entity.js';
import { CreateClaseDto } from './dto/create-clase.dto.js';
import { UpdateClaseDto } from './dto/update-clase.dto.js';

@Injectable()
export class ClaseService {
  constructor(
    @InjectRepository(Clase)
    private readonly repo: Repository<Clase>,
  ) {}

  // ---------- CRUD ----------

  findAll() {
    return this.repo.find({ order: { id: 'ASC' } }); // SELECT ... FROM "clase"
  }

  async findOne(id: number) {
    const clase = await this.repo.findOneBy({ id }); // ... WHERE "id" = $1
    if (!clase) throw new NotFoundException('No existe la clase'); // 404
    return clase;
  }

  create(dto: CreateClaseDto) {
    const { entrenadorId, ...datos } = dto;
    const clase = this.repo.create({
      ...datos,
      entrenador: { id: entrenadorId } as Entrenador,
    });
    return this.repo.save(clase); // INSERT ... RETURNING "id"
  }

  async update(id: number, dto: UpdateClaseDto) {
    const clase = await this.findOne(id); // 404 si no existe
    const { entrenadorId, ...datos } = dto;
    Object.assign(clase, datos);
    if (entrenadorId !== undefined) {
      clase.entrenador = { id: entrenadorId } as Entrenador;
    }
    return this.repo.save(clase); // UPDATE ... WHERE "id" = $n
  }

  async remove(id: number) {
    await this.findOne(id); // 404 si no existe
    try {
      await this.repo.delete(id); // DELETE FROM "clase" WHERE "id" = $1
    } catch (e: any) {
      // 23503 = foreign_key_violation (la clase ya tiene inscripciones)
      if ((e?.driverError?.code ?? e?.code) === '23503') {
        throw new ConflictException(
          'No se puede eliminar: la clase tiene inscripciones',
        );
      }
      throw e;
    }
    return { mensaje: `Clase ${id} eliminada` };
  }

  // ---------- Ejercicio 10B: consultas ----------

  // (I) relations: cada clase con su entrenador -> LEFT JOIN "entrenador"
  conEntrenador() {
    return this.repo.find({
      relations: { entrenador: true },
      order: { id: 'ASC' },
    });
  }

  // (II) QueryBuilder: JOIN + filtro con parámetro + orden
  porEspecialidad(especialidad: string) {
    return this.repo
      .createQueryBuilder('c')
      .innerJoinAndSelect('c.entrenador', 'e')
      .where('e.especialidad = :especialidad', { especialidad })
      .orderBy('c.nombre')
      .getMany();
  }
}
