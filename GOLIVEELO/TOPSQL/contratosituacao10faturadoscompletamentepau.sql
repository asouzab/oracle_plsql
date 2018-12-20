--20181027213007
--20181027213048





WITH BLOQUEIO_CONFIRMADA AS 
(

select 
distinct 
cli_cont.no_cliente,
cont.nu_contrato_sap, 
ic.cd_item_contrato,
CD_BLOQUEIO_FATURAMENTO,
CD_BLOQUEIO_ENTREGA,
cd_bloqueio_credito,
cd_situacao_contrato,
DS_CREDIT_BLOCK_REASON 
 ,cont.dh_ult_interface
, cont.dt_fim 
from vnd.contrato cont
inner join vnd.item_contrato ic
on cont.cd_contrato = ic.cd_contrato 
inner join vnd.cliente_contrato cli_cont
on cont.CD_CLIENTE_CONTRATO = cli_cont.CD_CLIENTE_CONTRATO
where 
nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) > 0 
and cont.cd_status_contrato = 8
and cont.cd_situacao_contrato in (10)
--and cont.CD_BLOQUEIO_ENTREGA is null
--and cont.cd_bloqueio_credito is null
and cont.CD_BLOQUEIO_FATURAMENTO is null
and cont.DS_CREDIT_BLOCK_REASON is null
and cont.dt_fim > current_date - 3000
and cont.dh_ult_interface > current_date - 100

and exists (select 1 from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')
and ww.cd_bloqueio_credito = 'B'
and ww.DS_CREDIT_BLOCK_REASON is null or ww.ds_credit_block_reason = '  '
and ww.nu_ordem_venda is not null)
)

select 
distinct 
cli_cont.no_cliente,
cont.nu_contrato_sap, 
--ic.cd_item_contrato,
cont.CD_BLOQUEIO_FATURAMENTO,
cont.CD_BLOQUEIO_ENTREGA,
cont.cd_bloqueio_credito,
cont.cd_situacao_contrato,
cont.DS_CREDIT_BLOCK_REASON 
 ,cont.dh_ult_interface
, cont.dt_fim 

, (select max(ww.ds_credit_block_reason) 
from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')

) ds_credit

, (select max(ww.CD_BLOQUEIO_FATURAMENTO) 
from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')

) cd_b_faturamento

, (select max(ww.CD_BLOQUEIO_ENTREGA) 
from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')

) cd_b_entrega

, (select min(ww.cd_bloqueio_credito) 
from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')

) cd_b_credito

, (select max(ww.cd_bloqueio_remessa) 
from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')

) cd_b_remessa

, (select max(ww.cd_motivo_recusa)
from vnd.elo_carteira_sap ww
where ww.nu_contrato_sap = cont.NU_CONTRATO_SAP 
and ww.cd_item_contrato = ic.cd_item_contrato 
and ww.nu_carteira_version in( '20181110213006')

) cd_b_motivo_recusa

,nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) saldoitem


from vnd.contrato cont
inner join vnd.item_contrato ic
on cont.cd_contrato = ic.cd_contrato 
inner join vnd.cliente_contrato cli_cont
on cont.CD_CLIENTE_CONTRATO = cli_cont.CD_CLIENTE_CONTRATO

LEFT JOIN BLOQUEIO_CONFIRMADA CCBO
ON 
CCBO.NU_CONTRATO_SAP = cont.nu_contrato_sap
and CCBO.CD_ITEM_CONTRATO = ic.cd_item_contrato



where 
nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) > 0 
and cont.cd_status_contrato = 8
and cont.cd_situacao_contrato in (20)
--and cont.CD_BLOQUEIO_ENTREGA is null
--and cont.cd_bloqueio_credito is null
and cont.CD_BLOQUEIO_FATURAMENTO is null
--and cont.DS_CREDIT_BLOCK_REASON is null
and cont.dt_fim > current_date - 365
and cont.dh_ult_interface > current_date - 60
and ccbo.nu_contrato_sap is null;

;


select nu_carteira_version, count(1), trunc(dh_carteira, 'DDD') from vnd.elo_carteira_sap
where 1=1
and dh_carteira > current_date - 10
having count(1) > 5000
group by nu_carteira_version, trunc(dh_carteira, 'DDD')
ORDER BY trunc(dh_carteira, 'DDD');

 
and nu_carteira_version = '20181022213028'
and nu_contrato_sap = '0040103253'
order by cd_elo_carteira_sap desc;

select trunc(dh_carteira, 'DDD') , c.* from vnd.elo_carteira_sap c
where 1=1
--nu_carteira_version in ( '20181029213005')
 and nu_contrato_sap = '0040103253';


select * from vnd.contrato 
where cd_contrato = 224547 ;