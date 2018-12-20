CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_BATCH_ISSUE AS
/******************************************************************************
   NAME:       GX_ELO_BATCH_ISSUE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/06/2018      adesouz2       1. Created this package body.
******************************************************************************/


PROCEDURE PU_UPDATE_QT_SEMANA
( 
p_result        OUT t_cursor
)
IS 
BEGIN 
NULL;
END PU_UPDATE_QT_SEMANA;


PROCEDURE PU_UPDATE_QT_SEMANA_CIF
( 
p_result        OUT t_cursor

)

IS 
    
    v_limit                     NUMBER := 10000;
    v_count                     NUMBER := 0;
    

    V_CART_QT_LINHAS      NUMBER; 
    V_LINHA                 PLS_INTEGER;   
    
    v_item_new vnd.elo_carteira.cd_elo_agendamento_item%TYPE;
    v_item_old vnd.elo_carteira.cd_elo_agendamento_item%TYPE;  
    
    v_qt_saldo_by_item VND.ELO_AGENDAMENTO_WEEK.QT_SEMANA%TYPE;

    TYPE carteira_r IS RECORD
    (
        cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
        cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
        nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE,
        qt_saldo_by_item                vnd.elo_agendamento_week.qt_semana%TYPE,
        qt_semana_by_item               vnd.elo_agendamento_week.qt_semana%TYPE
    );
    TYPE carteira_t IS TABLE OF carteira_r;
    t_carteira carteira_t;
        
    TYPE carteira_vol_programado_r IS RECORD
    (
        cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
        cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        qt_agendada                     vnd.elo_carteira.qt_agendada%TYPE,
        qt_agendada_confirmada          vnd.elo_carteira.qt_agendada_confirmada%TYPE
    );
    TYPE carteira_vol_programado_t IS TABLE OF carteira_vol_programado_r
    INDEX BY PLS_INTEGER;
         
    tof_carteira_vol_prog carteira_vol_programado_t;  
    
    tof_agendamento_item carteira_vol_programado_t;  
    
    
    
    TYPE daily_agendamento_day_r IS RECORD
    (
    cd_elo_agendamento_item    vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
    nu_semana                  vnd.elo_agendamento_week.nu_semana%TYPE,
    cd_grupo_embalagem         vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
    nu_quantidade              vnd.elo_agendamento_week.qt_semana%TYPE,
    cd_week                    vnd.elo_agendamento.cd_week%TYPE,
    cd_site                    CHAR(4),
    site_type                  CHAR(1),
    cd_sales_office            vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
    cd_sales_group             vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
    minimun_day_for_replan     vnd.elo_agendamento_day.nu_dia_semana%TYPE
    ) ; 
    
    TYPE agendamento_day_t IS TABLE OF daily_agendamento_day_r;
    tof_agendamento_day agendamento_day_t;    
    
    TYPE daily_agendamento_day_t IS TABLE OF daily_agendamento_day_r
    INDEX BY PLS_INTEGER;      
    
    tofdaily_agendamento_day_t daily_agendamento_day_t;
    
    
    TYPE elo_agendamento_item_r IS RECORD
    (
    cd_elo_agendamento_item     vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE
    ); 
    
    TYPE elo_agendamento_item_t IS TABLE OF elo_agendamento_item_r
    INDEX BY PLS_INTEGER;
  

    CURSOR c_carteira IS
    
    WITH CTE_ITEM_CARTEIRA_ADJ AS (
    SELECT 1 cd_elo_carteira,
           ca.cd_elo_agendamento_item,
           NVL(ca.qt_saldo, 0)  qt_saldo,
           1 nu_ordem,
            nvl((SELECT NVL(SUM(cate.qt_agendada_confirmada), 0) 
            FROM vnd.elo_carteira cate
            WHERE cate.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
            AND cate.qt_agendada_confirmada > 0 
            AND cate.CD_STATUS_CEL_FINAL = 59
            AND (cate.cd_tipo_agendamento in (22,23,24) or (cate.cd_tipo_agendamento = 25 and cate.cd_status_replan = 32))                
            AND cate.ic_ativo = 'S'),0) qt_saldo_by_item ,
            NVL((SELECT SUM(WE.QT_SEMANA) 
            FROM VND.ELO_AGENDAMENTO_WEEK WE
            WHERE WE.CD_ELO_AGENDAMENTO_WEEK = AW.CD_ELO_AGENDAMENTO_WEEK
            ) , 0) qt_semana_by_week               
                          
           
      FROM vnd.elo_carteira ca
     INNER JOIN vnd.elo_agendamento_item ai
        ON ai.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
     INNER JOIN vnd.elo_agendamento_week aw
        ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
     INNER JOIN vnd.elo_agendamento_supervisor ap
     on ap.CD_ELO_AGENDAMENTO_SUPERVISOR = ai.CD_ELO_AGENDAMENTO_SUPERVISOR
     inner join vnd.elo_agendamento age
     on age.cd_elo_agendamento = ap.cd_elo_agendamento 
     WHERE   
       age.cd_elo_status in (6,7)
       AND ca.ic_ativo = 'S'
       AND ai.ic_ativo = 'S'
      -- AND (ca.cd_tipo_agendamento in (22,23,24) or (ca.cd_tipo_agendamento = 25 and ca.cd_status_replan = 32))
      -- AND ca.cd_status_cel_final = 59 
       AND ca.CD_INCOTERMS = 'CIF'
      -- AND ca.QT_AGENDADA_CONFIRMADA > 0 
    )
    
    SELECT 
    cd_elo_carteira, 
    cd_elo_agendamento_item,
    sum(qt_saldo) qt_saldo,
    nu_ordem,
    MAX(qt_saldo_by_item) qt_saldo_by_item, 
    MAX(qt_semana_by_week) qt_semana_by_item
    
    FROM  CTE_ITEM_CARTEIRA_ADJ
     
    
    GROUP BY 
    cd_elo_carteira, 
    cd_elo_agendamento_item,
    nu_ordem
    
    HAVING  ABS(MAX(qt_saldo_by_item) - MAX(qt_semana_by_week)) > 1   --TOLERANCIA DE 1 VOLUME NA QUANTIDADE
    
    ORDER BY 
    cd_elo_agendamento_item 
    ;
    
    CURSOR C_WEEKS (pi_cd_elo_agendamento_item VND.ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_ITEM%TYPE) IS 
    SELECT 
    BEGRP.CD_ELO_AGENDAMENTO_ITEM,
    BEGRP.NU_SEMANA,
    BEGRP.CD_GRUPO_EMBALAGEM,
    BEGRP.QT_SEMANA, 
    BEGRP.CD_WEEK ,
    BEGRP.CD_SITE,
    BEGRP.SITE_TYPE, 
    BEGRP.CD_SALES_OFFICE, 
    BEGRP.CD_SALES_GROUP,
    MIN(BEGRP.minimun_day_for_replan) minimun_day_for_replan
    FROM (
    SELECT 
    WEES.CD_ELO_AGENDAMENTO_ITEM,
    WEES.NU_SEMANA,
    DAYSS.CD_GRUPO_EMBALAGEM, 
    WEES.QT_SEMANA,
    AGE.CD_WEEK,
    CASE 
    WHEN AGE.CD_POLO IS NOT NULL THEN AGE.CD_POLO
    WHEN AGE.CD_CENTRO_EXPEDIDOR IS NOT NULL THEN AGE.CD_CENTRO_EXPEDIDOR
    ELSE AGE.CD_MACHINE END CD_SITE,
    CASE 
    WHEN AGE.CD_POLO IS NOT NULL THEN 'P'
    WHEN AGE.CD_CENTRO_EXPEDIDOR IS NOT NULL THEN 'C'
    ELSE 'M' END SITE_TYPE,             
    SUP.CD_SALES_OFFICE,
    SUP.CD_SALES_GROUP,        
    CASE 
    WHEN ITEM.cd_status_replan IS NOT NULL THEN DAYSS.NU_DIA_SEMANA
    ELSE 1 END minimun_day_for_replan   -- SEGUNDA-FEIRA
    
    FROM VND.ELO_AGENDAMENTO AGE
    INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
    ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO 
    INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
    ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEES
    ON 
    ITEM.CD_ELO_AGENDAMENTO_ITEM = WEES.CD_ELO_AGENDAMENTO_ITEM
    INNER JOIN VND.ELO_AGENDAMENTO_DAY DAYSS
    ON 
    WEES.CD_ELO_AGENDAMENTO_WEEK = DAYSS.CD_ELO_AGENDAMENTO_WEEK
    
    WHERE 
    ITEM.CD_ELO_AGENDAMENTO_ITEM = pi_cd_elo_agendamento_item
    ) BEGRP
    GROUP BY
    BEGRP.CD_ELO_AGENDAMENTO_ITEM,
    BEGRP.NU_SEMANA,
    BEGRP.CD_GRUPO_EMBALAGEM,
    BEGRP.QT_SEMANA, 
    BEGRP.CD_WEEK ,
    BEGRP.CD_SITE,
    BEGRP.SITE_TYPE, 
    BEGRP.CD_SALES_OFFICE, 
    BEGRP.CD_SALES_GROUP--,
    --BEGRP.minimun_day_for_replan;    
    ;
    

    BEGIN
        
        v_count:=0;
        
        OPEN    c_carteira;                               
        FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
        CLOSE   c_carteira;

        V_CART_QT_LINHAS:=t_carteira.COUNT;
        V_LINHA:=1;

        <<main_loop>>
        LOOP

            EXIT WHEN v_count >= V_CART_QT_LINHAS;


            --V_LINHA:=1;
            v_item_new:=t_carteira(V_LINHA).cd_elo_agendamento_item;
            v_item_old:=v_item_new; 
            
            v_qt_saldo_by_item:= t_carteira(V_LINHA).qt_saldo_by_item;    
            --   v_qt_saldo_by_item this is total quantity of week by item  (maximum qt)     
            
            
            LOOP
            
                EXIT WHEN v_count >= V_CART_QT_LINHAS OR not(v_item_new = v_item_old);

                tof_carteira_vol_prog(tof_carteira_vol_prog.COUNT+1).CD_ELO_AGENDAMENTO_ITEM:= t_carteira(V_LINHA).CD_ELO_AGENDAMENTO_ITEM; 
                tof_carteira_vol_prog(tof_carteira_vol_prog.COUNT).qt_agendada_confirmada:= v_qt_saldo_by_item; 
                
                tof_agendamento_item(tof_agendamento_item.COUNT+1).CD_ELO_AGENDAMENTO_ITEM:= t_carteira(V_LINHA).CD_ELO_AGENDAMENTO_ITEM;
                tof_agendamento_item(tof_agendamento_item.COUNT).qt_agendada_confirmada:= v_qt_saldo_by_item;
                
                
                v_count := v_count + 1;
                V_LINHA:=V_LINHA +1;
                IF v_count < V_CART_QT_LINHAS then 
                    v_item_new:=t_carteira(V_LINHA).cd_elo_agendamento_item;
                END IF;
                
                

            END LOOP;
            
        END LOOP main_loop;
        

        
        BEGIN 
        FORALL i_cart in INDICES OF tof_carteira_vol_prog
                UPDATE vnd.elo_agendamento_week wees
                   SET wees.qt_semana = tof_carteira_vol_prog(i_cart).qt_agendada_confirmada
                 WHERE wees.cd_elo_agendamento_item = tof_carteira_vol_prog(i_cart).cd_elo_agendamento_item
                 AND nvl(wees.qt_semana,0) <> tof_carteira_vol_prog(i_cart).qt_agendada_confirmada
                ;
				COMMIT;        
        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.001 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;    
        END;        
        
        
        V_CART_QT_LINHAS:= tof_agendamento_item.COUNT;
        
        IF V_CART_QT_LINHAS > 0 THEN
        BEGIN
        
        FOR i_cart IN 1..  tof_agendamento_item.LAST
        LOOP
        
            BEGIN 
            OPEN    C_WEEKS(tof_agendamento_item(i_cart).cd_elo_agendamento_item);                               
            FETCH   C_WEEKS BULK COLLECT INTO tof_agendamento_day LIMIT v_limit;
            CLOSE   C_WEEKS;
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.002 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
            END;
            
            END;
            
            
            IF tof_agendamento_day.COUNT > 0 THEN 
            BEGIN 
        
                FOR i_day IN 1.. tof_agendamento_day.LAST
                LOOP
                
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT +1).cd_elo_agendamento_item:=tof_agendamento_day(i_day).cd_elo_agendamento_item; 
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).nu_semana:=tof_agendamento_day(i_day).nu_semana;         
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_grupo_embalagem:=tof_agendamento_day(i_day).cd_grupo_embalagem;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).nu_quantidade:=tof_agendamento_day(i_day).nu_quantidade;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_week:=tof_agendamento_day(i_day).cd_week;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_site:=tof_agendamento_day(i_day).cd_site;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).site_type:=tof_agendamento_day(i_day).site_type;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_sales_office:=tof_agendamento_day(i_day).cd_sales_office;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_sales_group:=tof_agendamento_day(i_day).cd_sales_group;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).minimun_day_for_replan:=tof_agendamento_day(i_day).minimun_day_for_replan;
                END LOOP;
                END;
            END IF;
        
        END LOOP;
        
        V_CART_QT_LINHAS:= tofdaily_agendamento_day_t.COUNT;
        
        IF V_CART_QT_LINHAS > 0 THEN
        BEGIN
        
        FOR i_cart IN 1..  tofdaily_agendamento_day_t.LAST
        LOOP  
        
        BEGIN
        VND.GX_ELO_SCHEDULING.pi_agendamento_day_cif(
        P_CD_ELO_AGENDAMENTO_ITEM => tofdaily_agendamento_day_t(i_cart).CD_ELO_AGENDAMENTO_ITEM,
        P_NU_SEMANA => tofdaily_agendamento_day_t(i_cart).NU_SEMANA, 
        P_CD_GRUPO_EMBALAGEM => tofdaily_agendamento_day_t(i_cart).CD_GRUPO_EMBALAGEM, 
        P_NU_QUANTIDADE =>  tofdaily_agendamento_day_t(i_cart).NU_QUANTIDADE, 
        P_CD_WEEK =>  tofdaily_agendamento_day_t(i_cart).CD_WEEK,
        P_CD_SITE =>  tofdaily_agendamento_day_t(i_cart).CD_SITE,
        P_SITE_TYPE =>  tofdaily_agendamento_day_t(i_cart).SITE_TYPE,
        P_CD_SALES_OFFICE =>  tofdaily_agendamento_day_t(i_cart).CD_SALES_OFFICE,        
        P_CD_SALES_GROUP =>  tofdaily_agendamento_day_t(i_cart).CD_SALES_GROUP,
        P_MINIMUN_DAY_FOR_REPLAN =>  tofdaily_agendamento_day_t(i_cart).MINIMUN_DAY_FOR_REPLAN,  
        P_RESULT => p_result

        );
        COMMIT;

        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.003 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
        --ROLLBACK;
        END;
        
        
        
        END;
        
        END LOOP;      
        
        
        END;
        END IF;
        
        
        END; 
        END IF;
        
        


