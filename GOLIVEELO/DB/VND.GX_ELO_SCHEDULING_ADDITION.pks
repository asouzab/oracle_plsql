CREATE OR REPLACE PACKAGE VND."GX_ELO_SCHEDULING_ADDITION" AS 

    TYPE t_cursor IS REF CURSOR;

    TYPE t_vet_retorno IS TABLE OF VARCHAR2(500);

    TYPE split_tbl IS TABLE OF VARCHAR2(300);
    
    
    FUNCTION fx_split (
        p_lista         IN VARCHAR2,
        p_delimitador   IN VARCHAR2 DEFAULT ','
    ) RETURN t_vet_retorno PIPELINED;
    
    
    FUNCTION fx_split2 (
        list            IN VARCHAR2,
        delimiter       IN VARCHAR2 DEFAULT ','
    ) RETURN split_tbl;

    PROCEDURE px_basic_data (
        p_cd_week               IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_clientes              OUT t_cursor,
        p_produto               OUT t_cursor,
        p_incoterms             OUT t_cursor,
        p_supervisors           OUT t_cursor
    );

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
    );
    
    PROCEDURE pi_add_item (
        p_cd_week               IN  vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN  vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN  vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN  vnd.elo_agendamento.cd_machine%TYPE,
        p_cd_elo_carteira_sap   IN  VARCHAR2,
        p_retorno               OUT t_cursor
    );

    PROCEDURE px_carteira_sap (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_number_of_records     IN NUMBER,
        p_retorno               OUT t_cursor
    );
    
    PROCEDURE px_incoterms (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    );
    
    PROCEDURE px_products (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    );
    
    PROCEDURE px_customers (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    );
    
    PROCEDURE px_supervisors (
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_nu_carteira_version   IN vnd.elo_carteira_sap.nu_carteira_version%TYPE,
        p_retorno               OUT t_cursor
    );
    
    
END GX_ELO_SCHEDULING_ADDITION;
/