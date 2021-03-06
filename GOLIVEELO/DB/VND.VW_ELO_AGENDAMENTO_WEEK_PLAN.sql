 CREATE OR REPLACE FORCE VIEW "VND"."VW_ELO_AGENDAMENTO_WEEK_PLAN" 
 ( CD_ELO_AGENDAMENTO_WEEK,CD_ELO_AGENDAMENTO_ITEM,NU_SEMANA,QT_COTA,QT_SEMANA,QT_EMERGENCIAL, IC_AJUSTE ) AS 
 
WITH CTE_ITEM_FU AS (

SELECT ITEM.CD_ELO_AGENDAMENTO_ITEM, IWEEKING.CD_ELO_AGENDAMENTO_WEEK
/*, ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR, ITEM.CD_CLIENTE, 
ITEM.CD_PRODUTO_SAP, ITEM.CD_COTA_COMPARTILHADA, ITEM.DS_OBSERVACAO_TORRE_FRETES,
ITEM.IC_ATIVO, ITEM.IC_CORTADO_SEMANA_ANTERIOR, ITEM.CD_ELO_PRIORITY_OPTION, ITEM.CD_STATUS_REPLAN,
ITEM.CD_ELO_AGENDAMENTO_ITEM_ANTIGO, ITEM.IC_ADICAO*/
FROM VND.ELO_AGENDAMENTO_ITEM ITEM
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
ON ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR = SUP.CD_ELO_AGENDAMENTO_SUPERVISOR
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO
INNER JOIN VND.ELO_STATUS AGE_ST
ON AGE.CD_ELO_STATUS = AGE_ST.CD_ELO_STATUS
AND AGE_ST.SG_STATUS IN ('PLAN',' AGCTR')
INNER JOIN VND.ELO_AGENDAMENTO_WEEK IWEEKING
ON 
IWEEKING.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM

WHERE EXISTS (
    SELECT 1 FROM VND.ELO_AGENDAMENTO_WEEK WEEK
    INNER JOIN (
        SELECT 
        TRUNC(SUM((DAYSF.NU_QUANTIDADE)),0) NU_QUANTIDADE, DAYSF.CD_ELO_AGENDAMENTO_WEEK 
        FROM VND.ELO_AGENDAMENTO_DAY DAYSF 
        GROUP BY DAYSF.CD_ELO_AGENDAMENTO_WEEK
        ) WEEK_FU
        ON
        WEEK_FU.CD_ELO_AGENDAMENTO_WEEK = WEEK.CD_ELO_AGENDAMENTO_WEEK

WHERE WEEK.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM
AND WEEK_FU.NU_QUANTIDADE > WEEK.QT_SEMANA)
),
--select * from CTE_ITEM_FU

CTE_CARTEIRA AS (
SELECT 
--NVL(CT.CD_CENTRO_EXPEDIDOR_FABRICA, CT.CD_CENTRO_EXPEDIDOR) CD_CENTRO_EXPEDIDOR, 
CT.CD_ELO_AGENDAMENTO_ITEM, CT.QT_AGENDADA_CONFIRMADA QT_AGENDADA_CONFIRMADA
FROM VND.ELO_CARTEIRA CT
INNER JOIN CTE_ITEM_FU ITEMF
ON ITEMF.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM
WHERE 
CT.IC_ATIVO = 'S'
--AND  CT.QT_AGENDADA_CONFIRMADA > 0 
--GROUP BY 
--NVL(CT.CD_CENTRO_EXPEDIDOR_FABRICA, CT.CD_CENTRO_EXPEDIDOR),
--CT.CD_ELO_AGENDAMENTO_ITEM
),
CTE_WEEK AS (
SELECT IWEEK.CD_ELO_AGENDAMENTO_WEEK, IWEEK.CD_ELO_AGENDAMENTO_ITEM, 
IWEEK.NU_SEMANA, IWEEK.QT_COTA,
LEAST(IWEEK.QT_SEMANA, NVL((SELECT SUM(ICTG.QT_AGENDADA_CONFIRMADA) QT
                        FROM CTE_CARTEIRA ICTG 
                        WHERE
                        ICTG.CD_ELO_AGENDAMENTO_ITEM = IWEEK.CD_ELO_AGENDAMENTO_ITEM  ), 99999999))  QT_SEMANA  , 
IWEEK.QT_EMERGENCIAL,
IWEEK.QT_SEMANA QT_SEMANA_ORIGINAL

FROM VND.ELO_AGENDAMENTO_WEEK IWEEK
WHERE 
EXISTS (SELECT 1 FROM CTE_ITEM_FU ITEMFG 
WHERE ITEMFG.CD_ELO_AGENDAMENTO_WEEK = IWEEK.CD_ELO_AGENDAMENTO_WEEK)

)
SELECT 
CWEEK.CD_ELO_AGENDAMENTO_WEEK,
CWEEK.CD_ELO_AGENDAMENTO_ITEM,
CWEEK.NU_SEMANA,
CWEEK.QT_COTA,
CWEEK.QT_SEMANA,
CWEEK.QT_EMERGENCIAL,
'S' IC_AJUSTE

FROM CTE_WEEK CWEEK
UNION 
SELECT 
IGWEEK.CD_ELO_AGENDAMENTO_WEEK,
IGWEEK.CD_ELO_AGENDAMENTO_ITEM,
IGWEEK.NU_SEMANA,
IGWEEK.QT_COTA,
IGWEEK.QT_SEMANA,
IGWEEK.QT_EMERGENCIAL,
'O' IC_AJUSTE

FROM VND.ELO_AGENDAMENTO_ITEM ITEM
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
ON ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR = SUP.CD_ELO_AGENDAMENTO_SUPERVISOR
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO
INNER JOIN VND.ELO_STATUS AGE_ST
ON AGE.CD_ELO_STATUS = AGE_ST.CD_ELO_STATUS
AND AGE_ST.SG_STATUS IN ('PLAN',' AGCTR')
INNER JOIN VND.ELO_AGENDAMENTO_WEEK IGWEEK
ON 
IGWEEK.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM

WHERE 
NOT EXISTS (SELECT 1 FROM CTE_WEEK IIW WHERE IIW.CD_ELO_AGENDAMENTO_WEEK = IGWEEK.CD_ELO_AGENDAMENTO_WEEK);


/
GRANT SELECT ON "VND"."VW_ELO_AGENDAMENTO_WEEK_PLAN" TO VND, VND_SEC; 