END PU_UPDATE_QT_SEMANA_CIF;



PROCEDURE PU_UPDATE_QT_SEMANA_MONTH_CIF
( 
p_result        OUT t_cursor

)

IS 
    
    v_limit                     NUMBER := 10000;
    v_count                     NUMBER := 0;
    

    V_CART_QT_LINHAS      NUMBER; 
    V_LINHA                 PLS_INTEGER;   
    
    v_item_new vnd.elo_carteira.cd_elo_agendamento_item%TYPE;
    v_item_old vnd.elo_carteira.cd_elo_agendamento_item%TYPE;  
    
    v_qt_saldo_by_item VND.ELO_AGENDAMENTO_WEEK.QT_SEMANA%TYPE;

    TYPE carteira_r IS RECORD
    (
        cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
        cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
        nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE,
        qt_saldo_by_item                vnd.elo_agendamento_week.qt_semana%TYPE,
        qt_semana_by_item               vnd.elo_agendamento_week.qt_semana%TYPE
    );
    TYPE carteira_t IS TABLE OF carteira_r;
    t_carteira carteira_t;
        
    TYPE carteira_vol_programado_r IS RECORD
    (
        cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
        cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        qt_agendada                     vnd.elo_carteira.qt_agendada%TYPE,
        qt_agendada_confirmada          vnd.elo_carteira.qt_agendada_confirmada%TYPE
    );
    TYPE carteira_vol_programado_t IS TABLE OF carteira_vol_programado_r
    INDEX BY PLS_INTEGER;
         
    tof_carteira_vol_prog carteira_vol_programado_t;  
    
    tof_agendamento_item carteira_vol_programado_t;  
    
    
    
    TYPE daily_agendamento_day_r IS RECORD
    (
    cd_elo_agendamento_item    vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
    nu_semana                  vnd.elo_agendamento_week.nu_semana%TYPE,
    cd_grupo_embalagem         vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
    nu_quantidade              vnd.elo_agendamento_week.qt_semana%TYPE,
    cd_week                    vnd.elo_agendamento.cd_week%TYPE,
    cd_site                    CHAR(4),
    site_type                  CHAR(1),
    cd_sales_office            vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
    cd_sales_group             vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
    minimun_day_for_replan     vnd.elo_agendamento_day.nu_dia_semana%TYPE
    ) ; 
    
    TYPE agendamento_day_t IS TABLE OF daily_agendamento_day_r;
    tof_agendamento_day agendamento_day_t;    
    
    TYPE daily_agendamento_day_t IS TABLE OF daily_agendamento_day_r
    INDEX BY PLS_INTEGER;      
    
    tofdaily_agendamento_day_t daily_agendamento_day_t;
    
    
    TYPE elo_agendamento_item_r IS RECORD
    (
    cd_elo_agendamento_item     vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE
    ); 
    
    TYPE elo_agendamento_item_t IS TABLE OF elo_agendamento_item_r
    INDEX BY PLS_INTEGER;
  

    CURSOR c_carteira IS
    
    WITH CTE_ITEM_CARTEIRA_ADJ AS (
    SELECT 1 cd_elo_carteira,
           ca.cd_elo_agendamento_item,
           NVL(ca.qt_saldo, 0)  qt_saldo,
           1 nu_ordem,
            nvl((SELECT NVL(SUM(cate.qt_agendada_confirmada), 0) 
            FROM vnd.elo_carteira cate
            WHERE cate.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
            AND cate.qt_agendada_confirmada > 0 
            AND cate.CD_STATUS_CEL_FINAL = 59
            AND (cate.cd_tipo_agendamento in (22,23,24) or (cate.cd_tipo_agendamento = 25 and cate.cd_status_replan = 32))                
            AND cate.ic_ativo = 'S'),0) qt_saldo_by_item ,
            NVL((SELECT SUM(WE.QT_SEMANA) 
            FROM VND.ELO_AGENDAMENTO_WEEK WE
            WHERE WE.CD_ELO_AGENDAMENTO_WEEK = AW.CD_ELO_AGENDAMENTO_WEEK
            ) , 0) qt_semana_by_week               
                          
           
      FROM vnd.elo_carteira ca
     INNER JOIN vnd.elo_agendamento_item ai
        ON ai.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
     INNER JOIN vnd.elo_agendamento_week aw
        ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
     INNER JOIN vnd.elo_agendamento_supervisor ap
     on ap.CD_ELO_AGENDAMENTO_SUPERVISOR = ai.CD_ELO_AGENDAMENTO_SUPERVISOR
     inner join vnd.elo_agendamento age
     on age.cd_elo_agendamento = ap.cd_elo_agendamento 
     WHERE   
       age.cd_elo_status in (8,9)
       AND ca.ic_ativo = 'S'
       AND ai.ic_ativo = 'S'
      -- AND (ca.cd_tipo_agendamento in (22,23,24) or (ca.cd_tipo_agendamento = 25 and ca.cd_status_replan = 32))
      -- AND ca.cd_status_cel_final = 59 
       AND ca.CD_INCOTERMS = 'CIF'
      -- AND ca.QT_AGENDADA_CONFIRMADA > 0 
    )
    
    SELECT 
    cd_elo_carteira, 
    cd_elo_agendamento_item,
    sum(qt_saldo) qt_saldo,
    nu_ordem,
    MAX(qt_saldo_by_item) qt_saldo_by_item, 
    MAX(qt_semana_by_week) qt_semana_by_item
    
    FROM  CTE_ITEM_CARTEIRA_ADJ
     
    
    GROUP BY 
    cd_elo_carteira, 
    cd_elo_agendamento_item,
    nu_ordem
    
    HAVING  ABS(MAX(qt_saldo_by_item) - MAX(qt_semana_by_week)) > 1   --TOLERANCIA DE 1 VOLUME NA QUANTIDADE
    
    ORDER BY 
    cd_elo_agendamento_item 
    ;
    
    CURSOR C_WEEKS (pi_cd_elo_agendamento_item VND.ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_ITEM%TYPE) IS 
    SELECT 
    BEGRP.CD_ELO_AGENDAMENTO_ITEM,
    BEGRP.NU_SEMANA,
    BEGRP.CD_GRUPO_EMBALAGEM,
    BEGRP.QT_SEMANA, 
    BEGRP.CD_WEEK ,
    BEGRP.CD_SITE,
    BEGRP.SITE_TYPE, 
    BEGRP.CD_SALES_OFFICE, 
    BEGRP.CD_SALES_GROUP,
    MIN(BEGRP.minimun_day_for_replan) minimun_day_for_replan
    FROM (
    SELECT 
    WEES.CD_ELO_AGENDAMENTO_ITEM,
    WEES.NU_SEMANA,
    DAYSS.CD_GRUPO_EMBALAGEM, 
    WEES.QT_SEMANA,
    AGE.CD_WEEK,
    CASE 
    WHEN AGE.CD_POLO IS NOT NULL THEN AGE.CD_POLO
    WHEN AGE.CD_CENTRO_EXPEDIDOR IS NOT NULL THEN AGE.CD_CENTRO_EXPEDIDOR
    ELSE AGE.CD_MACHINE END CD_SITE,
    CASE 
    WHEN AGE.CD_POLO IS NOT NULL THEN 'P'
    WHEN AGE.CD_CENTRO_EXPEDIDOR IS NOT NULL THEN 'C'
    ELSE 'M' END SITE_TYPE,             
    SUP.CD_SALES_OFFICE,
    SUP.CD_SALES_GROUP,        
    CASE 
    WHEN ITEM.cd_status_replan IS NOT NULL THEN DAYSS.NU_DIA_SEMANA
    ELSE 1 END minimun_day_for_replan   -- SEGUNDA-FEIRA
    
    FROM VND.ELO_AGENDAMENTO AGE
    INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
    ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO 
    INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
    ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEES
    ON 
    ITEM.CD_ELO_AGENDAMENTO_ITEM = WEES.CD_ELO_AGENDAMENTO_ITEM
    INNER JOIN VND.ELO_AGENDAMENTO_DAY DAYSS
    ON 
    WEES.CD_ELO_AGENDAMENTO_WEEK = DAYSS.CD_ELO_AGENDAMENTO_WEEK
    
    WHERE 
    ITEM.CD_ELO_AGENDAMENTO_ITEM = pi_cd_elo_agendamento_item
    ) BEGRP
    GROUP BY
    BEGRP.CD_ELO_AGENDAMENTO_ITEM,
    BEGRP.NU_SEMANA,
    BEGRP.CD_GRUPO_EMBALAGEM,
    BEGRP.QT_SEMANA, 
    BEGRP.CD_WEEK ,
    BEGRP.CD_SITE,
    BEGRP.SITE_TYPE, 
    BEGRP.CD_SALES_OFFICE, 
    BEGRP.CD_SALES_GROUP--,
    --BEGRP.minimun_day_for_replan;    
    ;
    

    BEGIN
        
        v_count:=0;
        
        OPEN    c_carteira;                               
        FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
        CLOSE   c_carteira;

        V_CART_QT_LINHAS:=t_carteira.COUNT;
        V_LINHA:=1;

        <<main_loop>>
        LOOP

            EXIT WHEN v_count >= V_CART_QT_LINHAS;


            --V_LINHA:=1;
            v_item_new:=t_carteira(V_LINHA).cd_elo_agendamento_item;
            v_item_old:=v_item_new; 
            
            v_qt_saldo_by_item:= t_carteira(V_LINHA).qt_saldo_by_item;    
            --   v_qt_saldo_by_item this is total quantity of week by item  (maximum qt)     
            
            
            LOOP
            
                EXIT WHEN v_count >= V_CART_QT_LINHAS OR not(v_item_new = v_item_old);

                tof_carteira_vol_prog(tof_carteira_vol_prog.COUNT+1).CD_ELO_AGENDAMENTO_ITEM:= t_carteira(V_LINHA).CD_ELO_AGENDAMENTO_ITEM; 
                tof_carteira_vol_prog(tof_carteira_vol_prog.COUNT).qt_agendada_confirmada:= v_qt_saldo_by_item; 
                
                tof_agendamento_item(tof_agendamento_item.COUNT+1).CD_ELO_AGENDAMENTO_ITEM:= t_carteira(V_LINHA).CD_ELO_AGENDAMENTO_ITEM;
                tof_agendamento_item(tof_agendamento_item.COUNT).qt_agendada_confirmada:= v_qt_saldo_by_item;
                
                
                v_count := v_count + 1;
                V_LINHA:=V_LINHA +1;
                IF v_count < V_CART_QT_LINHAS then 
                    v_item_new:=t_carteira(V_LINHA).cd_elo_agendamento_item;
                END IF;
                
                

            END LOOP;
            
        END LOOP main_loop;
        

        
        BEGIN 
        FORALL i_cart in INDICES OF tof_carteira_vol_prog
                UPDATE vnd.elo_agendamento_week wees
                   SET wees.qt_semana = tof_carteira_vol_prog(i_cart).qt_agendada_confirmada
                 WHERE wees.cd_elo_agendamento_item = tof_carteira_vol_prog(i_cart).cd_elo_agendamento_item
                 AND nvl(wees.qt_semana,0) <> tof_carteira_vol_prog(i_cart).qt_agendada_confirmada
                ;
				COMMIT;        
        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.001 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;    
        END;        
        
        
        V_CART_QT_LINHAS:= tof_agendamento_item.COUNT;
        
        IF V_CART_QT_LINHAS > 0 THEN
        BEGIN
        
        FOR i_cart IN 1..  tof_agendamento_item.LAST
        LOOP
        
            BEGIN 
            OPEN    C_WEEKS(tof_agendamento_item(i_cart).cd_elo_agendamento_item);                               
            FETCH   C_WEEKS BULK COLLECT INTO tof_agendamento_day LIMIT v_limit;
            CLOSE   C_WEEKS;
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.002 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
            END;
            
            END;
            
            
            IF tof_agendamento_day.COUNT > 0 THEN 
            BEGIN 
        
                FOR i_day IN 1.. tof_agendamento_day.LAST
                LOOP
                
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT +1).cd_elo_agendamento_item:=tof_agendamento_day(i_day).cd_elo_agendamento_item; 
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).nu_semana:=tof_agendamento_day(i_day).nu_semana;         
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_grupo_embalagem:=tof_agendamento_day(i_day).cd_grupo_embalagem;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).nu_quantidade:=tof_agendamento_day(i_day).nu_quantidade;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_week:=tof_agendamento_day(i_day).cd_week;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_site:=tof_agendamento_day(i_day).cd_site;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).site_type:=tof_agendamento_day(i_day).site_type;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_sales_office:=tof_agendamento_day(i_day).cd_sales_office;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).cd_sales_group:=tof_agendamento_day(i_day).cd_sales_group;
                    tofdaily_agendamento_day_t(tofdaily_agendamento_day_t.COUNT).minimun_day_for_replan:=tof_agendamento_day(i_day).minimun_day_for_replan;
                END LOOP;
                END;
            END IF;
        
        END LOOP;
        
        V_CART_QT_LINHAS:= tofdaily_agendamento_day_t.COUNT;
        
        IF V_CART_QT_LINHAS > 0 THEN
        BEGIN
        
        FOR i_cart IN 1..  tofdaily_agendamento_day_t.LAST
        LOOP  
        
        BEGIN
        VND.GX_ELO_SCHEDULING.pi_agendamento_day_cif(
        P_CD_ELO_AGENDAMENTO_ITEM => tofdaily_agendamento_day_t(i_cart).CD_ELO_AGENDAMENTO_ITEM,
        P_NU_SEMANA => tofdaily_agendamento_day_t(i_cart).NU_SEMANA, 
        P_CD_GRUPO_EMBALAGEM => tofdaily_agendamento_day_t(i_cart).CD_GRUPO_EMBALAGEM, 
        P_NU_QUANTIDADE =>  tofdaily_agendamento_day_t(i_cart).NU_QUANTIDADE, 
        P_CD_WEEK =>  tofdaily_agendamento_day_t(i_cart).CD_WEEK,
        P_CD_SITE =>  tofdaily_agendamento_day_t(i_cart).CD_SITE,
        P_SITE_TYPE =>  tofdaily_agendamento_day_t(i_cart).SITE_TYPE,
        P_CD_SALES_OFFICE =>  tofdaily_agendamento_day_t(i_cart).CD_SALES_OFFICE,        
        P_CD_SALES_GROUP =>  tofdaily_agendamento_day_t(i_cart).CD_SALES_GROUP,
        P_MINIMUN_DAY_FOR_REPLAN =>  tofdaily_agendamento_day_t(i_cart).MINIMUN_DAY_FOR_REPLAN,  
        P_RESULT => p_result

        );
        COMMIT;

        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.003 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
        --ROLLBACK;
        END;
        
        
        
        END;
        
        END LOOP;      
        
        
        END;
        END IF;
        
        
        END; 
        END IF;
        
        


