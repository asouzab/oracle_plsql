CREATE OR REPLACE PACKAGE VND."GX_ELO_REPLAN_PROCESS" AS 

    TYPE T_CURSOR IS REF CURSOR;

    TYPE T_VET_RETORNO IS TABLE OF VARCHAR2(500);

    TYPE SPLIT_TBL IS TABLE OF VARCHAR2(300);
    
    
    FUNCTION FX_SPLIT (
        P_LISTA         IN VARCHAR2,
        P_DELIMITADOR   IN VARCHAR2 DEFAULT ','
    ) RETURN T_VET_RETORNO PIPELINED;
    
    
    FUNCTION FX_SPLIT2 (
        LIST            IN VARCHAR2,
        DELIMITER       IN VARCHAR2 DEFAULT ','
    ) RETURN SPLIT_TBL;


    PROCEDURE PX_REPLAN_BASIC_DATA(
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE := NULL,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE := NULL,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE := NULL,
        P_RETORNO               OUT T_CURSOR,
        P_PRODUTO               OUT T_CURSOR,
        P_INCOTERMS             OUT T_CURSOR,
        P_SUPERVISORS           OUT T_CURSOR
    );
    
    PROCEDURE PX_REPLAN_BASIC_DATA_SAP (
        P_CD_WEEK               IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_RETORNO               OUT T_CURSOR,
        P_PRODUTO               OUT T_CURSOR,
        P_INCOTERMS             OUT T_CURSOR,
        P_SUPERVISORS           OUT T_CURSOR
    );

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
    );
    
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
    );
    
    PROCEDURE PI_REPLAN (
        p_cd_week                       IN vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo                       IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor           IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine                    IN vnd.elo_agendamento.cd_machine%TYPE,
        p_cd_agendamento_item_origem    IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_retorno                       OUT t_cursor
    );

    PROCEDURE PI_REPLAN_SAP (
        p_cd_week               IN  vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN  vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN  vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN  vnd.elo_agendamento.cd_machine%TYPE,
        p_cd_elo_carteira_sap   IN  VARCHAR2,
        p_retorno               OUT t_cursor
    );
    
    PROCEDURE PX_ITENS_VERIFICAR (
        p_cd_week               IN  vnd.elo_agendamento.cd_week%TYPE,
        p_cd_polo               IN  vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN  vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN  vnd.elo_agendamento.cd_machine%TYPE,
        p_retorno               OUT t_cursor
    );
    
    PROCEDURE PU_APROVAR_REPLAN (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_retorno                   OUT t_cursor
    );
    
    PROCEDURE PU_REPROVAR_REPLAN (
        p_cd_elo_agendamento_item   IN vnd.elo_agendamento_item.cd_elo_agendamento_item%TYPE,
        p_retorno                   OUT t_cursor
    );
    
END GX_ELO_REPLAN_PROCESS;
/