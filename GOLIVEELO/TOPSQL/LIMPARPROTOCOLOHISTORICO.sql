
DECLARE 

V_LIMITENA_INTERFACE NUMBER:= 50000;
V_LIMITE_MODI NUMBER:=30;


CURSOR C_WHO_UPDATE IS 
SELECT  
CT.CD_ELO_CARTEIRA, 
PROT_HIS.ID 

FROM VND.ELO_CARTEIRA CT
INNER JOIN VND.ELO_AGENDAMENTO AG
ON 
AG.CD_ELO_AGENDAMENTO = CT.CD_ELO_AGENDAMENTO
inner join VND.ELO_CARTEIRA_PROT_HIST PROT_HIS
ON 
PROT_HIS.CD_ELO_CARTEIRA = CT.CD_ELO_CARTEIRA

WHERE 
CT.IC_ATIVO = 'S'
and AG.IC_ATIVO = 'S'
AND AG.CD_ELO_STATUS IN (8,9) 
AND ((CT.CD_STATUS_CEL_FINAL  IN ( 59 ) AND PROT_HIS.DH_MODIFICACAO_PROTOCOLO < CURRENT_DATE - V_LIMITE_MODI)
OR (PROT_HIS.DH_MODIFICACAO_PROTOCOLO < CURRENT_DATE - 90)
)

;



V_LIMIT NUMBER:=110000;

TYPE elo_interface_r IS RECORD
(
CD_ELO_CARTEIRA     VND.ELO_CARTEIRA_PROT_HIST.CD_ELO_CARTEIRA%TYPE,
ID                  VND.ELO_CARTEIRA_PROT_HIST.ID%TYPE

); 

TYPE elo_interface_t IS TABLE OF elo_interface_r
INDEX BY PLS_INTEGER;

tof_elo_interface_todos elo_interface_t;

BEGIN

    
    BEGIN
        OPEN    C_WHO_UPDATE;  
        FETCH   C_WHO_UPDATE BULK COLLECT INTO tof_elo_interface_todos LIMIT V_LIMIT;
        CLOSE   C_WHO_UPDATE;

        EXCEPTION  
        WHEN NO_DATA_FOUND THEN 
        NULL;
        
        WHEN OTHERS THEN 
        BEGIN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
        --ROLLBACK;
        END;
    END;
    
    
	IF tof_elo_interface_todos.COUNT > 0 THEN 
	BEGIN 
        
	BEGIN
		FORALL i_cart IN INDICES OF tof_elo_interface_todos
                DELETE FROM VND.ELO_CARTEIRA_PROT_HIST 
                WHERE ID = tof_elo_interface_todos(i_cart).ID AND 
                CD_ELO_CARTEIRA = tof_elo_interface_todos(i_cart).CD_ELO_CARTEIRA
                ;
		
            COMMIT;  
                  
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.304 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
            END;
    END;


	END;
	END IF;       
    

DBMS_SESSION.free_unused_user_memory;

END;

--select * from vnd.ELO_CARTEIRA_PROT_HIST where DH_MODIFICACAO_PROTOCOLO < CURRENT_DATE - 90 ORDER BY ID ASC;
--SELECT TRUNC(DH_MODIFICACAO_PROTOCOLO, 'MONTH'), COUNT(1) FROM ELO_CARTEIRA_PROT_HIST GROUP BY TRUNC(DH_MODIFICACAO_PROTOCOLO, 'MONTH') ;



SELECT * FROM VND.ELO_CARTEIRA 
WHERE CD_ELO_CARTEIRA = 243695;

SELECT * FROM VND.ELO_CARTEIRA_PROT_HIST
WHERE CD_ELO_CARTEIRA = 243695;

BEGIN
DBMS_SESSION.free_unused_user_memory;

END;









