
WITH MY_SCOPE AS 
( 
SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_WEEK, AGE.CD_POLO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_ELO_STATUS,
SUP.CD_SALES_GROUP, ITEM.CD_ELO_AGENDAMENTO_ITEM, ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR, 
ITEM.CD_CLIENTE, ITEM.CD_PRODUTO_SAP, ITEM.CD_INCOTERMS, 
WEEKSS.CD_ELO_AGENDAMENTO_WEEK, WEEKSS.NU_SEMANA, WEEKSS.QT_SEMANA, WEEKSS.QT_EMERGENCIAL,
CASE 

WHEN (SELECT SUM(DDS.NU_QUANTIDADE) 
FROM VND.ELO_AGENDAMENTO_DAY DDS 
WHERE DDS.CD_ELO_AGENDAMENTO_WEEK = WEEKSS.CD_ELO_AGENDAMENTO_WEEK)  IS NULL THEN NULL
WHEN 
ABS((SELECT SUM(DDS.NU_QUANTIDADE) 
FROM VND.ELO_AGENDAMENTO_DAY DDS 
WHERE DDS.CD_ELO_AGENDAMENTO_WEEK = WEEKSS.CD_ELO_AGENDAMENTO_WEEK) - WEEKSS.QT_SEMANA) > 1.00 THEN  
(SELECT SUM(DDS.NU_QUANTIDADE) 
FROM VND.ELO_AGENDAMENTO_DAY DDS 
WHERE DDS.CD_ELO_AGENDAMENTO_WEEK = WEEKSS.CD_ELO_AGENDAMENTO_WEEK)
ELSE WEEKSS.QT_SEMANA END 
SUM_OF_DAY
 
FROM VND.ELO_AGENDAMENTO AGE
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO
INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
ON 
SUP.CD_ELO_AGENDAMENTO_SUPERVISOR  = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEEKSS
ON WEEKSS.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM 

WHERE 
AGE.IC_ATIVO = 'S'
AND SUP.IC_ATIVO = 'S'
AND ITEM.IC_ATIVO = 'S'
),

CTE_CARTEIRA AS 
(
SELECT CT.CD_ELO_AGENDAMENTO, CT.NU_ORDEM, CT.CD_SALES_GROUP, CT.CD_ELO_CARTEIRA, CT.NU_CONTRATO_SAP, CT.CD_ITEM_CONTRATO, 
CT.NU_ORDEM_VENDA, CT.CD_PRODUTO_SAP, 
CT.CD_ELO_AGENDAMENTO_ITEM, CT.QT_AGENDADA_CONFIRMADA , CT.QT_AGENDADA, CT.CD_STATUS_CEL_FINAL, 
CT.CD_STATUS_CUSTOMER_SERVICE, CT.CD_STATUS_TORRE_FRETES, CT.CD_INCOTERMS,
CASE 
WHEN CT.CD_INCOTERMS = 'CIF' THEN CT.CD_CLIENTE_RECEBEDOR 
ELSE CT.CD_CLIENTE_PAGADOR END CD_CLIENTE ,
CT.CD_TIPO_AGENDAMENTO, CT.CD_STATUS_REPLAN, CT.IC_ATIVO


FROM VND.ELO_CARTEIRA CT 
WHERE CT.IC_ATIVO = 'S' 
AND EXISTS (SELECT 1 FROM MY_SCOPE MAGE 
WHERE MAGE.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM)


)

SELECT 
MS.CD_ELO_AGENDAMENTO, MS.CD_WEEK,  MS.CD_POLO, MS.CD_CENTRO_EXPEDIDOR, MS.CD_ELO_STATUS, MS.CD_SALES_GROUP, 
MS.CD_CLIENTE, --CTA.CD_CLIENTE CART_CLIENTE, 
MS.CD_PRODUTO_SAP, --CTA.CD_PRODUTO_SAP CART_PRODUTO_SAP, 

MS.CD_ELO_AGENDAMENTO_WEEK, MS.NU_SEMANA,
--CTA.CD_SALES_GROUP, 
 CTA.CD_ELO_CARTEIRA, CTA.NU_CONTRATO_SAP,  CTA.CD_ITEM_CONTRATO,   
CTA.CD_STATUS_CUSTOMER_SERVICE, CTA.CD_STATUS_TORRE_FRETES, 
CTA.CD_TIPO_AGENDAMENTO, CTA.CD_STATUS_REPLAN,
MS.CD_INCOTERMS,-- CTA.CD_INCOTERMS CART_INCOTERMS,
MS.CD_ELO_AGENDAMENTO_ITEM,
CTA.NU_ORDEM, CTA.CD_STATUS_CEL_FINAL,
MS.QT_SEMANA, MS.QT_EMERGENCIAL, MS.SUM_OF_DAY, 
CTA.QT_AGENDADA_CONFIRMADA, CTA.QT_AGENDADA, 

(SELECT SUM(GGC.QT_AGENDADA) FROM CTE_CARTEIRA GGC
WHERE 
GGC.CD_ELO_AGENDAMENTO_ITEM = CTA.CD_ELO_AGENDAMENTO_ITEM) QT_AGENDADA_BY_ITEM, 


(SELECT SUM(GGC.QT_AGENDADA_CONFIRMADA) FROM CTE_CARTEIRA GGC
WHERE 
GGC.CD_ELO_AGENDAMENTO_ITEM = CTA.CD_ELO_AGENDAMENTO_ITEM 
AND GGC.IC_ATIVO = 'S' 
AND GGC.CD_STATUS_CEL_FINAL = 59 
AND (GGC.CD_TIPO_AGENDAMENTO IN (22, 23,24) OR ( GGC.CD_TIPO_AGENDAMENTO = 25 AND GGC.CD_STATUS_REPLAN = 32 ))) ITEMBYCARTEIRA, 

(SELECT SUM(GGC.QT_AGENDADA) FROM CTE_CARTEIRA GGC
WHERE 
GGC.CD_ELO_AGENDAMENTO_ITEM = CTA.CD_ELO_AGENDAMENTO_ITEM 
AND GGC.IC_ATIVO = 'S' 
AND GGC.CD_STATUS_CEL_FINAL = 59
AND (GGC.CD_TIPO_AGENDAMENTO IN (22, 23,24) OR ( GGC.CD_TIPO_AGENDAMENTO = 25 AND GGC.CD_STATUS_REPLAN = 32 ))) ITEMBYAGENDAMENTO

FROM CTE_CARTEIRA CTA
INNER JOIN MY_SCOPE MS
ON
CTA.CD_ELO_AGENDAMENTO_ITEM = MS.CD_ELO_AGENDAMENTO_ITEM  
 
WHERE 1=1
AND MS.CD_ELO_STATUS IN (1,2,3,4,5,6,7,8)
AND NVL(CTA.CD_TIPO_AGENDAMENTO, 28) IN (22, 23,24, 28 )
--AND CTA.QT_AGENDADA = 0
AND CTA.QT_AGENDADA_CONFIRMADA > 0 
AND CTA.CD_STATUS_CEL_FINAL = 59
--and CTA.cd_elo_agendamento_item = 13079

ORDER BY MS.CD_ELO_AGENDAMENTO, MS.CD_ELO_AGENDAMENTO_ITEM, CTA.NU_ORDEM

;

