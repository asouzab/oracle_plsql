CREATE OR REPLACE PACKAGE VND."GX_ELO_AGENDAMENTO" IS
    
    
    TYPE T_CURSOR IS REF CURSOR;
    
    
    TYPE SPLIT_TBL IS TABLE OF VARCHAR2(300);
    
    
    FUNCTION FX_SPLIT2 (
        LIST        IN VARCHAR2,
        DELIMITER   IN VARCHAR2 DEFAULT ','
    ) RETURN SPLIT_TBL;



    /********************************************************************* 
    Returns the priority option of the Priority Panel copy for the 
    schedulling week.
    
    AUTHOR: Sergio Umlauf
    
    p_cd_elo_agendamento:   The Schedulling ID.
    p_sg_priority_option:   Priority Option symbol.
    returns:                CD_ELO_PRIORITY_OPTION for the Schedulling or 
                            null if the priority option was not included
                            in the Priority Panel at the moment of 
                            its copy.
    /*********************************************************************/
    FUNCTION FX_PRIORITY_OPTION (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_SG_PRIORITY_OPTION    IN VND.ELO_PRIORITY_OPTION.SG_PRIORITY_OPTION%TYPE
    ) RETURN VND.ELO_AGENDAMENTO_PRIO_PANEL.CD_ELO_PRIORITY_OPTION%TYPE;

    

    /********************************************************************* 
    Checks if a document type is used in the Cooperative process.
    
    AUTHOR: Sergio Umlauf
    
    p_cd_tipo_ordem:    The document type.   
    returns:            'S' if the document type is used in the 
                            Cooperative process;
                        'N' otherwise. 
    /*********************************************************************/
    FUNCTION FX_IS_DOCTYPE_COOPERATIVE (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_COOPERATIVE%TYPE;
    
    
    
    /********************************************************************* 
    Checks if a document type is used in the Contract Split process.
    
    AUTHOR: Sergio Umlauf
    
    p_cd_tipo_ordem:    The document type.   
    returns:            'S' if the document type is used in the 
                            Contract Split process;
                        'N' otherwise. 
    /*********************************************************************/
    FUNCTION FX_IS_DOCTYPE_SPLIT (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_SPLIT%TYPE;

    
    
    /********************************************************************* 
    Checks if a document type is of Antecipated Billing type.
    
    AUTHOR: Sergio Umlauf
    
    p_cd_tipo_ordem:    The document type.   
    returns:            'S' if the document type is of Antecipated 
                            Billing type;
                        'N' otherwise. 
    /*********************************************************************/
    FUNCTION FX_IS_DOCTYPE_FA (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_FA%TYPE;
    
    
    /********************************************************************* 
    Checks if a document type is of Export type.
    
    AUTHOR: Alex Oliveira
    
    p_cd_tipo_ordem:    The document type.   
    returns:            'S' if the document type is of Export type;
                        'N' otherwise. 
    /*********************************************************************/
    FUNCTION FX_IS_DOCTYPE_EXPORT (
        P_CD_TIPO_ORDEM     IN VND.TIPO_ORDEM.CD_TIPO_ORDEM%TYPE
    ) RETURN VND.TIPO_ORDEM.IC_EXPORT%TYPE;


    
    /********************************************************************* 
    Returns the previous schedulling ID for a given place, i.e., Polo,
    Plant and/or Machine.
    
    AUTHOR: Sergio Umlauf
    
    p_cd_elo_agendamento:   The schedulling ID for which the previsou one
                            is needed.
    p_cd_polo:              Polo ID
    p_cd_centro_expedidor:  Plant ID
    p_cd_machine:           Machine ID
    returns:                The ID of the previous shedulling.
    /*********************************************************************/
    FUNCTION FX_PREVIOUS_SCHEDULLING (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE
    ) RETURN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE;


    
    /********************************************************************* 
    Returns the status that of a document/product if found in the 
    specified SAP portfolio.
    
    AUTHOR: Sergio Umlauf
    
    p_nu_carteira_version:  The SAP portfolio version.
    p_nu_ordem_venda:       Sales Order number
    p_cd_produto_sap:       Finish material code
    returns:                Status from VND.ELO_STATUS of type 'BLCIF'.
    /*********************************************************************/
    FUNCTION FX_STATUS_BACKLOG_CIF (
        P_NU_CARTEIRA_VERSION   IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_NU_ORDEM_VENDA        IN VND.ELO_CARTEIRA_SAP.NU_ORDEM_VENDA%TYPE,
        P_CD_PRODUTO_SAP        IN VND.ELO_CARTEIRA_SAP.CD_PRODUTO_SAP%TYPE
    ) RETURN VND.ELO_STATUS.CD_ELO_STATUS%TYPE;



    FUNCTION fx_plant_forecast (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_dt_week_start         IN vnd.elo_agendamento.dt_week_start%TYPE,
        p_site_id               IN CHAR,
        p_site_type             IN CHAR
    ) RETURN vnd.elo_agendamento_supervisor.qt_forecast%TYPE;



    FUNCTION fx_supervisor_forecast  (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_dt_week_start         IN vnd.elo_agendamento.dt_week_start%TYPE,
        p_site_id               IN CHAR,
        p_site_type             IN CHAR,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    ) RETURN vnd.elo_agendamento_supervisor.qt_forecast%TYPE;



    FUNCTION fx_supervisor_quota  (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_sales_group        IN vnd.elo_agendamento_supervisor.cd_sales_group%TYPE
    ) RETURN vnd.elo_agendamento_supervisor.qt_cota%TYPE;

  
    
    FUNCTION fx_latest_sales_office (
        p_cd_elo_agendamento    IN vnd.elo_carteira.cd_elo_agendamento%TYPE,
        p_cd_sales_group        IN vnd.elo_carteira.cd_sales_group%TYPE
    ) RETURN vnd.elo_carteira.cd_sales_office%TYPE;



    FUNCTION fx_latest_sales_district (
        p_cd_elo_agendamento    IN vnd.elo_carteira.cd_elo_agendamento%TYPE,
        p_cd_sales_office       IN vnd.elo_carteira.cd_sales_office%TYPE
    ) RETURN vnd.elo_carteira.cd_sales_district%TYPE;
    
    
    
    
    
    

    /*#######################################################################*/








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
    );


    PROCEDURE PU_ATUALIZA_ELO_AGENDAMENTO (
        P_NU_CARTEIRA_VERSION           IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_DH_LIMITE                     IN VARCHAR,
        P_QT_OVERBOOKING_SUPERVISORES   IN VND.ELO_AGENDAMENTO.QT_OVERBOOKING_SUPERVISORES%TYPE,
        P_QT_LIMITE_EMERGENCIAL         IN VND.ELO_AGENDAMENTO.QT_LIMITE_EMERGENCIAL%TYPE,
        P_NU_SEMANAS                    IN VND.ELO_AGENDAMENTO.NU_SEMANAS%TYPE,
        P_CD_ELO_AGENDAMENTO            IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE
    );

    PROCEDURE PI_RELEASE_SCHEDULING (
        P_CD_ELO_AGENDAMENTO            IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_NU_CARTEIRA_VERSION           IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_CD_POLO                       IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR           IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE                    IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_RETORNO                       OUT T_CURSOR
    );

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
    );


   PROCEDURE PX_GET_AGENDAMENTO (
        P_WEEK                  IN VARCHAR2 DEFAULT NULL,
        P_CD_POLO               VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_SG_STATUS             varchar DEFAULT NULL,
        P_IC_ATIVO              VND.ELO_AGENDAMENTO.IC_ATIVO%TYPE DEFAULT NULL,
        P_RETORNO               OUT T_CURSOR
    );


    PROCEDURE PU_AGEND_CENTRO_ITEM (
        P_CD_AGENDAMENTO_CENTROS   IN VARCHAR,
        P_OVERBOOKINGS             IN VARCHAR,
        P_MACHINE_PROFS            IN VARCHAR,
        P_NU_SEMANAS               IN NUMBER
    );


    PROCEDURE PX_GET_POLOS (
        P_RETORNO   OUT T_CURSOR
    );
    
    
    PROCEDURE PX_GET_CD_WEEKS (
        P_RETORNO   OUT T_CURSOR
    );


    PROCEDURE PX_GET_POLO (
        P_RETORNO   OUT T_CURSOR,
        P_CD_POLO   IN CTF.POLO.CD_POLO%TYPE
    );


    PROCEDURE PX_GET_MAQUINAS (
        P_CD_CENTRO   IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_RETORNO     OUT T_CURSOR
    );


    PROCEDURE PX_GET_MAQUINA (
        P_RETORNO      OUT T_CURSOR,
        P_CD_MAQUINA   IN CTF.MACHINE.CD_MACHINE%TYPE
    );


    PROCEDURE PX_GET_CENTROS (
        P_CD_POLO   IN CTF.POLO_CENTRO_EXPEDIDOR.CD_POLO%TYPE,
        P_RETORNO   OUT T_CURSOR
    );


    PROCEDURE PX_GET_CENTRO (
        P_CD_CENTRO   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_RETORNO     OUT T_CURSOR
    );


    PROCEDURE PX_GET_NU_CARTEIRA_VERSION (
        P_POLO      IN CTF.POLO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO IN VND.ELO_CARTEIRA_SAP.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_RETORNO   OUT T_CURSOR
    );


    PROCEDURE PX_GET_MACHINE_PROFS (
        P_CD_POLO      IN CTF.POLO_CENTRO_EXPEDIDOR.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO    IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE   IN CTF.MACHINE.CD_MACHINE%TYPE DEFAULT NULL,
        P_RETORNO      OUT T_CURSOR
    );


    PROCEDURE PI_CREATE_PARAMETERS_IMAGES (
        P_CD_ELO_AGENDAMENTO   IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL
    );


    PROCEDURE PI_INSERE_ELO_AGEND_SUPERVISOR (
        P_CD_ELO_AGENDAMENTO   IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL
    );


    PROCEDURE PX_GET_AGEND_CENTRO_ITENS (
        P_CD_POLO         IN ELO_AGENDAMENTO_CENTRO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO       IN ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE      IN ELO_AGENDAMENTO_CENTRO.CD_MACHINE%TYPE DEFAULT NULL,
        P_DT_WEEK_START   IN ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%TYPE,
        P_RETORNO         OUT T_CURSOR
    );
    
    PROCEDURE PU_STATUS_LOGISTICA (
        P_CD_ELO_CARTEIRA   IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
        P_STATUS_LOGISTICA  IN VND.ELO_CARTEIRA.CD_STATUS_LOGISTICA%TYPE,
        P_RESULT            OUT T_CURSOR
    );

    
    /********************************************************************* 
    Copies data from VND.ELO_CARTEIRA_SAP to VND.ELO_CARTEIRA at the
    moment of the Scheduling creation. It also checks for backlog CIF
    documents for the previous scheduling week.
    
    AUTHOR: Sergio Umlauf
    /*********************************************************************/
    PROCEDURE PI_COPY_PORTFOLIO (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE,
        P_NU_CARTEIRA_VERSION   IN VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE,
        P_CD_POLO               IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_MACHINE            IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE
    );
    
    
    
    PROCEDURE PI_AGENDAMENTO_SUPERVISOR (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
    );
    
    
    PROCEDURE PI_AGENDAMENTO_ITEM (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
    );

-- #019
--    PROCEDURE PI_AGENDAMENTO_ITEM_1 (
--        P_CD_ELO_AGENDAMENTO    IN VND.ELO_CARTEIRA.CD_ELO_AGENDAMENTO%TYPE
--    );
    
    PROCEDURE PX_GET_DETAILS (
        P_CD_AGENDAMENTO       IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL,
        P_RETORNO              OUT T_CURSOR
    );
    
    PROCEDURE PU_STATUS_AGENDAMENTO (
        P_CD_ELO_AGENDAMENTO    IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE DEFAULT NULL,
        P_STATUS_DE             IN VND.ELO_STATUS.SG_STATUS%TYPE DEFAULT NULL,
        P_STATUS_PARA           IN VND.ELO_STATUS.SG_STATUS%TYPE DEFAULT NULL,
        P_RETORNO               OUT T_CURSOR
    );
    
END GX_ELO_AGENDAMENTO;
/