END PU_UPDATE_QT_SEMANA_MONTH_CIF;


PROCEDURE PI_AGENDAMENTO_BATCH
IS 

    CURSOR C_AGENDA IS 
    SELECT 1 CD_ELO_AGENDAMENTO 
    FROM VND.ELO_AGENDAMENTO AGE 
    WHERE 
    AGE.CD_ELO_STATUS IN (6,7)
    AND ROWNUM=1;

    V_LIMIT NUMBER:=100;
    V_CART_QT_LINHAS      NUMBER; 

    TYPE elo_agendamento_r IS RECORD
    (
    cd_elo_agendamento     vnd.elo_agendamento.cd_elo_agendamento%TYPE
    ); 
    
    TYPE elo_agendamento_t IS TABLE OF elo_agendamento_r
    INDEX BY PLS_INTEGER;
    
    tof_agendamento elo_agendamento_t;
    
    p_result         t_cursor;

BEGIN 

    BEGIN 
    OPEN    C_AGENDA;                               
    FETCH   C_AGENDA BULK COLLECT INTO tof_agendamento LIMIT V_LIMIT;
    CLOSE   C_AGENDA;
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.030 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;

    V_CART_QT_LINHAS:= tof_agendamento.COUNT;

    IF V_CART_QT_LINHAS > 0 THEN 
    BEGIN 
        FOR i_cart IN 1..  tof_agendamento.LAST
        LOOP  
            BEGIN
            PU_UPDATE_QT_SEMANA_CIF(
                P_RESULT => p_result
                );
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.031 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
            END;   
            END;     

        END LOOP;

    END;
    END IF;


