        WITH CTE_AGENDAMENTO AS 
        (
        
        SELECT  ag.* from vnd.elo_agendamento ag
              WHERE 
                    (   CASE WHEN :p_site_type = 'P' AND ag.CD_POLO = :p_cd_site THEN 1
                           WHEN   :p_site_type = 'C' AND ag.CD_CENTRO_EXPEDIDOR = :p_cd_site THEN 1
                           WHEN   :p_site_type = 'M' AND ag.CD_MACHINE = :p_cd_site THEN 1
                           ELSE 0
                        END = 1 
                    ) 
                AND ag.cd_week = :p_cd_week
        
        ) ,
        CTE_AGENDAMENTO_ITEM AS 
        (
        
        SELECT ITEM.CD_ELO_AGENDAMENTO_ITEM, ITEM.CD_CLIENTE , ITEM.CD_INCOTERMS , ITEM.IC_ATIVO, 
        ITEM.CD_PRODUTO_SAP , ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR, ITEM.IC_ADICAO, ITEM.CD_STATUS_REPLAN,
        ITEM.DS_OBSERVACAO_TORRE_FRETES, ITEM.IC_CORTADO_SEMANA_ANTERIOR, ITEM.CD_COTA_COMPARTILHADA

        FROM CTE_AGENDAMENTO AGE
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR SUP
        ON SUP.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_AGENDAMENTO_ITEM ITEM 
        ON 
        ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR = SUP.CD_ELO_AGENDAMENTO_SUPERVISOR
        
        WHERE
        SUP.IC_ATIVO = 'S'
        AND ITEM.IC_ATIVO = 'S'
        AND (:p_cd_sales_office IS NULL OR SUP.cd_sales_office = :p_cd_sales_office)
        AND (:p_cd_sales_group IS NULL OR SUP.cd_sales_group = :p_cd_sales_group)
        
        ),
        
        CTE_CARTEIRA_TO_DO AS 
        (
        SELECT CART.*
        FROM  CTE_AGENDAMENTO_ITEM ITEMID
        INNER JOIN VND.ELO_CARTEIRA CART
        ON CART.CD_ELO_AGENDAMENTO_ITEM = ITEMID.CD_ELO_AGENDAMENTO_ITEM
        ), 
        
        cart AS ( 
            SELECT  ai.cd_elo_agendamento_item Id,
                    ai.cd_elo_agendamento_item SchedulingItemId,
                    ag.cd_elo_agendamento, 
                    ag.cd_elo_agendamento SchedulingId,
                    ag.cd_week WeekCode,
                    ai.cd_incoterms Incoterms,
                    ai.cd_cota_compartilhada QuotaSharingKey,             
                    MIN(ca.cd_agente_venda) cd_agente_venda, 
                    MIN(ca.no_agente) no_agente, 
                    MAX(ap.qt_cota) as qt_cota,                    
                    NVL(SUM(ca.qt_programada),0) ContractTotal,
                    NVL(SUM(ca.qt_entregue),0) ContractDelivered,
                    NVL(SUM(ca.qt_agendada_anterior),0) PreviousPlannedQuantity,
                    
                    -- BAKCLOG
                    --NVL(SUM(ca.qt_backlog_cif),0) BacklogCIFQuantity,
                    gx_elo_scheduling.fx_backlog_cif(ag.cd_week, ai.cd_elo_agendamento_item) BacklogCIFQuantity,
                    
                    CASE WHEN MAX(NVL(ca.ic_cooperative,'N')) = 'S' THEN
                            NVL(gx_elo_scheduling.fx_no_protocol_balance(ai.cd_elo_agendamento_item),0)
                         ELSE
                            0
                    END NoProtocolBalance,
                    GREATEST (0, NVL(gx_elo_scheduling.fx_blocked_balance(ai.cd_elo_agendamento_item),0)) BlockedBalance,
                    GREATEST (
                            0,
                            (
                                NVL(SUM(ca.qt_programada),0) /*ContractTotal*/ - 
                                NVL(SUM(ca.qt_entregue),0) /*ContractDelivered*/ -
                                NVL(gx_elo_scheduling.fx_blocked_balance(ai.cd_elo_agendamento_item),0) /*BlockedBalance*/ -
                                NVL(SUM(ca.qt_agendada_anterior),0) /*PreviousPlannedQuantity*/ -
                                -- BACKLOG
                                --NVL(SUM(ca.qt_backlog_cif),0) /*BacklogCIFQuantity*/ -
                                gx_elo_scheduling.fx_backlog_cif(ag.cd_week, ai.cd_elo_agendamento_item) /*BacklogCIFQuantity*/  -
                                GREATEST (
                                            0,
                                            (
                                                NVL(gx_elo_scheduling.fx_no_protocol_balance(ai.cd_elo_agendamento_item),0) /*NoProtocolBalance*/ -
                                                NVL(gx_elo_scheduling.fx_blocked_balance(ai.cd_elo_agendamento_item),0) /*BlockedBalance*/
                                            )
                                         )
                            )
                    ) Balance,
                    NVL(gx_elo_scheduling.fx_no_protocol_balance(ai.cd_elo_agendamento_item),0) NoProtocolBalanceN,
                    NVL(gx_elo_scheduling.fx_blocked_balance(ai.cd_elo_agendamento_item),0) BlockedBalanceN,
                    (
                        SELECT NVL(SUM(ca_.qt_saldo),0)
                          FROM CTE_CARTEIRA_TO_DO ca_
                         WHERE ca_.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                           AND ca_.cd_grupo_embalagem = 'B'
                    ) AS BAG,

                    (
                        SELECT NVL(SUM(ca_.qt_saldo),0)
                          FROM CTE_CARTEIRA_TO_DO ca_
                         WHERE ca_.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                           AND ca_.cd_grupo_embalagem = 'S'
                    ) AS SMALLBAG,
                    
                    (
                        SELECT NVL(SUM(ca_.qt_saldo),0)
                          FROM CTE_CARTEIRA_TO_DO ca_
                         WHERE ca_.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                           AND ca_.cd_grupo_embalagem = 'G'
                    ) AS GRANEL,
                    MAX(
                            CASE WHEN NVL(ap.qt_cota_ajustada, 0) > 0 THEN
                                    CASE WHEN NVL(ag.qt_overbooking_supervisores, 0) > 0 THEN
                                        ap.qt_cota_ajustada + (ap.qt_cota_ajustada * (ag.qt_overbooking_supervisores / 100))
                                    ELSE
                                        ap.qt_cota_ajustada
                                    END
                                 ELSE 
                                    CASE WHEN NVL(ag.qt_overbooking_supervisores, 0) > 0 THEN
                                        NVL(ap.qt_cota, 0) + (NVL(ap.qt_cota, 0) * (ag.qt_overbooking_supervisores / 100))
                                    ELSE
                                        NVL(ap.qt_cota, 0)
                                    END
                            END
                       ) AS SupervisorQuota,
                    
                    ai.ic_cortado_semana_anterior CortadoSemanaAnterior,
                    ai.ds_observacao_torre_fretes FreightTowerRemarks,
                    
                    -- BAKCLOG
                    --gx_elo_scheduling.fx_total_backlog_cif(ai.cd_elo_agendamento_item) TotalBacklogCIF,
                    gx_elo_scheduling.fx_backlog_cif(ag.cd_week, ai.cd_elo_agendamento_item) TotalBacklogCIF,
                    
                    NVL(ai.cd_status_replan, 0) ReplanStatus,
                    NVL(ag.qt_overbooking_supervisores, 0) OverbookingSupervisores,
                    NVL(ai.ic_adicao, 'N') IsAddition,

                    --DATAS
                    MIN(CA.DH_BACKLOG_CIF) AS AtrasadaDesde,                  
                    (
                      SELECT NVL(SUM(qt_saldo), 0) 
                        FROM CTE_CARTEIRA_TO_DO ca
                       WHERE ca.DH_ENTREGA < SYSDATE
                         AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoAtrasado,
                    TRUNC(ADD_MONTHS(SYSDATE,1),'MM') AS LiberadoMonth1,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM CTE_CARTEIRA_TO_DO ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,1),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth1Quantity,
                    TRUNC(ADD_MONTHS(SYSDATE,2),'MM') AS LiberadoMonth2,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM CTE_CARTEIRA_TO_DO ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,2),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth2Quantity,
                    TRUNC(ADD_MONTHS(SYSDATE,3),'MM') AS LiberadoMonth3,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM CTE_CARTEIRA_TO_DO ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,3),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth3Quantity,
                    TRUNC(ADD_MONTHS(SYSDATE,4),'MM') AS LiberadoMonth4,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM CTE_CARTEIRA_TO_DO ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,4),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth4Quantity,   
        
                    gx_elo_scheduling.fx_has_coop_document(ai.cd_elo_agendamento_item) AS HasCooperativeDocument,            
                    gx_elo_scheduling.fx_has_split_document(ai.cd_elo_agendamento_item) AS HasSplitDocument,            
                    ag.dh_limite,
        
                    -- Regional Manager
                    ap.cd_sales_office Code,
                    ap.cd_sales_office RegionalManagerCode,
                    ca.no_sales_office Name,
                    ca.no_sales_office RegionalManagerName,
        
                    -- Supervisor
                    ap.cd_sales_group Code_1,
                    ap.cd_sales_group SupervisorCode,
                    ca.no_sales_group Name_1,
                    ca.no_sales_group SupervisorName,
        
                    -- Customer
                    ai.cd_cliente Id_3,
                    ai.cd_cliente CustomerId,
                    CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.no_cliente_pagador
                            ELSE ca.no_cliente_recebedor
                    END Name_2,
                    CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.no_cliente_pagador
                            ELSE ca.no_cliente_recebedor
                    END CustomerName,
                    CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.ds_endereco_pagador
                            ELSE ca.ds_endereco_recebedor
                    END Address,
                    ca.ic_relacionamento Relationship,
                    --MIN(ca.no_municipio) Municipio,
                    --MIN(ca.sg_estado) Estado,
        
                    -- Product
                    ai.cd_produto_sap Id_5,
                    ai.cd_produto_sap ProductId,
                    ca.no_produto_sap Description

               FROM  CTE_AGENDAMENTO ag
               INNER JOIN CTE_CARTEIRA_TO_DO ca
               ON ag.cd_elo_agendamento = ca.cd_elo_agendamento
              INNER JOIN vnd.elo_agendamento_supervisor ap
                 ON ag.cd_elo_agendamento = ap.cd_elo_agendamento 
              INNER JOIN CTE_AGENDAMENTO_ITEM ai
                 ON
                 ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor 
                 and ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
              WHERE 

                (:p_cd_sales_office IS NULL OR ap.cd_sales_office = :p_cd_sales_office)
                AND (:p_cd_sales_group IS NULL OR ap.cd_sales_group = :p_cd_sales_group)
                AND ca.ic_ativo = 'S'
                AND ai.ic_ativo = 'S'
                AND ap.ic_ativo = 'S'
                

              GROUP BY  ai.cd_elo_agendamento_item, 
                        ag.cd_elo_agendamento,
                        ca.no_produto_sap, 
                        --ca.no_cliente_recebedor, 
                        --ca.no_cliente_pagador,
                        --ca.ds_endereco_recebedor, 
                        --ca.ds_endereco_pagador, 
                        CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.no_cliente_pagador
                             ELSE ca.no_cliente_recebedor
                        END,
                        CASE WHEN ai.cd_incoterms = 'FOB' THEN ca.ds_endereco_pagador
                             ELSE ca.ds_endereco_recebedor
                        END,
                        ca.ic_relacionamento, 
                        ap.cd_sales_office,
                        ap.cd_sales_group,
                        ca.no_sales_group, 
                        ca.no_sales_office,                    
                        ag.cd_week,
                        ai.cd_incoterms,
                        ai.cd_cota_compartilhada,
                        ai.ic_cortado_semana_anterior,
                        ai.cd_cliente,
                        ai.cd_produto_sap,
                        ag.dh_limite,
                        ai.ds_observacao_torre_fretes,
                        ai.cd_status_replan,
                        ag.qt_overbooking_supervisores,
                        --ca.no_municipio,
                        --ca.sg_estado,
                        ai.ic_adicao
        ),
        re AS (
            SELECT ca.id,
                   CASE
                      WHEN ca.cd_agente_venda IS NULL THEN ''
                      WHEN ca.cd_agente_venda = cn.ds_value THEN ''
                      ELSE ca.cd_agente_venda
                   END cd_agente_venda,
                   CASE
                      WHEN ca.cd_agente_venda IS NULL THEN ''
                      WHEN ca.cd_agente_venda = cn.ds_value THEN ''
                      ELSE ca.no_agente
                   END no_agente
              FROM cart ca
              LEFT OUTER JOIN constantes cn
                ON ca.cd_agente_venda = cn.ds_value
               AND cn.sg_sigla = 'AGDUM'
             INNER JOIN CTE_AGENDAMENTO ag
                ON ag.cd_elo_agendamento = ca.cd_elo_agendamento
               AND ROWNUM = 1 -- On an ELO Walk Through, Daniela Santos said to get the first one.
             WHERE ag.ic_ativo = 'S'
        ),
        municipio AS (
                        SELECT ec.cd_elo_agendamento_item Id,
                               ec.no_municipio Municipio,
                               ec.sg_estado Estado
                          FROM CTE_CARTEIRA_TO_DO ec
                         INNER JOIN cart
                               ON cart.Id = ec.cd_elo_agendamento_item
                         WHERE ec.cd_elo_carteira = (
                                    SELECT MAX(cd_elo_carteira) cd_elo_carteira
                                      FROM CTE_CARTEIRA_TO_DO ca
                                     WHERE ca.cd_elo_agendamento_item = cart.Id)


        )
        SELECT
               ca.Id,
               ca.SchedulingItemId,
               ca.SchedulingId,
               ca.WeekCode,
               ca.Incoterms,
               ca.QuotaSharingKey,
               ca.ContractTotal,
               ca.ContractDelivered,
               ca.PreviousPlannedQuantity,
               ca.BacklogCIFQuantity,
               ca.NoProtocolBalance,
               ca.BlockedBalance,
               ca.Balance,                 
               ca.BAG,                    
               ca.SMALLBAG,
               ca.GRANEL,
               ca.SupervisorQuota,
               ca.CortadoSemanaAnterior,
               ca.FreightTowerRemarks,
               ca.TotalBacklogCIF,
               ca.ReplanStatus,
               ca.IsAddition,
               /*
               B: Need to sum BlockedBalance when calculating avaible volume to schedule.
               P: Need to sum NoProtocolBalance when calculating avaible volume to schedule.
               */
               CASE WHEN NoProtocolBalanceN < BlockedBalanceN THEN 'B'
                    ELSE 'P'
               END Sumizator,

               --DATAS
               AtrasadaDesde,                  
               LiberadoAtrasado,
               LiberadoMonth1,              
               LiberadoMonth1Quantity,
               LiberadoMonth2,              
               LiberadoMonth2Quantity,
               LiberadoMonth3,              
               LiberadoMonth3Quantity,
               LiberadoMonth4,              
               LiberadoMonth4Quantity,  

               CASE WHEN NVL(ca.SupervisorQuota, 0) = 0 THEN 0
                    ELSE ROUND((NVL(aw.qt_semana,0) / ca.SupervisorQuota) * 100, 5)
               END CotaConsumo,
               gx_elo_scheduling.fx_consumo_cota_supervisor(ca.cd_elo_agendamento, CA.Code_1) AS CotaConsumoSupervisor,
               gx_elo_scheduling.fx_consumo_cota_centro(:p_cd_week, :p_cd_site, :p_site_type) AS CotaConsumoCentro,

               CA.HasCooperativeDocument,
               CA.HasSplitDocument,
               NVL(aw.qt_semana,0) WeekQuantity,
               CA.dh_limite,

               -- Regional Manager
               us_rm.cd_usuario AS Id,
               us_rm.cd_usuario AS RegionalManagerId,
               CA.Code,
               CA.RegionalManagerCode,
               CA.Name,
               CA.RegionalManagerName,

               --SUPERVISOR 
               us_sp.cd_usuario AS Id,
               us_sp.cd_usuario AS SupervisorId,
               CA.Code_1 AS Code,
               CA.SupervisorCode,
               CA.Name_1 AS Name,
               CA.SupervisorName,

               --CUSTOMER
               CA.Id_3 AS Id,
               CA.CustomerId,
               CA.Name_2 AS Name,
               CA.CustomerName,
               CA.Address,
               CA.Relationship, 
               municipio.Municipio,
               municipio.Estado, 
               
               --REPRE
               re.cd_agente_venda Id,
               re.cd_agente_venda RepresentantiveId,
               re.no_agente Name,
               re.no_agente RepresentantiveName,
               
               --PRODUCT
               CA.Id_5 AS ID,
               CA.ProductId,
               CA.Description,

               -- Weeks
               aw.cd_elo_agendamento_week AS Id,
               aw.cd_elo_agendamento_week WeekId,
               aw.nu_semana WeekNumber,
               aw.qt_semana Quantity,
               aw.qt_semana WeekQuantity,
               aw.qt_emergencial Emergency,
               (
                    SELECT ROUND(NVL(SUM(ad.nu_quantidade), 0), 1)
                      FROM vnd.elo_agendamento_day ad
                     WHERE ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week
                       AND ad.cd_grupo_embalagem = 'B'
               ) QuantityB,
               (
                    SELECT ROUND(NVL(SUM(ad.nu_quantidade), 0), 1)
                      FROM vnd.elo_agendamento_day ad
                     WHERE ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week
                       AND ad.cd_grupo_embalagem = 'S'
               ) QuantityS,
               (
                    SELECT ROUND(NVL(SUM(ad.nu_quantidade), 0), 1)
                      FROM vnd.elo_agendamento_day ad
                     WHERE ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week
                       AND ad.cd_grupo_embalagem = 'G'
               ) QuantityG,

               -- Days
               ad.cd_elo_agendamento_day AS Id,
               ad.cd_elo_agendamento_day DayId,
               ad.nu_dia_semana WeekDay,
               ad.nu_quantidade Quantity,
               ad.nu_quantidade DayQuantity,
               ad.cd_grupo_embalagem PackageGroupId,

               -- Package Group
               ad.cd_grupo_embalagem AS Id,
               ad.cd_grupo_embalagem PackageGroupId

               FROM cart ca LEFT OUTER JOIN re ON re.id = ca.id
               LEFT OUTER JOIN municipio ON municipio.Id = ca.id
               LEFT OUTER JOIN vnd.elo_agendamento_week aw ON aw.cd_elo_agendamento_item = CA.ID
               LEFT OUTER JOIN vnd.elo_agendamento_day ad ON ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week
               INNER JOIN ctf.usuario us_rm ON us_rm.cd_usuario_original = CA.CODE --(CD_SALES_OFFICE)
               INNER JOIN ctf.usuario us_sp ON us_sp.cd_usuario_original = CA.Code_1 -- (cd_sales_group)

               ORDER BY CA.ID
               ;