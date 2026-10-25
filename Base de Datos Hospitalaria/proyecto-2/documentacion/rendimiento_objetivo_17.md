# Objetivo 17: rendimiento de las dos formas del ranking

Tiempo de ejecución (mediana de 3 corridas de `EXPLAIN ANALYZE`, en milisegundos).
Generado por `sql/consultas/rendimiento/medir_objetivo_17.sh` el 2026-11-07 12:42.

| Médicos calificados | Calificaciones | A: ventana (ms) | B: correlacionada (ms) | B / A |
|---:|---:|---:|---:|---:|
| 31 | 112 | 0.6 | 0.9 | 1.4x |
| 531 | 10112 | 13.7 | 113.7 | 8.3x |
| 2031 | 40112 | 62.3 | 1344.1 | 21.6x |
| 5031 | 100112 | 168.8 | 5707.1 | 33.8x |

## Conclusión

Con pocos médicos las dos formas tardan lo mismo, pero al crecer los datos la forma A
(funciones de ventana) crece casi en proporción a los registros, mientras que la forma B
(subconsultas correlacionadas) crece con el cuadrado del número de médicos: para cada
médico vuelve a recorrer a todos los demás, dos veces (hospital y cadena). La forma A
ordena una sola vez cada partición, así que es la que se recomienda para un reporte que
se ejecuta con frecuencia sobre un volumen creciente.

## Plan de ejecución con el mayor volumen

Forma A (ventana): un solo recorrido y ordenamientos para cada `rank()`.

```
Sort (actual rows=5031.00 loops=1)
  Sort Key: (rank() OVER w1), promedios.hospital, promedios.medico
  Sort Method: quicksort  Memory: 685kB
  Buffers: shared hit=2523
  ->  WindowAgg (actual rows=5031.00 loops=1)
        Window: w2 AS (PARTITION BY promedios.hospital ORDER BY promedios.promedio ROWS UNBOUNDED PRECEDING)
        Storage: Memory  Maximum Storage: 17kB
        Buffers: shared hit=2517
        ->  Sort (actual rows=5031.00 loops=1)
              Sort Key: promedios.hospital, promedios.promedio
              Sort Method: quicksort  Memory: 606kB
              Buffers: shared hit=2517
              ->  WindowAgg (actual rows=5031.00 loops=1)
                    Window: w1 AS (ORDER BY promedios.promedio ROWS UNBOUNDED PRECEDING)
                    Storage: Memory  Maximum Storage: 17kB
                    Buffers: shared hit=2514
                    ->  Sort (actual rows=5031.00 loops=1)
                          Sort Key: promedios.promedio
                          Sort Method: quicksort  Memory: 567kB
                          Buffers: shared hit=2514
                          ->  Subquery Scan on promedios (actual rows=5031.00 loops=1)
                                Buffers: shared hit=2514
                                ->  HashAggregate (actual rows=5031.00 loops=1)
                                      Group Key: m.id_medico, h.nombre
                                      Batches: 1  Memory Usage: 1553kB
                                      Buffers: shared hit=2514
                                      ->  Hash Join (actual rows=100112.00 loops=1)
                                            Hash Cond: (m.id_hospital = h.id_hospital)
                                            Buffers: shared hit=2514
                                            ->  Hash Join (actual rows=100112.00 loops=1)
                                                  Hash Cond: (c.id_medico = m.id_medico)
                                                  Buffers: shared hit=2513
                                                  ->  Hash Join (actual rows=100112.00 loops=1)
                                                        Hash Cond: (co.id_cita = c.id_cita)
                                                        Buffers: shared hit=2421
                                                        ->  Hash Join (actual rows=100112.00 loops=1)
                                                              Hash Cond: (ca.id_consulta = co.id_consulta)
                                                              Buffers: shared hit=1281
                                                              ->  Seq Scan on calificacion ca (actual rows=100187.00 loops=1)
                                                                    Buffers: shared hit=738
                                                              ->  Hash (actual rows=100178.00 loops=1)
                                                                    Buckets: 131072  Batches: 1  Memory Usage: 4938kB
                                                                    Buffers: shared hit=543
                                                                    ->  Seq Scan on consulta co (actual rows=100178.00 loops=1)
                                                                          Buffers: shared hit=543
                                                        ->  Hash (actual rows=100225.00 loops=1)
                                                              Buckets: 131072  Batches: 1  Memory Usage: 4940kB
                                                              Buffers: shared hit=1140
                                                              ->  Seq Scan on cita c (actual rows=100225.00 loops=1)
                                                                    Filter: ((fecha_hora >= '2026-01-01 00:00:00+00'::timestamp with time zone) AND (fecha_hora <= '2026-10-31 23:59:59+00'::timestamp with time zone))
                                                                    Buffers: shared hit=1140
                                                  ->  Hash (actual rows=5051.00 loops=1)
                                                        Buckets: 8192  Batches: 1  Memory Usage: 361kB
                                                        Buffers: shared hit=92
                                                        ->  Seq Scan on medico m (actual rows=5051.00 loops=1)
                                                              Buffers: shared hit=92
                                            ->  Hash (actual rows=5.00 loops=1)
                                                  Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                  Buffers: shared hit=1
                                                  ->  Seq Scan on hospital h (actual rows=5.00 loops=1)
                                                        Buffers: shared hit=1
Planning:
  Buffers: shared hit=604
Planning Time: 3.135 ms
Execution Time: 152.726 ms
```

