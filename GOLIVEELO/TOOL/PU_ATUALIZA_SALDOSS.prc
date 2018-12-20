CREATE OR REPLACE PROCEDURE VND.PU_ATUALIZA_SALDOSS(
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_RETORNO               OUT VND.GX_ELO_FACTORY.t_cursor)
    
    IS
    
   -- v_count number;
   -- v_count_ag number;
    --iNU_QUANTIDADE              VND.PEDIDO.NU_QUANTIDADE%TYPE;
    --iNU_QUANTIDADE_ENTREGUE     VND.PEDIDO.NU_QUANTIDADE_ENTREGUE%TYPE;
   -- iNU_QUANTIDADE_SALDO        VND.PEDIDO.NU_QUANTIDADE_SALDO%TYPE;
    V_TRAVA VARCHAR2(1):='N';
    
    V_HOUVE_REFRESH VARCHAR2(1):='N';
    
    V_LIMIT NUMBER:=11000;
    
    V_CD_ELO_AGENDAMENTO VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE;
 
    
    CURSOR C_CARTEIRA (PI_CD_ELO_AGENDAMENTO VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE ) IS  
    SELECT EC.NU_ORDEM_VENDA, EC.CD_ITEM_PEDIDO, EC.CD_ELO_CARTEIRA, EC.QT_AGENDADA_REFRESH, EC.QT_AGENDADA_CONFIRMADA
    FROM VND.ELO_CARTEIRA EC
    
    WHERE 
    EC.QT_AGENDADA_CONFIRMADA > 0
    AND EC.CD_ELO_AGENDAMENTO = PI_CD_ELO_AGENDAMENTO;
    
    
    TYPE elo_carteira_r IS RECORD
    (
    NU_ORDEM_VENDA     VND.ELO_CARTEIRA.NU_ORDEM_VENDA%TYPE,
    CD_ITEM_PEDIDO   VND.ELO_CARTEIRA.CD_ITEM_PEDIDO%TYPE,
    CD_ELO_CARTEIRA VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE, 
    QT_AGENDADA_REFRESH  VND.ELO_CARTEIRA.QT_AGENDADA_REFRESH%TYPE,
    QT_AGENDADA_CONFIRMADA VND.ELO_CARTEIRA.QT_AGENDADA_REFRESH%TYPE

    ); 

    TYPE elo_carteira_t IS TABLE OF elo_carteira_r
    INDEX BY PLS_INTEGER;
    tof_elo_carteira elo_carteira_t;


   -- C_LINHA C_CARTEIRA%ROWTYPE;
    
    CURSOR C_PEDIDO (PI_CD_ELO_CARTEIRA VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
                     PI_QT_AGENDADA_CONFIRMADA VND.ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA%TYPE,
                    PI_NU_ORDEM_VENDA VND.PEDIDO.NU_ORDEM_VENDA%TYPE) IS
    SELECT      PI_CD_ELO_CARTEIRA CD_ELO_CARTEIRA, 
                PI_QT_AGENDADA_CONFIRMADA QT_AGENDADA_CONFIRMADA
                , SUM(NVL(PED.NU_QUANTIDADE, 0))
                , SUM(NVL(PED.NU_QUANTIDADE_ENTREGUE, 0))
                , SUM(NVL(PED.NU_QUANTIDADE_SALDO, 0))
                

    FROM        VND.PEDIDO PED
    WHERE       
        --PED.CD_ITEM_PEDIDO = C_LINHA.CD_ITEM_PEDIDO
    --AND 
    PED.NU_ORDEM_VENDA = PI_NU_ORDEM_VENDA;   
    
    TYPE elo_pedido_r IS RECORD
    (
    CD_ELO_CARTEIRA     VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
    QT_AGENDADA_CONFIRMADA     VND.ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA%TYPE,    
    NU_QUANTIDADE   VND.PEDIDO.NU_QUANTIDADE%TYPE,
    NU_QUANTIDADE_ENTREGUE VND.PEDIDO.NU_QUANTIDADE_ENTREGUE%TYPE, 
    NU_QUANTIDADE_SALDO  VND.PEDIDO.NU_QUANTIDADE_SALDO%TYPE

    ); 

    TYPE elo_pedido_t IS TABLE OF elo_pedido_r
    INDEX BY PLS_INTEGER;
    tof_elo_pedido elo_pedido_t;
    
    tof_elo_pedido_all elo_pedido_t;
    
    TYPE elo_agendamento_r IS RECORD
    (
    CD_ELO_AGENDAMENTO     VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE
    ); 

    TYPE elo_agendamento_t IS TABLE OF elo_agendamento_r
    INDEX BY PLS_INTEGER;
    tof_elo_agendamento elo_agendamento_t;    
    
    
    


    PROCEDURE FOUND_AGENDAMENTO 
    ( PI_CD_ELO_AGENDAMENTO OUT VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE) IS
    
        CURSOR C_AGENDAMENTO IS
        SELECT EA.CD_ELO_AGENDAMENTO 
        FROM VND.ELO_AGENDAMENTO EA 
        WHERE EA.CD_WEEK = P_CD_WEEK
        AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
        AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
        AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE)
        AND EA.CD_ELO_STATUS = 6;       
    
    
    BEGIN
    
        OPEN    C_AGENDAMENTO ;  
        BEGIN 
        FETCH  C_AGENDAMENTO BULK COLLECT INTO tof_elo_agendamento LIMIT 1;
        CLOSE   C_AGENDAMENTO;

        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        BEGIN
            PI_CD_ELO_AGENDAMENTO:=NULL;
        END;
         
        WHEN OTHERS THEN 
        BEGIN
            PI_CD_ELO_AGENDAMENTO:=NULL;
        END;

        END;
        
        IF tof_elo_agendamento.COUNT > 0 THEN 
            PI_CD_ELO_AGENDAMENTO:= tof_elo_agendamento(1).CD_ELO_AGENDAMENTO; 
        
        END IF;
        
    
    END FOUND_AGENDAMENTO;
 


   PROCEDURE FOUND_PEDIDO (PI_CD_ELO_CARTEIRA VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
                            PI_QT_AGENDADA_CONFIRMADA VND.ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA%TYPE, 
                            PI_NU_ORDEM_VENDA VND.PEDIDO.NU_ORDEM_VENDA%TYPE) IS
    
    V_ACHOU_PED VARCHAR2(1):='N';

    BEGIN
    
            
        OPEN    C_PEDIDO (PI_CD_ELO_CARTEIRA, 
                          PI_QT_AGENDADA_CONFIRMADA,
                            PI_NU_ORDEM_VENDA);  

        BEGIN 
                                 
        FETCH  C_PEDIDO BULK COLLECT INTO tof_elo_pedido LIMIT 1;
        CLOSE   C_PEDIDO;

        EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
            V_ACHOU_PED:='N';
        END;

        END;
        
        IF tof_elo_pedido.COUNT >0 THEN
            IF tof_elo_pedido(1).NU_QUANTIDADE IS NOT NULL OR 
                tof_elo_pedido(1).NU_QUANTIDADE_ENTREGUE IS NOT NULL OR 
                tof_elo_pedido(1).NU_QUANTIDADE_SALDO IS NOT NULL  THEN 
                
                IF (tof_elo_pedido(1).NU_QUANTIDADE_SALDO < tof_elo_pedido(1).QT_AGENDADA_CONFIRMADA) 
                    AND (tof_elo_pedido(1).NU_QUANTIDADE_SALDO > 0)
                    THEN 
                    tof_elo_pedido(1).QT_AGENDADA_CONFIRMADA:= tof_elo_pedido(1).NU_QUANTIDADE_SALDO;
                END IF;     
                --= CASE WHEN iNU_QUANTIDADE_SALDO < EC.QT_AGENDADA_CONFIRMADA THEN iNU_QUANTIDADE_SALDO ELSE EC.QT_AGENDADA_CONFIRMADA END
                
                  
                tof_elo_pedido_all(tof_elo_pedido_all.COUNT+1):=tof_elo_pedido(1);
                
            END IF;
            tof_elo_pedido.DELETE;
        END IF;
    
    END FOUND_PEDIDO; 
    
    
    BEGIN
    

    BEGIN
        FOUND_AGENDAMENTO(V_CD_ELO_AGENDAMENTO);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_CD_ELO_AGENDAMENTO:=NULL;
    WHEN OTHERS THEN 
    BEGIN
        V_CD_ELO_AGENDAMENTO:=NULL;
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_FACTORY.402 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    
    END;        
    
    END;    
    
    IF V_CD_ELO_AGENDAMENTO IS NOT NULL THEN 
    

    OPEN    C_CARTEIRA (V_CD_ELO_AGENDAMENTO);  
    
    BEGIN 
                             
    FETCH  C_CARTEIRA BULK COLLECT INTO tof_elo_carteira LIMIT V_LIMIT;
    CLOSE   C_CARTEIRA;

    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_FACTORY.403 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;    
    
    END IF;
    
    
    IF tof_elo_carteira.COUNT > 0 THEN 
    BEGIN

        FOR i_cartT in tof_elo_carteira.FIRST .. tof_elo_carteira.LAST
        LOOP
            V_TRAVA:='N';
                BEGIN
                FOUND_PEDIDO (tof_elo_carteira(i_cartT).CD_ELO_CARTEIRA, 
                                  tof_elo_carteira(i_cartT).QT_AGENDADA_CONFIRMADA,
                                    tof_elo_carteira(i_cartT).NU_ORDEM_VENDA);  
                EXCEPTION  
                WHEN OTHERS THEN 
                BEGIN
                RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_FACTORY.404 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                --ROLLBACK;
                END;

                END;

        END LOOP; 
        
    END;
    END IF;
    
    IF tof_elo_pedido_all.COUNT > 0 THEN  
        BEGIN

        FORALL i_cart_ped in indices of tof_elo_pedido_all

        -- ALTERADO POR SOLICITAÇÃO DE PAULO KALIL EM 19/01/2017
        -- SE UM DOS VALORES FOR NULL, DESPREZA A ATUALIZACAO
        --IF (iNU_QUANTIDADE IS NOT NULL OR iNU_QUANTIDADE_ENTREGUE IS NOT NULL OR iNU_QUANTIDADE_SALDO IS NOT NULL) THEN
        -- BEGIN

        -- ATUALIZA A CARTEIRA 
        UPDATE      VND.ELO_CARTEIRA EC
        SET         EC.CD_USUARIO_REFRESH = 4198
        , EC.DH_REFRESH = CURRENT_DATE
        , EC.QT_PROGRAMADA_REFRESH = tof_elo_pedido_all(i_cart_ped).NU_QUANTIDADE
        , EC.QT_ENTREGUE_REFRESH = tof_elo_pedido_all(i_cart_ped).NU_QUANTIDADE_ENTREGUE
        , EC.QT_SALDO_REFRESH = tof_elo_pedido_all(i_cart_ped).NU_QUANTIDADE_SALDO
        --, EC.QT_AGENDADA_CONFIRMADA = CASE WHEN iNU_QUANTIDADE_SALDO < EC.QT_AGENDADA_CONFIRMADA THEN iNU_QUANTIDADE_SALDO ELSE EC.QT_AGENDADA_CONFIRMADA END
        , EC.QT_AGENDADA_CONFIRMADA = tof_elo_pedido_all(i_cart_ped).QT_AGENDADA_CONFIRMADA
        , EC.DS_VERSAO = SUBSTR(NVL(EC.DS_VERSAO, ' '), 1,3500 ) || SUBSTR(  '[{"ID": 0002, "APP": "GX_ELO_FACTORY.PU_ATUALIZA_SALDO",' || 
        '"PROPERTIE": [{"NAME": "QT_AGENDADA_CONFIRMADA_C_LINHA", "VAL":' || NVL(TO_CHAR(tof_elo_pedido_all(i_cart_ped).QT_AGENDADA_CONFIRMADA), 'NULL') || '},' ||
        '{"NAME": "QT_PROGRAMADA_REFRESH", "VAL":' || TO_CHAR(tof_elo_pedido_all(i_cart_ped).NU_QUANTIDADE) ||  '},' ||
        '{"NAME": "QT_ENTREGUE_REFRESH", "VAL":' || TO_CHAR(tof_elo_pedido_all(i_cart_ped).NU_QUANTIDADE_ENTREGUE) ||  '},' ||
        '{"NAME": "QT_SALDO_REFRESH", "VAL":' || TO_CHAR(tof_elo_pedido_all(i_cart_ped).NU_QUANTIDADE_SALDO) || '},' ||
        '], "DH_ULT_MOD": ' || TO_CHAR(CURRENT_DATE) || ' }],' ,1, 500)
        WHERE       EC.CD_ELO_CARTEIRA = tof_elo_pedido_all(i_cart_ped).CD_ELO_CARTEIRA;

        COMMIT;            

        V_HOUVE_REFRESH:='S';

        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        BEGIN
        V_TRAVA:= 'S';
        ROLLBACK;
        END;
        WHEN OTHERS THEN 
        BEGIN
        V_TRAVA:= 'S';
        ROLLBACK;
        END;
        
        END;


    END IF;

    tof_elo_pedido_all.DELETE;
    
    IF V_HOUVE_REFRESH = 'S' THEN 
        BEGIN
        -- ATUALIZA ELO_AGENDAMENTO
        UPDATE VND.ELO_AGENDAMENTO EA
        SET EA.DH_REFRESH = CURRENT_DATE
        WHERE 
        EA.CD_ELO_AGENDAMENTO = V_CD_ELO_AGENDAMENTO;
     
        COMMIT;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        BEGIN
        V_TRAVA:= 'S';
        ROLLBACK;
        END;
        WHEN OTHERS THEN 
        BEGIN
        V_TRAVA:= 'S';
        ROLLBACK;
        END;
        
        END;                
    
    END IF;
    
    
    BEGIN
    VND.GX_ELO_FACTORY.PU_ATUALIZA_CAPACIDADE(
            P_CD_POLO   ,           
        P_CD_CENTRO_EXPEDIDOR  , 
        P_CD_MACHINE    ,       
        P_CD_WEEK   );  
    EXCEPTION
    WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(
        -20001,
        'ERRO ENCONTRADO - '
         || SQLCODE
         || ' -ERROR- '
         || SQLERRM
    );
    END;
        
    DBMS_SESSION.free_unused_user_memory;    
    
    OPEN P_RETORNO FOR
    SELECT '1' AS P_SUCESSO
    FROM DUAL;
    
    
    EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            OPEN P_RETORNO FOR
            SELECT '0' AS P_SUCESSO
            FROM DUAL;
            ROLLBACK;
        END;
    
    END PU_ATUALIZA_SALDOSS;
/