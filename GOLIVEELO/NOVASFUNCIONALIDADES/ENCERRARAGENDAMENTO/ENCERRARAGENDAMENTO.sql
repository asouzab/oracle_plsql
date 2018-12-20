
DECLARE 

CURSOR C_CT_ESCOPO IS 

SELECT 
CT.*

FROM VND.ELO_CARTEIRA CT
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON 
AGE.CD_ELO_AGENDAMENTO = CT.CD_ELO_AGENDAMENTO
WHERE 
CT.IC_ATIVO = 'S'
AND AGE.IC_ATIVO = 'S'
AND AGE.CD_ELO_STATUS IN (1,2,3,4,5,6,7 )  
AND AGE.DT_WEEK_START < CURRENT_DATE -20
AND NVL(CT.QT_AGENDADA_CONFIRMADA,0) >= 0
--AND CT.QT_AGENDADA > 0
--AND NVL(CT.CD_STATUS_CEL_FINAL, 40) IN (40, 59 )
AND NOT(NVL(CT.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND (CT.CD_TIPO_AGENDAMENTO IN (22,23,24) 
        OR (CT.CD_TIPO_AGENDAMENTO = 25 AND CT.CD_STATUS_REPLAN = 32) 
        OR (CT.CD_TIPO_AGENDAMENTO IS NULL 
        AND EXISTS (SELECT 1 FROM VND.VW_ELO_AGENDAMENTO_ITEM_ADICAO IIS WHERE IIS.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM)) )

order by AGE.CD_ELO_AGENDAMENTO, CT.CD_ELO_AGENDAMENTO_ITEM
;

CURSOR C_ATIVO (PI_CD_ELO_AGENDAMENTO_ITEM VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO_ITEM%TYPE) IS
SELECT 
CT.*

FROM VND.ELO_CARTEIRA CT

WHERE 
CT.IC_ATIVO = 'S'
AND CT.CD_ELO_AGENDAMENTO_ITEM = PI_CD_ELO_AGENDAMENTO_ITEM
AND CT.QT_AGENDADA_CONFIRMADA > 0
AND NVL(CT.CD_STATUS_CEL_FINAL, 99) IN (99, 59 )

AND (CT.CD_TIPO_AGENDAMENTO IN (22,23,24) 
        OR (CT.CD_TIPO_AGENDAMENTO = 25 AND CT.CD_STATUS_REPLAN = 32) 
        OR (CT.CD_TIPO_AGENDAMENTO IS NULL 
        AND EXISTS (SELECT 1 FROM VND.VW_ELO_AGENDAMENTO_ITEM_ADICAO IIS WHERE IIS.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM)) )
;



V_LIMIT NUMBER:=1000;


TYPE elo_ct_escopo_t IS TABLE OF VND.ELO_CARTEIRA%ROWTYPE
INDEX BY PLS_INTEGER;
tof_elo_ct_escopo elo_ct_escopo_t;

tof_elo_escopo_all elo_ct_escopo_t;


CURSOR C_ITEM_VALID (
PI_CD_ELO_AGENDAMENTO VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE,
PI_CD_ELO_AGENDAMENTO_ITEM VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO_ITEM%TYPE) IS 
SELECT 

PI_CD_ELO_AGENDAMENTO CD_ELO_AGENDAMENTO,
ITEM.CD_ELO_AGENDAMENTO_ITEM,
SUM(NVL(SS.QT_SEMANA,0)) QT_SEMANA,
SUM(NVL(DDAY.NU_QUANTIDADE,0)) NU_QUANTIDADE

FROM VND.ELO_AGENDAMENTO_ITEM ITEM 
LEFT JOIN VND.ELO_AGENDAMENTO_WEEK SS 
ON ITEM.CD_ELO_AGENDAMENTO_ITEM = SS.CD_ELO_AGENDAMENTO_ITEM
LEFT JOIN VND.ELO_AGENDAMENTO_DAY DDAY ON 
SS.CD_ELO_AGENDAMENTO_WEEK = DDAY.CD_ELO_AGENDAMENTO_WEEK 

WHERE 
EXISTS (SELECT 1 FROM VND.ELO_CARTEIRA CT
WHERE 
CT.IC_ATIVO = 'S'
AND CT.CD_ELO_AGENDAMENTO_ITEM = PI_CD_ELO_AGENDAMENTO_ITEM
AND CT.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM
AND CT.QT_AGENDADA_CONFIRMADA > 0
AND NVL(CT.CD_STATUS_CEL_FINAL, 99) IN (99, 59 )

AND (CT.CD_TIPO_AGENDAMENTO IN (22,23,24) 
        OR (CT.CD_TIPO_AGENDAMENTO = 25 AND CT.CD_STATUS_REPLAN = 32) 
        OR (CT.CD_TIPO_AGENDAMENTO IS NULL 
        AND EXISTS (SELECT 1 FROM VND.VW_ELO_AGENDAMENTO_ITEM_ADICAO IIS WHERE IIS.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM)) )
)   
GROUP BY ITEM.CD_ELO_AGENDAMENTO_ITEM
;  

TYPE elo_item_r IS RECORD
(
CD_ELO_AGENDAMENTO VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE,
CD_ELO_AGENDAMENTO_ITEM VND.ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_ITEM%TYPE,
QT_SEMANA VND.ELO_AGENDAMENTO_WEEK.QT_SEMANA%TYPE,
NU_QUANTIDADE VND.ELO_AGENDAMENTO_DAY.NU_QUANTIDADE%TYPE

);

TYPE elo_item_t IS TABLE OF elo_item_r
INDEX BY PLS_INTEGER;
tof_elo_item elo_item_t;

tof_agendamento_item elo_item_t;


CURSOR C_AGENDAMENTO_VALID (
PI_CD_ELO_AGENDAMENTO VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
) IS 
SELECT 

AGE.CD_ELO_AGENDAMENTO CD_ELO_AGENDAMENTO,
1 CD_ELO_AGENDAMENTO_ITEM,
SUM(NVL(SS.QT_SEMANA,0)) QT_SEMANA,
SUM(NVL(DDAY.NU_QUANTIDADE,0)) NU_QUANTIDADE

FROM VND.ELO_AGENDAMENTO AGE
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO 
INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM
ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR 
LEFT JOIN VND.ELO_AGENDAMENTO_WEEK SS 
ON ITEM.CD_ELO_AGENDAMENTO_ITEM = SS.CD_ELO_AGENDAMENTO_ITEM
LEFT JOIN VND.ELO_AGENDAMENTO_DAY DDAY ON 
SS.CD_ELO_AGENDAMENTO_WEEK = DDAY.CD_ELO_AGENDAMENTO_WEEK 


WHERE 
AGE.IC_ATIVO = 'S'
AND AGE.CD_ELO_AGENDAMENTO = PI_CD_ELO_AGENDAMENTO
GROUP BY AGE.CD_ELO_AGENDAMENTO
;  

tof_agendamento_todo elo_item_t;

tof_ag_todo_delete elo_item_t;
tof_procede_delete elo_item_t;




BEGIN

  

--BEGIN



    OPEN    C_CT_ESCOPO;   
    LOOP <<ESCOPO>>
    BEGIN
   
        FETCH   C_CT_ESCOPO BULK COLLECT INTO tof_elo_ct_escopo LIMIT V_LIMIT;
    
        IF tof_elo_ct_escopo.COUNT > 0 THEN 
        BEGIN

        
        FOR i_cart in tof_elo_ct_escopo.FIRST .. tof_elo_ct_escopo.LAST
        LOOP
            tof_elo_escopo_all(tof_elo_escopo_all.COUNT +1):=tof_elo_ct_escopo(i_cart);
  
        END LOOP;



        END;

        END IF;    
  


        EXIT WHEN C_CT_ESCOPO%NOTFOUND;
        

    END;

    END LOOP ESCOPO;
    CLOSE   C_CT_ESCOPO;
    
    IF tof_elo_escopo_all.COUNT > 0 THEN 
    BEGIN
    
        FOR i_item in tof_elo_escopo_all.FIRST .. tof_elo_escopo_all.LAST
        LOOP <<CTITEM>>
        

        
            BEGIN 
            OPEN    C_ITEM_VALID(tof_elo_escopo_all(i_item).CD_ELO_AGENDAMENTO, tof_elo_escopo_all(i_item).CD_ELO_AGENDAMENTO_ITEM);                               
            FETCH   C_ITEM_VALID BULK COLLECT INTO tof_elo_item LIMIT 1;
            CLOSE   C_ITEM_VALID;
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
            END;

            END;
            
            IF tof_elo_item.COUNT > 0 THEN
                IF tof_elo_item(tof_elo_item.first).qt_semana > 0 or  tof_elo_item(tof_elo_item.first).nu_quantidade > 0 THEN 
                    tof_agendamento_item(tof_agendamento_item.COUNT+1):= tof_elo_item(1);
                else 
                    tof_agendamento_todo(tof_agendamento_todo.COUNT+1):=tof_elo_item(1); 

                END IF;  
            else 
                tof_agendamento_todo(tof_agendamento_todo.COUNT+1).CD_ELO_AGENDAMENTO:=tof_elo_escopo_all(i_item).CD_ELO_AGENDAMENTO;
                tof_agendamento_todo(tof_agendamento_todo.COUNT).CD_ELO_AGENDAMENTO_ITEM:=1;    
                tof_agendamento_todo(tof_agendamento_todo.COUNT).QT_SEMANA:=0;
                tof_agendamento_todo(tof_agendamento_todo.COUNT).NU_QUANTIDADE:=0;
                  
            END IF;
            
    
        END LOOP CTITEM;
        
        IF tof_agendamento_todo.COUNT > 0 THEN 
        
            IF tof_agendamento_item.COUNT > 0 THEN
                FOR i_dele IN tof_agendamento_todo.first .. tof_agendamento_todo.last
                LOOP
                
                    FOR i_tem_volume IN tof_agendamento_item.first .. tof_agendamento_item.last
                    LOOP
                        if tof_agendamento_todo.exists (i_dele) then 
                            IF tof_agendamento_todo(i_dele).cd_elo_agendamento = tof_agendamento_item(i_tem_volume).cd_elo_agendamento then
                                tof_agendamento_todo.delete(i_dele);
                                
                                exit ;
                            END IF; 
                        end if;
                    END LOOP;
                


                END LOOP;
            
             
            END IF;
            
            if tof_agendamento_todo.count > 0 then
            
                for itodol in tof_agendamento_todo.first .. tof_agendamento_todo.last
                loop
                    if tof_agendamento_todo.exists(itodol) then 
                    
                        BEGIN 
                        OPEN    C_AGENDAMENTO_VALID(tof_agendamento_todo(itodol).cd_elo_agendamento);                               
                        FETCH   C_AGENDAMENTO_VALID BULK COLLECT INTO tof_ag_todo_delete LIMIT 1;
                        CLOSE   C_AGENDAMENTO_VALID;
                        EXCEPTION  
                        WHEN OTHERS THEN 
                        BEGIN
                        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                        --ROLLBACK;
                        END; 
                        END;
                        
                        if tof_ag_todo_delete.count > 0 then
                            IF nvl(tof_ag_todo_delete(tof_ag_todo_delete.first).qt_semana, 0) = 0 
                            AND nvl(tof_ag_todo_delete(tof_ag_todo_delete.first).nu_quantidade, 0) = 0 THEN
                                tof_procede_delete(tof_procede_delete.COUNT +1):=tof_ag_todo_delete(tof_ag_todo_delete.first);
                                DBMS_OUTPUT.PUT_LINE( tof_procede_elete(tof_procede_delete.COUNT).CD_ELO_AGENDAMENTO  );
                                
                                
                            END IF;
                         
                        end if;
                        
                    
                    
                    end if;
                end loop;

            end if;



        
        END IF;
    
    
    END;
    END IF;
    
    tof_elo_ct_escopo.delete; 
    tof_agendamento_todo.delete;  
    tof_agendamento_item.delete; 
    tof_elo_item.delete;
    tof_elo_escopo_all.delete;
    tof_procede_delete.delete;
    tof_ag_todo_delete.delete;



END;