END PI_AGENDAMENTO_BATCH;

PROCEDURE PI_AGENDAMENTO_BATCH_MONTH
IS 

    CURSOR C_AGENDA IS 
    SELECT 1 CD_ELO_AGENDAMENTO 
    FROM VND.ELO_AGENDAMENTO AGE 
    WHERE 
    AGE.CD_ELO_STATUS IN (8,9)
    AND ROWNUM=1;

    V_LIMIT NUMBER:=100;
    V_CART_QT_LINHAS      NUMBER; 

    TYPE elo_agendamento_r IS RECORD
    (
    cd_elo_agendamento     vnd.elo_agendamento.cd_elo_agendamento%TYPE
    ); 
    
    TYPE elo_agendamento_t IS TABLE OF elo_agendamento_r
    INDEX BY PLS_INTEGER;
    
    tof_agendamento elo_agendamento_t;
    
    p_result         t_cursor;

BEGIN 

    BEGIN 
    OPEN    C_AGENDA;                               
    FETCH   C_AGENDA BULK COLLECT INTO tof_agendamento LIMIT V_LIMIT;
    CLOSE   C_AGENDA;
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.040 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;

    V_CART_QT_LINHAS:= tof_agendamento.COUNT;

    IF V_CART_QT_LINHAS > 0 THEN 
    BEGIN 
        FOR i_cart IN 1..  tof_agendamento.LAST
        LOOP  
            BEGIN
            PU_UPDATE_QT_SEMANA_MONTH_CIF(
                P_RESULT => p_result
                );
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.041 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
            END;   
            END;     

        END LOOP;

    END;
    END IF;


