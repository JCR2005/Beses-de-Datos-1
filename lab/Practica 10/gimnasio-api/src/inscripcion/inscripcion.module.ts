import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Inscripcion } from '../entidades/inscripcion.entity.js';
import { InscripcionController } from './inscripcion.controller.js';
import { InscripcionService } from './inscripcion.service.js';

@Module({
  imports: [TypeOrmModule.forFeature([Inscripcion])],
  controllers: [InscripcionController],
  providers: [InscripcionService],
})
export class InscripcionModule {}
