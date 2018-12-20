select 
cc.*, 
--ic.*,
clicont.*, 
grpcli.*,
segcli.*,
coofilial.*,
coop.*,
a_coop.*,
prop_coop.*,
tpo.*,
1

from vnd.contrato cc
inner join vnd.item_contrato ic
on cc.cd_contrato = ic.cd_contrato
inner join vnd.cliente_contrato clicont
on clicont.cd_cliente_contrato = cc.cd_cliente_contrato
and clicont.cd_sales_org = cc.cd_sales_org
and clicont.cd_distribution_channel = cc.cd_distribution_channel
and clicont.cd_sales_division = cc.cd_sales_division


inner join CTF.GRUPO_CLIENTES grpcli 
on clicont.cd_grupo_clientes = grpcli.cd_grupo_clientes
inner join ctf.segmento_cliente segcli
on 
segcli.CD_SEGMENTO_CLIENTE = clicont.CD_SEGMENTO_CLIENTE
left join cpt.cooperativa_filial  coofilial
on coofilial.CD_CLIENTE = clicont.CD_CLIENTE
left join CPT.COOPERATIVA  coop
on coop.CD_COOPERATIVA = coofilial.CD_COOPERATIVA
left join cpt.cooperado a_coop
on a_coop.CD_COOPERATIVA = coop.CD_COOPERATIVA
left join cpt.propriedade_cooperado prop_coop
on prop_coop.CD_COOPERADO = a_coop.CD_COOPERADO

INNER JOIN vnd.tipo_ordem TPO
ON cc.CD_SALES_ORG = TPO.CD_SALES_ORG 
and cc.CD_DISTRIBUTION_CHANNEL = TPO.CD_DISTRIBUTION_CHANNEL 
and cc.CD_SALES_DIVISION = TPO.CD_SALES_DIVISION 
and cc.CD_TIPO_CONTRATO = TPO.CD_TIPO_ORDEM


where 1=1
AND cc.IC_ATIVO = 'S'  
and NVL(tpo.ic_cooperative, 'T') = 'S'
and nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) <> 0

AND cc.IC_SIGNED  = 'S' 
AND (cc.DT_FIM > TO_DATE(TO_CHAR(TRUNC(current_date, 'YEAR'), 'YYYY-MM-DD'), 'YYYY-MM-DD') -1 
     AND cc.DT_FIM < TO_DATE(TO_CHAR(TRUNC(current_date+4000, 'YEAR'), 'YYYY-MM-DD'), 'YYYY-MM-DD') )
and ( (cc.CD_SITUACAO_CONTRATO in (5,10,20) AND cc.CD_STATUS_CONTRATO in (8)) 
or (cc.CD_SITUACAO_CONTRATO = 25 AND cc.cd_status_contrato = 8 and cc.DT_FIM > current_date - 30 AND cc.DT_FIM < TRUNC(current_date+90, 'YEAR'))
)

--5	Comercial
--10	Crédito
--15	Cobrança
--20	Liberado
--25	Finalizado
--30	Recusado/Cancelado
--99	Verificar erro status
--35	Bloqueio de Material
--90	Contrato Excluido no SAP
--40	Incompleto


--and cc.nu_contrato_sap = '0040405500'
--and ic.cd_item_contrato = 10
--and ic.cd_produto_sap = '000000000000114862'
--and ic.cd_contrato = 230358
--and cc.nu_contrato = 3067325
--and cc.cd_cliente_contrato = 495283
--and cc.cd_sales_org = 'BR02'
--AND cc.CD_DISTRIBUTION_CHANNEL = 10
--AND cc.CD_SALES_DIVISION = 10
--AND cc.CD_TIPO_CONTRATO = 'ZCQN'
--and clicont.cd_cliente = '0004023276'
and (clicont.CD_CLIENTE is null or 
        coofilial.CD_COOPERATIVA is null or  
        coop.CD_COOPERATIVA is null or 
        a_coop.CD_COOPERATIVA is null 
        )
;

/*
SELECT DENTCC.* FROM
(

SELECT 
(SELECT SUM(nvl(icS.NU_QUANTIDADE,0) - nvl(icS.NU_QTY_DELIVERED,0)) 
    FROM VND.ITEM_CONTRATO ICS
    WHERE ICS.CD_CONTRATO = CC.CD_CONTRATO) TOTALLINE, 
CC.*
--, CCC.* 
FROM VND.CONTRATO CC
LEFT JOIN VND.VW_ELO_CONTRATO CCC
ON CC.CD_CONTRATO = CCC.CD_CONTRATO
WHERE 
CCC.CD_CONTRATO IS NULL
AND CC.DT_FIM > TO_DATE(TO_CHAR(TRUNC(current_date, 'YEAR'), 'YYYY-MM-DD'), 'YYYY-MM-DD') -90
AND CC.CD_STATUS_CONTRATO = 8
AND CC.IC_ATIVO = 'S'
) DENTCC
WHERE DENTCC.TOTALLINE > 0 
; 
*/