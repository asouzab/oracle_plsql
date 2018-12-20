
DECLARE 

CURSOR C_WHO_UPDATE IS 
select max(mm.cd_interface) cd_interface, mm.nu_codigo, mm.ic_tipo 
from vnd.interface mm
where 
mm.dh_execucao > current_date -2
and exists (

(select 1 from 
(
SELECT it.nu_codigo, count(1)  FROM VND.INTERFACE it
where it.dh_execucao > current_date -2
group by it.nu_codigo
having count(1) > 1) ss
where ss.nu_codigo = mm.nu_codigo))
group by mm.nu_codigo, mm.ic_tipo
 ;

V_LIMIT NUMBER:=10000;

TYPE elo_interface_r IS RECORD
(
CD_INTERFACE     VND.INTERFACE.CD_INTERFACE%TYPE,
NU_CODIGO     VND.INTERFACE.NU_CODIGO%TYPE,
IC_TIPO     VND.INTERFACE.IC_TIPO%TYPE

); 

TYPE elo_interface_t IS TABLE OF elo_interface_r
INDEX BY PLS_INTEGER;
tof_elo_interface elo_interface_t;

tof_new_interface elo_interface_t;



BEGIN


    BEGIN 
    OPEN    C_WHO_UPDATE;                               
    FETCH   C_WHO_UPDATE BULK COLLECT INTO tof_elo_interface LIMIT V_LIMIT;
    CLOSE   C_WHO_UPDATE;
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;
    

    
    IF tof_elo_interface.COUNT > 0 THEN 
    
    FOR i_cart in tof_elo_interface.First .. tof_elo_interface.Last
    loop
    tof_new_interface(tof_new_interface.COUNT + 1).CD_INTERFACE:= tof_elo_interface(i_cart).CD_INTERFACE;

    
    end loop;
    
    
    END IF;
    
    
    
	IF tof_new_interface.COUNT > 0 THEN 
	BEGIN 
		FORALL i_cart in INDICES OF tof_new_interface
            
                delete   VND.INTERFACE 
                where CD_INTERFACE = tof_new_interface(i_cart).CD_INTERFACE
                ;
		
    COMMIT;        
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.304 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    ROLLBACK;
    END;
    END;


	END IF;    
    



END;

--select * from vnd.interface where dh_execucao is null;






