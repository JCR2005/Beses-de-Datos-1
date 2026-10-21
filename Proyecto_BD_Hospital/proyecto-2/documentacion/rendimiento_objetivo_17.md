# Objetivo 17: rendimiento de las dos formas del ranking

Tiempo de ejecución (mediana de 3 corridas de `EXPLAIN ANALYZE`, en milisegundos).
Generado por `sql/consultas/rendimiento/medir_objetivo_17.sh` el 2026-10-20 18:18.

| Médicos calificados | Calificaciones | A: ventana (ms) | B: correlacionada (ms) | B / A |
|---:|---:|---:|---:|---:|
| 31 | 112 | 0.4 | 0.5 | 1.2x |
| 531 | 10112 | 8.4 | 45.3 | 5.4x |
| 2031 | 40112 | 35.3 | 576.1 | 16.3x |
| 5031 | 100112 | 115.6 | 3638.1 | 31.5x |

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
WindowAgg (actual rows=5031.00 loops=1)
  Window: w2 AS (ORDER BY pm.promedio ROWS UNBOUNDED PRECEDING)
  Storage: Memory  Maximum Storage: 17kB
  Buffers: shared hit=2519
  ->  Sort (actual rows=5031.00 loops=1)
        Sort Key: pm.promedio
        Sort Method: quicksort  Memory: 389kB
        Buffers: shared hit=2519
        ->  WindowAgg (actual rows=5031.00 loops=1)
              Window: w1 AS (PARTITION BY pm.id_hospital ORDER BY pm.promedio ROWS UNBOUNDED PRECEDING)
              Storage: Memory  Maximum Storage: 17kB
              Buffers: shared hit=2516
              ->  Sort (actual rows=5031.00 loops=1)
                    Sort Key: pm.id_hospital, pm.promedio
                    Sort Method: quicksort  Memory: 350kB
                    Buffers: shared hit=2516
                    ->  Subquery Scan on pm (actual rows=5031.00 loops=1)
                          Buffers: shared hit=2513
                          ->  HashAggregate (actual rows=5031.00 loops=1)
                                Group Key: ci.id_medico, me.id_hospital
                                Batches: 1  Memory Usage: 1297kB
                                Buffers: shared hit=2513
                                ->  Hash Join (actual rows=100112.00 loops=1)
                                      Hash Cond: (ci.id_medico = me.id_medico)
                                      Buffers: shared hit=2513
                                      ->  Hash Join (actual rows=100112.00 loops=1)
                                            Hash Cond: (co.id_cita = ci.id_cita)
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
                                                  ->  Seq Scan on cita ci (actual rows=100225.00 loops=1)
                                                        Filter: ((fecha_hora >= '2026-01-01'::date) AND (fecha_hora < '2026-11-01'::date))
                                                        Buffers: shared hit=1140
                                      ->  Hash (actual rows=5051.00 loops=1)
                                            Buckets: 8192  Batches: 1  Memory Usage: 262kB
                                            Buffers: shared hit=92
                                            ->  Seq Scan on medico me (actual rows=5051.00 loops=1)
                                                  Buffers: shared hit=92
Planning:
  Buffers: shared hit=767
Planning Time: 1.390 ms
Execution Time: 76.028 ms
```

Forma B (correlacionada): las dos subconsultas se ejecutan una vez por cada médico (loops).

```
CTE Scan on pm p1 (actual rows=5031.00 loops=1)
  Storage: Memory  Maximum Storage: 300kB
  Buffers: shared hit=2513
  CTE pm
    ->  HashAggregate (actual rows=5031.00 loops=1)
          Group Key: ci.id_medico, me.id_hospital
          Batches: 1  Memory Usage: 1553kB
          Buffers: shared hit=2513
          ->  Hash Join (actual rows=100112.00 loops=1)
                Hash Cond: (ci.id_medico = me.id_medico)
                Buffers: shared hit=2513
                ->  Hash Join (actual rows=100112.00 loops=1)
                      Hash Cond: (co.id_cita = ci.id_cita)
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
                            ->  Seq Scan on cita ci (actual rows=100225.00 loops=1)
                                  Filter: ((fecha_hora >= '2026-01-01'::date) AND (fecha_hora < '2026-11-01'::date))
                                  Buffers: shared hit=1140
                ->  Hash (actual rows=5051.00 loops=1)
                      Buckets: 8192  Batches: 1  Memory Usage: 262kB
                      Buffers: shared hit=92
                      ->  Seq Scan on medico me (actual rows=5051.00 loops=1)
                            Buffers: shared hit=92
  SubPlan 2
    ->  Aggregate (actual rows=1.00 loops=5031)
          ->  CTE Scan on pm p2 (actual rows=5.58 loops=5031)
                Filter: ((promedio < p1.promedio) AND (id_hospital = p1.id_hospital))
                Rows Removed by Filter: 5025
                Storage: Memory  Maximum Storage: 300kB
  SubPlan 3
    ->  Aggregate (actual rows=1.00 loops=5031)
          ->  CTE Scan on pm p2_1 (actual rows=2016.79 loops=5031)
                Filter: (promedio < p1.promedio)
                Rows Removed by Filter: 3014
                Storage: Memory  Maximum Storage: 300kB
Planning:
  Buffers: shared hit=812
Planning Time: 1.452 ms
Execution Time: 3240.808 ms
```
