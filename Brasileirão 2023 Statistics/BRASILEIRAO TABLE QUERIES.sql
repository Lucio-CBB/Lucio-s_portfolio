-- BRASILEIRÃO TABLE QUERIES 

-- Which game on the championship had the max number of goals and which teams were participating?

USE brasileirao;

select * 
from rodadas_realizadas_2023;

SELECT mandante, visitante, mandante_placar, visitante_placar, max(mandante_placar + visitante_placar) AS gols_totais
FROM rodadas_realizadas_2023
group by mandante, visitante, mandante_placar, visitante_placar
ORDER BY gols_totais desc;

-- Was there any team that managed to win all the direct matches against the top three teams in the standings?


-- TOP 3 TIMES: Palmeiras, Gremio e Atletico MG

/*
-- Games where Palmeiras lost
SELECT mandante, visitante, mandante_placar, visitante_placar
FROM rodadas_realizadas_2023
WHERE mandante = 'Palmeiras' AND mandante_placar < visitante_placar OR visitante = 'Palmeiras' AND mandante_placar > visitante_placar;

-- Games where Gremio lost
SELECT mandante, visitante, mandante_placar, visitante_placar
FROM rodadas_realizadas_2023
WHERE mandante = 'GrÃªmio' AND mandante_placar < visitante_placar OR visitante = 'GrÃªmio' AND mandante_placar > visitante_placar;

-- Games where Atletico MG lost
SELECT mandante, visitante, mandante_placar, visitante_placar
FROM rodadas_realizadas_2023
WHERE mandante = 'AtlÃ©tico-MG' AND mandante_placar < visitante_placar OR visitante = 'AtlÃ©tico-MG' AND mandante_placar > visitante_placar;

*/

-- TIMES COM MAIS DERROTAS E MAIS VITORIAS EM CONFRONTOS DIRETOS 

SELECT 
CASE 
	WHEN mandante_placar > visitante_placar THEN mandante 
    ELSE visitante 
    END AS time_vencedor,
SUM(CASE 
	WHEN mandante_placar > visitante_placar THEN 1
    ELSE 1
    END) AS victories
    
FROM rodadas_realizadas_2023 as A
WHERE (mandante  = 'AtlÃ©tico-MG' AND mandante_placar < visitante_placar OR visitante = 'AtlÃ©tico-MG' AND mandante_placar > visitante_placar)
OR (mandante = 'GrÃªmio' AND mandante_placar < visitante_placar OR visitante = 'GrÃªmio' AND mandante_placar > visitante_placar) 
OR (mandante = 'Palmeiras' AND mandante_placar < visitante_placar OR visitante = 'Palmeiras' AND mandante_placar > visitante_placar)
GROUP BY time_vencedor
ORDER BY victories desc;



SELECT 
CASE 
	WHEN mandante_placar < visitante_placar THEN mandante 
    ELSE visitante 
    END AS time_perdedor,

SUM(CASE 

	WHEN mandante_placar < visitante_placar THEN 1
    ELSE 1
    END) AS defeats
    
FROM rodadas_realizadas_2023 
WHERE (mandante  = 'AtlÃ©tico-MG' AND mandante_placar > visitante_placar OR visitante = 'AtlÃ©tico-MG' AND mandante_placar < visitante_placar)
OR (mandante = 'GrÃªmio' AND mandante_placar > visitante_placar OR visitante = 'GrÃªmio' AND mandante_placar < visitante_placar) 
OR (mandante = 'Palmeiras' AND mandante_placar > visitante_placar OR visitante = 'Palmeiras' AND mandante_placar < visitante_placar)
GROUP BY time_perdedor
ORDER BY defeats DESC;

-- RELAÇÃO COMPLETA COM VITORIAS, DERROTAS E EMPATES

WITH 

A AS 
(
SELECT 
(CASE 
	WHEN mandante_placar > visitante_placar THEN mandante 
    WHEN visitante_placar > mandante_placar THEN visitante
    END) AS time,
    
COALESCE(SUM(CASE 
	WHEN mandante_placar > visitante_placar THEN 1
    ELSE 1
    END), 0) AS victories

FROM rodadas_realizadas_2023 as A
WHERE (mandante  = 'AtlÃ©tico-MG' AND mandante_placar < visitante_placar OR visitante = 'AtlÃ©tico-MG' AND mandante_placar > visitante_placar)
OR (mandante = 'GrÃªmio' AND mandante_placar < visitante_placar OR visitante = 'GrÃªmio' AND mandante_placar > visitante_placar) 
OR (mandante = 'Palmeiras' AND mandante_placar < visitante_placar OR visitante = 'Palmeiras' AND mandante_placar > visitante_placar)
GROUP BY time),