END PI_AGENDAMENTO_BATCH_MONTH;


PROCEDURE PI_AGENDAMENTO_WEEKDAY_FROZZEN
IS 

    CURSOR C_AGENDA IS 
    
    WITH CTE_FROZZEN AS (
    SELECT SUP.CD_ELO_AGENDAMENTO
    FROM VND.ELO_AGENDAMENTO_SUPERVISOR SUP
    INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
    ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN VND.ELO_AGENDAMENTO_WEEK_FROZZEN WEFR 
    ON ITEM.CD_ELO_AGENDAMENTO_ITEM = WEFR.CD_ELO_AGENDAMENTO_ITEM 
    WHERE 
    WEFR.CD_ELO_STATUS_FROZZEN = 3
    AND WEFR.DH_ULT_ALTERACAO > (SYSDATE - 365)
    GROUP BY 
    SUP.CD_ELO_AGENDAMENTO
    )
    
    SELECT DISTINCT AGE.CD_ELO_AGENDAMENTO 
    FROM VND.ELO_AGENDAMENTO AGE 
    LEFT JOIN CTE_FROZZEN FR
    ON AGE.CD_ELO_AGENDAMENTO = FR.CD_ELO_AGENDAMENTO 
    
    WHERE 
    AGE.CD_ELO_STATUS in( 3, 4, 5) AND 
    FR.CD_ELO_AGENDAMENTO IS NULL;

    V_LIMIT NUMBER:=10000;
    V_CART_QT_LINHAS      NUMBER; 

    TYPE elo_agendamento_r IS RECORD
    (
    cd_elo_agendamento     vnd.elo_agendamento.cd_elo_agendamento%TYPE
    ); 
    
    TYPE elo_agendamento_t IS TABLE OF elo_agendamento_r
    INDEX BY PLS_INTEGER;
    
    tof_agendamento elo_agendamento_t;


