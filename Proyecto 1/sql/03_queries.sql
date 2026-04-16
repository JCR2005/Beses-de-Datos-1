

--1. Goles totales por equipo en la Champions League en finales(2010-2019)

    SELECT t.team_name,
    SUM(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE 0 END 
        + Case WHEN m.away_team_id = t.team_id then m.away_score ELSE 0 end) as goles_totales
        FROM "MATCH" m 
        join competition_season cs on m.competition_season_id = cs.competition_season_id
        join competition c on cs.competition_id = c.competition_id
        join team t on m.home_team_id = t.team_id or m.away_team_id = t.team_id
        where c.competition_name = 'Champions League'
        group by t.team_name
        order by goles_totales desc;


 --2. Top 5 equipos visitantes con mas victorias sin importar competencia

    SELECT t.team_name, COUNT(*) AS Ganadores
        FROM "MATCH" m
        JOIN team t ON m.away_team_id = t.team_id
        WHERE m.away_score > m.home_score
        GROUP BY t.team_name
        ORDER BY Ganadores DESC;

--3. Goles hechos en cada final de la Champions League(1010-2019)
    SELECT s.season_name,
        SUM( m.home_score + m.away_score) AS total_goals
        FROM "MATCH" m
        JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
        JOIN competition c ON cs.competition_id = c.competition_id
        JOIN season s ON cs.season_id = s.season_id
        WHERE c.competition_name = 'Champions League'
        GROUP BY s.season_name
        ORDER BY s.season_name;

--4. Equipos con mayor promedio de goles en finales UCL(2010-2019)
    SELECT t.team_name,
                AVG(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE m.away_score END) AS goles
            FROM "MATCH" m
            JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
            JOIN competition c ON cs.competition_id = c.competition_id
            JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
            WHERE c.competition_name = 'Champions League'
            GROUP BY t.team_name
            ORDER BY goles DESC;

--. top 10 mundiales jugador por selección
    SELECT FIRST 10 t.team_name, COUNT(DISTINCT m.competition_season_id) as torneos
            FROM "MATCH" m JOIN team t ON (m.home_team_id = t.team_id)
            GROUP BY t.team_name ORDER BY torneos DESC;

--6. tiros por equipo final 2019 UCL
    SELECT t.team_name,
         SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
         SUM(CASE WHEN e.event_type LIKE 'Shot%' AND e.outcome = 'Goal' THEN 1 ELSE 0 END) AS goles
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 22912
    GROUP BY t.team_name
    ORDER BY tiros DESC;

--7. Heatmap de tiros en la final UCL 2019 (Liverpool vs Tottenham)
        SELECT e.x, e.y, t.team_name
            FROM "EVENT" e
            JOIN team t ON e.team_id = t.team_id
         WHERE e.match_id = 22912
             AND e.event_type LIKE 'Shot%'
             AND e.x IS NOT NULL AND e.y IS NOT NULL;

--8. Mapa de pases exitosos de Liverpool en la final 2019
        SELECT e.x, e.y, e.end_x, e.end_y
            FROM "EVENT" e
            JOIN team t ON e.team_id = t.team_id
         WHERE e.match_id = 22912
             AND t.team_name = 'Liverpool'
             AND e.event_type LIKE 'Pass%'
             AND (e.outcome = 'Successful' OR e.outcome IS NULL)
             AND e.x IS NOT NULL AND e.y IS NOT NULL
             AND e.end_x IS NOT NULL AND e.end_y IS NOT NULL;

--9. goles por equipo Argentina vs Inglaterra 1986
    SELECT t.team_name,
           SUM(CASE WHEN e.is_goal = 1 THEN 1 ELSE 0 END) AS goles
      FROM "EVENT" e
      JOIN team t ON e.team_id = t.team_id
     WHERE e.match_id = 3750191
     GROUP BY t.team_name
     ORDER BY goles DESC;

--10. Goleadores de la final UCL 2019
    SELECT p.player_name,
           COUNT(*) AS goles_final
      FROM "EVENT" e
      JOIN player p ON e.player_id = p.player_id
     WHERE e.match_id = 22912
       AND e.is_goal = 1
     GROUP BY p.player_name
     ORDER BY goles_final DESC;