B AS
(
SELECT
(CASE 
	WHEN mandante_placar < visitante_placar THEN mandante 
    ELSE visitante 
    END) AS time,
    
coalesce(sum(CASE 
	WHEN mandante_placar = visitante_placar THEN 1
    END),0) AS empates,
    
COALESCE(SUM(CASE 

	WHEN mandante_placar < visitante_placar THEN 1
    ELSE 1
    END), 0) AS defeats

FROM rodadas_realizadas_2023 
WHERE (mandante  = 'AtlÃ©tico-MG' AND mandante_placar > visitante_placar OR visitante = 'AtlÃ©tico-MG' AND mandante_placar < visitante_placar)
OR (mandante = 'GrÃªmio' AND mandante_placar > visitante_placar OR visitante = 'GrÃªmio' AND mandante_placar < visitante_placar) 
OR (mandante = 'Palmeiras' AND mandante_placar > visitante_placar OR visitante = 'Palmeiras' AND mandante_placar < visitante_placar)

GROUP BY time),

C 
AS 
(SELECT 
CASE
WHEN mandante = 'AtlÃ©tico-MG' then visitante
WHEN visitante = 'AtlÃ©tico-MG' then mandante
WHEN mandante = 'GrÃªmio' then visitante
WHEN visitante = 'GrÃªmio' then mandante
WHEN mandante = 'Palmeiras' then visitante
WHEN visitante = 'Palmeiras'then mandante
END AS time,

coalesce(count(CASE 
	WHEN mandante_placar = visitante_placar THEN 1
    END),0) AS empates

FROM rodadas_realizadas_2023 
WHERE
(mandante  = 'AtlÃ©tico-MG' AND mandante_placar = visitante_placar) OR (visitante = 'AtlÃ©tico-MG' AND mandante_placar = visitante_placar) 
OR (mandante = 'GrÃªmio' AND mandante_placar = visitante_placar) OR (visitante = 'GrÃªmio' AND mandante_placar = visitante_placar) 
OR (mandante = 'Palmeiras' AND mandante_placar = visitante_placar) OR (visitante = 'Palmeiras' AND mandante_placar = visitante_placar) 
group by time)

SELECT  COALESCE(A.time,B.time) AS time, COALESCE((A.victories),0) AS victories, COALESCE((B.defeats),0) AS derrotas, COALESCE((C.empates),0) AS empates
FROM B
LEFT JOIN A ON A.time = B.time
LEFT JOIN C ON B.time = C.time

ORDER BY victories desc;




-- WHICH TEAM HAS PRESENTED MOST AND LEAST PRO GOALS ON THE CHAMPIONSHIP AND HOW DID THIS REFLECTED ON ITS FINAL POSITION ON THE TABLE?


SELECT time, Saldo_de_gols, posicao, pontos 
FROM classificacao_2023
WHERE rodada = '38'
order by saldo_de_gols desc;

SELECT time, Saldo_de_gols, posicao, pontos 
FROM classificacao_2023
WHERE rodada = '38'
order by saldo_de_gols asc;

-- MATCHES WHERE HE HAD A 3 OR MORE GOALS OF DIFFERENCE ON THE CHAMPIONSHIP

SELECT
CASE 
	WHEN mandante_placar > visitante_placar THEN mandante 
    ELSE visitante 
    END AS time_vencedor,
    
mandante, visitante, mandante_placar, visitante_placar, rodada, ABS(mandante_placar - visitante_placar) AS saldo_gols
FROM rodadas_realizadas_2023
WHERE ((mandante_placar - visitante_placar >= 3) OR (Visitante_Placar - mandante_placar >= 3))
ORDER BY saldo_gols DESC;


-- WHICH TEAM HAD THE MOST VICTORIOUS SEQUENCE AND HOW DID THIS AFFECT ON ITS POSITIONING ON THE TABLE


WITH 
tabela_classificacao_final AS 
(
SELECT posicao, time
FROM classificacao_2023
WHERE rodada = '38'

) 

