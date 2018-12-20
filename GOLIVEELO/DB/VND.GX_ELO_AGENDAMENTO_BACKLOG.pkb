    CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_AGENDAMENTO_BACKLOG" IS


    PROCEDURE PI_BACKLOG (
        P_WEEKS_REF IN NUMBER
    )
    IS
    BEGIN
        PI_BACKLOG_PROTOCOLOS(P_WEEKS_REF);
        PI_NAO_VO_NAO_DESDOBRO(P_WEEKS_REF);
        PI_DESDOBRO(P_WEEKS_REF);
    END PI_BACKLOG;
    
    

    PROCEDURE PI_BACKLOG_PROTOCOLOS (
        P_WEEKS_REF IN NUMBER
    )
    IS
    BEGIN
        
        INSERT INTO VND.ELO_AGENDAMENTO_BACKLOG (
            CD_ELO_AGENDAMENTO_BACKLOG,
            CD_WEEK,
            CD_WEEK_REF,
            DT_WEEK_START,
            DT_WEEK_START_REF,
            SG_TIPO_DOCUMENTO,
            NU_DOCUMENTO,
            NU_ITEM_DOCUMENTO,
            QT_FORNECIDA,
            QT_BACKLOG,
            QT_BACKLOG_CONFIRMADA,
            QT_CONTRATADA,
            QT_AGENDADA_SEMANA_2,
            QT_REJEITADA_SEMANA_2,
            DH_BACKLOG
        )
        SELECT vnd.seq_elo_agendamento_backlog.nextval,
               'W' || TO_CHAR(dt_week_start, 'IW') || TO_CHAR(dt_week_start, 'RRRR')        AS cd_week,
               'W' || TO_CHAR(dt_week_start_1, 'IW') || TO_CHAR(dt_week_start_1, 'RRRR')    AS cd_week_ref,
               dt_week_start,
               dt_week_start_1                                                              AS dt_week_start_ref,
               'P'                                                                          AS sg_tipo_documento,
               nu_documento,
               NULL                                                                         AS nu_item_documento,
               G10                                                                          AS Fornecido_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                              AS Backlog_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                              AS BacklogConfirmada_0,
               F10                                                                          AS Contratada_0,
               I6                                                                           AS Agendado_2,
               0/*M8*/                                                                      AS Rejeitado_2,
               CURRENT_DATE                                                                 AS DataBacklog_0
          FROM (
                    WITH datAS AS 
                    (
                        SELECT 
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref))          AS dt_week_start,       -- EXE
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 7      AS dt_week_start_now,   -- G6, J8
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 14     AS dt_week_start_1      -- REF, I6, G8, M8
                          FROM dual
                    ),
                    agend AS 
                    (
                        SELECT 
                               -- Protocolo no ELO na Semana - 2
                               vp.NU_PROTOCOLO                          NU_DOCUMENTO, 
                               NVL(SUM(vp.QT_AGENDADA_PROTOCOLO), 0)    QT_AGENDADA, 
                               
                               -- Agendamento na Semana - 2
                               ag.DT_WEEK_START                         DT_WEEK_START,
                               ag.CD_WEEK                               CD_WEEK,
                               
                               -- Protocolo no MOL na Semana - 0 (esta semana)
                               NVL(MAX(en.QT_QUANTIDADE), 0)            QT_QUANTIDADE,
                               NVL(MAX(en.QT_FORNECIDO), 0)             QT_FORNECIDO
                               
                          FROM vnd.elo_vbak_protocolo vp
                         
                         INNER JOIN 
                               vnd.elo_carteira ca
                               ON ca.cd_elo_carteira = vp.cd_elo_carteira
                         
                         INNER JOIN
                               vnd.elo_agendamento ag
                               ON ag.cd_elo_agendamento = ca.cd_elo_agendamento
                              
                         LEFT OUTER JOIN
                               cpt.entrega en
                               ON vp.nu_protocolo = en.nu_protocolo_entrega
                                  
                             WHERE ag.dt_week_start = (SELECT dt_week_start_1 FROM datas)
                               AND ag.ic_ativo = 'S'
                               AND vp.ic_ativo = 'S'
                               AND NVL(vp.qt_agendada_protocolo, 0) > 0
                               AND en.sg_status NOT IN ('P', 'C')
                               
                             group by vp.NU_PROTOCOLO,
                                      ag.DT_WEEK_START,
                                      ag.CD_WEEK
                    ),
                    -- Para G6, J8
                    bklog AS 
                    (
                        SELECT nu_documento,
                               qt_fornecida,
                               qt_backlog_confirmada
                          FROM vnd.elo_agendamento_backlog
                         WHERE dt_week_start = (SELECT dt_week_start_now FROM datas)
                           AND sg_tipo_documento = 'P'
                    )

                    SELECT datas.*,
                           ag.NU_DOCUMENTO,
                           NVL(ag.QT_AGENDADA, 0)           AS I6,     --Agendado na semana - 2
                           NVL(bl.QT_FORNECIDA, 0)          AS G6,     --Fornecido na semana - 2
                           NVL(ag.QT_FORNECIDO, 0)          AS G8,     --Fornecido na semana - 1
                           NVL(bl.QT_BACKLOG_CONFIRMADA, 0) AS J8,     --Backlog na semana - 1
                           NVL(ag.QT_QUANTIDADE, 0)         AS F10,    --Contratado na semana - 0 (esta semana)
                           NVL(ag.QT_FORNECIDO, 0)          AS G10     --Fornecido na semana - 0 (esta semana)
                           
                      FROM agend ag
                      
                     INNER JOIN 
                           datas
                           ON ag.dt_week_start = datas.dt_week_start_1
                      
                      LEFT OUTER JOIN 
                           bklog bl
                           ON bl.nu_documento = ag.nu_documento                
               )
         WHERE NVL(GREATEST((I6+J8-(G8-G6)/*-M8*/), 0), 0) > 0
        ;
        
        COMMIT;
        
        -- Legado da semana anterior.

        INSERT INTO VND.ELO_AGENDAMENTO_BACKLOG (
            CD_ELO_AGENDAMENTO_BACKLOG,
            CD_WEEK,
            CD_WEEK_REF,
            DT_WEEK_START,
            DT_WEEK_START_REF,
            SG_TIPO_DOCUMENTO,
            NU_DOCUMENTO,
            NU_ITEM_DOCUMENTO,
            QT_FORNECIDA,
            QT_BACKLOG,
            QT_BACKLOG_CONFIRMADA,
            QT_CONTRATADA,
            QT_AGENDADA_SEMANA_2,
            QT_REJEITADA_SEMANA_2,
            DH_BACKLOG
        )
        SELECT vnd.seq_elo_agendamento_backlog.nextval,
               'W' || TO_CHAR(dt_week_start, 'IW') || TO_CHAR(dt_week_start, 'RRRR')        AS cd_week,
               'W' || TO_CHAR(dt_week_start_1, 'IW') || TO_CHAR(dt_week_start_1, 'RRRR')    AS cd_week_ref,
               dt_week_start,
               dt_week_start_1                                                              AS dt_week_start_ref,
               'P'                                                                          AS sg_tipo_documento,
               nu_documento,
               NULL                                                                         AS nu_item_documento,
               G10                                                                          AS Fornecido_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               F10                                                                          AS Contratada_0,
               I6                                                                           AS Agendado_2,
               0/*M8*/                                                                      AS Rejeitado_2,
               CURRENT_DATE                                                                 AS DataBacklog_0
          FROM (
                    WITH datAS AS 
                    (
                        SELECT 
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref))          AS dt_week_start,       -- EXE
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 7      AS dt_week_start_now,   -- G6, J8
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 14     AS dt_week_start_1      -- REF, I6, G8, M8
                          FROM dual
                    )
                    SELECT datas.*,
                           bl.nu_documento,
                           bl.qt_fornecida                  AS G6,
                           NVL(en.qt_fornecido, 0)          AS G8,
                           0/*bl.QT_AGENDADA_SEMANA_2*/     AS I6,
                           bl.qt_backlog_confirmada         AS J8,
                           NVL(en.qt_quantidade, 0)         AS F10,
                           NVL(en.qt_fornecido, 0)          AS G10
                           
                      FROM vnd.elo_agendamento_backlog bl
                     INNER JOIN datas
                           ON bl.dt_week_start = datas.dt_week_start_now
                     INNER JOIN
                           cpt.entrega en
                           ON en.nu_protocolo_entrega = bl.nu_documento
                           
                     WHERE bl.nu_documento NOT IN (
                                SELECT nu_documento
                                  FROM vnd.elo_agendamento_backlog bl
                                 WHERE bl.dt_week_start = datas.dt_week_start
                                   AND bl.sg_tipo_documento = 'P'
                           )
                       AND bl.sg_tipo_documento = 'P'
                       --AND en.sg_status NOT IN ('P', 'C')
               ) x
         WHERE GREATEST((I6+J8-(G8-G6)/*-M8*/), 0) > 0
        ;
        
        COMMIT;
    END PI_BACKLOG_PROTOCOLOS;
    
    
    PROCEDURE PI_NAO_VO_NAO_DESDOBRO (
        P_WEEKS_REF IN NUMBER
    )
    IS
    BEGIN
        INSERT INTO VND.ELO_AGENDAMENTO_BACKLOG (
            CD_ELO_AGENDAMENTO_BACKLOG,
            CD_WEEK,
            CD_WEEK_REF,
            DT_WEEK_START,
            DT_WEEK_START_REF,
            SG_TIPO_DOCUMENTO,
            NU_DOCUMENTO,
            NU_ITEM_DOCUMENTO,
            QT_FORNECIDA,
            QT_BACKLOG,
            QT_BACKLOG_CONFIRMADA,
            QT_CONTRATADA,
            QT_AGENDADA_SEMANA_2,
            QT_REJEITADA_SEMANA_2,
            DH_BACKLOG
        )
        SELECT vnd.seq_elo_agendamento_backlog.nextval,
               'W' || TO_CHAR(dt_week_start, 'IW') || TO_CHAR(dt_week_start, 'RRRR')        AS cd_week,
               'W' || TO_CHAR(dt_week_start_1, 'IW') || TO_CHAR(dt_week_start_1, 'RRRR')    AS cd_week_ref,
               dt_week_start,
               dt_week_start_1                                                              AS dt_week_start_ref,
               'C'                                                                          AS sg_tipo_documento,
               nu_documento,
               nu_item_documento,
               G10                                                                          AS Fornecido_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS BacklogConfirmada_0,
               F10                                                                          AS Contratada_0,
               I6                                                                           AS Agendado_2,
               0/*M8*/                                                                      AS Rejeitado_2,
               CURRENT_DATE                                                                 AS DataBacklog_0
          FROM (
                    WITH datAS AS 
                    (
                        SELECT 
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref))          AS dt_week_start,       -- EXE
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 7      AS dt_week_start_now,   -- G6, J8
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 14     AS dt_week_start_1      -- REF, I6, G8, M8
                          FROM dual
                    ),
                    agend AS 
                    (
                        SELECT 
                               -- Documento no ELO na Semana - 2
                               ca.nu_contrato_sap                       NU_DOCUMENTO,
                               ca.cd_item_contrato                      NU_ITEM_DOCUMENTO,
                               NVL(SUM(ca.qt_agendada_confirmada), 0)   QT_AGENDADA,
                               
                               -- Agendamento na Semana - 2
                               ag.DT_WEEK_START                         DT_WEEK_START,
                               ag.CD_WEEK                               CD_WEEK,

                               -- Documento no MOL na Semana - 0 (esta semana)
                               NVL(MAX(ic.NU_QUANTIDADE), 0)            QT_QUANTIDADE,
                               NVL(MAX(ic.NU_QTY_DELIVERED), 0)         QT_FORNECIDO
                               
                          FROM vnd.elo_carteira ca
                         INNER JOIN
                               vnd.elo_agendamento ag
                               ON ag.cd_elo_agendamento = ca.cd_elo_agendamento
                         INNER JOIN
                               (
                                    SELECT distinct cd_tipo_ordem 
                                      FROM tipo_ordem
                                     WHERE ic_split <> 'S'
                                       AND ic_cooperative <> 'S'
                               ) tm
                               ON tm.cd_tipo_ordem = ca.cd_tipo_contrato
                         LEFT OUTER JOIN
                               vnd.contrato co
                               ON co.nu_contrato_sap = ca.nu_contrato_sap
                         LEFT OUTER JOIN
                               vnd.item_contrato ic
                               ON ic.cd_contrato = co.cd_contrato
                              AND ic.cd_item_contrato = ca.cd_item_contrato
                              
                         WHERE ag.dt_week_start = (SELECT dt_week_start_1 FROM datas)
                           AND ag.ic_ativo = 'S'
                           AND ca.ic_ativo = 'S'
                           AND co.ic_ativo = 'S'
                           AND ca.cd_incoterms = 'CIF'
                           AND co.cd_incoterms = 'CIF'
                           AND NVL(ca.qt_agendada_confirmada, 0) > 0
                           
                         group by ca.nu_contrato_sap,
                                  ca.cd_item_contrato,
                                  ag.dt_week_start,
                                  ag.cd_week
                    ),
                    -- Para G6, J8
                    bklog AS 
                    (
                        SELECT nu_documento,
                               nu_item_documento,
                               qt_fornecida,
                               qt_backlog_confirmada
                          FROM vnd.elo_agendamento_backlog
                         WHERE dt_week_start = (SELECT dt_week_start_now FROM datas)
                           AND sg_tipo_documento = 'C'
                    )
                                  
                    SELECT datas.*,
                           ag.NU_DOCUMENTO,
                           ag.NU_ITEM_DOCUMENTO,
                           NVL(ag.QT_AGENDADA, 0)           AS I6,     --Agendado na semana - 2
                           NVL(bl.QT_FORNECIDA, 0)          AS G6,     --Fornecido na semana - 2
                           NVL(ag.QT_FORNECIDO, 0)          AS G8,     --Fornecido na semana - 1
                           NVL(bl.QT_BACKLOG_CONFIRMADA, 0) AS J8,     --Backlog na semana - 1
                           NVL(ag.QT_QUANTIDADE, 0)         AS F10,    --Contratado na semana - 0 (esta semana)
                           NVL(ag.QT_FORNECIDO, 0)          AS G10     --Fornecido na semana - 0 (esta semana)
                           
                      FROM agend ag
                      
                     INNER JOIN 
                           datas
                           ON ag.dt_week_start = datas.dt_week_start_1
                      
                      LEFT OUTER JOIN 
                           bklog bl
                           ON bl.nu_documento = ag.nu_documento
                          AND bl.nu_item_documento = ag.nu_item_documento
               )
         WHERE NVL(GREATEST((I6+J8-(G8-G6)/*-M8*/), 0), 0) > 0
        ;
        
        COMMIT;

        -- Legado da semana anterior.

        INSERT INTO VND.ELO_AGENDAMENTO_BACKLOG (
            CD_ELO_AGENDAMENTO_BACKLOG,
            CD_WEEK,
            CD_WEEK_REF,
            DT_WEEK_START,
            DT_WEEK_START_REF,
            SG_TIPO_DOCUMENTO,
            NU_DOCUMENTO,
            NU_ITEM_DOCUMENTO,
            QT_FORNECIDA,
            QT_BACKLOG,
            QT_BACKLOG_CONFIRMADA,
            QT_CONTRATADA,
            QT_AGENDADA_SEMANA_2,
            QT_REJEITADA_SEMANA_2,
            DH_BACKLOG
        )
        SELECT vnd.seq_elo_agendamento_backlog.nextval,
               'W' || TO_CHAR(dt_week_start, 'IW') || TO_CHAR(dt_week_start, 'RRRR')        AS cd_week,
               'W' || TO_CHAR(dt_week_start_1, 'IW') || TO_CHAR(dt_week_start_1, 'RRRR')    AS cd_week_ref,
               dt_week_start,
               dt_week_start_1                                                              AS dt_week_start_ref,
               'C'                                                                          AS sg_tipo_documento,
               nu_documento,
               nu_item_documento,
               G10                                                                          AS Fornecido_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               F10                                                                          AS Contratada_0,
               I6                                                                           AS Agendado_2,
               0/*M8*/                                                                      AS Rejeitado_2,
               CURRENT_DATE                                                                 AS DataBacklog_0
          FROM (
                    WITH datas AS 
                    (
                        SELECT 
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref))          AS dt_week_start,       -- EXE
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 7      AS dt_week_start_now,   -- G6, J8
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 14     AS dt_week_start_1      -- REF, I6, G8, M8
                          FROM dual
                    )
                    SELECT datas.*,
                           bl.nu_documento,
                           bl.nu_item_documento,
                           bl.qt_fornecida                  AS G6,
                           NVL(ic.nu_qty_delivered, 0)      AS G8,
                           0/*bl.QT_AGENDADA_SEMANA_2*/     AS I6,
                           bl.qt_backlog_confirmada         AS J8,
                           NVL(ic.nu_quantidade, 0)         AS F10,
                           NVL(ic.nu_qty_delivered, 0)      AS G10
                           
                      FROM vnd.elo_agendamento_backlog bl
                     INNER JOIN datas
                           ON bl.dt_week_start = datas.dt_week_start_now
                     LEFT OUTER JOIN
                           vnd.contrato co
                           ON co.nu_contrato_sap = bl.nu_documento
                     LEFT OUTER JOIN
                           vnd.item_contrato ic
                           ON ic.cd_contrato = co.cd_contrato
                          AND ic.cd_item_contrato = bl.nu_item_documento

                     WHERE bl.nu_documento || NVL(bl.nu_item_documento, '') NOT IN (
                                SELECT nu_documento || NVL(nu_item_documento, '')
                                  FROM vnd.elo_agendamento_backlog bl
                                 WHERE bl.dt_week_start = datas.dt_week_start
                                   AND bl.sg_tipo_documento = 'C'
                           )
                       AND bl.sg_tipo_documento = 'C'
                       AND co.cd_incoterms = 'CIF'
                       --AND co.ic_ativo = 'S'
               ) x
         WHERE GREATEST((I6+J8-(G8-G6)/*-M8*/), 0) > 0
        ;
        
        COMMIT;
    END PI_NAO_VO_NAO_DESDOBRO;
    
    
    
    PROCEDURE PI_DESDOBRO (
        P_WEEKS_REF IN NUMBER
    )
    IS
    BEGIN
        INSERT INTO VND.ELO_AGENDAMENTO_BACKLOG (
            CD_ELO_AGENDAMENTO_BACKLOG,
            CD_WEEK,
            CD_WEEK_REF,
            DT_WEEK_START,
            DT_WEEK_START_REF,
            SG_TIPO_DOCUMENTO,
            NU_DOCUMENTO,
            NU_ITEM_DOCUMENTO,
            QT_FORNECIDA,
            QT_BACKLOG,
            QT_BACKLOG_CONFIRMADA,
            QT_CONTRATADA,
            QT_AGENDADA_SEMANA_2,
            QT_REJEITADA_SEMANA_2,
            DH_BACKLOG
        )
        SELECT vnd.seq_elo_agendamento_backlog.nextval,
               'W' || TO_CHAR(dt_week_start, 'IW') || TO_CHAR(dt_week_start, 'RRRR')        AS cd_week,
               'W' || TO_CHAR(dt_week_start_1, 'IW') || TO_CHAR(dt_week_start_1, 'RRRR')    AS cd_week_ref,
               dt_week_start,
               dt_week_start_1                                                              AS dt_week_start_ref,
               'O'                                                                          AS sg_tipo_documento,
               nu_documento,
               nu_item_documento,
               G10                                                                          AS Fornecido_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS BacklogConfirmada_0,
               F10                                                                          AS Contratada_0,
               I6                                                                           AS Agendado_2,
               0/*M8*/                                                                      AS Rejeitado_2,
               CURRENT_DATE                                                                 AS DataBacklog_0
          FROM (
                    WITH datAS AS 
                    (
                        SELECT 
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref))          AS dt_week_start,       -- EXE
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 7      AS dt_week_start_now,   -- G6, J8
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 14     AS dt_week_start_1      -- REF, I6, G8, M8
                          FROM dual
                    ),
                    agend AS 
                    (
                        SELECT 
                               -- Documento no ELO na Semana - 2
                               ca.nu_ordem_venda                        NU_DOCUMENTO,
                               ca.cd_item_pedido                        NU_ITEM_DOCUMENTO,
                               NVL(SUM(ca.qt_agendada_confirmada), 0)   QT_AGENDADA,
                               
                               -- Agendamento na Semana - 2
                               ag.DT_WEEK_START                         DT_WEEK_START,
                               ag.CD_WEEK                               CD_WEEK,

                               -- Documento no MOL na Semana - 0 (esta semana)
                               NVL(MAX(pe.NU_QUANTIDADE), 0)            QT_QUANTIDADE,
                               NVL(MAX(pe.NU_QUANTIDADE_ENTREGUE), 0)   QT_FORNECIDO
                               
                          FROM vnd.elo_carteira ca
                         INNER JOIN
                               vnd.elo_agendamento ag
                               ON ag.cd_elo_agendamento = ca.cd_elo_agendamento
                         INNER JOIN
                               (
                                    SELECT distinct cd_tipo_ordem 
                                      FROM tipo_ordem
                                     WHERE ic_split = 'S'
                               ) tm
                               ON tm.cd_tipo_ordem = ca.cd_tipo_contrato
                         LEFT OUTER JOIN
                               vnd.pedido pe
                               ON pe.nu_ordem_venda = ca.nu_ordem_venda
                              AND pe.cd_item_pedido = ca.cd_item_pedido
                              
                         WHERE ag.dt_week_start = (SELECT dt_week_start_1 FROM datas)
                           AND ag.ic_ativo = 'S'
                           AND ca.ic_ativo = 'S'
                           AND ca.cd_incoterms = 'CIF'
                           AND NVL(ca.qt_agendada_confirmada, 0) > 0
                           AND ca.nu_ordem_venda is not null
                           
                         group by ca.nu_ordem_venda,
                                  ca.cd_item_pedido,
                                  ag.DT_WEEK_START,
                                  ag.CD_WEEK
                    ),
                    -- Para G6, J8
                    bklog AS 
                    (
                        SELECT nu_documento,
                               nu_item_documento,
                               qt_fornecida,
                               qt_backlog_confirmada
                          FROM vnd.elo_agendamento_backlog
                         WHERE dt_week_start = (SELECT dt_week_start_now FROM datas)
                           AND sg_tipo_documento = 'O'
                    )
                                  
                    SELECT datas.*,
                           ag.nu_documento,
                           ag.nu_item_documento,
                           NVL(ag.QT_AGENDADA, 0)           AS I6,     --Agendado na semana - 2
                           NVL(bl.QT_FORNECIDA, 0)          AS G6,     --Fornecido na semana - 2
                           NVL(ag.QT_FORNECIDO, 0)          AS G8,     --Fornecido na semana - 1
                           NVL(bl.QT_BACKLOG_CONFIRMADA, 0) AS J8,     --Backlog na semana - 1
                           NVL(ag.QT_QUANTIDADE, 0)         AS F10,    --Contratado na semana - 0 (esta semana)
                           NVL(ag.QT_FORNECIDO, 0)          AS G10     --Fornecido na semana - 0 (esta semana)
                           
                      FROM agend ag
                      
                     INNER JOIN 
                           datas
                           ON ag.dt_week_start = datas.dt_week_start_1
                      
                      LEFT OUTER JOIN 
                           bklog bl
                           ON bl.nu_documento = ag.nu_documento
                          AND bl.nu_item_documento = ag.nu_item_documento
               )
         WHERE NVL(GREATEST((I6+J8-(G8-G6)/*-M8*/), 0), 0) > 0
        ;
        
        COMMIT;
        
        -- Legado da semana anterior.

        INSERT INTO VND.ELO_AGENDAMENTO_BACKLOG (
            CD_ELO_AGENDAMENTO_BACKLOG,
            CD_WEEK,
            CD_WEEK_REF,
            DT_WEEK_START,
            DT_WEEK_START_REF,
            SG_TIPO_DOCUMENTO,
            NU_DOCUMENTO,
            NU_ITEM_DOCUMENTO,
            QT_FORNECIDA,
            QT_BACKLOG,
            QT_BACKLOG_CONFIRMADA,
            QT_CONTRATADA,
            QT_AGENDADA_SEMANA_2,
            QT_REJEITADA_SEMANA_2,
            DH_BACKLOG
        )
        SELECT vnd.seq_elo_agendamento_backlog.nextval,
               'W' || TO_CHAR(dt_week_start, 'IW') || TO_CHAR(dt_week_start, 'RRRR')        AS cd_week,
               'W' || TO_CHAR(dt_week_start_1, 'IW') || TO_CHAR(dt_week_start_1, 'RRRR')    AS cd_week_ref,
               dt_week_start,
               dt_week_start_1                                                              AS dt_week_start_ref,
               'O'                                                                          AS sg_tipo_documento,
               nu_documento,
               nu_item_documento,
               G10                                                                          AS Fornecido_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               GREATEST((I6+J8-(G8-G6)/*-M8*/), 0)                                          AS Backlog_0,
               F10                                                                          AS Contratada_0,
               I6                                                                           AS Agendado_2,
               0/*M8*/                                                                      AS Rejeitado_2,
               CURRENT_DATE                                                                 AS DataBacklog_0
          FROM (
                    WITH datAS AS 
                    (
                        SELECT 
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref))          AS dt_week_start,       -- EXE
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 7      AS dt_week_start_now,   -- G6, J8
                               TRUNC(CURRENT_DATE, 'iw') + (7 * (1 + p_weeks_ref)) - 14     AS dt_week_start_1      -- REF, I6, G8, M8
                          FROM dual
                    )
                    SELECT datas.*,
                           bl.nu_documento,
                           bl.nu_item_documento,
                           bl.qt_fornecida                      AS G6,
                           NVL(pe.NU_QUANTIDADE_ENTREGUE, 0)    AS G8,
                           0/*bl.QT_AGENDADA_SEMANA_2*/         AS I6,
                           bl.qt_backlog_confirmada             AS J8,
                           NVL(pe.nu_quantidade, 0)             AS F10,
                           NVL(pe.NU_QUANTIDADE_ENTREGUE, 0)    AS G10
                           
                      FROM vnd.elo_agendamento_backlog bl
                     INNER JOIN datas
                           ON bl.dt_week_start = datas.dt_week_start_now
                     LEFT OUTER JOIN
                           vnd.pedido pe
                           ON pe.nu_ordem_venda = bl.nu_documento
                          AND pe.cd_item_pedido = bl.nu_item_documento

                     WHERE bl.nu_documento || NVL(bl.nu_item_documento, '') NOT IN (
                                SELECT nu_documento || NVL(nu_item_documento, '')
                                  FROM vnd.elo_agendamento_backlog bl
                                 WHERE bl.dt_week_start = datas.dt_week_start
                                   AND bl.sg_tipo_documento = 'O'
                           )
                       AND bl.sg_tipo_documento = 'O'
                       --AND pe.cd_incoterms = 'CIF' -- Nao eh preenchido pelo ZSDR3077_CRG_PEDIDOS_NV
               ) x
         WHERE GREATEST((I6+J8-(G8-G6)/*-M8*/), 0) > 0
        ;
        
        COMMIT;
    END PI_DESDOBRO;


    PROCEDURE PX_BACKLOG (
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_DT_WEEK_START_FROM    IN VARCHAR2,
        P_DT_WEEK_START_TO      IN VARCHAR2,
        P_RETORNO               OUT T_CURSOR
    )
    IS
        L_DT_WEEK_FROM           VARCHAR2(20);
        L_DT_WEEK_TO             VARCHAR2(20); 
    BEGIN
        L_DT_WEEK_FROM  := CASE WHEN P_DT_WEEK_START_FROM IS NULL THEN TO_CHAR(SYSDATE-15, 'YYYY-MM-DD') 
                                ELSE P_DT_WEEK_START_FROM
                           END;
        L_DT_WEEK_TO    := CASE WHEN P_DT_WEEK_START_TO IS NULL THEN TO_CHAR(SYSDATE+15, 'YYYY-MM-DD') 
                                ELSE P_DT_WEEK_START_TO
                           END;
    
        OPEN P_RETORNO FOR
        SELECT  DISTINCT
                CASE bl.sg_tipo_documento
                     WHEN 'P' THEN 'Protocolo'
                     WHEN 'C' THEN 'Contrato'
                     WHEN 'O' THEN 'Ordem de Venda'
                END                                             AS "Tipo"
                
               ,NU_DOCUMENTO                                    AS "Documento"
               --,NU_ITEM_DOCUMENTO                               AS "Item"
               ,QT_BACKLOG_CONFIRMADA                           AS "Backlog"
               
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN ic.cd_centro_expedidor
                     WHEN 'C' THEN ic_c.cd_centro_expedidor
                     WHEN 'O' THEN pe.cd_centro_expedidor
                END                                             AS "Centro"
               
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN ae.nu_contrato_sap
                     WHEN 'C' THEN bl.nu_documento
                     WHEN 'O' THEN pe.nu_contrato_sap
                END                                             AS "Contrato"
                
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN ae.cd_item_contrato
                     WHEN 'C' THEN bl.nu_item_documento
                     WHEN 'O' THEN pe.cd_item_contrato
                END                                             AS "Item Contrato"
                
               ,CASE bl.sg_tipo_documento
                      WHEN 'O' THEN bl.nu_documento
                      ELSE ''
                 END                                            AS "Ordem de Venda"
                
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN ps_p.no_produto_sap
                     WHEN 'C' THEN ps_c.no_produto_sap
                     WHEN 'O' THEN ps_o.no_produto_sap
                END                                             AS "Descrição"
                
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN TO_CHAR(TO_NUMBER(ic.cd_produto_sap))
                     WHEN 'C' THEN TO_CHAR(TO_NUMBER(ic_c.cd_produto_sap))
                     WHEN 'O' THEN TO_CHAR(TO_NUMBER(pe.cd_produto_sap))
                END                                             AS "Produto"
                
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN TO_CHAR(TO_NUMBER(cl_p.cd_cliente))
                     WHEN 'C' THEN TO_CHAR(TO_NUMBER(cl_c.cd_cliente))
                     WHEN 'O' THEN TO_CHAR(TO_NUMBER(cl_o.cd_cliente))
                END                                             AS "Cliente Recebedor"
                
               ,CASE bl.sg_tipo_documento
                     WHEN 'P' THEN cl_p.no_cliente
                     WHEN 'C' THEN cl_c.no_cliente
                     WHEN 'O' THEN cl_o.no_cliente
                END                                             AS "Nome Cliente"
               
          FROM VND.ELO_AGENDAMENTO_BACKLOG BL
          
          -- P
          LEFT OUTER JOIN 
               cpt.entrega en
               ON (
                    bl.sg_tipo_documento = 'P' AND bl.nu_documento = en.nu_protocolo_entrega
                  )
                  
          LEFT OUTER JOIN
               cpt.autorizacao_entrega ae
               ON ae.cd_autorizacao_entrega = en.cd_autorizacao_entrega
               
          LEFT OUTER JOIN
               vnd.contrato co
               ON co.nu_contrato = ae.nu_contrato
                  
          LEFT OUTER JOIN
               vnd.item_contrato ic
               ON ic.cd_contrato = co.cd_contrato
              AND ic.cd_item_contrato = ae.cd_item_contrato
              
          LEFT OUTER JOIN
               ctf.produto_sap ps_p
               ON ps_p.cd_produto_sap = ic.cd_produto_sap
               
          LEFT OUTER JOIN
               cpt.cooperativa_filial cf
               ON cf.cd_cooperativa_filial = ae.cd_cooperativa_filial
               
          LEFT OUTER JOIN
               cpt.cooperado cp
               ON cp.cd_cooperado = ae.cd_cooperado
          
          LEFT OUTER JOIN
               cpt.propriedade_cooperado pc
               ON pc.cd_cooperado = cp.cd_cooperado
                
          LEFT OUTER JOIN
               ctf.cliente cl_p
               ON cl_p.cd_cliente = CASE WHEN ae.cd_cooperado IS NULL THEN cf.cd_cliente
                                         ELSE pc.cd_cliente
                                    END
                  
               
          -- C
          LEFT OUTER JOIN
               vnd.contrato co_c
               ON (
                    bl.sg_tipo_documento = 'C' AND bl.nu_documento = co_c.nu_contrato_sap
                  )
                  
          LEFT OUTER JOIN
               vnd.item_contrato ic_c
               ON ic_c.cd_contrato = co_c.cd_contrato
              AND (
                    bl.sg_tipo_documento = 'C' AND bl.nu_item_documento = ic_c.cd_item_contrato
                  )
              
          LEFT OUTER JOIN
               ctf.produto_sap ps_c
               ON ps_c.cd_produto_sap = ic_c.cd_produto_sap
               
          LEFT OUTER JOIN
               vnd.cliente_contrato cc
               ON co_c.cd_cliente_contrato = cc.cd_cliente_contrato
               
          LEFT OUTER JOIN
               ctf.cliente cl_c
               ON cl_c.cd_cliente = cc.cd_cliente


          -- O
          LEFT OUTER JOIN
               vnd.pedido pe
               ON (
                    bl.sg_tipo_documento = 'O' AND bl.nu_documento = pe.nu_ordem_venda
                                               --AND bl.nu_item_documento = pe.cd_item_pedido
                  )
              
          LEFT OUTER JOIN
               ctf.produto_sap ps_o
               ON ps_o.cd_produto_sap = pe.cd_produto_sap
               
          LEFT OUTER JOIN
               vnd.contrato co_o
               ON co_o.nu_contrato_sap = pe.nu_contrato_sap
               
          LEFT OUTER JOIN
               vnd.cliente_contrato cc_o
               ON co_o.cd_cliente_contrato = cc_o.cd_cliente_contrato

          LEFT OUTER JOIN
               ctf.cliente cl_o
               ON cl_o.cd_cliente = cc_o.cd_cliente
               
               
         WHERE (P_CD_WEEK IS NULL OR BL.CD_WEEK = P_CD_WEEK)
           AND (P_DT_WEEK_START_FROM IS NULL OR TO_CHAR(BL.DT_WEEK_START,'YYYYWW') >= TO_CHAR(TO_DATE(L_DT_WEEK_FROM,'YYYY-MM-DD'),'YYYYWW'))
           AND (P_DT_WEEK_START_TO IS NULL OR TO_CHAR(BL.DT_WEEK_START,'YYYYWW') <= TO_CHAR(TO_DATE(L_DT_WEEK_TO,'YYYY-MM-DD'),'YYYYWW'))
           AND NVL(BL.QT_BACKLOG_CONFIRMADA, 0) > 0
           
         ORDER BY 1
        ;
    END PX_BACKLOG;


    PROCEDURE PX_DOCUMENT_HISTORY (
        P_NU_DOCUMENTO          IN VND.ELO_AGENDAMENTO_BACKLOG.NU_DOCUMENTO%TYPE,
        P_NU_ITEM_DOCUMENTO     IN VND.ELO_AGENDAMENTO_BACKLOG.NU_ITEM_DOCUMENTO%TYPE,
        P_RETORNO               OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT bl.DT_WEEK_START                     AS WeekStart,
               bl.CD_WEEK                           AS WeekCode,
               bl.DT_WEEK_START_REF                 AS WeekStartRef,
               bl.CD_WEEK_REF                       AS WeekCodeRef,
               bl.SG_TIPO_DOCUMENTO                 AS DocumentType,
               bl.NU_DOCUMENTO                      AS DocumentNumber,
               bl.NU_ITEM_DOCUMENTO                 AS Item,
               NVL(bl_1.QT_BACKLOG_CONFIRMADA, 0)   AS Backlog_1,
               bl.QT_AGENDADA_SEMANA_2              AS Scheduled_2,
               bl.QT_FORNECIDA                      AS Delivered,
               bl.QT_BACKLOG                        AS OriginalBacklog,
               bl.QT_BACKLOG_CONFIRMADA             AS ConfirmedBacklog,
               bl.DH_BACKLOG                        AS BacklogDate
               
          FROM vnd.elo_agendamento_backlog  bl
          
          LEFT OUTER JOIN
               vnd.elo_agendamento_backlog  bl_1
               ON bl_1.sg_tipo_documento = bl.sg_tipo_documento
              AND bl_1.nu_documento = bl.nu_documento
              AND (bl.nu_item_documento IS NULL OR bl_1.nu_item_documento = bl.nu_item_documento)
              AND bl_1.dt_week_start = bl.dt_week_start - 7
          
         WHERE bl.nu_documento = P_NU_DOCUMENTO
           AND (P_NU_ITEM_DOCUMENTO IS NULL OR bl.nu_item_documento = P_NU_ITEM_DOCUMENTO)
         ORDER BY bl.dt_week_start
        ;
    END PX_DOCUMENT_HISTORY;


    PROCEDURE PX_BACKLOG (
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_SG_TIPO_DOCUMENTO     IN VND.ELO_AGENDAMENTO_BACKLOG.SG_TIPO_DOCUMENTO%TYPE,
        P_NU_DOCUMENTO          IN VND.ELO_AGENDAMENTO_BACKLOG.NU_DOCUMENTO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_PRODUTO_SAP        IN CTF.PRODUTO_SAP.CD_PRODUTO_SAP%TYPE,
        P_CD_CLIENTE            IN CTF.CLIENTE.CD_CLIENTE%TYPE,
        P_NO_CLIENTE            IN CTF.CLIENTE.NO_CLIENTE%TYPE,
        P_CD_SALES_GROUP        IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
        P_RETORNO               OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN p_retorno FOR
        SELECT bl.cd_elo_agendamento_backlog                    AS "Id", 
               bl.sg_tipo_documento                             AS "DocumentType", 
               bl.nu_documento                                  AS "DocumentNumber", 
               bl.nu_item_documento                             AS "Item", 
               bl.qt_backlog                                    AS "OriginalBacklog", 
               bl.qt_backlog_confirmada                         AS "ConfirmedBacklog", 
               bl.dh_backlog                                    AS "BacklogDate", 
               bl.dt_week_start_ref                             AS "WeekStartRef", 
               bl.cd_week_ref                                   AS "WeekCodeRef",
               bl.cd_week                                       AS "WeekCode"
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN ic.cd_centro_expedidor
                    WHEN 'C' THEN ic_c.cd_centro_expedidor
                    WHEN 'O' THEN pe.cd_centro_expedidor
               END                                              AS "Plant"
               
                -- Contract
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN ae.nu_contrato_sap
                    WHEN 'C' THEN bl.nu_documento
                    WHEN 'O' THEN pe.nu_contrato_sap
               END                                              AS "Contract"
               
                -- ContractItem
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN ae.cd_item_contrato
                    WHEN 'C' THEN bl.nu_item_documento
                    WHEN 'O' THEN pe.cd_item_contrato
               END                                              AS "ContractItem"
               
                -- SalesOrder
              ,CASE bl.sg_tipo_documento
                     WHEN 'O' THEN bl.nu_documento
                     ELSE ''
               END                                              AS "SalesOrder"
               
                -- Product
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN TO_CHAR(TO_NUMBER(ic.cd_produto_sap))
                    WHEN 'C' THEN TO_CHAR(TO_NUMBER(ic_c.cd_produto_sap))
                    WHEN 'O' THEN TO_CHAR(TO_NUMBER(pe.cd_produto_sap))
               END                                              AS "ProductId"
               
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN ps_p.no_produto_sap
                    WHEN 'C' THEN ps_c.no_produto_sap
                    WHEN 'O' THEN ps_o.no_produto_sap
               END                                              AS "ProductDescription"
               
                -- Customer
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN TO_CHAR(TO_NUMBER(cl_p.cd_cliente))
                    WHEN 'C' THEN TO_CHAR(TO_NUMBER(cl_c.cd_cliente))
                    WHEN 'O' THEN TO_CHAR(TO_NUMBER(cl_o.cd_cliente))
               END                                              AS "CustomerId"
               
              ,CASE bl.sg_tipo_documento
                    WHEN 'P' THEN cl_p.no_cliente
                    WHEN 'C' THEN cl_c.no_cliente
                    WHEN 'O' THEN cl_o.no_cliente
               END                                              AS "CustomerName"
               
              ,us.cd_usuario_original                           AS "SalesGroupId"

          FROM vnd.elo_agendamento_backlog bl
          
          
          -- P
          LEFT OUTER JOIN 
               cpt.entrega en
               ON (
                    bl.sg_tipo_documento = 'P' AND bl.nu_documento = en.nu_protocolo_entrega
                  )
                  
          LEFT OUTER JOIN
               cpt.autorizacao_entrega ae
               ON ae.cd_autorizacao_entrega = en.cd_autorizacao_entrega
               
          LEFT OUTER JOIN
               vnd.contrato co
               ON co.nu_contrato = ae.nu_contrato
                  
          LEFT OUTER JOIN
               vnd.item_contrato ic
               ON ic.cd_contrato = co.cd_contrato
              AND ic.cd_item_contrato = ae.cd_item_contrato
              
          LEFT OUTER JOIN
               ctf.produto_sap ps_p
               ON ps_p.cd_produto_sap = ic.cd_produto_sap
               
          LEFT OUTER JOIN
               cpt.cooperativa_filial cf
               ON cf.cd_cooperativa_filial = ae.cd_cooperativa_filial
               
          LEFT OUTER JOIN
               cpt.cooperado cp
               ON cp.cd_cooperado = ae.cd_cooperado
          
          LEFT OUTER JOIN
               cpt.propriedade_cooperado pc
               ON pc.cd_cooperado = cp.cd_cooperado
                
          LEFT OUTER JOIN
               ctf.cliente cl_p
               ON cl_p.cd_cliente = CASE WHEN ae.cd_cooperado IS NULL THEN cf.cd_cliente
                                         ELSE pc.cd_cliente
                                    END
                  
               
          -- C
          LEFT OUTER JOIN
               vnd.contrato co_c
               ON (
                    bl.sg_tipo_documento = 'C' AND bl.nu_documento = co_c.nu_contrato_sap
                  )
                  
          LEFT OUTER JOIN
               vnd.item_contrato ic_c
               ON ic_c.cd_contrato = co_c.cd_contrato
              AND (
                    bl.sg_tipo_documento = 'C' AND bl.nu_item_documento = ic_c.cd_item_contrato
                  )
              
          LEFT OUTER JOIN
               ctf.produto_sap ps_c
               ON ps_c.cd_produto_sap = ic_c.cd_produto_sap
               
          LEFT OUTER JOIN
               vnd.cliente_contrato cc
               ON co_c.cd_cliente_contrato = cc.cd_cliente_contrato
               
          LEFT OUTER JOIN
               ctf.cliente cl_c
               ON cl_c.cd_cliente = cc.cd_cliente


          -- O
          LEFT OUTER JOIN
               vnd.pedido pe
               ON (
                    bl.sg_tipo_documento = 'O' AND bl.nu_documento = pe.nu_ordem_venda
                                               --AND bl.nu_item_documento = pe.cd_item_pedido
                  )
              
          LEFT OUTER JOIN
               ctf.produto_sap ps_o
               ON ps_o.cd_produto_sap = pe.cd_produto_sap
               
          LEFT OUTER JOIN
               vnd.contrato co_o
               ON co_o.nu_contrato_sap = pe.nu_contrato_sap
               
          LEFT OUTER JOIN
               vnd.cliente_contrato cc_o
               ON co_o.cd_cliente_contrato = cc_o.cd_cliente_contrato

          LEFT OUTER JOIN
               ctf.cliente cl_o
               ON cl_o.cd_cliente = cc_o.cd_cliente
          
          LEFT OUTER JOIN
               ctf.usuario us
               ON (
                        bl.sg_tipo_documento = 'P' AND us.cd_usuario = co.cd_usuario_venda
                        OR
                        bl.sg_tipo_documento = 'C' AND us.cd_usuario = co_c.cd_usuario_venda
                        OR
                        bl.sg_tipo_documento = 'O' AND us.cd_usuario = pe.cd_usuario_venda
                  )
                  
         WHERE (p_cd_week IS NULL OR bl.cd_week_ref = p_cd_week)
           AND (p_sg_tipo_documento IS NULL OR bl.sg_tipo_documento = p_sg_tipo_documento)
           AND (p_nu_documento IS NULL OR bl.nu_documento like p_nu_documento)
           AND (p_cd_sales_group IS NULL OR us.cd_usuario_original like p_cd_sales_group)
           AND (
                    p_cd_centro_expedidor IS NULL OR
                    (
                        CASE bl.sg_tipo_documento
                            WHEN 'P' THEN ic.cd_centro_expedidor
                            WHEN 'C' THEN ic_c.cd_centro_expedidor
                            WHEN 'O' THEN pe.cd_centro_expedidor
                        END
                    ) LIKE p_cd_centro_expedidor
                )
           AND (
                    p_cd_produto_sap IS NULL OR
                    (
                        CASE bl.sg_tipo_documento
                            WHEN 'P' THEN TO_CHAR(TO_NUMBER(ic.cd_produto_sap))
                            WHEN 'C' THEN TO_CHAR(TO_NUMBER(ic_c.cd_produto_sap))
                            WHEN 'O' THEN TO_CHAR(TO_NUMBER(pe.cd_produto_sap))
                        END
                    ) LIKE p_cd_produto_sap
                )
           AND (
                    p_cd_cliente IS NULL OR
                    (
                        CASE bl.sg_tipo_documento
                             WHEN 'P' THEN TO_CHAR(TO_NUMBER(cl_p.cd_cliente))
                             WHEN 'C' THEN TO_CHAR(TO_NUMBER(cl_c.cd_cliente))
                             WHEN 'O' THEN TO_CHAR(TO_NUMBER(cl_o.cd_cliente))
                        END 
                    ) LIKE p_cd_cliente
                )
           AND (
                    p_no_cliente IS NULL OR
                    (
                        CASE bl.sg_tipo_documento
                             WHEN 'P' THEN cl_p.no_cliente
                             WHEN 'C' THEN cl_c.no_cliente
                             WHEN 'O' THEN cl_o.no_cliente
                        END  
                    ) LIKE p_no_cliente
                )
         ORDER BY bl.sg_tipo_documento,
                  bl.nu_documento
        ;
    END PX_BACKLOG;
    
    
    PROCEDURE PU_BACKLOG (
        P_CD_USUARIO                    IN VND.ELO_AGENDAMENTO_BACKLOG_LOG.CD_USUARIO%TYPE,
        P_CD_ELO_AGENDAMENTO_BACKLOG    IN VND.ELO_AGENDAMENTO_BACKLOG.CD_ELO_AGENDAMENTO_BACKLOG%TYPE,
        P_QT_BACKLOG_CONFIRMADA         IN VND.ELO_AGENDAMENTO_BACKLOG.QT_BACKLOG_CONFIRMADA%TYPE
    )
    IS
    BEGIN
        INSERT INTO vnd.elo_agendamento_backlog_log (
           cd_elo_agendamento_backlog_log, 
           dh_log, 
           cd_usuario, 
           qt_backlog_confirmada_old, 
           qt_backlog_confirmada_new
        ) VALUES (
            seq_agendamento_backlog_log.NEXTVAL,
            CURRENT_DATE,
            p_cd_usuario,
            (
                SELECT qt_backlog_confirmada 
                  FROM vnd.elo_agendamento_backlog 
                 WHERE cd_elo_agendamento_backlog = p_cd_elo_agendamento_backlog
            ),
            p_qt_backlog_confirmada
        );

        UPDATE vnd.elo_agendamento_backlog
           SET qt_backlog_confirmada = p_qt_backlog_confirmada
         WHERE cd_elo_agendamento_backlog = p_cd_elo_agendamento_backlog
        ;
    EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'GX_ELO_AGENDAMENTO_BACKLOG.PU_BACKLOG - ' || SQLCODE || ' - ERROR - ' || SQLERRM);
    END PU_BACKLOG;


    PROCEDURE PX_PLANTS (
        P_RETORNO               OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT cd_centro_expedidor  AS "Id",
               ds_centro_expedidor  AS "Description"
          FROM ctf.centro_expedidor ce
         WHERE ce.ic_ativo = 'S'
         ORDER BY ce.cd_centro_expedidor
        ;
    END PX_PLANTS;
    
END GX_ELO_AGENDAMENTO_BACKLOG;
/