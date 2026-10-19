import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Clase } from '../entidades/clase.entity.js';
import { Inscripcion } from '../entidades/inscripcion.entity.js';
import { InscribirDto } from './dto/inscribir.dto.js';

@Injectable()
export class InscripcionService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(Inscripcion)
    private readonly repo: Repository<Inscripcion>,
  ) {}

  findAll() {
    return this.repo.find({
      relations: { socio: true, clase: true },
      order: { id: 'ASC' },
    });
  }

  // 10B-IV: transacción con DOS cambios
  //   1) INSERT en inscripcion
  //   2) UPDATE clase SET cupo_disponible = cupo_disponible - 1
  // Si la clase ya no tiene cupo, el CHECK (cupo_disponible >= 0) falla en el
  // paso 2 y PostgreSQL revierte TAMBIÉN el INSERT del paso 1 (ROLLBACK).
  async inscribir(dto: InscribirDto) {
    try {
      return await this.dataSource.transaction(async (manager) => {
        const inscripcion = await manager.save(Inscripcion, {
          socioId: dto.socioId,
          claseId: dto.claseId,
        });
        await manager.decrement(
          Clase,
          { id: dto.claseId },
          'cupoDisponible',
          1,
        );
        return inscripcion;
      });
    } catch (e: any) {
      const code = e?.driverError?.code ?? e?.code;
      if (code === '23514') {
        // check_violation
        throw new ConflictException(
          'La clase no tiene cupo: la transacción se revirtió (ROLLBACK) y la inscripción no quedó guardada',
        );
      }
      if (code === '23503') {
        // foreign_key_violation
        throw new NotFoundException('El socio o la clase no existe');
      }
      if (code === '23505') {
        // unique_violation
        throw new ConflictException('El socio ya está inscrito en esa clase');
      }
      throw e;
    }
  }
}