SELECT tabela_classificacao_final.time, max(classificacao_2023.vitorias_consecutivas) AS vitorias_seguidas, tabela_classificacao_final.posicao AS posicao_final
FROM tabela_classificacao_final
LEFT JOIN classificacao_2023
ON tabela_classificacao_final.time = classificacao_2023.time
GROUP BY tabela_classificacao_final.time, posicao_final
ORDER BY vitorias_seguidas DESC;


-- WHICH TEAM HAD THE MOST DEFEAT SEQUENCE AND HOW DID THIS AFFECT ON ITS POSITIONING ON THE TABLE

WITH 
tabela_classificacao_final AS 
(
SELECT posicao, time
FROM classificacao_2023
WHERE rodada = '38'

) 

SELECT tabela_classificacao_final.time, max(classificacao_2023.derrotas_consecutivas) AS derrotas_seguidas, tabela_classificacao_final.posicao AS posicao_final
FROM tabela_classificacao_final
LEFT JOIN classificacao_2023
ON tabela_classificacao_final.time = classificacao_2023.time
GROUP BY tabela_classificacao_final.time, posicao_final
ORDER BY derrotas_seguidas DESC;


-- WHICH TEAM HAD THE BEST WINNING PERCENTAGE ON HOME GAMES AND WHAT WAS THE MAIN IMPACT ON ITS FINAL CLASSIFICATION

SELECT * FROM rodadas_realizadas_2023;



WITH tabela_vitorias AS 
(
SELECT
(CASE
WHEN mandante_placar > visitante_placar THEN Mandante
END) AS time,

COUNT(CASE
WHEN mandante_placar > visitante_placar THEN Mandante 
END) AS vitorias_mandante

FROM rodadas_realizadas_2023
WHERE mandante_placar > visitante_placar
GROUP BY time

),
tabela_total AS 
(
SELECT COUNT(MANDANTE) AS total_jogos_casa, mandante AS time FROM rodadas_realizadas_2023 GROUP BY mandante
),
classificacao_final AS
(
SELECT time, posicao, Rodada
from classificacao_2023 WHERE
rodada IN (SELECT DISTINCT rodada FROM classificacao_2023 WHERE rodada = '38')
)

SELECT tabela_vitorias.time, tabela_total.total_jogos_casa, tabela_vitorias.vitorias_mandante, tabela_vitorias.vitorias_mandante/tabela_total.total_jogos_casa as aproveitamento, classificacao_final.posicao
FROM tabela_vitorias
LEFT JOIN tabela_total ON tabela_total.time = tabela_vitorias.time
LEFT JOIN classificacao_final ON tabela_total.time = classificacao_final.time
ORDER BY aproveitamento DESC;



-- WHICH TEAM HAD THE BEST WINNING PERCENTAGE ON AWAY GAMES AND WHAT WAS THE MAIN IMPACT ON ITS FINAL CLASSIFICATION


WITH tabela_vitorias AS 
(
SELECT
(CASE
WHEN (visitante_placar - mandante_placar) >= 1 THEN Visitante
END) AS time,

COUNT(CASE
WHEN (visitante_placar - mandante_placar) >= 1  
THEN Visitante
END) AS vitorias_visitante

FROM rodadas_realizadas_2023
WHERE mandante_placar < visitante_placar
GROUP BY time

),
tabela_total AS 
(
SELECT COUNT(visitante) AS total_jogos_fora, visitante AS time FROM rodadas_realizadas_2023 GROUP BY visitante
),
classificacao_final AS
(
SELECT time, posicao, Rodada
from classificacao_2023 WHERE
rodada IN (SELECT DISTINCT rodada FROM classificacao_2023 WHERE rodada = '38')
)

SELECT tabela_vitorias.time, tabela_total.total_jogos_fora, tabela_vitorias.vitorias_visitante, tabela_vitorias.vitorias_visitante/tabela_total.total_jogos_fora as aproveitamento, classificacao_final.posicao
FROM tabela_vitorias
LEFT JOIN tabela_total ON tabela_total.time = tabela_vitorias.time
LEFT JOIN classificacao_final ON tabela_total.time = classificacao_final.time
ORDER BY aproveitamento DESC;



-- Houve algum time que teve melhor desempenho como visitante do que como mandante e como isso refletiu na sua posição no campeonato?


