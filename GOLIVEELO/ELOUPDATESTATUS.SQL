select * from vnd.elo_agendamento 
where cd_week = 'W182018' 
and cd_polo in( 'P003', 'P004')

select * from vnd.elo_agendamento 
where 
cd_elo_agendamento in (45, 24)
cd_week = 'W192018' 
and cd_polo in( 'P013')
AND CD_CENTRO_EXPEDIDOR = '6240'

SELECT * FROM CTF.POLO
select * from ctf.polo_centro_expedidor where cd_polo = 'P003'


select * from elo_status

update vnd.elo_agendamento 
set cd_elo_status = 2
where cd_elo_agendamento = 25;


update vnd.elo_agendamento 
set cd_elo_status = 8
where cd_elo_agendamento = 9;

update vnd.elo_agendamento 
set cd_elo_status = 8
where cd_elo_agendamento = 5;


select * from all_objects 
where (status = 'VALID')
AND OBJECT_TYPE = 'PACKAGE BODY'
AND OWNER = 'VND'
AND OBJECT_NAME LIKE '%ELO%'

SELECT * FROM VND.ELO_STATUS

select * from vnd.elo_agendamento  where cd_elo_agendamento = 33
where cd_week = 'W12018' AND CD_CENTRO_EXPEDIDOR = '7000'

SELECT 
CD_ELO_CARTEIRA,  CD_CENTRO_EXPEDIDOR, 
NU_CONTRATO_SAP, NU_ORDEM_VENDA, CD_TIPO_AGENDAMENTO, CD_TIPO_REPLAN, CD_STATUS_REPLAN,
CD_STATUS_CEL_FINAL, QT_AGENDADA_CONFIRMADA, QT_PROGRAMADA, QT_SALDO, NU_ORDEM
NO_CLIENTE, NU_PROTOCOLO , CD_STATUS_CUSTOMER_SERVICE, CD_STATUS_TORRE_FRETES,  QT_AGENDADA, 
DH_LIBERACAO_TORRE_FRETES, CD_INCOTERMS,
DS_VERSAO

--SELECT * 
FROM VND.ELO_CARTEIRA 
WHERE CD_ELO_AGENDAMENTO = 66
and cd_tipo_agendamento is not null -- = 25
AND CD_SALES_GROUP = '740'
and cd_status_replan = 32
and qt_agendada_confirmada > 0
--AND CD_CLIENTE = '0004017712'
and cd_sales_group = '758'
AND NU_CONTRATO_SAP = '0040383859'
AND NVL(CD_STATUS_CEL_FINAL , 9999) <> 59
AND QT_AGENDADA_CONFIRMADA > 0

STATUS 8 
Aceito pela Controladoria	8	AGCTR

SELECT * FROM VND.PEDIDO WHERE  NU_ORDEM_VENDA IN( '0002' , '0002346819')

2348502
2348503



       SELECT
              EC.NU_CONTRATO
            , EC.NU_ORDEM_VENDA
            , EC.CD_ITEM_PEDIDO
            , (NVL(PED.NU_QUANTIDADE_SALDO, 0)) NU_QUANTIDADE_SALDO
            , NVL(EC.QT_AGENDADA_CONFIRMADA, 0) "QT_AGENDADA_CONFIRMADA"
            , NVL(EC.QT_AGENDADA_CELULA, 0) "QT_AGENDADA_CELULA"
            , (DS_OBSERVACAO_ADVEN) DS_OBSERVACAO_ADVEN
            , EC.NU_CONTRATO_SAP
            , EC.CD_ELO_AGENDAMENTO
            , (EC.CD_ELO_CARTEIRA) CD_ELO_CARTEIRA
            , ec.*
        FROM VND.ELO_CARTEIRA EC 
        LEFT JOIN VND.PEDIDO PED ON PED.NU_ORDEM_VENDA = EC.NU_ORDEM_VENDA --AND PED.CD_ITEM_PEDIDO = EC.CD_ITEM_PEDIDO  -- INCLUDED BY ADRIANO BAVIERA 2018-01-12 ISSUE BY RONIE
        INNER JOIN VND.ELO_AGENDAMENTO EA ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
        WHERE EC.IC_ATIVO <> 'N'
        AND EC.NU_ORDEM_VENDA IN( '0002330344' , 'k0')
        
        SELECT * FROM VND.ELO_CARTEIRA_SAP 
        WHERE 1=1
        and NU_CARTEIRA_VERSION = '20180412063241'
        AND NU_ORDEM_VENDA IN( '0002346819' , '0002346819')
        select * from vnd.elo_agendamento
        
        
--delete from elo_carteira 
--where cd_elo_carteira = 21677

select cd_elo_agendamento,  cd_elo_agendamento_item, nu_ordem_venda, cd_item_pedido,count(1) from vnd.elo_carteira
where nu_ordem_venda is not null and qt_agendada_confirmada > 0 AND CD_INCOTERMS = 'CIF'
group by 
cd_elo_agendamento, cd_elo_agendamento_item, nu_ordem_venda, cd_item_pedido
having count(1) > 1


select * from vnd.elo_VBAK_PROTOCOLO
WHERE CD_ELO_CARTEIRA = 22290

