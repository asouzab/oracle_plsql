select distinct
--ent.dt_sugestao_entrega,
entrega.cd_autorizacao_entrega, 
--entrega.*,
-- 'adriano' adriano,
--ent.*,
--ent.nu_protocolo_ENTREGA,
entrega.cd_produto_sap, 
--entrega.nu_ordem_venda,
 entrega.nu_contrato_sap, entrega.cd_item_contrato,
--entrega.cd_item_pedido,  
entrega.qt_quantidade qt_quantidade_reserva, 
ent.QT_quantidade quantidade_entrega, ent.qt_fornecido
,ent.sg_status--, 
--ent.ic_liberado_entrega--,
--ent.ds_log_sap

from cpt.autorizacao_entrega entrega
inner join 
(select som.CD_AUTORIZACAO_ENTREGA , max(som.dt_sugestao_entrega) dt_sugestao_entrega, 
sum(nvl(som.QT_quantidade,0)) qt_quantidade , sum(nvl(som.qt_fornecido,0)) qt_fornecido,
som.sg_status
from cpt.entrega som
where 
NVL(som.sg_status,'C') <> 'C'
AND som.nu_protocolo_entrega = 'R123927HQ1'
group by 
som.CD_AUTORIZACAO_ENTREGA ,
som.sg_status

) ent
on 
entrega.cd_autorizacao_entrega = ent.cd_autorizacao_entrega
where entrega.nu_contrato_sap is not null 
and entrega.dt_autorizacao > trunc(current_date, 'year')
and NVL(ent.sg_status,'C') <> 'C'
AND NVL(entrega.QT_QUANTIDADE,0) <> NVL(ent.QT_QUANTIDADE,0)
--and entrega.cd_autorizacao_entrega = 122637
;

select * from cpt.entrega
where 
nu_protocolo_entrega = 'R124234FI1'
and cd_autorizacao_entrega = 124234;

select * from cpt.autorizacao_entrega
where 
cd_autorizacao_entrega = 124234;

--update cpt.autorizacao_entrega set qt_quantidade = 300 where cd_autorizacao_entrega = 122088 and cd_produto_sap = '000000000000118569' and nu_contrato_sap = '0040389524' and cd_item_contrato = 20;




3062214 – divergência de 28 ton 25 00 18 UR Kmag
R128608DN1 – 28 ton

3056696 – divergência de 27 ton KCL 60
R123927HQ1 – 13 TON
R123934NO1 – 14 TON

3058113 – divergência 63 ton 09 43 00 s9
R124232MR1 – 63 TON

3058776 – divergência 26 ton MAP 11 52
R125898YC1 – 26 TON

3058833 – divergência de 107 ton KCL
R124234FI1 – 8 TON
R124234FI1 – 63 TON
R125871AQ1 – 28 TON
R126299NL1 – 8 TON

3058834 – divergência de 93 ton MAP 11 52
R125633NH1 – 20 TON
R126300BU1 – 73 TON