WITH tabela_vitorias AS 
(
SELECT
(CASE
WHEN (visitante_placar - mandante_placar) >= 1 THEN Visitante
END) AS time,

COUNT(CASE
WHEN (visitante_placar - mandante_placar) >= 1  
THEN Visitante
END) AS vitorias_visitante

FROM rodadas_realizadas_2023
WHERE mandante_placar < visitante_placar
GROUP BY time

),
tabela_total AS 
(
SELECT COUNT(visitante) AS total_jogos_fora, visitante AS time FROM rodadas_realizadas_2023 GROUP BY visitante
),
classificacao_final AS
(
SELECT time, posicao, Rodada
from classificacao_2023 WHERE
rodada IN (SELECT DISTINCT rodada FROM classificacao_2023 WHERE rodada = '38')
)

SELECT tabela_vitorias.time, tabela_total.total_jogos_fora, tabela_vitorias.vitorias_visitante, tabela_vitorias.vitorias_visitante/tabela_total.total_jogos_fora as aproveitamento, classificacao_final.posicao
FROM tabela_vitorias
LEFT JOIN tabela_total ON tabela_total.time = tabela_vitorias.time
LEFT JOIN classificacao_final ON tabela_total.time = classificacao_final.time
ORDER BY aproveitamento DESC;

WITH tabela_vitorias AS 
(
SELECT
(CASE
WHEN mandante_placar > visitante_placar THEN Mandante
END) AS time,

COUNT(CASE
WHEN mandante_placar > visitante_placar THEN Mandante 
END) AS vitorias_mandante

FROM rodadas_realizadas_2023
WHERE mandante_placar > visitante_placar
GROUP BY time

),
tabela_total AS 
(
SELECT COUNT(MANDANTE) AS total_jogos_casa, mandante AS time FROM rodadas_realizadas_2023 GROUP BY mandante
),
classificacao_final AS
(
SELECT time, posicao, Rodada
from classificacao_2023 WHERE
rodada IN (SELECT DISTINCT rodada FROM classificacao_2023 WHERE rodada = '38')
)

SELECT tabela_vitorias.time, tabela_total.total_jogos_casa, tabela_vitorias.vitorias_mandante, tabela_vitorias.vitorias_mandante/tabela_total.total_jogos_casa as aproveitamento, classificacao_final.posicao
FROM tabela_vitorias
LEFT JOIN tabela_total ON tabela_total.time = tabela_vitorias.time
LEFT JOIN classificacao_final ON tabela_total.time = classificacao_final.time
ORDER BY aproveitamento DESC;



-- TABELA APROVEITAMENTO JOGOS CASA E FORA




WITH 
tabela_vitorias_visitante AS 
(
SELECT
(CASE
WHEN (visitante_placar - mandante_placar) >= 1 THEN Visitante
END) AS time,

COUNT(CASE
WHEN (visitante_placar - mandante_placar) >= 1  
THEN Visitante
END) AS vitorias_visitante

FROM rodadas_realizadas_2023
WHERE mandante_placar < visitante_placar
GROUP BY time

),

tabela_total_visitante AS 
(
SELECT COUNT(visitante) AS total_jogos_fora, visitante AS time FROM rodadas_realizadas_2023 GROUP BY visitante
),

tabela_vitorias_mandante AS 
(
SELECT
(CASE
WHEN mandante_placar > visitante_placar THEN Mandante
END) AS time,

COUNT(CASE
WHEN mandante_placar > visitante_placar THEN Mandante 
END) AS vitorias_mandante

FROM rodadas_realizadas_2023
WHERE mandante_placar > visitante_placar
GROUP BY time

),

tabela_total_mandante AS 
(
SELECT COUNT(MANDANTE) AS total_jogos_casa, mandante AS time FROM rodadas_realizadas_2023 GROUP BY mandante
),

tabela_total_empates AS
(



)
classificacao_final AS
(
SELECT time, posicao, Rodada
from classificacao_2023 WHERE
rodada IN (SELECT DISTINCT rodada FROM classificacao_2023 WHERE rodada = '38')
)

