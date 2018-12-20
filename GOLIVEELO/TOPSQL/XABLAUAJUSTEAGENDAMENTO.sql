/*
DECLARE 


CURSOR C_CARTEIRA_ELO IS 
*/

WITH CTE_PROBLEM AS (
select DISTINCT 

ct.NU_CONTRATO_SAP, 
ct.CD_ITEM_CONTRATO, 
ct.NU_ORDEM_VENDA,
ct.CD_PRODUTO_SAP
 
from vnd.elo_carteira ct
inner join vnd.elo_agendamento age
on ct.cd_elo_agendamento = age.cd_elo_agendamento 
inner join vnd.elo_agendamento_supervisor sup
on age.cd_elo_agendamento = sup.cd_elo_agendamento 
inner join vnd.elo_agendamento_item item 
on sup.cd_elo_agendamento_supervisor = item.cd_elo_agendamento_supervisor
and item.cd_elo_agendamento_item = ct.cd_elo_agendamento_item

LEFT join vnd.elo_agendamento_week wees
on 
item.cd_elo_agendamento_item = wees.cd_elo_agendamento_item
and wees.qt_semana <> ct.qt_saldo

where 
age.cd_elo_status in (6, 7,8)
and nu_ordem_venda not in ('0', 'x', 'x')
and ct.cd_status_customer_service is not null
and ct.cd_status_cel_final is not null
and ((ct.cd_tipo_agendamento in (22,23,24))
OR ( ct.cd_tipo_agendamento = 25 and ct.cd_status_replan = 32)
)   
and (ct.qt_agendada_confirmada >= 0 or ct.qt_saldo <> ct.qt_agendada_confirmada)
 
and NVL((SELECT SUM(DDDAY.NU_QUANTIDADE) D
FROM VND.ELO_AGENDAMENTO_DAY DDDAY
WHERE DDDAY.CD_ELO_AGENDAMENTO_WEEK = wees.CD_ELO_AGENDAMENTO_WEEK),0) <> NVL(wees.qt_semana,0)
)


select 
AGE.CD_ELO_AGENDAMENTO,
ct.CD_ELO_CARTEIRA, 
wees.CD_ELO_AGENDAMENTO_WEEK,
ct.cd_tipo_agendamento,
ct.cd_elo_agendamento_item,
ct.NU_CONTRATO_SAP, 
ct.CD_ITEM_CONTRATO, 
ct.NU_ORDEM_VENDA, 
age.NU_CARTEIRA_VERSION, 
ct.CD_STATUS_CUSTOMER_SERVICE,
ct.CD_INCOTERMS,
ct.CD_STATUS_CEL_FINAL,
ct.cd_centro_expedidor, 
ct.ds_centro_expedidor,
ct.qt_agendada_confirmada,
ct.qt_saldo,

(select MAX(QT_SALDO) FROM VND.ELO_CARTEIRA_SAP SAP
WHERE SAP.NU_CONTRATO_SAP = CT.NU_CONTRATO_SAP
AND SAP.CD_ITEM_CONTRATO = CT.CD_ITEM_CONTRATO
AND SAP.CD_PRODUTO_SAP = CT.CD_PRODUTO_SAP
AND SAP.CD_INCOTERMS = CT.CD_INCOTERMS
AND SAP.NU_ORDEM_VENDA = CT.NU_ORDEM_VENDA) MAX_QT_SALDO_OV_SAP,

(select MIN(QT_SALDO) FROM VND.ELO_CARTEIRA_SAP SAP
WHERE SAP.NU_CONTRATO_SAP = CT.NU_CONTRATO_SAP
AND SAP.CD_ITEM_CONTRATO = CT.CD_ITEM_CONTRATO
AND SAP.CD_PRODUTO_SAP = CT.CD_PRODUTO_SAP
AND SAP.CD_INCOTERMS = CT.CD_INCOTERMS
AND SAP.NU_ORDEM_VENDA = CT.NU_ORDEM_VENDA) MIN_QT_SALDO_OV_SAP,

(select MAX(QT_SALDO) FROM VND.ELO_CARTEIRA_SAP SAP
WHERE SAP.NU_CONTRATO_SAP = CT.NU_CONTRATO_SAP
AND SAP.CD_ITEM_CONTRATO = CT.CD_ITEM_CONTRATO
AND SAP.CD_PRODUTO_SAP = CT.CD_PRODUTO_SAP
AND SAP.CD_INCOTERMS = CT.CD_INCOTERMS
AND SAP.CD_CLIENTE = CT.CD_CLIENTE
AND SAP.NU_CARTEIRA_VERSION = AGE.NU_CARTEIRA_VERSION
AND SAP.NU_ORDEM_VENDA = CT.NU_ORDEM_VENDA) QT_SALDO_OV_CVERSION_SAP,

