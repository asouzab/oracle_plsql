select count(1), cd_elo_agendamento, 
case when nvl(cd_tipo_agendamento, 22) in (22,23,24) then 22 else cd_tipo_agendamento end cd_tipo_agendamento, 
CD_PRODUTO_SAP, nu_contrato_sap, CD_ITEM_CONTRATO, nu_ordem_venda, 
sum(qt_programada) qt_programada, sum(qt_entregue) qt_entregue, sum(qt_saldo) qt_saldo, sum(qt_agendada) qt_agendada, sum(qt_agendada_confirmada) qt_agendada_confirmada
 from vnd.elo_carteira where cd_elo_agendamento_item in 
(

select item.cd_elo_agendamento_item from vnd.elo_agendamento age
inner join vnd.elo_agendamento_supervisor sup
on age.cd_elo_agendamento = sup.cd_elo_agendamento
inner join vnd.elo_agendamento_item item
on sup.cd_elo_agendamento_supervisor = item.cd_elo_agendamento_supervisor
inner join vnd.elo_agendamento_week wee
on 
item.cd_elo_agendamento_item = wee.cd_elo_agendamento_item 
inner join vnd.elo_agendamento_day da
on 
wee.cd_elo_agendamento_week = da.cd_elo_agendamento_week
where 
1=1
and (age.DT_WEEK_START > sysdate - 300) 
and age.ic_ativo ='S'
AND item.ic_ativo = 'S'
and (nvl(cd_tipo_agendamento, 22) in (22,23,24) or  (cd_tipo_agendamento = 25 and cd_status_replan = 32))


)

group by cd_elo_agendamento, 
case when nvl(cd_tipo_agendamento, 22) in (22,23,24) then 22 else cd_tipo_agendamento end , CD_PRODUTO_SAP, nu_contrato_sap, CD_ITEM_CONTRATO, nu_ordem_venda--, qt_programada, qt_entregue, qt_saldo, qt_agendada, qt_agendada_confirmada

having count(1) > 1

;

SELECT * FROM VND.ELO_AGENDAMENTO WHERE CD_ELO_AGENDAMENTO = 170; 

SELECT * FROM VND.ELO_CARTEIRA_SAp
WHERE 1=1 
--AND CD_ELO_AGENDAMENTO = 170
AND  NU_CARTEIRA_VERSION = '20180602233000'
AND CD_PRODUTO_SAP = '000000000000105606' AND NU_CONTRATO_SAP = '0040384453' AND CD_ITEM_CONTRATO = 10 AND  NU_ORDEM_VENDA = '0002341307' ;
170	22		0040384453	10	0002341307



SELECT * FROM ALL_SOURCE 
WHERE TEXT LIKE '%9999%';

