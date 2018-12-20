
DECLARE 

CURSOR C_WHO_UPDATE IS 
SELECT INTE.CD_INTERFACE, 0 NEW_INTERFACE
FROM VND.INTERFACE INTE
WHERE CD_INTERFACE >=6863;

V_LIMIT NUMBER:=10000;

TYPE elo_interface_r IS RECORD
(
CD_INTERFACE     VND.INTERFACE.CD_INTERFACE%TYPE,
NEW_INTERFACE     VND.INTERFACE.CD_INTERFACE%TYPE


); 

TYPE elo_interface_t IS TABLE OF elo_interface_r
INDEX BY PLS_INTEGER;
tof_elo_interface elo_interface_t;

tof_new_interface elo_interface_t;

V_INTERFACE    NUMBER;


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
    
    V_INTERFACE:=6864;
    
    IF tof_elo_interface.COUNT > 0 THEN 
    
    FOR i_cart in tof_elo_interface.First .. tof_elo_interface.Last
    loop
    tof_new_interface(tof_new_interface.COUNT + 1).CD_INTERFACE:= tof_elo_interface(i_cart).CD_INTERFACE;
    tof_new_interface(tof_new_interface.COUNT).NEW_INTERFACE:= V_INTERFACE;
    V_INTERFACE:=V_INTERFACE+1;
    
    end loop;
    
    
    END IF;
    
    
    
	IF tof_new_interface.COUNT > 0 THEN 
	BEGIN 
		FORALL i_cart in INDICES OF tof_new_interface
            
                update  VND.INTERFACE 
                set CD_INTERFACE = tof_new_interface(i_cart).new_interface
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






