CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_REPLAN_PROCESS AS

    --EXEMPLO DE USO "SELECT * FROM TABLE(GX_NOTA_FISCAL_V2.SPLIT('1;2;3;4;5;6;7;8;9',';'))"
    FUNCTION FX_SPLIT(P_LISTA       VARCHAR2,
                                 P_DELIMITADOR VARCHAR2 := ',') RETURN T_VET_RETORNO
        PIPELINED IS
        LISTA_INDEX PLS_INTEGER;
        LISTA       VARCHAR2(32767) := P_LISTA;

    BEGIN
        LOOP
            LISTA_INDEX := INSTR(LISTA,
                                                     P_DELIMITADOR);
            IF LISTA_INDEX > 0 THEN
                PIPE ROW(SUBSTR(LISTA,
                                                1,
                                                LISTA_INDEX - 1));
                LISTA := SUBSTR(LISTA,
                                                LISTA_INDEX + LENGTH(P_DELIMITADOR));
            ELSE
                PIPE ROW(LISTA);
                EXIT;
            END IF;
        END LOOP;
        RETURN;
    END FX_SPLIT;
    


    FUNCTION FX_SPLIT2 (
        LIST        IN VARCHAR2,
        DELIMITER   IN VARCHAR2 DEFAULT ','
    ) RETURN SPLIT_TBL AS

        SPLITTED   SPLIT_TBL := SPLIT_TBL ();
        I          PLS_INTEGER := 0;
        LIST_      VARCHAR2(16000) := LIST;
    BEGIN
        LOOP
            I := INSTR(LIST_,DELIMITER);
            IF
                I > 0
            THEN
                SPLITTED.EXTEND(1);
                SPLITTED(SPLITTED.LAST) := SUBSTR(
                    LIST_,
                    1,
                    I - 1
                );

                LIST_ := SUBSTR(
                    LIST_,
                    I + LENGTH(DELIMITER)
                );
            ELSE
                SPLITTED.EXTEND(1);
                SPLITTED(SPLITTED.LAST) := LIST_;
                RETURN SPLITTED;
            END IF;

        END LOOP;
    END FX_SPLIT2;
    


    PROCEDURE PX_REPLAN_BASIC_DATA (
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_RETORNO               OUT T_CURSOR,
        P_PRODUTO               OUT T_CURSOR,
        P_INCOTERMS             OUT T_CURSOR,
        P_SUPERVISORS           OUT T_CURSOR
    )
    AS 
    BEGIN
  
        OPEN P_RETORNO FOR
        SELECT DISTINCT 
               AI.CD_CLIENTE,
               CASE WHEN AI.CD_INCOTERMS = 'FOB' THEN CA.NO_CLIENTE_PAGADOR
                    ELSE CA.NO_CLIENTE_RECEBEDOR
               END AS NO_CLIENTE
          FROM VND.ELO_AGENDAMENTO_ITEM AI
         INNER JOIN VND.ELO_CARTEIRA CA
            ON CA.CD_ELO_AGENDAMENTO_ITEM = AI.CD_ELO_AGENDAMENTO_ITEM
         INNER JOIN VND.ELO_AGENDAMENTO AG
            ON CA.CD_ELO_AGENDAMENTO = AG.CD_ELO_AGENDAMENTO
         WHERE (P_CD_POLO IS NULL OR AG.CD_POLO = P_CD_POLO)
           AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           AND (P_CD_MACHINE IS NULL OR AG.CD_MACHINE = P_CD_MACHINE)
           AND AG.CD_WEEK = P_CD_WEEK
           AND CA.CD_TIPO_AGENDAMENTO IS NOT NULL
         ORDER BY 2
        ; 

        OPEN P_PRODUTO FOR
        SELECT DISTINCT 
               AI.CD_PRODUTO_SAP,
               CA.NO_PRODUTO_SAP,
               TO_CHAR(TO_NUMBER(AI.CD_PRODUTO_SAP)) || ' - ' || CA.NO_PRODUTO_SAP CD_NO_PRODUTO_SAP
          FROM VND.ELO_AGENDAMENTO_ITEM AI
         INNER JOIN VND.ELO_CARTEIRA CA
            ON CA.CD_ELO_AGENDAMENTO_ITEM = AI.CD_ELO_AGENDAMENTO_ITEM
           AND AI.CD_PRODUTO_SAP = CA.CD_PRODUTO_SAP
         INNER JOIN VND.ELO_AGENDAMENTO AG
            ON CA.CD_ELO_AGENDAMENTO = AG.CD_ELO_AGENDAMENTO
         WHERE (P_CD_POLO IS NULL OR AG.CD_POLO = P_CD_POLO)
           AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           AND (P_CD_MACHINE IS NULL OR AG.CD_MACHINE = P_CD_MACHINE)
           AND AG.CD_WEEK = P_CD_WEEK
           AND CA.CD_TIPO_AGENDAMENTO IS NOT NULL
         ORDER BY CA.NO_PRODUTO_SAP
        ; 

        OPEN P_INCOTERMS FOR
        SELECT DISTINCT
               AI.CD_INCOTERMS
          FROM VND.ELO_AGENDAMENTO_ITEM AI
         INNER JOIN VND.ELO_CARTEIRA CA
            ON CA.CD_ELO_AGENDAMENTO_ITEM = AI.CD_ELO_AGENDAMENTO_ITEM
         INNER JOIN VND.ELO_AGENDAMENTO AG
            ON CA.CD_ELO_AGENDAMENTO = AG.CD_ELO_AGENDAMENTO
         WHERE (P_CD_POLO IS NULL OR AG.CD_POLO = P_CD_POLO)
           AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           AND (P_CD_MACHINE IS NULL OR AG.CD_MACHINE = P_CD_MACHINE)
           AND AG.CD_WEEK = P_CD_WEEK
           AND CA.CD_TIPO_AGENDAMENTO IS NOT NULL
         ORDER BY AI.CD_INCOTERMS
        ; 

        OPEN P_SUPERVISORS FOR
        SELECT DISTINCT 
               AP.CD_SALES_GROUP,
               CA.NO_SALES_GROUP,
               AP.CD_SALES_GROUP || ' - ' || CA.NO_SALES_GROUP CD_NO_SALES_GROUP
          FROM VND.ELO_AGENDAMENTO_SUPERVISOR AP
         INNER JOIN VND.ELO_AGENDAMENTO_ITEM AI
            ON AP.CD_ELO_AGENDAMENTO_SUPERVISOR = AI.CD_ELO_AGENDAMENTO_SUPERVISOR
         INNER JOIN VND.ELO_AGENDAMENTO_WEEK AW
            ON AW.CD_ELO_AGENDAMENTO_ITEM = AI.CD_ELO_AGENDAMENTO_ITEM
         INNER JOIN VND.ELO_AGENDAMENTO AG
            ON AG.CD_ELO_AGENDAMENTO = AP.CD_ELO_AGENDAMENTO
         INNER JOIN VND.ELO_CARTEIRA CA
            ON CA.CD_ELO_AGENDAMENTO = AG.CD_ELO_AGENDAMENTO
           AND CA.CD_SALES_GROUP = AP.CD_SALES_GROUP
         WHERE (P_CD_POLO IS NULL OR AG.CD_POLO = P_CD_POLO)
           AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           AND (P_CD_MACHINE IS NULL OR AG.CD_MACHINE = P_CD_MACHINE)
           AND AG.CD_WEEK = P_CD_WEEK
           AND CA.CD_TIPO_AGENDAMENTO IS NOT NULL
           AND NVL(AW.QT_SEMANA, 0) > 0
         ORDER BY CA.NO_SALES_GROUP
        ;
   
    END PX_REPLAN_BASIC_DATA;


    
    PROCEDURE PX_REPLAN_BASIC_DATA_SAP (
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_RETORNO               OUT T_CURSOR,
        P_PRODUTO               OUT T_CURSOR,
        P_INCOTERMS             OUT T_CURSOR,
        P_SUPERVISORS           OUT T_CURSOR
    )
    IS
    BEGIN
        INSERT INTO vnd.elo_carteira_sap_tmp (
            cd_centro_expedidor,
            nu_carteira_version
        )
        SELECT cc.cd_centro_expedidor,
               MAX(TO_NUMBER(cc.nu_carteira_version)) nu_carteira_version
          FROM vnd.elo_carteira_sap_centro cc
          LEFT OUTER JOIN ctf.polo_centro_expedidor pc
            ON pc.cd_centro_expedidor = cc.cd_centro_expedidor
          LEFT OUTER JOIN ctf.centro_expedidor_machine cm
            ON cm.cd_centro_expedidor = cc.cd_centro_expedidor
         WHERE 
                   (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
               AND (p_cd_centro_expedidor IS NULL OR cc.cd_centro_expedidor = p_cd_centro_expedidor)
               AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
         GROUP BY cc.cd_centro_expedidor
        ;
                
        OPEN p_retorno FOR
        SELECT DISTINCT 
               cs.CD_CLIENTE,
               CASE WHEN cs.CD_INCOTERMS = 'FOB' THEN cs.NO_CLIENTE_PAGADOR
                    ELSE cs.NO_CLIENTE_RECEBEDOR
               END AS NO_CLIENTE
               
          FROM vnd.elo_carteira_sap cs
          
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY 2
        ; 
        
        OPEN p_produto FOR
        SELECT DISTINCT 
               cs.cd_produto_sap,
               cs.no_produto_sap,
               TO_CHAR(TO_NUMBER(cs.cd_produto_sap)) || ' - ' || cs.no_produto_sap cd_no_produto_sap
               
          FROM vnd.elo_carteira_sap cs
                
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY cs.NO_PRODUTO_SAP
        ; 
        
        OPEN P_INCOTERMS FOR
        SELECT DISTINCT 
               cs.cd_incoterms
               
          FROM vnd.elo_carteira_sap cs
                
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY cs.cd_incoterms
        ;
        
        OPEN P_SUPERVISORS FOR
        SELECT DISTINCT 
               cs.cd_sales_group,
               cs.no_sales_group,
               cs.cd_sales_group || ' - ' || cs.no_sales_group cd_no_sales_group
               
          FROM vnd.elo_carteira_sap cs
                
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY cs.no_sales_group
        ; 
    END PX_REPLAN_BASIC_DATA_SAP;



    PROCEDURE PX_ITEMS_FOR_REPLAN(
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_CD_SALES_GROUP        IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
        P_CD_CLIENTE            IN VND.ELO_AGENDAMENTO_ITEM.CD_CLIENTE%TYPE,
        P_CD_PRODUTO            IN VND.ELO_AGENDAMENTO_ITEM.CD_PRODUTO_SAP%TYPE,
        P_CD_INCOTERMS          IN VND.ELO_AGENDAMENTO_ITEM.CD_INCOTERMS%TYPE,
        P_RETORNO               OUT T_CURSOR
    )
    AS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT 
               AI.CD_ELO_AGENDAMENTO_ITEM, 
               MAX(AP.CD_SALES_GROUP) CD_SALES_GROUP,
               MAX(CA.NO_SALES_GROUP) NO_SALES_GROUP,
               MAX(AP.CD_SALES_GROUP) || ' - ' || MAX(CA.NO_SALES_GROUP) CD_NO_SALES_GROUP,
               AI.CD_CLIENTE,
               MAX(CA.NO_CLIENTE) NO_CLIENTE,
               AI.CD_PRODUTO_SAP,
               MAX(CA.NO_PRODUTO_SAP),
               TO_CHAR(TO_NUMBER(AI.CD_PRODUTO_SAP)) || ' - ' || MAX(CA.NO_PRODUTO_SAP) CD_NO_PRODUTO_SAP,
               AI.CD_INCOTERMS,
               'X' CD_ELO_CARTEIRA_SAP
               
          FROM VND.ELO_AGENDAMENTO AG
         
         INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AP
            ON AG.CD_ELO_AGENDAMENTO = AP.CD_ELO_AGENDAMENTO
         
         INNER JOIN VND.ELO_AGENDAMENTO_ITEM AI
            ON AP.CD_ELO_AGENDAMENTO_SUPERVISOR = AI.CD_ELO_AGENDAMENTO_SUPERVISOR
         
         INNER JOIN ELO_CARTEIRA CA
            ON AI.CD_ELO_AGENDAMENTO_ITEM = CA.CD_ELO_AGENDAMENTO_ITEM
           AND AP.CD_SALES_GROUP = CA.CD_SALES_GROUP
          
         WHERE (P_CD_CLIENTE IS NULL OR AI.CD_CLIENTE = P_CD_CLIENTE)
           AND (P_CD_POLO IS NULL OR AG.CD_POLO = P_CD_POLO)
           AND (P_CD_CENTRO_EXPEDIDOR  IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           AND (P_CD_MACHINE  IS NULL OR AG.CD_MACHINE = P_CD_MACHINE)
           AND (P_CD_SALES_GROUP IS NULL OR AP.CD_SALES_GROUP= P_CD_SALES_GROUP)
           AND (P_CD_PRODUTO IS NULL OR AI.CD_PRODUTO_SAP = P_CD_PRODUTO)
           AND (P_CD_WEEK IS NULL OR AG.CD_WEEK = P_CD_WEEK)
           AND (P_CD_INCOTERMS IS NULL OR AI.CD_INCOTERMS = P_CD_INCOTERMS)
           
         GROUP BY AI.CD_ELO_AGENDAMENTO_ITEM,
                  AI.CD_PRODUTO_SAP,
                  AI.CD_CLIENTE,
                  AI.CD_INCOTERMS
         
         ORDER BY MAX(CA.NO_SALES_GROUP),
                  MAX(CA.NO_CLIENTE)
        ;
    END PX_ITEMS_FOR_REPLAN;
    
    
    
    PROCEDURE PX_ITEMS_FOR_REPLAN_SAP (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_cd_sales_group        IN vnd.elo_carteira_sap.cd_sales_group%TYPE,
        p_cd_cliente            IN vnd.elo_carteira_sap.cd_cliente%TYPE,
        p_cd_produto            IN vnd.elo_carteira_sap.cd_produto_sap%TYPE,
        p_cd_incoterms          IN vnd.elo_carteira_sap.cd_incoterms%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_retorno FOR
        WITH centro_cart AS (
            SELECT cs.cd_centro_expedidor,
                   MAX(TO_NUMBER(cs.nu_carteira_version)) nu_carteira_version
              FROM vnd.elo_carteira_sap cs
              LEFT OUTER JOIN ctf.polo_centro_expedidor pc
                ON pc.cd_centro_expedidor = cs.cd_centro_expedidor
              LEFT OUTER JOIN ctf.centro_expedidor_machine cm
                ON cm.cd_centro_expedidor = cs.cd_centro_expedidor
             WHERE 
                       (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
                   AND (p_cd_centro_expedidor IS NULL OR cs.cd_centro_expedidor = p_cd_centro_expedidor)
                   AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
                   AND (p_nu_carteira_version IS NULL OR cs.nu_carteira_version = p_nu_carteira_version)
             GROUP BY cs.cd_centro_expedidor
        ),
        cart_sap as (
            SELECT cs.cd_sales_group,
                   cs.no_sales_group,
                   cs.cd_sales_group || ' - ' || cs.no_sales_group cd_no_sales_group,
                   CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.cd_cliente_pagador
                        ELSE cs.cd_cliente_recebedor
                   END AS cd_cliente,
                   CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.no_cliente_pagador
                        ELSE cs.no_cliente_recebedor
                   END AS no_cliente,
                   cs.cd_produto_sap,
                   cs.no_produto_sap,
                   TO_CHAR(TO_NUMBER(cs.cd_produto_sap)) || ' - ' || cs.no_produto_sap cd_no_produto_sap,
                   cs.cd_incoterms,
                   LISTAGG(cs.cd_elo_carteira_sap, ',') WITHIN GROUP (ORDER BY cd_elo_carteira_sap) AS cd_elo_carteira_sap
                   
              FROM vnd.elo_carteira_sap cs
                           
             WHERE (p_cd_cliente IS NULL OR cs.cd_cliente = p_cd_cliente)
               AND (p_cd_sales_group IS NULL OR cs.cd_sales_group = p_cd_sales_group)
               AND (p_cd_incoterms IS NULL OR cs.cd_incoterms = p_cd_incoterms)
               AND cd_centro_expedidor || nu_carteira_version in (select cd_centro_expedidor || nu_carteira_version from centro_cart)
           
             GROUP BY cs.cd_sales_group,
                      cs.no_sales_group,
                      CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.cd_cliente_pagador
                           ELSE cs.cd_cliente_recebedor
                      END,
                      CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.no_cliente_pagador
                           ELSE cs.no_cliente_recebedor
                      END,
                      cs.cd_produto_sap,
                      cs.no_produto_sap,
                      cs.cd_incoterms
        )
        SELECT 'X' cd_elo_agendamento_item,
               cs.*
               
          FROM cart_sap cs
                  
         WHERE p_cd_produto IS NULL OR cs.cd_produto_sap = p_cd_produto
           
         ORDER BY cs.cd_sales_group,
                  cs.cd_cliente,
                  cs.cd_produto_sap,
                  cs.cd_incoterms
                  
        ;
    END PX_ITEMS_FOR_REPLAN_SAP;
    
    

    PROCEDURE PI_REPLAN (
        p_cd_week                       IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo                       IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor           IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine                    IN vnd.elo_agendamento.cd_machine%TYPE,
        p_cd_agendamento_item_origem    IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_retorno                       OUT t_cursor
    )
    IS
        v_cd_elo_agendamento_destino    vnd.elo_agendamento.cd_elo_agendamento%TYPE;
        v_cd_elo_agendamento_item_dest  vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE;
        v_cd_sales_group                vnd.elo_agendamento_supervisor.cd_sales_group%TYPE;
        v_cd_elo_agendamento_superv     vnd.elo_agendamento_supervisor.cd_elo_agendamento_supervisor%TYPE;
        v_cd_elo_agendamento_week_orig  vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
        v_cd_elo_agendamento_week_dest  vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
        v_count                         NUMBER := 0;
        v_limit                         NUMBER := 1000;
        
        TYPE week_r IS RECORD
        (
            cd_elo_agendamento_week     vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE,
            cd_elo_agendamento_item     vnd.elo_agendamento_week.cd_elo_agendamento_item%TYPE, 
            nu_semana                   vnd.elo_agendamento_week.nu_semana%TYPE, 
            qt_cota                     vnd.elo_agendamento_week.qt_cota%TYPE, 
            qt_semana                   vnd.elo_agendamento_week.qt_semana%TYPE, 
            qt_emergencial              vnd.elo_agendamento_week.qt_emergencial%TYPE

        );
        TYPE week_t IS TABLE OF week_r;
        t_week week_t;

        CURSOR c_weeks IS
        SELECT cd_elo_agendamento_week,
               cd_elo_agendamento_item,
               nu_semana,
               qt_cota,
               qt_semana,
               qt_emergencial
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_agendamento_item_origem
        ;

    BEGIN
        -- Agendamento destino
        SELECT COUNT(ag.cd_elo_agendamento)
          INTO v_count
          FROM vnd.elo_agendamento ag
         WHERE ag.ic_ativo = 'S'
           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
           AND ag.cd_week = p_cd_week
        ;
        
        IF v_count = 0 THEN
            OPEN p_retorno FOR
            SELECT 'NOAGEND' FROM DUAL;
            RETURN;
        END IF;
        
        SELECT ag.cd_elo_agendamento
          INTO v_cd_elo_agendamento_destino
          FROM vnd.elo_agendamento ag
         WHERE ag.ic_ativo = 'S'
           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
           AND ag.cd_week = p_cd_week
        ;

        -- 1) Busca ou cria o supervisor:
        SELECT ap.cd_sales_group
          INTO v_cd_sales_group
          FROM vnd.elo_agendamento_supervisor ap
         INNER JOIN vnd.elo_agendamento_item ai
            ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
         WHERE ai.cd_elo_agendamento_item = p_cd_agendamento_item_origem 
        ;
    
        SELECT COUNT(cd_elo_agendamento_supervisor)
          INTO v_count
          FROM vnd.elo_agendamento_supervisor ap
         WHERE ap.cd_elo_agendamento = v_cd_elo_agendamento_destino
           AND ap.cd_sales_group = v_cd_sales_group
        ;

        IF v_count = 0 THEN
            -- Supervisor não existe no agendamento destino.
            SELECT seq_elo_agend_supervisor.nextval
              INTO v_cd_elo_agendamento_superv
              FROM dual;
        
            INSERT INTO vnd.elo_agendamento_supervisor (
                cd_elo_agendamento_supervisor, 
                cd_elo_agendamento, 
                cd_sales_district, 
                cd_sales_office, 
                cd_sales_group, 
                cd_elo_status, 
                cd_usuario_fechamento, 
                dh_fechamento, 
                ic_ativo, 
                qt_forecast, 
                qt_cota, 
                qt_cota_ajustada, 
                cd_usuario_cota_ajustada, 
                dh_cota_ajustada
            )
            SELECT
                   v_cd_elo_agendamento_superv,
                   v_cd_elo_agendamento_destino,
                   ap.cd_sales_district,
                   ap.cd_sales_office,
                   ap.cd_sales_group,
                   vnd.gx_elo_common.fx_elo_status('AGSUP', 'ASFIN'),
                   NULL,
                   NULL,
                   'S',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL 
              FROM vnd.elo_agendamento_supervisor ap
             INNER JOIN vnd.elo_agendamento_item ai
                ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
             WHERE ai.cd_elo_agendamento_item = p_cd_agendamento_item_origem
            ;
        ELSIF v_count > 1 THEN
            OPEN p_retorno FOR
            SELECT 'MANYSUP' FROM DUAL;
            RETURN;
        ELSE
            SELECT cd_elo_agendamento_supervisor
              INTO v_cd_elo_agendamento_superv
              FROM vnd.elo_agendamento_supervisor ap
             WHERE ap.cd_elo_agendamento = v_cd_elo_agendamento_destino
               AND ap.cd_sales_group = v_cd_sales_group
            ;
        END IF;


        -- 2) Cria o novo item do agendamento:
        SELECT seq_elo_agendamento_item.nextval
          INTO v_cd_elo_agendamento_item_dest
          FROM dual;

        INSERT INTO vnd.elo_agendamento_item (
            cd_elo_agendamento_item, 
            cd_elo_agendamento_supervisor, 
            cd_cliente, 
            cd_produto_sap, 
            cd_incoterms, 
            cd_cota_compartilhada, 
            ds_observacao_torre_fretes, 
            ic_ativo, 
            ic_cortado_semana_anterior, 
            cd_elo_priority_option, 
            cd_status_replan, 
            cd_elo_agendamento_item_antigo
        )
        SELECT v_cd_elo_agendamento_item_dest,
               v_cd_elo_agendamento_superv,
               ai.cd_cliente,
               ai.cd_produto_sap,
               ai.cd_incoterms,
               NULL,
               ai.ds_observacao_torre_fretes,
               'S',
               NULL,
               ai.cd_elo_priority_option,
               vnd.gx_elo_common.fx_elo_status('APREP','RPNEW'),
               ai.cd_elo_agendamento_item   --CD_ELO_AGENDAMENTO_ITEM_ANTIGO
          FROM vnd.elo_agendamento_item ai
         WHERE ai.cd_elo_agendamento_item = p_cd_agendamento_item_origem 
        ;

        -- 3) Copia as semanas e dias do item de origem:
        OPEN    c_weeks;                               
        FETCH   c_weeks BULK COLLECT INTO t_week LIMIT v_limit;
        CLOSE   c_weeks;
        
        FOR i_week IN 1 .. t_week.COUNT
        LOOP
            v_cd_elo_agendamento_week_orig := t_week(i_week).cd_elo_agendamento_week;
            
            SELECT seq_elo_agendamento_week.nextval
              INTO v_cd_elo_agendamento_week_dest
              FROM dual
            ;
            
            INSERT INTO vnd.elo_agendamento_week (
                cd_elo_agendamento_week, 
                cd_elo_agendamento_item, 
                nu_semana, 
                qt_cota, 
                qt_semana, 
                qt_emergencial
            ) VALUES (
                v_cd_elo_agendamento_week_dest,
                v_cd_elo_agendamento_item_dest,
                t_week(i_week).nu_semana,
                t_week(i_week).qt_cota,
                t_week(i_week).qt_semana,
                t_week(i_week).qt_emergencial
            );
            
            INSERT INTO vnd.elo_agendamento_day (
                cd_elo_agendamento_day, 
                cd_elo_agendamento_week, 
                nu_dia_semana, 
                cd_grupo_embalagem, 
                nu_quantidade
            )
            SELECT seq_elo_agendamento_day.nextval,
                   v_cd_elo_agendamento_week_dest,
                   nu_dia_semana,
                   cd_grupo_embalagem,
                   nu_quantidade
              FROM vnd.elo_agendamento_day ad
             WHERE ad.cd_elo_agendamento_week = v_cd_elo_agendamento_week_orig
            ;
        END LOOP;


        -- 4) Copia a carteira do item de origem:
        INSERT INTO vnd.elo_carteira (
            cd_elo_carteira, 
            cd_elo_agendamento_item, 
            cd_tipo_agendamento, 
            cd_tipo_replan, 
            cd_elo_agendamento, 
            dh_replan, 
            cd_status_replan, 
            cd_elo_agendamento_replan, 
            ic_ativo,
            qt_agendada,
            qt_agendada_confirmada, 
            cd_elo_carteira_antigo,
            cd_centro_expedidor, 
            ds_centro_expedidor, 
            dh_carteira, 
            cd_sales_org, 
            nu_contrato_sap, 
            cd_tipo_contrato, 
            nu_contrato_substitui, 
            dt_pago, 
            nu_contrato, 
            nu_ordem_venda, 
            ic_sem_ordem_venda, 
            ds_status_contrato_sap, 
            cd_cliente, 
            no_cliente, 
            cd_incoterms, 
            cd_sales_district, 
            cd_sales_office, 
            no_sales_office, 
            cd_sales_group, 
            no_sales_group, 
            cd_agente_venda, 
            no_agente, 
            dh_vencimento_pedido, 
            dt_credito, 
            dt_inicio, 
            dt_fim, 
            dh_inclusao, 
            dh_entrega, 
            sg_estado, 
            no_municipio, 
            ds_bairro, 
            cd_produto_sap, 
            no_produto_sap, 
            qt_programada, 
            qt_entregue, 
            qt_saldo, 
            vl_unitario, 
            vl_brl, 
            vl_taxa_dolar, 
            vl_usd, 
            pc_comissao, 
            cd_sacaria, 
            ds_sacaria, 
            cd_cultura_sap, 
            ds_cultura_sap, 
            cd_bloqueio_remessa, 
            cd_bloqueio_faturamento, 
            cd_bloqueio_credito, 
            cd_bloqueio_remessa_item, 
            cd_bloqueio_faturamento_item, 
            cd_motivo_recusa, 
            cd_login, 
            cd_segmentacao_cliente, 
            ds_segmentacao_cliente, 
            ds_segmento_cliente_sap, 
            cd_forma_pagamento, 
            cd_tipo_pagamento, 
            ds_tipo_pagamento, 
            cd_agrupamento, 
            cd_bloqueio_entrega, 
            nu_cnpj, 
            nu_cpf, 
            nu_inscricao_estadual, 
            nu_inscricao_municipal, 
            nu_cep, 
            ds_endereco_recebedor, 
            cd_cliente_recebedor, 
            no_cliente_recebedor, 
            cd_moeda, 
            cd_supply_group, 
            ds_venda_compartilhada, 
            cd_status_liberacao, 
            cd_item_pedido, 
            cd_cliente_pagador, 
            no_cliente_pagador, 
            ic_relacionamento, 
            nu_ordem, 
            qt_agendada_fabrica, 
            qt_agendada_sap, 
            cd_usuario_refresh, 
            dh_refresh, 
            qt_programada_refresh, 
            qt_entregue_refresh, 
            qt_saldo_refresh, 
            cd_bloqueio_remessa_r, 
            cd_bloqueio_faturamento_r, 
            cd_bloqueio_credito_r, 
            cd_bloqueio_remessa_item_r, 
            cd_bloqueio_faturamento_item_r, 
            ds_observacao_adven, 
            ic_permitir_cs, 
            dh_liberacao_torre_fretes, 
            dh_modificacao_torre_fretes, 
            dh_contratacao_torre_fretes, 
            cd_elo_freight_tower_reason, 
            vl_frete_contratado, 
            ic_nao_liberada_sem_protocolo, 
            ic_entrega_cadenciada_cliente, 
            ic_dificuldade_contratacao, 
            ic_outros, 
            cd_status_customer_service, 
            cd_status_torre_fretes, 
            cd_status_controladoria, 
            cd_grupo_embalagem, 
            ds_credit_block_reason, 
            dh_credit_block, 
            sg_destino_backlog_cif, 
            cd_status_backlog_cif, 
            qt_agendada_anterior, 
            dh_backlog_cif, 
            qt_backlog_cif, 
            qt_agendada_refresh, 
            cd_usuario_fabrica, 
            dh_fabrica, 
            cd_usuario_cortado_fabrica, 
            dh_cortado_fabrica, 
            cd_usuario_ajuste_sap, 
            dh_ajuste_sap, 
            cd_item_contrato, 
            cd_status_logistica, 
            ic_cortado_fabrica, 
            ic_cooperative, 
            ic_split, 
            ic_emergencial, 
            ds_roteiro_entrega, 
            cd_elo_priority_option, 
            qt_ajustada_fabrica, 
            qt_ajustada_sap, 
            ic_fa, 
            cd_centro_expedidor_fabrica, 
            ds_centro_expedidor_fabrica, 
            nu_ordem_venda_fabrica, 
            vl_frete_distribuicao, 
            cd_motivo_recusa_refresh, 
            ic_export, 
            ds_credit_block_reason_r, 
            cd_status_cel_initial, 
            cd_status_cel_final, 
            ds_endereco_pagador, 
            no_sales_district, 
            ds_observacao_torre_fretes, 
            qt_agendada_celula, 
            dh_modificacao_cell_att, 
            cd_usuario_modif_cell_att, 
            nu_protocolo, 
            qt_agendada_protocolo, 
            nu_protocolo_entrega, 
            cd_elo_carteira_grouping
        )
        SELECT
               vnd.seq_elo_carteira.nextval, 
               v_cd_elo_agendamento_item_dest, 
               vnd.gx_elo_common.fx_elo_status('TIPAG','REPLAN'),--cd_tipo_agendamento
               vnd.gx_elo_common.fx_elo_status('TIPRP','INCLUSAO'),--cd_tipo_replan
               v_cd_elo_agendamento_destino, --cd_elo_agendamento
               SYSDATE,--dh_replan, 
               NULL,--cd_status_replan, 
               ca.cd_elo_agendamento, --cd_elo_agendamento_replan
               'S', --ic_ativo 
               ca.qt_agendada,
               ca.qt_agendada_confirmada,
               ca.cd_elo_carteira,
               ca.cd_centro_expedidor, 
               ca.ds_centro_expedidor, 
               ca.dh_carteira, 
               ca.cd_sales_org, 
               ca.nu_contrato_sap, 
               ca.cd_tipo_contrato, 
               ca.nu_contrato_substitui, 
               ca.dt_pago, 
               ca.nu_contrato, 
               ca.nu_ordem_venda, 
               ca.ic_sem_ordem_venda, 
               ca.ds_status_contrato_sap, 
               ca.cd_cliente, 
               ca.no_cliente, 
               ca.cd_incoterms, 
               ca.cd_sales_district, 
               ca.cd_sales_office, 
               ca.no_sales_office, 
               ca.cd_sales_group, 
               ca.no_sales_group, 
               ca.cd_agente_venda, 
               ca.no_agente, 
               ca.dh_vencimento_pedido, 
               ca.dt_credito, 
               ca.dt_inicio, 
               ca.dt_fim, 
               ca.dh_inclusao, 
               ca.dh_entrega, 
               ca.sg_estado, 
               ca.no_municipio, 
               ca.ds_bairro, 
               ca.cd_produto_sap, 
               ca.no_produto_sap, 
               ca.qt_programada, 
               ca.qt_entregue, 
               ca.qt_saldo, 
               ca.vl_unitario, 
               ca.vl_brl, 
               ca.vl_taxa_dolar, 
               ca.vl_usd, 
               ca.pc_comissao, 
               ca.cd_sacaria, 
               ca.ds_sacaria, 
               ca.cd_cultura_sap, 
               ca.ds_cultura_sap, 
               ca.cd_bloqueio_remessa, 
               ca.cd_bloqueio_faturamento, 
               ca.cd_bloqueio_credito, 
               ca.cd_bloqueio_remessa_item, 
               ca.cd_bloqueio_faturamento_item, 
               ca.cd_motivo_recusa, 
               ca.cd_login, 
               ca.cd_segmentacao_cliente, 
               ca.ds_segmentacao_cliente, 
               ca.ds_segmento_cliente_sap, 
               ca.cd_forma_pagamento, 
               ca.cd_tipo_pagamento, 
               ca.ds_tipo_pagamento, 
               ca.cd_agrupamento, 
               ca.cd_bloqueio_entrega, 
               ca.nu_cnpj, 
               ca.nu_cpf, 
               ca.nu_inscricao_estadual, 
               ca.nu_inscricao_municipal, 
               ca.nu_cep, 
               ca.ds_endereco_recebedor, 
               ca.cd_cliente_recebedor, 
               ca.no_cliente_recebedor, 
               ca.cd_moeda, 
               ca.cd_supply_group, 
               ca.ds_venda_compartilhada, 
               ca.cd_status_liberacao, 
               ca.cd_item_pedido, 
               ca.cd_cliente_pagador, 
               ca.no_cliente_pagador, 
               ca.ic_relacionamento, 
               ca.nu_ordem, 
               ca.qt_agendada_fabrica, 
               ca.qt_agendada_sap, 
               ca.cd_usuario_refresh, 
               ca.dh_refresh, 
               ca.qt_programada_refresh, 
               ca.qt_entregue_refresh, 
               ca.qt_saldo_refresh, 
               ca.cd_bloqueio_remessa_r, 
               ca.cd_bloqueio_faturamento_r, 
               ca.cd_bloqueio_credito_r, 
               ca.cd_bloqueio_remessa_item_r, 
               ca.cd_bloqueio_faturamento_item_r, 
               ca.ds_observacao_adven, 
               ca.ic_permitir_cs, 
               ca.dh_liberacao_torre_fretes, 
               ca.dh_modificacao_torre_fretes, 
               ca.dh_contratacao_torre_fretes, 
               ca.cd_elo_freight_tower_reason, 
               ca.vl_frete_contratado, 
               ca.ic_nao_liberada_sem_protocolo, 
               ca.ic_entrega_cadenciada_cliente, 
               ca.ic_dificuldade_contratacao, 
               ca.ic_outros, 
               ca.cd_status_customer_service, 
               ca.cd_status_torre_fretes, 
               ca.cd_status_controladoria, 
               ca.cd_grupo_embalagem, 
               ca.ds_credit_block_reason, 
               ca.dh_credit_block, 
               ca.sg_destino_backlog_cif, 
               ca.cd_status_backlog_cif, 
               ca.qt_agendada_anterior, 
               ca.dh_backlog_cif, 
               ca.qt_backlog_cif, 
               ca.qt_agendada_refresh, 
               ca.cd_usuario_fabrica, 
               ca.dh_fabrica, 
               ca.cd_usuario_cortado_fabrica, 
               ca.dh_cortado_fabrica, 
               ca.cd_usuario_ajuste_sap, 
               ca.dh_ajuste_sap, 
               ca.cd_item_contrato, 
               ca.cd_status_logistica, 
               ca.ic_cortado_fabrica, 
               ca.ic_cooperative, 
               ca.ic_split, 
               ca.ic_emergencial, 
               ca.ds_roteiro_entrega, 
               ca.cd_elo_priority_option, 
               ca.qt_ajustada_fabrica, 
               ca.qt_ajustada_sap, 
               ca.ic_fa, 
               ca.cd_centro_expedidor_fabrica, 
               ca.ds_centro_expedidor_fabrica, 
               ca.nu_ordem_venda_fabrica, 
               ca.vl_frete_distribuicao, 
               ca.cd_motivo_recusa_refresh, 
               ca.ic_export, 
               ca.ds_credit_block_reason_r, 
               ca.cd_status_cel_initial, 
               ca.cd_status_cel_final, 
               ca.ds_endereco_pagador, 
               ca.no_sales_district, 
               ca.ds_observacao_torre_fretes, 
               ca.qt_agendada_celula, 
               ca.dh_modificacao_cell_att, 
               ca.cd_usuario_modif_cell_att, 
               ca.nu_protocolo, 
               ca.qt_agendada_protocolo, 
               ca.nu_protocolo_entrega, 
               ca.cd_elo_carteira_grouping
          FROM vnd.elo_carteira ca
         WHERE ca.cd_elo_agendamento_item = p_cd_agendamento_item_origem
        ;
        
        COMMIT;
        
        UPDATE vnd.elo_carteira 
           SET qt_agendada_confirmada = NULL 
         WHERE cd_elo_agendamento_item = p_cd_agendamento_item_origem
        ;
        
        COMMIT;
      
        OPEN p_retorno FOR
        SELECT 'SUCCESS' FROM DUAL;
    END PI_REPLAN;

    
    
    PROCEDURE PI_REPLAN_SAP (
        p_cd_week               IN  vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN  vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN  vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN  vnd.elo_agendamento.cd_machine%TYPE,
        p_cd_elo_carteira_sap   IN  VARCHAR2,
        p_retorno               OUT t_cursor
    )
    IS
        v_cd_elo_agendamento_destino    vnd.elo_agendamento.cd_elo_agendamento%TYPE;
        v_cd_elo_agendamento_superv     vnd.elo_agendamento_supervisor.cd_elo_agendamento_supervisor%TYPE;
        v_cd_elo_agendamento_item_dest  vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE;
        v_count                         NUMBER := 0;
        v_cd_elo_carteira_destino       vnd.elo_carteira.cd_elo_carteira%TYPE;
        t_carteira_sap                  split_tbl;
    BEGIN
        -- Agendamento destino
        SELECT COUNT(ag.cd_elo_agendamento)
          INTO v_count
          FROM vnd.elo_agendamento ag
         WHERE ag.ic_ativo = 'S'
           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
           AND ag.cd_week = p_cd_week
        ;
        
        IF v_count = 0 THEN
            OPEN p_retorno FOR
            SELECT 'NOAGEND' FROM DUAL;
            RETURN;
        END IF;
        
        SELECT ag.cd_elo_agendamento
          INTO v_cd_elo_agendamento_destino
          FROM vnd.elo_agendamento ag
         WHERE ag.ic_ativo = 'S'
           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
           AND ag.cd_week = p_cd_week
        ;
        
        
        -- 1) Busca ou cria o supervisor:
        SELECT COUNT(cd_elo_agendamento_supervisor)
          INTO v_count
          FROM vnd.elo_agendamento_supervisor ap
         INNER JOIN vnd.elo_carteira_sap cs
            ON cs.cd_sales_group = ap.cd_sales_group
         WHERE cs.cd_elo_carteira_sap IN (
                    SELECT * FROM TABLE(gx_elo_replan_process.fx_split(p_cd_elo_carteira_sap, ','))
               ) 
           AND ap.cd_elo_agendamento = v_cd_elo_agendamento_destino
        ;
        
        IF v_count = 0 THEN
            -- Supervisor não existe no agendamento destino.
            SELECT seq_elo_agend_supervisor.nextval
              INTO v_cd_elo_agendamento_superv
              FROM dual;
        
            INSERT INTO vnd.elo_agendamento_supervisor (
                cd_elo_agendamento_supervisor, 
                cd_elo_agendamento, 
                cd_sales_district, 
                cd_sales_office, 
                cd_sales_group, 
                cd_elo_status, 
                cd_usuario_fechamento, 
                dh_fechamento, 
                ic_ativo, 
                qt_forecast, 
                qt_cota, 
                qt_cota_ajustada, 
                cd_usuario_cota_ajustada, 
                dh_cota_ajustada
            )
            SELECT DISTINCT
                   v_cd_elo_agendamento_superv,
                   v_cd_elo_agendamento_destino,
                   cs.cd_sales_district,
                   cs.cd_sales_office,
                   cs.cd_sales_group,
                   vnd.gx_elo_common.fx_elo_status('AGSUP', 'ASFIN'),
                   NULL,
                   NULL,
                   'S',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL 
              FROM vnd.elo_carteira_sap cs
             WHERE cs.cd_elo_carteira_sap IN (
                        SELECT * FROM TABLE(gx_elo_replan_process.fx_split(p_cd_elo_carteira_sap, ',')) 
                   )
            ;
        ELSE
            SELECT cd_elo_agendamento_supervisor
              INTO v_cd_elo_agendamento_superv
              FROM (
                        SELECT ap.cd_elo_agendamento_supervisor
                          FROM vnd.elo_agendamento_supervisor ap
                         INNER JOIN vnd.elo_carteira_sap cs
                            ON cs.cd_sales_group = ap.cd_sales_group
                         WHERE cs.cd_elo_carteira_sap IN (
                                    SELECT * FROM TABLE(gx_elo_replan_process.fx_split(p_cd_elo_carteira_sap, ',')) 
                               )
                           AND ap.cd_elo_agendamento = v_cd_elo_agendamento_destino
                           AND ap.cd_elo_agendamento_supervisor IS NOT NULL
                   )
             WHERE ROWNUM = 1
            ;
        END IF;

        
        -- 2) Cria o novo item do agendamento:
        SELECT seq_elo_agendamento_item.nextval
          INTO v_cd_elo_agendamento_item_dest
          FROM dual;

        INSERT INTO vnd.elo_agendamento_item (
            cd_elo_agendamento_item, 
            cd_elo_agendamento_supervisor, 
            cd_cliente, 
            cd_produto_sap, 
            cd_incoterms, 
            cd_cota_compartilhada, 
            ds_observacao_torre_fretes, 
            ic_ativo, 
            ic_cortado_semana_anterior, 
            cd_elo_priority_option, 
            cd_status_replan, 
            cd_elo_agendamento_item_antigo
        )
        SELECT DISTINCT
               v_cd_elo_agendamento_item_dest,
               v_cd_elo_agendamento_superv,
               CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.cd_cliente_pagador
                    ELSE cs.cd_cliente_recebedor
               END,                                                 --cd_cliente
               cs.cd_produto_sap,
               cs.cd_incoterms,
               NULL,                                                --cd_cota_compartilhada
               NULL,                                                --ds_observacao_torre_fretes,
               'S',                                                 --ic_ativo
               'N',                                                 --ic_cortado_semana_anterior
               NULL,                                                --cd_elo_priority_option
               vnd.gx_elo_common.fx_elo_status('APREP','RPNEW'),    --cd_status_replan
               NULL                                                 --cd_elo_agendamento_item_antigo
          FROM vnd.elo_carteira_sap cs
         WHERE cs.cd_elo_carteira_sap IN (
                    SELECT * FROM TABLE(gx_elo_replan_process.fx_split(p_cd_elo_carteira_sap, ',')) 
               )
         GROUP BY CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.cd_cliente_pagador
                       ELSE cs.cd_cliente_recebedor
                  END,
                  cs.cd_produto_sap,
                  cs.cd_incoterms,
                  cs.cd_sales_group
        ;

        
        -- 3) Cria o registro na ELO_CARTEIRA copiando da ELO_CARTEIRA_SAP:
        t_carteira_sap := gx_elo_replan_process.fx_split2(p_cd_elo_carteira_sap, ',');
        
        FOR i IN t_carteira_sap.FIRST..t_carteira_sap.LAST LOOP
            SELECT vnd.seq_elo_carteira.nextval
              INTO v_cd_elo_carteira_destino
              FROM dual
            ;
            
            INSERT INTO VND.ELO_CARTEIRA (
                CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                DH_CARTEIRA,
                CD_SALES_ORG,
                NU_CONTRATO_SAP,
                CD_TIPO_CONTRATO,
                NU_CONTRATO_SUBSTITUI,
                DT_PAGO,
                NU_CONTRATO,
                NU_ORDEM_VENDA,
                DS_STATUS_CONTRATO_SAP,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_INCOTERMS,
                CD_SALES_DISTRICT,
                CD_SALES_OFFICE,
                NO_SALES_OFFICE,
                CD_SALES_GROUP,
                NO_SALES_GROUP,
                CD_AGENTE_VENDA,
                NO_AGENTE,
                DH_VENCIMENTO_PEDIDO,
                DT_CREDITO,
                DT_INICIO,
                DT_FIM,
                DH_INCLUSAO,
                DH_ENTREGA,
                SG_ESTADO,
                NO_MUNICIPIO,
                DS_BAIRRO,
                CD_PRODUTO_SAP,
                NO_PRODUTO_SAP,
                QT_PROGRAMADA,
                QT_ENTREGUE,
                QT_SALDO,
                VL_UNITARIO,
                VL_BRL,
                VL_TAXA_DOLAR,
                VL_USD,
                PC_COMISSAO,
                CD_SACARIA,
                DS_SACARIA,
                CD_CULTURA_SAP,
                DS_CULTURA_SAP,
                CD_BLOQUEIO_REMESSA,
                CD_BLOQUEIO_FATURAMENTO,
                CD_BLOQUEIO_CREDITO,
                CD_BLOQUEIO_REMESSA_ITEM,
                CD_BLOQUEIO_FATURAMENTO_ITEM,
                CD_MOTIVO_RECUSA,
                CD_LOGIN,
                CD_SEGMENTACAO_CLIENTE,
                DS_SEGMENTACAO_CLIENTE,
                DS_SEGMENTO_CLIENTE_SAP,
                CD_FORMA_PAGAMENTO,
                CD_TIPO_PAGAMENTO,
                DS_TIPO_PAGAMENTO,
                CD_AGRUPAMENTO,
                CD_BLOQUEIO_ENTREGA,
                NU_CNPJ,
                NU_CPF,
                NU_INSCRICAO_ESTADUAL,
                NU_INSCRICAO_MUNICIPAL,
                NU_CEP,
                DS_ENDERECO_RECEBEDOR,
                CD_CLIENTE_RECEBEDOR,
                NO_CLIENTE_RECEBEDOR,
                CD_MOEDA,
                CD_SUPPLY_GROUP,
                DS_VENDA_COMPARTILHADA,
                CD_STATUS_LIBERACAO,
                CD_ITEM_PEDIDO,
                CD_CLIENTE_PAGADOR,
                NO_CLIENTE_PAGADOR,
                CD_GRUPO_EMBALAGEM,
                DS_CREDIT_BLOCK_REASON,
                DH_CREDIT_BLOCK,
                CD_ITEM_CONTRATO,
                VL_FRETE_DISTRIBUICAO,
                DS_ENDERECO_PAGADOR,
                NO_SALES_DISTRICT,
                -- Following fields do not come from ELO_CARTEIRA_SAP.
                CD_ELO_AGENDAMENTO_ITEM,
                IC_SEM_ORDEM_VENDA,
                IC_RELACIONAMENTO,
                NU_ORDEM,
                QT_AGENDADA,
                QT_AGENDADA_FABRICA,
                QT_AGENDADA_SAP,
                CD_USUARIO_REFRESH,
                DH_REFRESH,
                QT_PROGRAMADA_REFRESH,
                QT_ENTREGUE_REFRESH,
                QT_SALDO_REFRESH,
                QT_AGENDADA_CONFIRMADA,
                CD_TIPO_AGENDAMENTO,
                CD_TIPO_REPLAN,
                DH_REPLAN,
                CD_STATUS_REPLAN,
                CD_BLOQUEIO_REMESSA_R,
                CD_BLOQUEIO_FATURAMENTO_R,
                CD_BLOQUEIO_CREDITO_R,
                CD_BLOQUEIO_REMESSA_ITEM_R,
                CD_BLOQUEIO_FATURAMENTO_ITEM_R,
                DS_OBSERVACAO_ADVEN,
                IC_PERMITIR_CS,
                DH_LIBERACAO_TORRE_FRETES,
                DH_MODIFICACAO_TORRE_FRETES,
                DH_CONTRATACAO_TORRE_FRETES,
                CD_ELO_FREIGHT_TOWER_REASON,
                VL_FRETE_CONTRATADO,
                IC_NAO_LIBERADA_SEM_PROTOCOLO,
                IC_ENTREGA_CADENCIADA_CLIENTE,
                IC_DIFICULDADE_CONTRATACAO,
                IC_OUTROS,
                CD_STATUS_CUSTOMER_SERVICE,
                CD_STATUS_TORRE_FRETES,
                CD_STATUS_CONTROLADORIA,
                IC_ATIVO,
                SG_DESTINO_BACKLOG_CIF,
                CD_STATUS_BACKLOG_CIF,
                QT_AGENDADA_ANTERIOR,
                DH_BACKLOG_CIF,
                QT_BACKLOG_CIF,
                CD_ELO_AGENDAMENTO,
                QT_AGENDADA_REFRESH,
                CD_USUARIO_FABRICA,
                DH_FABRICA,
                CD_USUARIO_CORTADO_FABRICA,
                DH_CORTADO_FABRICA,
                CD_USUARIO_AJUSTE_SAP,
                DH_AJUSTE_SAP,
                CD_STATUS_LOGISTICA,
                IC_CORTADO_FABRICA,
                IC_COOPERATIVE,
                IC_SPLIT,
                IC_FA,
                IC_EMERGENCIAL,
                DS_ROTEIRO_ENTREGA,
                CD_ELO_PRIORITY_OPTION,
                QT_AJUSTADA_FABRICA,
                QT_AJUSTADA_SAP,
                IC_EXPORT,
                DS_CREDIT_BLOCK_REASON_R,
                CD_STATUS_CEL_INITIAL,
                CD_STATUS_CEL_FINAL
            )
            SELECT
                    v_cd_elo_carteira_destino,
                    CS.CD_CENTRO_EXPEDIDOR,
                    CS.DS_CENTRO_EXPEDIDOR,
                    CS.DH_CARTEIRA,
                    CS.CD_SALES_ORG,
                    CS.NU_CONTRATO_SAP,
                    CS.CD_TIPO_CONTRATO,
                    CS.NU_CONTRATO_SUBSTITUI,
                    CS.DT_PAGO,
                    CS.NU_CONTRATO,
                    CS.NU_ORDEM_VENDA,
                    CS.DS_STATUS_CONTRATO_SAP,
                    CS.CD_CLIENTE,
                    CS.NO_CLIENTE,
                    CS.CD_INCOTERMS,
                    CS.CD_SALES_DISTRICT,
                    CS.CD_SALES_OFFICE,
                    CS.NO_SALES_OFFICE,
                    CS.CD_SALES_GROUP,
                    CS.NO_SALES_GROUP,
                    CS.CD_AGENTE_VENDA,
                    CS.NO_AGENTE,
                    CS.DH_VENCIMENTO_PEDIDO,
                    CS.DT_CREDITO,
                    CS.DT_INICIO,
                    CS.DT_FIM,
                    CS.DH_INCLUSAO,
                    CS.DH_ENTREGA,
                    CS.SG_ESTADO,
                    CS.NO_MUNICIPIO,
                    CS.DS_BAIRRO,
                    CS.CD_PRODUTO_SAP,
                    CS.NO_PRODUTO_SAP,
                    CS.QT_PROGRAMADA,
                    CS.QT_ENTREGUE,
                    CS.QT_SALDO,
                    CS.VL_UNITARIO,
                    CS.VL_BRL,
                    CS.VL_TAXA_DOLAR,
                    CS.VL_USD,
                    CS.PC_COMISSAO,
                    CS.CD_SACARIA,
                    CS.DS_SACARIA,
                    CS.CD_CULTURA_SAP,
                    CS.DS_CULTURA_SAP,
                    CS.CD_BLOQUEIO_REMESSA,
                    CS.CD_BLOQUEIO_FATURAMENTO,
                    CS.CD_BLOQUEIO_CREDITO,
                    CS.CD_BLOQUEIO_REMESSA_ITEM,
                    CS.CD_BLOQUEIO_FATURAMENTO_ITEM,
                    CS.CD_MOTIVO_RECUSA,
                    CS.CD_LOGIN,
                    CS.CD_SEGMENTACAO_CLIENTE,
                    CS.DS_SEGMENTACAO_CLIENTE,
                    CS.DS_SEGMENTO_CLIENTE_SAP,
                    CS.CD_FORMA_PAGAMENTO,
                    CS.CD_TIPO_PAGAMENTO,
                    CS.DS_TIPO_PAGAMENTO,
                    CS.CD_AGRUPAMENTO,
                    CS.CD_BLOQUEIO_ENTREGA,
                    CS.NU_CNPJ,
                    CS.NU_CPF,
                    CS.NU_INSCRICAO_ESTADUAL,
                    CS.NU_INSCRICAO_MUNICIPAL,
                    CS.NU_CEP,
                    CS.DS_ENDERECO_RECEBEDOR,
                    CS.CD_CLIENTE_RECEBEDOR,
                    CS.NO_CLIENTE_RECEBEDOR,
                    CS.CD_MOEDA,
                    CS.CD_SUPPLY_GROUP,
                    CS.DS_VENDA_COMPARTILHADA,
                    CS.CD_STATUS_LIBERACAO,
                    CS.CD_ITEM_PEDIDO,
                    CS.CD_CLIENTE_PAGADOR,
                    CS.NO_CLIENTE_PAGADOR,
                    CS.CD_GRUPO_EMBALAGEM,
                    CS.DS_CREDIT_BLOCK_REASON,
                    CS.DH_CREDIT_BLOCK,
                    CS.CD_ITEM_CONTRATO,
                    CS.VL_FRETE_DISTRIBUICAO,
                    CS.DS_ENDERECO_PAGADOR,
                    CS.NO_SALES_DISTRICT,
                    -- Following fields do not come from ELO_CARTEIRA_SAP.
                    v_cd_elo_agendamento_item_dest,                                         --CD_ELO_AGENDAMENTO_ITEM
                    CASE 
                        WHEN cs.nu_ordem_venda IS NULL OR TRIM(cs.nu_ordem_venda) = '' THEN 'S'
                        ELSE 'N'
                    END,                                                                    --IC_SEM_ORDEM_VENDA
                    'N',                                                                    --IC_RELACIONAMENTO
                    NULL,                                                                   --NU_ORDEM
                    NULL,                                                                   --QT_AGENDADA
                    NULL,                                                                   --QT_AGENDADA_FABRICA
                    NULL,                                                                   --QT_AGENDADA_SAP
                    NULL,                                                                   --CD_USUARIO_REFRESH
                    NULL,                                                                   --DH_REFRESH
                    NULL,                                                                   --QT_PROGRAMADA_REFRESH
                    NULL,                                                                   --QT_ENTREGUE_REFRESH
                    NULL,                                                                   --QT_SALDO_REFRESH
                    NULL,                                                                   --QT_AGENDADA_CONFIRMADA
                    vnd.gx_elo_common.fx_elo_status('TIPAG','REPLAN'),                      --CD_TIPO_AGENDAMENTO
                    vnd.gx_elo_common.fx_elo_status('TIPRP','INCLUSAO'),                    --CD_TIPO_REPLAN
                    SYSDATE,                                                                --DH_REPLAN
                    NULL,                                                                   --CD_STATUS_REPLAN
                    NULL,                                                                   --CD_BLOQUEIO_REMESSA_R
                    NULL,                                                                   --CD_BLOQUEIO_FATURAMENTO_R
                    NULL,                                                                   --CD_BLOQUEIO_CREDITO_R
                    NULL,                                                                   --CD_BLOQUEIO_REMESSA_ITEM_R
                    NULL,                                                                   --CD_BLOQUEIO_FATURAMENTO_ITEM_R
                    NULL,                                                                   --DS_OBSERVACAO_ADVEN
                    NULL,                                                                   --IC_PERMITIR_CS
                    NULL,                                                                   --DH_LIBERACAO_TORRE_FRETES
                    NULL,                                                                   --DH_MODIFICACAO_TORRE_FRETES
                    NULL,                                                                   --DH_CONTRATACAO_TORRE_FRETES
                    NULL,                                                                   --CD_STATUS_TORRE_FRETES
                    NULL,                                                                   --VL_FRETE_CONTRATADO
                    NULL,                                                                   --IC_NAO_LIBERADA_SEM_PROTOCOLO
                    NULL,                                                                   --IC_ENTREGA_CADENCIADA_CLIENTE
                    NULL,                                                                   --IC_DIFICULDADE_CONTRATACAO
                    NULL,                                                                   --IC_OUTROS
                    NULL,                                                                   --CD_STATUS_CUSTOMER_SERVICE
                    NULL,                                                                   --CD_STATUS_TORRE_FRETES
                    NULL,                                                                   --CD_STATUS_CONTROLADORIA
                    'S',                                                                    --IC_ATIVO
                    NULL,                                                                   --SG_DESTINO_BACKLOG_CIF
                    NULL,                                                                   --CD_STATUS_BACKLOG_CIF
                    NULL,                                                                   --QT_AGENDADA_ANTERIOR
                    NULL,                                                                   --DH_BACKLOG_CIF
                    NULL,                                                                   --QT_BACKLOG_CIF
                    v_cd_elo_agendamento_destino,                                           --CD_ELO_AGENDAMENTO
                    NULL,                                                                   --QT_AGENDADA_REFRESH
                    NULL,                                                                   --CD_USUARIO_FABRICA
                    NULL,                                                                   --DH_FABRICA
                    NULL,                                                                   --CD_USUARIO_CORTADO_FABRICA
                    NULL,                                                                   --DH_CORTADO_FABRICA
                    NULL,                                                                   --CD_USUARIO_AJUSTE_SAP
                    NULL,                                                                   --DH_AJUSTE_SAP
                    NULL,                                                                   --CD_STATUS_LOGISTICA
                    NULL,                                                                   --IC_CORTADO_FABRICA
                    VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_COOPERATIVE(CS.CD_TIPO_CONTRATO),  --IC_COOPERATIVE
                    VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_SPLIT(CS.CD_TIPO_CONTRATO),        --IC_SPLIT
                    VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_FA(CS.CD_TIPO_CONTRATO),           --IC_FA
                    NULL,                                                                   --IC_EMERGENCIAL
                    cs.ds_roteiro_entrega,                                                  --DS_ROTEIRO_ENTREGA
                    NULL,                                                                   --CD_ELO_PRIORITY_OPTION
                    NULL,                                                                   --QT_AJUSTADA_FABRICA 
                    NULL,                                                                   --QT_AJUSTADA_SAP
                    vnd.gx_elo_agendamento.fx_is_doctype_export(cs.cd_tipo_contrato),       --IC_EXPORT
                    NULL,                                                                   --DS_CREDIT_BLOCK_REASON_R,
                    NULL,                                                                   --CD_STATUS_CEL_INITIAL,
                    NULL                                                                    --CD_STATUS_CEL_FINAL

            FROM vnd.elo_carteira_sap cs

           WHERE cs.cd_elo_carteira_sap = t_carteira_sap(i)
           ;
           
            MERGE INTO VND.ELO_CARTEIRA T_DESTINO
            USING
            (
                SELECT CA.CD_CLIENTE,
                       CA.CD_CLIENTE_PAGADOR,
                       CA.CD_CLIENTE_RECEBEDOR,
                       CA.CD_PRODUTO_SAP,
                       CA.CD_INCOTERMS,
                       SUM(CA.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA

                  FROM VND.ELO_CARTEIRA CA
                        
                 WHERE CA.CD_ELO_AGENDAMENTO = v_cd_elo_agendamento_destino
                   AND CA.CD_TIPO_AGENDAMENTO <> gx_elo_common.fx_elo_status('TIPAG','REPLAN')
                   AND CA.IC_ATIVO = 'S'
                   AND NVL(CA.QT_AGENDADA_CONFIRMADA, 0) > 0
                   AND CA.CD_ELO_CARTEIRA <> v_cd_elo_carteira_destino
                   
                 GROUP BY CA.CD_CLIENTE,
                          CA.CD_CLIENTE_PAGADOR,
                          CA.CD_CLIENTE_RECEBEDOR,
                          CA.CD_PRODUTO_SAP,
                          CA.CD_INCOTERMS
            ) T_FONTE
            ON (
                        T_DESTINO.CD_CLIENTE            = T_FONTE.CD_CLIENTE
                    AND T_DESTINO.CD_CLIENTE_PAGADOR    = T_FONTE.CD_CLIENTE_PAGADOR
                    AND T_DESTINO.CD_CLIENTE_RECEBEDOR  = T_FONTE.CD_CLIENTE_RECEBEDOR
                    AND T_DESTINO.CD_PRODUTO_SAP        = T_FONTE.CD_PRODUTO_SAP
                    AND T_DESTINO.CD_INCOTERMS          = T_FONTE.CD_INCOTERMS
                    AND T_DESTINO.CD_ELO_AGENDAMENTO    = v_cd_elo_agendamento_destino
                    AND T_DESTINO.CD_ELO_CARTEIRA       = v_cd_elo_carteira_destino
               )
               
            WHEN MATCHED THEN 
                UPDATE SET
                       T_DESTINO.QT_AGENDADA_ANTERIOR = T_FONTE.QT_AGENDADA_CONFIRMADA
            ;
        END LOOP;

       
        OPEN p_retorno FOR
        SELECT 'SUCCESS' FROM DUAL;
    END PI_REPLAN_SAP;
    
    
    
    PROCEDURE PX_ITENS_VERIFICAR (
        p_cd_week               IN  vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN  vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN  vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN  vnd.elo_agendamento.cd_machine%TYPE,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_retorno FOR
        SELECT ai.cd_elo_agendamento_item,
               ai.cd_elo_agendamento_item_antigo,
               ai.cd_cliente,
               CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.no_cliente_pagador
                    ELSE ca.no_cliente_recebedor
               END AS no_cliente,
               ai.cd_produto_sap,
               TO_CHAR(TO_NUMBER(ai.cd_produto_sap)) cd_produto_sap_s,
               ca.no_produto_sap,
               TO_CHAR(TO_NUMBER(ai.cd_produto_sap)) || ' - ' || ca.no_produto_sap cd_no_produto_sap,
               ai.cd_incoterms,
               ap.cd_sales_group,
               ca.no_sales_group,
               ap.cd_sales_group || ' - ' || ca.no_sales_group cd_no_sales_group,
               NVL(SUM(aw.qt_semana), 0) qt_semana
         
         FROM vnd.elo_agendamento ag
         
         INNER JOIN vnd.elo_agendamento_supervisor ap
            ON ap.cd_elo_agendamento = ag.cd_elo_agendamento
         
         INNER JOIN vnd.elo_agendamento_item ai
            ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
            
         INNER JOIN vnd.elo_carteira ca
            ON ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
            
          LEFT OUTER JOIN vnd.elo_agendamento_week aw
            ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
            
         WHERE ag.ic_ativo = 'S'
           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
           AND ag.cd_week = p_cd_week
           AND ai.cd_status_replan = vnd.gx_elo_common.fx_elo_status('APREP','RPNEW')
           
         GROUP BY ai.cd_elo_agendamento_item,
               ai.cd_elo_agendamento_item_antigo,
               ai.cd_cliente,
               CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.no_cliente_pagador
                    ELSE ca.no_cliente_recebedor
               END,
               ai.cd_produto_sap,
               ca.no_produto_sap,
               ai.cd_incoterms,
               ap.cd_sales_group,
               ca.no_sales_group
        ;
    END PX_ITENS_VERIFICAR;
    
    
    
    PROCEDURE PU_APROVAR_REPLAN (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_retorno                   OUT t_cursor
    )
    IS
    BEGIN
        UPDATE vnd.elo_carteira ca
           SET --ca.cd_status_torre_fretes        = vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),
               ca.cd_status_customer_service    = vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),
               ca.cd_status_logistica           = vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),
               ca.cd_status_controladoria       = vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),
               ca.cd_status_replan              = vnd.gx_elo_common.fx_elo_status('TWORK','APREP')--,
               --ca.dh_liberacao_torre_fretes     = CURRENT_DATE
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        UPDATE vnd.elo_agendamento_item ai
           SET ai.cd_status_replan = vnd.gx_elo_common.fx_elo_status('APREP','RPAPR')
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        OPEN p_retorno FOR
        SELECT 'SUCCESS' FROM DUAL;
    END PU_APROVAR_REPLAN;
    
    
    
    PROCEDURE PU_REPROVAR_REPLAN (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_retorno                   OUT t_cursor
    )
    IS
        v_cd_elo_agenditem_antigo vnd.elo_agendamento_item.cd_elo_agendamento_item_antigo%TYPE;
    BEGIN
        SELECT ai.cd_elo_agendamento_item_antigo
          INTO v_cd_elo_agenditem_antigo
          FROM vnd.elo_agendamento_item ai
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        IF v_cd_elo_agenditem_antigo IS NOT NULL THEN
            MERGE INTO vnd.elo_carteira ca
            USING
            (
                SELECT cd_elo_carteira_antigo,
                       qt_agendada_confirmada
                  FROM vnd.elo_carteira
                 WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
            ) ca_nova
            ON (ca.cd_elo_carteira = ca_nova.cd_elo_carteira_antigo)
               
            WHEN MATCHED THEN 
            UPDATE SET ca.qt_agendada_confirmada = ca_nova.qt_agendada_confirmada
            ;
        END IF;
        
        UPDATE vnd.elo_carteira ca
           SET ca.qt_agendada = NULL,
               ca.qt_agendada_confirmada = NULL,
               ca.cd_status_replan = vnd.gx_elo_common.fx_elo_status('TWORK','RPREP')
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        UPDATE vnd.elo_agendamento_item ai
           SET ai.cd_status_replan = vnd.gx_elo_common.fx_elo_status('APREP','RPREP')
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        COMMIT;
        
        OPEN p_retorno FOR
        SELECT 'SUCCESS' FROM DUAL;
    END PU_REPROVAR_REPLAN;
    
    
END GX_ELO_REPLAN_PROCESS;
/