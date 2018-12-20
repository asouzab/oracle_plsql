select distinct age.* from vnd.elo_agendamento age
inner join vnd.elo_carteira_sap sa
on age.nu_carteira_version = sa.nu_carteira_version

where 
age.cd_elo_status in (1,2,3,4,5,6,7,8)
and sa.dh_carteira > current_date - 27

and sa.nu_carteira_version in (

'20181020213111'   ,   --        10513    20/10/2018  congelada com bloqueios (não utilizar)
--20181020214618'              9315      20/10/2018
--20181021213011'              9333      21/10/2018
'20181021213025'    ,    --      10492    21/10/2018  congelada com bloqueios (não utilizar)
'20181022213038'     ,   --      10492    22/10/2018  congelada com bloqueios (não utilizar)
--20181022213028'              9155      22/10/2018
'20181023213056'    ,     --     10491    23/10/2018  congelada com bloqueios (não utilizar)
--20181023213012              9065      23/10/2018
'20181024213002'    ,     --     10490    24/10/2018  congelada com bloqueios (não utilizar)
--20181024213013              8901      24/10/2018
'20181025213018'    ,     --     10489    25/10/2018  congelada com bloqueios (não utilizar)
--20181025213000              8800      25/10/2018
'20181026213036'    ,     --     10470    26/10/2018  congelada com bloqueios (não utilizar)
--20181026213016'              8678      26/10/2018
--20181027213007'              8649      27/10/2018
'20181027213048'    ,     --     10470    27/10/2018  congelada com bloqueios (não utilizar)
--20181028213005'              8675      28/10/2018
'20181028213151'         --     10470    28/10/2018  congelada com bloqueios (não utilizar)


)

;
