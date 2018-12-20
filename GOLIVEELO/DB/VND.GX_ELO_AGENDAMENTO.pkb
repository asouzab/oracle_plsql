CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_AGENDAMENTO" IS


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


    FUNCTION FX_PRIORITY_OPTION (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_SG_PRIORITY_OPTION    IN VND.ELO_PRIORITY_OPTION.SG_PRIORITY_OPTION%TYPE
    ) RETURN VND.ELO_AGENDAMENTO_PRIO_PANEL.CD_ELO_PRIORITY_OPTION%TYPE
    IS
        V_RESULT VND.ELO_AGENDAMENTO_PRIO_PANEL.CD_ELO_PRIORITY_OPTION%TYPE;
    BEGIN

        SELECT AP.CD_ELO_PRIORITY_OPTION
          INTO V_RESULT
          FROM VND.ELO_AGENDAMENTO_PRIO_PANEL AP
         INNER JOIN VND.ELO_PRIORITY_OPTION PO
            ON PO.CD_ELO_PRIORITY_OPTION = AP.CD_ELO_PRIORITY_OPTION
         WHERE PO.SG_PRIORITY_OPTION = P_SG_PRIORITY_OPTION
           AND AP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
        ;

        RETURN V_RESULT;

    END FX_PRIORITY_OPTION;



    FUNCTION FX_IS_DOCTYPE_COOPERATIVE (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_COOPERATIVE%TYPE
    IS
        V_RESULT VND.TIPO_ORDEM.IC_COOPERATIVE%TYPE;
    BEGIN

        SELECT DISTINCT 
               CASE 
                    WHEN IC_COOPERATIVE IS NULL THEN 'N' 
                    ELSE IC_COOPERATIVE 
               END
          INTO V_RESULT
          FROM VND.TIPO_ORDEM 
         WHERE CD_TIPO_ORDEM = P_CD_TIPO_ORDEM
        ;

        RETURN V_RESULT;

    END FX_IS_DOCTYPE_COOPERATIVE;



    FUNCTION FX_IS_DOCTYPE_SPLIT (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_SPLIT%TYPE
    IS
        V_RESULT VND.TIPO_ORDEM.IC_SPLIT%TYPE;
    BEGIN

        SELECT DISTINCT 
               CASE 
                    WHEN IC_SPLIT IS NULL THEN 'N' 
                    ELSE IC_SPLIT 
               END
          INTO V_RESULT
          FROM VND.TIPO_ORDEM 
         WHERE CD_TIPO_ORDEM = P_CD_TIPO_ORDEM
        ;

        RETURN V_RESULT;

    END FX_IS_DOCTYPE_SPLIT;



    FUNCTION FX_IS_DOCTYPE_FA (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_FA%TYPE
    IS
        V_RESULT VND.TIPO_ORDEM.IC_FA%TYPE;
    BEGIN

        SELECT DISTINCT 
               CASE 
                    WHEN IC_FA IS NULL THEN 'N' 
                    ELSE IC_FA 
               END
          INTO V_RESULT
          FROM VND.TIPO_ORDEM 
         WHERE CD_TIPO_ORDEM = P_CD_TIPO_ORDEM
        ;

        RETURN V_RESULT;

    END FX_IS_DOCTYPE_FA;


    FUNCTION FX_IS_DOCTYPE_EXPORT (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_EXPORT%TYPE
    IS
        V_RESULT VND.TIPO_ORDEM.IC_EXPORT%TYPE;
    BEGIN

        SELECT DISTINCT 
               CASE 
                    WHEN IC_EXPORT IS NULL THEN 'N' 
                    ELSE IC_EXPORT 
               END
          INTO V_RESULT
          FROM VND.TIPO_ORDEM 
         WHERE CD_TIPO_ORDEM = P_CD_TIPO_ORDEM
        ;

        RETURN V_RESULT;

    END FX_IS_DOCTYPE_EXPORT;


    FUNCTION FX_PREVIOUS_SCHEDULLING (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE
    ) RETURN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE
    IS
        V_RESULT VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE;
    BEGIN
        SELECT CD_ELO_AGENDAMENTO
          INTO V_RESULT
          FROM (
                    SELECT * 
                      FROM VND.ELO_AGENDAMENTO AG
                     WHERE AG.DT_WEEK_START < (
                                                SELECT DT_WEEK_START 
                                                  FROM VND.ELO_AGENDAMENTO 
                                                 WHERE CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                              )
                           AND (P_CD_POLO IS NULL OR AG.CD_POLO = P_CD_POLO)
                           AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
                           AND (P_CD_MACHINE IS NULL OR AG.CD_MACHINE = P_CD_MACHINE)
                           AND AG.IC_ATIVO = 'S'
                     ORDER BY AG.DT_WEEK_START DESC
               )
         WHERE ROWNUM = 1
        ;
        RETURN V_RESULT;
    END FX_PREVIOUS_SCHEDULLING;



    FUNCTION FX_STATUS_BACKLOG_CIF (
        P_NU_CARTEIRA_VERSION   IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_NU_ORDEM_VENDA        IN VND.ELO_CARTEIRA_SAP.NU_ORDEM_VENDA%TYPE,
        P_CD_PRODUTO_SAP        IN VND.ELO_CARTEIRA_SAP.CD_PRODUTO_SAP%TYPE
    ) RETURN VND.ELO_STATUS.CD_ELO_STATUS%TYPE
    IS
        V_RESULT VND.ELO_STATUS.CD_ELO_STATUS%TYPE;
    BEGIN

        SELECT CASE
                    WHEN COUNT(CD_ELO_CARTEIRA_SAP) > 0 THEN GX_ELO_COMMON.FX_ELO_STATUS('BLCIF','FOUND')
                    ELSE GX_ELO_COMMON.FX_ELO_STATUS('BLCIF','NOFND')
               END CD_STATUS_BACKLOG_CIF
          INTO V_RESULT
          FROM VND.VW_ELO_CARTEIRA_SAP CS
         WHERE CS.NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
           AND CS.NU_ORDEM_VENDA  = P_NU_ORDEM_VENDA
           AND CS.CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
        ;

        RETURN V_RESULT;

    END FX_STATUS_BACKLOG_CIF;



    FUNCTION fx_plant_forecast (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_dt_week_start         IN vnd.elo_agendamento.dt_week_start%TYPE,
        p_site_id               IN CHAR,
        p_site_type             IN CHAR
    ) RETURN vnd.elo_agendamento_supervisor.qt_forecast%TYPE
    IS
        v_result            vnd.elo_agendamento_supervisor.qt_forecast%TYPE;
    BEGIN
        SELECT NVL(SUM(qt_valor), 0) qt_forecast
        
          INTO v_result

          FROM vnd.detalhe_planejamento dp

         INNER JOIN vnd.planejamento pl
            ON pl.cd_planejamento = dp.cd_planejamento

         WHERE 
               (
                  p_site_type = 'P' AND pl.cd_centro_expedidor IN (
                        SELECT cd_centro_expedidor
                          FROM vnd.elo_agendamento_polo_centro pc
                         WHERE pc.cd_polo = p_site_id
                           AND pc.cd_elo_agendamento = p_cd_elo_agendamento
                  )
                  OR
                  p_site_type = 'C' AND pl.cd_centro_expedidor = p_site_id
                  OR
                  p_site_type = 'M' AND pl.cd_centro_expedidor IN (
                        SELECT cd_centro_expedidor
                          FROM vnd.elo_agendamento_centro_machine cm
                         WHERE cm.cd_machine = p_site_id
                           AND cm.cd_elo_agendamento = p_cd_elo_agendamento
                  )
               )
           AND pl.cd_periodo = (
                                    SELECT cd_periodo
                                      FROM (
                                                SELECT pe.cd_periodo
                                                  FROM vnd.periodo pe
                                                 INNER JOIN vnd.tipo_planejamento tp
                                                    ON tp.cd_tipo_planejamento = pe.cd_tipo_planejamento
                                                 WHERE UPPER(tp.sg_tipo_planejamento) = 'MENSAL'
                                                   AND 
                                                       (
                                                            pe.dt_periodo_de <= TRUNC(p_dt_week_start, 'MM')
                                                            AND
                                                            pe.dt_periodo_ate >= TRUNC(p_dt_week_start, 'MM')
                                                       )
                                                 ORDER BY pe.dt_referencia DESC
                                           )
                                     WHERE ROWNUM = 1
                               )
           AND dp.dt_planejamento = TRUNC(p_dt_week_start, 'MM')
           AND dp.ic_ativo = 'S'
           AND pl.cd_usuario IN (
                    SELECT cd_usuario
                      FROM ctf.usuario us
                     INNER JOIN (
                                    SELECT DISTINCT cd_sales_group
                                      FROM vnd.elo_carteira
                                     WHERE cd_elo_agendamento = p_cd_elo_agendamento
                                       AND ic_ativo = 'S'
                                ) ca
                        ON ca.cd_sales_group = us.cd_usuario_original
               )
        ;

        RETURN v_result;
    END fx_plant_forecast;



    FUNCTION fx_supervisor_forecast  (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_dt_week_start         IN vnd.elo_agendamento.dt_week_start%TYPE,
        p_site_id               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    ) RETURN vnd.elo_agendamento_supervisor.qt_forecast%TYPE
    IS
        v_result    vnd.elo_agendamento_supervisor.qt_forecast%TYPE;
    BEGIN
        SELECT ROUND(NVL(SUM(qt_valor), 0)) qt_forecast
        
          INTO v_result
          
          FROM vnd.detalhe_planejamento dp
          
         INNER JOIN vnd.planejamento pl
            ON pl.cd_planejamento = dp.cd_planejamento
            
         INNER JOIN ctf.usuario us
            ON us.cd_usuario = pl.cd_usuario

         WHERE 
               (
                  p_site_type = 'P' AND pl.cd_centro_expedidor IN (
                        SELECT cd_centro_expedidor
                          FROM vnd.elo_agendamento_polo_centro pc
                         WHERE pc.cd_polo = p_site_id
                           AND pc.cd_elo_agendamento = p_cd_elo_agendamento
                  )
                  OR
                  p_site_type = 'C' AND pl.cd_centro_expedidor = p_site_id
                  OR
                  p_site_type = 'M' AND pl.cd_centro_expedidor IN (
                        SELECT cd_centro_expedidor
                          FROM vnd.elo_agendamento_centro_machine cm
                         WHERE cm.cd_machine = p_site_id
                           AND cm.cd_elo_agendamento = p_cd_elo_agendamento
                  )
               )
           AND pl.cd_periodo = (
                                    SELECT cd_periodo
                                      FROM (
                                                SELECT pe.cd_periodo
                                                  FROM vnd.periodo pe
                                                 INNER JOIN vnd.tipo_planejamento tp
                                                    ON tp.cd_tipo_planejamento = pe.cd_tipo_planejamento
                                                 WHERE UPPER(tp.sg_tipo_planejamento) = 'MENSAL'
                                                   AND 
                                                       (
                                                            pe.dt_periodo_de <= TRUNC(p_dt_week_start, 'MM')
                                                            AND
                                                            pe.dt_periodo_ate >= TRUNC(p_dt_week_start, 'MM')
                                                       )
                                                 ORDER BY pe.dt_referencia DESC
                                           )
                                     WHERE ROWNUM = 1
                               )
           AND us.cd_usuario_original = p_cd_sales_group
           AND dp.dt_planejamento = TRUNC(p_dt_week_start, 'MM')
           AND dp.ic_ativo = 'S'
        ;

        RETURN v_result;
    END fx_supervisor_forecast;



    FUNCTION fx_supervisor_quota  (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    ) RETURN vnd.elo_agendamento_supervisor.qt_cota%TYPE
    IS
        v_dt_week_start                 vnd.elo_agendamento.dt_week_start%TYPE;
        v_site_id                       CHAR(4);
        v_site_type                     CHAR(4);
        v_nu_semanas                    vnd.elo_agendamento.nu_semanas%TYPE;
        v_days_at_month                 NUMBER;
        v_days_at_next_month            NUMBER;

        v_qt_sup_forecast_this_month    vnd.elo_agendamento_supervisor.qt_forecast%TYPE;
        v_qt_sup_forecast_next_month    vnd.elo_agendamento_supervisor.qt_forecast%TYPE;
        v_this_month_sup_daily_quota    NUMBER;
        v_next_month_sup_daily_quota    NUMBER;

        v_qt_plant_forecast_this_month  vnd.elo_agendamento_supervisor.qt_forecast%TYPE;
        v_qt_plant_forecast_next_month  vnd.elo_agendamento_supervisor.qt_forecast%TYPE;
        v_this_month_plant_daily_quota  NUMBER;
        v_next_month_plant_daily_quota  NUMBER;

        v_sup_agendamento_quota         vnd.elo_agendamento_supervisor.qt_cota%TYPE := 0;
        v_plant_agendamento_quota       vnd.elo_agendamento_supervisor.qt_cota%TYPE := 0;

        v_total_plant_capacity          vnd.elo_agendamento_centro_item.nu_capacidade%TYPE;

        v_result                        vnd.elo_agendamento_supervisor.qt_cota%TYPE := 0;
    BEGIN
        SELECT ag.dt_week_start,
               ag.nu_semanas,
               CASE 
                   WHEN ag.cd_polo IS NOT NULL THEN ag.cd_polo
                   WHEN ag.cd_centro_expedidor IS NOT NULL THEN ag.cd_centro_expedidor
                   WHEN ag.cd_machine IS NOT NULL THEN ag.cd_machine
               END SiteId,
               CASE 
                    WHEN ag.cd_polo IS NOT NULL THEN 'P'
                    WHEN ag.cd_centro_expedidor IS NOT NULL THEN 'C'
                    WHEN ag.cd_machine IS NOT NULL THEN 'M'
               END SiteType
          INTO v_dt_week_start, v_nu_semanas, v_site_id, v_site_type
          FROM vnd.elo_agendamento ag
         WHERE ag.cd_elo_agendamento = p_cd_elo_agendamento
        ;    

        v_qt_sup_forecast_this_month    := gx_elo_agendamento.fx_supervisor_forecast(p_cd_elo_agendamento, v_dt_week_start, v_site_id, v_site_type, p_cd_sales_group);
        v_qt_sup_forecast_next_month    := gx_elo_agendamento.fx_supervisor_forecast(p_cd_elo_agendamento, ADD_MONTHS(v_dt_week_start, 1), v_site_id, v_site_type, p_cd_sales_group);
        v_qt_plant_forecast_this_month  := gx_elo_agendamento.fx_plant_forecast(p_cd_elo_agendamento, v_dt_week_start, v_site_id, v_site_type);
        v_qt_plant_forecast_next_month  := gx_elo_agendamento.fx_plant_forecast(p_cd_elo_agendamento, ADD_MONTHS(v_dt_week_start, 1), v_site_id, v_site_type);

        SELECT 
               -- This month supervisor daily quota
               (v_qt_sup_forecast_this_month / EXTRACT(DAY FROM LAST_DAY(ag.dt_week_start))) AS ThisMonthDailyQuota,
               -- Next month supervisor daily quota
               (v_qt_sup_forecast_next_month / EXTRACT(DAY FROM LAST_DAY(ADD_MONTHS(ag.dt_week_start, 1)))) AS NextMonthDailyQuota,

               -- This month plant daily quota
               (v_qt_plant_forecast_this_month / EXTRACT(DAY FROM LAST_DAY(ag.dt_week_start))) AS ThisMonthDailyQuota,
               -- Next month plant daily quota
               (v_qt_plant_forecast_next_month / EXTRACT(DAY FROM LAST_DAY(ADD_MONTHS(ag.dt_week_start, 1)))) AS NextMonthDailyQuota,

               -- Check if ELO_AGENDAMENTO last day is in another month and calculate days at month
               CASE WHEN (TRUNC(ag.dt_week_start + (ag.nu_semanas * 7), 'MM') - TRUNC(ag.dt_week_start, 'MM')) = 0 THEN
                        ag.nu_semanas * 7
                    ELSE
                        LAST_DAY(ag.dt_week_start) - ag.dt_week_start + 1
               END DaysAtMonth,
               CASE WHEN (TRUNC(ag.dt_week_start + (ag.nu_semanas * 7), 'MM') - TRUNC(ag.dt_week_start, 'MM')) = 0 THEN
                        0
                    ELSE
                        (ag.nu_semanas * 7) - (LAST_DAY(ag.dt_week_start) - ag.dt_week_start + 1)
               END DaysAtNextMonth
          INTO v_this_month_sup_daily_quota, 
               v_next_month_sup_daily_quota, 
               v_this_month_plant_daily_quota, 
               v_next_month_plant_daily_quota, 
               v_days_at_month, 
               v_days_at_next_month
          FROM vnd.elo_agendamento ag
         WHERE ag.cd_elo_agendamento = p_cd_elo_agendamento
        ;

        -- Get Agendamento´s quota, using formula:
        -- (Month´s Daily Quota* Days at month)+(next Month´s Daily Quota* Days at next month)
        v_sup_agendamento_quota     := (v_this_month_sup_daily_quota * v_days_at_month) + (v_next_month_sup_daily_quota * v_days_at_next_month);
        v_plant_agendamento_quota   := (v_this_month_plant_daily_quota * v_days_at_month) + (v_next_month_plant_daily_quota * v_days_at_next_month);

        -- Get Agendamento´s proportional quota according to Polo/Plant Capacity at Parameters using rule of three as below:
        -- (Agendamento´s quota*Total Polo/Plant capacity) / Total Agendamento´s quota
        SELECT SUM(ci.nu_capacidade) * v_nu_semanas
          INTO v_total_plant_capacity
          FROM vnd.elo_agendamento_centro ac

         INNER JOIN vnd.elo_agendamento_centro_item ci
            ON ci.cd_agendamento_centro = ac.cd_agendamento_centro

         WHERE ac.dt_week_start = v_dt_week_start
           AND 
               (
                  v_site_type = 'P' AND ac.cd_centro_expedidor IN (
                        SELECT cd_centro_expedidor
                          FROM vnd.elo_agendamento_polo_centro pc
                         WHERE pc.cd_polo = v_site_id
                           AND pc.cd_elo_agendamento = p_cd_elo_agendamento
                  )
                  OR
                  v_site_type = 'C' AND ac.cd_centro_expedidor = v_site_id
                  OR
                  v_site_type = 'M' AND ac.cd_centro_expedidor IN (
                        SELECT cd_centro_expedidor
                          FROM vnd.elo_agendamento_centro_machine cm
                         WHERE cm.cd_machine = v_site_id
                           AND cm.cd_elo_agendamento = p_cd_elo_agendamento
                  )
               )
           AND ci.ic_ativo = 'S'
           AND ac.ic_ativo = 'S'
        ;   

        IF v_plant_agendamento_quota > 0 THEN
            v_result := ROUND((v_sup_agendamento_quota * v_total_plant_capacity) / v_plant_agendamento_quota);
        END IF;

        RETURN v_result;
    END fx_supervisor_quota;



    FUNCTION fx_latest_sales_office (
        p_cd_elo_agendamento    IN vnd.elo_carteira.cd_elo_agendamento%TYPE,
        p_cd_sales_group        IN vnd.elo_carteira.cd_sales_group%TYPE
    ) RETURN vnd.elo_carteira.cd_sales_office%TYPE
    IS
        v_result vnd.elo_carteira.cd_sales_office%TYPE;
    BEGIN
        SELECT cd_sales_office
          INTO v_result
          FROM (
                    SELECT ca.cd_sales_office
                      FROM elo_carteira ca
                     WHERE ca.cd_elo_agendamento = p_cd_elo_agendamento
                       AND ca.cd_sales_group = p_cd_sales_group
                     ORDER BY ca.dh_inclusao DESC
               )
         WHERE ROWNUM = 1
        ;
        RETURN v_result;
    END fx_latest_sales_office;



    FUNCTION fx_latest_sales_district (
        p_cd_elo_agendamento    IN vnd.elo_carteira.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_carteira.cd_sales_office%TYPE
    ) RETURN vnd.elo_carteira.cd_sales_district%TYPE
    IS
        v_result vnd.elo_carteira.cd_sales_district%TYPE;
    BEGIN
        SELECT cd_sales_district
          INTO v_result
          FROM (
                    SELECT ca.cd_sales_district
                      FROM elo_carteira ca
                     WHERE ca.cd_elo_agendamento = p_cd_elo_agendamento
                       AND ca.cd_sales_office = p_cd_sales_office
                     ORDER BY ca.dh_inclusao DESC
               )
         WHERE ROWNUM = 1
        ;
        RETURN v_result;
    END fx_latest_sales_district;







    /*#######################################################################*/






    PROCEDURE PX_GET_CD_WEEKS ( P_RETORNO OUT T_CURSOR )
        IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT DISTINCT
                CD_WEEK

            FROM
                ELO_AGENDAMENTO
            ORDER BY CD_WEEK;

    END PX_GET_CD_WEEKS;


    PROCEDURE PX_GET_POLOS ( P_RETORNO OUT T_CURSOR )
        IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT
                CD_POLO,
                DS_POLO
            FROM
                CTF.POLO
            WHERE
                IC_ATIVO = 'S';

    END PX_GET_POLOS;


    PROCEDURE PX_GET_POLO (
        P_RETORNO   OUT T_CURSOR,
        P_CD_POLO   IN CTF.POLO.CD_POLO%TYPE
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT
                CD_POLO,
                DS_POLO
            FROM
                CTF.POLO
            WHERE
                    IC_ATIVO = 'S'
                AND
                    CD_POLO = P_CD_POLO;

    END PX_GET_POLO;


    PROCEDURE PX_GET_MAQUINAS (
        P_CD_CENTRO   IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_RETORNO     OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
          SELECT DISTINCT
                 M.CD_MACHINE,
                 M.DS_MACHINE
            FROM CTF.MACHINE M
           INNER JOIN CTF.CENTRO_EXPEDIDOR_MACHINE CM ON M.CD_MACHINE = CM.CD_MACHINE
           WHERE CM.CD_CENTRO_EXPEDIDOR = NVL(P_CD_CENTRO,CM.CD_CENTRO_EXPEDIDOR)
             AND M.IC_ATIVO = 'S'
             AND CM.IC_ATIVO = 'S'
        ORDER BY M.DS_MACHINE;

    END PX_GET_MAQUINAS;


    PROCEDURE PX_GET_MAQUINA (
        P_RETORNO      OUT T_CURSOR,
        P_CD_MAQUINA   IN CTF.MACHINE.CD_MACHINE%TYPE
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT
                CD_MACHINE,
                DS_MACHINE
            FROM
                CTF.MACHINE
            WHERE
                IC_ATIVO = 'S';

    END PX_GET_MAQUINA;

    PROCEDURE PX_GET_CENTROS (
        P_CD_POLO   IN CTF.POLO_CENTRO_EXPEDIDOR.CD_POLO%TYPE,
        P_RETORNO   OUT T_CURSOR
    )
    IS
    BEGIN
        IF
            (
                P_CD_POLO IS NULL
            OR P_CD_POLO = '' OR P_CD_POLO = '0' )
        THEN
            OPEN P_RETORNO FOR
                SELECT
                    CD_CENTRO_EXPEDIDOR,
                    CD_CENTRO_EXPEDIDOR || ' - ' || DS_CENTRO_EXPEDIDOR DS_CENTRO_EXPEDIDOR,
                    CD_CENTRO_EXPEDIDOR || ' - ' || DS_CENTRO_EXPEDIDOR AS CD_DS_CENTRO_EXPEDIDOR
                FROM
                    CTF.CENTRO_EXPEDIDOR
                WHERE
                        IC_ATIVO = 'S'
                ORDER BY DS_CENTRO_EXPEDIDOR;

        ELSE
            OPEN P_RETORNO FOR
                SELECT
                    C.CD_CENTRO_EXPEDIDOR,
                    c.CD_CENTRO_EXPEDIDOR || ' - ' || C.DS_CENTRO_EXPEDIDOR DS_CENTRO_EXPEDIDOR,
                    C.CD_CENTRO_EXPEDIDOR || ' - ' || C.DS_CENTRO_EXPEDIDOR AS CD_DS_CENTRO_EXPEDIDOR
                FROM
                    CTF.CENTRO_EXPEDIDOR C
                    INNER JOIN CTF.POLO_CENTRO_EXPEDIDOR PC ON PC.CD_CENTRO_EXPEDIDOR = C.CD_CENTRO_EXPEDIDOR
                WHERE
                        PC.CD_POLO = P_CD_POLO
                    AND
                        C.IC_ATIVO = 'S'
                ORDER BY DS_CENTRO_EXPEDIDOR;

        END IF;
    END PX_GET_CENTROS;

    PROCEDURE PX_GET_CENTRO (
        P_CD_CENTRO   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_RETORNO     OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR
            FROM
                CTF.CENTRO_EXPEDIDOR
            WHERE
                    IC_ATIVO = 'S'
                AND
                    CD_CENTRO_EXPEDIDOR = P_CD_CENTRO;

    END PX_GET_CENTRO;




    PROCEDURE PX_GET_NU_CARTEIRA_VERSION (
        P_POLO      IN CTF.POLO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO IN VND.ELO_CARTEIRA_SAP.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_RETORNO   OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT DISTINCT
               TO_DATE(ecs.NU_CARTEIRA_VERSION,'YYYYMMDDHH24MISS') AS NU_CARTEIRA_VERSION_DATE,
               ecs.NU_CARTEIRA_VERSION,
               (
                    SELECT COUNT(CD_ELO_CARTEIRA_SAP)
                      FROM VND.VW_ELO_CARTEIRA_SAP CS
                     WHERE CS.NU_CARTEIRA_VERSION = ECS.NU_CARTEIRA_VERSION
               ) QTDE
          FROM
               VND.VW_ELO_CARTEIRA_SAP ecs
         WHERE (P_CD_CENTRO IS NULL OR ecs.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO)
           AND (P_POLO IS NULL OR ecs.CD_CENTRO_EXPEDIDOR IN (select PC.CD_CENTRO_EXPEDIDOR 
                                                                from CTF.POLO_CENTRO_EXPEDIDOR PC
                                                               where PC.CD_POLO = P_POLO))
         ORDER BY 
               TO_DATE(ecs.NU_CARTEIRA_VERSION,'YYYYMMDDHH24MISS') DESC;

    END PX_GET_NU_CARTEIRA_VERSION;


    PROCEDURE PX_GET_MACHINE_PROFS (
        P_CD_POLO      IN CTF.POLO_CENTRO_EXPEDIDOR.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO    IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE   IN CTF.MACHINE.CD_MACHINE%TYPE DEFAULT NULL,
        P_RETORNO      OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT DISTINCT
            PROF.CD_MACHINE_PROFILE,
            PROF.DS_MACHINE_PROFILE,
            M.CD_MACHINE
        FROM
            CTF.POLO_CENTRO_EXPEDIDOR PC
            INNER JOIN CTF.CENTRO_EXPEDIDOR E ON E.CD_CENTRO_EXPEDIDOR = PC.CD_CENTRO_EXPEDIDOR
            INNER JOIN CTF.CENTRO_EXPEDIDOR_MACHINE MC ON MC.CD_CENTRO_EXPEDIDOR = E.CD_CENTRO_EXPEDIDOR
            INNER JOIN CTF.MACHINE M ON M.CD_MACHINE = MC.CD_MACHINE
            INNER JOIN CTF.MACHINE_MACHINE_PROFILE MM ON MM.CD_MACHINE = M.CD_MACHINE
            INNER JOIN CTF.MACHINE_PROFILE PROF ON PROF.CD_MACHINE_PROFILE = MM.CD_MACHINE_PROFILE
        WHERE
                PC.CD_POLO = NVL(P_CD_POLO,PC.CD_POLO)
            AND
                E.CD_CENTRO_EXPEDIDOR = NVL(P_CD_CENTRO,E.CD_CENTRO_EXPEDIDOR)
            AND
                M.CD_MACHINE = NVL(P_CD_MACHINE,M.CD_MACHINE)
        ORDER BY PROF.DS_MACHINE_PROFILE;

    END PX_GET_MACHINE_PROFS;


    PROCEDURE PI_CRIAR_AGENDAMENTO (
        P_CD_AGENDAMENTO                IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL,
        P_NU_CARTEIRA_VERSION           IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE DEFAULT NULL,
        P_DT_WEEK_START                 IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE DEFAULT NULL,
        P_CD_WEEK                       IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE DEFAULT NULL,
        P_CD_POLO                       IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR           IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE                    IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_DH_LIMITE                     IN VARCHAR,
        P_QT_OVERBOOKING_SUPERVISORES   IN VND.ELO_AGENDAMENTO.QT_OVERBOOKING_SUPERVISORES%TYPE DEFAULT NULL,
        P_QT_LIMITE_EMERGENCIAL         IN VND.ELO_AGENDAMENTO.QT_LIMITE_EMERGENCIAL%TYPE DEFAULT NULL,
        P_NU_SEMANAS                    IN VND.ELO_AGENDAMENTO.NU_SEMANAS%TYPE DEFAULT NULL,
        P_CD_AGENDAMENTO_CENTROS        IN VARCHAR DEFAULT NULL,
        P_OVERBOOKINGS                  IN VARCHAR DEFAULT NULL,
        P_MACHINE_PROFILES              IN VARCHAR DEFAULT NULL,
        P_RETORNO                       OUT T_CURSOR
    )
    IS
        V_CD_ELO_AGENDAMENTO   VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE;
        v_count NUMBER;
    BEGIN

        select count(ag.CD_ELO_AGENDAMENTO)
          into v_count
          from VND.ELO_AGENDAMENTO ag
         where ag.IC_ATIVO = 'S'
           and (P_CD_POLO is null or ag.CD_POLO = P_CD_POLO)
           and (P_CD_CENTRO_EXPEDIDOR is null or ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           and (P_CD_MACHINE is null or ag.CD_MACHINE = P_CD_MACHINE)
           and to_number(to_char(to_date(ag.DT_WEEK_START,'DD/MM/RRRR'),'WW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'WW'))
           and extract(year from ag.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
           and rownum = 1;

        IF v_count > 0 THEN
            select ag.CD_ELO_AGENDAMENTO
              into V_CD_ELO_AGENDAMENTO
              from VND.ELO_AGENDAMENTO ag
             where ag.IC_ATIVO = 'S'
               and (P_CD_POLO is null or ag.CD_POLO = P_CD_POLO)
               and (P_CD_CENTRO_EXPEDIDOR is null or ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
               and (P_CD_MACHINE is null or ag.CD_MACHINE = P_CD_MACHINE)
               and to_number(to_char(to_date(ag.DT_WEEK_START,'DD/MM/RRRR'),'WW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'WW'))
               and extract(year from ag.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
               and rownum = 1;
        END IF;

        IF P_CD_AGENDAMENTO is null AND V_CD_ELO_AGENDAMENTO is null THEN

            -- HEADER DO AGENDAMENTO
            PI_INSERE_ELO_AGENDAMENTO(
                P_NU_CARTEIRA_VERSION,
                P_DT_WEEK_START,
                P_CD_WEEK,
                P_CD_POLO,
                P_CD_CENTRO_EXPEDIDOR,
                P_CD_MACHINE,
                P_DH_LIMITE,
                P_QT_OVERBOOKING_SUPERVISORES,
                P_QT_LIMITE_EMERGENCIAL,
                P_NU_SEMANAS,
                V_CD_ELO_AGENDAMENTO
            );

        ELSE

            --V_CD_ELO_AGENDAMENTO := P_CD_AGENDAMENTO;

            --ATUALIZA AGENDAMENTO
            PU_ATUALIZA_ELO_AGENDAMENTO(
                P_NU_CARTEIRA_VERSION,
                P_DH_LIMITE,
                P_QT_OVERBOOKING_SUPERVISORES,
                P_QT_LIMITE_EMERGENCIAL,
                P_NU_SEMANAS,
                NVL(P_CD_AGENDAMENTO, V_CD_ELO_AGENDAMENTO)
            );

        END IF;

        -- ATUALIZA AGENDAMENTO_CENTRO_ITENS
        PU_AGEND_CENTRO_ITEM(
            P_CD_AGENDAMENTO_CENTROS,
            P_OVERBOOKINGS,
            P_OVERBOOKINGS,
            P_NU_SEMANAS
        ); 

        OPEN P_RETORNO FOR
            SELECT V_CD_ELO_AGENDAMENTO AS CD_ELO_AGENDAMENTO FROM  DUAL;

    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'PI_CRIAR_AGENDAMENTO - ERRO ENCONTRADO - '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM
                );
                ROLLBACK;
            END;
    END PI_CRIAR_AGENDAMENTO;



    PROCEDURE PU_ATUALIZA_ELO_AGENDAMENTO (
        P_NU_CARTEIRA_VERSION           IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_DH_LIMITE                     IN VARCHAR,
        P_QT_OVERBOOKING_SUPERVISORES   IN VND.ELO_AGENDAMENTO.QT_OVERBOOKING_SUPERVISORES%TYPE,
        P_QT_LIMITE_EMERGENCIAL         IN VND.ELO_AGENDAMENTO.QT_LIMITE_EMERGENCIAL%TYPE,
        P_NU_SEMANAS                    IN VND.ELO_AGENDAMENTO.NU_SEMANAS%TYPE,
        P_CD_ELO_AGENDAMENTO            IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE
    )

    IS

    BEGIN

        update VND.ELO_AGENDAMENTO
           set NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION,
               DH_LIMITE = TO_DATE(P_DH_LIMITE,'DD/MM/YYYY HH24:MI'),
               QT_OVERBOOKING_SUPERVISORES = P_QT_OVERBOOKING_SUPERVISORES,
               QT_LIMITE_EMERGENCIAL = P_QT_LIMITE_EMERGENCIAL,
               NU_SEMANAS = P_NU_SEMANAS
         where CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO;

    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RAISE_APPLICATION_ERROR(-20001, 'PU_ATUALIZA_ELO_AGENDAMENTO - ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                ROLLBACK;
            END;

    END PU_ATUALIZA_ELO_AGENDAMENTO;

    PROCEDURE PI_RELEASE_SCHEDULING (
        P_CD_ELO_AGENDAMENTO            IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_NU_CARTEIRA_VERSION           IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_CD_POLO                       IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR           IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE                    IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_RETORNO                       OUT T_CURSOR
    ) 

    IS

    BEGIN

        VND.GX_ELO_AGENDAMENTO.PI_CREATE_PARAMETERS_IMAGES(P_CD_ELO_AGENDAMENTO);

        -- COPIA A CARTEIRA
        VND.GX_ELO_AGENDAMENTO.PI_COPY_PORTFOLIO(
            P_CD_ELO_AGENDAMENTO,
            P_NU_CARTEIRA_VERSION,
            P_CD_POLO,
            P_CD_CENTRO_EXPEDIDOR,
            P_CD_MACHINE
        );        

        -- INSERE REGISTROS EM VND.ELO_AGENDAMENTO_SUPERVISOR
        -- PI_INSERE_ELO_AGEND_SUPERVISOR(V_CD_ELO_AGENDAMENTO);
        VND.GX_ELO_AGENDAMENTO.PI_AGENDAMENTO_SUPERVISOR (
            P_CD_ELO_AGENDAMENTO
        );

        -- INSERE REGISTROS EM VND.ELO_AGENDAMENTO_ITEM
        VND.GX_ELO_AGENDAMENTO.PI_AGENDAMENTO_ITEM (
            P_CD_ELO_AGENDAMENTO
        );

        -- ATUALIZA STATUS
        update VND.ELO_AGENDAMENTO
           set CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('AGEND','AGOPN')
         where CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
           and CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('AGEND','AGNEW');

        OPEN P_RETORNO FOR
            SELECT P_CD_ELO_AGENDAMENTO AS CD_ELO_AGENDAMENTO FROM DUAL;

    END PI_RELEASE_SCHEDULING;

    PROCEDURE PI_INSERE_ELO_AGENDAMENTO (
        P_NU_CARTEIRA_VERSION           IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE DEFAULT NULL,
        P_DT_WEEK_START                 IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE DEFAULT NULL,
        P_CD_WEEK                       IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE DEFAULT NULL,
        P_CD_POLO                       IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR           IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE                    IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_DH_LIMITE                     IN VARCHAR,
        P_QT_OVERBOOKING_SUPERVISORES   IN VND.ELO_AGENDAMENTO.QT_OVERBOOKING_SUPERVISORES%TYPE DEFAULT NULL,
        P_QT_LIMITE_EMERGENCIAL         IN VND.ELO_AGENDAMENTO.QT_LIMITE_EMERGENCIAL%TYPE DEFAULT NULL,
        P_NU_SEMANAS                    IN VND.ELO_AGENDAMENTO.NU_SEMANAS%TYPE DEFAULT NULL,
        P_CD_ELO_AGENDAMENTO            OUT VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE
    )
    IS

    BEGIN

        INSERT INTO ELO_AGENDAMENTO (
            CD_ELO_AGENDAMENTO,
            DT_WEEK_START,
            CD_WEEK,
            CD_CENTRO_EXPEDIDOR,
            CD_POLO,
            CD_MACHINE,
            NU_CARTEIRA_VERSION,
            DH_LIMITE,
            QT_OVERBOOKING_SUPERVISORES,
            QT_LIMITE_EMERGENCIAL,
            CD_ELO_STATUS,
            NU_SEMANAS,
            IC_ATIVO
        ) VALUES (
            SEQ_ELO_AGENDAMENTO.NEXTVAL,
            P_DT_WEEK_START,
            P_CD_WEEK,
            P_CD_CENTRO_EXPEDIDOR,
            P_CD_POLO,
            P_CD_MACHINE,
            P_NU_CARTEIRA_VERSION,
            TO_DATE(P_DH_LIMITE,'DD/MM/YYYY HH24:MI'),
            P_QT_OVERBOOKING_SUPERVISORES,
            P_QT_LIMITE_EMERGENCIAL,
            VND.GX_ELO_COMMON.FX_ELO_STATUS('AGEND', 'AGNEW'),
            P_NU_SEMANAS,
            'S'
        ) RETURNING CD_ELO_AGENDAMENTO INTO P_CD_ELO_AGENDAMENTO;

        EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'PI_INSERE_ELO_AGENDAMENTO - ERRO ENCONTRADO - '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM
                );
                ROLLBACK;
            END;

    END PI_INSERE_ELO_AGENDAMENTO;


    PROCEDURE PX_GET_AGENDAMENTO (
        P_WEEK                  IN VARCHAR2 DEFAULT NULL,
        P_CD_POLO               VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_SG_STATUS             varchar DEFAULT NULL,
        P_IC_ATIVO              VND.ELO_AGENDAMENTO.IC_ATIVO%TYPE DEFAULT NULL,
        P_RETORNO               OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR

        SELECT  A.CD_ELO_AGENDAMENTO,
                A.CD_POLO,
                A.CD_CENTRO_EXPEDIDOR,
                A.CD_MACHINE,
                S.DS_STATUS,
                P.DS_POLO,
                C.DS_CENTRO_EXPEDIDOR,
                M.DS_MACHINE,
                CASE 
                    WHEN A.CD_POLO IS NOT NULL
                    THEN 'POLO : ' || P.DS_POLO
                WHEN 
                    A.CD_CENTRO_EXPEDIDOR IS NOT NULL
                    THEN 'CENTRO : ' || C.DS_CENTRO_EXPEDIDOR
                WHEN 
                    A.CD_MACHINE IS NOT NULL
                    THEN 'MAQUINA : ' || M.DS_MACHINE
                END                                             AS LOCAL,
                A.CD_ELO_AGENDAMENTO,
                TO_CHAR(A.DT_WEEK_START,'DD/MM/YYYY')           AS DT_WEEK_START,
                A.CD_WEEK
            FROM
                VND.ELO_AGENDAMENTO A
           INNER JOIN VND.ELO_STATUS S 
              ON A.CD_ELO_STATUS = S.CD_ELO_STATUS 
           INNER JOIN ELO_TIPO_STATUS T on T.CD_ELO_TIPO_STATUS = S.CD_ELO_TIPO_STATUS
            LEFT JOIN CTF.POLO P 
              ON A.CD_POLO = P.CD_POLO
            LEFT JOIN CTF.CENTRO_EXPEDIDOR C 
              ON A.CD_CENTRO_EXPEDIDOR =  C.CD_CENTRO_EXPEDIDOR
            LEFT JOIN CTF.MACHINE M 
              ON A.CD_MACHINE = M.CD_MACHINE
           WHERE T.SG_TIPO_STATUS = 'AGEND'
             AND (P_CD_POLO IS NULL OR TRIM(A.CD_POLO) = TRIM(P_CD_POLO))
             AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR TRIM(A.CD_CENTRO_EXPEDIDOR) = TRIM(P_CD_CENTRO_EXPEDIDOR))
             AND (P_CD_MACHINE IS NULL OR A.CD_MACHINE = P_CD_MACHINE)
             and (P_WEEK is null OR A.CD_WEEK = P_WEEK)
             AND (P_IC_ATIVO IS NULL OR A.IC_ATIVO = P_IC_ATIVO)
        ORDER BY A.CD_ELO_AGENDAMENTO DESC;

    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'ERRO ENCONTRADO - '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM
                );
                ROLLBACK;
            END;
    END PX_GET_AGENDAMENTO;


    PROCEDURE PU_AGEND_CENTRO_ITEM (
        P_CD_AGENDAMENTO_CENTROS   IN VARCHAR,
        P_OVERBOOKINGS             IN VARCHAR,
        P_MACHINE_PROFS            IN VARCHAR,
        P_NU_SEMANAS               IN NUMBER
    )
    IS
        TAB_CD_CENTROS              SPLIT_TBL;
        TAB_CD_CENTROS_TAB1         SPLIT_TBL;
        TAB_CD_CENTROS_TAB2         SPLIT_TBL;
        TAB_OVERBOOKINGS            SPLIT_TBL;
        TAB_OVERBOOKINGS_TAB1       SPLIT_TBL;
        TAB_OVERBOOKINGS_TAB2       SPLIT_TBL;
        TAB_MACHINE_PROFILES        SPLIT_TBL;
        TAB_MACHINE_PROFILES_TAB1   SPLIT_TBL;
        TAB_MACHINE_PROFILES_TAB2   SPLIT_TBL;
    BEGIN
        TAB_CD_CENTROS := GX_ELO_AGENDAMENTO.FX_SPLIT2(P_CD_AGENDAMENTO_CENTROS,'@');
        TAB_OVERBOOKINGS := GX_ELO_AGENDAMENTO.FX_SPLIT2(P_OVERBOOKINGS,'@');
        TAB_MACHINE_PROFILES := GX_ELO_AGENDAMENTO.FX_SPLIT2(P_MACHINE_PROFS,'@');

        ------------ TAB1-----------------
        TAB_CD_CENTROS_TAB1 := GX_ELO_AGENDAMENTO.FX_SPLIT2(TAB_CD_CENTROS(1),',');
        TAB_OVERBOOKINGS_TAB1 := GX_ELO_AGENDAMENTO.FX_SPLIT2(TAB_OVERBOOKINGS(1),',');
        TAB_MACHINE_PROFILES_TAB1 := GX_ELO_AGENDAMENTO.FX_SPLIT2(TAB_MACHINE_PROFILES(1),',');
        FOR I IN TAB_CD_CENTROS_TAB1.FIRST..TAB_CD_CENTROS_TAB1.LAST LOOP
            FOR X IN TAB_OVERBOOKINGS_TAB1.FIRST..TAB_OVERBOOKINGS_TAB1.LAST LOOP
                UPDATE ELO_AGENDAMENTO_CENTRO_ITEM
                    SET
                        QT_OVERBOOKING = TAB_OVERBOOKINGS_TAB1(X)
                WHERE
                        CD_AGENDAMENTO_CENTRO = TAB_CD_CENTROS_TAB1(I)
                    AND
                        NU_DIA_SEMANA = X;

            END LOOP;

            FOR X IN TAB_MACHINE_PROFILES_TAB1.FIRST..TAB_MACHINE_PROFILES_TAB1.LAST LOOP
                UPDATE ELO_AGENDAMENTO_CENTRO_ITEM
                    SET
                        CD_PERFIL_MAQUINA = TAB_MACHINE_PROFILES_TAB1(X)
                WHERE
                        CD_AGENDAMENTO_CENTRO = TAB_CD_CENTROS_TAB1(I)
                    AND
                        NU_DIA_SEMANA = X;

            END LOOP;

        END LOOP;


        ------------ TAB2-----------------

        IF
            P_NU_SEMANAS = 2
        THEN
            IF
                TAB_CD_CENTROS.COUNT > 1
            THEN
                TAB_CD_CENTROS_TAB2 := GX_ELO_AGENDAMENTO.FX_SPLIT2(TAB_CD_CENTROS(2),',');
            END IF;

            IF
                TAB_OVERBOOKINGS.COUNT > 1
            THEN
                TAB_OVERBOOKINGS_TAB2 := GX_ELO_AGENDAMENTO.FX_SPLIT2(TAB_OVERBOOKINGS(2),',');
            END IF;

            IF
                TAB_MACHINE_PROFILES.COUNT > 1
            THEN
                TAB_MACHINE_PROFILES_TAB2 := GX_ELO_AGENDAMENTO.FX_SPLIT2(TAB_MACHINE_PROFILES(2),',');
            END IF;

            FOR I IN TAB_CD_CENTROS_TAB2.FIRST..TAB_CD_CENTROS_TAB2.LAST LOOP
                FOR X IN TAB_OVERBOOKINGS_TAB2.FIRST..TAB_OVERBOOKINGS_TAB2.LAST LOOP
                    UPDATE ELO_AGENDAMENTO_CENTRO_ITEM
                        SET
                            QT_OVERBOOKING = TAB_OVERBOOKINGS_TAB2(X)
                    WHERE
                            CD_AGENDAMENTO_CENTRO = TAB_CD_CENTROS_TAB2(I)
                        AND
                            NU_DIA_SEMANA = X;

                END LOOP;

                FOR X IN TAB_MACHINE_PROFILES_TAB2.FIRST..TAB_MACHINE_PROFILES_TAB2.LAST LOOP
                    UPDATE ELO_AGENDAMENTO_CENTRO_ITEM
                        SET
                            CD_PERFIL_MAQUINA = TAB_MACHINE_PROFILES_TAB2(X)
                    WHERE
                            CD_AGENDAMENTO_CENTRO = TAB_CD_CENTROS_TAB2(I)
                        AND
                            NU_DIA_SEMANA = X;

                END LOOP;

            END LOOP;

            TAB_CD_CENTROS_TAB2.DELETE;
            TAB_OVERBOOKINGS_TAB2.DELETE;
            TAB_MACHINE_PROFILES_TAB2.DELETE;
        END IF;

        TAB_CD_CENTROS.DELETE;
        TAB_CD_CENTROS_TAB1.DELETE;
        TAB_OVERBOOKINGS.DELETE;
        TAB_OVERBOOKINGS_TAB1.DELETE;
        TAB_MACHINE_PROFILES.DELETE;
        TAB_MACHINE_PROFILES_TAB1.DELETE;
    END PU_AGEND_CENTRO_ITEM;


    PROCEDURE PI_INSERE_ELO_AGEND_SUPERVISOR (
        P_CD_ELO_AGENDAMENTO   IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL
    )
    IS
    BEGIN
        INSERT INTO ELO_AGENDAMENTO_SUPERVISOR (
            CD_ELO_AGENDAMENTO,
            CD_ELO_AGENDAMENTO_SUPERVISOR,
            CD_SALES_DISTRICT,
            CD_SALES_GROUP,
            CD_SALES_OFFICE,
            IC_ATIVO
        ) SELECT
            P_CD_ELO_AGENDAMENTO,
            SEQ_ELO_AGEND_SUPERVISOR.NEXTVAL,
            CD_SALES_DISTRICT,
            CD_SALES_GROUP,
            CD_SALES_OFFICE,
            IC_ATIVO
        FROM
            (
                SELECT DISTINCT
                    CD_SALES_DISTRICT,
                    CD_SALES_GROUP,
                    CD_SALES_OFFICE,
                    'S' AS IC_ATIVO
                FROM
                    ELO_CARTEIRA
                WHERE
                    CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
            );

    END PI_INSERE_ELO_AGEND_SUPERVISOR;


    PROCEDURE PI_CREATE_PARAMETERS_IMAGES (
        P_CD_ELO_AGENDAMENTO   IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL
    )
    IS
        V_CD_LOCAL  CHAR(4);
        V_COUNT     NUMBER := 0;
    BEGIN 

        -- ELO_PRIORITY_PANEL to ELO_AGENDAMENTO_PRIO_PANEL
        SELECT NVL(CD_POLO, NVL(CD_CENTRO_EXPEDIDOR, CD_MACHINE))
          INTO V_CD_LOCAL
          FROM VND.ELO_AGENDAMENTO AG
         WHERE AG.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
        ;
        
        SELECT COUNT(CD_ELO_PRIORITY_PANEL)
          INTO V_COUNT
          FROM VND.ELO_PRIORITY_PANEL
         WHERE CD_CENTRO_EXPEDIDOR = V_CD_LOCAL
        ;

        IF V_COUNT > 0 THEN
            INSERT INTO VND.ELO_AGENDAMENTO_PRIO_PANEL (
                CD_ELO_AGENDAMENTO_PRIO_PANEL,
                CD_ELO_AGENDAMENTO,
                CD_ELO_PRIORITY_OPTION,
                NU_ORDER
            )
            SELECT
                   SEQ_ELO_AGEND_PRIO_PANEL.NEXTVAL,
                   P_CD_ELO_AGENDAMENTO,
                   CD_ELO_PRIORITY_OPTION,
                   NU_ORDER
              FROM VND.ELO_PRIORITY_PANEL
             WHERE CD_CENTRO_EXPEDIDOR = V_CD_LOCAL
            ;
        ELSE
            INSERT INTO VND.ELO_AGENDAMENTO_PRIO_PANEL (
                CD_ELO_AGENDAMENTO_PRIO_PANEL,
                CD_ELO_AGENDAMENTO,
                CD_ELO_PRIORITY_OPTION,
                NU_ORDER
            )
            SELECT
                   SEQ_ELO_AGEND_PRIO_PANEL.NEXTVAL,
                   P_CD_ELO_AGENDAMENTO,
                   CD_ELO_PRIORITY_OPTION,
                   NU_ORDER
              FROM VND.ELO_PRIORITY_PANEL
             WHERE CD_CENTRO_EXPEDIDOR IS NULL
            ;
        END IF;


        -- ELO_PRIORITY_MATERIAL to ELO_AGENDAMENTO_PRIO_MATERIAL

        INSERT INTO VND.ELO_AGENDAMENTO_PRIO_MATERIAL (
            CD_ELO_AGENDAMENTO,
            CD_PRODUTO_SAP,
            NU_ORDER
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_PRODUTO_SAP,
               NU_ORDER
          FROM VND.ELO_PRIORITY_MATERIAL
        ;


        -- CLIENTE_RELACIONAMENTO to ELO_AGENDAMENTO_CLI_RELAC

        INSERT INTO VND.ELO_AGENDAMENTO_CLI_RELAC (
            CD_ELO_AGENDAMENTO,
            CD_CLIENTE,
            NO_CLIENTE
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_CLIENTE,
               NO_CLIENTE
          FROM CTF.CLIENTE_RELACIONAMENTO
        ;


        -- POLO_CENTRO_EXPEDIDOR to ELO_AGENDAMENTO_POLO_CENTRO

        INSERT INTO VND.ELO_AGENDAMENTO_POLO_CENTRO (
            CD_ELO_AGENDAMENTO,
            CD_POLO,
            CD_CENTRO_EXPEDIDOR
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_POLO,
               CD_CENTRO_EXPEDIDOR
          FROM CTF.POLO_CENTRO_EXPEDIDOR PC
         WHERE PC.IC_ATIVO = 'S'
        ;


        -- CENTRO_EXPEDIDOR_MACHINE to ELO_AGENDAMENTO_CENTRO_MACHINE

        INSERT INTO ELO_AGENDAMENTO_CENTRO_MACHINE (
            CD_ELO_AGENDAMENTO,
            CD_CENTRO_EXPEDIDOR,
            CD_MACHINE
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_CENTRO_EXPEDIDOR,
               CD_MACHINE
          FROM CTF.CENTRO_EXPEDIDOR_MACHINE PM
         WHERE PM.IC_ATIVO = 'S'
        ;


        -- MACHINE_MACHINE_PROFILE to ELO_AGENDAMENTO_MACHINE_PROFIL

        INSERT INTO ELO_AGENDAMENTO_MACHINE_PROFIL (
            CD_ELO_AGENDAMENTO,
            CD_MACHINE,
            CD_MACHINE_PROFILE
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_MACHINE,
               CD_MACHINE_PROFILE
          FROM CTF.MACHINE_MACHINE_PROFILE MP
         WHERE MP.IC_ATIVO = 'S'
        ;


        -- MACHINE_PROFILE_LINHA_PRODUTO to ELO_AGENDAMENTO_PROFILE_LINHA

        INSERT INTO ELO_AGENDAMENTO_PROFILE_LINHA (
            CD_ELO_AGENDAMENTO,
            CD_MACHINE_PROFILE,
            CD_LINHA_PRODUTO_SAP
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_MACHINE_PROFILE,
               CD_LINHA_PRODUTO_SAP
          FROM CTF.MACHINE_PROFILE_LINHA_PRODUTO ML
         WHERE ML.IC_ATIVO = 'S'
        ;


        -- CENTRO_EXPEDIDOR_GRP_EMBALAGEM to ELO_AGENDAMENTO_CEN_GRP_EMB

        INSERT INTO ELO_AGENDAMENTO_CEN_GRP_EMB (
            CD_ELO_AGENDAMENTO,
            CD_CENTRO_EXPEDIDOR,
            CD_GRUPO_EMBALAGEM
        )
        SELECT
               P_CD_ELO_AGENDAMENTO,
               CD_CENTRO_EXPEDIDOR,
               CD_GRUPO_EMBALAGEM
          FROM CTF.CENTRO_EXPEDIDOR_GRP_EMBALAGEM CG
         WHERE CG.IC_ATIVO = 'S'
        ;

    END PI_CREATE_PARAMETERS_IMAGES;


    PROCEDURE PX_GET_AGEND_CENTRO_ITENS (
        P_CD_POLO         IN ELO_AGENDAMENTO_CENTRO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO       IN ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE      IN ELO_AGENDAMENTO_CENTRO.CD_MACHINE%TYPE DEFAULT NULL,
        P_DT_WEEK_START   IN ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%TYPE,
        P_RETORNO         OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT
                CI.CD_AGENDAMENTO_CENTRO,
                CI.NU_DIA_SEMANA,
                CI.NU_CAPACIDADE,
                CI.NU_CAPACIDADE_MAXIMA,
                CI.NU_ENSACADO,
                CI.QT_OVERBOOKING,
                MP.DS_MACHINE_PROFILE,
                C.CD_POLO,
                C.CD_CENTRO_EXPEDIDOR,
                C.CD_MACHINE,
                C.DT_WEEK_START
            FROM
                ELO_AGENDAMENTO_CENTRO_ITEM CI
                INNER JOIN ELO_AGENDAMENTO_CENTRO C ON C.CD_AGENDAMENTO_CENTRO = CI.CD_AGENDAMENTO_CENTRO
                LEFT JOIN CTF.MACHINE_PROFILE MP ON MP.CD_MACHINE_PROFILE = CI.CD_PERFIL_MAQUINA

            WHERE  (P_CD_POLO IS NULL OR TRIM(C.CD_POLO) = TRIM(P_CD_POLO))

                AND (P_CD_CENTRO IS NULL OR TRIM(C.CD_CENTRO_EXPEDIDOR) = TRIM(P_CD_CENTRO))
                AND (P_CD_MACHINE IS NULL OR TRIM(C.CD_MACHINE) = TRIM(P_CD_MACHINE))
                AND (P_DT_WEEK_START IS NULL OR to_number(to_char(to_date(C.DT_WEEK_START,'DD/MM/RRRR'),'WW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'WW')))
                AND EXTRACT(YEAR FROM C.DT_WEEK_START) = EXTRACT(YEAR FROM TO_DATE(P_DT_WEEK_START,'DD/MM/RRRR'))
                AND C.IC_ATIVO = 'S'
                AND CI.IC_ATIVO = 'S'
                
            ORDER BY
                C.CD_POLO,
                C.CD_CENTRO_EXPEDIDOR,
                CI.NU_DIA_SEMANA;

    END PX_GET_AGEND_CENTRO_ITENS;

    PROCEDURE PU_STATUS_LOGISTICA (
        P_CD_ELO_CARTEIRA   IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
        P_STATUS_LOGISTICA  IN VND.ELO_CARTEIRA.CD_STATUS_LOGISTICA%TYPE,
        P_RESULT            OUT T_CURSOR
    )

    IS

    BEGIN

        SAVEPOINT sp_sptest;

        IF P_CD_ELO_CARTEIRA is null or P_CD_ELO_CARTEIRA = 0 THEN
            RAISE_APPLICATION_ERROR(-20101, ' Parameter: P_CD_ELO_CARTEIRA is null or empty');
        ELSE
            update VND.ELO_CARTEIRA
               set CD_STATUS_LOGISTICA = P_STATUS_LOGISTICA
             where CD_ELO_CARTEIRA = P_CD_ELO_CARTEIRA;
        END IF;

        OPEN P_RESULT FOR
            select P_CD_ELO_CARTEIRA as CD_ELO_CARTEIRA from dual;

    EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO sp_sptest;
        RAISE_APPLICATION_ERROR(-20000,'  ' || 'SQLERRM');

    NULL;

    END PU_STATUS_LOGISTICA;



    PROCEDURE PI_COPY_PORTFOLIO (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE,
        P_NU_CARTEIRA_VERSION   IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE
    )
    IS
        v_records_affected      NUMBER;
    BEGIN
        /***********************************************************************
        Exclusao de registros duplicados.
        Solucao temporaria, enquanto a extracao da carteira nao for corrigida
        no SAP.
        ***********************************************************************/
        INSERT INTO VND.ELO_CARTEIRA_SAP_BKP (
           CD_ELO_CARTEIRA_SAP, 
           NU_CARTEIRA_VERSION, 
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
           NU_CNPJ, NU_CPF, 
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
           VL_FRETE_DISTRIBUICAO, 
           CD_GRUPO_EMBALAGEM, 
           DS_CREDIT_BLOCK_REASON, 
           DH_CREDIT_BLOCK, 
           CD_ITEM_CONTRATO, 
           DS_ROTEIRO_ENTREGA, 
           DS_ENDERECO_PAGADOR, 
           NO_SALES_DISTRICT, 
           DH_BACKUP
        )
        SELECT
             CD_ELO_CARTEIRA_SAP,
             NU_CARTEIRA_VERSION,
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
             VL_FRETE_DISTRIBUICAO,
             CD_GRUPO_EMBALAGEM,
             DS_CREDIT_BLOCK_REASON,
             DH_CREDIT_BLOCK,
             CD_ITEM_CONTRATO,
             DS_ROTEIRO_ENTREGA,
             DS_ENDERECO_PAGADOR,
             NO_SALES_DISTRICT,
             CURRENT_DATE
        FROM vnd.VW_elo_carteira_sap 
       WHERE nu_carteira_version = P_NU_CARTEIRA_VERSION 
         AND cd_elo_carteira_sap NOT IN (
                SELECT MIN(cd_elo_carteira_sap) cd_elo_carteira 
                  FROM vnd.VW_elo_carteira_sap 
                 WHERE nu_carteira_version = P_NU_CARTEIRA_VERSION
                 GROUP BY nu_contrato_sap, 
                          cd_item_contrato, 
                          nu_ordem_venda, 
                          cd_item_pedido
             );

        DELETE FROM vnd.elo_carteira_sap 
         WHERE nu_carteira_version = P_NU_CARTEIRA_VERSION 
           AND cd_elo_carteira_sap NOT IN (
                SELECT MIN(cd_elo_carteira_sap) cd_elo_carteira 
                  FROM vnd.elo_carteira_sap 
                 WHERE nu_carteira_version = P_NU_CARTEIRA_VERSION
                 GROUP BY nu_contrato_sap, 
                          cd_item_contrato, 
                          nu_ordem_venda, 
                          cd_item_pedido
        );
        
        v_records_affected := SQL%ROWCOUNT;
        
        ctf.gx_email_service.pi_email_with_body (
            'sergio.umlauf@mosaicco.com',
            'noreply@mosaicco.com',
            NULL,
            NULL,
            'ELO - Registros excluídos em ELO_CARTEIRA_SAP',
            TO_CHAR(v_records_affected)
        );
        /**********************************************************************/
        
        
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
     SELECT VND.SEQ_ELO_CARTEIRA.NEXTVAL,
            Y.CD_CENTRO_EXPEDIDOR,
            Y.DS_CENTRO_EXPEDIDOR,
            Y.DH_CARTEIRA,
            Y.CD_SALES_ORG,
            Y.NU_CONTRATO_SAP,
            Y.CD_TIPO_CONTRATO,
            Y.NU_CONTRATO_SUBSTITUI,
            Y.DT_PAGO,
            Y.NU_CONTRATO,
            Y.NU_ORDEM_VENDA,
            Y.DS_STATUS_CONTRATO_SAP,
            Y.CD_CLIENTE,
            Y.NO_CLIENTE,
            Y.CD_INCOTERMS,
            Y.CD_SALES_DISTRICT,
            Y.CD_SALES_OFFICE,
            Y.NO_SALES_OFFICE,
            Y.CD_SALES_GROUP,
            Y.NO_SALES_GROUP,
            Y.CD_AGENTE_VENDA,
            Y.NO_AGENTE,
            Y.DH_VENCIMENTO_PEDIDO,
            Y.DT_CREDITO,
            Y.DT_INICIO,
            Y.DT_FIM,
            Y.DH_INCLUSAO,
            Y.DH_ENTREGA,
            Y.SG_ESTADO,
            Y.NO_MUNICIPIO,
            Y.DS_BAIRRO,
            Y.CD_PRODUTO_SAP,
            Y.NO_PRODUTO_SAP,
            Y.QT_PROGRAMADA,
            Y.QT_ENTREGUE,
            Y.QT_SALDO,
            Y.VL_UNITARIO,
            Y.VL_BRL,
            Y.VL_TAXA_DOLAR,
            Y.VL_USD,
            Y.PC_COMISSAO,
            Y.CD_SACARIA,
            Y.DS_SACARIA,
            Y.CD_CULTURA_SAP,
            Y.DS_CULTURA_SAP,
            Y.CD_BLOQUEIO_REMESSA,
            Y.CD_BLOQUEIO_FATURAMENTO,
            Y.CD_BLOQUEIO_CREDITO,
            Y.CD_BLOQUEIO_REMESSA_ITEM,
            Y.CD_BLOQUEIO_FATURAMENTO_ITEM,
            Y.CD_MOTIVO_RECUSA,
            Y.CD_LOGIN,
            Y.CD_SEGMENTACAO_CLIENTE,
            Y.DS_SEGMENTACAO_CLIENTE,
            Y.DS_SEGMENTO_CLIENTE_SAP,
            Y.CD_FORMA_PAGAMENTO,
            Y.CD_TIPO_PAGAMENTO,
            Y.DS_TIPO_PAGAMENTO,
            Y.CD_AGRUPAMENTO,
            Y.CD_BLOQUEIO_ENTREGA,
            Y.NU_CNPJ,
            Y.NU_CPF,
            Y.NU_INSCRICAO_ESTADUAL,
            Y.NU_INSCRICAO_MUNICIPAL,
            Y.NU_CEP,
            Y.DS_ENDERECO_RECEBEDOR,
            Y.CD_CLIENTE_RECEBEDOR,
            Y.NO_CLIENTE_RECEBEDOR,
            Y.CD_MOEDA,
            Y.CD_SUPPLY_GROUP,
            Y.DS_VENDA_COMPARTILHADA,
            Y.CD_STATUS_LIBERACAO,
            Y.CD_ITEM_PEDIDO,
            Y.CD_CLIENTE_PAGADOR,
            Y.NO_CLIENTE_PAGADOR,
            Y.CD_GRUPO_EMBALAGEM,
            Y.DS_CREDIT_BLOCK_REASON,
            Y.DH_CREDIT_BLOCK,
            Y.CD_ITEM_CONTRATO,
            Y.VL_FRETE_DISTRIBUICAO,
            Y.DS_ENDERECO_PAGADOR,
            Y.NO_SALES_DISTRICT,
            NULL,                               --CD_ELO_AGENDAMENTO_ITEM
            Y.IC_SEM_ORDEM_VENDA,               --IC_SEM_ORDEM_VENDA
            Y.IC_RELACIONAMENTO,                --IC_RELACIONAMENTO
            NULL,                               --NU_ORDEM
            NULL,                               --QT_AGENDADA
            NULL,                               --QT_AGENDADA_FABRICA
            NULL,                               --QT_AGENDADA_SAP
            NULL,                               --CD_USUARIO_REFRESH
            NULL,                               --DH_REFRESH
            NULL,                               --QT_PROGRAMADA_REFRESH
            NULL,                               --QT_ENTREGUE_REFRESH
            NULL,                               --QT_SALDO_REFRESH
            NULL,                               --QT_AGENDADA_CONFIRMADA
            NULL,                               --CD_TIPO_AGENDAMENTO
            NULL,                               --CD_TIPO_REPLAN
            NULL,                               --CD_BLOQUEIO_REMESSA_R
            NULL,                               --CD_BLOQUEIO_FATURAMENTO_R
            NULL,                               --CD_BLOQUEIO_CREDITO_R
            NULL,                               --CD_BLOQUEIO_REMESSA_ITEM_R
            NULL,                               --CD_BLOQUEIO_FATURAMENTO_ITEM_R
            NULL,                               --DS_OBSERVACAO_ADVEN
            NULL,                               --IC_PERMITIR_CS
            NULL,                               --DH_LIBERACAO_TORRE_FRETES
            NULL,                               --DH_MODIFICACAO_TORRE_FRETES
            NULL,                               --DH_CONTRATACAO_TORRE_FRETES
            NULL,                               --CD_STATUS_TORRE_FRETES
            NULL,                               --VL_FRETE_CONTRATADO
            NULL,                               --IC_NAO_LIBERADA_SEM_PROTOCOLO
            NULL,                               --IC_ENTREGA_CADENCIADA_CLIENTE
            NULL,                               --IC_DIFICULDADE_CONTRATACAO
            NULL,                               --IC_OUTROS
            NULL,                               --CD_STATUS_CUSTOMER_SERVICE
            NULL,                               --CD_STATUS_TORRE_FRETES
            NULL,                               --CD_STATUS_CONTROLADORIA
            'S',                                --IC_ATIVO
            NULL,                               --SG_DESTINO_BACKLOG_CIF
            NULL,                               --CD_STATUS_BACKLOG_CIF
            NULL,                               --QT_AGENDADA_ANTERIOR
            NULL,                               --DH_BACKLOG_CIF
            NULL,                               --QT_BACKLOG_CIF
            P_CD_ELO_AGENDAMENTO,              --CD_ELO_AGENDAMENTO
            NULL,                               --QT_AGENDADA_REFRESH
            NULL,                               --CD_USUARIO_FABRICA
            NULL,                               --DH_FABRICA
            NULL,                               --CD_USUARIO_CORTADO_FABRICA
            NULL,                               --DH_CORTADO_FABRICA
            NULL,                               --CD_USUARIO_AJUSTE_SAP
            NULL,                               --DH_AJUSTE_SAP
            NULL,                               --CD_STATUS_LOGISTICA
            NULL,                               --IC_CORTADO_FABRICA
            Y.IC_COOPERATIVE,                   --IC_COOPERATIVE
            Y.IC_SPLIT,                         --IC_SPLIT
            Y.IC_FA,                            --IC_FA
            NULL,                               --IC_EMERGENCIAL
            Y.DS_ROTEIRO_ENTREGA,               --DS_ROTEIRO_ENTREGA
            Y.CD_ELO_PRIORITY_OPTION,           --CD_ELO_PRIORITY_OPTION
            NULL,                               --QT_AJUSTADA_FABRICA 
            NULL,                               --QT_AJUSTADA_SAP
            Y.IC_EXPORT,                        --IC_EXPORT
            NULL,                               --DS_CREDIT_BLOCK_REASON_R,
            NULL,                               --CD_STATUS_CEL_INITIAL,
            NULL                                --CD_STATUS_CEL_FINAL

  FROM (
            WITH X AS 
                (
                    SELECT CS_.NU_ORDEM_VENDA,
                           COUNT(CS_.CD_ELO_CARTEIRA_SAP) QT
                      FROM VND.VW_ELO_CARTEIRA_SAP CS_
                     WHERE
                           CS_.NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
                           AND
                           (
                               P_CD_POLO IS NULL OR CS_.CD_CENTRO_EXPEDIDOR IN (
                                                    SELECT CD_CENTRO_EXPEDIDOR
                                                      FROM VND.ELO_AGENDAMENTO_POLO_CENTRO PC
                                                     WHERE PC.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                                       AND TRIM(PC.CD_POLO) = TRIM(P_CD_POLO)
                                                )
                           )
                           AND
                           (
                               P_CD_CENTRO_EXPEDIDOR IS NULL OR CS_.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
                           )
                           AND
                           (
                               P_CD_MACHINE IS NULL OR CS_.CD_CENTRO_EXPEDIDOR IN (
                                                           SELECT CD_CENTRO_EXPEDIDOR
                                                             FROM VND.ELO_AGENDAMENTO_CENTRO_MACHINE CM
                                                            WHERE CM.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                                              AND CM.CD_MACHINE = P_CD_MACHINE
                                                       )
                           )
                       AND CS_.NU_ORDEM_VENDA IS NOT NULL
                     GROUP BY CS_.NU_ORDEM_VENDA
                    HAVING COUNT(CS_.CD_ELO_CARTEIRA_SAP) > 1
                )
        SELECT
                CS.CD_CENTRO_EXPEDIDOR,
                CS.DS_CENTRO_EXPEDIDOR,
                MAX(CS.DH_CARTEIRA) DH_CARTEIRA,
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
                MIN(CS.DH_ENTREGA) DH_ENTREGA,
                CS.SG_ESTADO,
                CS.NO_MUNICIPIO,
                CS.DS_BAIRRO,
                CS.CD_PRODUTO_SAP,
                CS.NO_PRODUTO_SAP,
                SUM(CS.QT_PROGRAMADA) QT_PROGRAMADA,
                SUM(CS.QT_ENTREGUE) QT_ENTREGUE,
                SUM(CS.QT_SALDO) QT_SALDO,
                CS.VL_UNITARIO,
                SUM(CS.VL_BRL) VL_BRL,
                CS.VL_TAXA_DOLAR,
                SUM(CS.VL_USD) VL_USD,
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
                CASE WHEN NVL(MAX(x.qt), 1) > 1 THEN 9999
                    ELSE MAX(CS.CD_ITEM_PEDIDO)
                END CD_ITEM_PEDIDO,
                CS.CD_CLIENTE_PAGADOR,
                CS.NO_CLIENTE_PAGADOR,
                CS.CD_GRUPO_EMBALAGEM,
                CS.DS_CREDIT_BLOCK_REASON,
                CS.DH_CREDIT_BLOCK,
                CS.CD_ITEM_CONTRATO,
                VL_FRETE_DISTRIBUICAO,
                CS.DS_ENDERECO_PAGADOR,
                CS.NO_SALES_DISTRICT,
                -- Following fields do not come from ELO_CARTEIRA_SAP.
                CASE 
                    WHEN CS.NU_ORDEM_VENDA IS NULL OR TRIM(CS.NU_ORDEM_VENDA) = '' THEN 'S'
                    ELSE 'N'
                END IC_SEM_ORDEM_VENDA,             --IC_SEM_ORDEM_VENDA
                CASE 
                    WHEN CR.CD_CLIENTE IS NULL THEN 'N' 
                    ELSE 'S' 
                END IC_RELACIONAMENTO,              --IC_RELACIONAMENTO
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_COOPERATIVE(CS.CD_TIPO_CONTRATO) IC_COOPERATIVE,   -- IC_COOPERATIVE
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_SPLIT(CS.CD_TIPO_CONTRATO) IC_SPLIT,               -- IC_SPLIT
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_FA(CS.CD_TIPO_CONTRATO) IC_FA,                     -- IC_FA
                CS.DS_ROTEIRO_ENTREGA,              --DS_ROTEIRO_ENTREGA
                /*
                Priority option must always follow this sequence:

                Check if it's backlog CIF
                  |---  If not, check if the customer is a relationship customer
                    |---  If not, check if the material is a priority material

                Backlog CIF will come from second INSERT statement below, thus here 
                we only check for Customer Relationship and Priority Material.
                */
                CASE 
                    WHEN CR.CD_CLIENTE IS NOT NULL THEN VND.GX_ELO_AGENDAMENTO.FX_PRIORITY_OPTION(P_CD_ELO_AGENDAMENTO, 'CLIRE') 
                    ELSE 
                        CASE 
                            WHEN PM.CD_PRODUTO_SAP IS NOT NULL THEN VND.GX_ELO_AGENDAMENTO.FX_PRIORITY_OPTION(P_CD_ELO_AGENDAMENTO, 'PRODU')
                            ELSE NULL
                        END
                END CD_ELO_PRIORITY_OPTION,                                                             --CD_ELO_PRIORITY_OPTION
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_EXPORT(CS.CD_TIPO_CONTRATO) IC_EXPORT              --IC_EXPORT

        FROM
                VND.VW_ELO_CARTEIRA_SAP CS
                
                LEFT OUTER JOIN X
                             ON X.NU_ORDEM_VENDA = CS.NU_ORDEM_VENDA

                LEFT OUTER JOIN VND.ELO_AGENDAMENTO_CLI_RELAC CR
                             ON (
                                     CS.CD_INCOTERMS = 'FOB' AND CR.CD_CLIENTE = CS.CD_CLIENTE_PAGADOR
                                     OR
                                     CS.CD_INCOTERMS = 'CIF' AND CR.CD_CLIENTE = CS.CD_CLIENTE_RECEBEDOR
                                )
                            AND CR.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO

                LEFT OUTER JOIN VND.ELO_AGENDAMENTO_PRIO_MATERIAL PM
                             ON PM.CD_PRODUTO_SAP = CS.CD_PRODUTO_SAP
                            AND PM.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                
        WHERE
                CS.NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
                AND
                (
                    P_CD_POLO IS NULL OR CS.CD_CENTRO_EXPEDIDOR IN (
                                         SELECT CD_CENTRO_EXPEDIDOR
                                           FROM VND.ELO_AGENDAMENTO_POLO_CENTRO PC
                                          WHERE PC.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                            AND TRIM(PC.CD_POLO) = TRIM(P_CD_POLO)
                                     )
                )
                AND
                (
                    P_CD_CENTRO_EXPEDIDOR IS NULL OR CS.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
                )
                AND
                (
                    P_CD_MACHINE IS NULL OR CS.CD_CENTRO_EXPEDIDOR IN (
                                                SELECT CD_CENTRO_EXPEDIDOR
                                                  FROM VND.ELO_AGENDAMENTO_CENTRO_MACHINE CM
                                                 WHERE CM.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                                   AND CM.CD_MACHINE = P_CD_MACHINE
                                            )
                )
                
       GROUP BY
                CS.CD_CENTRO_EXPEDIDOR,
                CS.DS_CENTRO_EXPEDIDOR,
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
                CS.SG_ESTADO,
                CS.NO_MUNICIPIO,
                CS.DS_BAIRRO,
                CS.CD_PRODUTO_SAP,
                CS.NO_PRODUTO_SAP,
                CS.VL_UNITARIO,
                CS.VL_TAXA_DOLAR,
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
                CS.CD_CLIENTE_PAGADOR,
                CS.NO_CLIENTE_PAGADOR,
                CS.CD_GRUPO_EMBALAGEM,
                CS.DS_CREDIT_BLOCK_REASON,
                CS.DH_CREDIT_BLOCK,
                CS.CD_ITEM_CONTRATO,
                CS.VL_FRETE_DISTRIBUICAO,
                CS.DS_ENDERECO_PAGADOR,
                CS.NO_SALES_DISTRICT,
                CASE 
                    WHEN CS.NU_ORDEM_VENDA IS NULL OR TRIM(CS.NU_ORDEM_VENDA) = '' THEN 'S'
                    ELSE 'N'
                END,                                                                    --IC_SEM_ORDEM_VENDA
                CASE 
                    WHEN CR.CD_CLIENTE IS NULL THEN 'N' 
                    ELSE 'S' 
                END,                                                                    --IC_RELACIONAMENTO
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_COOPERATIVE(CS.CD_TIPO_CONTRATO),  --IC_COOPERATIVE
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_SPLIT(CS.CD_TIPO_CONTRATO),        --IC_SPLIT
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_FA(CS.CD_TIPO_CONTRATO),           --IC_FA
                CS.DS_ROTEIRO_ENTREGA,                                                  --DS_ROTEIRO_ENTREGA
                CASE 
                    WHEN CR.CD_CLIENTE IS NOT NULL THEN VND.GX_ELO_AGENDAMENTO.FX_PRIORITY_OPTION(P_CD_ELO_AGENDAMENTO, 'CLIRE') 
                    ELSE 
                        CASE 
                            WHEN PM.CD_PRODUTO_SAP IS NOT NULL THEN VND.GX_ELO_AGENDAMENTO.FX_PRIORITY_OPTION(P_CD_ELO_AGENDAMENTO, 'PRODU')
                            ELSE NULL
                        END
                END,                                                                    --CD_ELO_PRIORITY_OPTION
                VND.GX_ELO_AGENDAMENTO.FX_IS_DOCTYPE_EXPORT(CS.CD_TIPO_CONTRATO)        --IC_EXPORT

          --ORDER BY NU_ORDEM_VENDA
        ) Y
        ;

        -- ##### UPDATES PREVIUOS PLANNED QUANTITY #####
        MERGE INTO VND.ELO_CARTEIRA T_DESTINO
        USING
        (
            SELECT DISTINCT
                CA.NU_ORDEM_VENDA,
                CA.CD_ITEM_PEDIDO,
                CA.CD_PRODUTO_SAP,
                NVL(SUM(CA.QT_AGENDADA_CONFIRMADA), 0) QT_AGENDADA_CONFIRMADA

              FROM
                    VND.ELO_CARTEIRA CA

                    LEFT JOIN VND.ELO_AGENDAMENTO_CLI_RELAC CR
                           ON (
                                   CA.CD_INCOTERMS = 'FOB' AND CR.CD_CLIENTE = CA.CD_CLIENTE_PAGADOR
                                   OR
                                   CA.CD_INCOTERMS = 'CIF' AND CR.CD_CLIENTE = CA.CD_CLIENTE_RECEBEDOR
                              )
                          AND CR.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO

             WHERE
                    CA.CD_ELO_AGENDAMENTO = VND.GX_ELO_COMMON.FX_PREVIOUS_SCHEDULING(P_CD_ELO_AGENDAMENTO, P_CD_POLO, P_CD_CENTRO_EXPEDIDOR, P_CD_MACHINE, 1)
                    AND
                    (
                        P_CD_POLO IS NULL OR CA.CD_CENTRO_EXPEDIDOR IN (
                                             SELECT CD_CENTRO_EXPEDIDOR
                                               FROM VND.ELO_AGENDAMENTO_POLO_CENTRO PC
                                              WHERE PC.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                                AND TRIM(PC.CD_POLO) = TRIM(P_CD_POLO)
                                         )
                    )
                    AND
                    (
                        P_CD_CENTRO_EXPEDIDOR IS NULL OR CA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
                    )
                    AND
                    (
                    P_CD_MACHINE IS NULL OR CA.CD_CENTRO_EXPEDIDOR IN (
                                                SELECT CD_CENTRO_EXPEDIDOR
                                                  FROM VND.ELO_AGENDAMENTO_CENTRO_MACHINE CM
                                                 WHERE CM.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                                                   AND CM.CD_MACHINE = P_CD_MACHINE
                                            )
                    )
                    --AND CA.CD_TIPO_AGENDAMENTO = gx_elo_common.fx_elo_status('TIPAG','PLAN')
                    AND (CA.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (CA.CD_TIPO_AGENDAMENTO = 25 AND CA.CD_STATUS_REPLAN = 32))
                    AND CA.CD_STATUS_CEL_FINAL = 59
                    
                    AND CA.IC_ATIVO = 'S'
                    AND CA.NU_ORDEM_VENDA <> 0
                    AND CA.CD_ITEM_PEDIDO <> 0
                    AND NVL(CA.QT_AGENDADA_CONFIRMADA, 0) > 0
               GROUP BY CA.NU_ORDEM_VENDA,
                        CA.CD_ITEM_PEDIDO,
                        CA.CD_PRODUTO_SAP
        ) T_FONTE
        ON (
                    T_DESTINO.NU_ORDEM_VENDA = T_FONTE.NU_ORDEM_VENDA
                AND T_DESTINO.CD_ITEM_PEDIDO = T_FONTE.CD_ITEM_PEDIDO
                AND T_DESTINO.CD_PRODUTO_SAP = T_FONTE.CD_PRODUTO_SAP
                AND T_DESTINO.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
           )
           
        WHEN MATCHED THEN 
            UPDATE SET
                   T_DESTINO.QT_AGENDADA_ANTERIOR = T_FONTE.QT_AGENDADA_CONFIRMADA
        ;

--        
--        -- ##### COPY BACKLOG CIF FROM PREVIOUS SCHEDULLING #####
--        MERGE INTO VND.ELO_CARTEIRA T_DESTINO
--        USING
--        (
--            SELECT DISTINCT
--                CA.CD_CENTRO_EXPEDIDOR,
--                CA.DS_CENTRO_EXPEDIDOR,
--                MAX(CA.DH_CARTEIRA) DH_CARTEIRA,
--                CA.CD_SALES_ORG,
--                CA.NU_CONTRATO_SAP,
--                CA.CD_TIPO_CONTRATO,
--                CA.NU_CONTRATO_SUBSTITUI,
--                CA.DT_PAGO,
--                CA.NU_CONTRATO,
--                CA.NU_ORDEM_VENDA,
--                CA.DS_STATUS_CONTRATO_SAP,
--                CA.CD_CLIENTE,
--                CA.NO_CLIENTE,
--                CA.CD_INCOTERMS,
--                CA.CD_SALES_DISTRICT,
--                CA.CD_SALES_OFFICE,
--                CA.NO_SALES_OFFICE,
--                CA.CD_SALES_GROUP,
--                CA.NO_SALES_GROUP,
--                CA.CD_AGENTE_VENDA,
--                CA.NO_AGENTE,
--                CA.DH_VENCIMENTO_PEDIDO,
--                CA.DT_CREDITO,
--                CA.DT_INICIO,
--                CA.DT_FIM,
--                CA.DH_INCLUSAO,
--                CA.DH_ENTREGA,
--                CA.SG_ESTADO,
--                CA.NO_MUNICIPIO,
--                CA.DS_BAIRRO,
--                CA.CD_PRODUTO_SAP,
--                CA.NO_PRODUTO_SAP,
--                CA.QT_PROGRAMADA,
--                CA.QT_ENTREGUE,
--                CA.QT_SALDO,
--                CA.VL_UNITARIO,
--                CA.VL_BRL,
--                CA.VL_TAXA_DOLAR,
--                CA.VL_USD,
--                CA.PC_COMISSAO,
--                CA.CD_SACARIA,
--                CA.DS_SACARIA,
--                CA.CD_CULTURA_SAP,
--                CA.DS_CULTURA_SAP,
--                CA.CD_BLOQUEIO_REMESSA,
--                CA.CD_BLOQUEIO_FATURAMENTO,
--                CA.CD_BLOQUEIO_CREDITO,
--                CA.CD_BLOQUEIO_REMESSA_ITEM,
--                CA.CD_BLOQUEIO_FATURAMENTO_ITEM,
--                CA.CD_MOTIVO_RECUSA,
--                CA.CD_LOGIN,
--                CA.CD_SEGMENTACAO_CLIENTE,
--                CA.DS_SEGMENTACAO_CLIENTE,
--                CA.DS_SEGMENTO_CLIENTE_SAP,
--                CA.CD_FORMA_PAGAMENTO,
--                CA.CD_TIPO_PAGAMENTO,
--                CA.DS_TIPO_PAGAMENTO,
--                CA.CD_AGRUPAMENTO,
--                CA.CD_BLOQUEIO_ENTREGA,
--                CA.NU_CNPJ,
--                CA.NU_CPF,
--                CA.NU_INSCRICAO_ESTADUAL,
--                CA.NU_INSCRICAO_MUNICIPAL,
--                CA.NU_CEP,
--                CA.DS_ENDERECO_RECEBEDOR,
--                CA.CD_CLIENTE_RECEBEDOR,
--                CA.NO_CLIENTE_RECEBEDOR,
--                CA.CD_MOEDA,
--                CA.CD_SUPPLY_GROUP,
--                CA.DS_VENDA_COMPARTILHADA,
--                CA.CD_STATUS_LIBERACAO,
--                CA.CD_ITEM_PEDIDO,
--                CA.CD_CLIENTE_PAGADOR,
--                CA.NO_CLIENTE_PAGADOR,
--                CA.CD_GRUPO_EMBALAGEM,
--                CA.DS_CREDIT_BLOCK_REASON,
--                CA.DH_CREDIT_BLOCK,
--                CA.CD_ITEM_CONTRATO,
--                CA.VL_FRETE_DISTRIBUICAO,
--                CA.DS_ENDERECO_PAGADOR,
--                CA.NO_SALES_DISTRICT,
--                -- Following fields do not exist in ELO_CARTEIRA_SAP.
--                CA.IC_SEM_ORDEM_VENDA,
--                CASE 
--                    WHEN CR.CD_CLIENTE IS NULL THEN 'N' 
--                    ELSE 'S' 
--                END IC_RELACIONAMENTO,
--                CA.QT_BACKLOG_CIF,          --qt_agendada,
--                CA.QT_AGENDADA_CONFIRMADA,  --qt_agendada_anterior,
--                CA.IC_COOPERATIVE,
--                CA.IC_SPLIT,
--                CA.IC_FA,
--                CA.DS_ROTEIRO_ENTREGA
--
--              FROM
--                    VND.ELO_CARTEIRA CA
--
--                    LEFT JOIN VND.ELO_AGENDAMENTO_CLI_RELAC CR
--                           ON (
--                                   CA.CD_INCOTERMS = 'FOB' AND CR.CD_CLIENTE = CA.CD_CLIENTE_PAGADOR
--                                   OR
--                                   CA.CD_INCOTERMS = 'CIF' AND CR.CD_CLIENTE = CA.CD_CLIENTE_RECEBEDOR
--                              )
--                          AND CR.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--
--             WHERE
--                    CA.CD_ELO_AGENDAMENTO = VND.GX_ELO_COMMON.FX_PREVIOUS_SCHEDULING(P_CD_ELO_AGENDAMENTO, P_CD_POLO, P_CD_CENTRO_EXPEDIDOR, P_CD_MACHINE, 1)
--                    AND
--                    (
--                        P_CD_POLO IS NULL OR CA.CD_CENTRO_EXPEDIDOR IN (
--                                             SELECT CD_CENTRO_EXPEDIDOR
--                                               FROM VND.ELO_AGENDAMENTO_POLO_CENTRO PC
--                                              WHERE PC.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--                                                AND TRIM(PC.CD_POLO) = TRIM(P_CD_POLO)
--                                         )
--                    )
--                    AND
--                    (
--                        P_CD_CENTRO_EXPEDIDOR IS NULL OR CA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
--                    )
--                    AND
--                    (
--                    P_CD_MACHINE IS NULL OR CA.CD_CENTRO_EXPEDIDOR IN (
--                                                SELECT CD_CENTRO_EXPEDIDOR
--                                                  FROM VND.ELO_AGENDAMENTO_CENTRO_MACHINE CM
--                                                 WHERE CM.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--                                                   AND CM.CD_MACHINE = P_CD_MACHINE
--                                            )
--                    )
--                    AND CA.SG_DESTINO_BACKLOG_CIF = 'ZCSHIP'
--                    AND CA.IC_ATIVO = 'S'
--                    AND TRIM(CA.NU_ORDEM_VENDA) <> '0'
--                    AND CA.CD_ITEM_PEDIDO <> 0
--                    
--          GROUP BY  CA.CD_CENTRO_EXPEDIDOR,
--                    CA.DS_CENTRO_EXPEDIDOR,
--                    CA.CD_SALES_ORG,
--                    CA.NU_CONTRATO_SAP,
--                    CA.CD_TIPO_CONTRATO,
--                    CA.NU_CONTRATO_SUBSTITUI,
--                    CA.DT_PAGO,
--                    CA.NU_CONTRATO,
--                    CA.NU_ORDEM_VENDA,
--                    CA.DS_STATUS_CONTRATO_SAP,
--                    CA.CD_CLIENTE,
--                    CA.NO_CLIENTE,
--                    CA.CD_INCOTERMS,
--                    CA.CD_SALES_DISTRICT,
--                    CA.CD_SALES_OFFICE,
--                    CA.NO_SALES_OFFICE,
--                    CA.CD_SALES_GROUP,
--                    CA.NO_SALES_GROUP,
--                    CA.CD_AGENTE_VENDA,
--                    CA.NO_AGENTE,
--                    CA.DH_VENCIMENTO_PEDIDO,
--                    CA.DT_CREDITO,
--                    CA.DT_INICIO,
--                    CA.DT_FIM,
--                    CA.DH_INCLUSAO,
--                    CA.DH_ENTREGA,
--                    CA.SG_ESTADO,
--                    CA.NO_MUNICIPIO,
--                    CA.DS_BAIRRO,
--                    CA.CD_PRODUTO_SAP,
--                    CA.NO_PRODUTO_SAP,
--                    CA.QT_PROGRAMADA,
--                    CA.QT_ENTREGUE,
--                    CA.QT_SALDO,
--                    CA.VL_UNITARIO,
--                    CA.VL_BRL,
--                    CA.VL_TAXA_DOLAR,
--                    CA.VL_USD,
--                    CA.PC_COMISSAO,
--                    CA.CD_SACARIA,
--                    CA.DS_SACARIA,
--                    CA.CD_CULTURA_SAP,
--                    CA.DS_CULTURA_SAP,
--                    CA.CD_BLOQUEIO_REMESSA,
--                    CA.CD_BLOQUEIO_FATURAMENTO,
--                    CA.CD_BLOQUEIO_CREDITO,
--                    CA.CD_BLOQUEIO_REMESSA_ITEM,
--                    CA.CD_BLOQUEIO_FATURAMENTO_ITEM,
--                    CA.CD_MOTIVO_RECUSA,
--                    CA.CD_LOGIN,
--                    CA.CD_SEGMENTACAO_CLIENTE,
--                    CA.DS_SEGMENTACAO_CLIENTE,
--                    CA.DS_SEGMENTO_CLIENTE_SAP,
--                    CA.CD_FORMA_PAGAMENTO,
--                    CA.CD_TIPO_PAGAMENTO,
--                    CA.DS_TIPO_PAGAMENTO,
--                    CA.CD_AGRUPAMENTO,
--                    CA.CD_BLOQUEIO_ENTREGA,
--                    CA.NU_CNPJ,
--                    CA.NU_CPF,
--                    CA.NU_INSCRICAO_ESTADUAL,
--                    CA.NU_INSCRICAO_MUNICIPAL,
--                    CA.NU_CEP,
--                    CA.DS_ENDERECO_RECEBEDOR,
--                    CA.CD_CLIENTE_RECEBEDOR,
--                    CA.NO_CLIENTE_RECEBEDOR,
--                    CA.CD_MOEDA,
--                    CA.CD_SUPPLY_GROUP,
--                    CA.DS_VENDA_COMPARTILHADA,
--                    CA.CD_STATUS_LIBERACAO,
--                    CA.CD_ITEM_PEDIDO,
--                    CA.CD_CLIENTE_PAGADOR,
--                    CA.NO_CLIENTE_PAGADOR,
--                    CA.CD_GRUPO_EMBALAGEM,
--                    CA.DS_CREDIT_BLOCK_REASON,
--                    CA.DH_CREDIT_BLOCK,
--                    CA.CD_ITEM_CONTRATO,
--                    CA.VL_FRETE_DISTRIBUICAO,
--                    CA.DS_ENDERECO_PAGADOR,
--                    CA.NO_SALES_DISTRICT,
--                    CA.IC_SEM_ORDEM_VENDA,
--                    CASE 
--                        WHEN CR.CD_CLIENTE IS NULL THEN 'N' 
--                        ELSE 'S' 
--                    END,
--                    CA.QT_BACKLOG_CIF,
--                    CA.QT_AGENDADA_CONFIRMADA,
--                    CA.IC_COOPERATIVE,
--                    CA.IC_SPLIT,
--                    CA.IC_FA,
--                    CA.DS_ROTEIRO_ENTREGA
--        ) T_FONTE
--        ON (
--                    T_DESTINO.NU_ORDEM_VENDA = T_FONTE.NU_ORDEM_VENDA
--                AND T_DESTINO.CD_ITEM_PEDIDO = T_FONTE.CD_ITEM_PEDIDO
--                AND T_DESTINO.CD_PRODUTO_SAP = T_FONTE.CD_PRODUTO_SAP
--                AND T_DESTINO.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--           )
--           
--        WHEN MATCHED THEN 
--            UPDATE SET
--                   T_DESTINO.CD_STATUS_BACKLOG_CIF = gx_elo_common.fx_elo_status('BLCIF','FOUND'),
--                   T_DESTINO.QT_BACKLOG_CIF = T_FONTE.QT_AGENDADA_CONFIRMADA
--                   
--        WHEN NOT MATCHED THEN
--            INSERT (
--            /*001*/    CD_ELO_CARTEIRA,
--            /*002*/    CD_CENTRO_EXPEDIDOR,
--            /*003*/    DS_CENTRO_EXPEDIDOR,
--            /*004*/    DH_CARTEIRA,
--            /*005*/    CD_SALES_ORG,
--            /*006*/    NU_CONTRATO_SAP,
--            /*007*/    CD_TIPO_CONTRATO,
--            /*008*/    NU_CONTRATO_SUBSTITUI,
--            /*009*/    DT_PAGO,
--            /*010*/    NU_CONTRATO,
--            /*011*/    NU_ORDEM_VENDA,
--            /*012*/    DS_STATUS_CONTRATO_SAP,
--            /*013*/    CD_CLIENTE,
--            /*014*/    NO_CLIENTE,
--            /*015*/    CD_INCOTERMS,
--            /*016*/    CD_SALES_DISTRICT,
--            /*017*/    CD_SALES_OFFICE,
--            /*018*/    NO_SALES_OFFICE,
--            /*019*/    CD_SALES_GROUP,
--            /*020*/    NO_SALES_GROUP,
--            /*021*/    CD_AGENTE_VENDA,
--            /*022*/    NO_AGENTE,
--            /*023*/    DH_VENCIMENTO_PEDIDO,
--            /*024*/    DT_CREDITO,
--            /*025*/    DT_INICIO,
--            /*026*/    DT_FIM,
--            /*027*/    DH_INCLUSAO,
--            /*028*/    DH_ENTREGA,
--            /*029*/    SG_ESTADO,
--            /*030*/    NO_MUNICIPIO,
--            /*031*/    DS_BAIRRO,
--            /*032*/    CD_PRODUTO_SAP,
--            /*033*/    NO_PRODUTO_SAP,
--            /*034*/    QT_PROGRAMADA,
--            /*035*/    QT_ENTREGUE,
--            /*036*/    QT_SALDO,
--            /*037*/    VL_UNITARIO,
--            /*038*/    VL_BRL,
--            /*039*/    VL_TAXA_DOLAR,
--            /*040*/    VL_USD,
--            /*041*/    PC_COMISSAO,
--            /*042*/    CD_SACARIA,
--            /*043*/    DS_SACARIA,
--            /*044*/    CD_CULTURA_SAP,
--            /*045*/    DS_CULTURA_SAP,
--            /*046*/    CD_BLOQUEIO_REMESSA,
--            /*047*/    CD_BLOQUEIO_FATURAMENTO,
--            /*048*/    CD_BLOQUEIO_CREDITO,
--            /*049*/    CD_BLOQUEIO_REMESSA_ITEM,
--            /*050*/    CD_BLOQUEIO_FATURAMENTO_ITEM,
--            /*051*/    CD_MOTIVO_RECUSA,
--            /*052*/    CD_LOGIN,
--            /*053*/    CD_SEGMENTACAO_CLIENTE,
--            /*054*/    DS_SEGMENTACAO_CLIENTE,
--            /*055*/    DS_SEGMENTO_CLIENTE_SAP,
--            /*056*/    CD_FORMA_PAGAMENTO,
--            /*057*/    CD_TIPO_PAGAMENTO,
--            /*058*/    DS_TIPO_PAGAMENTO,
--            /*059*/    CD_AGRUPAMENTO,
--            /*060*/    CD_BLOQUEIO_ENTREGA,
--            /*061*/    NU_CNPJ,
--            /*062*/    NU_CPF,
--            /*063*/    NU_INSCRICAO_ESTADUAL,
--            /*064*/    NU_INSCRICAO_MUNICIPAL,
--            /*065*/    NU_CEP,
--            /*066*/    DS_ENDERECO_RECEBEDOR,
--            /*067*/    CD_CLIENTE_RECEBEDOR,
--            /*068*/    NO_CLIENTE_RECEBEDOR,
--            /*069*/    CD_MOEDA,
--            /*070*/    CD_SUPPLY_GROUP,
--            /*071*/    DS_VENDA_COMPARTILHADA,
--            /*072*/    CD_STATUS_LIBERACAO,
--            /*073*/    CD_ITEM_PEDIDO,
--            /*074*/    CD_CLIENTE_PAGADOR,
--            /*075*/    NO_CLIENTE_PAGADOR,
--            /*076*/    CD_GRUPO_EMBALAGEM,
--            /*077*/    DS_CREDIT_BLOCK_REASON,
--            /*078*/    DH_CREDIT_BLOCK,
--            /*079*/    CD_ITEM_CONTRATO,
--            /*080*/    VL_FRETE_DISTRIBUICAO,
--            /*081*/    DS_ENDERECO_PAGADOR,
--            /*082*/    NO_SALES_DISTRICT,
--                       -- Following fields do not exist in ELO_CARTEIRA_SAP.
--            /*083*/    CD_ELO_AGENDAMENTO_ITEM,
--            /*084*/    IC_SEM_ORDEM_VENDA,
--            /*085*/    IC_RELACIONAMENTO,
--            /*086*/    NU_ORDEM,
--            /*087*/    QT_AGENDADA,
--            /*088*/    QT_AGENDADA_FABRICA,
--            /*089*/    QT_AGENDADA_SAP,
--            /*090*/    CD_USUARIO_REFRESH,
--            /*091*/    DH_REFRESH,
--            /*092*/    QT_PROGRAMADA_REFRESH,
--            /*093*/    QT_ENTREGUE_REFRESH,
--            /*094*/    QT_SALDO_REFRESH,
--            /*095*/    QT_AGENDADA_CONFIRMADA,
--            /*096*/    CD_TIPO_AGENDAMENTO,
--            /*097*/    CD_TIPO_REPLAN,
--            /*098*/    CD_BLOQUEIO_REMESSA_R,
--            /*099*/    CD_BLOQUEIO_FATURAMENTO_R,
--            /*100*/    CD_BLOQUEIO_CREDITO_R,
--            /*101*/    CD_BLOQUEIO_REMESSA_ITEM_R,
--            /*102*/    CD_BLOQUEIO_FATURAMENTO_ITEM_R,
--            /*103*/    DS_OBSERVACAO_ADVEN,
--            /*104*/    IC_PERMITIR_CS,
--            /*105*/    DH_LIBERACAO_TORRE_FRETES,
--            /*106*/    DH_MODIFICACAO_TORRE_FRETES,
--            /*107*/    DH_CONTRATACAO_TORRE_FRETES,
--            /*108*/    CD_ELO_FREIGHT_TOWER_REASON,
--            /*109*/    VL_FRETE_CONTRATADO,
--            /*110*/    IC_NAO_LIBERADA_SEM_PROTOCOLO,
--            /*111*/    IC_ENTREGA_CADENCIADA_CLIENTE,
--            /*112*/    IC_DIFICULDADE_CONTRATACAO,
--            /*113*/    IC_OUTROS,
--            /*114*/    CD_STATUS_CUSTOMER_SERVICE,
--            /*115*/    CD_STATUS_TORRE_FRETES,
--            /*116*/    CD_STATUS_CONTROLADORIA,
--            /*117*/    IC_ATIVO,
--            /*118*/    SG_DESTINO_BACKLOG_CIF,
--            /*119*/    CD_STATUS_BACKLOG_CIF,
--            /*120*/    QT_AGENDADA_ANTERIOR,
--            /*121*/    DH_BACKLOG_CIF,
--            /*122*/    QT_BACKLOG_CIF,
--            /*123*/    CD_ELO_AGENDAMENTO,
--            /*124*/    QT_AGENDADA_REFRESH,
--            /*125*/    CD_USUARIO_FABRICA,
--            /*126*/    DH_FABRICA,
--            /*127*/    CD_USUARIO_CORTADO_FABRICA,
--            /*128*/    DH_CORTADO_FABRICA,
--            /*129*/    CD_USUARIO_AJUSTE_SAP,
--            /*130*/    DH_AJUSTE_SAP,
--            /*131*/    CD_STATUS_LOGISTICA,
--            /*132*/    IC_CORTADO_FABRICA,
--            /*133*/    IC_COOPERATIVE,
--            /*134*/    IC_SPLIT,
--            /*135*/    IC_FA,
--            /*136*/    IC_EMERGENCIAL,
--            /*137*/    DS_ROTEIRO_ENTREGA,
--            /*138*/    CD_ELO_PRIORITY_OPTION,
--            /*139*/    QT_AJUSTADA_FABRICA,
--            /*140*/    QT_AJUSTADA_SAP,
--            /*141*/    IC_EXPORT,
--            /*142*/    DS_CREDIT_BLOCK_REASON_R,
--            /*143*/    CD_STATUS_CEL_INITIAL,
--            /*144*/    CD_STATUS_CEL_FINAL
--            ) VALUES ( ---------------------------------------------------------
--            /*001*/    VND.SEQ_ELO_CARTEIRA.NEXTVAL,
--            /*002*/    T_FONTE.CD_CENTRO_EXPEDIDOR,
--            /*003*/    T_FONTE.DS_CENTRO_EXPEDIDOR,
--            /*004*/    T_FONTE.DH_CARTEIRA,
--            /*005*/    T_FONTE.CD_SALES_ORG,
--            /*006*/    T_FONTE.NU_CONTRATO_SAP,
--            /*007*/    T_FONTE.CD_TIPO_CONTRATO,
--            /*008*/    T_FONTE.NU_CONTRATO_SUBSTITUI,
--            /*009*/    T_FONTE.DT_PAGO,
--            /*010*/    T_FONTE.NU_CONTRATO,
--            /*011*/    T_FONTE.NU_ORDEM_VENDA,
--            /*012*/    T_FONTE.DS_STATUS_CONTRATO_SAP,
--            /*013*/    T_FONTE.CD_CLIENTE,
--            /*014*/    T_FONTE.NO_CLIENTE,
--            /*015*/    T_FONTE.CD_INCOTERMS,
--            /*016*/    T_FONTE.CD_SALES_DISTRICT,
--            /*017*/    T_FONTE.CD_SALES_OFFICE,
--            /*018*/    T_FONTE.NO_SALES_OFFICE,
--            /*019*/    T_FONTE.CD_SALES_GROUP,
--            /*020*/    T_FONTE.NO_SALES_GROUP,
--            /*021*/    T_FONTE.CD_AGENTE_VENDA,
--            /*022*/    T_FONTE.NO_AGENTE,
--            /*023*/    T_FONTE.DH_VENCIMENTO_PEDIDO,
--            /*024*/    T_FONTE.DT_CREDITO,
--            /*025*/    T_FONTE.DT_INICIO,
--            /*026*/    T_FONTE.DT_FIM,
--            /*027*/    T_FONTE.DH_INCLUSAO,
--            /*028*/    T_FONTE.DH_ENTREGA,
--            /*029*/    T_FONTE.SG_ESTADO,
--            /*030*/    T_FONTE.NO_MUNICIPIO,
--            /*031*/    T_FONTE.DS_BAIRRO,
--            /*032*/    T_FONTE.CD_PRODUTO_SAP,
--            /*033*/    T_FONTE.NO_PRODUTO_SAP,
--            /*034*/    T_FONTE.QT_PROGRAMADA,
--            /*035*/    T_FONTE.QT_ENTREGUE,
--            /*036*/    T_FONTE.QT_SALDO,
--            /*037*/    T_FONTE.VL_UNITARIO,
--            /*038*/    T_FONTE.VL_BRL,
--            /*039*/    T_FONTE.VL_TAXA_DOLAR,
--            /*040*/    T_FONTE.VL_USD,
--            /*041*/    T_FONTE.PC_COMISSAO,
--            /*042*/    T_FONTE.CD_SACARIA,
--            /*043*/    T_FONTE.DS_SACARIA,
--            /*044*/    T_FONTE.CD_CULTURA_SAP,
--            /*045*/    T_FONTE.DS_CULTURA_SAP,
--            /*046*/    T_FONTE.CD_BLOQUEIO_REMESSA,
--            /*047*/    T_FONTE.CD_BLOQUEIO_FATURAMENTO,
--            /*048*/    T_FONTE.CD_BLOQUEIO_CREDITO,
--            /*049*/    T_FONTE.CD_BLOQUEIO_REMESSA_ITEM,
--            /*050*/    T_FONTE.CD_BLOQUEIO_FATURAMENTO_ITEM,
--            /*051*/    T_FONTE.CD_MOTIVO_RECUSA,
--            /*052*/    T_FONTE.CD_LOGIN,
--            /*053*/    T_FONTE.CD_SEGMENTACAO_CLIENTE,
--            /*054*/    T_FONTE.DS_SEGMENTACAO_CLIENTE,
--            /*055*/    T_FONTE.DS_SEGMENTO_CLIENTE_SAP,
--            /*056*/    T_FONTE.CD_FORMA_PAGAMENTO,
--            /*057*/    T_FONTE.CD_TIPO_PAGAMENTO,
--            /*058*/    T_FONTE.DS_TIPO_PAGAMENTO,
--            /*059*/    T_FONTE.CD_AGRUPAMENTO,
--            /*060*/    T_FONTE.CD_BLOQUEIO_ENTREGA,
--            /*061*/    T_FONTE.NU_CNPJ,
--            /*062*/    T_FONTE.NU_CPF,
--            /*063*/    T_FONTE.NU_INSCRICAO_ESTADUAL,
--            /*064*/    T_FONTE.NU_INSCRICAO_MUNICIPAL,
--            /*065*/    T_FONTE.NU_CEP,
--            /*066*/    T_FONTE.DS_ENDERECO_RECEBEDOR,
--            /*067*/    T_FONTE.CD_CLIENTE_RECEBEDOR,
--            /*068*/    T_FONTE.NO_CLIENTE_RECEBEDOR,
--            /*069*/    T_FONTE.CD_MOEDA,
--            /*070*/    T_FONTE.CD_SUPPLY_GROUP,
--            /*071*/    T_FONTE.DS_VENDA_COMPARTILHADA,
--            /*072*/    T_FONTE.CD_STATUS_LIBERACAO,
--            /*073*/    T_FONTE.CD_ITEM_PEDIDO,
--            /*074*/    T_FONTE.CD_CLIENTE_PAGADOR,
--            /*075*/    T_FONTE.NO_CLIENTE_PAGADOR,
--            /*076*/    T_FONTE.CD_GRUPO_EMBALAGEM,
--            /*077*/    T_FONTE.DS_CREDIT_BLOCK_REASON,
--            /*078*/    T_FONTE.DH_CREDIT_BLOCK,
--            /*079*/    T_FONTE.CD_ITEM_CONTRATO,
--            /*080*/    T_FONTE.VL_FRETE_DISTRIBUICAO,
--            /*081*/    T_FONTE.DS_ENDERECO_PAGADOR,
--            /*082*/    T_FONTE.NO_SALES_DISTRICT,
--                -- Following fields do not exist in ELO_CARTEIRA_SAP.
--            /*083*/    NULL,                            --cd_elo_agendamento_item,
--            /*084*/    T_FONTE.IC_SEM_ORDEM_VENDA,      
--            /*085*/    T_FONTE.IC_RELACIONAMENTO,       
--            /*086*/    NULL,                            --nu_ordem,
--            /*087*/    T_FONTE.QT_BACKLOG_CIF,          --qt_agendada,
--            /*088*/    NULL,                            --qt_agendada_fabrica,
--            /*089*/    NULL,                            --qt_agendada_sap,
--            /*090*/    NULL,                            --cd_usuario_refresh,
--            /*091*/    NULL,                            --dh_refresh,
--            /*092*/    NULL,                            --qt_programada_refresh,
--            /*093*/    NULL,                            --qt_entregue_refresh,
--            /*094*/    NULL,                            --qt_saldo_refresh,
--            /*095*/    NULL,                            --qt_agendada_confirmada,
--            /*096*/    NULL,                            --cd_tipo_agendamento,
--            /*097*/    NULL,                            --cd_tipo_replan,
--            /*098*/    NULL,                            --cd_bloqueio_remessa_r,
--            /*099*/    NULL,                            --cd_bloqueio_faturamento_r,
--            /*100*/    NULL,                            --cd_bloqueio_credito_r,
--            /*101*/    NULL,                            --cd_bloqueio_remessa_item_r,
--            /*102*/    NULL,                            --cd_bloqueio_faturamento_item_r,
--            /*103*/    NULL,                            --ds_observacao_adven,
--            /*104*/    NULL,                            --ic_permitir_cs,
--            /*105*/    NULL,                            --dh_liberacao_torre_fretes,
--            /*106*/    NULL,                            --dh_modificacao_torre_fretes,
--            /*107*/    NULL,                            --dh_contratacao_torre_fretes,
--            /*108*/    NULL,                            --cd_elo_freight_tower_reason,
--            /*109*/    NULL,                            --vl_frete_contratado,
--            /*110*/    NULL,                            --ic_nao_liberada_sem_protocolo,
--            /*111*/    NULL,                            --ic_entrega_cadenciada_cliente,
--            /*112*/    NULL,                            --ic_dificuldade_contratacao,
--            /*113*/    NULL,                            --ic_outros,
--            /*114*/    NULL,                            --cd_status_customer_service,
--            /*115*/    NULL,                            --cd_status_torre_fretes,
--            /*116*/    NULL,                            --cd_status_controladoria,
--            /*117*/    'S',                             --ic_ativo,
--            /*118*/    NULL,                            --sg_destino_backlog_cif,
--            /*119*/    GX_ELO_AGENDAMENTO.FX_STATUS_BACKLOG_CIF(P_NU_CARTEIRA_VERSION, T_FONTE.NU_ORDEM_VENDA, T_FONTE.CD_PRODUTO_SAP), --cd_status_backlog_cif
--            /*120*/    NULL,                            --qt_agendada_anterior,
--            /*121*/    NULL,                            --dh_backlog_cif
--            /*122*/    T_FONTE.QT_AGENDADA_CONFIRMADA,  --qt_backlog_cif,
--            /*123*/    P_CD_ELO_AGENDAMENTO,            --cd_elo_agendamento,
--            /*124*/    NULL,                            --qt_agendada_refresh,
--            /*125*/    NULL,                            --cd_usuario_fabrica,
--            /*126*/    NULL,                            --dh_fabrica,
--            /*127*/    NULL,                            --cd_usuario_cortado_fabrica,
--            /*128*/    NULL,                            --dh_cortado_fabrica,
--            /*129*/    NULL,                            --cd_usuario_ajuste_sap,
--            /*130*/    NULL,                            --dh_ajuste_sap,
--            /*131*/    NULL,                            --cd_status_logistica,
--            /*132*/    NULL,                            --ic_cortado_fabrica,
--            /*133*/    T_FONTE.IC_COOPERATIVE,
--            /*134*/    T_FONTE.IC_SPLIT,
--            /*135*/    T_FONTE.IC_FA,
--            /*136*/    NULL,                            --ic_emergencial,
--            /*137*/    T_FONTE.DS_ROTEIRO_ENTREGA,
--                       /*
--                       Priority option must always follow this sequence:
--
--                       Check if it's backlog CIF
--                         |---  If not, check if the customer is a relationship customer
--                           |---  If not, check if the material is a priority material
--
--                       As here we are copying backlog CIF from previous documents portfolio,
--                       and backlog CIF is the first option to check, we already mark this
--                       as Backlog CIF.
--                       */
--            /*138*/    GX_ELO_AGENDAMENTO.FX_PRIORITY_OPTION(P_CD_ELO_AGENDAMENTO, 'BACKL'), --cd_elo_priority_option,
--            /*139*/    NULL,                            --qt_ajustada_fabrica,
--            /*140*/    NULL,                            --qt_ajustada_sap
--            /*141*/    NULL,                            --ic_export,
--            /*142*/    NULL,                            --ds_credit_block_reason_r,
--            /*143*/    NULL,                            --cd_status_cel_initial,
--            /*144*/    NULL                             --cd_status_cel_final
--            )
--        ;
--



        -- "ELO Project - [27, 32] 'Agendamento' spec V5.doc"
        -- Pg 17
        -- NU_ORDEM: Right after filling field CD_ELO_PRIORITY_OPTION with 
        -- priority types put them in the correct ascending sequence (regarding 
        -- priority definitions at ELO_AGENDAMENTO_PRIO_PANEL, 
        -- ELO_AGENDAMENTO_PRIO_MATERIAL, FIFO for contract number and 
        -- considering first records with IC_SEM_ORDEM_VENDA = ‘N’) and assigns 
        -- a sequential number here, until it completes all records on 
        -- ELO_CARTEIRA grouped with same CD_ELO_AGENDAMENTO.

        -- Update carteira items order according to Priority Panel and FIFO.
        -- FIFO: First items who have sales order number, ordered by it, ascending;
        --       Then those who does not have sales order number, order by SAP 
        --       contract number, ascending.
        MERGE INTO VND.ELO_CARTEIRA T1
        USING
        (
            SELECT X.CD_ELO_CARTEIRA, ROWNUM AS ORDEM FROM (
                SELECT CA.CD_ELO_CARTEIRA,
                       CA.CD_ELO_AGENDAMENTO,
                       CA.CD_ELO_PRIORITY_OPTION,
                       PP.NU_ORDER,
                       CA.NU_ORDEM_VENDA,
                       TO_NUMBER(CASE WHEN CA.NU_ORDEM_VENDA IS NULL THEN 2 ELSE 1 END) OV,
                       CA.NU_CONTRATO_SAP

                  FROM VND.ELO_CARTEIRA CA

                  LEFT OUTER JOIN VND.ELO_AGENDAMENTO_PRIO_PANEL PP
                    ON PP.CD_ELO_PRIORITY_OPTION = CA.CD_ELO_PRIORITY_OPTION
                   AND PP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO

                  LEFT OUTER JOIN ELO_AGENDAMENTO_PRIO_MATERIAL AM
                    ON CA.CD_PRODUTO_SAP = AM.CD_PRODUTO_SAP
                   AND AM.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO

                 WHERE CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO

                 ORDER BY PP.NU_ORDER,
                          AM.NU_ORDER,
                          TO_NUMBER(CASE WHEN CA.IC_SEM_ORDEM_VENDA = 'S' THEN 2 ELSE 1 END),
                          TO_NUMBER(TRIM(CA.NU_ORDEM_VENDA)),
                          TO_NUMBER(TRIM(CA.NU_CONTRATO_SAP))
            ) X
        ) T2
        ON (T1.CD_ELO_CARTEIRA = T2.CD_ELO_CARTEIRA)
        WHEN MATCHED THEN UPDATE SET
        T1.NU_ORDEM = T2.ORDEM
        ;

    EXCEPTION
        WHEN OTHERS THEN
            BEGIN RAISE_APPLICATION_ERROR(-20001, 'PI_COPY_PORTFOLIO - ERRO ENCONTRADO - '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM
                );
                ROLLBACK;
            END;

    END PI_COPY_PORTFOLIO;



    PROCEDURE PI_AGENDAMENTO_SUPERVISOR (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
    )
    IS
        v_dt_week_start                 vnd.elo_agendamento.dt_week_start%TYPE;
        v_site_id                       CHAR(4);
        v_site_type                     CHAR(4);
    BEGIN   
        SELECT ag.dt_week_start,
               CASE 
                   WHEN ag.cd_polo IS NOT NULL THEN ag.cd_polo
                   WHEN ag.cd_centro_expedidor IS NOT NULL THEN ag.cd_centro_expedidor
                   WHEN ag.cd_machine IS NOT NULL THEN ag.cd_machine
               END SiteId,
               CASE 
                    WHEN ag.cd_polo IS NOT NULL THEN 'P'
                    WHEN ag.cd_centro_expedidor IS NOT NULL THEN 'C'
                    WHEN ag.cd_machine IS NOT NULL THEN 'M'
               END SiteType
          INTO v_dt_week_start, v_site_id, v_site_type
          FROM vnd.elo_agendamento ag
         WHERE ag.cd_elo_agendamento = p_cd_elo_agendamento
        ;    

        INSERT INTO VND.ELO_AGENDAMENTO_SUPERVISOR (
            CD_ELO_AGENDAMENTO_SUPERVISOR, 
            CD_ELO_AGENDAMENTO, 
            CD_ELO_STATUS, 
            CD_SALES_DISTRICT, 
            CD_SALES_OFFICE, 
            CD_SALES_GROUP, 
            CD_USUARIO_COTA_AJUSTADA, 
            CD_USUARIO_FECHAMENTO, 
            DH_COTA_AJUSTADA, 
            DH_FECHAMENTO, 
            IC_ATIVO, 
            QT_COTA, 
            QT_COTA_AJUSTADA, 
            QT_FORECAST
        )
        SELECT SEQ_ELO_AGEND_SUPERVISOR.NEXTVAL,
               P_CD_ELO_AGENDAMENTO,
               VND.GX_ELO_COMMON.FX_ELO_STATUS('AGSUP', 'ASNEW'),
               EC.CD_SALES_DISTRICT,
               EC.CD_SALES_OFFICE,
               EC.CD_SALES_GROUP,
               NULL,       /* CD_USUARIO_COTA_AJUSTADA */
               NULL,       /* CD_USUARIO_FECHAMENTO */
               NULL,       /* DH_COTA_AJUSTADA */
               NULL,       /* DH_FECHAMENTO */
               'S',        /* IC_ATIVO */
               gx_elo_agendamento.fx_supervisor_quota(p_cd_elo_agendamento, ec.cd_sales_group),       /* QT_COTA */
               NULL,       /* QT_COTA_AJUSTADA */
               gx_elo_agendamento.fx_supervisor_forecast(p_cd_elo_agendamento, v_dt_week_start, v_site_id, v_site_type, ec.cd_sales_group) /* QT_FORECAST */ 
          FROM (
                     SELECT DISTINCT ca.cd_sales_group,
                            /*
                            We can have different Sales Office for the same 
                            Sales Group.
                            */
                            CASE WHEN us_ger.cd_usuario_original IS NULL THEN 
                                      gx_elo_agendamento.fx_latest_sales_office(p_cd_elo_agendamento, ca.cd_sales_group)
                                 ELSE 
                                      us_ger.cd_usuario_original
                            END
                            AS cd_sales_office,
                            /*
                            We can have different Sales District for the same 
                            Sales Office + Sales Group.
                            */
                            CASE WHEN us_nac.cd_usuario_original IS NULL THEN 
                                      gx_elo_agendamento.fx_latest_sales_district(
                                            p_cd_elo_agendamento,
                                            CASE WHEN us_ger.cd_usuario_original IS NULL THEN 
                                                gx_elo_agendamento.fx_latest_sales_office(p_cd_elo_agendamento, ca.cd_sales_group)
                                            ELSE 
                                                us_ger.cd_usuario_original
                                            END
                                      )
                                 ELSE 
                                      us_nac.cd_usuario_original
                            END
                            AS cd_sales_district
                       FROM vnd.elo_carteira ca
                       LEFT OUTER JOIN ctf.usuario us
                         ON us.cd_usuario_original = ca.cd_sales_group
                       LEFT OUTER JOIN ctf.usuario us_ger
                         ON us_ger.cd_usuario = us.cd_usuario_superior
                       LEFT OUTER JOIN ctf.usuario us_nac
                         ON us_nac.cd_usuario = us_ger.cd_usuario_superior
                      WHERE ca.cd_elo_agendamento = p_cd_elo_agendamento
                      GROUP BY us_ger.cd_usuario_original,
                               ca.cd_sales_group,
                               us_nac.cd_usuario_original,
                               ca.cd_sales_office
               ) EC
        ;
    END PI_AGENDAMENTO_SUPERVISOR;



    PROCEDURE PI_AGENDAMENTO_ITEM (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
    )
    IS
    BEGIN
        INSERT INTO VND.ELO_AGENDAMENTO_ITEM (
           CD_ELO_AGENDAMENTO_ITEM, 
           CD_ELO_AGENDAMENTO_SUPERVISOR, 
           CD_CLIENTE, 
           CD_PRODUTO_SAP, 
           CD_INCOTERMS, 
           CD_COTA_COMPARTILHADA, 
           CD_ELO_PRIORITY_OPTION, 
           CD_STATUS_REPLAN, 
           DS_OBSERVACAO_TORRE_FRETES, 
           IC_ATIVO, 
           IC_CORTADO_SEMANA_ANTERIOR
        )
        SELECT SEQ_ELO_AGENDAMENTO_ITEM.NEXTVAL,
               EC.CD_ELO_AGENDAMENTO_SUPERVISOR,
               EC.CD_CLIENTE,
               EC.CD_PRODUTO_SAP,
               EC.CD_INCOTERMS,
               NULL,
               NULL,
               NULL,
               NULL,
               'S',
               NULL
          FROM (
                    -- GROUP BY SUPERVISOR, CUSTOMER, MATERIAL and INCOTERM
                    SELECT AP.CD_ELO_AGENDAMENTO_SUPERVISOR,
                           CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.CD_CLIENTE_PAGADOR
                                ELSE CA.CD_CLIENTE_RECEBEDOR
                           END CD_CLIENTE,
                           CA.CD_PRODUTO_SAP,
                           CA.CD_INCOTERMS

                      FROM VND.ELO_CARTEIRA CA

                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AP
                        ON AP.CD_SALES_GROUP = CA.CD_SALES_GROUP
                       AND AP.CD_SALES_OFFICE = CA.CD_SALES_OFFICE

                     WHERE CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                       AND AP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                       AND CA.CD_PRODUTO_SAP IS NOT NULL
                       AND CA.CD_INCOTERMS IS NOT NULL

                     GROUP BY AP.CD_ELO_AGENDAMENTO_SUPERVISOR,
                              CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.CD_CLIENTE_PAGADOR
                                   ELSE CA.CD_CLIENTE_RECEBEDOR
                              END,
                              CA.CD_PRODUTO_SAP,
                              CA.CD_INCOTERMS

                     ORDER BY AP.CD_ELO_AGENDAMENTO_SUPERVISOR
               ) EC
        ;

        -- Updates reference to VND.ELO_AGENDAMENTO_ITEM in VND.ELO_CARTEIRA.
        MERGE INTO VND.ELO_CARTEIRA CA
        USING
        (
            SELECT AI.CD_ELO_AGENDAMENTO_ITEM,
                   AP.CD_SALES_GROUP,
                   AI.CD_CLIENTE,
                   AI.CD_PRODUTO_SAP,
                   AI.CD_INCOTERMS
              FROM VND.ELO_AGENDAMENTO_ITEM AI
             INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AP
                ON AP.CD_ELO_AGENDAMENTO_SUPERVISOR = AI.CD_ELO_AGENDAMENTO_SUPERVISOR
             WHERE AP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
        ) AI
        ON (
                    CA.CD_SALES_GROUP = AI.CD_SALES_GROUP
                AND CA.CD_PRODUTO_SAP = AI.CD_PRODUTO_SAP
                AND CA.CD_INCOTERMS = AI.CD_INCOTERMS
                AND (
                       (CA.CD_INCOTERMS = 'FOB' AND AI.CD_CLIENTE = CA.CD_CLIENTE_PAGADOR)
                       OR
                       (CA.CD_INCOTERMS = 'CIF' AND AI.CD_CLIENTE = CA.CD_CLIENTE_RECEBEDOR)
                    )
                AND CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
           )
        WHEN MATCHED THEN UPDATE SET
        CA.CD_ELO_AGENDAMENTO_ITEM = AI.CD_ELO_AGENDAMENTO_ITEM
        ;


        -- "ELO Project - [27, 32] 'Agendamento' spec V5.doc"
        -- Pg 22
        -- CD_ELO_PRIORITY_OPTION: After loading records here, check ELO_CARTEIRA 
        -- grouped records and get CD_ELO_PRIORITY_OPTION to check its content 
        -- and define which one will be filled in this field, following priority 
        -- sequence from ELO_PRIORITY_PANEL.
        MERGE INTO VND.ELO_AGENDAMENTO_ITEM AI
        USING
        (
            SELECT *
              FROM (
                        SELECT CA.CD_ELO_AGENDAMENTO_ITEM,
                               CA.CD_ELO_PRIORITY_OPTION,
                               PP.NU_ORDER

                          FROM VND.ELO_CARTEIRA CA

                          LEFT OUTER JOIN VND.ELO_AGENDAMENTO_PRIO_PANEL PP
                            ON PP.CD_ELO_PRIORITY_OPTION = CA.CD_ELO_PRIORITY_OPTION
                           AND PP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO

                         WHERE CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
                           AND CA.CD_ELO_PRIORITY_OPTION IS NOT NULL

                         ORDER BY PP.NU_ORDER
                    ) EC
              WHERE ROWNUM = 1
        ) CA
        ON (
                    AI.CD_ELO_AGENDAMENTO_ITEM = CA.CD_ELO_AGENDAMENTO_ITEM
                AND AI.IC_ATIVO = 'S'
           )
        WHEN MATCHED THEN UPDATE SET
        AI.CD_ELO_PRIORITY_OPTION = CA.CD_ELO_PRIORITY_OPTION
        ;
    END PI_AGENDAMENTO_ITEM;

-- #019
--    PROCEDURE PI_AGENDAMENTO_ITEM_1 (
--        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
--    )
--    IS
--        V_CD_WEEK           VND.ELO_AGENDAMENTO.CD_WEEK%TYPE;
--        V_CD_LOCAL          CHAR(4);
--    BEGIN
--        SELECT CD_WEEK,
--               CASE WHEN CD_POLO IS NOT NULL THEN CD_POLO
--                    WHEN CD_CENTRO_EXPEDIDOR IS NOT NULL THEN CD_CENTRO_EXPEDIDOR
--                    WHEN CD_MACHINE IS NOT NULL THEN CD_MACHINE
--               END CD_LOCAL
--          INTO V_CD_WEEK,
--               V_CD_LOCAL
--          FROM VND.ELO_AGENDAMENTO AG
--         WHERE AG.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--        ;
--    
--        INSERT INTO VND.ELO_AGENDAMENTO_ITEM (
--           CD_ELO_AGENDAMENTO_ITEM, 
--           CD_ELO_AGENDAMENTO_SUPERVISOR, 
--           CD_CLIENTE, 
--           CD_PRODUTO_SAP, 
--           CD_INCOTERMS, 
--           CD_COTA_COMPARTILHADA, 
--           CD_ELO_PRIORITY_OPTION, 
--           CD_STATUS_REPLAN, 
--           DS_OBSERVACAO_TORRE_FRETES, 
--           IC_ATIVO, 
--           IC_CORTADO_SEMANA_ANTERIOR,
--           CD_ELO_AGENDAMENTO,
--           CD_WEEK,
--           CD_LOCAL,
--           NO_PRODUTO_SAP,
--           CD_SALES_GROUP,
--           NO_SALES_GROUP,
--           CD_SALES_OFFICE,
--           NO_SALES_OFFICE,
--           CD_SALES_DISTRICT,
--           NO_SALES_DISTRICT,
--           CD_AGENTE_VENDA,
--           NO_AGENTE,
--           NO_CLIENTE,
--           DS_ENDERECO,
--           DS_BAIRRO,
--           NO_MUNICIPIO,
--           SG_ESTADO,
--           IC_RELACIONAMENTO,
--           QT_PROGRAMADA,
--           QT_ENTREGUE,
--           QT_AGENDADA_ANTERIOR,
--           QT_BACKLOG_CIF,
--           QT_BLOQUEADA,
--           QT_SALDO_BAG,
--           QT_SALDO_SACO,
--           QT_SALDO_GRANEL,
--           IC_TEM_DOCUMENTO_COOP
--        )
--        SELECT SEQ_ELO_AGENDAMENTO_ITEM.NEXTVAL,    --CD_ELO_AGENDAMENTO_ITEM
--               EC.CD_ELO_AGENDAMENTO_SUPERVISOR,    --CD_ELO_AGENDAMENTO_SUPERVISOR
--               EC.CD_CLIENTE,                       --CD_CLIENTE
--               EC.CD_PRODUTO_SAP,                   --CD_PRODUTO_SAP
--               EC.CD_INCOTERMS,                     --CD_INCOTERMS
--               NULL,                                --CD_COTA_COMPARTILHADA
--               NULL,                                --CD_ELO_PRIORITY_OPTION
--               NULL,                                --CD_STATUS_REPLAN
--               NULL,                                --DS_OBSERVACAO_TORRE_FRETES
--               'S',                                 --IC_ATIVO
--               NULL,                                --IC_CORTADO_SEMANA_ANTERIOR
--               P_CD_ELO_AGENDAMENTO,                --CD_ELO_AGENDAMENTO,
--               V_CD_WEEK,                           --CD_WEEK
--               V_CD_LOCAL,                          --CD_LOCAL
--               NO_PRODUTO_SAP,                      --NO_PRODUTO_SAP
--               CD_SALES_GROUP,                      --CD_SALES_GROUP
--               NO_SALES_GROUP,                      --NO_SALES_GROUP
--               CD_SALES_OFFICE,                     --CD_SALES_OFFICE
--               NO_SALES_OFFICE,                     --NO_SALES_OFFICE,
--               CD_SALES_DISTRICT,                   --CD_SALES_DISTRICT
--               NO_SALES_DISTRICT,                   --NO_SALES_DISTRICT
--               CD_AGENTE_VENDA,                     --CD_AGENTE_VENDA
--               NO_AGENTE,                           --NO_AGENTE
--               NO_CLIENTE,                          --NO_CLIENTE
--               DS_ENDERECO,                         --DS_ENDERECO
--               DS_BAIRRO,                           --DS_BAIRRO
--               NO_MUNICIPIO,                        --NO_MUNICIPIO
--               SG_ESTADO,                           --SG_ESTADO
--               IC_RELACIONAMENTO,                   --IC_RELACIONAMENTO
--               QT_PROGRAMADA,                       --QT_PROGRAMADA
--               QT_ENTREGUE,                         --QT_ENTREGUE
--               QT_AGENDADA_ANTERIOR,                --QT_AGENDADA_ANTERIOR
--               QT_BACKLOG_CIF,                      --QT_BACKLOG_CIF
--               QT_BLOQUEADA,                        --QT_BLOQUEADA
--               QT_SALDO_BAG,                        --QT_SALDO_BAG
--               QT_SALDO_SACO,                       --QT_SALDO_SACO
--               QT_SALDO_GRANEL,                     --QT_SALDO_GRANEL
--               IC_TEM_DOCUMENTO_COOP                --IC_TEM_DOCUMENTO_COOP
--               
--          FROM (
--                    -- GROUP BY SUPERVISOR, CUSTOMER, MATERIAL and INCOTERM
--                    SELECT AP.CD_ELO_AGENDAMENTO_SUPERVISOR,
--                           CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.CD_CLIENTE_PAGADOR
--                                ELSE CA.CD_CLIENTE_RECEBEDOR
--                           END CD_CLIENTE,
--                           CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.NO_CLIENTE_PAGADOR
--                                ELSE CA.NO_CLIENTE_RECEBEDOR
--                           END NO_CLIENTE,
--                           CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.DS_ENDERECO_PAGADOR
--                                ELSE CA.DS_ENDERECO_RECEBEDOR
--                           END DS_ENDERECO,
--                           CA.CD_PRODUTO_SAP,
--                           CA.CD_INCOTERMS,
--                           CA.NO_PRODUTO_SAP,
--                           AP.CD_SALES_GROUP,
--                           CA.NO_SALES_GROUP,
--                           AP.CD_SALES_OFFICE,
--                           CA.NO_SALES_OFFICE,
--                           AP.CD_SALES_DISTRICT,
--                           (
--                                SELECT NO_SALES_DISTRICT 
--                                  FROM ELO_CARTEIRA 
--                                 WHERE CD_SALES_DISTRICT = AP.CD_SALES_DISTRICT
--                                   AND CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--                                   AND ROWNUM = 1
--                           ) NO_SALES_DISTRICT,
--                           CASE
--                              WHEN MAX(CA.CD_AGENTE_VENDA) IS NULL THEN NULL
--                              WHEN MAX(CA.CD_AGENTE_VENDA) = MAX(CN.DS_VALUE) THEN NULL
--                              ELSE MAX(CA.CD_AGENTE_VENDA)
--                           END CD_AGENTE_VENDA,
--                           CASE
--                              WHEN MAX(CA.CD_AGENTE_VENDA) IS NULL THEN NULL
--                              WHEN MAX(CA.CD_AGENTE_VENDA) = MAX(CN.DS_VALUE) THEN NULL
--                              ELSE MAX(CA.NO_AGENTE)
--                           END NO_AGENTE,
--                           MAX(CA.DS_BAIRRO) DS_BAIRRO,
--                           MAX(CA.NO_MUNICIPIO) NO_MUNICIPIO,
--                           MAX(CA.SG_ESTADO) SG_ESTADO,
--                           MAX(CA.IC_RELACIONAMENTO) IC_RELACIONAMENTO,
--                           NVL(SUM(CA.QT_PROGRAMADA),0) QT_PROGRAMADA,
--                           NVL(SUM(CA.QT_ENTREGUE),0) QT_ENTREGUE,
--                           NVL(SUM(CA.QT_AGENDADA_ANTERIOR),0) QT_AGENDADA_ANTERIOR,
--                           NVL(SUM(CA.QT_BACKLOG_CIF),0) QT_BACKLOG_CIF,
--                           NVL(SUM(
--                                CASE WHEN (
--                                                 ca.ic_sem_ordem_venda = 'S'
--                                              OR TRIM(ca.cd_bloqueio_remessa) IS NOT NULL
--                                              OR TRIM(ca.cd_bloqueio_faturamento) IS NOT NULL
--                                              OR TRIM(ca.cd_bloqueio_credito) IS NOT NULL
--                                              OR TRIM(ca.cd_bloqueio_remessa_item) IS NOT NULL
--                                              OR TRIM(ca.cd_bloqueio_faturamento_item) IS NOT NULL
--                                              OR TRIM(ca.cd_motivo_recusa) IS NOT NULL
--                                          )
--                                     THEN ca.qt_programada
--                                     ELSE 0
--                                END
--                           ),0) QT_BLOQUEADA,
--                           NVL(SUM(
--                                    CASE WHEN CA.CD_GRUPO_EMBALAGEM = 'B' THEN CA.QT_SALDO
--                                         ELSE 0
--                                    END
--                           ),0) QT_SALDO_BAG,
--                           NVL(SUM(
--                                    CASE WHEN CA.CD_GRUPO_EMBALAGEM = 'S' THEN CA.QT_SALDO
--                                         ELSE 0
--                                    END
--                           ),0) QT_SALDO_SACO,
--                           NVL(SUM(
--                                    CASE WHEN CA.CD_GRUPO_EMBALAGEM = 'G' THEN CA.QT_SALDO
--                                         ELSE 0
--                                    END
--                           ),0) QT_SALDO_GRANEL,
--                           MAX(
--                                CASE WHEN TD.CD_TIPO_ORDEM IS NOT NULL THEN 'S'
--                                     ELSE 'N'
--                                END
--                           ) IC_TEM_DOCUMENTO_COOP
--
--                      FROM VND.ELO_CARTEIRA CA
--
--                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AP
--                        ON AP.CD_SALES_GROUP = CA.CD_SALES_GROUP
--                       AND AP.CD_SALES_OFFICE = CA.CD_SALES_OFFICE
--                       
--                      LEFT OUTER JOIN VND.CONSTANTES CN
--                        ON CA.CD_AGENTE_VENDA = CN.DS_VALUE
--                       AND CN.SG_SIGLA = 'AGDUM'
--
--                      LEFT OUTER JOIN VND.TIPO_ORDEM TD
--                        ON TD.CD_TIPO_ORDEM = CA.CD_TIPO_CONTRATO
--                       AND TD.IC_COOPERATIVE = 'S'
--
--                     WHERE CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--                       AND AP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--                       AND CA.CD_PRODUTO_SAP IS NOT NULL
--                       AND CA.CD_INCOTERMS IS NOT NULL
--
--                     GROUP BY AP.CD_ELO_AGENDAMENTO_SUPERVISOR,
--                              CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.CD_CLIENTE_PAGADOR
--                                ELSE CA.CD_CLIENTE_RECEBEDOR
--                              END,
--                              CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.NO_CLIENTE_PAGADOR
--                                ELSE CA.NO_CLIENTE_RECEBEDOR
--                              END,
--                              CASE WHEN CA.CD_INCOTERMS = 'FOB' THEN CA.DS_ENDERECO_PAGADOR
--                                ELSE CA.DS_ENDERECO_RECEBEDOR
--                              END,
--                              CA.CD_PRODUTO_SAP,
--                              CA.CD_INCOTERMS,
--                              CA.NO_PRODUTO_SAP,
--                              AP.CD_SALES_GROUP,
--                              CA.NO_SALES_GROUP,
--                              AP.CD_SALES_OFFICE,
--                              CA.NO_SALES_OFFICE,
--                              AP.CD_SALES_DISTRICT
--
--                     ORDER BY AP.CD_ELO_AGENDAMENTO_SUPERVISOR
--               ) EC
--        ;
--
--        -- Updates reference to VND.ELO_AGENDAMENTO_ITEM in VND.ELO_CARTEIRA.
--        MERGE INTO VND.ELO_CARTEIRA CA
--        USING
--        (
--            SELECT AI.CD_ELO_AGENDAMENTO_ITEM,
--                   AP.CD_SALES_GROUP,
--                   AI.CD_CLIENTE,
--                   AI.CD_PRODUTO_SAP,
--                   AI.CD_INCOTERMS
--              FROM VND.ELO_AGENDAMENTO_ITEM AI
--             INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AP
--                ON AP.CD_ELO_AGENDAMENTO_SUPERVISOR = AI.CD_ELO_AGENDAMENTO_SUPERVISOR
--             WHERE AP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--        ) AI
--        ON (
--                    CA.CD_SALES_GROUP = AI.CD_SALES_GROUP
--                AND CA.CD_PRODUTO_SAP = AI.CD_PRODUTO_SAP
--                AND CA.CD_INCOTERMS = AI.CD_INCOTERMS
--                AND (
--                       (CA.CD_INCOTERMS = 'FOB' AND AI.CD_CLIENTE = CA.CD_CLIENTE_PAGADOR)
--                       OR
--                       (CA.CD_INCOTERMS = 'CIF' AND AI.CD_CLIENTE = CA.CD_CLIENTE_RECEBEDOR)
--                    )
--                AND CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--           )
--        WHEN MATCHED THEN UPDATE SET
--        CA.CD_ELO_AGENDAMENTO_ITEM = AI.CD_ELO_AGENDAMENTO_ITEM
--        ;
--
--
--        -- "ELO Project - [27, 32] 'Agendamento' spec V5.doc"
--        -- Pg 22
--        -- CD_ELO_PRIORITY_OPTION: After loading records here, check ELO_CARTEIRA 
--        -- grouped records and get CD_ELO_PRIORITY_OPTION to check its content 
--        -- and define which one will be filled in this field, following priority 
--        -- sequence from ELO_PRIORITY_PANEL.
--        MERGE INTO VND.ELO_AGENDAMENTO_ITEM AI
--        USING
--        (
--            SELECT *
--              FROM (
--                        SELECT CA.CD_ELO_AGENDAMENTO_ITEM,
--                               CA.CD_ELO_PRIORITY_OPTION,
--                               PP.NU_ORDER
--
--                          FROM VND.ELO_CARTEIRA CA
--
--                          LEFT OUTER JOIN VND.ELO_AGENDAMENTO_PRIO_PANEL PP
--                            ON PP.CD_ELO_PRIORITY_OPTION = CA.CD_ELO_PRIORITY_OPTION
--                           AND PP.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--
--                         WHERE CA.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
--                           AND CA.CD_ELO_PRIORITY_OPTION IS NOT NULL
--
--                         ORDER BY PP.NU_ORDER
--                    ) EC
--              WHERE ROWNUM = 1
--        ) CA
--        ON (
--                    AI.CD_ELO_AGENDAMENTO_ITEM = CA.CD_ELO_AGENDAMENTO_ITEM
--                AND AI.IC_ATIVO = 'S'
--           )
--        WHEN MATCHED THEN UPDATE SET
--        AI.CD_ELO_PRIORITY_OPTION = CA.CD_ELO_PRIORITY_OPTION
--        ;
--    END PI_AGENDAMENTO_ITEM_1;


    PROCEDURE PX_GET_DETAILS (
        P_CD_AGENDAMENTO       IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL,
        P_RETORNO              OUT T_CURSOR
    )

    IS

    BEGIN

        OPEN P_RETORNO FOR
                select es.SG_STATUS,
                       ag.NU_CARTEIRA_VERSION,
                       ag.NU_SEMANAS,
                       ag.DH_LIMITE,
                       ag.QT_OVERBOOKING_SUPERVISORES,
                       ag.QT_LIMITE_EMERGENCIAL
                  from VND.ELO_AGENDAMENTO ag
                 inner join VND.ELO_STATUS es
                    on ag.CD_ELO_STATUS = es.CD_ELO_STATUS
                 inner join VND.ELO_TIPO_STATUS ts
                    on ts.CD_ELO_TIPO_STATUS = es.CD_ELO_TIPO_STATUS
                 where ts.SG_TIPO_STATUS = 'AGEND'
                   and ag.CD_ELO_AGENDAMENTO = P_CD_AGENDAMENTO;

    END PX_GET_DETAILS;

    PROCEDURE PU_STATUS_AGENDAMENTO (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL,
        P_STATUS_DE             IN VND.ELO_STATUS.SG_STATUS%TYPE DEFAULT NULL,
        P_STATUS_PARA           IN VND.ELO_STATUS.SG_STATUS%TYPE DEFAULT NULL,
        P_RETORNO               OUT T_CURSOR
    )

    IS

    V_STATUS_DE     INT;
    V_STATUS_PARA   INT;
    V_RETORNO       CHAR;

    BEGIN

        select es.CD_ELO_STATUS
          into V_STATUS_DE
          from VND.ELO_STATUS es
         where es.SG_STATUS = P_STATUS_DE;

        select es.CD_ELO_STATUS
          into V_STATUS_PARA
          from VND.ELO_STATUS es
         where es.SG_STATUS = P_STATUS_PARA;

        IF V_STATUS_PARA is not null THEN

            update VND.ELO_AGENDAMENTO
               set CD_ELO_STATUS = V_STATUS_PARA
             where CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO
               --and CD_ELO_STATUS = V_STATUS_DE
                and CD_ELO_STATUS = V_STATUS_DE and CD_ELO_STATUS < V_STATUS_PARA -- STATUS ALLOW ABOVE CURRENT ADRIANO 2018/04/17
               ;

            V_RETORNO := 'T';

        ELSE
            V_RETORNO := 'F';
        END IF;

        OPEN P_RETORNO FOR
            SELECT V_RETORNO AS RETORNO FROM DUAL;

    EXCEPTION
        WHEN OTHERS THEN
            BEGIN RAISE_APPLICATION_ERROR(-20001, 'PU_STATUS_AGENDAMENTO - ERRO ENCONTRADO - '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM
                );
                ROLLBACK;
            END;

    END PU_STATUS_AGENDAMENTO;



END GX_ELO_AGENDAMENTO;
/