BEGIN 

    BEGIN 
    OPEN    C_AGENDA;                               
    FETCH   C_AGENDA BULK COLLECT INTO tof_agendamento LIMIT V_LIMIT;
    CLOSE   C_AGENDA;
    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.022 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;

    V_CART_QT_LINHAS:= tof_agendamento.COUNT;

    IF V_CART_QT_LINHAS > 0 THEN 
    BEGIN 
        FOR i_cart IN 1..  tof_agendamento.LAST
        LOOP  
        BEGIN
        PI_AGENDAMENTO_WEEKDAY_FROZZEN(
            P_CD_ELO_AGENDAMENTO=> tof_agendamento(i_cart).CD_ELO_AGENDAMENTO
            );
        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.023 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
        --ROLLBACK;
        END;            
            
            
        END;
        
        END LOOP;

    END;
    END IF;


END PI_AGENDAMENTO_WEEKDAY_FROZZEN;




PROCEDURE PI_AGENDAMENTO_WEEKDAY_FROZZEN
(
P_CD_ELO_AGENDAMENTO IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE 
)
IS 

V_CD_ELO_STATUS_FROZZEN VND.ELO_STATUS.CD_ELO_STATUS%TYPE;
V_BATCH_ID VARCHAR2(10);
V_CD_ELO_AGENDAMENTO  VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE;

