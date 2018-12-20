select 

CASE WHEN nu_contrato IS NOT NULL THEN 'S' ELSE 'N' END TEM_PO,
CASE WHEN nu_contrato_SAP IS NOT NULL THEN 'S' ELSE 'N' END TEM_CONTRATO_SAP,

cont.nu_contrato_sap, 
cont.nu_contrato,
cont.cd_contrato,


--max(trunc(greatest(cont.dh_inclusao, cont.dh_geracao, cont.dh_assinatura, cont.dh_envio_adven, dh_ult_interface),'YEAR')) ultima_modificacao,
cont.cd_sales_org,
cont.cd_status_contrato,
stc.ds_status_contrato,
cont.cd_situacao_contrato,
sc.ds_situacao_contrato,
cont.ic_ativo,

CASE WHEN DS_PDF IS NOT NULL THEN 'S' ELSE 'N' END TEM_PDF,
trunc(NVL(cont.dt_fim, cont.dt_inicio), 'YEAR') FIM_CONTRATO,
trunc(cont.dt_inicio,'YEAR') INICIO_CONTRATO,
--count(1) QUANTIDADE 
cont.*,
ic.cd_item_contrato,
ic.cd_produto_sap,
tos.cd_tipo_ordem,
tos.ds_tipo_ordem,
tos.sg_category,
tos.ic_cooperative ,
tos.ic_split,
tos.IC_EXPORT,
tos.ic_fa,
tos.cd_distribution_channel, 
clicont.*,
grpcli.*,
segcli.*


from vnd.contrato cont

inner join vnd.item_contrato ic
on cont.cd_contrato = ic.cd_contrato
left join vnd.situacao_contrato sc on sc.cd_situacao_contrato = cont.cd_situacao_contrato  
left join vnd.status_contrato stc on stc.cd_status_contrato = cont.cd_status_contrato
left join vnd.tipo_ordem tos 
on 
tos.cd_tipo_ordem = cont.cd_tipo_contrato
and tos.cd_sales_org = cont.cd_sales_org 
and tos.cd_distribution_channel = cont.cd_distribution_channel 
and tos.cd_sales_division = cont.cd_sales_division

inner join vnd.cliente_contrato clicont
on clicont.cd_cliente_contrato = cont.cd_cliente_contrato
and clicont.cd_sales_org = cont.cd_sales_org
and clicont.cd_distribution_channel = cont.cd_distribution_channel
and clicont.cd_sales_division = cont.cd_sales_division
inner join CTF.GRUPO_CLIENTES grpcli 
on clicont.cd_grupo_clientes = grpcli.cd_grupo_clientes
inner join ctf.segmento_cliente segcli
on 
segcli.CD_SEGMENTO_CLIENTE = clicont.CD_SEGMENTO_CLIENTE



WHERE 1=1
and (cont.nu_contrato_sap = '0040398072' or cont.cd_tipo_contrato in ('ZCDB', 'ZCDN') or tos.ic_cooperative = 'S' OR tos.ic_split = 'S' or segcli.cd_segmento_cliente in (2  ) ) 
and cont.nu_contrato IS NOT NULL
and cont.nu_contrato_SAP IS NOT NULL
and cont.DS_PDF IS NOT NULL 
and cont.ic_ativo = 'S'
and cont.cd_status_contrato in (8)
and cont.dt_fim > trunc(current_date-365, 'YEAR') AND cont.dt_fim < trunc(current_date+365, 'YEAR') 
and cont.cd_incoterms = 'CIF'
--and nvl(ic.nu_quantidade,0) - nvl(ic.nu_qty_delivered,0) > 1
and ic.ic_recusado = 'N'
--and (cont.ds_credit_block_reason is null or substr(cont.ds_credit_block_reason, 1,2) < '  ')  


/*
group by 
trunc(nvl(cont.dt_fim, cont.dt_inicio), 'YEAR'),
trunc(cont.dt_inicio,'YEAR'), 
cont.cd_status_contrato, cont.ic_ativo, 
cont.cd_sales_org,
cont.cd_situacao_contrato,
sc.ds_situacao_contrato,
stc.ds_status_contrato,
CASE WHEN DS_PDF IS NOT NULL THEN 'S' ELSE 'N' END ,
CASE WHEN nu_contrato IS NOT NULL THEN 'S' ELSE 'N' END, -- TEM_PO,
CASE WHEN nu_contrato_SAP IS NOT NULL THEN 'S' ELSE 'N' END -- TEM_CONTRATO_SAP,
*/
;


select * from vnd.tipo_ordem; 