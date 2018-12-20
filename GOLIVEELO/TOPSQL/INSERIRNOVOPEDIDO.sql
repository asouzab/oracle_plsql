INSERT INTO VND.INTERFACE (
  CD_INTERFACE, 
   IC_TIPO, 
   NU_CODIGO
)
select
(select max(CD_INTERFACE) from interface) + rownum,
 'G',
 nu_contrato_sap
from vnd.contrato
 where nu_contrato_sap in (
'0040388989'
);


INSERT INTO VND.INTERFACE (
  CD_INTERFACE, 
   IC_TIPO, 
   NU_CODIGO
)
SELECT 
(select max(CD_INTERFACE) from interface) + 1 , 'C','2359208' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 2 , 'C','2355660' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 3 , 'C','2359306' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 4 , 'C','2351914' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 5 , 'C','2359260' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 6 , 'C','2359210' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 7 , 'C','2359283' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 8 , 'C','2359208' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 9 , 'C','2359305' FROM DUAL
--
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 10 , 'C','2359279' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 11 , 'C','2359208' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 12 , 'C','2362250' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 13 , 'C','2359280' FROM DUAL
UNION
SELECT 
(select max(CD_INTERFACE) from interface) + 14 , 'C','2351921' FROM DUAL;





SELECT * FROM VND.INTERFACE
WHERE DH_EXECUCAO IS NULL;

























