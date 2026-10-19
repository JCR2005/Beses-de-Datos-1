import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // Puerto = 3000 + últimos 2 dígitos del carné (202231970 -> 3070)
  await app.listen(process.env.PORT ?? 3070);
}
void bootstrap();
