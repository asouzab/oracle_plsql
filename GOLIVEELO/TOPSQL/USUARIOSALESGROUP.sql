WITH USUARIO_LO AS 
(select 
sg.cd_usuario cd_usuario_sales_group, 
--sg.cd_usuario_superior cd_user_superior_sale_group, 
sg.cd_usuario_original cd_sales_group, 
------sg.tipo_usuario cd_tipo_usuario_sales_group, 
sg.no_usuario no_sales_group, 
sg.cd_login cd_login_sales_group,

--so.cd_usuario cd_usuario_sales_office, 
--so.cd_usuario_superior cd_user_superior_sale_office, 
so.cd_usuario_original cd_sales_office, 
--so.tipo_usuario cd_tipo_usuario_sales_office, 
so.no_usuario no_sales_office, 
--so.cd_login cd_login_sales_office,

--sd.cd_usuario cd_usuario_sales_district, 
--sd.cd_usuario_superior cd_user_superior_sale_district, 
sd.cd_usuario_original cd_sales_district, 
--sd.tipo_usuario cd_tipo_usuario_sales_district, 
sd.no_usuario no_sales_district--, 
--sd.cd_login cd_login_sales_district

from ctf.usuario sg
left join ctf.usuario so
on 
sg.cd_usuario_superior = so.cd_usuario
AND so.cd_tipo_usuario in (2,3)
and so.cd_usuario_original is not null 
and so.cd_usuario_superior is not null

left join ctf.usuario sd
on 
sg.cd_usuario_superior = sd.cd_usuario
AND sd.cd_tipo_usuario in (2,3)
and sd.cd_usuario_original is not null 
--and sd.cd_usuario_superior is not null

where sg.ic_ativo = 'S'
AND sg.cd_tipo_usuario in(4)--2-gerente regional, 3 gerente nacional, 4 supervisor 
and sg.cd_usuario_original is not null
and sg.cd_usuario_superior is not null
)
SELECT SAP.NU_CARTEIRA_VERSION, 
(SELECT US.CD_SALES_GROUP FROM USUARIO_LO US WHERE US.CD_SALES_GROUP = SAP.CD_SALES_GROUP) CD_SALES_GROUP 
--US.NO_SALES_GROUP,
--US.CD_SALES_OFFICE,
--US.NO_SALES_OFFICE,
--US.CD_SALES_DISTRICT,
--US.NO_SALES_DISTRICT
FROM VND.ELO_CARTEIRA_SAP SAP
--LEFT JOIN USUARIO_LO US
--ON 
--SAP.CD_SALES_GROUP = US.CD_SALES_GROUP
WHERE 
SAP.DH_CARTEIRA > CURRENT_DATE - 30
GROUP BY 
SAP.NU_CARTEIRA_VERSION, 
SAP.CD_SALES_GROUP 
--US.NO_SALES_GROUP,
--US.CD_SALES_OFFICE,
--US.NO_SALES_OFFICE,
--US.CD_SALES_DISTRICT,
--US.NO_SALES_DISTRICT

;


select max(dh_carteira) dh , cd_sales_group, no_sales_group, cd_sales_office, no_sales_office, cd_sales_district, no_sales_district
from vnd.elo_carteira_sap
where dh_carteira >  current_date - 3000

and cd_sales_group in 
(
738,
739,
742,
745,
746
)
group by 
cd_sales_group, no_sales_group, cd_sales_office, no_sales_office, cd_sales_district, no_sales_district;



SELECT * FROM ALL_VIEWS 
WHERE UPPER(TEXT) LIKE '%VW_ELO_CARTEIRA_SAP_SALESGROUP%';