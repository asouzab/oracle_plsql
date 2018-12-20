update vnd.elo_carteira 
set cd_status_customer_service = 12
where 
dh_liberacao_torre_fretes is not null 
and cd_status_torre_fretes is not null
and nvl(cd_status_customer_service, 11) in (10,11)
and nvl(qt_agendada_confirmada,0) > 0
and cd_status_cel_final = 59
and (cd_tipo_agendamento in (22, 23, 24) or (cd_tipo_agendamento = 25 and cd_status_replan = 32)); 

SELECT * FROM VND.ELO_CARTEIRA 
WHERE 
NU_ORDEM_VENDA IN (
'0002346448', '0002358128', '0002364352')
AND QT_AGENDADA_CONFIRMADA > 0 AND CD_STATUS_CEL_FINAL = 59 
AND DH_LIBERACAO_TORRE_FRETES IS NOT NULL; 
