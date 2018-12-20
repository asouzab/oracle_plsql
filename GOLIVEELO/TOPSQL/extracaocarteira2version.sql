--20181028213005
--20181028213151



--select distinct dd.* from (
select a3038.*, 
a3028.*
from 
(
select * from vnd.elo_carteira_sap sp
where nu_carteira_version = '20181110213006'
--and nu_contrato_sap = '0040385808'
and sp.DT_PAGO > current_date - 5
) a3038
inner join
(
select * from vnd.elo_carteira_sap sp
where nu_carteira_version = '20181110213006'
--and nu_contrato_sap = '0040385808'
and sp.DT_PAGO > current_date - 30

) a3028
on
a3038.nu_contrato_sap  = a3028.nu_contrato_sap and
a3038.cd_item_contrato = a3028.cd_item_contrato and 
a3038.nu_ordem_venda = a3028.nu_ordem_venda   and 
a3038.cd_item_pedido = a3028.cd_item_pedido and
a3038.cd_sales_group = a3028.cd_sales_group and 
a3038.no_sales_group = a3028.no_sales_group

where 
1=1
--and a3038.nu_contrato_sap is null or a3028.nu_contrato_sap is null

--union
--select a3038.*, a3028.*
--from 
--(
--select * from vnd.elo_carteira_sap 
--where nu_carteira_version = '20181028213005'
--) a3038
--inner join
--(
--select * from vnd.elo_carteira_sap 
--where nu_carteira_version = '20181028213151'
--
--) a3028
--on
--a3038.nu_contrato_sap  = a3028.nu_contrato_sap and
--a3038.cd_item_contrato = a3028.cd_item_contrato and 
--a3038.nu_ordem_venda = a3028.nu_ordem_venda   and 
--a3038.cd_item_pedido = a3028.cd_item_pedido and
--a3038.cd_sales_group = a3028.cd_sales_group and 
--a3038.no_sales_group = a3028.no_sales_group
--
--where 
--1=1
--and a3038.nu_contrato_sap is null or a3028.nu_contrato_sap is null

--) dd

;



