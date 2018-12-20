alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';
select count(1) from vnd.elo_carteira_sap_import
where nu_carteira_version = '20180731041552';


delete from vnd.elo_carteira_sap_import
where nu_carteira_version = '20180731041552';




DECLARE
    -- Declarations
    var_P_NU_CARTEIRA_VERSION   VARCHAR2 (14);
    
CURSOR VERS 
IS 

SELECT 
NU_CARTEIRA_VERSION ,
TEMPARCIAL
FROM 
(

SELECT 
DI.NU_CARTEIRA_VERSION,
DI.TEMPARCIAL, 

(SELECT COUNT(1) 
            FROM VND.ELO_CARTEIRA_SAP TEMPARCIAL 
            WHERE 
            TEMPARCIAL.NU_CARTEIRA_VERSION = DI.NU_CARTEIRA_VERSION) QT_CARTEIRA 
 
FROM (
select sap.NU_CARTEIRA_VERSION , 
CASE WHEN (SELECT COUNT(1) 
            FROM VND.ELO_CARTEIRA_SAP_IMPORT TEMPARCIAL 
            WHERE TEMPARCIAL.NU_CARTEIRA_VERSION = sap.NU_CARTEIRA_VERSION) >= 1 THEN 1
ELSE 0 END TEMPARCIAL 

from vnd.elo_carteira_sap sap
left join vnd.elo_carteira_sap_import impor
on sap.nu_carteira_version = impor.nu_carteira_version 
and sap.nu_contrato_sap = impor.nu_contrato_sap
and sap.cd_item_contrato = impor.cd_item_contrato
and sap.cd_produto_sap = impor.cd_produto_sap 
and NVL(sap.NU_ORDEM_VENDA, '0') = NVL(impor.NU_ORDEM_VENDA,'0')

WHERE 1=1
--AND NU_CARTEIRA_VERSION = '20180405060009'
and sap.dh_carteira > current_date - 180  
and impor.nu_carteira_version is null 
GROUP BY sap.nu_carteira_version

) DI

)
ORDER BY QT_CARTEIRA DESC 
;

TYPE elo_sap_r IS RECORD
(
NU_CARTEIRA_VERSION 			VND.ELO_CARTEIRA_SAP_IMPORT.NU_CARTEIRA_VERSION%TYPE,
TEM_PARCIAL  NUMBER
);

TYPE elo_sap_T IS TABLE OF elo_sap_r
INDEX BY PLS_INTEGER;
tof_elo_sap elo_sap_T;    
    
    
BEGIN


    open VERS ;
    fetch VERS bulk collect into tof_elo_sap limit 1000; 
    close VERS; 
    
    IF tof_elo_sap.COUNT > 0 THEN 
    BEGIN 
    
        FOR i_elo_sap in tof_elo_sap.FIRST .. tof_elo_sap.LAST
        LOOP

        -- Initialization
        var_P_NU_CARTEIRA_VERSION := tof_elo_sap(i_elo_sap).NU_CARTEIRA_VERSION;

        -- Call
         DBMS_OUTPUT.PUT_LINE(current_date);
        VND.PI_ELO_CARTEIRA_SAP_IMPORT (
            P_NU_CARTEIRA_VERSION   => var_P_NU_CARTEIRA_VERSION);

        -- Transaction Control
        COMMIT;
        
        END LOOP;
    end;
    end if;
    
END;


