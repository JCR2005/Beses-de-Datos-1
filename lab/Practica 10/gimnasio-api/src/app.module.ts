import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { ClaseModule } from './clase/clase.module.js';
import { InscripcionModule } from './inscripcion/inscripcion.module.js';
import { Clase } from './entidades/clase.entity.js';
import { Entrenador } from './entidades/entrenador.entity.js';
import { Inscripcion } from './entidades/inscripcion.entity.js';
import { Socio } from './entidades/socio.entity.js';
import { TipoMembresia } from './entidades/tipo-membresia.entity.js';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST ?? 'localhost',
      port: Number(process.env.DB_PORT ?? 5435), // contenedor lab_DB1
      username: process.env.DB_USER ?? 'postgres',
      password: process.env.DB_PASS ?? '4170',
      database: process.env.DB_NAME ?? 'gimnasio',
      entities: [Clase, Entrenador, Inscripcion, Socio, TipoMembresia], // todas
      synchronize: true, // lo pide el Ejercicio #10
      logging: true, // muestra en consola cada SQL que genera
    }),
    ClaseModule,
    InscripcionModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
