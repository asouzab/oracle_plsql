select distinct age.nu_carteira_version, age.cd_elo_agendamento, age.cd_week, age.cd_polo, age.cd_centro_expedidor , age.cd_elo_status, 
ec.nu_protocolo
, cc.DS_CENTRO_EXPEDIDOR 
,ec.ds_centro_expedidor, ec.cd_centro_expedidor, ec.cd_elo_carteira, ec.nu_contrato_sap, ec.nu_ordem_venda, ec.qt_agendada_confirmada , ec.cd_status_cel_final, ec.qt_saldo
, ec.DS_CREDIT_BLOCK_REASON
, ec.*
,(SELECT '1'
FROM VND.ELO_STATUS STB 
WHERE 
STB.CD_ELO_TIPO_STATUS = 10 
AND SUBSTR(EC.DS_CREDIT_BLOCK_REASON, 1,2) = SUBSTR(STB.DS_STATUS, 1,2) AND ROWNUM=1) 
 ,                                                   
1

from vnd.elo_agendamento age
inner join vnd.elo_carteira ec
on age.cd_elo_agendamento = ec.cd_elo_agendamento 
left join ctf.centro_expedidor cc 
on ec.cd_centro_expedidor = cc.cd_centro_expedidor
where 
ec.ic_ativo ='S' 
AND age.cd_week = 'W362018'
AND (ec.cd_centro_expedidor in ('60220') or age.cd_polo = 'P002')
AND nu_contrato_sap in ('0040397213' )
--and ec.nu_ordem_venda IN( '0002351235' ) 
--and ec.cd_elo_carteira = 293095
and nvl(ec.qt_agendada_confirmada,0) >= 0
--and ec.cd_sales_office = 5921
--and ec.nu_contrato = 3060713 
--and ec.qt_agendada > 0
--and ec.cd_incoterms = 'CIF'
--and ec.cd_sales_group = 709

--and ec.cd_grupo_embalagem = 'B'
--AND EC.NO_PRODUTO_SAP = 'MS09F 07 34 12 S9'
--AND ec.DS_CREDIT_BLOCK_REASON is not null 
--and ec.cd_bloqueio_credito not in ( 'B')
--AND NVL(EC.CD_STATUS_CEL_FINAL, 999) =  59
--AND IC_COOPERATIVE = 'S'
--AND AGE.CD_ELO_STATUS IN (40,50,6)
--and UPPER(ec.no_cliente) LIKE '%COOPERMOTA%'

AND (ec.cd_tipo_agendamento in (22,23,24) or (ec.cd_tipo_agendamento = 25 and ec.cd_status_replan = 32) or cd_tipo_agendamento is null )



;


--programado 185, semana 196

SELECT * FROM VND.ELO_AGENDAMENTO_WEEK WHERE CD_ELO_AGENDAMENTO_ITEM in( 133832);
SELECT * FROM VND.ELO_AGENDAMENTO_WEEK WHERE CD_ELO_AGENDAMENTO_WEEK in( 53762);
SELECT * FROM VND.ELO_AGENDAMENTO_DAY WHERE CD_ELO_AGENDAMENTO_WEEK in (53762);  -- 253

SELECT * FROM VND.ELO_AGENDAMENTO_ITEM WHERE CD_ELO_AGENDAMENTO_ITEM in(133832);  --cif

SELECT * FROM VND.ELO_AGENDAMENTO WHERE CD_ELO_AGENDAMENTO in( 408);


select * from vnd.elo_agendamento_supervisor where CD_ELO_AGENDAMENTO in( 367);
select * from vnd.elo_agendamento_supervisor where CD_ELO_AGENDAMENTO_supervisor in( 5596);
select * from vnd.elo_agendamento_grouping where nu_documento = 'R128385BD1' or CD_ELO_AGENDAMENTO_WEEK in (53762);

select * from vnd.elo_vbak_protocolo 
where 1=1
--cd_elo_carteira in (278211 )
and nu_protocolo in (
'R128385BD1' 

)
--and cd_elo_vbak_protocolo in (7010, 7011)

;


SELECT CAT.CD_ELO_CARTEIRA, SUM( PROT.QT_AGENDADA_PROTOCOLO) protocolo, MIN(CAT.QT_AGENDADA_CONFIRMADA) confirmada
--INTO V_TOTAL_PROTOCOLO, V_QT_AGENDADA_CONFIRMADA
FROM VND.ELO_VBAK_PROTOCOLO PROT
INNER JOIN VND.ELO_CARTEIRA CAT
ON PROT.CD_ELO_CARTEIRA = CAT.CD_ELO_CARTEIRA
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON CAT.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
WHERE 
--PROT.CD_ELO_CARTEIRA = 0002393210
AGE.CD_WEEK = 'W362018'
--AND AGE.CD_CENTRO_EXPEDIDOR = '6260'
AND AGE.CD_POLO = 'P002'

