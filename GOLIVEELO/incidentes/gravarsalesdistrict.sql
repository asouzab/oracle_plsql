SELECT * FROM ALL_SOURCE
WHERE UPPER(TEXT) LIKE '%DS_VERSAO%';

select * from vnd.elo_agendamento
where cd_week = 'W222018' AND CD_POLO = 'P002';

SELECT * FROM VND.ELO_STATUS;

SELECT * FROM VND.ELO_AGENDAMENTO;

SELECT * FROM VND.ELO_CARTEIRA
WHERE 
CD_ELO_AGENDAMENTO = 123
AND QT_AGENDADA_CONFIRMADA > 0 
AND (NVL(CD_TIPO_AGENDAMENTO, 223) IN (22,23,24) OR CD_TIPO_AGENDAMENTO = 25 AND CD_STATUS_REPLAN = 32) 


select * from vnd.elo_carteira_sap 
where no_sales_group = ' '; 
where cd_sales_group is null;
where cd_sales_group = 706
and nu_contrato_sap = '0040387058' and nu_ordem_venda = '0002349664';

;


select * from vnd.ELO_CARTEIRA_SAP
where no_sales_district is null;

Alex Francisco

--update vnd.elo_carteira
--set no_sales_group = 'Alex Francisco' 
--where no_sales_group= ' ' and cd_sales_group = 855;

select
'UPDATE vnd.elo_carteira set no_sales_district = ''' 
|| sss.no_sales_district 
|| ''' , cd_sales_district = ''' 
|| sss.cd_sales_district 
|| ''' where cd_elo_carteira = ' || to_char(c.cd_elo_carteira) || ' and no_sales_district is null ;'
, 


 c.cd_elo_carteira, c.cd_tipo_agendamento, 
c.no_sales_district, c.cd_sales_district, c.cd_sales_group , 
sss.cd_sales_district, sss.no_sales_district, sss.cd_sales_group
from  vnd.elo_carteira c 
inner join vnd.elo_agendamento age
on age.cd_elo_agendamento = c.cd_elo_agendamento  

inner join
(select distinct sap.cd_sales_group, sap.cd_sales_district, sap.no_sales_district, sap.nu_carteira_version, sap.nu_contrato_sap , sap.nu_ordem_venda
 from vnd.elo_carteira_sap sap
) sss on
sss.cd_sales_group = c.cd_sales_group
and sss.nu_contrato_sap = c.nu_contrato_sap 
and sss.nu_ordem_venda = c.nu_ordem_venda
and age.nu_carteira_version = sss.nu_carteira_version 

where c.no_sales_district is null; 
