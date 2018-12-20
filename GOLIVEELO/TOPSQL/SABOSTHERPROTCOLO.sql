
SELECT CAG.CD_ELO_AGENDAMENTO, CAG.CD_WEEK, CAG.CD_POLO, CAG.CD_CENTRO_EXPEDIDOR, CAG.CD_ELO_STATUS, AG_IT.CD_PRODUTO_SAP,
AG_WEEK.CD_ELO_AGENDAMENTO_WEEK, AG_WEEK.QT_SEMANA,
AG_GROUP.*,
--AG_IT.* 

(SELECT SUM(VBPROT.QT_AGENDADA_PROTOCOLO) VB
FROM VND.ELO_CARTEIRA CAT
INNER JOIN VND.ELO_VBAK_PROTOCOLO VBPROT
ON CAT.CD_ELO_CARTEIRA = VBPROT.CD_ELO_CARTEIRA

WHERE CAG.CD_ELO_AGENDAMENTO =
CAT.CD_ELO_AGENDAMENTO
AND CAT.IC_COOPERATIVE = 'S'
AND CAT.QT_AGENDADA_CONFIRMADA > 0
AND VBPROT.QT_AGENDADA_PROTOCOLO > 0 
AND (CAT.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CAT.CD_TIPO_AGENDAMENTO = 25 AND CAT.CD_STATUS_REPLAN = 32))
AND AG_IT.CD_ELO_AGENDAMENTO_ITEM = CAT.CD_ELO_AGENDAMENTO_ITEM
AND CAT.IC_ATIVO = 'S') QT_PROTOCOLO_CARTEIRA,
CPT_ENT.SG_STATUS,
CPT_ENT.NU_PROTOCOLO_ENTREGA,
CPT_ENT.QT_QUANTIDADE,
NVL(CPT_ENT.QT_QUANTIDADE,0) - NVL(CPT_ENT.QT_FORNECIDO,0) QT_SALDO_ENTREGA,
CPT_AUT.NU_CONTRATO_SAP ,
CPT_AUT.CD_ITEM_CONTRATO

,CATT.CD_ELO_CARTEIRA
,CATT.QT_AGENDADA_CONFIRMADA
,CATT.NU_ORDEM_VENDA
,CATT.CD_STATUS_CEL_FINAL
,VBPROTT.CD_ELO_VBAK_PROTOCOLO
,VBPROTT.NU_PROTOCOLO
,VBPROTT.QT_AGENDADA_PROTOCOLO



FROM VND.ELO_AGENDAMENTO CAG
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AG_SUP
ON CAG.CD_ELO_AGENDAMENTO = AG_SUP.CD_ELO_AGENDAMENTO
INNER JOIN VND.ELO_AGENDAMENTO_ITEM AG_IT
ON AG_SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = AG_IT.CD_ELO_AGENDAMENTO_SUPERVISOR
INNER JOIN ELO_AGENDAMENTO_WEEK AG_WEEK
ON AG_IT.CD_ELO_AGENDAMENTO_ITEM = AG_WEEK.CD_ELO_AGENDAMENTO_ITEM

LEFT JOIN VND.ELO_CARTEIRA CATT
ON AG_IT.CD_ELO_AGENDAMENTO_ITEM = CATT.CD_ELO_AGENDAMENTO_ITEM
AND CAG.CD_ELO_AGENDAMENTO = CATT.CD_ELO_AGENDAMENTO
AND CATT.IC_COOPERATIVE = 'S'
AND CATT.IC_ATIVO = 'S'
AND CATT.QT_AGENDADA_CONFIRMADA > 0
AND (CATT.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CATT.CD_TIPO_AGENDAMENTO = 25 AND CATT.CD_STATUS_REPLAN = 32))

LEFT JOIN VND.ELO_VBAK_PROTOCOLO VBPROTT
ON CATT.CD_ELO_CARTEIRA = VBPROTT.CD_ELO_CARTEIRA
AND VBPROTT.QT_AGENDADA_PROTOCOLO > 0 

LEFT JOIN VND.ELO_AGENDAMENTO_GROUPING AG_GRPNAOSEMPROPO
ON AG_GRPNAOSEMPROPO.NU_DOCUMENTO = VBPROTT.NU_PROTOCOLO

LEFT JOIN VND.ELO_AGENDAMENTO_GROUPING AG_GROUP
ON AG_GROUP.CD_ELO_AGENDAMENTO_WEEK = AG_WEEK.CD_ELO_AGENDAMENTO_WEEK   

LEFT JOIN CPT.ENTREGA CPT_ENT 
ON
CPT_ENT.SG_STATUS NOT IN ('P', 'C')
AND CPT_ENT.NU_PROTOCOLO_ENTREGA = AG_GROUP.NU_DOCUMENTO

