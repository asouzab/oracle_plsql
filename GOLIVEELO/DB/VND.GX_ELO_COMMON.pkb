CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_COMMON" AS


    FUNCTION fx_split(
        p_lista       VARCHAR2,
        p_delimitador VARCHAR2 := ','
    ) RETURN T_VET_RETORNO PIPELINED
    IS
        lista_index PLS_INTEGER;
        lista       VARCHAR2(16000) := P_LISTA;
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
    ) RETURN split_tbl AS

        splitted   split_tbl := split_tbl ();
        I          PLS_INTEGER := 0;
        list_      VARCHAR2(16000) := LIST;
    BEGIN
        LOOP
            I := INSTR(list_,delimiter);
            IF
                I > 0
            THEN
                splitted.EXTEND(1);
                splitted(splitted.LAST) := SUBSTR(
                    list_,
                    1,
                    I - 1
                );

                list_ := SUBSTR(
                    list_,
                    I + LENGTH(delimiter)
                );
            ELSE
                splitted.EXTEND(1);
                splitted(splitted.LAST) := LIST_;
                RETURN splitted;
            END IF;

        END LOOP;
    END fx_split2;



    FUNCTION fx_elo_status (
        p_sg_tipo_status    IN vnd.elo_tipo_status.sg_tipo_status%TYPE,
        p_sg_status         IN vnd.elo_status.sg_status%TYPE
    ) RETURN vnd.elo_status.cd_elo_status%TYPE
    IS
        v_result vnd.elo_status.cd_elo_status%TYPE;
    BEGIN

        SELECT es.cd_elo_status

            INTO v_result

            FROM vnd.elo_status es

        INNER JOIN vnd.elo_tipo_status ts
            ON ts.cd_elo_tipo_status = es.cd_elo_tipo_status

            WHERE ts.sg_tipo_status = p_sg_tipo_status
            AND es.sg_status = p_sg_status
        ;

        RETURN v_result;

    END fx_elo_status;



    PROCEDURE PX_GET_POLOS (
        P_RESULT OUT T_CURSOR
    )
    AS
    BEGIN
        OPEN P_RESULT FOR
        SELECT
               CD_POLO,
               DS_POLO,
               IC_ATIVO,
               DH_INCLUSAO,
               DH_ULT_ALTERACAO,
               CD_USUARIO_INCLUSAO,
               CD_USUARIO_ALTERACAO
          FROM
               CTF.POLO;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000,'MENSAGEM' || SQLERRM);
    END PX_GET_POLOS;



    PROCEDURE px_elo_status (
        p_sg_tipo_status    IN vnd.elo_tipo_status.sg_tipo_status%TYPE,
        p_order_by          IN varchar2,
        p_order             IN varchar2,
        p_result            OUT t_cursor
    )
    IS
    BEGIN
        OPEN p_result FOR
        SELECT es.cd_elo_status,
               es.ds_status,
               es.nu_order

          FROM vnd.elo_status es

         INNER JOIN vnd.elo_tipo_status ts
            ON ts.cd_elo_tipo_status = es.cd_elo_tipo_status

         WHERE ts.sg_tipo_status = p_sg_tipo_status

         ORDER BY 
                  CASE WHEN p_order = 'ASC' AND p_order_by = 'ID' THEN es.cd_elo_status END,
                  CASE WHEN p_order = 'DESC' AND p_order_by = 'ID' THEN es.cd_elo_status END DESC,
                  CASE WHEN p_order = 'ASC' AND p_order_by = 'DESCRIPTION' THEN es.ds_status END,
                  CASE WHEN p_order = 'DESC' AND p_order_by = 'DESCRIPTION' THEN es.ds_status END DESC,
                  CASE WHEN p_order = 'ASC' AND p_order_by = 'ORDER' THEN es.nu_order END,
                  CASE WHEN p_order = 'DESC' AND p_order_by = 'ORDER' THEN es.nu_order END DESC
         ;
    END px_elo_status
    ;



    FUNCTION fx_elo_status_order (
        p_sg_tipo_status    IN vnd.elo_tipo_status.sg_tipo_status%TYPE,
        p_sg_status         IN vnd.elo_status.sg_status%TYPE
    ) RETURN vnd.elo_status.nu_order%TYPE
    IS
        v_result vnd.elo_status.nu_order%TYPE;
    BEGIN
        SELECT NVL(es.nu_order, -1)
            INTO v_result
            FROM vnd.elo_status es
        INNER JOIN vnd.elo_tipo_status ts
            ON ts.cd_elo_tipo_status = es.cd_elo_tipo_status
            WHERE ts.sg_tipo_status = p_sg_tipo_status
            AND es.sg_status = p_sg_status
        ;

        RETURN v_result;
    END fx_elo_status_order;



    FUNCTION fx_elo_status_order (
        p_cd_elo_status    IN vnd.elo_status.cd_elo_status%TYPE
    ) RETURN vnd.elo_status.nu_order%TYPE
    IS
        v_result vnd.elo_status.nu_order%TYPE;
    BEGIN
        SELECT NVL(es.nu_order, -1)
            INTO v_result
            FROM vnd.elo_status es
            WHERE es.cd_elo_status = p_cd_elo_status
        ;

        RETURN v_result;
    END fx_elo_status_order;
    
    
    
    FUNCTION fx_previous_scheduling (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_polo               IN vnd.elo_agendamento.cd_polo%TYPE,
        p_cd_centro_expedidor   IN vnd.elo_agendamento.cd_centro_expedidor%TYPE,
        p_cd_machine            IN vnd.elo_agendamento.cd_machine%TYPE,
        p_weeks                 IN NUMBER DEFAULT 1
    ) RETURN vnd.elo_agendamento.cd_elo_agendamento%TYPE
    IS
        v_result vnd.elo_agendamento.cd_elo_agendamento%TYPE;
    BEGIN
        SELECT cd_elo_agendamento
          INTO v_result
          FROM (
                    SELECT * 
                      FROM vnd.elo_agendamento ag
                     WHERE ag.dt_week_start = TRUNC((
                                                SELECT dt_week_start - (7 * p_weeks)
                                                  FROM vnd.elo_agendamento 
                                                 WHERE cd_elo_agendamento = p_cd_elo_agendamento
                                              ),'iw')
                           AND (p_cd_polo IS NULL OR ag.cd_polo = p_cd_polo)
                           AND (p_cd_centro_expedidor IS NULL OR ag.cd_centro_expedidor = p_cd_centro_expedidor)
                           AND (p_cd_machine IS NULL OR ag.cd_machine = p_cd_machine)
                           AND ag.ic_ativo = 'S'
                     ORDER BY ag.dt_week_start DESC
               )
         WHERE ROWNUM = 1
        ;
        RETURN v_result;
    END fx_previous_scheduling;
    
    
    
    FUNCTION fx_previous_scheduling (
        p_cd_elo_agendamento    IN vnd.elo_agendamento.cd_elo_agendamento%TYPE,
        p_cd_site               IN CHAR,
        p_site_type             IN CHAR,
        p_weeks                 IN NUMBER DEFAULT 1
    ) RETURN vnd.elo_agendamento.cd_elo_agendamento%TYPE
    IS
        v_result vnd.elo_agendamento.cd_elo_agendamento%TYPE;
    BEGIN
        SELECT cd_elo_agendamento
          INTO v_result
          FROM (
                    SELECT * 
                      FROM vnd.elo_agendamento ag
                     WHERE ag.dt_week_start = TRUNC((
                                                SELECT dt_week_start - (7 * p_weeks)
                                                  FROM vnd.elo_agendamento 
                                                 WHERE cd_elo_agendamento = p_cd_elo_agendamento
                                              ),'iw')
                           AND (
                                    CASE WHEN p_site_type = 'P' AND ag.CD_POLO = p_cd_site THEN 1
                                         WHEN p_site_type = 'C' AND ag.CD_CENTRO_EXPEDIDOR = p_cd_site THEN 1
                                         WHEN p_site_type = 'M' AND ag.CD_MACHINE = p_cd_site THEN 1
                                         ELSE 0
                                    END = 1 
                               )
                           AND ag.ic_ativo = 'S'
                     ORDER BY ag.dt_week_start DESC
               )
         WHERE ROWNUM = 1
        ;
        RETURN v_result;
    END fx_previous_scheduling;
    
    
END GX_ELO_COMMON;
/