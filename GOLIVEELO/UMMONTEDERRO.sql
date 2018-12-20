SELECT * FROM JOB_ERROR
WHERE DH_EXECUTED > SYSDATE - 30;

SELECT DISTINCT AGE.NU_CARTEIRA_VERSION, AGE.CD_ELO_STATUS, CART.NU_CONTRATO_SAP, CART.NU_ORDEM_VENDA 
FROM VND.ELO_CARTEIRA CART
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON CART.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO

INNER JOIN 
(SELECT AA.CD_ELO_AGENDAMENTO
FROM  VND.ELO_AGENDAMENTO AA 
WHERE AA.CD_ELO_STATUS IN (3,4,5,6)
) S
ON S.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO 
WHERE

CART.QT_AGENDADA_CONFIRMADA > 0  

--CART.CD_STATUS_CEL_FINAL > 0
;


SELECT * FROM VND.ELO_CARTEIRA
WHERE NU_CONTRATO_SAP = '0040392084';

SELECT * FROM VND.ELO_CARTEIRA 
WHERE NVL(QT_AGENDADA_CONFIRMADA, 0) <=0
AND QT_AGENDADA >0 AND DH_CORTADO_FABRICA  IS NULL
AND NVL(CD_STATUS_CEL_FINAL, 2) <> 59
AND (CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CD_TIPO_AGENDAMENTO = 25 AND CD_STATUS_REPLAN = 32))
AND NVL(NU_PROTOCOLO_ENTREGA, 'X') <> 'GXCT_PU_POPUP:0' ;



SELECT cd_incoterms, nu_ordem_venda, cd_status_customer_service, cd_status_torre_fretes, 
dh_liberacao_torre_fretes, qt_agendada, qt_agendada_confirmada, dh_replan, cd_tipo_agendamento ,  cd_status_replan, CD_ELO_CARTEIRA_GROUPING,
DS_VERSAO
FROM VND.ELO_CARTEIRA 
WHERE NU_ORDEM_VENDA = '0002364182'
AND CD_STATUS_CEL_FINAL = 59;


SELECT * FROM ALL_SOURCE 
WHERE UPPER(TEXT) LIKE '%VW_ELO_AGENDAMENTO_WEEK_PLAN%';



SELECT cd_incoterms, nu_ordem_venda, cd_status_customer_service, cd_status_torre_fretes, 
dh_liberacao_torre_fretes, qt_agendada, qt_agendada_confirmada, dh_replan, cd_tipo_agendamento ,  cd_status_replan, CD_ELO_CARTEIRA_GROUPING,
DS_VERSAO
FROM VND.ELO_CARTEIRA
WHERE CD_INCOTERMS = 'FOB' AND CD_STATUS_TORRE_FRETES IS NOT NULL
AND CD_TIPO_AGENDAMENTO NOT IN (25);


SELECT CD_ELO_AGENDAMENTO_ITEM, COUNT(1)
FROM (
select  CD_ELO_AGENDAMENTO_ITEM 
from vnd.elo_agendamento_week
GROUP BY CD_ELO_AGENDAMENTO_ITEM
)
GROUP BY CD_ELO_AGENDAMENTO_ITEM
HAVING COUNT(1) > 1;



SELECT DISTINCT DS_CREDIT_BLOCK_REASON 
FROM ELO_CARTEIRA 
WHERE 
(CD_BLOQUEIO_CREDITO = 'B' 
OR CD_BLOQUEIO_REMESSA = 'B' 
OR CD_BLOQUEIO_REMESSA_ITEM = 'B' 
OR CD_BLOQUEIO_FATURAMENTO  = 'B'
OR CD_BLOQUEIO_FATURAMENTO_ITEM = 'B' 
)
AND DS_CREDIT_BLOCK_REASON IS NOT NULL;