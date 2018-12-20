
select ec.cd_tipo_agendamento, iis.IC_ADICAO, ec.cd_status_replan, ec.cd_status_cel_final, ec.qt_agendada_confirmada, cath.* 
from vnd.elo_carteira_hist cath
inner join vnd.elo_carteira ec
on 
ec.cd_elo_carteira = cath.cd_elo_carteira 
left join vnd.vw_elo_agendamento_item_adicao iis
on cath.cd_elo_agendamento_item = iis.cd_elo_agendamento_item

where 
case 
when ec.cd_tipo_agendamento in (22,23,24) then 22
when ec.CD_TIPO_AGENDAMENTO is null then 28
when ec.cd_tipo_agendamento = 25 then 25 end <> 
case 
when cath.cd_tipo_agendamento in (22, 23, 24) then 22
when cath.cd_tipo_agendamento is null then 22
when cath.CD_TIPO_AGENDAMENTO = 25 then 25 end;
