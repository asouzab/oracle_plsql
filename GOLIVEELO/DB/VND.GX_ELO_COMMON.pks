CREATE OR REPLACE PACKAGE VND.GX_ELO_COMMON AS 

    TYPE T_CURSOR IS REF CURSOR;
    
    TYPE T_VET_RETORNO IS TABLE OF VARCHAR2(300);
    
    TYPE SPLIT_TBL IS TABLE OF VARCHAR2(300);
    
    
    
    -- EXEMPLO DE USO "SELECT * FROM TABLE(FX_SPLIT('1;2;3;4;5;6;7;8;9',';'))"
    FUNCTION fx_split(
        p_lista       VARCHAR2,
        p_delimitador VARCHAR2 := ','
    ) RETURN t_vet_retorno PIPELINED;
    
    
    FUNCTION fx_split2 (
        list        IN VARCHAR2,
        delimiter   IN VARCHAR2 DEFAULT ','
    ) RETURN split_tbl;
  
  
    FUNCTION fx_elo_status (
        p_sg_tipo_status    IN vnd.elo_tipo_status.sg_tipo_status%TYPE,
        p_sg_status         IN vnd.elo_status.sg_status%TYPE
    ) RETURN vnd.elo_status.cd_elo_status%TYPE;

    FUNCTION fx_elo_status_order (
        p_sg_tipo_status    IN vnd.elo_tipo_status.sg_tipo_status%TYPE,
        p_sg_status         IN vnd.elo_status.sg_status%TYPE
    ) RETURN vnd.elo_status.nu_order%TYPE;
    
    FUNCTION fx_elo_status_order (
        p_cd_elo_status    IN vnd.elo_status.cd_elo_status%TYPE
    ) RETURN vnd.elo_status.nu_order%TYPE;
    
    PROCEDURE PX_GET_POLOS (
        P_RESULT  OUT T_CURSOR
    );

    PROCEDURE px_elo_status (
        p_sg_tipo_status    IN vnd.elo_tipo_status.sg_tipo_status%TYPE,
        p_order_by          IN varchar2,
        p_order             IN varchar2,
        p_result            OUT t_cursor
    );
    
    FUNCTION fx_previous_scheduling (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_weeks                 IN NUMBER DEFAULT 1
    ) RETURN vnd.elo_agendamento.cd_elo_agendamento%TYPE;

    FUNCTION fx_previous_scheduling (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_weeks                 IN NUMBER DEFAULT 1
    ) RETURN vnd.elo_agendamento.cd_elo_agendamento%TYPE;

END GX_ELO_COMMON;
/