BEGIN 

BEGIN
SELECT 
AGE.CD_ELO_STATUS INTO V_CD_ELO_STATUS_FROZZEN
FROM VND.ELO_AGENDAMENTO AGE 
WHERE 
AGE.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO;
EXCEPTION  
WHEN OTHERS THEN 
BEGIN
RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.004 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
--ROLLBACK;
END;

END;

IF V_CD_ELO_STATUS_FROZZEN IN (4,5)  THEN 
--ESTE PROCESSO TEM COMO OBJETIVO TIRAR A FOTO DO AGENDAMENTO NO STATUS 3 
--MAS COMO O STATUS 3 PODE ACONTECER EM HORAS E PODE IR PARA O STATUS 4 OU 5 
-- ENTAO É TIRADA A FOTO E COLOCADO NO STATUS 3

    BEGIN

    SELECT SUP.CD_ELO_AGENDAMENTO INTO V_CD_ELO_AGENDAMENTO
    FROM VND.ELO_AGENDAMENTO_SUPERVISOR SUP
    INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
    ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN VND.ELO_AGENDAMENTO_WEEK_FROZZEN WEFR 
    ON ITEM.CD_ELO_AGENDAMENTO_ITEM = WEFR.CD_ELO_AGENDAMENTO_ITEM 
    WHERE 
    WEFR.CD_ELO_STATUS_FROZZEN = 3
    AND WEFR.DH_ULT_ALTERACAO > (SYSDATE - 365)
    AND SUP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO;

    EXCEPTION  
    WHEN no_data_found THEN 
    BEGIN
    V_CD_ELO_STATUS_FROZZEN:=3; 
    END;
    WHEN others THEN 
    BEGIN
    V_CD_ELO_STATUS_FROZZEN:=3; 
    END;

    END;

    IF V_CD_ELO_STATUS_FROZZEN <> 3 AND V_CD_ELO_AGENDAMENTO IS NULL THEN
        V_CD_ELO_STATUS_FROZZEN:=3;
    END IF; 