select * from vnd.elo_carteira
WHERE CD_ELO_CARTEIRA = 22290

refresh foi dia 19.04

select * from vnd.pedido
where nu_ordem_venda = '0002348498'


SELECT * FROM VND.ELO_AGENDAMENTO_WEEK 
WHERE CD_ELO_AGENDAMENTO_ITEM = 9484  -- 126

SELECT * FROM VND.ELO_AGENDAMENTO_DAY
WHERE CD_ELO_AGENDAMENTO_WEEK = 3563

SELECT * FROM VND.ELO_AGENDAMENTO_ITEM 
WHERE CD_ELO_AGENDAMENTO_ITEM = 5368

SELECT * FROM VND.ELO_CARTEIRA
WHERE CD_ELO_AGENDAMENTO_ITEM = 5368



WITH CTE_PAVOR AS 
(
SELECT 
ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR, ITEM.CD_CLIENTE, ITEM.CD_PRODUTO_SAP, ITEM.CD_INCOTERMS,
WEEK.CD_ELO_AGENDAMENTO_WEEK, ROUND(WEEK.QT_SEMANA,0) QT_SEMANA, --WEEK.CD_ELO_AGENDAMENTO_ITEM ,
ITEM.CD_ELO_AGENDAMENTO_ITEM, DAYSF.NU_DIA_SEMANA, DAYSF.CD_GRUPO_EMBALAGEM, DAYSF.NU_QUANTIDADE 
, (SELECT ROUND(SUM(DS.NU_QUANTIDADE),0) FROM VND.ELO_AGENDAMENTO_DAY DS
WHERE DS.CD_ELO_AGENDAMENTO_WEEK = WEEK.CD_ELO_AGENDAMENTO_WEEK) SOMADAY

FROM VND.ELO_AGENDAMENTO_ITEM ITEM 
INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEEK
ON 
ITEM.CD_ELO_AGENDAMENTO_ITEM = WEEK.CD_ELO_AGENDAMENTO_ITEM
LEFT JOIN VND.ELO_AGENDAMENTO_DAY DAYSF
ON 
WEEK.CD_ELO_AGENDAMENTO_WEEK = DAYSF.CD_ELO_AGENDAMENTO_WEEK
), 

CTE_LAKE AS (
SELECT * FROM (

SELECT VONBRAU.*, 0 TOTAL_SEMANA, '0000' NU_CONTRATO_SAP, '0000' NU_ORDEM_VENDA, CURRENT_DATE INTER_CONTRATO, CURRENT_DATE INTER_OV 
FROM CTE_PAVOR VONBRAU
WHERE VONBRAU.QT_SEMANA > VONBRAU.SOMADAY
UNION 
SELECT VONBRAU.*, 0 TOTAL_SEMANA,  '0000' NU_CONTRATO_SAP, '0000' NU_ORDEM_VENDA, CURRENT_DATE INTER_CONTRATO, CURRENT_DATE INTER_OV
FROM CTE_PAVOR VONBRAU
WHERE VONBRAU.QT_SEMANA < VONBRAU.SOMADAY
UNION 
SELECT 10000 SUP, FOB.CD_CLIENTE_RECEBEDOR, FOB.CD_PRODUTO_SAP, FOB.CD_INCOTERMS, 1 WEEK, FOB.QT_AGENDADA_CONFIRMADA, 
FOB.CD_ELO_AGENDAMENTO_ITEM, 9 NU_DIA_SEMANA, FOB.CD_GRUPO_EMBALAGEM, FOB.QT_AGENDADA_CONFIRMADA, 
(SELECT SUM(TGT.QT_AGENDADA_CONFIRMADA) FROM VND.ELO_CARTEIRA TGT WHERE TGT.CD_ELO_AGENDAMENTO_ITEM = FOB.CD_ELO_AGENDAMENTO_ITEM) DOM,
(SELECT SUM(TGT.QT_SEMANA) / COUNT(1) FROM CTE_PAVOR TGT WHERE TGT.CD_ELO_AGENDAMENTO_ITEM = FOB.CD_ELO_AGENDAMENTO_ITEM) TOTAL_SEMANA 
, FOB.NU_CONTRATO_SAP, FOB.NU_ORDEM_VENDA  
, CURRENT_DATE  INTER_CONTRATO, 
CURRENT_DATE INTER_OV 


FROM VND.ELO_CARTEIRA FOB
WHERE EXISTS (SELECT 1 FROM CTE_PAVOR PP WHERE PP.CD_ELO_AGENDAMENTO_ITEM = FOB.CD_ELO_AGENDAMENTO_ITEM)
AND FOB.CD_INCOTERMS = 'FOB'
UNION 
SELECT 20000 SUP, CIF.CD_CLIENTE, CIF.CD_PRODUTO_SAP, CIF.CD_INCOTERMS, 1 WEEK, CIF.QT_AGENDADA_CONFIRMADA, 
CIF.CD_ELO_AGENDAMENTO_ITEM, 9 NU_DIA_SEMANA, CIF.CD_GRUPO_EMBALAGEM, CIF.QT_AGENDADA_CONFIRMADA, 
(SELECT SUM(TGT.QT_AGENDADA_CONFIRMADA) FROM VND.ELO_CARTEIRA TGT WHERE TGT.CD_ELO_AGENDAMENTO_ITEM = CIF.CD_ELO_AGENDAMENTO_ITEM) DOM, 
(SELECT SUM(TGT.QT_SEMANA) / COUNT(1) FROM CTE_PAVOR TGT WHERE TGT.CD_ELO_AGENDAMENTO_ITEM = CIF.CD_ELO_AGENDAMENTO_ITEM) TOTAL_SEMANA 
, CIF.NU_CONTRATO_SAP, CIF.NU_ORDEM_VENDA 
, CURRENT_DATE INTER_CONTRATO, 
CURRENT_DATE INTER_OV 

FROM VND.ELO_CARTEIRA CIF
WHERE EXISTS (SELECT 1 FROM CTE_PAVOR PP WHERE PP.CD_ELO_AGENDAMENTO_ITEM = CIF.CD_ELO_AGENDAMENTO_ITEM)
AND CIF.CD_INCOTERMS = 'CIF'
) 
)

