CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_PLANNING" AS

    PROCEDURE PX_SEARCH_PLANNING (
        P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MACHINES              IN VARCHAR,
        P_WEEK                  IN INT,
        P_RETURN                OUT T_CURSOR)
        
    IS
    BEGIN
        OPEN P_RETURN FOR

        select distinct 
               ag.CD_ELO_AGENDAMENTO                                                as CodeAgendamento,
               ag.CD_WEEK                                                           as SEMANA,
               ag.CD_ELO_STATUS                                                     as CD_STATUS,
               es.DS_STATUS                                                         as CLASSIFICACAO,
               es2.DS_STATUS                                                        as TIPO_REPLAN,
               to_char(ec.DH_BACKLOG_CIF)                                           as BACKLOG,
               ec.DS_CENTRO_EXPEDIDOR                                               as CENTRO,
               ma.DS_MACHINE                                                        as MAQUINA,
               ec.CD_INCOTERMS                                                      as INCOTERM,
               ec.CD_CLIENTE                                                        as CD_CLIENTE,
               ec.NO_CLIENTE                                                        as DS_CLIENTE,
               eai.CD_COTA_COMPARTILHADA                                            as COTA,
               u.CD_USUARIO || '-' || u.NO_USUARIO                                  as SUPERVISOR,
               ge.DS_GRUPO_EMBALAGEM                                                as EMBALAGEM,
               (CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                     THEN NVL(tf.CD_DIA_EXATO, ' ') 
                     ELSE ' ' END)                                                  as DIA_EXATO,
               (CASE WHEN ec.CD_TIPO_AGENDAMENTO = GX_ELO_COMMON.FX_ELO_STATUS('TIPAG','REPLAN')
                      AND ec.CD_TIPO_REPLAN <> GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','INCLUSAO')
                     THEN (ec.QT_PROGRAMADA * -1)
                     ELSE ec.QT_PROGRAMADA END)                                     as VALOR,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 1
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 1 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as SEG,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 2
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 2 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as TER,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 3
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 3 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as QUA,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 4
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 4 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as QUI,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 5
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 5 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as SEX,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 6
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 6 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as SAB,
               to_char((CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                              AND tf.CD_DIA_EXATO != '' 
                              AND tf.NU_DIA_SEMANA = 7
                             THEN NVL(tf.NU_QUANTIDADE, 0) 
                             ELSE 
                              (CASE WHEN tf.NU_DIA_SEMANA = 7 
                                    THEN NVL(tf.NU_QUANTIDADE, 0) 
                                    ELSE 0
                                END)
                        END))                                                       as DOM
          from VND.ELO_CARTEIRA ec
          left join VND.ELO_CARTEIRA_DAY ecd
            on ecd.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
         inner join VND.ELO_AGENDAMENTO_ITEM eai
            on ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
         inner join CTF.USUARIO u
            on ec.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
         inner join VND.GRUPO_EMBALAGEM ge
            on ec.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM
         inner join VND.ELO_AGENDAMENTO ag
            on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
         inner join VND.ELO_CARTEIRA_TORRE_FRETES tf
            on tf.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
         inner join VND.ELO_STATUS es
            on es.CD_ELO_STATUS = ag.CD_ELO_STATUS
          left join VND.ELO_STATUS es2
            on ec.CD_TIPO_REPLAN = es2.CD_ELO_STATUS
          left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE
         where ec.IC_ATIVO = 'S'
           and ag.IC_ATIVO = 'S'
           and ge.IC_ATIVO = 'S'
           and es.SG_STATUS IN ('PLAN','AGCTR','AGENC')
           and ec.QT_AGENDADA_CONFIRMADA > 0
           and (P_POLO is null or ag.CD_POLO = P_POLO) 
           and (P_CD_CENTRO_EXPEDIDOR is null or ec.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
           and (P_MACHINES is null or ag.CD_MACHINE IN (P_MACHINES))
           and (P_WEEK is null or to_number(to_char(to_date(ag.DT_WEEK_START,'DD/MM/YYYY'),'WW')) = P_WEEK);

    END PX_SEARCH_PLANNING;

    --TODO: Corrigir
    PROCEDURE PU_UPDATE_STATUS_PLANNING (
        P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MACHINES              IN VARCHAR,
        P_WEEK                  IN INT,
        P_STATUS                IN VARCHAR2,
        P_RETURN                OUT T_CURSOR)

    IS

        V_CD_ELO_STATUS    NUMBER(9);

    BEGIN

        select es.CD_ELO_STATUS
          into V_CD_ELO_STATUS
          from VND.ELO_STATUS es
         where es.SG_STATUS = P_STATUS;

        update VND.ELO_AGENDAMENTO
           set CD_ELO_STATUS = V_CD_ELO_STATUS
         where CD_ELO_AGENDAMENTO IN ( select distinct
                                              ag.CD_ELO_AGENDAMENTO
                                         from VND.ELO_CARTEIRA ec
                                        inner join VND.ELO_AGENDAMENTO ag
                                           on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                                        inner join VND.ELO_STATUS es
                                           on es.CD_ELO_STATUS = ag.CD_ELO_STATUS
                                        where ec.IC_ATIVO = 'S'
                                          and ag.IC_ATIVO = 'S'
                                          and es.SG_STATUS IN ('PLAN','AGCTR','AGENC')
                                          and ec.QT_AGENDADA_CONFIRMADA > 0
                                          and (P_POLO is null or ag.CD_POLO = P_POLO) 
                                          and (P_CD_CENTRO_EXPEDIDOR is null or ec.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
                                          and (P_MACHINES is null or ag.CD_MACHINE IN (P_MACHINES))
                                          and (P_WEEK is null or to_number(to_char(to_date(ag.DT_WEEK_START,'DD/MM/YYYY'),'WW')) = P_WEEK));

        OPEN P_RETURN FOR
            select 1 as CodeAgendamento from dual;

    EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: PU_UPDATE_STATUS_PLANNING - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;

    END PU_UPDATE_STATUS_PLANNING;

END GX_ELO_PLANNING;


/