END IF;



V_BATCH_ID:='BA' || TO_CHAR(CURRENT_DATE, 'YYMMDDHH') ;


BEGIN 

INSERT INTO VND.ELO_AGENDAMENTO_WEEK_FROZZEN
(
  BATCH_ID ,
  CD_ELO_STATUS_FROZZEN  ,
  CD_ELO_AGENDAMENTO_WEEK ,
  CD_ELO_AGENDAMENTO_ITEM ,
  NU_SEMANA ,
  QT_COTA ,
  QT_SEMANA  ,
  QT_EMERGENCIAL ,
  DH_ULT_ALTERACAO   

)

SELECT 

  V_BATCH_ID  BATCH_ID ,
  V_CD_ELO_STATUS_FROZZEN CD_ELO_STATUS_FROZZEN  ,
  WEES.CD_ELO_AGENDAMENTO_WEEK ,
  WEES.CD_ELO_AGENDAMENTO_ITEM ,
  WEES.NU_SEMANA ,
  WEES.QT_COTA ,
  WEES.QT_SEMANA  ,
  WEES.QT_EMERGENCIAL ,
  CURRENT_DATE DH_ULT_ALTERACAO 

FROM VND.ELO_AGENDAMENTO_WEEK WEES 
WHERE 
EXISTS (SELECT 1 FROM VND.ELO_AGENDAMENTO AGE 
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO 
INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
WHERE
AGE.IC_ATIVO = 'S' 
--AND AGE.CD_ELO_STATUS IN (2,3)
AND AGE.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
AND WEES.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM)
;
COMMIT;
EXCEPTION  
WHEN OTHERS THEN 
BEGIN
RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.006 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
ROLLBACK;
END;

END;


BEGIN 

INSERT INTO VND.ELO_AGENDAMENTO_DAY_FROZZEN
(

  BATCH_ID ,
  CD_ELO_STATUS_FROZZEN ,
  CD_ELO_AGENDAMENTO_DAY ,
  CD_ELO_AGENDAMENTO_WEEK ,
  NU_DIA_SEMANA ,
  CD_GRUPO_EMBALAGEM ,
  NU_QUANTIDADE  , 
  DH_ULT_ALTERACAO  

)

SELECT 

  V_BATCH_ID  BATCH_ID ,
  V_CD_ELO_STATUS_FROZZEN CD_ELO_STATUS_FROZZEN  ,
  DDAYS.CD_ELO_AGENDAMENTO_DAY ,
  DDAYS.CD_ELO_AGENDAMENTO_WEEK ,
  DDAYS.NU_DIA_SEMANA ,
  DDAYS.CD_GRUPO_EMBALAGEM ,
  DDAYS.NU_QUANTIDADE  , 
  CURRENT_DATE DH_ULT_ALTERACAO 
  
FROM VND.ELO_AGENDAMENTO_DAY DDAYS
WHERE 
EXISTS (SELECT 1 FROM VND.ELO_AGENDAMENTO AGE 
INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
ON AGE.CD_ELO_AGENDAMENTO = SUP.CD_ELO_AGENDAMENTO 
INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
ON SUP.CD_ELO_AGENDAMENTO_SUPERVISOR = ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEES
ON WEES.CD_ELO_AGENDAMENTO_ITEM = ITEM.CD_ELO_AGENDAMENTO_ITEM
WHERE
AGE.IC_ATIVO = 'S' 
--AND AGE.CD_ELO_STATUS IN (2,3)
AND AGE.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
AND WEES.CD_ELO_AGENDAMENTO_WEEK = DDAYS.CD_ELO_AGENDAMENTO_WEEK)
;
COMMIT;
EXCEPTION  
WHEN OTHERS THEN 
BEGIN
RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.008 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
ROLLBACK;
END;

END;


END PI_AGENDAMENTO_WEEKDAY_FROZZEN;


END GX_ELO_BATCH_ISSUE;
/