SELECT 
STAGE.DS_STATUS,
AGED.CD_ELO_AGENDAMENTO, AGED.CD_WEEK, AGED.DT_WEEK_START, AGED.CD_POLO, AGED.CD_CENTRO_EXPEDIDOR,
LAKE.*

, (SELECT MAX(CC.DH_ULT_INTERFACE )
FROM VND.CONTRATO CC 
WHERE CC.NU_CONTRATO_SAP = LAKE.NU_CONTRATO_SAP 
)  INTER_CONTRATO, 

(SELECT MAX(CC.DH_ULT_INTERFACE) 
FROM VND.PEDIDO CC
WHERE (CC.NU_ORDEM_VENDA = LAKE.NU_ORDEM_VENDA
/*OR CC.NU_CONTRATO_SAP = CIF.NU_CONTRATO_SAP*/)) INTER_OV 
, PROTO.NU_PROTOCOLO

 FROM CTE_LAKE  LAKE
 INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEMS 
 ON 
 ITEMS.CD_ELO_AGENDAMENTO_ITEM = LAKE.CD_ELO_AGENDAMENTO_ITEM 
 INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
 ON
 SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEMS.CD_ELO_AGENDAMENTO_SUPERVISOR 
 INNER JOIN VND.ELO_AGENDAMENTO AGED
 ON 
 AGED.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO 
 INNER JOIN VND.ELO_STATUS STAGE
 ON STAGE.CD_ELO_STATUS = AGED.CD_ELO_STATUS
 LEFT JOIN VND.ELO_CARTEIRA CART
 ON CART.CD_ELO_AGENDAMENTO = AGED.CD_ELO_AGENDAMENTO 
 AND CART.CD_ELO_AGENDAMENTO_ITEM = ITEMS.CD_ELO_AGENDAMENTO_ITEM 
 AND CART.QT_AGENDADA_CONFIRMADA  > 0 
 LEFT JOIN VND.ELO_VBAK_PROTOCOLO PROTO
 ON CART.CD_ELO_CARTEIRA = PROTO.CD_ELO_CARTEIRA
  


ORDER BY LAKE.CD_INCOTERMS ASC,  LAKE.CD_CLIENTE ASC,  LAKE.CD_PRODUTO_SAP,  LAKE.NU_DIA_SEMANA,  LAKE.CD_ELO_AGENDAMENTO_ITEM


select * from vnd.elo_carteira

select SUBSTR( '[{"ID": 0001, "APP": "GX_ELO_SCHEDULING.pi_agendamento_week_qty", "PROPERTIE": [{"NAME": "QT_AGENDADA_CONFIRMADA", "VAL": NULL}], "DH_ULT_MOD": ' || TO_CHAR(CURRENT_DATE) || ' }]' ,1, 4000) DS
from dual
            94354-9180
            
            



        
UPDATE VND.ELO_CARTEIRA
SET QT_AGENDADA_CONFIRMADA = 120
WHERE CD_ELO_CARTEIRA 
IN 
(32193)

select * from vnd.elo_carteira 
WHERE 
cd_elo_agendamento_item = 9501
CD_ELO_CARTEIRA 


IN 
(32193) or cd_elo_agendamento_item = 9484

select * from vnd.elo_agendamento_week 
where --CD_ELO_AGENDAMENTO_WEEK = 3035
cd_elo_agendamento_item = 9840

select * from vnd.elo_agendamento_grouping 
where 
--nu_documento = 'R121312ZI1'

cd_elo_agendamento_week = 3675

select sum(nu_quantidade) from vnd.elo_agendamento_day 
where 3675 = cd_elo_agendamento_week

select c.cd_elo_agendamento, c.cd_elo_agendamento_item, c.cd_elo_carteira,
c.cd_cliente, c.no_cliente, c.*
from vnd.elo_carteira c 
where c.cd_elo_carteira = 33366

select * from vnd.elo_vbak_protocolo 
where cd_elo_carteira = 33366
and cd_elo_vbak_protocolo = 325 








