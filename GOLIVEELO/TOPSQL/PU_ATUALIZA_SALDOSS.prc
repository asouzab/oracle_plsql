CREATE    PROCEDURE PU_ATUALIZA_SALDOSS(
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_RETORNO               OUT t_cursor)
    
    IS
    
    v_count number;
    v_count_ag number;
    iNU_QUANTIDADE              VND.PEDIDO.NU_QUANTIDADE%TYPE;
    iNU_QUANTIDADE_ENTREGUE     VND.PEDIDO.NU_QUANTIDADE_ENTREGUE%TYPE;
    iNU_QUANTIDADE_SALDO        VND.PEDIDO.NU_QUANTIDADE_SALDO%TYPE;
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
   
    

    C_LINHA C_CARTEIRA%ROWTYPE;
    
    BEGIN
    
    SELECT COUNT(1) INTO v_count_ag
    FROM VND.ELO_AGENDAMENTO EA 
    WHERE EA.CD_WEEK = P_CD_WEEK
    AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
    AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
    AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE);    
    
    
    IF v_count_ag > 0 THEN 

        SELECT EA.CD_ELO_AGENDAMENTO INTO V_CD_ELO_AGENDAMENTO
        FROM VND.ELO_AGENDAMENTO EA 
        WHERE EA.CD_WEEK = P_CD_WEEK
        AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
        AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
        AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE);      

    END IF;
    

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
    
    IF tof_elo_carteira.COUNT > 0 THEN 
    BEGIN

    FOR i_cartT in tof_elo_carteira.FIRST .. tof_elo_carteira.LAST
    LOOP
    --FETCH C_CARTEIRA into C_LINHA;
    
    
        V_TRAVA:='N';
    
        v_count := 0;
        BEGIN
        SELECT NVL(COUNT(cd_pedido),0) INTO v_count
        FROM VND.PEDIDO 
        WHERE 
        --CD_ITEM_PEDIDO = C_LINHA.CD_ITEM_PEDIDO
        --AND 
        NU_ORDEM_VENDA =tof_elo_carteira(i_cartT).NU_ORDEM_VENDA;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        v_count:= 0;
        WHEN OTHERS THEN 
        v_count:=0;
        
        END;        
        
        IF v_count > 0 THEN
        
            BEGIN
            SELECT      SUM(NVL(PED.NU_QUANTIDADE, 0))
                        , SUM(NVL(PED.NU_QUANTIDADE_ENTREGUE, 0))
                        , SUM(NVL(PED.NU_QUANTIDADE_SALDO, 0))
            INTO        iNU_QUANTIDADE
                        , iNU_QUANTIDADE_ENTREGUE
                        , iNU_QUANTIDADE_SALDO
            FROM        VND.PEDIDO PED
            WHERE       
                --PED.CD_ITEM_PEDIDO = C_LINHA.CD_ITEM_PEDIDO
            --AND 
            PED.NU_ORDEM_VENDA = tof_elo_carteira(i_cartT).NU_ORDEM_VENDA;
            --AND ROWNUM = 1;
            EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            iNU_QUANTIDADE:= NULL;
            WHEN OTHERS THEN 
            iNU_QUANTIDADE:=NULL;
            
            END;            

            -- ALTERADO POR SOLICITAÇÃO DE PAULO KALIL EM 19/01/2017
            -- SE UM DOS VALORES FOR NULL, DESPREZA A ATUALIZACAO
            IF (iNU_QUANTIDADE IS NOT NULL OR iNU_QUANTIDADE_ENTREGUE IS NOT NULL OR iNU_QUANTIDADE_SALDO IS NOT NULL) THEN
                BEGIN
                    BEGIN
                    -- ATUALIZA A CARTEIRA 
                    UPDATE      VND.ELO_CARTEIRA EC
                    SET         EC.CD_USUARIO_REFRESH = 4198
                                , EC.DH_REFRESH = CURRENT_DATE
                                , EC.QT_PROGRAMADA_REFRESH = iNU_QUANTIDADE
                                , EC.QT_ENTREGUE_REFRESH = iNU_QUANTIDADE_ENTREGUE
                                , EC.QT_SALDO_REFRESH = iNU_QUANTIDADE_SALDO
                                , EC.QT_AGENDADA_CONFIRMADA = CASE WHEN iNU_QUANTIDADE_SALDO < EC.QT_AGENDADA_CONFIRMADA THEN iNU_QUANTIDADE_SALDO ELSE EC.QT_AGENDADA_CONFIRMADA END
                                , EC.DS_VERSAO = SUBSTR(NVL(EC.DS_VERSAO, ' '), 1,3500 ) || SUBSTR(  '[{"ID": 0002, "APP": "GX_ELO_FACTORY.PU_ATUALIZA_SALDO",' || 
                                '"PROPERTIE": [{"NAME": "QT_AGENDADA_CONFIRMADA_C_LINHA", "VAL":' || NVL(TO_CHAR(C_LINHA.QT_AGENDADA_CONFIRMADA), 'NULL') || '},' ||
                                '{"NAME": "QT_PROGRAMADA_REFRESH", "VAL":' || TO_CHAR(iNU_QUANTIDADE) ||  '},' ||
                                '{"NAME": "QT_ENTREGUE_REFRESH", "VAL":' || TO_CHAR(iNU_QUANTIDADE_ENTREGUE) ||  '},' ||
                                '{"NAME": "QT_SALDO_REFRESH", "VAL":' || TO_CHAR(iNU_QUANTIDADE_SALDO) || '},' ||
                                
                                        '], "DH_ULT_MOD": ' || TO_CHAR(CURRENT_DATE) || ' }],' ,1, 500)

                                
                    WHERE       EC.CD_ELO_CARTEIRA = tof_elo_carteira(i_cartT).CD_ELO_CARTEIRA;
                    --AND         EC.CD_ITEM_PEDIDO = C_LINHA.CD_ITEM_PEDIDO;
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
                
                
                END;
            END IF;
        END IF;
    END LOOP;
    
    
    END;
    END IF;
    
    IF V_HOUVE_REFRESH = 'S' THEN 
        BEGIN
        -- ATUALIZA ELO_AGENDAMENTO
        UPDATE VND.ELO_AGENDAMENTO EA
        SET EA.DH_REFRESH = CURRENT_DATE
        WHERE 
        EA_CD_ELO_AGENDAMENTO = V_ELO_AGENDAMENTO;
     
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
    PU_ATUALIZA_CAPACIDADE(
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
    
