import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Clase } from '../entidades/clase.entity.js';
import { ClaseController } from './clase.controller.js';
import { ClaseService } from './clase.service.js';

@Module({
  imports: [TypeOrmModule.forFeature([Clase])],
  controllers: [ClaseController],
  providers: [ClaseService],
})
export class ClaseModule {}