SELECT 
tabela_vitorias_visitante.time, tabela_total_visitante.total_jogos_fora, tabela_vitorias_visitante.vitorias_visitante, tabela_vitorias_visitante.vitorias_visitante/tabela_total_visitante.total_jogos_fora as aproveitamento_visitante,
tabela_total_mandante.total_jogos_casa, tabela_vitorias_mandante.vitorias_mandante, tabela_vitorias_mandante.vitorias_mandante/tabela_total_mandante.total_jogos_casa as aproveitamento_mandante, classificacao_final.posicao
FROM tabela_vitorias_visitante
LEFT JOIN tabela_total_visitante ON tabela_total_visitante.time = tabela_vitorias_visitante.time
LEFT JOIN classificacao_final ON tabela_total_visitante.time = classificacao_final.time
LEFT JOIN tabela_total_mandante ON tabela_total_mandante.time = tabela_vitorias_visitante.time
LEFT JOIN tabela_vitorias_mandante ON tabela_vitorias_mandante.time = tabela_vitorias_visitante.time
ORDER BY (aproveitamento_mandante - aproveitamento_visitante) DESC;




-- TEST


WITH 
tabela_vitorias_visitante AS 
(
SELECT
coalesce((CASE
WHEN (visitante_placar - mandante_placar) >= 1 THEN Visitante
WHEN (mandante_placar - visitante_placar) >= 1 THEN mandante
END), 0) AS time,

coalesce(COUNT(CASE
WHEN (visitante_placar - mandante_placar) >= 1  
THEN Visitante
END),0) AS vitorias_visitante
FROM rodadas_realizadas_2023

WHERE (CASE
WHEN (visitante_placar - mandante_placar) >= 1 THEN Visitante
WHEN (mandante_placar - visitante_placar) >= 1 THEN mandante
END) IS NOT NULL
GROUP BY time

),

tabela_total_visitante AS 
(
SELECT COUNT(visitante) AS total_jogos_fora, visitante AS time FROM rodadas_realizadas_2023 GROUP BY visitante
),

tabela_vitorias_mandante AS 
(
SELECT
(CASE
WHEN mandante_placar > visitante_placar THEN Mandante
END) AS time,

coalesce(COUNT(CASE
WHEN mandante_placar > visitante_placar THEN Mandante 
END),0) AS vitorias_mandante

FROM rodadas_realizadas_2023
WHERE mandante_placar > visitante_placar
GROUP BY time

),

tabela_total_mandante AS 
(
SELECT COUNT(MANDANTE) AS total_jogos_casa, mandante AS time FROM rodadas_realizadas_2023 GROUP BY mandante
),

empates_casa AS 
(
SELECT 
 
    
	CASE 
	WHEN mandante_placar = visitante_placar THEN mandante
    END AS time, 

coalesce(count(CASE 
	WHEN mandante_placar = visitante_placar THEN 1
    END),0) AS empates_mandante
FROM rodadas_realizadas_2023
GROUP BY time),

empates_fora AS
(
SELECT 
  CASE 
	WHEN mandante_placar = visitante_placar THEN visitante
    END AS time,

	coalesce(count(CASE 
	WHEN mandante_placar = visitante_placar THEN 1
    END),0) AS empates_visitante
FROM rodadas_realizadas_2023
GROUP BY time),

classificacao_final AS
(
SELECT time, posicao, Rodada
from classificacao_2023 WHERE
rodada IN (SELECT DISTINCT rodada FROM classificacao_2023 WHERE rodada = '38')
)

SELECT 

tabela_vitorias_visitante.time, tabela_total_visitante.total_jogos_fora, COALESCE((tabela_vitorias_visitante.vitorias_visitante),0) AS vitorias_visitante, empates_fora.empates_visitante, COALESCE((tabela_vitorias_visitante.vitorias_visitante),0)/tabela_total_visitante.total_jogos_fora as aproveitamento_visitante,
tabela_total_mandante.total_jogos_casa, tabela_vitorias_mandante.vitorias_mandante,empates_casa.empates_mandante, tabela_vitorias_mandante.vitorias_mandante/tabela_total_mandante.total_jogos_casa as aproveitamento_mandante, classificacao_final.posicao
FROM tabela_vitorias_mandante
LEFT JOIN tabela_total_visitante ON tabela_total_visitante.time = tabela_vitorias_mandante.time
LEFT JOIN classificacao_final ON tabela_total_visitante.time = classificacao_final.time
LEFT JOIN tabela_total_mandante ON tabela_total_mandante.time = tabela_vitorias_mandante.time
LEFT JOIN tabela_vitorias_visitante ON tabela_vitorias_visitante.time = tabela_vitorias_mandante.time
LEFT JOIN empates_fora ON empates_fora.time = tabela_vitorias_mandante.time
LEFT JOIN empates_casa ON empates_casa.time = tabela_vitorias_mandante.time
ORDER BY (aproveitamento_mandante - aproveitamento_visitante) DESC;