--11. Tiros por jugador en la final UCL 2019
        SELECT p.player_name, COUNT(*) AS tiros
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 22912
             AND e.event_type LIKE 'Shot%'
         GROUP BY p.player_name
         ORDER BY tiros DESC;

--12. Distribución de tiros por minuto en la final UCL 2019
        SELECT e.minute_value AS minuto,
                     COUNT(*) AS tiros
            FROM "EVENT" e
         WHERE e.match_id = 22912
             AND e.event_type LIKE 'Shot%'
         GROUP BY e.minute_value
         ORDER BY minuto;

--13. Faltas por equipo en la final UCL 2019
    SELECT t.team_name,
         COUNT(*) AS faltas
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 22912
      AND e.event_type = 'Foul Committed'
    GROUP BY t.team_name
    ORDER BY faltas DESC;

--14. Precisión de pase por equipo en la final UCL 2019
    SELECT t.team_name,
         SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END) AS pases,
         SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
           CAST(SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS DECIMAL(10,2)) /
           NULLIF(SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END), 0) AS precision_pct
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 22912
    GROUP BY t.team_name
    ORDER BY precision_pct DESC;

--15. Heatmap de tiros Argentina vs Inglaterra 1986
    SELECT e.x, e.y, t.team_name
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 3750191
      AND e.event_type LIKE 'Shot%'
      AND e.x IS NOT NULL AND e.y IS NOT NULL;

--16. Tiros y goles por equipo Argentina vs Inglaterra 1986
    SELECT t.team_name,
         SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
         SUM(CASE WHEN e.event_type LIKE 'Shot%' AND e.is_goal = 1 THEN 1 ELSE 0 END) AS goles
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 3750191
    GROUP BY t.team_name
    ORDER BY tiros DESC;

--17. Goleadores Argentina vs Inglaterra 1986
    SELECT p.player_name,
         COUNT(*) AS goles
     FROM "EVENT" e
     JOIN player p ON e.player_id = p.player_id
    WHERE e.match_id = 3750191
      AND e.is_goal = 1
    GROUP BY p.player_name
    ORDER BY goles DESC;

--18. Tiros por minuto Argentina vs Inglaterra 1986
    SELECT e.minute_value AS minuto,
         COUNT(*) AS tiros
     FROM "EVENT" e
    WHERE e.match_id = 3750191
      AND e.event_type LIKE 'Shot%'
    GROUP BY e.minute_value
    ORDER BY minuto;

--19. Faltas por equipo Argentina vs Inglaterra 1986
    SELECT t.team_name,
         COUNT(*) AS faltas
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 3750191
      AND e.event_type = 'Foul Committed'
    GROUP BY t.team_name
    ORDER BY faltas DESC;

--20. Precisión de pase Argentina vs Inglaterra 1986
    SELECT t.team_name,
         SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END) AS pases,
         SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
           CAST(SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS DECIMAL(10,2)) /
           NULLIF(SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END), 0) AS precision_pct
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 3750191
    GROUP BY t.team_name
    ORDER BY precision_pct DESC;

--21. Posesión promedio por equipo Mundial 2022
    SELECT t.team_name,
         AVG(mts.possession_pct) AS posesion_promedio
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY posesion_promedio DESC;

--22. Top 10 tiros totales Mundial 2022
    SELECT FIRST 10 t.team_name,
         SUM(mts.shots_total) AS tiros
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY tiros DESC;

--23. Top 10 tiros a puerta Mundial 2022
    SELECT FIRST 10 t.team_name,
         SUM(mts.shots_on_target) AS tiros_arco
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY tiros_arco DESC;
    

--24. Precisión de pase por equipo Mundial 2022
    SELECT t.team_name,
         SUM(mts.passes_completed) AS pases_completos,
         SUM(mts.passes_attempted) AS pases_intentados,
           CAST(SUM(mts.passes_completed) AS DECIMAL(10,2)) /
           NULLIF(SUM(mts.passes_attempted), 0) AS precision_pct
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY precision_pct DESC;

--25. Tarjetas amarillas por equipo Mundial 2022
    SELECT t.team_name,
         SUM(mts.yellow_cards) AS amarillas
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY amarillas DESC;

--26. Offsides por equipo Mundial 2022
    SELECT t.team_name,
         SUM(mts.offsides) AS offsides
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY offsides DESC;

