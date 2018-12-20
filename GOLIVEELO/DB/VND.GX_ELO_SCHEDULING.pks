CREATE OR REPLACE PACKAGE VND."GX_ELO_SCHEDULING" IS
    
    
    TYPE t_cursor IS REF CURSOR;


    /********************************************************************* 
    Returns the total of balance portfolio that have no protocols 
    for a given scheduling item.

    AUTHOR: Sergio Umlauf

    p_cd_elo_agendamento_item:   The Schedulling Item ID.
    returns:                     The portfolio volume witn no protocol.
    /*********************************************************************/
    FUNCTION fx_no_protocol_balance (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER;



    /********************************************************************* 
    Returns the total of blocked portfolio balance for a given scheduling 
    item.

    AUTHOR: Sergio Umlauf

    p_cd_elo_agendamento_item:   The Schedulling Item ID.
    returns:                     The portfolio's blocked volume.
    /*********************************************************************/
    FUNCTION fx_blocked_balance (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER;



    FUNCTION fx_has_coop_document (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN CHAR;
    
    
    
    FUNCTION fx_has_split_document (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN CHAR;
    
    
    
    FUNCTION fx_total_backlog_cif (
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER;
    
   

    FUNCTION fx_consumo_cota_supervisor (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_group        IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE
    ) RETURN NUMBER;



    FUNCTION fx_consumo_cota_centro (
        p_cd_week       IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site       IN CHAR,
        p_site_type     IN CHAR
    ) RETURN NUMBER;
    
    
    FUNCTION fx_backlog_cif (
        p_cd_week                 IN vnd.elo_agendamento_backlog.cd_week%TYPE,
        p_cd_elo_agendamento_item IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    ) RETURN NUMBER;

   
    
    
    
    
    
    /*#######################################################################*/








    /********************************************************************* 
    List all distinct Week codes of active schedulings 
    from ELO_AGENDAMENTO.

    AUTHOR: Sergio Umlauf

    returns:    Distinct Week codes of active schedulings. 
    /*********************************************************************/
    PROCEDURE px_weeks (
        p_result                OUT t_cursor
    );



    /********************************************************************* 
    List all distinct sites (Polo, Plant or Machine) codes of active  
    schedulings from ELO_AGENDAMENTO for a week code.

    AUTHOR: Sergio Umlauf

    p_cd_week:    A week code. 
    returns:      Distinct site codes of active schedulings. 
    /*********************************************************************/
    PROCEDURE px_sites_by_week (
        p_cd_week       IN vnd.elo_agendamento.cd_week%TYPE,
        p_result        OUT t_cursor
    );


    /********************************************************************* 
    List all distinct Regional Managers for a week code and site (Polo, 
    Plant or Machine).

    AUTHOR: Sergio Umlauf

    p_cd_week:    A week code. 
    p_cd_site:    Polo, Plant or Machine code.
    p_site_type:  'P' for Polo, 'C' for Plant, 'M' for Machine.
    returns:      Distinct site codes of Regional Managers. 
    /*********************************************************************/
    PROCEDURE px_regional_managers (
        p_cd_week       IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site       IN CHAR,
        p_site_type     IN CHAR,
        p_result        OUT t_cursor
    );


    /********************************************************************* 
    List all distinct Sales Supervisors for a week code, site (Polo, 
    Plant or Machine) and Regional Manager.

    AUTHOR: Sergio Umlauf

    p_cd_week:          A week code. 
    p_cd_site:          Polo, Plant or Machine code.
    p_site_type:        'P' for Polo, 'C' for Plant, 'M' for Machine.
    p_cd_sales_office:  The regional manager code.
    returns:            Distinct site codes of Sales Supervisors. 
    /*********************************************************************/
    PROCEDURE px_supervisors (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_cd_sales_office   IN vnd.elo_agendamento_supervisor.cd_sales_office%type,
        p_result            OUT t_cursor
    );



    PROCEDURE px_scheduling_items_qts (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_cd_sales_office   IN vnd.elo_agendamento_supervisor.cd_sales_office%type,
        p_cd_sales_group    IN vnd.elo_agendamento_supervisor.cd_sales_group%type,
        p_result            OUT t_cursor
    );
  
    

    /********************************************************************* 
    Available volume to be planned per day of week.

    /*********************************************************************/
    PROCEDURE px_available_volume (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_result            OUT t_cursor
    );


    PROCEDURE px_available_volume2 (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_result            OUT t_cursor
    );


    PROCEDURE px_months_ahead (
        p_result            OUT t_cursor
    );



    PROCEDURE pu_share_quota (
        p_scheling_items            IN VARCHAR,
        p_cd_cota_compartilhada     IN vnd.elo_agendamento_item.cd_cota_compartilhada%TYPE,
        p_result                    OUT t_cursor
    );



    PROCEDURE pu_unshare_quota (
        p_scheling_items            IN VARCHAR,
        p_result                    OUT t_cursor
    );



    PROCEDURE pi_agendamento_week_qty (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_semana                 IN vnd.elo_agendamento_week.qt_semana%TYPE
    );



    PROCEDURE pi_agendamento_week_qty_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_semana                 IN vnd.elo_agendamento_week.qt_semana%TYPE,
        p_result                    OUT t_cursor
    );



    PROCEDURE pd_agendamento_week (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE
    );



    PROCEDURE pi_agendamento_emerg (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_emergencial            IN vnd.elo_agendamento_week.qt_emergencial%TYPE
    );
    
    
    
    PROCEDURE pi_agendamento_week_emerg (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_emergencial            IN vnd.elo_agendamento_week.qt_emergencial%TYPE,
        p_result                    OUT t_cursor
    );



    PROCEDURE pi_agendamento_day (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_day.nu_quantidade%TYPE
    );



    PROCEDURE pi_agendamento_day_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_day.nu_quantidade%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    );



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
    );



    PROCEDURE pd_agendamento_day (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE
    );



    PROCEDURE pd_agendamento_day_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    );



    PROCEDURE pd_agendamento_day_cif (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    );



    PROCEDURE pu_check_week (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE
    );



    PROCEDURE px_protocols (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_result                    OUT t_cursor,
        p_packages                  OUT t_cursor,
        p_packages_scheduled        OUt t_cursor
    );



    PROCEDURE px_sales_orders (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_result                    OUT t_cursor
    );
    


    PROCEDURE pi_elo_agendamento_grouping (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_week.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_sg_tipo_documento         IN vnd.elo_agendamento_grouping.sg_tipo_documento%TYPE,
        p_nu_documento              IN vnd.elo_agendamento_grouping.nu_documento%TYPE,
        p_qt_agendada               IN vnd.elo_agendamento_grouping.qt_agendada%TYPE,
        p_cd_agrupamento_protocolo  IN vnd.elo_agendamento_grouping.cd_agrupamento_protocolo%TYPE,
        p_cd_usuario_criacao        IN vnd.elo_agendamento_grouping.cd_usuario_criacao%TYPE
    );



    PROCEDURE px_scheduling (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_result            OUT t_cursor
    );



    PROCEDURE pu_end_supervisor_scheduling (
        p_cd_week           IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site           IN CHAR,
        p_site_type         IN CHAR,
        p_cd_sales_office   IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group    IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    );



    PROCEDURE pu_distribute_protocol_group (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    );
    
    
    
    PROCEDURE pu_distribute_split_group (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    );
    
    
    
    PROCEDURE pu_distribute_emergency (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    );
    
    
    
    PROCEDURE pu_distribute_item (
        p_cd_elo_agendamento_item    IN vnd.elo_carteira.cd_elo_agendamento_item%TYPE
    );
    
    

    PROCEDURE pu_agendamento_status (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    );



    PROCEDURE pu_carteira_day (
        p_cd_elo_carteira       vnd.elo_carteira_day.cd_elo_carteira%TYPE, 
        p_cd_grupo_embalagem    vnd.elo_carteira_day.cd_grupo_embalagem%TYPE, 
        p_nu_semana             vnd.elo_carteira_day.nu_semana%TYPE,
        p_nu_dia_semana         vnd.elo_carteira_day.nu_dia_semana%TYPE, 
        p_nu_quantidade         vnd.elo_carteira_day.nu_quantidade%TYPE
    );



    PROCEDURE pu_observacao_torre_fretes (
        p_cd_elo_agendamento_item       IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_ds_observacao_torre_fretes    IN vnd.elo_agendamento_item.ds_observacao_torre_fretes%TYPE,
        p_result                        OUT t_cursor
    );



    PROCEDURE px_package_group_day (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_office       IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                OUT t_cursor
    );
    
    
    
    PROCEDURE px_package_group_total_fob (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_nu_dia_semana             IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    );
    
    
    
    PROCEDURE px_package_group_total_cif (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_cd_sales_office           IN vnd.elo_agendamento_supervisor.cd_sales_office%TYPE,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                    OUT t_cursor
    );
    
    
    
    PROCEDURE px_daily_quota (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_result                OUT t_cursor
    );



    PROCEDURE px_check_emergency_qty (
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR,
        p_cd_sales_group            IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_result                    OUT t_cursor
    );
    


    PROCEDURE px_check_plant_capacity (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR,
        p_minimun_day_for_replan    IN vnd.elo_agendamento_day.nu_dia_semana%TYPE,
        p_result                    OUT t_cursor,
        p_capacity                  OUT t_cursor
    );
    
    
    PROCEDURE pi_agendamento_week_factory (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_qt_semana                 IN vnd.elo_agendamento_week.qt_semana%TYPE
    );
    
    
    PROCEDURE pi_agendamento_day_factory (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_nu_semana                 IN vnd.elo_agendamento_week.nu_semana%TYPE,
        p_cd_grupo_embalagem        IN vnd.elo_agendamento_day.cd_grupo_embalagem%TYPE,
        p_nu_quantidade             IN vnd.elo_agendamento_week.qt_semana%TYPE,
        p_cd_week                   IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_site                   IN CHAR,
        p_site_type                 IN CHAR
    );


END GX_ELO_SCHEDULING;
/