wees.qt_semana,

NVL((SELECT SUM(DDDAY.NU_QUANTIDADE) FROM VND.ELO_AGENDAMENTO_DAY DDDAY
WHERE DDDAY.CD_ELO_AGENDAMENTO_WEEK = wees.CD_ELO_AGENDAMENTO_WEEK),0) TOTALDAY

 
from vnd.elo_carteira ct
inner join vnd.elo_agendamento age
on ct.cd_elo_agendamento = age.cd_elo_agendamento 
inner join vnd.elo_agendamento_supervisor sup
on age.cd_elo_agendamento = sup.cd_elo_agendamento 
inner join vnd.elo_agendamento_item item 
on sup.cd_elo_agendamento_supervisor = item.cd_elo_agendamento_supervisor
and item.cd_elo_agendamento_item = ct.cd_elo_agendamento_item

LEFT join vnd.elo_agendamento_week wees
on 
item.cd_elo_agendamento_item = wees.cd_elo_agendamento_item

where 
EXISTS (select 1 
from CTE_PROBLEM ov where ov.nu_ordem_venda = ct.nu_ordem_venda
and ov.cd_produto_sap = ct.cd_produto_sap)
or 
EXISTS (select 1 
from CTE_PROBLEM ov where ov.nu_contrato_sap = ct.nu_contrato_sap
and ov.cd_item_contrato = ct.cd_item_contrato
and ov.cd_produto_sap = ct.cd_produto_sap)
 

;

/*
TYPE carteira_sap_r IS RECORD
(
CD_ELO_CARTEIRA     VND.elo_carteira.CD_ELO_CARTEIRA%TYPE,
NU_CONTRATO_SAP         VND.elo_carteira.NU_CONTRATO_SAP%TYPE,
CD_ITEM_CONTRATO        VND.elo_carteira.CD_ITEM_CONTRATO%TYPE,
NU_ORDEM_VENDA          VND.elo_carteira.NU_ORDEM_VENDA%TYPE, 
NU_CARTEIRA_VERSION     VND.elo_carteira.NU_CARTEIRA_VERSION%TYPE,
cd_centro_expedidor     VND.elo_carteira.cd_centro_expedidor%TYPE,
ds_centro_expedidor     VND.elo_carteira.ds_centro_expedidor%TYPE


);


TYPE carteira_sap_t IS TABLE OF carteira_sap_r;
tableof_carteira_sap carteira_sap_t;

tableof_carteira_elo carteira_sap_t;

BEGIN


BEGIN 


    OPEN C_CARTEIRA_ELO;
    FETCH C_CARTEIRA_ELO BULK COLLECT INTO tableof_carteira_elo LIMIT 10000;
    CLOSE C_CARTEIRA_ELO;
        
    FORALL C_LINHA IN tableof_carteira_elo.first .. tableof_carteira_elo.last
    UPDATE VND.ELO_CARTEIRA SA
    SET SA.DS_CENTRO_EXPEDIDOR = tableof_carteira_elo(C_LINHA).DS_CENTRO_EXPEDIDOR
    WHERE 
    SA.DS_CENTRO_EXPEDIDOR <> tableof_carteira_elo(C_LINHA).DS_CENTRO_EXPEDIDOR 
    AND SA.CD_ELO_CARTEIRA =  tableof_carteira_elo(C_LINHA).CD_ELO_CARTEIRA;
    COMMIT;
        


END;

END;

/
select 
ct.CD_ELO_CARTEIRA, 
ct.NU_CONTRATO_SAP, 
ct.CD_ITEM_CONTRATO, 
ct.NU_ORDEM_VENDA, 
'' NU_CARTEIRA_VERSION, 
ct.cd_centro_expedidor, 
ct.ds_centro_expedidor, 
cc.DS_CENTRO_EXPEDIDOR CENTRO_FROM_BASE 
from vnd.elo_carteira ct
inner join ctf.centro_expedidor cc
on ct.cd_centro_expedidor = cc.cd_centro_expedidor
where ct.ds_centro_expedidor <> cc.ds_centro_expedidor;

*/