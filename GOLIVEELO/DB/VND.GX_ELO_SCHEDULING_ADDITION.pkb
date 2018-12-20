CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_SCHEDULING_ADDITION AS

    --EXEMPLO DE USO "SELECT * FROM TABLE(GX_NOTA_FISCAL_V2.SPLIT('1;2;3;4;5;6;7;8;9',';'))"
    FUNCTION fx_split(
        p_lista       VARCHAR2,
        p_delimitador VARCHAR2 := ','
    ) RETURN t_vet_retorno PIPELINED
    IS
        lista_index PLS_INTEGER;
        lista       VARCHAR2(32767) := p_lista;
    BEGIN
        LOOP
            lista_index := INSTR(lista, p_delimitador);
            IF lista_index > 0 THEN
                PIPE ROW(SUBSTR(lista, 1, lista_index - 1));
                lista := SUBSTR(lista, lista_index + LENGTH(p_delimitador));
            ELSE
                PIPE ROW(lista);
                EXIT;
            END IF;
        END LOOP;
        RETURN;
    END fx_split;
    

    FUNCTION fx_split2 (
        list        IN VARCHAR2,
        delimiter   IN VARCHAR2 DEFAULT ','
    ) RETURN split_tbl
    AS
        splitted   split_tbl := split_tbl ();
        i          PLS_INTEGER := 0;
        list_      VARCHAR2(16000) := list;
    BEGIN
        LOOP
            i := INSTR(list_, delimiter);
            IF
                i > 0
            THEN
                splitted.EXTEND(1);
                splitted(splitted.LAST) := SUBSTR(
                    list_,
                    1,
                    i - 1
                );

                list_ := SUBSTR(
                    list_,
                    I + LENGTH(delimiter)
                );
            ELSE
                splitted.EXTEND(1);
                splitted(splitted.LAST) := list_;
                RETURN splitted;
            END IF;
        END LOOP;
    END fx_split2;


    PROCEDURE px_basic_data (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_clientes              OUT t_cursor,
        p_produto               OUT t_cursor,
        p_incoterms             OUT t_cursor,
        p_supervisors           OUT t_cursor
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
                
        OPEN p_clientes FOR
        SELECT DISTINCT 
               cs.CD_CLIENTE AS Id,
               CASE WHEN cs.CD_INCOTERMS = 'FOB' THEN cs.NO_CLIENTE_PAGADOR
                    ELSE cs.NO_CLIENTE_RECEBEDOR
               END AS Name
               
          FROM vnd.elo_carteira_sap cs
          
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY 2
        ; 
        
        OPEN p_produto FOR
        SELECT DISTINCT 
               cs.cd_produto_sap AS Id,
               cs.no_produto_sap,
               TO_CHAR(TO_NUMBER(cs.cd_produto_sap)) || ' - ' || cs.no_produto_sap AS Description
               
          FROM vnd.elo_carteira_sap cs
                
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY cs.NO_PRODUTO_SAP
        ; 
        
        OPEN P_INCOTERMS FOR
        SELECT DISTINCT 
               cs.cd_incoterms AS Id
               
          FROM vnd.elo_carteira_sap cs
                
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY cs.cd_incoterms
        ;
        
        OPEN P_SUPERVISORS FOR
        SELECT DISTINCT 
               cs.cd_sales_group AS Id,
               cs.cd_sales_group AS Code,
               cs.no_sales_group AS Name
               
          FROM vnd.elo_carteira_sap cs
                
         INNER JOIN vnd.elo_carteira_sap_tmp ct
            ON cs.cd_centro_expedidor = ct.cd_centro_expedidor
           AND cs.nu_carteira_version = ct.nu_carteira_version
                 
         ORDER BY cs.no_sales_group
        ; 
    END px_basic_data;


    PROCEDURE px_items_for_addition (
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
                   cs.cd_incoterms,
                   LISTAGG(cs.cd_elo_carteira_sap, ',') WITHIN GROUP (ORDER BY cd_elo_carteira_sap) AS cd_elo_carteira_sap
                   
              FROM vnd.elo_carteira_sap cs
                           
             WHERE (p_cd_cliente IS NULL OR cs.cd_cliente = p_cd_cliente)
               AND (p_cd_sales_group IS NULL OR cs.cd_sales_group = p_cd_sales_group)
               AND (p_cd_incoterms IS NULL OR cs.cd_incoterms = p_cd_incoterms)
               AND cs.cd_centro_expedidor || cs.nu_carteira_version in (select cd_centro_expedidor || nu_carteira_version from centro_cart)
             
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
        SELECT 
               -- Sales Group
               cs.cd_sales_group SalesGroupId,
               cs.cd_sales_group SalesGroupCode,
               cs.no_sales_group SalesGroupName,
               
               -- Customer
               cs.cd_cliente AS CustomerId,
               cs.no_cliente AS CustomerName,
               
               -- Product
               cs.cd_produto_sap AS ProductId,
               cs.no_produto_sap AS ProductDescription,
               
               -- Incoterms
               cs.cd_incoterms IncotermsId,
               
               -- Carteiras Ids
               cs.cd_elo_carteira_sap Ids
                             
          FROM cart_sap cs
                  
         WHERE p_cd_produto IS NULL OR cs.cd_produto_sap = p_cd_produto
         
         ORDER BY cs.cd_sales_group,
                  cs.cd_cliente,
                  cs.cd_produto_sap,
                  cs.cd_incoterms
        ;
    END px_items_for_addition;

    
    
    PROCEDURE pi_add_item (
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
        v_sg_status_destino             vnd.elo_status.sg_status%TYPE;
        v_cd_tipo_agendamento           vnd.elo_carteira.cd_tipo_agendamento%TYPE := NULL;
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
        
        SELECT ag.cd_elo_agendamento,
               es.sg_status
          INTO v_cd_elo_agendamento_destino,
               v_sg_status_destino
          FROM vnd.elo_agendamento ag
          LEFT OUTER JOIN
               vnd.elo_status es
               ON es.cd_elo_status = ag.cd_elo_status
         WHERE ag.ic_ativo = 'S'
           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
           AND ag.cd_week = p_cd_week
        ;
        
        v_count := 0;
--        SELECT COUNT(cd_elo_agendamento_item)
--          INTO v_count
--          FROM vnd.elo_agendamento_item ai
--         INNER JOIN 
--               vnd.elo_agendamento_supervisor ap
--               ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
--         INNER JOIN 
--               vnd.elo_carteira_sap cs
--               ON  ai.cd_produto_sap    = cs.cd_produto_sap
--               AND ai.cd_incoterms      = cs.cd_incoterms
--               AND ai.cd_cliente        = CASE WHEN cs.cd_incoterms = 'FOB' THEN cs.cd_cliente_pagador
--                                               ELSE cs.cd_cliente_recebedor
--                                          END
--         WHERE ap.cd_elo_agendamento = v_cd_elo_agendamento_destino
--           AND cs.cd_elo_carteira_sap IN (
--                    SELECT * FROM TABLE(gx_elo_scheduling_addition.fx_split(p_cd_elo_carteira_sap, ','))
--               )
--        ;
--
--        IF v_count > 0 THEN
--            OPEN p_retorno FOR
--            SELECT 'ITEMEXIST' FROM DUAL;
--            RETURN;
--        END IF;
        
        IF v_sg_status_destino = 'AGOPN' OR v_sg_status_destino = 'AGFIN' OR v_sg_status_destino = 'AGLOG' THEN
            v_cd_tipo_agendamento := vnd.gx_elo_common.fx_elo_status('TIPAG','ORIGINAL');
        ELSIF v_sg_status_destino = 'AGPRE' OR v_sg_status_destino = 'AGCEL' THEN
            v_cd_tipo_agendamento := vnd.gx_elo_common.fx_elo_status('TIPAG','INCLUSAO');
        END IF;
        
        -- 1) Busca ou cria o supervisor:
        SELECT COUNT(cd_elo_agendamento_supervisor)
          INTO v_count
          FROM vnd.elo_agendamento_supervisor ap
         INNER JOIN vnd.elo_carteira_sap cs
            ON cs.cd_sales_group = ap.cd_sales_group
         WHERE cs.cd_elo_carteira_sap IN (
                    SELECT * FROM TABLE(gx_elo_scheduling_addition.fx_split(p_cd_elo_carteira_sap, ','))
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
                        SELECT * FROM TABLE(gx_elo_scheduling_addition.fx_split(p_cd_elo_carteira_sap, ',')) 
                   )
            ;
        ELSE
            SELECT cd_elo_agendamento_supervisor
              INTO v_cd_elo_agendamento_superv
              FROM (
                        SELECT cd_elo_agendamento_supervisor
                          FROM vnd.elo_agendamento_supervisor ap
                         INNER JOIN vnd.elo_carteira_sap cs
                            ON cs.cd_sales_group = ap.cd_sales_group
                         WHERE cs.cd_elo_carteira_sap IN (
                                    SELECT * FROM TABLE(gx_elo_scheduling_addition.fx_split(p_cd_elo_carteira_sap, ',')) 
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
            cd_elo_agendamento_item_antigo,
            ic_adicao
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
               NULL,                                                --cd_status_replan
               NULL,                                                --cd_elo_agendamento_item_antigo
               'S'                                                  --ic_adicao
          FROM vnd.elo_carteira_sap cs
         WHERE cs.cd_elo_carteira_sap  IN (
                    SELECT * FROM TABLE(gx_elo_scheduling_addition.fx_split(p_cd_elo_carteira_sap, ',')) 
               )
        ;

        
        -- 3) Cria o registro na ELO_CARTEIRA copiando da ELO_CARTEIRA_SAP:
        t_carteira_sap := gx_elo_scheduling_addition.fx_split2(p_cd_elo_carteira_sap, ',');

        FOR i IN t_carteira_sap.FIRST..t_carteira_sap.LAST LOOP
            SELECT vnd.seq_elo_carteira.nextval
              INTO v_cd_elo_carteira_destino
              FROM dual
            ;
            
            INSERT INTO VND.ELO_CARTEIRA (
            /*001*/    CD_ELO_CARTEIRA,
            /*002*/    CD_CENTRO_EXPEDIDOR,
            /*003*/    DS_CENTRO_EXPEDIDOR,
            /*004*/    DH_CARTEIRA,
            /*005*/    CD_SALES_ORG,
            /*006*/    NU_CONTRATO_SAP,
            /*007*/    CD_TIPO_CONTRATO,
            /*008*/    NU_CONTRATO_SUBSTITUI,
            /*009*/    DT_PAGO,
            /*010*/    NU_CONTRATO,
            /*011*/    NU_ORDEM_VENDA,
            /*012*/    DS_STATUS_CONTRATO_SAP,
            /*013*/    CD_CLIENTE,
            /*014*/    NO_CLIENTE,
            /*015*/    CD_INCOTERMS,
            /*016*/    CD_SALES_DISTRICT,
            /*017*/    CD_SALES_OFFICE,
            /*018*/    NO_SALES_OFFICE,
            /*019*/    CD_SALES_GROUP,
            /*020*/    NO_SALES_GROUP,
            /*021*/    CD_AGENTE_VENDA,
            /*022*/    NO_AGENTE,
            /*023*/    DH_VENCIMENTO_PEDIDO,
            /*024*/    DT_CREDITO,
            /*025*/    DT_INICIO,
            /*026*/    DT_FIM,
            /*027*/    DH_INCLUSAO,
            /*028*/    DH_ENTREGA,
            /*029*/    SG_ESTADO,
            /*030*/    NO_MUNICIPIO,
            /*031*/    DS_BAIRRO,
            /*032*/    CD_PRODUTO_SAP,
            /*033*/    NO_PRODUTO_SAP,
            /*034*/    QT_PROGRAMADA,
            /*035*/    QT_ENTREGUE,
            /*036*/    QT_SALDO,
            /*037*/    VL_UNITARIO,
            /*038*/    VL_BRL,
            /*039*/    VL_TAXA_DOLAR,
            /*040*/    VL_USD,
            /*041*/    PC_COMISSAO,
            /*042*/    CD_SACARIA,
            /*043*/    DS_SACARIA,
            /*044*/    CD_CULTURA_SAP,
            /*045*/    DS_CULTURA_SAP,
            /*046*/    CD_BLOQUEIO_REMESSA,
            /*047*/    CD_BLOQUEIO_FATURAMENTO,
            /*048*/    CD_BLOQUEIO_CREDITO,
            /*049*/    CD_BLOQUEIO_REMESSA_ITEM,
            /*050*/    CD_BLOQUEIO_FATURAMENTO_ITEM,
            /*051*/    CD_MOTIVO_RECUSA,
            /*052*/    CD_LOGIN,
            /*053*/    CD_SEGMENTACAO_CLIENTE,
            /*054*/    DS_SEGMENTACAO_CLIENTE,
            /*055*/    DS_SEGMENTO_CLIENTE_SAP,
            /*056*/    CD_FORMA_PAGAMENTO,
            /*057*/    CD_TIPO_PAGAMENTO,
            /*058*/    DS_TIPO_PAGAMENTO,
            /*059*/    CD_AGRUPAMENTO,
            /*060*/    CD_BLOQUEIO_ENTREGA,
            /*061*/    NU_CNPJ,
            /*062*/    NU_CPF,
            /*063*/    NU_INSCRICAO_ESTADUAL,
            /*064*/    NU_INSCRICAO_MUNICIPAL,
            /*065*/    NU_CEP,
            /*066*/    DS_ENDERECO_RECEBEDOR,
            /*067*/    CD_CLIENTE_RECEBEDOR,
            /*068*/    NO_CLIENTE_RECEBEDOR,
            /*069*/    CD_MOEDA,
            /*070*/    CD_SUPPLY_GROUP,
            /*071*/    DS_VENDA_COMPARTILHADA,
            /*072*/    CD_STATUS_LIBERACAO,
            /*073*/    CD_ITEM_PEDIDO,
            /*074*/    CD_CLIENTE_PAGADOR,
            /*075*/    NO_CLIENTE_PAGADOR,
            /*076*/    CD_GRUPO_EMBALAGEM,
            /*077*/    DS_CREDIT_BLOCK_REASON,
            /*078*/    DH_CREDIT_BLOCK,
            /*079*/    CD_ITEM_CONTRATO,
            /*080*/    VL_FRETE_DISTRIBUICAO,
            /*081*/    DS_ENDERECO_PAGADOR,
            /*082*/    NO_SALES_DISTRICT,
                       -- Following fields do not come from ELO_CARTEIRA_SAP.
            /*083*/    CD_ELO_AGENDAMENTO_ITEM,
            /*084*/    IC_SEM_ORDEM_VENDA,
            /*085*/    IC_RELACIONAMENTO,
            /*086*/    NU_ORDEM,
            /*087*/    QT_AGENDADA,
            /*088*/    QT_AGENDADA_FABRICA,
            /*089*/    QT_AGENDADA_SAP,
            /*090*/    CD_USUARIO_REFRESH,
            /*091*/    DH_REFRESH,
            /*092*/    QT_PROGRAMADA_REFRESH,
            /*093*/    QT_ENTREGUE_REFRESH,
            /*094*/    QT_SALDO_REFRESH,
            /*095*/    QT_AGENDADA_CONFIRMADA,
            /*096*/    CD_TIPO_AGENDAMENTO,
            /*097*/    CD_TIPO_REPLAN,
            /*098*/    DH_REPLAN,
            /*099*/    CD_STATUS_REPLAN,
            /*100*/    CD_BLOQUEIO_REMESSA_R,
            /*101*/    CD_BLOQUEIO_FATURAMENTO_R,
            /*102*/    CD_BLOQUEIO_CREDITO_R,
            /*103*/    CD_BLOQUEIO_REMESSA_ITEM_R,
            /*104*/    CD_BLOQUEIO_FATURAMENTO_ITEM_R,
            /*105*/    DS_OBSERVACAO_ADVEN,
            /*106*/    IC_PERMITIR_CS,
            /*107*/    DH_LIBERACAO_TORRE_FRETES,
            /*108*/    DH_MODIFICACAO_TORRE_FRETES,
            /*109*/    DH_CONTRATACAO_TORRE_FRETES,
            /*110*/    CD_ELO_FREIGHT_TOWER_REASON,
            /*111*/    VL_FRETE_CONTRATADO,
            /*112*/    IC_NAO_LIBERADA_SEM_PROTOCOLO,
            /*113*/    IC_ENTREGA_CADENCIADA_CLIENTE,
            /*114*/    IC_DIFICULDADE_CONTRATACAO,
            /*115*/    IC_OUTROS,
            /*116*/    CD_STATUS_CUSTOMER_SERVICE,
            /*117*/    CD_STATUS_TORRE_FRETES,
            /*118*/    CD_STATUS_CONTROLADORIA,
            /*119*/    IC_ATIVO,
            /*120*/    SG_DESTINO_BACKLOG_CIF,
            /*121*/    CD_STATUS_BACKLOG_CIF,
            /*122*/    QT_AGENDADA_ANTERIOR,
            /*123*/    DH_BACKLOG_CIF,
            /*124*/    QT_BACKLOG_CIF,
            /*125*/    CD_ELO_AGENDAMENTO,
            /*126*/    QT_AGENDADA_REFRESH,
            /*127*/    CD_USUARIO_FABRICA,
            /*128*/    DH_FABRICA,
            /*129*/    CD_USUARIO_CORTADO_FABRICA,
            /*130*/    DH_CORTADO_FABRICA,
            /*131*/    CD_USUARIO_AJUSTE_SAP,
            /*132*/    DH_AJUSTE_SAP,
            /*133*/    CD_STATUS_LOGISTICA,
            /*134*/    IC_CORTADO_FABRICA,
            /*135*/    IC_COOPERATIVE,
            /*136*/    IC_SPLIT,
            /*137*/    IC_FA,
            /*138*/    IC_EMERGENCIAL,
            /*139*/    DS_ROTEIRO_ENTREGA,
            /*140*/    CD_ELO_PRIORITY_OPTION,
            /*141*/    QT_AJUSTADA_FABRICA,
            /*142*/    QT_AJUSTADA_SAP,
            /*143*/    IC_EXPORT,
            /*144*/    DS_CREDIT_BLOCK_REASON_R,
            /*145*/    CD_STATUS_CEL_INITIAL,
            /*146*/    CD_STATUS_CEL_FINAL
            )
            SELECT
            /*001*/        v_cd_elo_carteira_destino,
            /*002*/        CS.CD_CENTRO_EXPEDIDOR,
            /*003*/        CS.DS_CENTRO_EXPEDIDOR,
            /*004*/        CS.DH_CARTEIRA,
            /*005*/        CS.CD_SALES_ORG,
            /*006*/        CS.NU_CONTRATO_SAP,
            /*007*/        CS.CD_TIPO_CONTRATO,
            /*008*/        CS.NU_CONTRATO_SUBSTITUI,
            /*009*/        CS.DT_PAGO,
            /*010*/        CS.NU_CONTRATO,
            /*011*/        CS.NU_ORDEM_VENDA,
            /*012*/        CS.DS_STATUS_CONTRATO_SAP,
            /*013*/        CS.CD_CLIENTE,
            /*014*/        CS.NO_CLIENTE,
            /*015*/        CS.CD_INCOTERMS,
            /*016*/        CS.CD_SALES_DISTRICT,
            /*017*/        CS.CD_SALES_OFFICE,
            /*018*/        CS.NO_SALES_OFFICE,
            /*019*/        CS.CD_SALES_GROUP,
            /*020*/        CS.NO_SALES_GROUP,
            /*021*/        CS.CD_AGENTE_VENDA,
            /*022*/        CS.NO_AGENTE,
            /*023*/        CS.DH_VENCIMENTO_PEDIDO,
            /*024*/        CS.DT_CREDITO,
            /*025*/        CS.DT_INICIO,
            /*026*/        CS.DT_FIM,
            /*027*/        CS.DH_INCLUSAO,
            /*028*/        CS.DH_ENTREGA,
            /*029*/        CS.SG_ESTADO,
            /*030*/        CS.NO_MUNICIPIO,
            /*031*/        CS.DS_BAIRRO,
            /*032*/        CS.CD_PRODUTO_SAP,
            /*033*/        CS.NO_PRODUTO_SAP,
            /*034*/        CS.QT_PROGRAMADA,
            /*035*/        CS.QT_ENTREGUE,
            /*036*/        CS.QT_SALDO,
            /*037*/        CS.VL_UNITARIO,
            /*038*/        CS.VL_BRL,
            /*039*/        CS.VL_TAXA_DOLAR,
            /*040*/        CS.VL_USD,
            /*041*/        CS.PC_COMISSAO,
            /*042*/        CS.CD_SACARIA,
            /*043*/        CS.DS_SACARIA,
            /*044*/        CS.CD_CULTURA_SAP,
            /*045*/        CS.DS_CULTURA_SAP,
            /*046*/        CS.CD_BLOQUEIO_REMESSA,
            /*047*/        CS.CD_BLOQUEIO_FATURAMENTO,
            /*048*/        CS.CD_BLOQUEIO_CREDITO,
            /*049*/        CS.CD_BLOQUEIO_REMESSA_ITEM,
            /*050*/        CS.CD_BLOQUEIO_FATURAMENTO_ITEM,
            /*051*/        CS.CD_MOTIVO_RECUSA,
            /*052*/        CS.CD_LOGIN,
            /*053*/        CS.CD_SEGMENTACAO_CLIENTE,
            /*054*/        CS.DS_SEGMENTACAO_CLIENTE,
            /*055*/        CS.DS_SEGMENTO_CLIENTE_SAP,
            /*056*/        CS.CD_FORMA_PAGAMENTO,
            /*057*/        CS.CD_TIPO_PAGAMENTO,
            /*058*/        CS.DS_TIPO_PAGAMENTO,
            /*059*/        CS.CD_AGRUPAMENTO,
            /*060*/        CS.CD_BLOQUEIO_ENTREGA,
            /*061*/        CS.NU_CNPJ,
            /*062*/        CS.NU_CPF,
            /*063*/        CS.NU_INSCRICAO_ESTADUAL,
            /*064*/        CS.NU_INSCRICAO_MUNICIPAL,
            /*065*/        CS.NU_CEP,
            /*066*/        CS.DS_ENDERECO_RECEBEDOR,
            /*067*/        CS.CD_CLIENTE_RECEBEDOR,
            /*068*/        CS.NO_CLIENTE_RECEBEDOR,
            /*069*/        CS.CD_MOEDA,
            /*070*/        CS.CD_SUPPLY_GROUP,
            /*071*/        CS.DS_VENDA_COMPARTILHADA,
            /*072*/        CS.CD_STATUS_LIBERACAO,
            /*073*/        CS.CD_ITEM_PEDIDO,
            /*074*/        CS.CD_CLIENTE_PAGADOR,
            /*075*/        CS.NO_CLIENTE_PAGADOR,
            /*076*/        CS.CD_GRUPO_EMBALAGEM,
            /*077*/        CS.DS_CREDIT_BLOCK_REASON,
            /*078*/        CS.DH_CREDIT_BLOCK,
            /*079*/        CS.CD_ITEM_CONTRATO,
            /*080*/        CS.VL_FRETE_DISTRIBUICAO,
            /*081*/        CS.DS_ENDERECO_PAGADOR,
            /*082*/        CS.NO_SALES_DISTRICT,
                           -- Following fields do not come from ELO_CARTEIRA_SAP.
            /*083*/        v_cd_elo_agendamento_item_dest,                                         --CD_ELO_AGENDAMENTO_ITEM
            /*084*/        CASE 
                               WHEN cs.nu_ordem_venda IS NULL OR TRIM(cs.nu_ordem_venda) = '' THEN 'S'
                               ELSE 'N'
                           END,                                                                    --IC_SEM_ORDEM_VENDA
            /*085*/        'N',                                                                    --IC_RELACIONAMENTO
            /*086*/        NULL,                                                                   --NU_ORDEM
            /*087*/        NULL,                                                                   --QT_AGENDADA
            /*088*/        NULL,                                                                   --QT_AGENDADA_FABRICA
            /*089*/        NULL,                                                                   --QT_AGENDADA_SAP
            /*090*/        NULL,                                                                   --CD_USUARIO_REFRESH
            /*091*/        NULL,                                                                   --DH_REFRESH
            /*092*/        NULL,                                                                   --QT_PROGRAMADA_REFRESH
            /*093*/        NULL,                                                                   --QT_ENTREGUE_REFRESH
            /*094*/        NULL,                                                                   --QT_SALDO_REFRESH
            /*095*/        NULL,                                                                   --QT_AGENDADA_CONFIRMADA
            /*096*/        v_cd_tipo_agendamento,                                                  --CD_TIPO_AGENDAMENTO
            /*097*/        NULL,                                                                   --CD_TIPO_REPLAN
            /*098*/        SYSDATE,                                                                --DH_REPLAN
            /*099*/        NULL,                                                                   --CD_STATUS_REPLAN
            /*100*/        NULL,                                                                   --CD_BLOQUEIO_REMESSA_R
            /*101*/        NULL,                                                                   --CD_BLOQUEIO_FATURAMENTO_R
            /*102*/        NULL,                                                                   --CD_BLOQUEIO_CREDITO_R
            /*103*/        NULL,                                                                   --CD_BLOQUEIO_REMESSA_ITEM_R
            /*104*/        NULL,                                                                   --CD_BLOQUEIO_FATURAMENTO_ITEM_R
            /*105*/        NULL,                                                                   --DS_OBSERVACAO_ADVEN
            /*106*/        NULL,                                                                   --IC_PERMITIR_CS
            /*107*/        NULL,                                                                   --DH_LIBERACAO_TORRE_FRETES
            /*108*/        NULL,                                                                   --DH_MODIFICACAO_TORRE_FRETES
            /*109*/        NULL,                                                                   --DH_CONTRATACAO_TORRE_FRETES
            /*110*/        NULL,                                                                   --CD_ELO_FREIGHT_TOWER_REASON
            /*111*/        NULL,                                                                   --VL_FRETE_CONTRATADO
            /*112*/        NULL,                                                                   --IC_NAO_LIBERADA_SEM_PROTOCOLO
            /*113*/        NULL,                                                                   --IC_ENTREGA_CADENCIADA_CLIENTE
            /*114*/        NULL,                                                                   --IC_DIFICULDADE_CONTRATACAO
            /*115*/        NULL,                                                                   --IC_OUTROS
            /*116*/        vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),                       --CD_STATUS_CUSTOMER_SERVICE
            /*117*/        vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),                       --CD_STATUS_TORRE_FRETES
            /*118*/        NULL,                                                                   --CD_STATUS_CONTROLADORIA
            /*119*/        'S',                                                                    --IC_ATIVO
            /*120*/        NULL,                                                                   --SG_DESTINO_BACKLOG_CIF
            /*121*/        NULL,                                                                   --CD_STATUS_BACKLOG_CIF
            /*122*/        NULL,                                                                   --QT_AGENDADA_ANTERIOR
            /*123*/        NULL,                                                                   --DH_BACKLOG_CIF
            /*124*/        NULL,                                                                   --QT_BACKLOG_CIF
            /*125*/        v_cd_elo_agendamento_destino,                                           --CD_ELO_AGENDAMENTO
            /*126*/        NULL,                                                                   --QT_AGENDADA_REFRESH
            /*127*/        NULL,                                                                   --CD_USUARIO_FABRICA
            /*128*/        NULL,                                                                   --DH_FABRICA
            /*129*/        NULL,                                                                   --CD_USUARIO_CORTADO_FABRICA
            /*130*/        NULL,                                                                   --DH_CORTADO_FABRICA
            /*131*/        NULL,                                                                   --CD_USUARIO_AJUSTE_SAP
            /*132*/        NULL,                                                                   --DH_AJUSTE_SAP
            /*133*/        vnd.gx_elo_common.fx_elo_status('CARTE','CANEW'),                       --CD_STATUS_LOGISTICA
            /*134*/        NULL,                                                                   --IC_CORTADO_FABRICA
            /*135*/        VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_COOPERATIVE(CS.CD_TIPO_CONTRATO),  --IC_COOPERATIVE
            /*136*/        VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_SPLIT(CS.CD_TIPO_CONTRATO),        --IC_SPLIT
            /*137*/        VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_FA(CS.CD_TIPO_CONTRATO),           --IC_FA
            /*138*/        NULL,                                                                   --IC_EMERGENCIAL
            /*139*/        cs.ds_roteiro_entrega,                                                  --DS_ROTEIRO_ENTREGA
            /*140*/        NULL,                                                                   --CD_ELO_PRIORITY_OPTION
            /*141*/        NULL,                                                                   --QT_AJUSTADA_FABRICA 
            /*142*/        NULL,                                                                   --QT_AJUSTADA_SAP
            /*143*/        vnd.gx_elo_agendamento.fx_is_doctype_export(cs.cd_tipo_contrato),       --IC_EXPORT
            /*144*/        NULL,                                                                   --DS_CREDIT_BLOCK_REASON_R,
            /*145*/        NULL,                                                                   --CD_STATUS_CEL_INITIAL,
            /*146*/        NULL                                                                    --CD_STATUS_CEL_FINAL
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
        
    EXCEPTION
        WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, SQLCODE || SQLERRM);
        ROLLBACK;
    END pi_add_item;

    
    PROCEDURE px_carteira_sap (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_number_of_records     IN NUMBER,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_retorno FOR
        SELECT *
          FROM (
                    SELECT nu_carteira_version  AS "Version",
                           dh_carteira          AS "Date"
                      FROM vnd.elo_carteira_sap cs
                      LEFT OUTER JOIN 
                           ctf.polo_centro_expedidor pc
                           ON pc.cd_centro_expedidor = cs.cd_centro_expedidor
                      LEFT OUTER JOIN 
                           ctf.centro_expedidor_machine cm
                           ON cm.cd_centro_expedidor = cs.cd_centro_expedidor
                     WHERE 
                               (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
                           AND (p_cd_centro_expedidor IS NULL OR cs.cd_centro_expedidor = p_cd_centro_expedidor)
                           AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
                     GROUP BY cs.nu_carteira_version,
                              dh_carteira
                     ORDER BY cs.nu_carteira_version DESC
               )
         WHERE ROWNUM <= p_number_of_records
        ;
    END px_carteira_sap;
    
    
    PROCEDURE px_incoterms (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN       
        OPEN p_retorno FOR
        SELECT DISTINCT 
               cs.cd_incoterms AS Id
               
          FROM vnd.elo_carteira_sap cs
                
          LEFT OUTER JOIN 
               ctf.polo_centro_expedidor pc
               ON pc.cd_centro_expedidor = cs.cd_centro_expedidor
               
          LEFT OUTER JOIN 
               ctf.centro_expedidor_machine cm
               ON cm.cd_centro_expedidor = cs.cd_centro_expedidor
         WHERE 
               (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR cs.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
           AND cs.nu_carteira_version = p_nu_carteira_version
                 
         ORDER BY cs.cd_incoterms
        ;
    END px_incoterms;
    
    
    PROCEDURE px_products (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN       
        OPEN p_retorno FOR
        SELECT DISTINCT 
               cs.cd_produto_sap AS Id,
               cs.no_produto_sap,
               TO_CHAR(TO_NUMBER(cs.cd_produto_sap)) || ' - ' || cs.no_produto_sap AS Description
               
          FROM vnd.elo_carteira_sap cs
          
          LEFT OUTER JOIN 
               ctf.polo_centro_expedidor pc
               ON pc.cd_centro_expedidor = cs.cd_centro_expedidor
               
          LEFT OUTER JOIN 
               ctf.centro_expedidor_machine cm
               ON cm.cd_centro_expedidor = cs.cd_centro_expedidor
         WHERE 
               (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR cs.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
           AND cs.nu_carteira_version = p_nu_carteira_version
                 
         ORDER BY cs.no_produto_sap
        ; 
    END px_products;
    
    
    PROCEDURE px_customers (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN       
        OPEN p_retorno FOR
        SELECT DISTINCT 
               cs.CD_CLIENTE AS Id,
               CASE WHEN cs.CD_INCOTERMS = 'FOB' THEN cs.NO_CLIENTE_PAGADOR
                    ELSE cs.NO_CLIENTE_RECEBEDOR
               END AS Name
               
          FROM vnd.elo_carteira_sap cs
          
          LEFT OUTER JOIN 
               ctf.polo_centro_expedidor pc
               ON pc.cd_centro_expedidor = cs.cd_centro_expedidor
               
          LEFT OUTER JOIN 
               ctf.centro_expedidor_machine cm
               ON cm.cd_centro_expedidor = cs.cd_centro_expedidor
         WHERE 
               (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR cs.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
           AND cs.nu_carteira_version = p_nu_carteira_version
                 
         ORDER BY 2
        ; 
    END px_customers;
    
    
    PROCEDURE px_supervisors (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    )
    IS
    BEGIN       
        OPEN p_retorno FOR
        SELECT DISTINCT 
               cs.cd_sales_group AS Id,
               cs.cd_sales_group AS Code,
               cs.no_sales_group AS Name
               
          FROM vnd.elo_carteira_sap cs
                
          LEFT OUTER JOIN 
               ctf.polo_centro_expedidor pc
               ON pc.cd_centro_expedidor = cs.cd_centro_expedidor
               
          LEFT OUTER JOIN 
               ctf.centro_expedidor_machine cm
               ON cm.cd_centro_expedidor = cs.cd_centro_expedidor
         WHERE 
               (p_cd_polo IS NULL OR pc.cd_polo = p_cd_polo)
           AND (p_cd_centro_expedidor IS NULL OR cs.cd_centro_expedidor = p_cd_centro_expedidor)
           AND (p_cd_machine IS NULL OR cm.cd_machine = p_cd_machine)
           AND cs.nu_carteira_version = p_nu_carteira_version
                 
         ORDER BY cs.no_sales_group
        ; 
    END px_supervisors;

    
    
END GX_ELO_SCHEDULING_ADDITION;
/