--27. Corners por equipo Mundial 2022
    SELECT t.team_name,
         SUM(mts.corners) AS corners
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id BETWEEN 3913071 AND 3913134
    GROUP BY t.team_name
    ORDER BY corners DESC;

--28. Estadísticas Final Mundial 2022 (Argentina vs Francia)
    SELECT t.team_name,
         mts.possession_pct AS posesion,
         mts.shots_total AS tiros,
         mts.shots_on_target AS tiros_arco,
         mts.passes_completed AS pases_completos
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id = 3913134
    ORDER BY tiros DESC;

--29. Semifinal Argentina vs Croacia 2022
    SELECT t.team_name,
         mts.possession_pct AS posesion,
         mts.shots_total AS tiros,
         mts.shots_on_target AS tiros_arco,
         mts.passes_completed AS pases_completos
     FROM match_team_stats mts
     JOIN team t ON mts.team_id = t.team_id
    WHERE mts.match_id = 3913131
    ORDER BY tiros DESC;



--30. Mapa de pases de Diego Maradona vs Inglaterra 1986
        SELECT e.x, e.y, e.end_x, e.end_y
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191
             AND p.player_name LIKE '%Maradona%'
             AND e.event_type LIKE 'Pass%'
             AND e.x IS NOT NULL AND e.y IS NOT NULL
             AND e.end_x IS NOT NULL AND e.end_y IS NOT NULL;

--31. Heatmap de conducciones de balon de Maradona vs Inglaterra 1986
        SELECT e.x, e.y
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191
             AND p.player_name LIKE '%Maradona%'
             AND e.event_type = 'Carry'
             AND e.x IS NOT NULL AND e.y IS NOT NULL;

--32. Resumen de métricas de Maradona vs Inglaterra 1986
        SELECT 'Eventos' AS metric, COUNT(*) AS valor
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%'
        UNION ALL
        SELECT 'Pases', COUNT(*)
            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE 'Pass%'
        UNION ALL
        SELECT 'Pases Completos', COUNT(*)
            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE 'Pass%' AND e.outcome IS NULL
        UNION ALL
        SELECT 'Carries', COUNT(*)
            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type = 'Carry'
        UNION ALL
        SELECT 'Dribbles', COUNT(*)
            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE '%Dribble%'
        UNION ALL
        SELECT 'Tiros', COUNT(*)
            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE 'Shot%'
        UNION ALL
        SELECT 'Goles', COUNT(*)
            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.is_goal = 1;

--33. Tiros y goles por equipo en la final UCL 2015 (Juventus vs Barcelona)
    SELECT t.team_name,
           SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
           SUM(CASE WHEN e.event_type LIKE 'Shot%' AND e.outcome = 'Goal' THEN 1 ELSE 0 END) AS goles
      FROM "EVENT" e
      JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 2015
     GROUP BY t.team_name
     ORDER BY tiros DESC;

--34. Heatmap de tiros en la final UCL 2015
        SELECT e.x, e.y, t.team_name
            FROM "EVENT" e
            JOIN team t ON e.team_id = t.team_id
         WHERE e.match_id = 2015
             AND e.event_type LIKE 'Shot%'
             AND e.x IS NOT NULL AND e.y IS NOT NULL;

--35. Mapa de pases exitosos de Barcelona en la final 2015
        SELECT e.x, e.y, e.end_x, e.end_y
            FROM "EVENT" e
            JOIN team t ON e.team_id = t.team_id
         WHERE e.match_id = 2015
             AND t.team_name = 'Barcelona'
             AND e.event_type LIKE 'Pass%'
             AND (e.outcome = 'Successful' OR e.outcome IS NULL)
             AND e.x IS NOT NULL AND e.y IS NOT NULL
             AND e.end_x IS NOT NULL AND e.end_y IS NOT NULL;

--36. Precisión de pase por equipo en la final UCL 2015
    SELECT t.team_name,
           SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END) AS pases,
           SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
             CAST(SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS DECIMAL(10,2)) /
             NULLIF(SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END), 0) AS precision_pct
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
    WHERE e.match_id = 2015
    GROUP BY t.team_name
    ORDER BY precision_pct DESC; 

--37. Faltas cometidas por equipo en la final UCL 2015
    SELECT t.team_name,
         COUNT(*) AS faltas
     FROM "EVENT" e
     JOIN team t ON e.team_id = t.team_id
        WHERE e.match_id = 2015
      AND e.event_type = 'Foul Committed'
    GROUP BY t.team_name
    ORDER BY faltas DESC;

