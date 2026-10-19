import { Body, Controller, Get, Post } from '@nestjs/common';
import { InscribirDto } from './dto/inscribir.dto.js';
import { InscripcionService } from './inscripcion.service.js';

@Controller('inscripcion')
export class InscripcionController {
  constructor(private readonly service: InscripcionService) {}

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Post('inscribir') // 10B-IV: transacción
  inscribir(@Body() dto: InscribirDto) {
    return this.service.inscribir(dto);
  }
}
