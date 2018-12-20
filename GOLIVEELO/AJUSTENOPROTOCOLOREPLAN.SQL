SELECT CD_ELO_AGENDAMENTO, CD_STATUS_TORRE_FRETES, CD_STATUS_CEL_FINAL, DH_LIBERACAO_TORRE_FRETES, QT_AGENDADA_CONFIRMADA , c.*, c.ds_versao FROM VND.ELO_CARTEIRA c
WHERE 
NU_ORDEM_VENDA = '0002350582'

select * from vnd.elo_vbak_protocolo 
where cd_elo_carteira = 27061

select nu_protocolo_entrega, dt_liberacao_entrega, dt_sugestao_entrega, qt_quantidade, qt_fornecido, sg_status, ds_observacao  from cpt.entrega  
where nu_protocolo_entrega in
('R121264HB1',
'R121294PY1',
'R121307VD1',
'R121264HB1',
'R121255CU1',
'R121168CV1',
'R121263AR1',
'R121244LU1'
)





select * from vnd.elo_agendamento_week 
where cd_elo_agendamento_item = 6376

select * from vnd.elo_agendamento_day 
where cd_elo_agendamento_week = 2664

select * from vnd.elo_carteira where ds_versao is not null

select * from all_source
where upper(text) LIKE '%SG_STATUS%'


select 'R' REPLAN, proto.cd_elo_vbak_protocolo,  ct.cd_elo_carteira, ct.qt_agendada_confirmada, '''' || ct.nu_contrato_sap || '''' nu_contrato_sap, 
'''' || ct.nu_ordem_venda || '''' , proto.nu_protocolo, ent.qt_quantidade, ent.qt_fornecido , 
ent.qt_quantidade -  ent.qt_fornecido, proto.QT_AGENDADA_PROTOCOLO
from vnd.elo_carteira ct
inner join vnd.elo_vbak_protocolo proto
on proto.cd_elo_carteira = ct.cd_elo_carteira 
inner join CPT.ENTREGA ent
on  proto.NU_PROTOCOLO = ENT.NU_PROTOCOLO_ENTREGA
where (ct.cd_tipo_replan is not null or ct.cd_tipo_agendamento = 25)
and proto.QT_AGENDADA_PROTOCOLO = 0
and ENT.SG_STATUS IN ('P')
and ct.qt_agendada_confirmada > 0 
--and ent.qt_quantidade = ct.qt_agendada_confirmada 
UNION 
select 'P' REPLAN, proto.cd_elo_vbak_protocolo,  ct.cd_elo_carteira, ct.qt_agendada_confirmada, '''' || ct.nu_contrato_sap || '''' NU_CONTRATO_SAP, 
'''' || ct.nu_ordem_venda || '''' , proto.nu_protocolo, ent.qt_quantidade, ent.qt_fornecido , 
ent.qt_quantidade -  ent.qt_fornecido,  proto.QT_AGENDADA_PROTOCOLO
from vnd.elo_carteira ct
inner join vnd.elo_vbak_protocolo proto
on proto.cd_elo_carteira = ct.cd_elo_carteira 
inner join CPT.ENTREGA ent
on  proto.NU_PROTOCOLO = ENT.NU_PROTOCOLO_ENTREGA
where 1=1 --(ct.cd_tipo_replan is not null or ct.cd_tipo_agendamento = 25)
--and proto.QT_AGENDADA_PROTOCOLO = 0
and ENT.SG_STATUS IN ('P')
and ct.qt_agendada_confirmada > 0 
AND proto.NU_PROTOCOLO IN (
--'R121246OJ1',
'R111039AV1',
'R121342CL1'
)
UNION 
select 'C' REPLAN, proto.cd_elo_vbak_protocolo,  ct.cd_elo_carteira, ct.qt_agendada_confirmada, '''' || ct.nu_contrato_sap || '''' NU_CONTRATO_SAP, 
'''' || ct.nu_ordem_venda || '''' , proto.nu_protocolo, ent.qt_quantidade, ent.qt_fornecido , 
ent.qt_quantidade -  ent.qt_fornecido,  proto.QT_AGENDADA_PROTOCOLO
from vnd.elo_carteira ct
inner join vnd.elo_vbak_protocolo proto
on proto.cd_elo_carteira = ct.cd_elo_carteira 
inner join CPT.ENTREGA ent
on  proto.NU_PROTOCOLO = ENT.NU_PROTOCOLO_ENTREGA
where 1=1 --(ct.cd_tipo_replan is not null or ct.cd_tipo_agendamento = 25)
--and proto.QT_AGENDADA_PROTOCOLO = 0
and ENT.SG_STATUS IN ('P')
and ct.qt_agendada_confirmada > 0 
AND ct.NU_CONTRATO_SAP IN (
'0040355298',
'0040386368',
'0040355298',
'0040386368'
)



order by nu_contrato_sap, CD_ELO_CARTEIRA, NU_PROTOCOLO 




select * from CPT.ENTREGA ENTR 

select * from vnd.elo_vbak_protocolo proto

UPDATE VND.ELO_VBAK_PROTOCOLO SET QT_AGENDADA_PROTOCOLO = 16 WHERE CD_ELO_VBAK_PROTOCOLO = 259 AND CD_ELO_CARTEIRA = 27535 AND QT_AGENDADA_PROTOCOLO = 0 ;
UPDATE VND.ELO_VBAK_PROTOCOLO SET QT_AGENDADA_PROTOCOLO = 6 WHERE CD_ELO_VBAK_PROTOCOLO = 22 AND CD_ELO_CARTEIRA = 1750 AND  QT_AGENDADA_PROTOCOLO = 0 ;