LEFT JOIN CPT.AUTORIZACAO_ENTREGA CPT_AUT 
ON CPT_ENT.CD_AUTORIZACAO_ENTREGA = CPT_AUT.CD_AUTORIZACAO_ENTREGA 

WHERE     CAG.IC_ATIVO = 'S'
AND AG_SUP.IC_ATIVO = 'S'
AND AG_IT.IC_ATIVO = 'S'
AND AG_WEEK.QT_SEMANA > 0 
--AND CPT_ENT.SG_STATUS NOT IN ('P', 'C')
AND CAG.CD_ELO_STATUS IN (1,2,3,4,5,6,7,8)


AND (EXISTS
(SELECT 1
FROM VND.ELO_CARTEIRA CAT
INNER JOIN VND.ELO_VBAK_PROTOCOLO VBPROT
ON CAT.CD_ELO_CARTEIRA = VBPROT.CD_ELO_CARTEIRA
INNER JOIN VND.ELO_VBAK VBAK
ON VBAK.CD_ELO_VBAK = VBPROT.CD_ELO_VBAK
AND VBAK.NU_CONTRATO_SAP = CAT.NU_CONTRATO_SAP 
AND VBAK.CD_ITEM_CONTRATO = CAT.CD_ITEM_CONTRATO

WHERE    
CAG.CD_ELO_AGENDAMENTO = CAT.CD_ELO_AGENDAMENTO
AND VBAK.NU_CONTRATO_SAP = CPT_AUT.NU_CONTRATO_SAP 
AND VBAK.CD_ITEM_CONTRATO = CPT_AUT.CD_ITEM_CONTRATO
AND CAT.IC_COOPERATIVE = 'S'
AND CAT.QT_AGENDADA_CONFIRMADA > 0
AND VBPROT.QT_AGENDADA_PROTOCOLO > 0 
AND (CAT.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CAT.CD_TIPO_AGENDAMENTO = 25 AND CAT.CD_STATUS_REPLAN = 32))
AND AG_IT.CD_ELO_AGENDAMENTO_ITEM = CAT.CD_ELO_AGENDAMENTO_ITEM
AND CAT.IC_ATIVO = 'S') or  AG_GRPNAOSEMPROPO.NU_DOCUMENTO is null) ;


select * from vnd.elo_carteira
where qt_agendada_protocolo > 0;


select * from vnd.elo_agendamento_grouping 
where cd_elo_agendamento_week = 3820;

'R114103MZ1'

select * from vnd.elo_agendamento_week 
where cd_elo_agendamento_week = 3820;

select * from vnd.elo_agendamento_item
where cd_elo_agendamento_item = 7047;

select * from vnd.elo_carteira
where cd_elo_agendamento_item = 7047;

select cat.cd_elo_agendamento_item, 
--cat.cd_incoterms, 
count(1) 
 from 
 (

select g.cd_elo_agendamento_item, 
g.nu_contrato_sap, g.cd_item_contrato, 
--g.cd_cliente_pagador,
g.cd_incoterms 
--g.ic_cooperative
from vnd.elo_carteira g
where
--cd_elo_agendamento_item = 11424
g.qt_agendada_confirmada > 0 
and exists (select 1 from vnd.elo_agendamento_week wees
inner join vnd.elo_agendamento_grouping grs on wees.cd_elo_agendamento_week = grs.cd_elo_agendamento_week 
            where wees.cd_elo_agendamento_item = g.cd_elo_agendamento_item)
AND g.ic_cooperative = 'S'
and g.cd_status_cel_final = 59
and (g.cd_tipo_agendamento in (22,23,24) or (g.cd_tipo_agendamento = 25 and g.cd_status_replan = 32)) 
group by g.cd_elo_agendamento_item, 
g.nu_contrato_sap, g.cd_item_contrato,
--g.cd_cliente_pagador,
g.cd_incoterms
--g.ic_cooperative
) cat
group by cat.cd_elo_agendamento_item --, cat.cd_cliente_pagador --, cat.cd_incoterms
having count(1) > 1;


select * from vnd.elo_carteira where cd_elo_agendamento_item is null;


SELECT * FROM VND.ELO_CARTEIRA C
WHERE 
--CD_ELO_CARTEIRA = 311838
C.cd_elo_agendamento_item = 152722;

;

select * from vnd.elo_agendamento where cd_elo_agendamento = 429;


select * from vnd.elo_agendamento_week
where cd_elo_agendamento_item =  152722;


select * from vnd.elo_agendamento_grouping 
where cd_elo_agendamento_week = 66195;



select * from vnd.elo_carteira_sap 
where nu_ordem_venda = '0002346281';


select distinct cd_bloqueio_remessa,  cd_bloqueio_faturamento from vnd.elo_carteira_sap 
where 1=1 
and nu_carteira_version = '20180831213018'
and nu_ordem_venda = '0002346281';
and ( cd_bloqueio_remessa = '90' or cd_bloqueio_faturamento = '98');