--38. Goleadores de la final UCL 2015
        SELECT p.player_name,
                     COUNT(*) AS goles
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND e.is_goal = 1
         GROUP BY p.player_name
         ORDER BY goles DESC;

--39. Resumen de métricas de Messi en la final UCL 2015
        SELECT 'Eventos' AS metric, COUNT(*) AS valor
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
        UNION ALL
        SELECT 'Pases', COUNT(*)
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
             AND e.event_type LIKE 'Pass%'
        UNION ALL
        SELECT 'Pases Completos', COUNT(*)
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
             AND e.event_type LIKE 'Pass%'
             AND e.outcome IS NULL
        UNION ALL
        SELECT 'Carries', COUNT(*)
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
             AND e.event_type = 'Carry'
        UNION ALL
        SELECT 'Dribbles', COUNT(*)
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
             AND e.event_type LIKE '%Dribble%'
        UNION ALL
        SELECT 'Tiros', COUNT(*)
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
             AND e.event_type LIKE 'Shot%'
        UNION ALL
        SELECT 'Goles', COUNT(*)
            FROM "EVENT" e
            JOIN player p ON e.player_id = p.player_id
         WHERE e.match_id = 2015
             AND p.player_name LIKE '%Messi%'
             AND e.is_goal = 1;

--40. Goles por equipo en el Mundial 2018
        SELECT t.team_name,
                     SUM(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE 0 END
                             + CASE WHEN m.away_team_id = t.team_id THEN m.away_score ELSE 0 END) AS goles
            FROM "MATCH" m
            JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
         WHERE m.competition_season_id = 11
         GROUP BY t.team_name
         ORDER BY goles DESC;

--41. Victorias por equipo en el Mundial 2018
        SELECT t.team_name,
                     SUM(CASE WHEN m.home_team_id = t.team_id AND m.home_score > m.away_score THEN 1 ELSE 0 END
                             + CASE WHEN m.away_team_id = t.team_id AND m.away_score > m.home_score THEN 1 ELSE 0 END) AS victorias
            FROM "MATCH" m
            JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
         WHERE m.competition_season_id = 11
         GROUP BY t.team_name
         ORDER BY victorias DESC;

--42. Promedio de goles por partido en el Mundial 2018
        SELECT AVG(m.home_score + m.away_score) AS promedio_goles
            FROM "MATCH" m
         WHERE m.competition_season_id = 11;

--43. Goles por fase en el Mundial 2018
        SELECT s.stage_name,
                     SUM(m.home_score + m.away_score) AS goles
            FROM "MATCH" m
            JOIN stage s ON m.stage_id = s.stage_id
         WHERE m.competition_season_id = 11
         GROUP BY s.stage_name
         ORDER BY goles DESC;

--44. Goles por equipo en La Liga
        SELECT t.team_name,
                     SUM(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE 0 END
                             + CASE WHEN m.away_team_id = t.team_id THEN m.away_score ELSE 0 END) AS goles
            FROM "MATCH" m
            JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
            JOIN competition c ON cs.competition_id = c.competition_id
            JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
         WHERE c.competition_name = 'La Liga'
         GROUP BY t.team_name
         ORDER BY goles DESC;

--45. Victorias por equipo en La Liga
        SELECT t.team_name,
                     SUM(CASE WHEN m.home_team_id = t.team_id AND m.home_score > m.away_score THEN 1 ELSE 0 END
                             + CASE WHEN m.away_team_id = t.team_id AND m.away_score > m.home_score THEN 1 ELSE 0 END) AS victorias
            FROM "MATCH" m
            JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
            JOIN competition c ON cs.competition_id = c.competition_id
            JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
         WHERE c.competition_name = 'La Liga'
         GROUP BY t.team_name
         ORDER BY victorias DESC;


--45. Goles por temporada en La Liga
        SELECT s.season_name,
                     SUM(m.home_score + m.away_score) AS goles
            FROM "MATCH" m
            JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
            JOIN competition c ON cs.competition_id = c.competition_id
            JOIN season s ON cs.season_id = s.season_id
         WHERE c.competition_name = 'La Liga'
         GROUP BY s.season_name
         ORDER BY s.season_name;