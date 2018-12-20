CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_SCHEDULING_FIX" IS

   
    FUNCTION fx_no_protocol_balance (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER
    IS
        v_result NUMBER := 0;
    BEGIN
        BEGIN
        WITH cart AS (
            SELECT DISTINCT
                   ca.nu_contrato,
                   ca.cd_item_contrato
              FROM vnd.elo_carteira ca
             WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND ca.ic_cooperative = 'S'
               AND ca.ic_ativo = 'S'
        )
        SELECT NVL(SUM(
               GREATEST(SUM(ca.qt_saldo) -
               ( 
                   SELECT (NVL(SUM(en.qt_quantidade),0) - NVL(SUM(NVL(en.qt_fornecido,0)),0)) qt_saldo_protocolo
                     FROM cart ca
                     LEFT OUTER JOIN cpt.autorizacao_entrega ae
                       ON ae.nu_contrato = ca.nu_contrato
                      AND ae.cd_item_contrato = ca.cd_item_contrato
                     LEFT OUTER JOIN cpt.entrega en
                       ON ae.cd_autorizacao_entrega = en.cd_autorizacao_entrega
                    WHERE en.sg_status NOT IN ('C', 'P')
               ), 0)), 0) NoProtocolBalance
          INTO v_result
          FROM vnd.elo_carteira ca
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND ca.ic_cooperative = 'S'
           AND ca.ic_ativo = 'S'
         GROUP BY ca.cd_elo_agendamento_item;
         
         EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_result:=0;
         WHEN OTHERS THEN
            v_result:=0;
         END;

        RETURN v_result;
    END fx_no_protocol_balance;



    FUNCTION fx_blocked_balance (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER
    IS
        v_result NUMBER := 0;
    BEGIN
	
		BEGIN
        SELECT NVL(SUM(ca.qt_programada),0) BlockedBalance
          INTO v_result
          FROM vnd.elo_carteira ca
         WHERE ca.ic_sem_ordem_venda = 'S'
           AND ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
         EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_result:=0;
         WHEN OTHERS THEN
            v_result:=0;
         END;		
		
		

        RETURN v_result;
    END fx_blocked_balance;



    FUNCTION fx_has_coop_document (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN CHAR
    IS
        v_result CHAR := 'N';
    BEGIN
	
		BEGIN
	
        SELECT CASE WHEN COUNT(cd_elo_carteira) > 0 THEN 'S'
               ELSE 'N'
               END
          INTO v_result
          FROM vnd.elo_carteira ca
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND ca.cd_tipo_contrato IN (
                SELECT DISTINCT cd_tipo_ordem
                  from vnd.tipo_ordem
                 where ic_cooperative = 'S'
           )
           AND ca.ic_ativo = 'S'
        ;
         EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_result:='N';
         WHEN OTHERS THEN
            v_result:='N';
         END;		
		
		
		
        RETURN v_result;
    END fx_has_coop_document;



    FUNCTION fx_has_split_document (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN CHAR
    IS
        v_result CHAR := 'N';
    BEGIN
	
		BEGIN
	
        SELECT CASE WHEN COUNT(cd_elo_carteira) > 0 THEN 'S'
               ELSE 'N'
               END
          INTO v_result
          FROM vnd.elo_carteira ca
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND ca.cd_tipo_contrato IN (
                SELECT DISTINCT cd_tipo_ordem
                  from vnd.tipo_ordem
                 where ic_split = 'S'
           )
           AND ca.ic_ativo = 'S'
        ;
		
		 EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_result:='N';
         WHEN OTHERS THEN
            v_result:='N';
         END;		
		

        RETURN v_result;
    END fx_has_split_document;
    


    FUNCTION fx_total_backlog_cif (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER
    IS
        v_result NUMBER := 0;
    BEGIN
		BEGIN
        SELECT NVL(SUM(ca.qt_backlog_cif), 0) TotalBacklogCIF
          INTO v_result
          FROM vnd.elo_carteira ca
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_result:=0;
         WHEN OTHERS THEN
            v_result:=0;
         END;	
		
		
		
        RETURN v_result;
    END fx_total_backlog_cif;


    
    FUNCTION fx_consumo_cota_supervisor (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_group        IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE
    ) RETURN NUMBER
    IS
        v_result NUMBER := 0;
    BEGIN
		BEGIN
	
        WITH dat AS (
                        SELECT NVL(SUM(aw.qt_semana), 0) QuantidadeAgendada,
                               NVL(ag.qt_overbooking_supervisores, 0) OverbookingSupervisores,
                               CASE WHEN NVL(ap.qt_cota_ajustada, 0) > 0 THEN ap.qt_cota_ajustada
                                    ELSE NVL(ap.qt_cota, 0)
                               END Cota
                                               
                          FROM elo_agendamento_week aw
                         
                         RIGHT OUTER JOIN vnd.elo_agendamento_item ai
                            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                         
                         INNER JOIN vnd.elo_agendamento_supervisor ap
                            ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                            
                         INNER JOIN vnd.elo_agendamento ag
                            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                            
                         WHERE ag.cd_elo_agendamento = p_cd_elo_agendamento
                           AND ap.cd_sales_group = p_cd_sales_group
                          
                         GROUP BY ag.qt_overbooking_supervisores,
                                  ap.qt_cota,
                                  ap.qt_cota_ajustada
                    )
                    
           SELECT 
                    CASE WHEN dat.Cota = 0 THEN 0
                        ELSE
                            CASE WHEN dat.OverbookingSupervisores = 0 THEN
                                ROUND((dat.QuantidadeAgendada / dat.Cota) * 100, 5)
                            ELSE
                                ROUND((dat.QuantidadeAgendada / (dat.Cota + (dat.Cota * (dat.OverbookingSupervisores / 100)))) * 100, 5)
                        END
                    END ConsumoAcumuladoSupervisor
             INTO v_result
             FROM dat
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_result:=0;
         WHEN OTHERS THEN
            v_result:=0;
         END;
		
		
        RETURN v_result;
    END fx_consumo_cota_supervisor;
  
    
    
    FUNCTION fx_consumo_cota_centro (
        p_cd_week       IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site       IN CHAR,
        p_site_type     IN CHAR
    ) RETURN NUMBER
    IS
        v_result NUMBER := 0;
    BEGIN
		BEGIN
        WITH agend AS (
                            SELECT ag.cd_elo_agendamento,
                                   ag.dt_week_start,
                                   ag.CD_POLO,
                                   ag.CD_CENTRO_EXPEDIDOR,
                                   ag.CD_MACHINE
                              FROM vnd.elo_agendamento ag
                             WHERE
                                   (
                                        CASE WHEN p_site_type = 'P' AND ag.CD_POLO = p_cd_site THEN 1
                                             WHEN p_site_type = 'C' AND ag.CD_CENTRO_EXPEDIDOR = p_cd_site THEN 1
                                             WHEN p_site_type = 'M' AND ag.CD_MACHINE = p_cd_site THEN 1
                                             ELSE 0
                                        END = 1 
                                   ) 
                            AND ag.cd_week = p_cd_week
                      ),
               sem AS (
                            SELECT (
                                      TO_NUMBER(TO_CHAR(TO_DATE(ag.dt_week_start,'DD/MM/RRRR'),'WW'))
                                      ||
                                      EXTRACT(YEAR FROM ag.dt_week_start)
                                   ) Semana,
                            
                                   NVL(SUM(aw.qt_semana), 0) TotalQuantidadeAgendada
                                                   
                              FROM vnd.elo_agendamento_week aw
                             
                             INNER JOIN vnd.elo_agendamento_item ai
                                ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                             
                             INNER JOIN vnd.elo_agendamento_supervisor ap
                                ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                                
                             INNER JOIN vnd.elo_agendamento ag
                                ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                                
                             WHERE ag.cd_elo_agendamento = (SELECT cd_elo_agendamento FROM agend)
                             
                             GROUP BY (
                                         TO_NUMBER(TO_CHAR(TO_DATE(ag.dt_week_start,'DD/MM/RRRR'),'WW'))
                                         ||
                                         EXTRACT(YEAR FROM ag.dt_week_start)
                                      )
                      ),
               cap AS (
                          SELECT
                                  (
                                     TO_NUMBER(TO_CHAR(TO_DATE(ac.dt_week_start,'DD/MM/RRRR'),'WW'))
                                     ||
                                     EXTRACT(YEAR FROM ac.dt_week_start)
                                  ) Semana,
                                  SUM(ci.nu_capacidade) CapacidadeCentroTotal
                                
                            FROM vnd.elo_agendamento_centro_item ci
                                  
                           INNER JOIN vnd.elo_agendamento_centro ac 
                              ON ac.cd_agendamento_centro = ci.cd_agendamento_centro
                                
                            WHERE (
                                        CASE WHEN p_site_type = 'P' AND ac.cd_polo = p_cd_site THEN 1
                                             WHEN p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site THEN 1
                                             WHEN p_site_type = 'M' AND ac.cd_machine = p_cd_site THEN 1
                                             ELSE 0
                                        END = 1 
                                  ) 
                              AND TO_NUMBER(TO_CHAR(TO_DATE(ac.dt_week_start,'DD/MM/RRRR'),'WW')) = TO_NUMBER(TO_CHAR((SELECT TO_DATE(dt_week_start,'DD/MM/RRRR') FROM agend),'WW'))
                              AND EXTRACT(YEAR FROM ac.dt_week_start) = EXTRACT(YEAR FROM (SELECT TO_DATE(dt_week_start,'DD/MM/RRRR') FROM agend))
                            
                            GROUP BY (
                                        TO_NUMBER(TO_CHAR(TO_DATE(ac.dt_week_start,'DD/MM/RRRR'),'WW'))
                                        ||
                                        EXTRACT(YEAR FROM ac.dt_week_start)
                                     )
                      )
                      
           SELECT 
                  --sem.TotalQuantidadeAgendada,
                  --cap.CapacidadeCentroTotal,
                  CASE WHEN cap.CapacidadeCentroTotal = 0 THEN 0
                       ELSE ROUND((sem.TotalQuantidadeAgendada / cap.CapacidadeCentroTotal) * 100, 5)
                  END AS ConsumoAcumuladoCentro
             
             INTO v_result
             
             FROM sem
             
            INNER JOIN cap ON cap.Semana = sem.Semana;
			EXCEPTION 
			 WHEN NO_DATA_FOUND THEN 
				v_result:=0;
			 WHEN OTHERS THEN
				v_result:=0;
			 END;	
			
        
        RETURN v_result;
    END fx_consumo_cota_centro;



    FUNCTION fx_backlog_cif (
        p_cd_week                 IN vnd.elo_agendamento_backlog.cd_week%TYPE,
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER
    IS
        v_result NUMBER := 0;
    BEGIN
    
        BEGIN
        SELECT SUM(qt_backlog_confirmada) qt_backlog_confirmada
          INTO v_result
          FROM (
                    SELECT NVL(SUM(bl.qt_backlog_confirmada), 0) qt_backlog_confirmada
                      FROM vnd.elo_agendamento_backlog bl
                     INNER JOIN
                           vnd.elo_carteira ca
                           ON (
                                    bl.sg_tipo_documento = 'C' AND (ca.nu_contrato_sap = bl.nu_documento AND ca.cd_item_contrato = bl.nu_item_documento)
                                    OR
                                    bl.sg_tipo_documento = 'O' AND (ca.nu_ordem_venda = bl.nu_documento AND ca.cd_item_pedido = bl.nu_item_documento)
                              )
                     WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                       AND ca.cd_incoterms = 'CIF'
                       AND ca.ic_ativo = 'S'
                       AND bl.cd_week = p_cd_week
                       AND bl.sg_tipo_documento IN ('C', 'O')

                    UNION

                    SELECT NVL(SUM(bl.qt_backlog_confirmada), 0) qt_backlog_confirmada
                      FROM vnd.elo_agendamento_backlog bl
                     INNER JOIN cpt.entrega en
                           ON en.nu_protocolo_entrega = bl.nu_documento
                     INNER JOIN
                           cpt.autorizacao_entrega ae
                           ON en.cd_autorizacao_entrega = ae.cd_autorizacao_entrega
                     INNER JOIN
                           vnd.elo_carteira ca       
                           ON ae.nu_contrato_sap = ca.nu_contrato_sap
                          AND ae.cd_item_contrato = ca.cd_item_contrato
                     WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                       AND ca.cd_incoterms = 'CIF'
                       AND ca.ic_ativo = 'S'
                       AND bl.cd_week = p_cd_week
                       AND bl.sg_tipo_documento = 'P'
               )
        ;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        v_result:=0;
        WHEN OTHERS THEN 
        v_result:=0;
        END;
        
        
        RETURN v_result;
    END fx_backlog_cif;
  


    



    
    
    /*#######################################################################*/









    PROCEDURE px_weeks (
        p_result                OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT DISTINCT
               ea.cd_week CdWeek,
               TRUNC(ea.dt_week_start, 'day') dt,
               ea.cd_week
          FROM vnd.elo_agendamento ea
         WHERE /*ea.cd_elo_status = vnd.gx_elo_common.fx_elo_status('AGEND', 'AGOPN')
           AND*/ ea.ic_ativo = 'S'
      ORDER BY TRUNC(ea.dt_week_start, 'day') desc
        ;
    END px_weeks;



    PROCEDURE px_sites_by_week (
        p_cd_week       IN vnd.elo_agendamento.cd_week%TYPE,
        p_result        OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT DISTINCT
               ea.cd_polo,
               ea.cd_centro_expedidor,
               ea.cd_machine,
               ea.cd_polo CdPolo,
               ea.cd_centro_expedidor CdCenter,
               ea.cd_machine CdMachine,
               CASE 
                    WHEN ea.cd_polo IS NOT NULL THEN 'Polo: ' || ea.cd_polo || ' - ' || po.ds_polo
                    WHEN ea.cd_centro_expedidor IS NOT NULL THEN 'Centro: ' || ea.cd_centro_expedidor || ' - ' || ce.ds_centro_expedidor
                    WHEN ea.cd_machine IS NOT NULL THEN 'M¿quina: ' || ea.cd_machine || ' - ' || ma.ds_machine
               END site,
               CASE 
                    WHEN ea.cd_polo IS NOT NULL THEN 'Polo: ' || ea.cd_polo || ' - ' || po.ds_polo
                    WHEN ea.cd_centro_expedidor IS NOT NULL THEN 'Centro: ' || ea.cd_centro_expedidor || ' - ' || ce.ds_centro_expedidor
                    WHEN ea.cd_machine IS NOT NULL THEN 'M¿quina: ' || ea.cd_machine || ' - ' || ma.ds_machine
               END Local,
               CASE 
                    WHEN ea.cd_polo IS NOT NULL THEN 'P'
                    WHEN ea.cd_centro_expedidor IS NOT NULL THEN 'C'
                    WHEN ea.cd_machine IS NOT NULL THEN 'M'
               END SiteType

          FROM vnd.elo_agendamento ea 

          LEFT OUTER JOIN ctf.centro_expedidor ce
            ON ce.cd_centro_expedidor = ea.cd_centro_expedidor

          LEFT OUTER JOIN ctf.machine ma
            ON ma.cd_machine = ea.cd_machine

          LEFT OUTER JOIN ctf.polo po
            ON po.cd_polo = ea.cd_polo

         WHERE ea.cd_week = p_cd_week
           --AND ea.cd_elo_status = vnd.gx_elo_common.fx_elo_status('AGEND', 'AGOPN')
           AND ea.ic_ativo = 'S'
         ;
    END px_sites_by_week;



    PROCEDURE px_regional_managers (
        p_cd_week       IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site       IN CHAR,
        p_site_type     IN CHAR,
        p_result        OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT DISTINCT

              us.cd_usuario Id,
              ap.cd_sales_office Code,
              us.no_usuario Name

         FROM vnd.elo_agendamento_supervisor ap

        INNER JOIN vnd.elo_agendamento ag
           ON ag.cd_elo_agendamento = ap.cd_elo_agendamento

        INNER JOIN ctf.usuario us
           ON us.cd_usuario_original = ap.cd_sales_office

        WHERE 
               (
                  p_site_type = 'P' AND ag.cd_polo = p_cd_site
                  OR
                  p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                  OR
                  p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
          AND ag.cd_week = p_cd_week
          --AND ag.cd_elo_status = vnd.gx_elo_common.fx_elo_status('AGEND', 'AGOPN')
          AND ag.ic_ativo = 'S'

        ORDER BY us.no_usuario
        ;

    END px_regional_managers;



    PROCEDURE px_supervisors (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_cd_sales_office   IN vnd.elo_agendamento_supervisor.cd_sales_office%type,
        p_result            OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT DISTINCT

              us.cd_usuario Id,
              ap.cd_sales_group Code,
              us.no_usuario Name

         FROM vnd.elo_agendamento_supervisor ap

        INNER JOIN vnd.elo_agendamento ag
           ON ag.cd_elo_agendamento = ap.cd_elo_agendamento

        INNER JOIN ctf.usuario us
           ON us.cd_usuario_original = ap.cd_sales_group

        WHERE 
               (
                  p_site_type = 'P' AND ag.cd_polo = p_cd_site
                  OR
                  p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                  OR
                  p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
          AND ag.cd_week = p_cd_week
          AND (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
          --AND ag.cd_elo_status = vnd.gx_elo_common.fx_elo_status('AGEND', 'AGOPN')
          AND ag.ic_ativo = 'S'

        ORDER BY us.no_usuario
        ;
    END px_supervisors;



    PROCEDURE px_scheduling_items_qts (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_cd_sales_office   IN vnd.elo_agendamento_supervisor.cd_sales_office%type,
        p_cd_sales_group    IN vnd.elo_agendamento_supervisor.cd_sales_group%type,
        p_result            OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        WITH cart AS ( 
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
                          FROM vnd.elo_carteira ca_
                         WHERE ca_.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                           AND ca_.cd_grupo_embalagem = 'B'
                    ) AS BAG,

                    (
                        SELECT NVL(SUM(ca_.qt_saldo),0)
                          FROM vnd.elo_carteira ca_
                         WHERE ca_.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                           AND ca_.cd_grupo_embalagem = 'S'
                    ) AS SMALLBAG,
                    
                    (
                        SELECT NVL(SUM(ca_.qt_saldo),0)
                          FROM vnd.elo_carteira ca_
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
                        FROM vnd.elo_carteira ca
                       WHERE ca.DH_ENTREGA < SYSDATE
                         AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoAtrasado,
                    TRUNC(ADD_MONTHS(SYSDATE,1),'MM') AS LiberadoMonth1,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM vnd.elo_carteira ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,1),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth1Quantity,
                    TRUNC(ADD_MONTHS(SYSDATE,2),'MM') AS LiberadoMonth2,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM vnd.elo_carteira ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,2),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth2Quantity,
                    TRUNC(ADD_MONTHS(SYSDATE,3),'MM') AS LiberadoMonth3,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM vnd.elo_carteira ca
                        WHERE TRUNC(ca.DH_ENTREGA,'MM') = TRUNC(ADD_MONTHS(SYSDATE,3),'MM')
                            AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
                    ) AS LiberadoMonth3Quantity,
                    TRUNC(ADD_MONTHS(SYSDATE,4),'MM') AS LiberadoMonth4,              
                    (
                        SELECT NVL(SUM(qt_saldo), 0)
                            FROM vnd.elo_carteira ca
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

               FROM vnd.elo_carteira ca
              INNER JOIN vnd.elo_agendamento_item ai
                 ON (
                       ai.cd_incoterms = 'FOB' AND ai.cd_cliente = ca.cd_cliente_pagador
                       OR
                       ai.cd_incoterms = 'CIF' AND ai.cd_cliente = ca.cd_cliente_recebedor
                    )
                AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
              INNER JOIN vnd.elo_agendamento_supervisor ap
                 ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
              INNER JOIN vnd.elo_agendamento ag
                 ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
              WHERE 
                    (   CASE WHEN p_site_type = 'P' AND ag.CD_POLO = p_cd_site THEN 1
                           WHEN   p_site_type = 'C' AND ag.CD_CENTRO_EXPEDIDOR = p_cd_site THEN 1
                           WHEN   p_site_type = 'M' AND ag.CD_MACHINE = p_cd_site THEN 1
                           ELSE 0
                        END = 1 
                    ) 
                AND ag.cd_week = p_cd_week
                AND (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
                AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
                AND ca.ic_ativo = 'S'
                AND ai.ic_ativo = 'S'
                AND ap.ic_ativo = 'S'
                AND ag.ic_ativo = 'S'

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
             INNER JOIN vnd.elo_agendamento ag
                ON ag.cd_elo_agendamento = ca.cd_elo_agendamento
               AND ROWNUM = 1 -- On an ELO Walk Through, Daniela Santos said to get the first one.
             WHERE ag.ic_ativo = 'S'
        ),
        municipio AS (
                        SELECT ec.cd_elo_agendamento_item Id,
                               ec.no_municipio Municipio,
                               ec.sg_estado Estado
                          FROM vnd.elo_carteira ec
                         INNER JOIN cart
                               ON cart.Id = ec.cd_elo_agendamento_item
                         WHERE ec.cd_elo_carteira = (
                                    SELECT MAX(cd_elo_carteira) cd_elo_carteira
                                      FROM elo_carteira ca
                                     WHERE ca.cd_elo_agendamento_item = cart.Id
                               )
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
               gx_elo_scheduling.fx_consumo_cota_centro(p_cd_week, p_cd_site, p_site_type) AS CotaConsumoCentro,

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
    END px_scheduling_items_qts;



    PROCEDURE px_available_volume (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_result            OUT t_cursor
    )
    IS
        v_cd_elo_agendamento vnd.elo_agendamento.cd_elo_agendamento%TYPE;
    BEGIN
		BEGIN
	
        SELECT -- TODO: Usando MAX enquanto nao consertam a criacao de mais de 
               -- um agendamento para o mesmo local e semana.

               --cd_elo_agendamento
               MAX(cd_elo_agendamento) cd_elo_agendamento 
          INTO v_cd_elo_agendamento
          FROM vnd.elo_agendamento ag
         WHERE (
                    p_site_type = 'P' AND ag.cd_polo = p_cd_site
                    OR
                    p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                    OR
                    p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
           AND ag.ic_ativo = 'S'
           AND ag.cd_week = p_cd_week
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_cd_elo_agendamento:=0;
         WHEN OTHERS THEN
            v_cd_elo_agendamento:=0;
         END;
		
		

        OPEN p_result FOR
        WITH -- Agendamento total quota
             total_quota AS (
                  SELECT ap.cd_elo_agendamento,
                         SUM(ap.qt_cota) ag_total_quota
                    FROM vnd.elo_agendamento_supervisor ap
                   WHERE ap.ic_ativo = 'S'
                     AND ap.cd_elo_agendamento = v_cd_elo_agendamento
                   GROUP BY ap.cd_elo_agendamento
             ),
             -- Agendamento total plant capacity
             total_plant_capacity AS (
                  SELECT ag.cd_elo_agendamento,
                         SUM(ci.nu_capacidade) ag_total_plant_capacity

                    FROM vnd.elo_agendamento_centro_item ci

                   INNER JOIN vnd.elo_agendamento_centro ac
                      ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                   INNER JOIN vnd.elo_agendamento ag
                      ON ag.dt_week_start = ac.dt_week_start

                  WHERE 
                        (
                             p_site_type = 'P' AND ac.cd_polo = p_cd_site
                             OR
                             p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                             OR
                             p_site_type = 'M' AND ac.cd_machine = p_cd_site
                        )
                    AND ci.ic_ativo = 'S'
                    AND ac.ic_ativo = 'S'
                    AND ag.ic_ativo = 'S'
                    AND ag.cd_elo_agendamento = v_cd_elo_agendamento
                  GROUP BY ag.cd_elo_agendamento
             ),
             -- Week day total planned quantity
             total_planned_quantity AS (
                 SELECT ap.cd_elo_agendamento,
                        NVL(SUM(ad.nu_quantidade), 0) wd_total_planned_quantity

                   FROM vnd.elo_agendamento_supervisor ap

                  INNER JOIN vnd.elo_agendamento_item ai
                     ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor

                   LEFT OUTER JOIN vnd.elo_agendamento_week aw
                     ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

                   LEFT OUTER JOIN vnd.elo_agendamento_day ad
                     ON ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week

                  WHERE ai.ic_ativo = 'S'
                    AND ap.ic_ativo = 'S'
                    AND ap.cd_elo_agendamento = v_cd_elo_agendamento

                  GROUP BY ap.cd_elo_agendamento
             )
        SELECT week_days.weekday DayOfWeek,
--               NVL(plant_items.nu_capacidade, 0) AS week_day_plant_capacity, -- Week day plant capacity
--               NVL(total_quota.ag_total_quota, 0) AS ag_total_quota,
--               NVL(total_plant_capacity.ag_total_plant_capacity, 0) AS ag_total_plant_capacity,
--               NVL((total_quota.ag_total_quota * plant_items.nu_capacidade) / total_plant_capacity.ag_total_plant_capacity, 0) AS week_day_total_quota,
--               NVL(total_planned_quantity.wd_total_planned_quantity, 0) AS wd_total_planned_quantity,
               CAST(
                        GREATEST (0,
                            NVL(
                                (
                                    (total_quota.ag_total_quota * plant_items.nu_capacidade) / total_plant_capacity.ag_total_plant_capacity
                                ) - total_planned_quantity.wd_total_planned_quantity
                           , 0)
                       )
                       AS BINARY_DOUBLE
                   )
               AS Quantity,
               GREATEST (0,
                   NVL(
                        (
                            (total_quota.ag_total_quota * plant_items.nu_capacidade) / total_plant_capacity.ag_total_plant_capacity
                        ) - total_planned_quantity.wd_total_planned_quantity
                   , 0)
               )
               AS QuantityDecimal

          FROM 
               (
                    SELECT ROWNUM weekday 
                      FROM dual 
                   CONNECT BY LEVEL <= (7 * (SELECT nu_semanas 
                                               FROM vnd.elo_agendamento 
                                              WHERE cd_elo_agendamento = v_cd_elo_agendamento)
                                       )
               ) week_days

          LEFT OUTER JOIN 
               (
                    SELECT ag.cd_elo_agendamento,
                           ag.nu_semanas,
                           ci.nu_dia_semana,
                           ci.nu_capacidade

                      FROM vnd.elo_agendamento_centro_item ci

                     INNER JOIN vnd.elo_agendamento_centro ac
                        ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                     INNER JOIN vnd.elo_agendamento ag
                        ON ag.dt_week_start = ac.dt_week_start

                       AND (
                                p_site_type = 'P' AND ac.cd_polo = p_cd_site
                                OR
                                p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                                OR
                                p_site_type = 'M' AND ac.cd_machine = p_cd_site
                           )
                     WHERE ci.ic_ativo = 'S'
                       AND ac.ic_ativo = 'S'
                       AND ag.ic_ativo = 'S'
                       AND ag.cd_elo_agendamento = v_cd_elo_agendamento
               ) plant_items
            ON plant_items.nu_dia_semana = week_days.weekday  

          LEFT OUTER JOIN total_quota
            ON total_quota.cd_elo_agendamento = plant_items.cd_elo_agendamento

          LEFT OUTER JOIN total_plant_capacity
            ON total_plant_capacity.cd_elo_agendamento = plant_items.cd_elo_agendamento

          LEFT OUTER JOIN total_planned_quantity
            ON total_planned_quantity.cd_elo_agendamento = plant_items.cd_elo_agendamento

         ORDER BY week_days.weekday
        ;
    END px_available_volume;



    PROCEDURE px_available_volume2 (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_result            OUT t_cursor
    )
    IS
        v_cd_elo_agendamento vnd.elo_agendamento.cd_elo_agendamento%TYPE;
    BEGIN
		BEGIN
        SELECT 
               MAX(cd_elo_agendamento) cd_elo_agendamento 
          INTO v_cd_elo_agendamento
          FROM vnd.elo_agendamento ag
         WHERE (
                    p_site_type = 'P' AND ag.cd_polo = p_cd_site
                    OR
                    p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                    OR
                    p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
           AND ag.ic_ativo = 'S'
           AND ag.cd_week = p_cd_week
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_cd_elo_agendamento:=0;
         WHEN OTHERS THEN
            v_cd_elo_agendamento:=0;
         END;
		

        OPEN p_result FOR
        WITH -- Agendamento total quota
             total_quota AS (
                  SELECT ap.cd_elo_agendamento,
                         SUM(ap.qt_cota) ag_total_quota
                    FROM vnd.elo_agendamento_supervisor ap
                   WHERE ap.ic_ativo = 'S'
                     AND ap.cd_elo_agendamento = v_cd_elo_agendamento
                   GROUP BY ap.cd_elo_agendamento
             ),
             -- Agendamento total plant capacity
             total_plant_capacity AS (
                  SELECT ag.cd_elo_agendamento,
                         SUM(ci.nu_capacidade) ag_total_plant_capacity

                    FROM vnd.elo_agendamento_centro_item ci

                   INNER JOIN vnd.elo_agendamento_centro ac
                      ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                   INNER JOIN vnd.elo_agendamento ag
                      ON ag.dt_week_start = ac.dt_week_start

                  WHERE 
                        (
                             p_site_type = 'P' AND ac.cd_polo = p_cd_site
                             OR
                             p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                             OR
                             p_site_type = 'M' AND ac.cd_machine = p_cd_site
                        )
                    AND ci.ic_ativo = 'S'
                    AND ac.ic_ativo = 'S'
                    AND ag.ic_ativo = 'S'
                    AND ag.cd_elo_agendamento = v_cd_elo_agendamento
                  GROUP BY ag.cd_elo_agendamento
             ),
             -- Week day total planned quantity
             total_planned_quantity AS (
                 SELECT ap.cd_elo_agendamento,
                        NVL(SUM(ad.nu_quantidade), 0) wd_total_planned_quantity

                   FROM vnd.elo_agendamento_supervisor ap

                  INNER JOIN vnd.elo_agendamento_item ai
                     ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor

                   LEFT OUTER JOIN vnd.elo_agendamento_week aw
                     ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

                   LEFT OUTER JOIN vnd.elo_agendamento_day ad
                     ON ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week

                  WHERE ai.ic_ativo = 'S'
                    AND ap.ic_ativo = 'S'
                    AND ap.cd_elo_agendamento = v_cd_elo_agendamento

                  GROUP BY ap.cd_elo_agendamento
             )
        SELECT week_days.weekday DayOfWeek,
--               NVL(plant_items.nu_capacidade, 0) AS week_day_plant_capacity, -- Week day plant capacity
--               NVL(total_quota.ag_total_quota, 0) AS ag_total_quota,
--               NVL(total_plant_capacity.ag_total_plant_capacity, 0) AS ag_total_plant_capacity,
--               NVL((total_quota.ag_total_quota * plant_items.nu_capacidade) / total_plant_capacity.ag_total_plant_capacity, 0) AS week_day_total_quota,
--               NVL(total_planned_quantity.wd_total_planned_quantity, 0) AS wd_total_planned_quantity,
               TRUNC(NVL(
                    (
                        (total_quota.ag_total_quota * plant_items.nu_capacidade) / total_plant_capacity.ag_total_plant_capacity
                    ) - total_planned_quantity.wd_total_planned_quantity
               , 0)
               ,5)
               AS Quantity

          FROM 
               (
                    SELECT ROWNUM weekday 
                      FROM dual 
                   CONNECT BY LEVEL <= (7 * (SELECT nu_semanas 
                                               FROM vnd.elo_agendamento 
                                              WHERE cd_elo_agendamento = v_cd_elo_agendamento)
                                       )
               ) week_days

          LEFT OUTER JOIN 
               (
                    SELECT ag.cd_elo_agendamento,
                           ag.nu_semanas,
                           ci.nu_dia_semana,
                           ci.nu_capacidade

                      FROM vnd.elo_agendamento_centro_item ci

                     INNER JOIN vnd.elo_agendamento_centro ac
                        ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                     INNER JOIN vnd.elo_agendamento ag
                        ON ag.dt_week_start = ac.dt_week_start

                       AND (
                                p_site_type = 'P' AND ac.cd_polo = p_cd_site
                                OR
                                p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                                OR
                                p_site_type = 'M' AND ac.cd_machine = p_cd_site
                           )
                     WHERE ci.ic_ativo = 'S'
                       AND ac.ic_ativo = 'S'
                       AND ag.ic_ativo = 'S'
                       AND ag.cd_elo_agendamento = v_cd_elo_agendamento
               ) plant_items
            ON plant_items.nu_dia_semana = week_days.weekday  

          LEFT OUTER JOIN total_quota
            ON total_quota.cd_elo_agendamento = plant_items.cd_elo_agendamento

          LEFT OUTER JOIN total_plant_capacity
            ON total_plant_capacity.cd_elo_agendamento = plant_items.cd_elo_agendamento

          LEFT OUTER JOIN total_planned_quantity
            ON total_planned_quantity.cd_elo_agendamento = plant_items.cd_elo_agendamento

         ORDER BY week_days.weekday
        ;
    END px_available_volume2;




    PROCEDURE px_months_ahead (
        p_result            OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT TRUNC(ADD_MONTHS(SYSDATE,ROWNUM),'MM') DateMonth 
          FROM dual 
        CONNECT BY LEVEL <= 4
        ;
    END px_months_ahead;



    PROCEDURE pu_share_quota (
        p_scheling_items            IN VARCHAR,
        p_cd_cota_compartilhada     IN vnd.elo_agendamento_item.cd_cota_compartilhada%TYPE,
        p_result                    OUT t_cursor
    )
    IS
        v_records_affected      NUMBER;
    BEGIN
		BEGIN
        UPDATE vnd.elo_agendamento_item ai
           SET ai.cd_cota_compartilhada = p_cd_cota_compartilhada
         WHERE ai.cd_elo_agendamento_item IN (
                                            SELECT * FROM TABLE(vnd.gx_elo_common.fx_split(p_scheling_items,','))
                                          )
        ;
		COMMIT;
		EXCEPTION 
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.001 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END; 
		END;
		

        v_records_affected := SQL%ROWCOUNT;

        OPEN p_result FOR
        SELECT v_records_affected FROM dual;
    END pu_share_quota;




    PROCEDURE pu_unshare_quota (
        p_scheling_items            IN VARCHAR,
        p_result                    OUT t_cursor
    )
    IS
        v_records_affected      NUMBER;
    BEGIN
		BEGIN
        UPDATE vnd.elo_agendamento_item ai
           SET ai.cd_cota_compartilhada = NULL
         WHERE ai.cd_elo_agendamento_item IN (
                                                SELECT * FROM TABLE(vnd.gx_elo_common.fx_split(p_scheling_items,','))
                                             )
        ;
		COMMIT;
		EXCEPTION 
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.002 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;
		END;		
		

        v_records_affected := SQL%ROWCOUNT;

        OPEN p_result FOR
        SELECT v_records_affected FROM dual;
    END pu_unshare_quota;


    PROCEDURE pu_agendamento_tipo (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE
    )
    IS
        v_count                 NUMBER;
        v_cd_elo_status         vnd.elo_agendamento.cd_elo_status%TYPE;
        v_nu_order_aglog        vnd.elo_status.nu_order%TYPE;
        v_nu_order_atual        vnd.elo_status.nu_order%TYPE;
        v_cd_tipo_agendamento   vnd.elo_carteira.cd_tipo_agendamento%TYPE;
    BEGIN
	
		BEGIN
	
        SELECT COUNT(ag.cd_elo_agendamento)
          INTO v_count
          FROM elo_agendamento ag
         INNER JOIN 
               elo_agendamento_supervisor ap
               ON ap.cd_elo_agendamento = ag.cd_elo_agendamento
         INNER JOIN
               elo_agendamento_item ai
               ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_count:=0;
         WHEN OTHERS THEN
            v_count:=0;
         END;
		
        
        IF v_count > 0 THEN
		
			BEGIN
            SELECT DISTINCT ag.cd_elo_status
              INTO v_cd_elo_status
              FROM elo_agendamento ag
             INNER JOIN 
                   elo_agendamento_supervisor ap
                   ON ap.cd_elo_agendamento = ag.cd_elo_agendamento
             INNER join
                   elo_agendamento_item ai
                   ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
             WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
            ;
			EXCEPTION 
			 WHEN NO_DATA_FOUND THEN 
				v_cd_elo_status:=0;
			 WHEN OTHERS THEN
				v_cd_elo_status:=0;
			 END;
			
            
            IF v_cd_elo_status IS NOT NULL THEN
                SELECT gx_elo_common.fx_elo_status_order(v_cd_elo_status) 
                  INTO v_nu_order_atual
                  FROM dual;
            END IF;
            
            SELECT gx_elo_common.fx_elo_status_order('AGEND','AGLOG') 
              INTO v_nu_order_aglog 
              FROM dual
            ;
            
            IF v_nu_order_atual <= v_nu_order_aglog THEN
                v_cd_tipo_agendamento := vnd.gx_elo_common.fx_elo_status('TIPAG','ORIGINAL');
            ELSE
                v_cd_tipo_agendamento := vnd.gx_elo_common.fx_elo_status('TIPAG','INCLUSAO');
            END IF;
        ELSE
            -- Could not define scheduling status or scheduling not found.
            v_cd_tipo_agendamento := vnd.gx_elo_common.fx_elo_status('TIPAG','ORIGINAL');
        END IF;
        
        v_count := 0;
    
        -- Is there any week with planned quantity (QT_SEMANA) for this scheduling item?
		BEGIN
        SELECT COUNT(cd_elo_agendamento_week)
          INTO v_count
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND NVL(aw.qt_semana, 0) > 0
        ;
		EXCEPTION 
		WHEN NO_DATA_FOUND THEN 
		v_count:=0;
		WHEN OTHERS THEN
		v_count:=0;
		END;
		

        -- If YES, update field CD_TIPO_AGENDAMENTO of records at ELO_CARTEIRA
        -- to 'ORIGINAL', otherwise to update it to NULL.
		
		BEGIN 
		
        UPDATE vnd.elo_carteira ec
           SET ec.cd_tipo_agendamento = CASE 
                                            WHEN v_count > 0 THEN v_cd_tipo_agendamento
                                            ELSE NULL
                                        END
         WHERE ec.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        -- But not for records already marked as REPLAN type.
           AND (
                    ec.cd_tipo_agendamento IS NULL OR
                    ec.cd_tipo_agendamento <> vnd.gx_elo_common.fx_elo_status('TIPAG','REPLAN')
               )
        ;
		COMMIT;
		EXCEPTION       
		WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.003 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;  
		END;		
		
		
    END pu_agendamento_tipo;


    PROCEDURE pi_agendamento_week_qty (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_semana                 IN vnd.elo_agendamento_week.qt_semana%TYPE
    )
    IS
        v_cd_tipo_agendamento   vnd.elo_carteira.cd_tipo_agendamento%TYPE;
        v_cd_tipo_replan        vnd.elo_status.cd_elo_status%TYPE;
    BEGIN
	
		BEGIN 
        SELECT MAX(cd_tipo_agendamento)
          INTO v_cd_tipo_agendamento
          FROM vnd.elo_carteira
         WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_cd_tipo_agendamento:=0;
         WHEN OTHERS THEN
            v_cd_tipo_agendamento:=0;
         END;
		
        
        v_cd_tipo_replan := vnd.gx_elo_common.fx_elo_status('TIPAG','REPLAN');
        
        IF NVL(p_qt_semana, 0) = 0 THEN
		
			BEGIN
            DELETE FROM vnd.elo_agendamento_day
             WHERE cd_elo_agendamento_week in (
                        SELECT cd_elo_agendamento_week
                          FROM vnd.elo_agendamento_week
                         WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
                           AND nu_semana = p_nu_semana
                   )
            ;
			COMMIT;
		    EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.004 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
			END;
			
			BEGIN
            DELETE FROM vnd.elo_agendamento_grouping
             WHERE cd_elo_agendamento_week in (
                        SELECT cd_elo_agendamento_week
                          FROM vnd.elo_agendamento_week
                         WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
                           AND nu_semana = p_nu_semana
                   )
            ;
			COMMIT;
		    EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.005 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
			END;
			
			BEGIN
            DELETE FROM vnd.elo_agendamento_week
             WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND nu_semana = p_nu_semana
            ;
			COMMIT;
		    EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.006 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
			END;
			
            
            IF v_cd_tipo_agendamento = v_cd_tipo_replan THEN
				BEGIN
				
                UPDATE vnd.elo_carteira ca
                   SET ca.qt_agendada_confirmada = NULL, 
				   DS_VERSAO = SUBSTR(DS_VERSAO ||  '[{"ID": 0001, "APP": "GX_ELO_SCHEDULING.pi_agendamento_week_qty", "PROPERTIE": [{"NAME": "QT_AGENDADA_CONFIRMADA", "VAL": NULL}], "DH_ULT_MOD": ' || TO_CHAR(CURRENT_DATE) || ' }],' ,1, 4000)
				   
                 WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item;
				COMMIT;
				EXCEPTION   
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.007 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					ROLLBACK;
				END;				 
				 
				 END;
            END IF;
        ELSE
		
			BEGIN
            MERGE INTO vnd.elo_agendamento_week aw USING DUAL ON (
                    cd_elo_agendamento_item = p_cd_elo_agendamento_item
                AND nu_semana = p_nu_semana
            )

            WHEN MATCHED THEN
                UPDATE 
                   SET qt_semana = p_qt_semana
                 WHERE cd_elo_agendamento_item  = p_cd_elo_agendamento_item
                   AND nu_semana                = p_nu_semana

            WHEN NOT MATCHED THEN
                INSERT (
                   cd_elo_agendamento_week, 
                   cd_elo_agendamento_item, 
                   nu_semana, 
                   qt_cota, 
                   qt_semana, 
                   qt_emergencial
                ) VALUES (
                   seq_elo_agendamento_week.nextval,
                   p_cd_elo_agendamento_item,
                   p_nu_semana,
                   NULL,
                   p_qt_semana,
                   NULL
                );
                COMMIT;
				EXCEPTION
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.008 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					ROLLBACK;
				END;
				END;
				
				
            IF v_cd_tipo_agendamento = v_cd_tipo_replan THEN
				BEGIN
                UPDATE vnd.elo_carteira ca
                   SET ca.qt_agendada_confirmada = p_qt_semana
                 WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item;
			     COMMIT;
				EXCEPTION   
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.008 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					ROLLBACK;
				END;
				END;				
				 
				 
            END IF;
        END IF;

        -- "ELO Project - [27, 32] 'Agendamento' spec V5.doc"
        -- Pg 16
        -- Get all ELO_CARTEIRA records grouped at an ELO_AGENDAMENTO_ITEM record, 
        -- where ELO_AGENDAMENTO_WEEK-NU_QTD_SEMANA not zero and assign ¿ORIGINAL¿.
		BEGIN
			pu_agendamento_tipo(p_cd_elo_agendamento_item);
		EXCEPTION		   
		WHEN OTHERS THEN 
		BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.009 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			
		END;
		END;
		
		
    END pi_agendamento_week_qty;



    PROCEDURE pi_agendamento_week_qty_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_semana                 IN vnd.elo_agendamento_week.qt_semana%TYPE,
        p_result                    OUT t_cursor
    )
    IS
        v_records_affected      NUMBER;
    BEGIN
	
		BEGIN 
        pi_agendamento_week_qty (
            p_cd_elo_agendamento_item,
            p_nu_semana,
            p_qt_semana
        );
		EXCEPTION
		WHEN OTHERS THEN 
		BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.010 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			
		END;
		END;
		

        v_records_affected := SQL%ROWCOUNT;

        OPEN p_result FOR
        SELECT v_records_affected FROM dual;
    END pi_agendamento_week_qty_fob;



    PROCEDURE pd_agendamento_week (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE
    )
    IS
    BEGIN
	
		BEGIN 
	
        DELETE FROM vnd.elo_agendamento_day ad
         WHERE ad.cd_elo_agendamento_week IN (
            SELECT cd_elo_agendamento_week 
              FROM vnd.elo_agendamento_week aw
             WHERE aw.cd_elo_agendamento_item   = p_cd_elo_agendamento_item
               AND aw.nu_semana                 = p_nu_semana
         )
        ;
		COMMIT;
		EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.011 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
		END;
		
		BEGIN 
        DELETE FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item   = p_cd_elo_agendamento_item
           AND aw.nu_semana                 = p_nu_semana
        ;
		COMMIT;
		EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.012 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
		END;

        -- "ELO Project - [27, 32] 'Agendamento' spec V5.doc"
        -- Pg 16
        -- Get all ELO_CARTEIRA records grouped at an ELO_AGENDAMENTO_ITEM record, 
        -- where ELO_AGENDAMENTO_WEEK-NU_QTD_SEMANA not zero and assign ¿ORIGINAL¿.
		BEGIN 
        pu_agendamento_tipo(p_cd_elo_agendamento_item);
		EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.013 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				
			END;
		END;
		
		
    END pd_agendamento_week;



    PROCEDURE pi_agendamento_emerg (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_emergencial            IN vnd.elo_agendamento_week.qt_emergencial%TYPE
    )
    IS
    BEGIN
		BEGIN 
        MERGE INTO vnd.elo_agendamento_week aw USING DUAL ON (
                cd_elo_agendamento_item = p_cd_elo_agendamento_item
            AND nu_semana = p_nu_semana
        )

        WHEN MATCHED THEN
            UPDATE 
               SET qt_emergencial           = p_qt_emergencial
             WHERE cd_elo_agendamento_item  = p_cd_elo_agendamento_item
               AND nu_semana                = p_nu_semana

        WHEN NOT MATCHED THEN
            INSERT (
               cd_elo_agendamento_week, 
               cd_elo_agendamento_item, 
               nu_semana, 
               qt_cota, 
               qt_semana, 
               qt_emergencial
            ) VALUES (
               seq_elo_agendamento_week.nextval,
               p_cd_elo_agendamento_item,
               p_nu_semana,
               NULL,
               NULL,
               p_qt_emergencial
            );
			COMMIT;
			
			EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.016 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
		END;
			
			
    END pi_agendamento_emerg;


    PROCEDURE pi_agendamento_week_emerg (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_emergencial            IN vnd.elo_agendamento_week.qt_emergencial%TYPE,
        p_result                    OUT t_cursor
    )
    IS
        v_qt_semana             vnd.elo_agendamento_week.qt_semana%TYPE;
        v_records_affected      NUMBER;
    BEGIN
        IF NVL(p_qt_emergencial, 0) = 0 THEN
            BEGIN 
			SELECT NVL(SUM(qt_semana), 0)
              INTO v_qt_semana
              FROM vnd.elo_agendamento_week
             WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND nu_semana = p_nu_semana
            ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_qt_semana:=0;
         WHEN OTHERS THEN
            v_qt_semana:=0;
         END;
			
			
            IF v_qt_semana = 0 THEN
                -- There's no week quantity and the emergency is being set to 
                -- zero also. So, delete the scheduling week record for the item.
				BEGIN
                pd_agendamento_week(p_cd_elo_agendamento_item, p_nu_semana);
				EXCEPTION 
     
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.017 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					--ROLLBACK;
				END;
				END;
				
            ELSE
                -- There's week quantity scheduled for the item. So we just 
                -- update the emergency quantity.
				BEGIN
                pi_agendamento_emerg(
                    p_cd_elo_agendamento_item,
                    p_nu_semana,
                    p_qt_emergencial
                );
				EXCEPTION 
     
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.018 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					--ROLLBACK;
				END;
				END;
				
            END IF;
        ELSE
			BEGIN
            pi_agendamento_emerg(
                p_cd_elo_agendamento_item,
                p_nu_semana,
                p_qt_emergencial
            );
			
			EXCEPTION 
 
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.019 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				--ROLLBACK;
			END;
			END;
			
        END IF;
        
        v_records_affected := SQL%ROWCOUNT;

		BEGIN 
        UPDATE vnd.elo_carteira ca
           SET ca.ic_emergencial = 'S'
         WHERE ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item;
		 COMMIT;
		 EXCEPTION      
			WHEN OTHERS THEN 
			BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.020 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
		END;

        OPEN p_result FOR
        SELECT v_records_affected FROM dual;
    END pi_agendamento_week_emerg;



    PROCEDURE pi_agendamento_day (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_day.nu_quantidade%TYPE
    )
    IS
        v_count                     NUMBER := 0;
        v_cd_elo_agendamento_week   vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
    BEGIN
		BEGIN
        SELECT COUNT(cd_elo_agendamento_week)
          INTO v_count
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND aw.nu_semana = p_nu_semana
        ;
		
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_count:=0;
         WHEN OTHERS THEN
            v_count:=0;
         END;
		

        IF v_count = 1 THEN
		
			BEGIN
            SELECT cd_elo_agendamento_week
              INTO v_cd_elo_agendamento_week
              FROM vnd.elo_agendamento_week aw
             WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND aw.nu_semana = p_nu_semana
            ;
			EXCEPTION 
			WHEN NO_DATA_FOUND THEN 
				v_cd_elo_agendamento_week:=0;
			WHEN OTHERS THEN
				v_cd_elo_agendamento_week:=0;
			END;
			
			BEGIN

            MERGE INTO vnd.elo_agendamento_day ad USING DUAL ON (
                    cd_elo_agendamento_week     = v_cd_elo_agendamento_week
                AND nu_dia_semana               = p_nu_dia_semana
                AND cd_grupo_embalagem          = p_cd_grupo_embalagem
            )

            WHEN MATCHED THEN
                UPDATE 
                   SET nu_quantidade            = p_nu_quantidade
                 WHERE cd_elo_agendamento_week  = v_cd_elo_agendamento_week
                   AND nu_dia_semana            = p_nu_dia_semana
                   AND cd_grupo_embalagem       = p_cd_grupo_embalagem

            WHEN NOT MATCHED THEN
                INSERT (
                    cd_elo_agendamento_day, 
                    cd_elo_agendamento_week, 
                    nu_dia_semana, 
                    cd_grupo_embalagem, 
                    nu_quantidade
                ) VALUES (
                    seq_elo_agendamento_day.nextval,
                    v_cd_elo_agendamento_week,
                    p_nu_dia_semana,
                    p_cd_grupo_embalagem,
                    p_nu_quantidade
                );
				COMMIT;
				
				EXCEPTION
			    WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.020 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					ROLLBACK;
				END;  
			END;				
				
        END IF;
    END pi_agendamento_day;



    PROCEDURE pi_agendamento_day_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_day.nu_quantidade%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    )
    IS
    BEGIN
		BEGIN
        pi_agendamento_day (
            p_cd_elo_agendamento_item,
            p_nu_semana,
            p_nu_dia_semana,
            p_cd_grupo_embalagem,
            p_nu_quantidade
        );
		
		EXCEPTION
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.021 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		--ROLLBACK;
		END;
		END;

		BEGIN
        px_package_group_total_fob(
            p_cd_elo_agendamento_item, 
            p_nu_semana, 
            p_nu_dia_semana, 
            p_cd_grupo_embalagem, 
            p_cd_sales_office, 
            p_cd_sales_group, 
            p_result
        );
		
		EXCEPTION
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.022 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		--ROLLBACK;
		END;
		END;
		
    END pi_agendamento_day_fob;



    PROCEDURE pi_agendamento_day_cif (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_week.qt_semana%TYPE,
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_minimun_day_for_replan    IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_result                    OUT t_cursor
    )
    IS
        v_cd_status_replan          vnd.elo_agendamento_item.cd_status_replan%TYPE;
        v_minimun_day_for_replan    vnd.elo_agendamento_day.nu_dia_semana%TYPE := 0;
        
        CURSOR c_agendamento_centro_item IS
        SELECT nu_dia_semana,
               SUM(nu_quantidade) nu_quantidade
          FROM (
                    SELECT ci.nu_dia_semana,
                           NVL((ratio_to_report(ci.nu_capacidade) over ()), 0) * p_nu_quantidade nu_quantidade

                      FROM vnd.elo_agendamento_centro ac

                     INNER JOIN vnd.elo_agendamento_centro_item ci
                        ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                     INNER JOIN vnd.elo_agendamento ag
                        ON ag.dt_week_start = ac.dt_week_start

                     WHERE 
                           (
                                   p_site_type = 'P' AND ac.cd_polo = p_cd_site
                                OR p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                                OR p_site_type = 'M' AND ac.cd_machine = p_cd_site
                           )
                       AND (
                                   p_site_type = 'P' AND ag.cd_polo = p_cd_site
                                OR p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                                OR p_site_type = 'M' AND ag.cd_machine = p_cd_site
                           )
                       AND ag.cd_week = p_cd_week
                       AND ci.nu_dia_semana >= v_minimun_day_for_replan
                       AND ac.ic_ativo = 'S'
                       AND ci.ic_ativo = 'S'
               )
      GROUP BY nu_dia_semana
      ORDER BY nu_dia_semana
        ;
    BEGIN
		BEGIN
        SELECT NVL(cd_status_replan, 0)
          INTO v_cd_status_replan
          FROM elo_agendamento_item ai
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_cd_status_replan:=0;
         WHEN OTHERS THEN
            v_cd_status_replan:=0;
         END;
        
        IF v_cd_status_replan > 0 THEN
            v_minimun_day_for_replan := p_minimun_day_for_replan;
        END IF;
        
        FOR agendamento_centro_item IN c_agendamento_centro_item LOOP
			BEGIN 
            pi_agendamento_day (
                p_cd_elo_agendamento_item,
                p_nu_semana,
                agendamento_centro_item.nu_dia_semana,
                p_cd_grupo_embalagem,
                agendamento_centro_item.nu_quantidade
            );
			EXCEPTION  
			WHEN OTHERS THEN 
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.030 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			--ROLLBACK;
			END; 
			END;
			
			
			
			
        END LOOP;

        IF c_agendamento_centro_item%ISOPEN THEN
            CLOSE c_agendamento_centro_item;
        END IF;

		
		BEGIN
        px_package_group_total_cif (
            p_cd_elo_agendamento_item,
            p_nu_semana,
            p_cd_grupo_embalagem,
            p_cd_sales_office,
            p_cd_sales_group,
            p_result
        );
		
		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.031 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		--ROLLBACK;
		END;
		END;		
		
		
    END pi_agendamento_day_cif;



    PROCEDURE pd_agendamento_day (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE
    )
    IS
        v_count                     NUMBER := 0;
        v_cd_elo_agendamento_week   vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
    BEGIN
		BEGIN
        SELECT COUNT(cd_elo_agendamento_week)
          INTO v_count
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND aw.nu_semana = p_nu_semana
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_count:=0;
         WHEN OTHERS THEN
            v_count:=0;
         END;
		

        IF v_count = 1 THEN
            SELECT cd_elo_agendamento_week
              INTO v_cd_elo_agendamento_week
              FROM vnd.elo_agendamento_week aw
             WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND aw.nu_semana = p_nu_semana
            ;

			BEGIN 
            DELETE FROM vnd.elo_agendamento_day ad
             WHERE ad.cd_elo_agendamento_week   = v_cd_elo_agendamento_week
               AND ad.nu_dia_semana             = p_nu_dia_semana
               AND ad.cd_grupo_embalagem        = p_cd_grupo_embalagem
            ;
			COMMIT;
			EXCEPTION  
			WHEN OTHERS THEN 
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.031 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			ROLLBACK;
			END; 
			END;
			
			
        END IF;
    END pd_agendamento_day;



    PROCEDURE pd_agendamento_day_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    )
    IS
    BEGIN
	
		BEGIN
        pd_agendamento_day (
            p_cd_elo_agendamento_item,
            p_nu_semana,
            p_nu_dia_semana,
            p_cd_grupo_embalagem
        );
		
		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.032 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		--ROLLBACK;
		END;
		END;
		
		
        BEGIN
        px_package_group_total_fob(
            p_cd_elo_agendamento_item, 
            p_nu_semana, 
            p_nu_dia_semana, 
            p_cd_grupo_embalagem, 
            p_cd_sales_office, 
            p_cd_sales_group, 
            p_result
        );
		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.033 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		--ROLLBACK;
		END;
		END;
		
		
    END pd_agendamento_day_fob;



    PROCEDURE pd_agendamento_day_cif (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    )
    IS
        v_count                     NUMBER := 0;
        v_cd_elo_agendamento_week   vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
        v_qt_semana                 vnd.elo_agendamento_week.qt_semana%TYPE;
    BEGIN
	
		BEGIN
        SELECT COUNT(cd_elo_agendamento_week)
          INTO v_count
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND aw.nu_semana = p_nu_semana
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_count:=0;
         WHEN OTHERS THEN
            v_count:=0;
         END;
		

        IF v_count = 1 THEN
            SELECT cd_elo_agendamento_week
              INTO v_cd_elo_agendamento_week
              FROM vnd.elo_agendamento_week aw
             WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND aw.nu_semana = p_nu_semana
            ;
			BEGIN 
            DELETE FROM vnd.elo_agendamento_day ad
             WHERE ad.cd_elo_agendamento_week   = v_cd_elo_agendamento_week
               AND ad.cd_grupo_embalagem        = p_cd_grupo_embalagem
            ;
			COMMIT;
			EXCEPTION  
			WHEN OTHERS THEN 
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.034 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			ROLLBACK;
			END;
			END;
			
			
        END IF;

--        SELECT NVL(SUM(ad.nu_quantidade), 0) 
--          INTO v_qt_semana
--          FROM vnd.elo_agendamento_day ad
--         WHERE ad.cd_elo_agendamento_week IN (
--                   SELECT aw.cd_elo_agendamento_week 
--                     FROM vnd.elo_agendamento_week aw
--                    WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
--                      AND aw.nu_semana = p_nu_semana
--               )
--        ;
--
--        pi_agendamento_week_qty (
--            p_cd_elo_agendamento_item,
--            p_nu_semana,
--            v_qt_semana
--        );

		BEGIN
        px_package_group_total_cif (
            p_cd_elo_agendamento_item,
            p_nu_semana,
            p_cd_grupo_embalagem,
            p_cd_sales_office,
            p_cd_sales_group,
            p_result
        );
		
		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.035 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		--ROLLBACK;
		END;
		END;
		
		
    END pd_agendamento_day_cif;



    PROCEDURE pu_check_week (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE
    )
    IS
        v_count                     NUMBER := 0;
        v_cd_elo_agendamento_week   vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
    BEGIN
		
		BEGIN 
        SELECT COUNT(cd_elo_agendamento_week)
          INTO v_count
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND aw.nu_semana = p_nu_semana
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_count:=0;
         WHEN OTHERS THEN
            v_count:=0;
         END;

        IF v_count = 1 THEN
            SELECT cd_elo_agendamento_week
              INTO v_cd_elo_agendamento_week
              FROM vnd.elo_agendamento_week aw
             WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND aw.nu_semana = p_nu_semana
            ;
			BEGIN
            SELECT COUNT(cd_elo_agendamento_day)
              INTO v_count
              FROM vnd.elo_agendamento_day ad
             WHERE ad.cd_elo_agendamento_week   = v_cd_elo_agendamento_week;
			EXCEPTION 
			 WHEN NO_DATA_FOUND THEN 
				v_count:=0;
			 WHEN OTHERS THEN
				v_count:=0;
			 END;			 
			 
            
            IF v_count = 0 THEN
				BEGIN
                pd_agendamento_week(p_cd_elo_agendamento_item, p_nu_semana);
				EXCEPTION  
				WHEN OTHERS THEN 
				BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.036 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				--ROLLBACK;
				END;
				END;				
				
				
				
            END IF;
        END IF;
    END pu_check_week;
    


    PROCEDURE px_protocols (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_result                    OUT t_cursor,
        p_packages                  OUT t_cursor,
        p_packages_scheduled        OUt t_cursor
    )
    IS
        v_cd_elo_agendamento    vnd.elo_agendamento.cd_elo_agendamento%TYPE;
        v_cd_polo               vnd.elo_agendamento.cd_polo%TYPE;
        v_cd_centro_expedidor   vnd.elo_agendamento.cd_centro_expedidor%TYPE;
        v_cd_machine            vnd.elo_agendamento.cd_machine%TYPE;
    BEGIN
	
		BEGIN
        SELECT ag.cd_elo_agendamento,
               ag.cd_polo,
               ag.cd_centro_expedidor,
               ag.cd_machine
          INTO v_cd_elo_agendamento,
               v_cd_polo,
               v_cd_centro_expedidor,
               v_cd_machine
          FROM vnd.elo_agendamento ag
         INNER JOIN 
               vnd.elo_agendamento_supervisor ap
               ON ap.cd_elo_agendamento = ag.cd_elo_agendamento
         INNER JOIN 
               vnd.elo_agendamento_item ai
               ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		EXCEPTION 
		 WHEN NO_DATA_FOUND THEN 
			BEGIN
			v_cd_elo_agendamento:=0;
			v_cd_polo:=NULL;
			v_cd_centro_expedidor:=NULL;
			v_cd_machine:=NULL;
			END;
		 WHEN OTHERS THEN
			BEGIN
			v_cd_elo_agendamento:=0;
			v_cd_polo:=NULL;
			v_cd_centro_expedidor:=NULL;
			v_cd_machine:=NULL;
			END;
		 END;
		
		
    
        OPEN p_result FOR
        WITH item AS (
            SELECT ai.cd_elo_agendamento_item,
                   ai.cd_incoterms
              FROM vnd.elo_agendamento_item ai
             WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ),
        grp AS (
            SELECT ar.nu_documento,
                   ar.cd_elo_agendamento_grouping,
                   ar.cd_agrupamento_protocolo,
                   ar.qt_agendada,
                   ai.cd_incoterms
              FROM vnd.elo_agendamento_grouping ar
             INNER JOIN 
                   vnd.elo_agendamento_week aw
                   ON aw.cd_elo_agendamento_week = ar.cd_elo_agendamento_week
             INNER JOIN vnd.elo_agendamento_item ai
                   ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
             WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND ar.sg_tipo_documento = 'P'
        ),
        prev_week_1 AS (
            -- Protocols scheduled in the previous scheduling week.
            SELECT ar.nu_documento,
                   ar.qt_agendada,
                   ar.qt_saldo
              FROM vnd.elo_agendamento_grouping ar
             INNER JOIN
                   vnd.elo_agendamento_week aw
                   ON aw.cd_elo_agendamento_week = ar.cd_elo_agendamento_week
             INNER JOIN
                   vnd.elo_agendamento_item ai
                   ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
             INNER JOIN
                   vnd.elo_agendamento_supervisor ap
                   ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
             WHERE ap.cd_elo_agendamento = gx_elo_common.fx_previous_scheduling(
                                                v_cd_elo_agendamento, 
                                                v_cd_polo, 
                                                v_cd_centro_expedidor,
                                                v_cd_machine,
                                                1
                                           )
               AND ar.sg_tipo_documento = 'P'
        ),
        prev_week_2 AS (
            -- Protocols scheduled in the previous scheduling week.
            SELECT ar.nu_documento,
                   ar.qt_agendada,
                   ar.qt_saldo
              FROM vnd.elo_agendamento_grouping ar
             INNER JOIN
                   vnd.elo_agendamento_week aw
                   ON aw.cd_elo_agendamento_week = ar.cd_elo_agendamento_week
             INNER JOIN
                   vnd.elo_agendamento_item ai
                   ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
             INNER JOIN
                   vnd.elo_agendamento_supervisor ap
                   ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
             WHERE ap.cd_elo_agendamento = gx_elo_common.fx_previous_scheduling(
                                                v_cd_elo_agendamento, 
                                                v_cd_polo, 
                                                v_cd_centro_expedidor,
                                                v_cd_machine,
                                                2
                                           )
               AND ar.sg_tipo_documento = 'P'
        )
        SELECT -- Protocol
               en.nu_protocolo_entrega Id,              
               ai.cd_incoterms Incoterms,
               en.dt_sugestao_entrega DateSuggested,
               en.qt_quantidade - NVL(en.qt_fornecido, 0) Balance,
               NVL(pw1.qt_saldo, 0) Balance1,
               NVL(pw2.qt_saldo, 0) Balance2,
               NVL(pw1.qt_agendada, 0) PreviousWeek1,
               NVL(pw2.qt_agendada, 0) PreviousWeek2,
               p_cd_elo_agendamento_item SchedulingItemId,
               p_nu_semana WeekNumber,
               
               NVL(pw1.qt_agendada, 0) /*PreviousWeek1*/ AS PlanS0,
               
               CASE WHEN ai.cd_incoterms = 'CIF' THEN
                        CASE WHEN NVL(pw2.qt_agendada, 0) = 0 OR NVL(pw2.qt_saldo, 0) = 0 THEN 0
                             ELSE
                                GREATEST(
                                    0,
                                    (
                                        NVL(pw2.qt_agendada, 0) /*PreviousWeek2*/ 
                                        - 
                                        (
                                            NVL(pw2.qt_saldo, 0) /*Balance2*/ 
                                            - 
                                            (en.qt_quantidade - NVL(en.qt_fornecido, 0)) /*Balance*/
                                        )
                                    )
                                )
                        END
                    ELSE
                        0
               END AS BacklogS1,
               
               -- Available = Balance - Plan S0 - Backlog S-1
               (en.qt_quantidade - NVL(en.qt_fornecido, 0)) /*Balance*/
               - 
               NVL(pw1.qt_agendada, 0) /*PreviousWeek1*/
               -
               (
                   CASE WHEN ai.cd_incoterms = 'CIF' THEN 
                            CASE WHEN NVL(pw2.qt_agendada, 0) = 0 OR NVL(pw2.qt_saldo, 0) = 0 THEN 0
                                 ELSE
                                    GREATEST(
                                        0,
                                        (
                                            NVL(pw2.qt_agendada, 0) /*PreviousWeek2*/ 
                                            - 
                                            (
                                                NVL(pw2.qt_saldo, 0) /*Balance2*/ 
                                                - 
                                                (en.qt_quantidade - NVL(en.qt_fornecido, 0)) /*Balance*/
                                            )
                                        )
                                    )
                            END
                        ELSE
                            0
                   END
               ) AS Available,
               
               CASE WHEN ae.cd_cooperado IS NULL THEN cf.no_cooperativa_filial
                    ELSE pc.no_propriedade
               END FarmName,
               CASE WHEN ae.cd_cooperado IS NULL THEN cl.ds_endereco
                    ELSE pc.ds_endereco
               END Address,
               mu.no_municipio City,
               es.sg_estado State,

               -- DeliveryAuthorization
               ae.cd_autorizacao_entrega Id,
               
               -- Package Group
               sa.cd_grupo_embalagem Id,
               
               -- Contract
               cart.nu_contrato_sap Id,
               cart.nu_contrato PONumber,

               -- ContractItem
               cart.cd_item_contrato Id,

               -- CooperativeBranch
               ae.cd_cooperativa_filial Id,
               cf.no_cooperativa_filial Name,

               -- Cooperado
               ae.cd_cooperado Id,
               cp.no_cooperado Name,

               -- Scheduling Grouping
               gp.cd_elo_agendamento_grouping Id,
               gp.cd_agrupamento_protocolo ProtocolGroupingKey,
               gp.qt_agendada Quantity

          FROM cpt.autorizacao_entrega ae

         INNER JOIN (
                         SELECT DISTINCT ec.nu_contrato,
                                         ec.nu_contrato_sap,
                                         ec.cd_item_contrato
                           FROM vnd.elo_carteira ec
                          WHERE ec.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                            AND ec.ic_ativo = 'S'
                    ) cart
            ON ae.nu_contrato = cart.nu_contrato
           AND ae.cd_item_contrato = cart.cd_item_contrato

         INNER JOIN 
               cpt.entrega                  en
               ON en.cd_autorizacao_entrega = ae.cd_autorizacao_entrega

         INNER JOIN 
               cpt.cooperativa_filial       cf
               ON ae.cd_cooperativa_filial = cf.cd_cooperativa_filial
          
          LEFT OUTER JOIN
               ctf.cliente cl
               ON cl.cd_cliente = cf.cd_cliente
               
          LEFT OUTER JOIN 
               vnd.sacaria                  sa
               ON sa.cd_sacaria = ae.cd_sacaria
            
          LEFT OUTER JOIN 
               cpt.cooperado                cp
               ON cp.cd_cooperado = ae.cd_cooperado
            
          LEFT OUTER JOIN 
               cpt.propriedade_cooperado    pc
               ON pc.cd_propriedade = ae.cd_propriedade
               
          LEFT OUTER JOIN
               ctf.municipio mu
               ON mu.cd_municipio = CASE WHEN ae.cd_cooperado IS NULL THEN pc.cd_municipio
                                         ELSE cl.cd_municipio
                                    END
               
          LEFT OUTER JOIN
               ctf.estado es
               ON es.cd_estado = mu.cd_estado
                 
          LEFT OUTER JOIN 
               grp                          gp
               ON gp.nu_documento = en.nu_protocolo_entrega
            
          LEFT OUTER JOIN 
               prev_week_1                  pw1
               ON pw1.nu_documento = en.nu_protocolo_entrega
            
          LEFT OUTER JOIN 
               prev_week_2                  pw2
               ON pw2.nu_documento = en.nu_protocolo_entrega
               
         INNER JOIN item ai
               ON ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item

         WHERE en.sg_status NOT IN ('C','P')
         
         ORDER BY en.nu_protocolo_entrega
        ;
        
        OPEN p_packages FOR
        SELECT ad.cd_grupo_embalagem Id,
               ROUND(NVL(SUM(ad.nu_quantidade), 0), 1) Quantity,
               CASE WHEN ad.cd_grupo_embalagem = 'B' THEN 1
                    WHEN ad.cd_grupo_embalagem = 'S' THEN 2
                    ELSE 3
               END Ordernator
          FROM vnd.elo_agendamento_day ad
         INNER JOIN
               vnd.elo_agendamento_week aw
               ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
         GROUP BY ad.cd_grupo_embalagem
         ORDER BY 3
        ;
        
        OPEN p_packages_scheduled FOR
        SELECT sa.cd_grupo_embalagem Id,
               ROUND(NVL(SUM(ar.qt_agendada), 0), 1) Quantity,
               CASE WHEN sa.cd_grupo_embalagem = 'B' THEN 1
                    WHEN sa.cd_grupo_embalagem = 'S' THEN 2
                    ELSE 3
               END Ordernator
          FROM vnd.elo_agendamento_grouping ar
         INNER JOIN vnd.elo_agendamento_week aw
            ON aw.cd_elo_agendamento_week = ar.cd_elo_agendamento_week
         INNER JOIN cpt.entrega en
            ON en.nu_protocolo_entrega = ar.nu_documento
         INNER JOIN cpt.autorizacao_entrega ae
            ON en.cd_autorizacao_entrega = ae.cd_autorizacao_entrega
          LEFT OUTER JOIN vnd.sacaria sa
            ON sa.cd_sacaria = ae.cd_sacaria
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND ar.sg_tipo_documento = 'P'
         GROUP BY sa.cd_grupo_embalagem
         ORDER BY 3
         ;
    END px_protocols;



    PROCEDURE px_sales_orders (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_result                    OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT -- Sales Order
               pe.nu_ordem_venda Id,
               NVL(SUM(pe.nu_quantidade - NVL(pe.nu_quantidade_entregue, 0)), 0) Balance,
               p_cd_elo_agendamento_item SchedulingItemId,
               p_nu_semana WeekNumber,

               -- Contract
               cart.nu_contrato_sap Id,
               cart.nu_contrato PONumber,

               -- ContractItem
               cart.cd_item_contrato Id,

               -- Scheduling Grouping
               grp.cd_elo_agendamento_grouping Id,
               grp.cd_agrupamento_protocolo ProtocolGroupingKey,
               NVL(grp.qt_agendada, 0) Quantity

          FROM vnd.pedido pe

         INNER JOIN (
                         select distinct ec.nu_contrato,
                                         ec.nu_contrato_sap,
                                         ec.cd_item_contrato
                           from vnd.elo_carteira ec
                          where ec.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                            and ec.ic_ativo = 'S'
                            and ec.ic_split = 'S'
                    ) cart
            ON pe.nu_contrato = cart.nu_contrato
           AND pe.cd_item_contrato = cart.cd_item_contrato

          LEFT OUTER JOIN (
                                SELECT ar.nu_documento,
                                       ar.cd_elo_agendamento_grouping,
                                       ar.cd_agrupamento_protocolo,
                                       ar.qt_agendada
                                  FROM vnd.elo_agendamento_grouping ar
                                 INNER JOIN vnd.elo_agendamento_week aw
                                    ON aw.cd_elo_agendamento_week = ar.cd_elo_agendamento_week
                                 WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                                   AND ar.sg_tipo_documento = 'D'
                          ) grp

            ON grp.nu_documento = pe.nu_ordem_venda
            
         WHERE pe.cd_situacao_pedido = 20
         
         GROUP BY pe.nu_ordem_venda,
                  cart.nu_contrato_sap,
                  cart.nu_contrato,
                  cart.cd_item_contrato,
                  grp.cd_elo_agendamento_grouping,
                  grp.cd_agrupamento_protocolo,
                  grp.qt_agendada

         ORDER BY pe.nu_ordem_venda
        ;
    END px_sales_orders;
    
    

    PROCEDURE pi_elo_agendamento_grouping (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_week.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_sg_tipo_documento         IN vnd.elo_agendamento_grouping.sg_tipo_documento%TYPE,
        p_nu_documento              IN vnd.elo_agendamento_grouping.nu_documento%TYPE,
        p_qt_agendada               IN vnd.elo_agendamento_grouping.qt_agendada%TYPE,
        p_cd_agrupamento_protocolo  IN vnd.elo_agendamento_grouping.cd_agrupamento_protocolo%TYPE,
        p_cd_usuario_criacao        IN vnd.elo_agendamento_grouping.cd_usuario_criacao%TYPE
    )
    IS
        v_cd_elo_agendamento_week   vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE;
        v_qt_saldo                  vnd.elo_agendamento_grouping.qt_saldo%TYPE := 0;
        v_count                     NUMBER := 0;
    BEGIN
	
		BEGIN
        SELECT cd_elo_agendamento_week 
          INTO v_cd_elo_agendamento_week
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND aw.nu_semana = p_nu_semana
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
            v_cd_elo_agendamento_week:=0;
         WHEN OTHERS THEN
            v_cd_elo_agendamento_week:=0;
         END;
        
        IF p_sg_tipo_documento = 'P' THEN
			BEGIN
            SELECT COUNT(en.cd_entrega)
              INTO v_count
              FROM cpt.entrega en
             WHERE en.nu_protocolo_entrega = p_nu_documento
            ;
			EXCEPTION 
			WHEN NO_DATA_FOUND THEN 
			v_count:=0;
			WHEN OTHERS THEN
			v_count:=0;
			END;
			
			
            IF v_count > 0 THEN
				BEGIN
                SELECT NVL(en.qt_quantidade, 0) - NVL(en.qt_fornecido, 0)
                  INTO v_qt_saldo
                  FROM cpt.entrega en
                 WHERE en.nu_protocolo_entrega = p_nu_documento
                ;
				EXCEPTION 
				WHEN NO_DATA_FOUND THEN 
				v_qt_saldo:=0;
				WHEN OTHERS THEN
				v_qt_saldo:=0;
				END;
            END IF;
        END IF;

		BEGIN
        MERGE INTO vnd.elo_agendamento_grouping ar USING DUAL ON (
                ar.cd_elo_agendamento_week = v_cd_elo_agendamento_week
            AND ar.nu_documento = p_nu_documento
            AND ar.sg_tipo_documento = p_sg_tipo_documento
        )

        WHEN MATCHED THEN
            UPDATE 
               SET qt_agendada              = p_qt_agendada,
                   cd_usuario_alteracao     = p_cd_usuario_criacao,
                   dh_alteracao             = SYSDATE
--             WHERE cd_elo_agendamento_item  = p_cd_elo_agendamento_item
--               AND nu_semana                = p_nu_semana

        WHEN NOT MATCHED THEN
            INSERT (
                cd_elo_agendamento_grouping, 
                cd_elo_agendamento_week, 
                cd_agrupamento_protocolo, 
                cd_usuario_alteracao, 
                cd_usuario_criacao, 
                dh_alteracao, 
                dh_criacao, 
                nu_documento, 
                qt_agendada, 
                sg_tipo_documento,
                qt_saldo
            ) VALUES (
                seq_elo_agendamento_grouping.nextval,
                v_cd_elo_agendamento_week,
                p_cd_agrupamento_protocolo,
                NULL,
                p_cd_usuario_criacao,
                NULL,
                SYSDATE,
                p_nu_documento,
                p_qt_agendada,
                p_sg_tipo_documento,
                v_qt_saldo
            );
		COMMIT;	
		EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.037 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;
		END;		
			
			
    END pi_elo_agendamento_grouping;




    PROCEDURE px_scheduling (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_result            OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        -- Agendamento total plant capacity
        WITH total_plant_capacity AS (
                  SELECT ag.cd_elo_agendamento,
                         SUM(ci.nu_capacidade) AS ag_total_plant_capacity

                    FROM vnd.elo_agendamento_centro_item ci

                   INNER JOIN vnd.elo_agendamento_centro ac
                      ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                   INNER JOIN vnd.elo_agendamento ag
                      ON ag.dt_week_start = ac.dt_week_start

                  WHERE 
                        (
                             p_site_type = 'P' AND ac.cd_polo = p_cd_site
                             OR
                             p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                             OR
                             p_site_type = 'M' AND ac.cd_machine = p_cd_site
                        )
                    AND ci.ic_ativo = 'S'
                    AND ac.ic_ativo = 'S'
                    AND ag.ic_ativo = 'S'
                    AND ag.cd_week = p_cd_week
                  GROUP BY ag.cd_elo_agendamento
             )
        SELECT ag.cd_elo_agendamento AS Id,
               ag.dh_limite AS LimitDate,
               pc.ag_total_plant_capacity AS LocalCapacity,
               (
                   select count(cd_elo_agendamento_supervisor)
                     from vnd.elo_agendamento_supervisor ap
                    where ap.cd_elo_agendamento = ag.cd_elo_agendamento
                      and ap.cd_elo_status <> vnd.gx_elo_common.fx_elo_status('AGSUP', 'ASFIN')
               ) AS OpenSupervisors,
               NVL(ag.qt_limite_emergencial, 0) AS EmergencialLimit,
               NVL(ag.nu_semanas, 1) Weeks,
               gx_elo_common.fx_elo_status_order('AGEND','AGFIN') FinalizedStatusOrder,

               -- Status
               ag.cd_elo_status AS Id,
               es.sg_status AS Symbol,
               es.ds_status AS Description,
               gx_elo_common.fx_elo_status_order(ag.cd_elo_status) StatusOrder

          FROM vnd.elo_agendamento ag

          LEFT OUTER JOIN vnd.elo_status es
            ON es.cd_elo_status = ag.cd_elo_status

          LEFT OUTER JOIN total_plant_capacity pc
            ON pc.cd_elo_agendamento = ag.cd_elo_agendamento

         WHERE 
               (
                   p_site_type = 'P' AND ag.cd_polo = p_cd_site
                   OR
                   p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                   OR
                   p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
           AND ag.cd_week = p_cd_week
        ;
    END px_scheduling;





    PROCEDURE pu_end_supervisor_scheduling (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_cd_sales_office   IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group    IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    )
    IS
        v_cd_elo_agendamento        vnd.elo_agendamento.cd_elo_agendamento%TYPE;
        v_cd_elo_carteira           vnd.elo_carteira.cd_elo_carteira%TYPE;
        v_cd_elo_agendamento_item   vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE;
        v_qt_agendada_item          vnd.elo_carteira.qt_agendada%TYPE;
        v_qt_semana_item            vnd.elo_agendamento_week.qt_semana%TYPE;
        v_qt_saldo_semana           vnd.elo_agendamento_week.qt_semana%TYPE;
        v_count_semana_disponivel   NUMBER;
        v_limit                     NUMBER := 10000;
        v_count                     NUMBER := 0;
        v_qt_agendada               vnd.elo_carteira.qt_agendada%TYPE;
        v_qt_agendada_day           vnd.elo_carteira_day.nu_quantidade%TYPE;
        v_qt_agendada_day_sum       vnd.elo_carteira_day.nu_quantidade%TYPE;
        v_status_order_atual        vnd.elo_status.nu_order%TYPE;
        v_status_order_novo         vnd.elo_status.nu_order%TYPE;

        -- Quantidade Semana disponivel
        CURSOR c_semana_disponivel IS
        SELECT COUNT(cd_elo_agendamento_week) FROM (
            SELECT aw.cd_elo_agendamento_week,
                   aw.qt_semana,
                   NVL(SUM(ca.qt_saldo),0) qt_saldo,
                   NVL(SUM(ca.qt_agendada),0) qt_agendada,
                   NVL(SUM(ca.qt_saldo),0) - NVL(SUM(ca.qt_agendada),0) qt_saldo_disponivel,
                   aw.qt_semana - NVL(SUM(ca.qt_agendada),0) qt_semana_disponivel

              FROM vnd.elo_agendamento_week aw

              LEFT OUTER JOIN vnd.elo_agendamento_item ai
                ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

             INNER JOIN vnd.elo_agendamento_supervisor ap
                ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor

              LEFT OUTER JOIN vnd.elo_carteira ca
                ON ca.cd_elo_agendamento = ap.cd_elo_agendamento
               AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

             WHERE (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
               AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
               AND ap.cd_elo_agendamento = v_cd_elo_agendamento
               AND ap.ic_ativo = 'S'
               AND NVL(aw.qt_semana,0) > 0

             GROUP BY aw.cd_elo_agendamento_week,
                      aw.qt_semana

            HAVING (NVL(SUM(ca.qt_saldo),0) - NVL(SUM(ca.qt_agendada),0)) > 0
               AND (aw.qt_semana - NVL(SUM(ca.qt_agendada),0)) > 0
        )
        ;

        TYPE carteira_r IS RECORD
        (
            cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
            nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE
        );
        TYPE carteira_t IS TABLE OF carteira_r;
        t_carteira carteira_t;

        CURSOR c_carteira IS
        SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) qt_saldo,
               ca.nu_ordem
          FROM vnd.elo_carteira ca
         INNER JOIN vnd.elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
         INNER JOIN vnd.elo_agendamento_week aw
            ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
         WHERE NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           AND NVL(aw.qt_semana, 0) > 0
           AND ca.cd_elo_agendamento = v_cd_elo_agendamento
           AND ca.ic_ativo = 'S'
           AND ai.ic_ativo = 'S'
         ORDER BY ca.nu_ordem
        ;

        CURSOR c_sum_agendada_item IS
        SELECT NVL(SUM(ca.qt_agendada), 0) 
          FROM vnd.elo_carteira ca
         WHERE ca.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND NVL(ca.qt_agendada, 0) > 0
           AND ca.ic_ativo = 'S'
        ;

        CURSOR c_sum_semana IS
        SELECT NVL(SUM(aw.qt_semana), 0)
          FROM vnd.elo_agendamento_week aw 
         WHERE aw.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND NVL(aw.qt_semana, 0) > 0
        ;

        TYPE carteira_day_r IS RECORD
        (
            cd_elo_agendamento_item vnd.elo_carteira.cd_elo_agendamento_item%TYPE,
            cd_elo_agendamento_day  vnd.elo_agendamento_day.cd_elo_agendamento_day%TYPE,
            cd_grupo_embalagem      vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
            nu_semana               vnd.elo_agendamento_week.nu_semana%TYPE,
            nu_dia_semana           vnd.elo_agendamento_day.nu_dia_semana%TYPE,
            qt_agendamento          vnd.elo_agendamento_day.nu_quantidade%TYPE,
            qt_carteira             vnd.elo_carteira_day.nu_quantidade%TYPE,
            qt_disponivel           vnd.elo_agendamento_day.nu_quantidade%TYPE
        );
        TYPE carteira_day_t IS TABLE OF carteira_day_r;
        t_carteira_day carteira_day_t;

        CURSOR c_carteira_day IS
        SELECT DISTINCT ca.cd_elo_agendamento_item,
               ad.cd_elo_agendamento_day,
               ad.cd_grupo_embalagem,
               aw.nu_semana,
               ad.nu_dia_semana,
               ad.nu_quantidade qt_agendamento,
               cd.nu_quantidade qt_carteira,
               NVL(SUM(ad.nu_quantidade),0) - NVL(SUM(cd.nu_quantidade),0) qt_disponivel

          FROM elo_agendamento_day ad

         INNER JOIN elo_agendamento_week aw
            ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week

         INNER JOIN elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

         INNER JOIN elo_agendamento_supervisor ap
            ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor

         INNER JOIN elo_agendamento ag
            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento

         INNER JOIN elo_carteira ca
            ON ca.cd_elo_agendamento = ag.cd_elo_agendamento
           AND ca.cd_elo_agendamento = ap.cd_elo_agendamento
           AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

          LEFT OUTER JOIN elo_carteira_day cd
            ON cd.cd_elo_carteira = ca.cd_elo_carteira
           AND cd.nu_semana = aw.nu_semana
           AND cd.nu_dia_semana = ad.nu_dia_semana

         WHERE ai.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND NVL(aw.qt_semana, 0) > 0

         GROUP BY ca.cd_elo_agendamento_item,
                  ad.cd_elo_agendamento_day,
                  ad.cd_grupo_embalagem,
                  aw.nu_semana,
                  ad.nu_dia_semana,
                  ad.nu_quantidade,
                  cd.nu_quantidade

        HAVING (NVL(SUM(ad.nu_quantidade),0) - NVL(SUM(cd.nu_quantidade),0)) > 0

         ORDER BY aw.nu_semana,
                  ad.nu_dia_semana
        ;

    BEGIN
		BEGIN
        SELECT an.cd_elo_agendamento,
               gx_elo_common.fx_elo_status_order(an.cd_elo_status)
          INTO v_cd_elo_agendamento,
               v_status_order_atual
          FROM vnd.elo_agendamento an
          WHERE 
                (
                    p_site_type = 'P' AND an.cd_polo = p_cd_site
                    OR
                    p_site_type = 'C' AND an.cd_centro_expedidor = p_cd_site
                    OR
                    p_site_type = 'M' AND an.cd_machine = p_cd_site
                )
            AND an.cd_week = p_cd_week
            AND an.ic_ativo = 'S'
        ;
		EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
			BEGIN
            v_cd_elo_agendamento:=0;
			v_status_order_atual:=NULL;
			END;
         WHEN OTHERS THEN
			BEGIN
            v_cd_elo_agendamento:=0;
			v_status_order_atual:=NULL;
			END;
         END;
		

        SELECT gx_elo_common.fx_elo_status_order('AGSUP', 'ASFIN')
          INTO v_status_order_novo
          FROM dual
        ;
        
        IF v_status_order_atual IS NOT NULL AND v_status_order_atual > v_status_order_novo THEN
            RETURN;
        END IF;
        
		BEGIN
		
        gx_elo_scheduling.pu_distribute_protocol_group(
            v_cd_elo_agendamento, 
            p_cd_sales_office, 
            p_cd_sales_group
        );
		
		EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.050 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
        END; 
		END;
        
		BEGIN
        gx_elo_scheduling.pu_distribute_split_group(
            v_cd_elo_agendamento, 
            p_cd_sales_office, 
            p_cd_sales_group
        );
		
		EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.051 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
        END; 
		END;

        <<main_loop>>
        LOOP
            OPEN    c_semana_disponivel;
            FETCH   c_semana_disponivel INTO v_count_semana_disponivel;
            CLOSE   c_semana_disponivel;

            EXIT WHEN v_count_semana_disponivel = 0 OR v_count = v_limit;

            OPEN    c_carteira;                               
            FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
            CLOSE   c_carteira;
            
            FOR i_cart IN 1 .. t_carteira.COUNT
            LOOP
                v_cd_elo_carteira           := t_carteira(i_cart).cd_elo_carteira;
                v_cd_elo_agendamento_item   := t_carteira(i_cart).cd_elo_agendamento_item;

                OPEN    c_sum_agendada_item;
                FETCH   c_sum_agendada_item INTO v_qt_agendada_item;
                CLOSE   c_sum_agendada_item;

                OPEN    c_sum_semana;
                FETCH   c_sum_semana INTO v_qt_semana_item;
                CLOSE   c_sum_semana;

                v_qt_saldo_semana := v_qt_semana_item - v_qt_agendada_item;

                CONTINUE WHEN v_qt_saldo_semana = 0;

                IF t_carteira(i_cart).qt_saldo >= v_qt_saldo_semana THEN
                    v_qt_agendada := v_qt_saldo_semana;
                ELSE
                    v_qt_agendada := t_carteira(i_cart).qt_saldo;
                END IF;

--                UPDATE vnd.elo_carteira ec
--                   SET ec.qt_agendada = NVL(ec.qt_agendada, 0) + v_qt_agendada,
--                       ec.qt_agendada_confirmada = NVL(ec.qt_agendada, 0) + v_qt_agendada
--                 WHERE ec.cd_elo_carteira = v_cd_elo_carteira
--                ;
                
				BEGIN
                UPDATE vnd.elo_carteira ec
                   SET ec.qt_agendada = v_qt_agendada,
                       ec.qt_agendada_confirmada = v_qt_agendada
                 WHERE ec.cd_elo_carteira = v_cd_elo_carteira
                ;
				COMMIT;
				EXCEPTION  
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.055 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					ROLLBACK;
				END;    
				END;

                -- Inserts or updates ELO_CARTEIRA_DAY.
                OPEN    c_carteira_day;                               
                FETCH   c_carteira_day BULK COLLECT INTO t_carteira_day LIMIT v_limit;
                CLOSE   c_carteira_day;

                v_qt_agendada_day       := 0;
                v_qt_agendada_day_sum   := 0;

                <<day_loop>>
                LOOP
                    <<carteira_day_loop>>
                    FOR i_cart_day IN 1 .. t_carteira_day.COUNT
                    LOOP
                        IF t_carteira_day(i_cart_day).qt_disponivel < v_qt_agendada THEN
                            v_qt_agendada_day := t_carteira_day(i_cart_day).qt_disponivel;
                        ELSE
                            v_qt_agendada_day := v_qt_agendada;
                        END IF;

                        v_qt_agendada_day_sum := v_qt_agendada_day_sum + v_qt_agendada_day;
                        IF v_qt_agendada_day_sum > v_qt_agendada THEN
                            v_qt_agendada_day := v_qt_agendada_day_sum - v_qt_agendada;
                        END IF;

						BEGIN	
                        gx_elo_scheduling.pu_carteira_day(
                            v_cd_elo_carteira,
                            t_carteira_day(i_cart_day).cd_grupo_embalagem,
                            t_carteira_day(i_cart_day).nu_semana,
                            t_carteira_day(i_cart_day).nu_dia_semana,
                            v_qt_agendada_day
                        );
						EXCEPTION  
						WHEN OTHERS THEN 
						BEGIN
							RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.056 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
							--ROLLBACK;
						END;    
						END;						
						

                        EXIT day_loop WHEN v_qt_agendada_day_sum >= v_qt_agendada;
                    END LOOP carteira_day_loop;
                END LOOP day_loop;

                COMMIT;
            END LOOP;

            v_count := v_count + 1;
        END LOOP main_loop;

		BEGIN
        gx_elo_scheduling.pu_distribute_emergency(
            v_cd_elo_agendamento, 
            p_cd_sales_office, 
            p_cd_sales_group
        );
		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.057 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			--ROLLBACK;
		END;    
		END;								
		
        
        -- Update supervisors scheduling status.
		BEGIN
        pu_agendamento_status (
            v_cd_elo_agendamento,
            p_cd_week,
            p_cd_site,
            p_site_type,
            p_cd_sales_office,
            p_cd_sales_group
        );

		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.058 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			--ROLLBACK;
		END;    
		END;			
		
		
    END pu_end_supervisor_scheduling;



    PROCEDURE pu_distribute_protocol_group (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    )
    IS
        v_limit                     NUMBER := 100;
        v_cd_elo_agendamento_item   vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE;
        v_nu_documento              vnd.elo_agendamento_grouping.nu_documento%TYPE;
        v_qt_agendada_grouping      vnd.elo_agendamento_grouping.qt_agendada%TYPE;
        v_nu_contrato_sap           vnd.elo_carteira.nu_contrato_sap%TYPE;
        v_cd_item_contrato          vnd.elo_carteira.cd_item_contrato%TYPE;
        v_cd_elo_carteira           vnd.elo_carteira.cd_elo_carteira%TYPE;
        v_qt_agendada_carteira      vnd.elo_agendamento_grouping.qt_agendada%TYPE;
        v_qt_agendada_day           vnd.elo_carteira_day.nu_quantidade%TYPE;
        v_qt_agendada_day_sum       vnd.elo_carteira_day.nu_quantidade%TYPE;


        /* --- GROUPING --- */
        TYPE grouping_r IS RECORD
        (
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            cd_elo_agendamento_grouping     vnd.elo_agendamento_grouping.cd_elo_agendamento_grouping%TYPE,
            nu_documento                    vnd.elo_agendamento_grouping.nu_documento%TYPE,
            nu_contrato_sap                 vnd.elo_carteira.nu_contrato_sap%TYPE,
            cd_item_contrato                vnd.elo_carteira.cd_item_contrato%TYPE,
            qt_agendada                     vnd.elo_agendamento_grouping.qt_agendada%TYPE
        );
        TYPE grouping_t IS TABLE OF grouping_r;
        t_grouping grouping_t;
        
        CURSOR c_grouping IS
        SELECT 
               ai.cd_elo_agendamento_item,
               gp.cd_elo_agendamento_grouping,
               gp.nu_documento,
               ae.nu_contrato_sap,
               ae.cd_item_contrato,
               gp.qt_agendada

          FROM vnd.elo_agendamento_week aw

         INNER JOIN vnd.elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

         INNER JOIN vnd.elo_agendamento_supervisor ap
            ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
            
         INNER JOIN vnd.elo_agendamento_grouping gp
            ON gp.cd_elo_agendamento_week = aw.cd_elo_agendamento_week
        
         INNER JOIN cpt.entrega en
            ON en.nu_protocolo_entrega = gp.nu_documento
            
         INNER JOIN cpt.autorizacao_entrega ae
            ON ae.cd_autorizacao_entrega = en.cd_autorizacao_entrega
        
         WHERE (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
           AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
           AND ap.cd_elo_agendamento = p_cd_elo_agendamento
           AND ap.ic_ativo = 'S'
           AND NVL(gp.qt_agendada, 0) > 0
           AND gp.sg_tipo_documento = 'P'
        ;
        
        /* --- CARTEIRA --- */
        TYPE carteira_r IS RECORD
        (
            cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
            nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE
        );
        TYPE carteira_t IS TABLE OF carteira_r;
        t_carteira carteira_t;

        CURSOR c_carteira IS
        SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) qt_saldo,
               nu_ordem
          FROM vnd.elo_carteira ca
         WHERE NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           AND ca.cd_elo_agendamento = p_cd_elo_agendamento
           AND ca.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND ca.nu_contrato_sap = v_nu_contrato_sap
           AND ca.cd_item_contrato = v_cd_item_contrato
           AND ca.ic_ativo = 'S'
         ORDER BY ca.nu_ordem
        ;
        
        /* --- CARTEIRA_DAY --- */
        TYPE carteira_day_r IS RECORD
        (
            cd_elo_agendamento_item vnd.elo_carteira.cd_elo_agendamento_item%TYPE,
            cd_elo_agendamento_day  vnd.elo_agendamento_day.cd_elo_agendamento_day%TYPE,
            cd_grupo_embalagem      vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
            nu_semana               vnd.elo_agendamento_week.nu_semana%TYPE,
            nu_dia_semana           vnd.elo_agendamento_day.nu_dia_semana%TYPE,
            qt_agendamento          vnd.elo_agendamento_day.nu_quantidade%TYPE,
            qt_carteira             vnd.elo_carteira_day.nu_quantidade%TYPE,
            qt_disponivel           vnd.elo_agendamento_day.nu_quantidade%TYPE
        );
        TYPE carteira_day_t IS TABLE OF carteira_day_r;
        t_carteira_day carteira_day_t;

        CURSOR c_carteira_day IS
        SELECT DISTINCT ca.cd_elo_agendamento_item,
               ad.cd_elo_agendamento_day,
               ad.cd_grupo_embalagem,
               aw.nu_semana,
               ad.nu_dia_semana,
               ad.nu_quantidade qt_agendamento,
               cd.nu_quantidade qt_carteira,
               NVL(SUM(ad.nu_quantidade),0) - NVL(SUM(cd.nu_quantidade),0) qt_disponivel

          FROM elo_agendamento_day ad

         INNER JOIN elo_agendamento_week aw
            ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week

         INNER JOIN elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

         INNER JOIN elo_agendamento_supervisor ap
            ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor

         INNER JOIN elo_agendamento ag
            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento

         INNER JOIN elo_carteira ca
            ON ca.cd_elo_agendamento = ag.cd_elo_agendamento
           AND ca.cd_elo_agendamento = ap.cd_elo_agendamento
           AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

          LEFT OUTER JOIN elo_carteira_day cd
            ON cd.cd_elo_carteira = ca.cd_elo_carteira
           AND cd.nu_semana = aw.nu_semana
           AND cd.nu_dia_semana = ad.nu_dia_semana

         WHERE ai.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND NVL(aw.qt_semana, 0) > 0

         GROUP BY ca.cd_elo_agendamento_item,
                  ad.cd_elo_agendamento_day,
                  ad.cd_grupo_embalagem,
                  aw.nu_semana,
                  ad.nu_dia_semana,
                  ad.nu_quantidade,
                  cd.nu_quantidade

        HAVING (NVL(SUM(ad.nu_quantidade),0) - NVL(SUM(cd.nu_quantidade),0)) > 0

         ORDER BY aw.nu_semana,
                  ad.nu_dia_semana
        ;
    BEGIN
        OPEN    c_grouping;
        FETCH   c_grouping BULK COLLECT INTO t_grouping LIMIT v_limit;
        CLOSE   c_grouping;
        
        <<grouping_loop>>
        FOR i_group IN 1 .. t_grouping.COUNT
        LOOP
            v_cd_elo_agendamento_item   := t_grouping(i_group).cd_elo_agendamento_item;
            v_nu_contrato_sap           := t_grouping(i_group).nu_contrato_sap;
            v_cd_item_contrato          := t_grouping(i_group).cd_item_contrato;
            v_qt_agendada_grouping      := t_grouping(i_group).qt_agendada;
        
            OPEN    c_carteira;                               
            FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
            CLOSE   c_carteira;
            
            <<carteira_loop>>
            FOR i_cart IN 1 .. t_carteira.COUNT
            LOOP
                v_cd_elo_carteira       := t_carteira(i_cart).cd_elo_carteira;
                v_qt_agendada_carteira  := 0;
                
                IF t_carteira(i_cart).qt_saldo >= v_qt_agendada_grouping THEN
                    v_qt_agendada_carteira := v_qt_agendada_grouping;
                ELSE
                    v_qt_agendada_carteira := t_carteira(i_cart).qt_saldo;
                END IF;
                
				BEGIN
                UPDATE vnd.elo_carteira ec
                   SET ec.qt_agendada = NVL(ec.qt_agendada, 0) + v_qt_agendada_carteira,
                       ec.qt_agendada_confirmada = NVL(ec.qt_agendada, 0) + v_qt_agendada_carteira
                 WHERE ec.cd_elo_carteira = v_cd_elo_carteira;
				 COMMIT;
				 EXCEPTION  
				WHEN OTHERS THEN 
				BEGIN
					RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.060 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
					ROLLBACK;
				END;  
				END;
				 

                -- Inserts or updates ELO_CARTEIRA_DAY.
                OPEN    c_carteira_day;                               
                FETCH   c_carteira_day BULK COLLECT INTO t_carteira_day LIMIT v_limit;
                CLOSE   c_carteira_day;
                
                v_qt_agendada_day       := 0;
                v_qt_agendada_day_sum   := 0;

                <<day_loop>>
                LOOP
                    <<carteira_day_loop>>
                    FOR i_cart_day IN 1 .. t_carteira_day.COUNT
                    LOOP
                        IF t_carteira_day(i_cart_day).qt_disponivel < v_qt_agendada_carteira THEN
                            v_qt_agendada_day := t_carteira_day(i_cart_day).qt_disponivel;
                        ELSE
                            v_qt_agendada_day := v_qt_agendada_carteira;
                        END IF;

                        v_qt_agendada_day_sum := v_qt_agendada_day_sum + v_qt_agendada_day;
                        IF v_qt_agendada_day_sum > v_qt_agendada_carteira THEN
                            v_qt_agendada_day := v_qt_agendada_day_sum - v_qt_agendada_carteira;
                        END IF;

						BEGIN
                        gx_elo_scheduling.pu_carteira_day(
                            v_cd_elo_carteira,
                            t_carteira_day(i_cart_day).cd_grupo_embalagem,
                            t_carteira_day(i_cart_day).nu_semana,
                            t_carteira_day(i_cart_day).nu_dia_semana,
                            v_qt_agendada_day
                        );
						EXCEPTION  
						WHEN OTHERS THEN 
						BEGIN
						RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.061 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
						ROLLBACK;
						END;  
						END;
						

                        EXIT day_loop WHEN v_qt_agendada_day_sum >= v_qt_agendada_carteira;
                    END LOOP carteira_day_loop;
                END LOOP day_loop;

                v_qt_agendada_grouping := v_qt_agendada_grouping - v_qt_agendada_carteira;
                
                EXIT carteira_loop WHEN v_qt_agendada_grouping <= 0;
                
            END LOOP carteira_loop;
            
        END LOOP grouping_loop;

    END pu_distribute_protocol_group;
    
    
    
    PROCEDURE pu_distribute_split_group (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    )
    IS
        v_limit                     NUMBER := 100;
        v_cd_elo_agendamento_item   vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE;
        v_nu_documento              vnd.elo_agendamento_grouping.nu_documento%TYPE;
        v_qt_agendada_grouping      vnd.elo_agendamento_grouping.qt_agendada%TYPE;
        v_nu_ordem_venda            vnd.elo_carteira.nu_ordem_venda%TYPE;
        v_cd_elo_carteira           vnd.elo_carteira.cd_elo_carteira%TYPE;
        v_qt_agendada_carteira      vnd.elo_agendamento_grouping.qt_agendada%TYPE;
        v_qt_agendada_day           vnd.elo_carteira_day.nu_quantidade%TYPE;
        v_qt_agendada_day_sum       vnd.elo_carteira_day.nu_quantidade%TYPE;


        /* --- GROUPING --- */
        TYPE grouping_r IS RECORD
        (
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            cd_elo_agendamento_grouping     vnd.elo_agendamento_grouping.cd_elo_agendamento_grouping%TYPE,
            nu_documento                    vnd.elo_agendamento_grouping.nu_documento%TYPE,
            qt_agendada                     vnd.elo_agendamento_grouping.qt_agendada%TYPE
        );
        TYPE grouping_t IS TABLE OF grouping_r;
        t_grouping grouping_t;
        
        CURSOR c_grouping IS
        SELECT 
               ai.cd_elo_agendamento_item,
               gp.cd_elo_agendamento_grouping,
               gp.nu_documento,
               gp.qt_agendada

          FROM vnd.elo_agendamento_week aw

         INNER JOIN vnd.elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

         INNER JOIN vnd.elo_agendamento_supervisor ap
            ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
            
         INNER JOIN vnd.elo_agendamento_grouping gp
            ON gp.cd_elo_agendamento_week = aw.cd_elo_agendamento_week
               
         WHERE (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
           AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
           AND ap.cd_elo_agendamento = p_cd_elo_agendamento
           AND ap.ic_ativo = 'S'
           AND NVL(gp.qt_agendada, 0) > 0
           AND gp.sg_tipo_documento = 'D'
        ;
        
        /* --- CARTEIRA --- */
        TYPE carteira_r IS RECORD
        (
            cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
            nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE
        );
        TYPE carteira_t IS TABLE OF carteira_r;
        t_carteira carteira_t;

        CURSOR c_carteira IS
        SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) qt_saldo,
               nu_ordem
          FROM vnd.elo_carteira ca
         WHERE NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           AND ca.cd_elo_agendamento = p_cd_elo_agendamento
           AND ca.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND ca.nu_ordem_venda = v_nu_ordem_venda
           AND ca.ic_ativo = 'S'
         ORDER BY ca.nu_ordem
        ;
        
        /* --- CARTEIRA_DAY --- */
        TYPE carteira_day_r IS RECORD
        (
            cd_elo_agendamento_item vnd.elo_carteira.cd_elo_agendamento_item%TYPE,
            cd_elo_agendamento_day  vnd.elo_agendamento_day.cd_elo_agendamento_day%TYPE,
            cd_grupo_embalagem      vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
            nu_semana               vnd.elo_agendamento_week.nu_semana%TYPE,
            nu_dia_semana           vnd.elo_agendamento_day.nu_dia_semana%TYPE,
            qt_agendamento          vnd.elo_agendamento_day.nu_quantidade%TYPE,
            qt_carteira             vnd.elo_carteira_day.nu_quantidade%TYPE,
            qt_disponivel           vnd.elo_agendamento_day.nu_quantidade%TYPE
        );
        TYPE carteira_day_t IS TABLE OF carteira_day_r;
        t_carteira_day carteira_day_t;

        CURSOR c_carteira_day IS
        SELECT DISTINCT ca.cd_elo_agendamento_item,
               ad.cd_elo_agendamento_day,
               ad.cd_grupo_embalagem,
               aw.nu_semana,
               ad.nu_dia_semana,
               ad.nu_quantidade qt_agendamento,
               cd.nu_quantidade qt_carteira,
               NVL(SUM(ad.nu_quantidade),0) - NVL(SUM(cd.nu_quantidade),0) qt_disponivel

          FROM elo_agendamento_day ad

         INNER JOIN elo_agendamento_week aw
            ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week

         INNER JOIN elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

         INNER JOIN elo_agendamento_supervisor ap
            ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor

         INNER JOIN elo_agendamento ag
            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento

         INNER JOIN elo_carteira ca
            ON ca.cd_elo_agendamento = ag.cd_elo_agendamento
           AND ca.cd_elo_agendamento = ap.cd_elo_agendamento
           AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

          LEFT OUTER JOIN elo_carteira_day cd
            ON cd.cd_elo_carteira = ca.cd_elo_carteira
           AND cd.nu_semana = aw.nu_semana
           AND cd.nu_dia_semana = ad.nu_dia_semana

         WHERE ai.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND NVL(aw.qt_semana, 0) > 0

         GROUP BY ca.cd_elo_agendamento_item,
                  ad.cd_elo_agendamento_day,
                  ad.cd_grupo_embalagem,
                  aw.nu_semana,
                  ad.nu_dia_semana,
                  ad.nu_quantidade,
                  cd.nu_quantidade

        HAVING (NVL(SUM(ad.nu_quantidade),0) - NVL(SUM(cd.nu_quantidade),0)) > 0

         ORDER BY aw.nu_semana,
                  ad.nu_dia_semana
        ;
    BEGIN
        OPEN    c_grouping;
        FETCH   c_grouping BULK COLLECT INTO t_grouping LIMIT v_limit;
        CLOSE   c_grouping;
        
        <<grouping_loop>>
        FOR i_group IN 1 .. t_grouping.COUNT
        LOOP
            v_cd_elo_agendamento_item   := t_grouping(i_group).cd_elo_agendamento_item;
            v_nu_ordem_venda            := t_grouping(i_group).nu_documento;
            v_qt_agendada_grouping      := t_grouping(i_group).qt_agendada;
        
            OPEN    c_carteira;                               
            FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
            CLOSE   c_carteira;
            
            <<carteira_loop>>
            FOR i_cart IN 1 .. t_carteira.COUNT
            LOOP
                v_cd_elo_carteira       := t_carteira(i_cart).cd_elo_carteira;
                v_qt_agendada_carteira  := 0;
                
                IF t_carteira(i_cart).qt_saldo >= v_qt_agendada_grouping THEN
                    v_qt_agendada_carteira := v_qt_agendada_grouping;
                ELSE
                    v_qt_agendada_carteira := t_carteira(i_cart).qt_saldo;
                END IF;
                
				BEGIN
                UPDATE vnd.elo_carteira ec
                   SET ec.qt_agendada = NVL(ec.qt_agendada, 0) + v_qt_agendada_carteira,
                       ec.qt_agendada_confirmada = NVL(ec.qt_agendada, 0) + v_qt_agendada_carteira
                 WHERE ec.cd_elo_carteira = v_cd_elo_carteira;
				 COMMIT;
				EXCEPTION  
				WHEN OTHERS THEN 
				BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.062 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
				END; 
				END;

                -- Inserts or updates ELO_CARTEIRA_DAY.
                OPEN    c_carteira_day;                               
                FETCH   c_carteira_day BULK COLLECT INTO t_carteira_day LIMIT v_limit;
                CLOSE   c_carteira_day;
                
                v_qt_agendada_day       := 0;
                v_qt_agendada_day_sum   := 0;

                <<day_loop>>
                LOOP
                    <<carteira_day_loop>>
                    FOR i_cart_day IN 1 .. t_carteira_day.COUNT
                    LOOP
                        IF t_carteira_day(i_cart_day).qt_disponivel < v_qt_agendada_carteira THEN
                            v_qt_agendada_day := t_carteira_day(i_cart_day).qt_disponivel;
                        ELSE
                            v_qt_agendada_day := v_qt_agendada_carteira;
                        END IF;

                        v_qt_agendada_day_sum := v_qt_agendada_day_sum + v_qt_agendada_day;
                        IF v_qt_agendada_day_sum > v_qt_agendada_carteira THEN
                            v_qt_agendada_day := v_qt_agendada_day_sum - v_qt_agendada_carteira;
                        END IF;

						BEGIN
                        gx_elo_scheduling.pu_carteira_day(
                            v_cd_elo_carteira,
                            t_carteira_day(i_cart_day).cd_grupo_embalagem,
                            t_carteira_day(i_cart_day).nu_semana,
                            t_carteira_day(i_cart_day).nu_dia_semana,
                            v_qt_agendada_day
                        );
						EXCEPTION  
						WHEN OTHERS THEN 
						BEGIN
						RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.063 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
						--ROLLBACK;
						END; 
						END;
						

                        EXIT day_loop WHEN v_qt_agendada_day_sum >= v_qt_agendada_carteira;
                    END LOOP carteira_day_loop;
                END LOOP day_loop;

                v_qt_agendada_grouping := v_qt_agendada_grouping - v_qt_agendada_carteira;
                
                EXIT carteira_loop WHEN v_qt_agendada_grouping <= 0;
                
            END LOOP carteira_loop;
            
        END LOOP grouping_loop;

    END pu_distribute_split_group;
    
    

    PROCEDURE pu_distribute_emergency (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    )
    IS
        v_limit                     NUMBER := 100;
        v_cd_elo_agendamento_item   vnd.elo_agendamento_week.cd_elo_agendamento_item%TYPE;
        v_cd_elo_carteira           vnd.elo_carteira.cd_elo_carteira%TYPE;
        v_qt_emergencial_week       vnd.elo_agendamento_week.qt_emergencial%TYPE;
        v_qt_emergencial_carteira   vnd.elo_carteira.qt_emergencial%TYPE;
        
        /* --- EMERGENCY ITEMS --- */
        TYPE emergency_r IS RECORD
        (
            cd_elo_agendamento_item         vnd.elo_agendamento_week.cd_elo_agendamento_item%TYPE,
            qt_emergencial                  vnd.elo_agendamento_week.qt_emergencial%TYPE
        );
        TYPE emergency_t IS TABLE OF emergency_r;
        t_emergency emergency_t;
        
        CURSOR c_emergency IS
        SELECT 
               aw.cd_elo_agendamento_item
             , SUM(aw.qt_emergencial) qt_emergencial

          FROM 
               vnd.elo_agendamento_week aw
          
               INNER JOIN 
               vnd.elo_agendamento_item ai
               ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
            
               INNER JOIN 
               vnd.elo_agendamento_supervisor ap
               ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
          
         WHERE 
               (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
           AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
           AND ap.cd_elo_agendamento = p_cd_elo_agendamento
           AND NVL(aw.qt_emergencial, 0) > 0
           
         GROUP BY aw.cd_elo_agendamento_item
        ;
    
        /* --- CARTEIRA --- */
        TYPE carteira_r IS RECORD
        (
            cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
            nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE
        );
        TYPE carteira_t IS TABLE OF carteira_r;
        t_carteira carteira_t;

        CURSOR c_carteira IS
        SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) qt_saldo,
               nu_ordem
          FROM vnd.elo_carteira ca
         WHERE NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           AND ca.cd_elo_agendamento = p_cd_elo_agendamento
           AND ca.cd_elo_agendamento_item = v_cd_elo_agendamento_item
           AND ca.ic_ativo = 'S'
           AND ca.ic_emergencial = 'S'
         ORDER BY ca.nu_ordem
        ;
    BEGIN
        OPEN    c_emergency;
        FETCH   c_emergency BULK COLLECT INTO t_emergency LIMIT v_limit;
        CLOSE   c_emergency;
        
        <<emergency_loop>>
        FOR i IN 1 .. t_emergency.COUNT
        LOOP
            v_cd_elo_agendamento_item   := t_emergency(i).cd_elo_agendamento_item;
            v_qt_emergencial_week       := t_emergency(i).qt_emergencial;
            
            OPEN    c_carteira;                               
            FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
            CLOSE   c_carteira;
            
            <<carteira_loop>>
            FOR j IN 1 .. t_carteira.COUNT
            LOOP
                v_cd_elo_carteira           := t_carteira(j).cd_elo_carteira;
                v_qt_emergencial_carteira   := 0;
                
                IF t_carteira(j).qt_saldo >= v_qt_emergencial_week THEN
                    v_qt_emergencial_carteira := v_qt_emergencial_week;
                ELSE
                    v_qt_emergencial_carteira := t_carteira(j).qt_saldo;
                END IF;
                
				BEGIN
                UPDATE vnd.elo_carteira ec
                   SET ec.qt_emergencial = NVL(ec.qt_emergencial, 0) + v_qt_emergencial_carteira
                 WHERE ec.cd_elo_carteira = v_cd_elo_carteira;
				 COMMIT;
				 EXCEPTION  
				WHEN OTHERS THEN 
				BEGIN
				RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.065 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
				END; 
				END;

                v_qt_emergencial_week := v_qt_emergencial_week - v_qt_emergencial_carteira;
                
                EXIT carteira_loop WHEN v_qt_emergencial_week <= 0;
                
            END LOOP carteira_loop;

			BEGIN
            UPDATE vnd.elo_carteira 
               SET ic_emergencial = 'N'
             WHERE cd_elo_agendamento = p_cd_elo_agendamento
               AND cd_elo_agendamento_item = v_cd_elo_agendamento_item
               AND NVL(qt_emergencial, 0) = 0
            ;
			COMMIT;
			EXCEPTION  
			WHEN OTHERS THEN 
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.066 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			ROLLBACK;
			END; 
			END;
            
        END LOOP emergency_loop;

    END pu_distribute_emergency;
    
    
    
    PROCEDURE pu_distribute_item (
        p_cd_elo_agendamento_item    IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    )
    IS
        v_count         NUMBER;
        v_limit         NUMBER := 100;
        v_qt_semana     vnd.elo_agendamento_week.qt_semana%TYPE;
        v_qt_agendada   vnd.elo_carteira.qt_agendada%TYPE;

        /* --- CARTEIRA --- */
        TYPE carteira_r IS RECORD
        (
            cd_elo_carteira                 vnd.elo_carteira.cd_elo_carteira%TYPE,
            cd_elo_agendamento_item         vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
            qt_saldo                        vnd.elo_carteira.qt_saldo%TYPE,
            nu_ordem                        vnd.elo_carteira.nu_ordem%TYPE
        );
        TYPE carteira_t IS TABLE OF carteira_r;
        t_carteira carteira_t;

        CURSOR c_carteira IS
        SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) qt_saldo,
               nu_ordem
          FROM vnd.elo_carteira ca
         WHERE NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           AND ca.cd_elo_agendamento_item = p_cd_elo_agendamento_item
           AND ca.ic_ativo = 'S'
         ORDER BY ca.nu_ordem
        ;
    BEGIN
        SELECT COUNT(aw.cd_elo_agendamento_week)
          INTO v_count
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        IF v_count <= 0 THEN
            RETURN;
        END IF;
        
        SELECT NVL(SUM(aw.qt_semana), 0)
          INTO v_qt_semana
          FROM vnd.elo_agendamento_week aw
         WHERE aw.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        IF v_qt_semana = 0 THEN
            RETURN;
        END IF;
    
        OPEN    c_carteira;                               
        FETCH   c_carteira BULK COLLECT INTO t_carteira LIMIT v_limit;
        CLOSE   c_carteira;
        
		BEGIN
        UPDATE vnd.elo_carteira ec
           SET ec.qt_agendada = 0,
               ec.qt_agendada_confirmada = 0
         WHERE ec.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		COMMIT;
		EXCEPTION  
		WHEN OTHERS THEN 
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.070 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		ROLLBACK;
		END; 
		END;
        
        <<carteira_loop>>
        FOR j IN 1 .. t_carteira.COUNT
        LOOP
            v_qt_agendada   := 0;
            
            IF t_carteira(j).qt_saldo >= v_qt_semana THEN
                v_qt_agendada := v_qt_semana;
            ELSE
                v_qt_agendada := t_carteira(j).qt_saldo;
            END IF;
            BEGIN
            UPDATE vnd.elo_carteira ec
               SET ec.qt_agendada = NVL(ec.qt_agendada, 0) + v_qt_agendada,
                   ec.qt_agendada_confirmada = NVL(ec.qt_agendada, 0) + v_qt_agendada,
                   ec.cd_tipo_agendamento = CASE WHEN ec.cd_tipo_agendamento IS NULL THEN vnd.gx_elo_common.fx_elo_status('TIPAG','INCLUSAO')
                                                 ELSE ec.cd_tipo_agendamento
                                            END
             WHERE ec.cd_elo_carteira = t_carteira(j).cd_elo_carteira
            ;
			COMMIT;
			EXCEPTION  
			WHEN OTHERS THEN 
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.071 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
			ROLLBACK;
			END; 
			END;			
			

            v_qt_semana := v_qt_semana - v_qt_agendada;
            
            EXIT carteira_loop WHEN v_qt_semana <= 0;
            
        END LOOP carteira_loop;
    END pu_distribute_item;
    


    PROCEDURE pu_agendamento_status (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    )
    IS
        v_count                             PLS_INTEGER := 0;
        V_TRAVA VARCHAR2(1):='N';
    BEGIN
        -- Update supervisors scheduling status.
        
        BEGIN 
        
        UPDATE vnd.elo_agendamento_supervisor ap
           SET ap.cd_elo_status = vnd.gx_elo_common.fx_elo_status('AGSUP', 'ASFIN')
         WHERE ap.cd_elo_agendamento_supervisor IN (
                    SELECT ap.cd_elo_agendamento_supervisor
                      FROM vnd.elo_agendamento an
                     INNER JOIN vnd.elo_agendamento_supervisor ap
                        ON an.cd_elo_agendamento = ap.cd_elo_agendamento
                      WHERE 
                            (
                                p_site_type = 'P' AND an.cd_polo = p_cd_site
                                OR
                                p_site_type = 'C' AND an.cd_centro_expedidor = p_cd_site
                                OR
                                p_site_type = 'M' AND an.cd_machine = p_cd_site
                            )
                        AND an.cd_week = p_cd_week
                        AND (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
                        AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
               )
        ;
        COMMIT;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        
            V_TRAVA:='S';
        WHEN OTHERS THEN 
            V_TRAVA:='S';
        
        END;
        
        BEGIN
        SELECT COUNT(cd_elo_agendamento_supervisor)
          INTO v_count
          FROM vnd.elo_agendamento_supervisor ap
         WHERE ap.cd_elo_agendamento = p_cd_elo_agendamento
           AND ap.cd_elo_status <> vnd.gx_elo_common.fx_elo_status('AGSUP','ASFIN')
           AND ap.ic_ativo = 'S'
        ;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        v_count:=0;
        WHEN OTHERS THEN 
        v_count:=NULL;
        END;

        IF v_count = 0 THEN
            -- All Supervisors schedulings finished. Update Scheduling status.
            BEGIN
            UPDATE vnd.elo_agendamento ag
               SET ag.cd_elo_status = vnd.gx_elo_common.fx_elo_status('AGEND','AGFIN')
             WHERE ag.cd_elo_agendamento = p_cd_elo_agendamento
			 AND ag.CD_ELO_STATUS < vnd.gx_elo_common.fx_elo_status('AGEND','AGFIN')
            ;
            COMMIT;
            EXCEPTION 
            WHEN OTHERS THEN
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.072 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
			END;
            END;
            
            
        END IF;

        --COMMIT;
    END pu_agendamento_status;


    PROCEDURE pu_carteira_day (
        p_cd_elo_carteira       vnd.elo_carteira_day.cd_elo_carteira%TYPE, 
        p_cd_grupo_embalagem    vnd.elo_carteira_day.cd_grupo_embalagem%TYPE, 
        p_nu_semana             vnd.elo_carteira_day.nu_semana%TYPE,
        p_nu_dia_semana         vnd.elo_carteira_day.nu_dia_semana%TYPE, 
        p_nu_quantidade         vnd.elo_carteira_day.nu_quantidade%TYPE
    )
    IS
    BEGIN
		BEGIN
        MERGE INTO vnd.elo_carteira_day USING DUAL ON (
                cd_elo_carteira     = p_cd_elo_carteira
            AND cd_grupo_embalagem  = p_cd_grupo_embalagem
            AND nu_semana           = p_nu_semana
            AND nu_dia_semana       = p_nu_dia_semana
        )

        WHEN MATCHED THEN
            UPDATE 
--               SET nu_quantidade       = nu_quantidade + p_nu_quantidade
               SET nu_quantidade       = p_nu_quantidade
             WHERE cd_elo_carteira     = p_cd_elo_carteira
               AND cd_grupo_embalagem  = p_cd_grupo_embalagem
               AND nu_semana           = p_nu_semana
               AND nu_dia_semana       = p_nu_dia_semana

        WHEN NOT MATCHED THEN
            INSERT (
                cd_elo_carteira_day,
                cd_elo_carteira, 
                cd_grupo_embalagem, 
                nu_semana,
                nu_dia_semana, 
                nu_quantidade
            ) VALUES (
                seq_elo_carteira_day.nextval,
                p_cd_elo_carteira, 
                p_cd_grupo_embalagem, 
                p_nu_semana,
                p_nu_dia_semana, 
                p_nu_quantidade
            );
			COMMIT;
            EXCEPTION 
            WHEN OTHERS THEN
			BEGIN
			RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.080 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
			END;
            END;			
			
    END;


    PROCEDURE pu_observacao_torre_fretes (
        p_cd_elo_agendamento_item       IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_ds_observacao_torre_fretes    IN vnd.elo_agendamento_item.ds_observacao_torre_fretes%TYPE,
        p_result                        OUT t_cursor
    )
    IS
        v_records_affected      NUMBER;
    BEGIN
		BEGIN
        UPDATE vnd.elo_agendamento_item
           SET ds_observacao_torre_fretes = p_ds_observacao_torre_fretes
         WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
		COMMIT;
		EXCEPTION 
		WHEN OTHERS THEN
		BEGIN
		RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_SCHEDULING.090 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
		ROLLBACK;
		END;
		END;	

        v_records_affected := SQL%ROWCOUNT;

        OPEN p_result FOR
        SELECT v_records_affected FROM dual;
    END pu_observacao_torre_fretes;



    PROCEDURE px_package_group_day (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        WITH agend AS (
                            SELECT ag.cd_elo_agendamento,
                                   ag.nu_semanas
                              FROM vnd.elo_agendamento ag
                             WHERE 
                                   (   CASE WHEN p_site_type = 'P' AND ag.CD_POLO = p_cd_site THEN 1
                                          WHEN   p_site_type = 'C' AND ag.CD_CENTRO_EXPEDIDOR = p_cd_site THEN 1
                                          WHEN   p_site_type = 'M' AND ag.CD_MACHINE = p_cd_site THEN 1
                                          ELSE 0
                                       END = 1 
                                   ) 
                               AND ag.cd_week = p_cd_week
                               AND ag.ic_ativo = 'S'
                      ),
        week_days AS  (
                        SELECT CEIL(ROWNUM / 7) weeknumber,
                               ROWNUM - ((CEIL(ROWNUM / 7) - 1) * 7) weekday
                          FROM dual 
                       CONNECT BY LEVEL <= (7 * (SELECT nu_semanas FROM agend))
                      ),
         agend_day AS (
                        SELECT ad.nu_dia_semana,
                               ad.cd_grupo_embalagem,
                               ad.nu_quantidade
                          FROM vnd.elo_agendamento_day ad
                         INNER JOIN vnd.elo_agendamento_week aw
                            ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week
                         INNER JOIN vnd.elo_agendamento_item ai
                            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                         INNER JOIN vnd.elo_agendamento_supervisor ap
                                on ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                         INNER JOIN vnd.elo_agendamento ag
                            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                         WHERE (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
                           AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
                           AND ag.cd_elo_agendamento = (SELECT cd_elo_agendamento FROM agend)
                      )
        SELECT wd.weeknumber WeekNumber,
               wd.weekday WeekDay,
               NVL(SUM(ad.nu_quantidade), 0) Quantity,
               ge.cd_grupo_embalagem Id

          FROM week_days wd
               
          LEFT OUTER JOIN vnd.grupo_embalagem ge
            ON ge.ic_ativo = 'S'
               
          LEFT OUTER JOIN agend_day ad
            ON ad.nu_dia_semana = wd.weekday
           AND ad.cd_grupo_embalagem = ge.cd_grupo_embalagem
           
         GROUP BY wd.weeknumber,
                  wd.weekday,
                  ge.cd_grupo_embalagem
               
         ORDER BY wd.weeknumber,
                  wd.weekday,
                  ge.cd_grupo_embalagem
        ;
    END px_package_group_day;



    PROCEDURE px_package_group_total_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        WITH agend AS (
                            SELECT ag.cd_elo_agendamento,
                                   ag.nu_semanas
                              FROM vnd.elo_agendamento_item ai
                             INNER JOIN vnd.elo_agendamento_supervisor ap
                                ON ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
                             INNER JOIN vnd.elo_agendamento ag
                                ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                             WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                      ),
        agend_day AS (
                        SELECT aw.nu_semana,
                               ad.nu_dia_semana,
                               ad.cd_grupo_embalagem,
                               ad.nu_quantidade
                          FROM vnd.elo_agendamento_day ad
                         INNER JOIN vnd.elo_agendamento_week aw
                            ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week
                         INNER JOIN vnd.elo_agendamento_item ai
                            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                         INNER JOIN vnd.elo_agendamento_supervisor ap
                                on ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                         INNER JOIN vnd.elo_agendamento ag
                            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                         WHERE (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
                           AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
                           AND ag.cd_elo_agendamento = (SELECT cd_elo_agendamento FROM agend)
                           AND aw.nu_semana = p_nu_semana
                           AND ad.nu_dia_semana = p_nu_dia_semana
                           AND ad.cd_grupo_embalagem = p_cd_grupo_embalagem
                     )
        SELECT ad.nu_semana WeekNumber,
               ad.nu_dia_semana WeekDay,
               NVL(SUM(ad.nu_quantidade), 0) Quantity,
               ad.cd_grupo_embalagem Id

          FROM agend_day ad
          
         GROUP BY ad.nu_semana,
                  ad.nu_dia_semana,
                  ad.cd_grupo_embalagem
        ;
    END px_package_group_total_fob;
    
    
    
    
    PROCEDURE px_package_group_total_cif (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        WITH agend AS (
                            select ag.cd_elo_agendamento,
                                   ag.nu_semanas
                              from vnd.elo_agendamento_item ai
                             inner join vnd.elo_agendamento_supervisor ap
                                on ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor
                             inner join vnd.elo_agendamento ag
                                on ag.cd_elo_agendamento = ap.cd_elo_agendamento
                             where ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
                      ),
        agend_day AS (
                        SELECT aw.nu_semana,
                               ad.nu_dia_semana,
                               ad.cd_grupo_embalagem,
                               ad.nu_quantidade
                          FROM vnd.elo_agendamento_day ad
                         INNER JOIN vnd.elo_agendamento_week aw
                            ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week
                         INNER JOIN vnd.elo_agendamento_item ai
                            ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                         INNER JOIN vnd.elo_agendamento_supervisor ap
                                on ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                         INNER JOIN vnd.elo_agendamento ag
                            ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                         WHERE (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
                           AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
                           AND ag.cd_elo_agendamento = (SELECT cd_elo_agendamento FROM agend)
                           AND aw.nu_semana = p_nu_semana
                           AND ad.cd_grupo_embalagem = p_cd_grupo_embalagem
                     )
                     
        SELECT ad.nu_semana WeekNumber,
               ad.nu_dia_semana WeekDay,
               NVL(SUM(ad.nu_quantidade), 0) Quantity,
               ad.cd_grupo_embalagem Id

          FROM agend_day ad
          
         GROUP BY ad.nu_semana,
                  ad.nu_dia_semana,
                  ad.cd_grupo_embalagem
                  
         ORDER BY ad.nu_semana,
                  ad.nu_dia_semana,
                  ad.cd_grupo_embalagem
        ;
    END px_package_group_total_cif;
    
    
    
    PROCEDURE px_daily_quota (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                OUT t_cursor
    )
    IS
        v_cd_elo_agendamento vnd.elo_agendamento.cd_elo_agendamento%TYPE;
    BEGIN
        SELECT cd_elo_agendamento
          INTO v_cd_elo_agendamento
          FROM vnd.elo_agendamento ag
         WHERE (
                    p_site_type = 'P' AND ag.cd_polo = p_cd_site
                 OR p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                 OR p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
           AND ag.ic_ativo = 'S'
           AND ag.cd_week = p_cd_week
        ;
        
        OPEN p_result FOR
        WITH week_days AS (
                              SELECT CEIL(ROWNUM / 7) weeknumber,
                                     ROWNUM - ((CEIL(ROWNUM / 7) - 1) * 7) weekday 
                                FROM dual 
                             CONNECT BY LEVEL <= (7 * (SELECT nu_semanas 
                                                         FROM vnd.elo_agendamento 
                                                        WHERE cd_elo_agendamento = v_cd_elo_agendamento)
                                                 )
                          ),
                 agend AS (
                                 SELECT CASE WHEN NVL(ap.qt_cota_ajustada, 0) > 0 THEN
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
                                        END qt_cota_with_overbooking,
                                        ag.dt_week_start,
                                        ag.cd_elo_agendamento
                                   FROM vnd.elo_agendamento_supervisor ap
                                  INNER JOIN vnd.elo_agendamento ag
                                     ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                                  WHERE ag.cd_elo_agendamento = v_cd_elo_agendamento
                                    AND ap.cd_sales_group = p_cd_sales_group
                          ),
               centroi AS (
                              SELECT ac.dt_week_start,
                                     ci.nu_dia_semana,
                                     ci.nu_capacidade
                                FROM vnd.elo_agendamento_centro_item ci
                               INNER JOIN vnd.elo_agendamento_centro ac
                                  ON ci.cd_agendamento_centro = ac.cd_agendamento_centro
                               INNER JOIN agend ag
                                  ON ac.dt_week_start = ag.dt_week_start
                               WHERE (
                                        p_site_type = 'P' AND ac.cd_centro_expedidor IN (
                                              SELECT cd_centro_expedidor
                                                FROM vnd.elo_agendamento_polo_centro pc
                                               WHERE pc.cd_polo = p_cd_site
                                                 AND pc.cd_elo_agendamento = v_cd_elo_agendamento
                                        )
                                        OR
                                        p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                                        OR
                                        p_site_type = 'M' AND ac.cd_centro_expedidor IN (
                                              SELECT cd_centro_expedidor
                                                FROM vnd.elo_agendamento_centro_machine cm
                                               WHERE cm.cd_machine = p_cd_site
                                                 AND cm.cd_elo_agendamento = v_cd_elo_agendamento
                                        )
                                     )
                          ),
                   sup AS (
                               SELECT NVL(SUM(ad.nu_quantidade), 0) nu_quantidade,
                                      ap.cd_elo_agendamento,
                                      ad.nu_dia_semana,
                                      aw.nu_semana
                                 FROM vnd.elo_agendamento_day ad
                                INNER JOIN vnd.elo_agendamento_week aw
                                   ON aw.cd_elo_agendamento_week = ad.cd_elo_agendamento_week
                                INNER JOIN vnd.elo_agendamento_item ai
                                   ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                                INNER JOIN vnd.elo_agendamento_supervisor ap
                                   ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                                WHERE ap.cd_elo_agendamento = v_cd_elo_agendamento
                                  AND ap.cd_sales_group = p_cd_sales_group
                                GROUP BY ap.cd_elo_agendamento,
                                         ad.nu_dia_semana,
                                         aw.nu_semana
                                ORDER BY ad.nu_dia_semana
                          )
                   
        SELECT wd.weeknumber WeekNumber,
               wd.weekday WeekDay,
               --NVL(ci.nu_capacidade, 0) PlantCapacity,
               --GREATEST(
                   NVL(
                         ROUND(
                                  NVL((ratio_to_report(ci.nu_capacidade) over ()), 0) * ag.qt_cota_with_overbooking
                           , 5)
                   , 0) - NVL(ap.nu_quantidade, 0) Quota
               --, 0) Quota
                
         FROM week_days wd

         LEFT OUTER JOIN centroi ci
           ON ci.nu_dia_semana = wd.weekday
           
         LEFT OUTER JOIN agend ag
           ON ag.dt_week_start = ci.dt_week_start
   
         LEFT OUTER JOIN sup ap
           ON ap.cd_elo_agendamento = ag.cd_elo_agendamento
          AND ap.nu_dia_semana = wd.weekday
          AND ap.nu_semana = wd.weeknumber
   
        ORDER BY wd.weekday
        ;
    END px_daily_quota;
    
    
    
    PROCEDURE px_check_emergency_qty (
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_result                    OUT t_cursor
    )
    IS
        v_count             NUMBER;
        v_cd_sales_group    vnd.elo_agendamento_supervisor.cd_sales_group%TYPE;
    BEGIN
        IF p_cd_sales_group IS NULL THEN
            SELECT COUNT(ap.cd_elo_agendamento_supervisor)
              INTO v_count
              FROM elo_agendamento_item ai
             INNER JOIN elo_agendamento_supervisor ap
                ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
             WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
            ;
            
            IF v_count > 0 THEN
                SELECT ap.cd_sales_group
                  INTO v_cd_sales_group
                  FROM elo_agendamento_item ai
                 INNER JOIN elo_agendamento_supervisor ap
                    ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                 WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
                ;
            ELSE
                RETURN;
            END IF;
        ELSE
            v_cd_sales_group := p_cd_sales_group;
        END IF;
    
        OPEN p_result FOR
        WITH agend AS (
                        SELECT ag.cd_elo_agendamento,
                               ag.qt_limite_emergencial EmergencyLimit,
                               NVL(ag.qt_overbooking_supervisores, 0) Overbooking
                          FROM vnd.elo_agendamento ag
                         WHERE
                            (   CASE WHEN p_site_type = 'P' AND ag.cd_polo = p_cd_site THEN 1
                                   WHEN   p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site THEN 1
                                   WHEN   p_site_type = 'M' AND ag.cd_machine = p_cd_site THEN 1
                                   ELSE 0
                                END = 1 
                            ) 
                        AND ag.cd_week = p_cd_week
                      ),
             suprv AS (
                            SELECT ap.cd_elo_agendamento_supervisor,
                                   ap.cd_elo_agendamento,
                                   NVL(ap.qt_cota, 0) Cota,
                                   NVL(ap.qt_cota_ajustada, 0) CotaAjustada,
                                   CASE WHEN NVL(ap.qt_cota_ajustada, 0) > 0 THEN
                                       CASE WHEN ag.Overbooking > 0 THEN
                                           ap.qt_cota_ajustada + (ap.qt_cota_ajustada * (ag.Overbooking / 100))
                                       ELSE
                                           ap.qt_cota_ajustada
                                       END
                                    ELSE 
                                       CASE WHEN ag.Overbooking > 0 THEN
                                           NVL(ap.qt_cota, 0) + (NVL(ap.qt_cota, 0) * (ag.Overbooking / 100))
                                       ELSE
                                           NVL(ap.qt_cota, 0)
                                       END
                                   END CotaWithOverbooking
                              FROM vnd.elo_agendamento_supervisor ap
                             INNER JOIN agend ag
                                ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                             WHERE ap.cd_sales_group = v_cd_sales_group
                      )
                      
             SELECT NVL(SUM(aw.qt_emergencial), 0) EmergencyQuantity,
                    ag.EmergencyLimit,
                    ap.Cota,
                    ap.CotaAjustada,
                    ap.CotaWithOverbooking
             
               FROM agend ag
               
               LEFT OUTER JOIN suprv ap
                 ON ag.cd_elo_agendamento = ap.cd_elo_agendamento
                 
               LEFT OUTER JOIN vnd.elo_agendamento_item ai
                 ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor
                AND ai.ic_ativo = 'S'
                
               LEFT OUTER JOIN vnd.elo_agendamento_week aw
                 ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item
                AND aw.cd_elo_agendamento_item <> p_cd_elo_agendamento_item
                AND aw.nu_semana = p_nu_semana
              
              GROUP BY ag.EmergencyLimit,
                       ap.Cota,
                       ap.CotaAjustada,
                       ap.CotaWithOverbooking
             ;
    END px_check_emergency_qty;
    
    
 
    PROCEDURE px_check_plant_capacity (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR,
        p_minimun_day_for_replan    IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_result                    OUT t_cursor,
        p_capacity                  OUT t_cursor
    )
    IS
        v_cd_status_replan          vnd.elo_agendamento_item.cd_status_replan%TYPE;
        v_minimun_day_for_replan    vnd.elo_agendamento_day.nu_dia_semana%TYPE := 0;
    BEGIN
        SELECT NVL(cd_status_replan, 0)
          INTO v_cd_status_replan
          FROM elo_agendamento_item ai
         WHERE ai.cd_elo_agendamento_item = p_cd_elo_agendamento_item
        ;
        
        IF v_cd_status_replan > 0 THEN
            v_minimun_day_for_replan := p_minimun_day_for_replan;
        END IF;
        
        OPEN p_result FOR
        SELECT NVL(COUNT(ci.cd_agendamento_centro_item), 0) Quantity,
               ag.dt_week_start WeekStartDate,
               p_site_type SiteType,
               p_cd_site SiteId
          FROM vnd.elo_agendamento ag
         LEFT OUTER JOIN vnd.elo_agendamento_centro ac
            ON ag.dt_week_start = ac.dt_week_start
           AND (
                       p_site_type = 'P' AND ac.cd_polo = p_cd_site
                    OR p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                    OR p_site_type = 'M' AND ac.cd_machine = p_cd_site
               )
           AND ac.ic_ativo = 'S'
         LEFT OUTER JOIN vnd.elo_agendamento_centro_item ci
            ON ci.cd_agendamento_centro = ac.cd_agendamento_centro
           AND ci.ic_ativo = 'S'
         WHERE (
                       p_site_type = 'P' AND ag.cd_polo = p_cd_site
                    OR p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                    OR p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
           AND ag.cd_week = p_cd_week
         GROUP BY ag.dt_week_start
        ;
        
        OPEN p_capacity FOR
        SELECT NVL(SUM(ci.nu_capacidade),0) Capacity

          FROM vnd.elo_agendamento_centro ac

         INNER JOIN vnd.elo_agendamento_centro_item ci
            ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

         INNER JOIN vnd.elo_agendamento ag
            ON ag.dt_week_start = ac.dt_week_start

         WHERE 
               (
                       p_site_type = 'P' AND ac.cd_polo = p_cd_site
                    OR p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                    OR p_site_type = 'M' AND ac.cd_machine = p_cd_site
               )
           AND (
                       p_site_type = 'P' AND ag.cd_polo = p_cd_site
                    OR p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                    OR p_site_type = 'M' AND ag.cd_machine = p_cd_site
               )
           AND ag.cd_week = p_cd_week
           AND ci.nu_dia_semana >= v_minimun_day_for_replan
           AND ac.ic_ativo = 'S'
           AND ci.ic_ativo = 'S'
        ;
    END px_check_plant_capacity;
    


    /*
        Used in VND.GX_ELO_FACTORY.PU_VERIFICA_AGENDAMENTO_CIF.
    */
    PROCEDURE pi_agendamento_week_factory (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_semana                 IN vnd.elo_agendamento_week.qt_semana%TYPE
    )
    IS
        v_cd_tipo_agendamento   vnd.elo_carteira.cd_tipo_agendamento%TYPE;
    BEGIN
       
        IF NVL(p_qt_semana, 0) = 0 THEN
            DELETE FROM vnd.elo_agendamento_day
             WHERE cd_elo_agendamento_week in (
                        SELECT cd_elo_agendamento_week
                          FROM vnd.elo_agendamento_week
                         WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
                           AND nu_semana = p_nu_semana
                   )
            ;
            DELETE FROM vnd.elo_agendamento_grouping
             WHERE cd_elo_agendamento_week in (
                        SELECT cd_elo_agendamento_week
                          FROM vnd.elo_agendamento_week
                         WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
                           AND nu_semana = p_nu_semana
                   )
            ;
            DELETE FROM vnd.elo_agendamento_week
             WHERE cd_elo_agendamento_item = p_cd_elo_agendamento_item
               AND nu_semana = p_nu_semana
            ;
        ELSE
            MERGE INTO vnd.elo_agendamento_week aw USING DUAL ON (
                    cd_elo_agendamento_item = p_cd_elo_agendamento_item
                AND nu_semana = p_nu_semana
            )

            WHEN MATCHED THEN
                UPDATE 
                   SET qt_semana = p_qt_semana
                 WHERE cd_elo_agendamento_item  = p_cd_elo_agendamento_item
                   AND nu_semana                = p_nu_semana

            WHEN NOT MATCHED THEN
                INSERT (
                   cd_elo_agendamento_week, 
                   cd_elo_agendamento_item, 
                   nu_semana, 
                   qt_cota, 
                   qt_semana, 
                   qt_emergencial
                ) VALUES (
                   seq_elo_agendamento_week.nextval,
                   p_cd_elo_agendamento_item,
                   p_nu_semana,
                   NULL,
                   p_qt_semana,
                   NULL
                );

        END IF;
    END pi_agendamento_week_factory;



    /*
        Used in VND.GX_ELO_FACTORY.PU_VERIFICA_AGENDAMENTO_CIF.
    */
    PROCEDURE pi_agendamento_day_factory (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_week.qt_semana%TYPE,
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR
    )
    IS
        CURSOR c_agendamento_centro_item IS
        SELECT nu_dia_semana,
               SUM(nu_quantidade) nu_quantidade
          FROM (
                    SELECT ci.nu_dia_semana,
                           NVL((ratio_to_report(ci.nu_capacidade) over ()), 0) * p_nu_quantidade nu_quantidade

                      FROM vnd.elo_agendamento_centro ac

                     INNER JOIN vnd.elo_agendamento_centro_item ci
                        ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

                     INNER JOIN vnd.elo_agendamento ag
                        ON ag.dt_week_start = ac.dt_week_start

                     WHERE 
                           (
                                   p_site_type = 'P' AND ac.cd_polo = p_cd_site
                                OR p_site_type = 'C' AND ac.cd_centro_expedidor = p_cd_site
                                OR p_site_type = 'M' AND ac.cd_machine = p_cd_site
                           )
                       AND (
                                   p_site_type = 'P' AND ag.cd_polo = p_cd_site
                                OR p_site_type = 'C' AND ag.cd_centro_expedidor = p_cd_site
                                OR p_site_type = 'M' AND ag.cd_machine = p_cd_site
                           )
                       AND ag.cd_week = p_cd_week
                       AND ac.ic_ativo = 'S'
                       AND ci.ic_ativo = 'S'
               )
      GROUP BY nu_dia_semana
      ORDER BY nu_dia_semana
        ;
    BEGIN
        FOR agendamento_centro_item IN c_agendamento_centro_item LOOP
            pi_agendamento_day (
                p_cd_elo_agendamento_item,
                p_nu_semana,
                agendamento_centro_item.nu_dia_semana,
                p_cd_grupo_embalagem,
                agendamento_centro_item.nu_quantidade
            );
        END LOOP;

        IF c_agendamento_centro_item%ISOPEN THEN
            CLOSE c_agendamento_centro_item;
        END IF;
    END pi_agendamento_day_factory;


END GX_ELO_SCHEDULING_FIX;
/