--AND cat.nu_ordem_venda = '0002393210'
AND CAT.NU_CONTRATO_SAP = '0040397213'


AND (CAT.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CAT.CD_TIPO_AGENDAMENTO = 25 AND CAT.CD_STATUS_REPLAN = 32)OR CAT.CD_TIPO_AGENDAMENTO IS NULL)
GROUP BY CAT.CD_ELO_CARTEIRA

;

SELECT * FROM VND.ELO_VBAK_PROTOCOLO
WHERE 289441 = CD_ELO_CARTEIRA;

SELECT * FROM VND.ELO_CARTEIRA
WHERE 289441 = CD_ELO_CARTEIRA;


SELECT GR.* , GG.NU_CONTRATO_SAP, GG.CD_ITEM_CONTRATO, GG.NU_ORDEM_VENDA, GG.CD_STATUS_CEL_FINAL, GG.CD_TIPO_AGENDAMENTO, GG.CD_STATUS_REPLAN

   FROM 
(

SELECT AGE.CD_WEEK, AGE.CD_ELO_STATUS, age.CD_ELO_AGENDAMENTO, age.CD_POLO, age.CD_CENTRO_EXPEDIDOR, CAT.CD_ELO_CARTEIRA,
SUM( PROT.QT_AGENDADA_PROTOCOLO) QT_PROTOCOLO, MIN(CAT.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA, 'K' STAT
--INTO V_TOTAL_PROTOCOLO, V_QT_AGENDADA_CONFIRMADA
FROM VND.ELO_VBAK_PROTOCOLO PROT
INNER JOIN VND.ELO_CARTEIRA CAT
ON PROT.CD_ELO_CARTEIRA = CAT.CD_ELO_CARTEIRA
INNER JOIN VND.ELO_agendamento age
on age.cd_elo_agendamento = cat.cd_elo_agendamento
WHERE 1=1
--PROT.CD_ELO_CARTEIRA = 293095
and age.cd_elo_status in (1,2,3,4,5,6,7)
and cat.ic_cooperative = 'S'
AND cat.qt_agendada_confirmada > 0
AND (CAT.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CAT.CD_TIPO_AGENDAMENTO = 25 AND CAT.CD_STATUS_REPLAN = 32))

GROUP BY CAT.CD_ELO_CARTEIRA,
AGE.CD_WEEK, AGE.CD_ELO_STATUS, age.CD_ELO_AGENDAMENTO, age.CD_POLO, age.CD_CENTRO_EXPEDIDOR

UNION 

SELECT AGE.CD_WEEK, AGE.CD_ELO_STATUS, age.CD_ELO_AGENDAMENTO, age.CD_POLO, age.CD_CENTRO_EXPEDIDOR, CAT.CD_ELO_CARTEIRA,
SUM( PROT.QT_AGENDADA_PROTOCOLO) QT_PROTOCOLO, MIN(CAT.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA, 'K' STAT
--INTO V_TOTAL_PROTOCOLO, V_QT_AGENDADA_CONFIRMADA
FROM VND.ELO_VBAK_PROTOCOLO PROT
INNER JOIN VND.ELO_CARTEIRA CAT
ON PROT.CD_ELO_CARTEIRA = CAT.CD_ELO_CARTEIRA
INNER JOIN VND.ELO_agendamento age
on age.cd_elo_agendamento = cat.cd_elo_agendamento
WHERE 1=1
--PROT.CD_ELO_CARTEIRA = 293095
and age.cd_elo_status in (1,2,3,4,5,6,7)
and cat.ic_cooperative = 'S'
AND NVL(cat.qt_agendada_confirmada,0) >= 0
AND (CAT.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CAT.CD_TIPO_AGENDAMENTO = 25 AND CAT.CD_STATUS_REPLAN = 32) OR cat.cd_tipo_agendamento is null)

GROUP BY CAT.CD_ELO_CARTEIRA,
AGE.CD_WEEK, AGE.CD_ELO_STATUS, age.CD_ELO_AGENDAMENTO, age.CD_POLO, age.CD_CENTRO_EXPEDIDOR


) GR
INNER JOIN VND.ELO_CARTEIRA GG
ON GG.CD_ELO_CARTEIRA = GR.CD_ELO_CARTEIRA


WHERE GR.QT_PROTOCOLO <> GR.QT_AGENDADA_CONFIRMADA
order by GR.CD_ELO_AGENDAMENTO, GR.CD_ELO_CARTEIRA
;






