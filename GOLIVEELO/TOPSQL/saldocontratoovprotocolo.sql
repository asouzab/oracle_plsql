with cte_vbak as 
(

SELECT  
proto.nu_protocolo, proto.cd_elo_carteira, proto.CD_ELO_VBAK , proto.CD_ELO_VBAK_PROTOCOLO , proto.QT_AGENDADA_PROTOCOLO, 
VVV.NU_CONTRATO_SAP, VVV.CD_ITEM_CONTRATO, VVV.NU_CONTRATO 
FROM VND.ELO_VBAK_PROTOCOLO proto
INNER JOIN VND.ELO_VBAK VVV
ON VVV.CD_ELO_VBAK = proto.CD_ELO_VBAK 

WHERE 
--CD_ELO_CARTEIRA in (
--120699
--);

  proto.CD_ELO_VBAK in (99992011, 999915594)
  
  or (VVV.NU_CONTRATO_SAP =  'zx0040388011' AND VVV.CD_ITEM_CONTRATO >=1)


-- cd_elo_vbak_protocolo in (
--3339,
--3340,
--3347,
--3348,
--3621,
--3715
--)
--and

 or proto.NU_PROTOCOLO in(
'xR125919KI1',
'xR125914RY1',
'xR125920GB1'
)

or exists (select 1 from vnd.elo_carteira cate 
            inner join vnd.elo_agendamento aged on cate.cd_elo_agendamento = aged.cd_elo_agendamento 
        where cate.nu_contrato_sap = vvv.nu_contrato_sap 
        and cate.cd_item_contrato = vvv.cd_item_contrato
        and cate.ic_cooperative = 'S'
        and aged.cd_week = 'W292018' AND aged.CD_POLO = 'P002'
        and cate.cd_status_cel_final = 59
        AND cate.qt_agendada_confirmada >0
        --and cate.nu_ordem_venda in ('0002315845')
        )

), 

CTE_CONTRATO AS  (
select 
cont.nu_contrato_sap, cont.CD_STATUS_CONTRATO, icon.CD_ITEM_CONTRATO, icon.nu_quantidade, icon.nu_qty_delivered , cont.DH_ULT_INTERFACE
from vnd.contrato cont
inner join vnd.item_contrato icon on cont.CD_CONTRATO = icon.CD_CONTRATO  
where EXISTS (SELECT 1 FROM cte_vbak c
where 
cont.nu_contrato = c.nu_contrato and icon.cd_item_contrato = c.cd_item_contrato
) 
)


SELECT ent.nu_protocolo_entrega, ent.qt_quantidade, ent.qt_fornecido, ent.sg_status
, cart.*




FROM CPT.ENTREGA ent
LEFT JOIN (
select ag.cd_elo_agendamento, ag.cd_elo_status cd_elo_status_agend, ag.cd_week, ag.CD_POLO, ag.CD_CENTRO_EXPEDIDOR CENTRO 
,c.ds_centro_expedidor, c.cd_centro_expedidor, c.cd_elo_carteira, c.cd_tipo_agendamento, c.cd_status_replan,
c.nu_contrato_sap, c.cd_item_contrato, c.cd_produto_sap, c.no_produto_sap, c.nu_ordem_venda, 
c.qt_agendada_confirmada , c.cd_status_cel_final, c.qt_saldo, c.qt_agendada
, c.DS_CREDIT_BLOCK_REASON
, port.NU_PROTOCOLO , port.QT_AGENDADA_PROTOCOLO 
, vbak.NU_CONTRATO_SAP  nu_contrato_vbak, vbak.CD_ITEM_CONTRATO cd_item_contrato_vbak 
, port.CD_ELO_VBAK , port.CD_ELO_VBAK_PROTOCOLO
, (select sum(nvl(cont.nu_quantidade,0) - nvl(cont.nu_qty_delivered,0)) from CTE_CONTRATO cont
where cont.nu_contrato_sap = c.nu_contrato_sap and cont.cd_item_contrato = c.cd_item_contrato
) saldo_contrato
, (select sum(nvl(cont.nu_quantidade,0)) from CTE_CONTRATO cont
where cont.nu_contrato_sap = c.nu_contrato_sap and cont.cd_item_contrato = c.cd_item_contrato
) valor_contrato

, (select max(nvl(cont.nu_quantidade_saldo,0)) from vnd.pedido cont
where cont.nu_ordem_venda = c.nu_ordem_venda and cont.cd_item_contrato = c.cd_item_contrato
and nvl(cont.nu_ordem_venda, '0') 
not IN ('          ', '0', '0         ' )

) qt_aberto_pedido

, xcont.DH_ULT_INTERFACE

, (select max((cont.dh_ult_interface)) from vnd.pedido cont
where cont.nu_ordem_venda = c.nu_ordem_venda and cont.cd_item_contrato = c.cd_item_contrato
and nvl(cont.nu_ordem_venda, '0') 
not IN ('          ', '0', '0         ' )

) dh_ult_interface_pedido

from vnd.elo_carteira c
inner join vnd.elo_agendamento ag
on c.cd_elo_agendamento = ag.cd_elo_agendamento 
inner join vnd.elo_vbak_protocolo port
on port.cd_elo_carteira = c.cd_elo_carteira
inner join vnd.elo_vbak vbak
on 
port.cd_elo_vbak = vbak.cd_elo_vbak
LEFT JOIN CTE_CONTRATO xcont
on c.nu_contrato_sap = xcont.nu_contrato_sap 
and c.cd_item_contrato = xcont.cd_item_contrato

where 
c.ic_cooperative = 'S'
AND
(c.cd_tipo_agendamento in (22,23,24) or (c.cd_tipo_agendamento = 25 and c.cd_status_replan = 32)
or exists (select 1 from vnd.vw_elo_agendamento_item_adicao iis 
            where iis.CD_ELO_AGENDAMENTO_ITEM = c.CD_ELO_AGENDAMENTO_ITEM
            and c.cd_tipo_agendamento is null)
)
) cart
on cart.nu_protocolo = ent.NU_PROTOCOLO_ENTREGA  

WHERE  ent.NU_PROTOCOLO_ENTREGA IN( 
SELECT  
proto.nu_protocolo 
FROM cte_vbak proto
);