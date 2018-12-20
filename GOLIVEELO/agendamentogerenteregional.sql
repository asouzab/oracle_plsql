select distinct c.cd_sales_district, no_sales_district,
c.cd_sales_group, c.no_sales_group, 
c.cd_sales_office, c.no_sales_office
from vnd.elo_carteira_sap c
where 
cd_sales_district = 'ZBR001';


select c.*
from vnd.elo_carteira_sap c
where 1=1
and nu_ordem_venda = '0002357550'
and nu_carteira_version = '20180508233001';


select c.*
from vnd.elo_carteira c
where 
nu_ordem_venda = '0002357544' AND cd_elo_agendamento = 78;

select * from vnd.elo_agendamento where cd_elo_agendamento = 78

select c.nu_quantidade, sg_classificacao, c.dh_marcacao, c.ds_senha, c.dh_producao, c.no_cliente, c.cd_week, c.* from vnd.elo_marcacao c
where cd_week = 'W202018'
AND CD_CENTRO_EXPEDIDOR = '6060'
AND CD_ELO_CARTEIRA = 39326


select * from ctf.polo
select * from ctf.centro_expedidor


select * from vnd.elo_agendamento 
where cd_elo_agendamento = 76
 
--edit vnd.elo_agendamento 
--where cd_elo_agendamento = 76;

select nu_ordem_venda, count(1) from 
(
select distinct c.nu_ordem_venda, c.cd_produto_sap
from vnd.elo_carteira_sap c
where nu_ordem_venda is not null
)
group by nu_ordem_venda 
having count(1) > 1 ;

select * from ctf.usuario
where cd_login = 'lgomes3' or cd_usuario_original = '733'

