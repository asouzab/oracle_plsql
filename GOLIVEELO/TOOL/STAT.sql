select * from vnd.elo_agendamento 
where cd_week = 'W242018' and cd_polo = 'P002' ;

select * from vnd.elo_carteira
where 
--3056025
nu_contrato_sap = '0040390467' and cd_produto_sap = '000000000000119049'
--and nu_ordem_venda is null
 AND CD_ELO_AGENDAMENTO = 171;
nu_ordem_venda = '0002373044';

update vnd.elo_carteira
set cd_status_cel_final = 59 
where 
nu_ordem_venda = '0002373026'
and cd_elo_carteira = '77446';


INSERT INTO VND.INTERFACE (
  CD_INTERFACE, 
   IC_TIPO, 
   NU_CODIGO
)
select
(select max(CD_INTERFACE) from interface) + 1,
 'G',
 nu_contrato_sap
from vnd.contrato
 where nu_contrato_sap in (
'0040392663');


INSERT INTO VND.INTERFACE (
  CD_INTERFACE, 
   IC_TIPO, 
   NU_CODIGO
)
select
(select max(CD_INTERFACE) from interface) + 1,
 'C', '0002373044'
 
 
from dual
 
;




SELECT * FROM VND.PEDIDO
WHERE nu_ordem_venda = '0002373044';


select * from VND.INTERFACE
where dh_execucao is null;


select * from vnd.job_error
where 
ds_key  --3056025
like '%2373044%';

SELECT '

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => '|| CHR(39) || 'VND' || CHR(39) ||
    ',TabName           => ' || CHR(39) ||  TABLE_NAME  || CHR(39) ||
    ',Estimate_Percent  => 10
    ,Method_Opt        => ' || CHR(39) || 'FOR ALL COLUMNS SIZE 1' || CHR(39) ||
    ',Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;' TT--, TT.*
FROM USER_TABLES TT 
WHERE  
 TABLE_NAME LIKE '%ELO%'
 AND STATUS = 'VALID' AND LAST_ANALYZED < SYSDATE - 30
 AND TEMPORARY = 'N'  ORDER BY NUM_ROWS ;
 
 