Forma B (correlacionada): las dos subconsultas se ejecutan una vez por cada médico (loops).

```
Sort (actual rows=5031.00 loops=1)
  Sort Key: ((1 + (SubPlan 3))), p1.hospital, p1.medico
  Sort Method: quicksort  Memory: 645kB
  Buffers: shared hit=2520
  CTE promedios
    ->  HashAggregate (actual rows=5031.00 loops=1)
          Group Key: m.id_medico, h.nombre
          Batches: 1  Memory Usage: 1553kB
          Buffers: shared hit=2514
          ->  Hash Join (actual rows=100112.00 loops=1)
                Hash Cond: (m.id_hospital = h.id_hospital)
                Buffers: shared hit=2514
                ->  Hash Join (actual rows=100112.00 loops=1)
                      Hash Cond: (c.id_medico = m.id_medico)
                      Buffers: shared hit=2513
                      ->  Hash Join (actual rows=100112.00 loops=1)
                            Hash Cond: (co.id_cita = c.id_cita)
                            Buffers: shared hit=2421
                            ->  Hash Join (actual rows=100112.00 loops=1)
                                  Hash Cond: (ca.id_consulta = co.id_consulta)
                                  Buffers: shared hit=1281
                                  ->  Seq Scan on calificacion ca (actual rows=100187.00 loops=1)
                                        Buffers: shared hit=738
                                  ->  Hash (actual rows=100178.00 loops=1)
                                        Buckets: 131072  Batches: 1  Memory Usage: 4938kB
                                        Buffers: shared hit=543
                                        ->  Seq Scan on consulta co (actual rows=100178.00 loops=1)
                                              Buffers: shared hit=543
                            ->  Hash (actual rows=100225.00 loops=1)
                                  Buckets: 131072  Batches: 1  Memory Usage: 4940kB
                                  Buffers: shared hit=1140
                                  ->  Seq Scan on cita c (actual rows=100225.00 loops=1)
                                        Filter: ((fecha_hora >= '2026-01-01 00:00:00+00'::timestamp with time zone) AND (fecha_hora <= '2026-10-31 23:59:59+00'::timestamp with time zone))
                                        Buffers: shared hit=1140
                      ->  Hash (actual rows=5051.00 loops=1)
                            Buckets: 8192  Batches: 1  Memory Usage: 361kB
                            Buffers: shared hit=92
                            ->  Seq Scan on medico m (actual rows=5051.00 loops=1)
                                  Buffers: shared hit=92
                ->  Hash (actual rows=5.00 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 9kB
                      Buffers: shared hit=1
                      ->  Seq Scan on hospital h (actual rows=5.00 loops=1)
                            Buffers: shared hit=1
  ->  CTE Scan on promedios p1 (actual rows=5031.00 loops=1)
        Storage: Memory  Maximum Storage: 596kB
        Buffers: shared hit=2514
        SubPlan 2
          ->  Aggregate (actual rows=1.00 loops=5031)
                ->  CTE Scan on promedios p2 (actual rows=5.58 loops=5031)
                      Filter: ((promedio < p1.promedio) AND ((hospital)::text = (p1.hospital)::text))
                      Rows Removed by Filter: 5025
                      Storage: Memory  Maximum Storage: 596kB
        SubPlan 3
          ->  Aggregate (actual rows=1.00 loops=5031)
                ->  CTE Scan on promedios p2_1 (actual rows=2016.79 loops=5031)
                      Filter: (promedio < p1.promedio)
                      Rows Removed by Filter: 3014
                      Storage: Memory  Maximum Storage: 596kB
Planning:
  Buffers: shared hit=592
Planning Time: 1.676 ms
Execution Time: 5014.176 ms
```
