
DECLARE 

CURSOR C_WHO_UPDATE IS 
SELECT AGE.CD_ELO_AGENDAMENTO
FROM VND.ELO_AGENDAMENTO AGE
WHERE 
AGE.IC_ATIVO = 'S'
AND AGE.CD_ELO_STATUS IN (9 )  
--AND AGE.CD_ELO_AGENDAMENTO NOT IN ( 22)
AND EXISTS (SELECT 1 FROM VND.ELO_CARTEIRA_HIST HIS
WHERE HIS.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO)

UNION 
SELECT AGE.CD_ELO_AGENDAMENTO
FROM VND.ELO_AGENDAMENTO AGE
INNER JOIN VND.ELO_CARTEIRA_HIST HIS
ON 
HIS.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
INNER JOIN (SELECT dentro.CD_ELO_AGENDAMENTO, 
                   MAX(dentro.dh_ult_alteracao) max_dh_ult_alteracao 
                FROM VND.ELO_CARTEIRA_HIST dentro
                GROUP BY dentro.cd_elo_agendamento
                 ) cart_hist_ult 
ON
HIS.CD_ELO_AGENDAMENTO = cart_hist_ult.CD_ELO_AGENDAMENTO                  
WHERE 
cart_hist_ult.max_dh_ult_alteracao < current_date - 15
and AGE.IC_ATIVO = 'S'
AND AGE.CD_ELO_STATUS IN (8 )  

GROUP BY 
AGE.CD_ELO_AGENDAMENTO

;

CURSOR C_DELETE_AFTER_COPY IS 
SELECT CART.ID
FROM VND.ELO_CARTEIRA_HIST_ENCERRADO CART
INNER JOIN VND.ELO_CARTEIRA_HIST HIST
ON CART.ID = HIST.ID
;


V_LIMIT NUMBER:=800;

TYPE elo_agendamento_r IS RECORD
(
CD_ELO_AGENDAMENTO     VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE

); 

TYPE elo_agendamento_t IS TABLE OF elo_agendamento_r
INDEX BY PLS_INTEGER;
tof_elo_agendamento elo_agendamento_t;


TYPE elo_carteira_r IS RECORD
(
ID     VND.ELO_CARTEIRA_HIST_ENCERRADO.ID%TYPE

); 

TYPE elo_carteira_t IS TABLE OF elo_carteira_r
INDEX BY PLS_INTEGER;
tof_elo_carteira elo_carteira_t;


PROCEDURE LIMPAR_AGEND_ENCERRADO
IS

tof_elo_delete elo_carteira_t;
V_LIMIT_DEL number:=100000;

CURSOR C_DEL_ENCER IS 
SELECT CART.ID
FROM VND.ELO_CARTEIRA_HIST_ENCERRADO CART
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON 
CART.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
WHERE
((CART.dh_ult_alteracao < current_date - 60 AND AGE.CD_ELO_STATUS = 9)
OR (CART.dh_ult_alteracao < current_date - 90 AND AGE.CD_ELO_STATUS = 8)) 
;


BEGIN


    BEGIN 
    OPEN    C_DEL_ENCER;                               
    FETCH   C_DEL_ENCER BULK COLLECT INTO tof_elo_delete LIMIT V_LIMIT_DEL;
    CLOSE   C_DEL_ENCER;
    EXCEPTION  
    WHEN NO_DATA_FOUND THEN 
    NULL;
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.402 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;
    
    IF tof_elo_delete.COUNT > 0 THEN 
    
        BEGIN
        FORALL i_del in  indices of  tof_elo_delete
        DELETE FROM VND.ELO_CARTEIRA_HIST_ENCERRADO
        WHERE ID = tof_elo_delete(i_del).ID;
        COMMIT;
        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.403 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
        --ROLLBACK;
        END;  
        END;  
    
    
    END IF;



END LIMPAR_AGEND_ENCERRADO;


BEGIN

if 1=1 then     

BEGIN


    BEGIN 
    OPEN    C_WHO_UPDATE;                               
    FETCH   C_WHO_UPDATE BULK COLLECT INTO tof_elo_agendamento LIMIT V_LIMIT;
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
    
    
	IF tof_elo_agendamento.COUNT > 0 THEN 
	BEGIN 
		FOR i_cart in tof_elo_agendamento.FIRST .. tof_elo_agendamento.LAST
		LOOP
            
            BEGIN
            
            INSERT INTO VND.ELO_CARTEIRA_HIST_ENCERRADO
            
            SELECT 
            HIST.* 
            FROM VND.ELO_CARTEIRA_HIST HIST
            LEFT JOIN VND.ELO_CARTEIRA_HIST_ENCERRADO ENCD
            ON HIST.ID = ENCD.ID
            WHERE 
            HIST.CD_ELO_AGENDAMENTO = tof_elo_agendamento(i_cart).CD_ELO_AGENDAMENTO
            AND ENCD.ID IS NULL;
            
            COMMIT;            
                  
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.304 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
            END;
            END;
		END LOOP; 

	END;
	END IF;    
    
END;

end if;

BEGIN 

    BEGIN 
    OPEN    C_DELETE_AFTER_COPY;                               
    FETCH   C_DELETE_AFTER_COPY BULK COLLECT INTO tof_elo_carteira LIMIT 100000;
    CLOSE   C_DELETE_AFTER_COPY;
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;
    
    IF tof_elo_carteira.COUNT > 0 THEN 
    
    BEGIN
    FORALL i_cart in  indices of  tof_elo_carteira
    DELETE FROM VND.ELO_CARTEIRA_HIST
    WHERE ID = tof_elo_carteira(i_cart).ID;
    COMMIT;
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.306 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    
    
    END; 
    
    
    END IF;
    
    


END;


LIMPAR_AGEND_ENCERRADO();    
 


DBMS_SESSION.free_unused_user_memory;



END;

begin
DBMS_SESSION.free_unused_user_memory;

END;







