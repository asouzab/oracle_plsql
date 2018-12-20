CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_SEMANAL_PAGINA" AS

 FUNCTION FX_INTERVAL_TO_STRING (P_INTERVAL IN VND.ELO_MARCACAO.IT_TMAC_CLIENTE%TYPE) RETURN varchar2
    IS
        V_RESULT VARCHAR2(10);
    BEGIN

        IF (P_INTERVAL IS NOT NULL) THEN
            select 
                    LPAD(EXTRACT(DAY FROM P_INTERVAL),2,'0')
                    ||
                    ':'
                    ||
                    LPAD(EXTRACT(HOUR FROM P_INTERVAL),2,'0')
                    || 
                    ':' 
                    || 
                    LPAD(EXTRACT(MINUTE FROM P_INTERVAL),2,'0')
              into V_RESULT
              from dual;
        ELSE
            V_RESULT := '0';
        END IF;

        RETURN v_result;

    END FX_INTERVAL_TO_STRING;

PROCEDURE PX_GET_CENTROS (P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN

  OPEN P_RETORNO FOR
    SELECT DISTINCT AG.CD_CENTRO_EXPEDIDOR, CE.DS_CENTRO_EXPEDIDOR
    FROM VND.ELO_AGENDAMENTO AG
    INNER JOIN CTF.CENTRO_EXPEDIDOR CE
    ON AG.CD_CENTRO_EXPEDIDOR = CE.CD_CENTRO_EXPEDIDOR
    WHERE CE.IC_ATIVO='S'
    ORDER BY CE.DS_CENTRO_EXPEDIDOR;

  END PX_GET_CENTROS;

 PROCEDURE PX_GET_CENTRO_FROM_MAQUINA (
                                        P_CD_MACHINE VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN

  OPEN P_RETORNO FOR
    SELECT  CEM.CD_CENTRO_EXPEDIDOR, CE.DS_CENTRO_EXPEDIDOR
    FROM CTF.CENTRO_EXPEDIDOR_MACHINE CEM
    INNER JOIN CTF.CENTRO_EXPEDIDOR CE
    ON CEM.CD_CENTRO_EXPEDIDOR = CE.CD_CENTRO_EXPEDIDOR
    WHERE
        CEM.CD_MACHINE = P_CD_MACHINE
        AND 
        CE.IC_ATIVO='S'
        AND 
        CEM.IC_ATIVO='S'
    ORDER BY CE.DS_CENTRO_EXPEDIDOR;

  END PX_GET_CENTRO_FROM_MAQUINA;

PROCEDURE PX_GET_MAQUINAS (P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN

  OPEN P_RETORNO FOR
    select distinct ag.CD_MACHINE, mac.DS_MACHINE 
    from VND.ELO_AGENDAMENTO ag
    inner join CTF.MACHINE mac on ag.CD_MACHINE = mac.CD_MACHINE
    where mac.IC_ATIVO='S'
    order by mac.DS_MACHINE;

  END PX_GET_MAQUINAS;

PROCEDURE PX_GET_MAQUINAS_FROM_CENTRO (
                                        P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN

  OPEN P_RETORNO FOR
    select cem.CD_MACHINE, mac.DS_MACHINE 
    from CTF.CENTRO_EXPEDIDOR_MACHINE cem
    inner join CTF.MACHINE mac on cem.CD_MACHINE = mac.CD_MACHINE
    where 
    cem.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
    and
    cem.IC_ATIVO='S'
    and 
    mac.IC_ATIVO='S'
    order by mac.DS_MACHINE;

  END PX_GET_MAQUINAS_FROM_CENTRO;   

PROCEDURE PX_GET_SEMANAS (P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN

  OPEN P_RETORNO FOR
    SELECT DISTINCT AG.CD_WEEK
    FROM VND.ELO_AGENDAMENTO AG
    WHERE AG.IC_ATIVO='S'
    ORDER BY AG.CD_WEEK desc;

  END PX_GET_SEMANAS;

PROCEDURE PX_GET_BLOCO_SEMANAS( P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                P_CD_MACHINE VARCHAR2,
                                P_CD_WEEK_LIST VARCHAR2,
                                P_RETORNO     OUT T_CURSOR
) AS
BEGIN

    OPEN P_RETORNO FOR
    SELECT 
        ag.CD_WEEK, ag.DT_WEEK_START, ag.CD_ELO_AGENDAMENTO, ag.CD_CENTRO_EXPEDIDOR, ag.CD_MACHINE
    from 
        VND.ELO_AGENDAMENTO ag
    where   
        ( ag.CD_WEEK IN (SELECT * FROM TABLE(vnd.gx_elo_common.fx_split(P_CD_WEEK_LIST,','))) )
        and
        ( 
            ( P_CD_CENTRO_EXPEDIDOR = '#' ) or 
            ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR )
        )
        and
        ( 
            ( P_CD_MACHINE = '#' ) or 
            ( ag.CD_MACHINE = P_CD_MACHINE ) 
        )
        and
        ag.IC_ATIVO='S'   
order by 
    ag.DT_WEEK_START desc, ag.CD_ELO_AGENDAMENTO asc;

END PX_GET_BLOCO_SEMANAS;

PROCEDURE PX_GET_SEMANAL_LINHAS (  P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_RETORNO     OUT T_CURSOR
    ) AS

  BEGIN


            CASE P_LINHA_TO_EXEC
                --01
                WHEN '01' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'Faturamento Total' grupo,
                    'Capacidade Planejada' item, 
                    carteira.CD_TIPO_AGENDAMENTO,
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
--                        inner join VND.ELO_MATINAL matinal
--                            on ag.CD_ELO_AGENDAMENTO = matinal.CD_ELO_AGENDAMENTO
--                        inner join VND.ELO_PRODUCTION_LOSS prodloss
--                            on ag.CD_ELO_AGENDAMENTO = prodloss.CD_ELO_AGENDAMENTO
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                    where   ( ag.CD_WEEK = P_CD_WEEK )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and

                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                        order by cartday.NU_DIA_SEMANA ;

                WHEN '02' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'FATURAMENTO TOTAL' grupo,
                    'ASSERT.TOTAL FAT ' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.QT_FATURADO NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where       ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( ag.CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( ag.CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                --04
                WHEN '04' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'Faturamento Total' grupo,
                    'Assertiv.Total Fat.' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
--                        inner join VND.ELO_MATINAL matinal
--                            on ag.CD_ELO_AGENDAMENTO = matinal.CD_ELO_AGENDAMENTO
--                        inner join VND.ELO_PRODUCTION_LOSS prodloss
--                            on ag.CD_ELO_AGENDAMENTO = prodloss.CD_ELO_AGENDAMENTO
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                    where       ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )          
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;  

                --05
                WHEN '05' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'CIF' grupo,
                    'Total CIF' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,
                    (
                    select distinct st.CD_ELO_TIPO_STATUS 
                    from VND.ELO_STATUS st
                                inner join VND.ELO_TIPO_STATUS tpst
                                on st.CD_ELO_TIPO_STATUS = tpst.CD_ELO_TIPO_STATUS
                             where
                             st.SG_STATUS<>'REPLAN' 
                             and
                             tpst.SG_TIPO_STATUS = 'TIPAG'
                             and 
                             st.CD_ELO_TIPO_STATUS=carteira.CD_TIPO_AGENDAMENTO

                    ) Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI

                    from VND.ELO_AGENDAMENTO ag
--                        inner join VND.ELO_MATINAL matinal
--                            on ag.CD_ELO_AGENDAMENTO = matinal.CD_ELO_AGENDAMENTO
--                        inner join VND.ELO_PRODUCTION_LOSS prodloss
--                            on ag.CD_ELO_AGENDAMENTO = prodloss.CD_ELO_AGENDAMENTO
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                    where       ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                                carteira.CD_INCOTERMS='CIF'
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;
                --06
                WHEN '06' THEN
                OPEN P_RETORNO FOR
                SELECT
                'CIF' grupo,
                'Planejado CIF' item, 
                carteira.CD_TIPO_AGENDAMENTO, 
                cartday.NU_DIA_SEMANA, 
                cartday.NU_QUANTIDADE,  
                (
                select distinct st.CD_ELO_TIPO_STATUS 
                from VND.ELO_STATUS st
                            inner join VND.ELO_TIPO_STATUS tpst
                            on st.CD_ELO_TIPO_STATUS = tpst.CD_ELO_TIPO_STATUS
                         where
                         st.SG_STATUS = 'REPLAN' 
                         and
                         tpst.SG_TIPO_STATUS = 'TIPAG'
                         and 
                         st.CD_ELO_TIPO_STATUS=carteira.CD_TIPO_AGENDAMENTO

                ) Tipo_De_Status,
                0 PKTAB,
                0 FKTABPAI

                from VND.ELO_AGENDAMENTO ag
--                    inner join VND.ELO_MATINAL matinal
--                        on ag.CD_ELO_AGENDAMENTO = matinal.CD_ELO_AGENDAMENTO
--                    inner join VND.ELO_PRODUCTION_LOSS prodloss
--                        on ag.CD_ELO_AGENDAMENTO = prodloss.CD_ELO_AGENDAMENTO
                    inner join VND.ELO_CARTEIRA carteira
                        on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                    inner join VND.ELO_CARTEIRA_DAY cartday
                        on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                where       ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            carteira.CD_INCOTERMS='CIF'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                    order by cartday.NU_DIA_SEMANA ;

                WHEN '07' THEN
                OPEN P_RETORNO FOR
                SELECT 
                'CIF' grupo,
                'Backlog' item, 
                '' CD_TIPO_AGENDAMENTO,
                1 NU_DIA_SEMANA, 
                carteira.QT_BACKLOG_CIF NU_QUANTIDADE,
                0 Tipo_De_Status,
                0 PKTAB,
                0 FKTABPAI
                from VND.ELO_AGENDAMENTO ag
                     inner join VND.ELO_CARTEIRA carteira
                        on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                where       ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            carteira.CD_INCOTERMS='CIF'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                WHEN '08' THEN
                OPEN P_RETORNO FOR
                SELECT 
                'CIF' grupo,
                'FATURADO CIF ' item, 
                '' CD_TIPO_AGENDAMENTO,
                ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                marc.DH_FATURAMENTO,
                marc.QT_FATURADO NU_QUANTIDADE,
                0 Tipo_De_Status,
                0 PKTAB,
                0 FKTABPAI
                --para validar chaves apenas
                --,ag.CD_ELO_AGENDAMENTO,
                --cart.CD_ELO_CARTEIRA,
                --marc.CD_ELO_MARCACAO
                from VND.ELO_AGENDAMENTO ag
                    inner join VND.ELO_CARTEIRA cart
                        on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                    inner join VND.ELO_MARCACAO marc
                        on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                where       (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_INCOTERMS='CIF'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                --09
                WHEN '09' THEN
                OPEN P_RETORNO FOR
                SELECT 
                'CIF' grupo,
                'MARCAÇÃO CIF ' item, 
                '' CD_TIPO_AGENDAMENTO,
                ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                marc.DH_FATURAMENTO,
                marc.NU_QUANTIDADE NU_QUANTIDADE,
                0 Tipo_De_Status,
                0 PKTAB,
                0 FKTABPAI
                --para validar chaves apenas
                --,ag.CD_ELO_AGENDAMENTO,
                --cart.CD_ELO_CARTEIRA,
                --marc.CD_ELO_MARCACAO
                from VND.ELO_AGENDAMENTO ag
                    inner join VND.ELO_CARTEIRA cart
                        on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                    inner join VND.ELO_MARCACAO marc
                        on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                where       (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_INCOTERMS='CIF'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                --13            
                WHEN '13' THEN
                OPEN P_RETORNO FOR
                    SELECT 
                    'FOB' grupo,
                    'TOTAL FOB' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                    on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            carteira.CD_INCOTERMS='FOB'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                    --14
                    WHEN '14' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'FOB' grupo,
                    'Planejado FOB' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,  
                    (
                    select distinct st.CD_ELO_TIPO_STATUS 
                    from VND.ELO_STATUS st
                                inner join VND.ELO_TIPO_STATUS tpst
                                on st.CD_ELO_TIPO_STATUS = tpst.CD_ELO_TIPO_STATUS
                             where
                             st.SG_STATUS <> 'REPLAN' 
                             and
                             tpst.SG_TIPO_STATUS = 'TIPAG'
                             and 
                             st.CD_ELO_TIPO_STATUS=carteira.CD_TIPO_AGENDAMENTO

                    ) Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                    on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            carteira.CD_INCOTERMS='FOB'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                    --15
                    WHEN '15' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'FOB' grupo,
                    'REPLAN FOB' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,  
                    (
                    select distinct st.CD_ELO_TIPO_STATUS 
                    from VND.ELO_STATUS st
                                inner join VND.ELO_TIPO_STATUS tpst
                                on st.CD_ELO_TIPO_STATUS = tpst.CD_ELO_TIPO_STATUS
                             where
                             st.SG_STATUS = 'REPLAN' 
                             and
                             tpst.SG_TIPO_STATUS = 'TIPAG'
                             and 
                             st.CD_ELO_TIPO_STATUS=carteira.CD_TIPO_AGENDAMENTO

                    ) Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                    on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            carteira.CD_INCOTERMS='FOB'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                    --16        
                    WHEN '16' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'FOB' grupo,
                    'SEM COTA' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            marc.SG_CLASSIFICACAO = 'SEMPLAN'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                    --17
                    WHEN '17' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'FOB' grupo,
                    'FATURADO FOB ' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.QT_FATURADO NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_INCOTERMS='FOB'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                    --18        
                    WHEN '18' THEN
                    OPEN P_RETORNO FOR
                    SELECT
                    'FOB' grupo,
                    'MARCAÇÃO FOB' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_INCOTERMS='FOB'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

                    --29
                    WHEN '29' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'MARCAÇÃO TOTAL DIA' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )

                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                    --30
                    WHEN '30' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'MARCAÇÃO SACARIA' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_GRUPO_EMBALAGEM = 'S'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                    --31
                    WHEN '31' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'MARCAÇÃO BIG BAG' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_GRUPO_EMBALAGEM = 'B'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                    --32
                    WHEN '32' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'MARCAÇÃO GRANEL' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            cart.CD_GRUPO_EMBALAGEM = 'G'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                    --33
                    WHEN '33' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'ANTECIPADO TONS' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_ANTECIPACAO_QUOTAS,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                    --inner join VND.ELO_MATINAL mat
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                    where   
                        ( ag.CD_WEEK = P_CD_WEEK )
                        and
                        ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                        and
                        ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                        and
                        ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                    --order by MAT.NU_DIA_SEMANA ;
                    order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;

                    --34
                    WHEN '34' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'TOTAL SOBRAS DIA ANTERIOR' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_TOTAL_SOBRA_DIA_ANTERIOR,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        --order by MAT.NU_DIA_SEMANA ;
                        order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;

                    --35
                    WHEN '35' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'SOBRAS SACARIA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_SACARIA,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;
                        --order by MAT.NU_DIA_SEMANA ;

                    --36
                    WHEN '36' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'SOBRAS BIG BAG' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_BIG_BAG,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;
                        --order by MAT.NU_DIA_SEMANA ;    

                    --37
                    WHEN '37' THEN
                    OPEN P_RETORNO FOR 
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'SOBRAS GRANEL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_GRANEL,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;
                        --order by MAT.NU_DIA_SEMANA ;  

                    --38
                    WHEN '38' THEN
                    OPEN P_RETORNO FOR 
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'SALDO A INGRESSAR NO SAP' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SALDO_INGRESSAR_SAP,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;
                        --order by MAT.NU_DIA_SEMANA ;

                    --39
                    WHEN '39' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'VOLUME COM PROBLEMA' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                    where   ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                                marc.CD_MOTIVO_STATUS <> ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;

                    --40
                    WHEN '40' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'MARCAÇÃO' grupo,
                    'VOLUME ACIMA 24HS' item, 
                    '' CD_TIPO_AGENDAMENTO,
                    ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) NU_DIA_SEMANA,
                    --marc.DH_FATURAMENTO,
                    marc.NU_QUANTIDADE NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    --para validar chaves apenas
                    --,ag.CD_ELO_AGENDAMENTO,
                    --cart.CD_ELO_CARTEIRA,
                    --marc.CD_ELO_MARCACAO
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'

                    where       ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                                marc.DH_SAIDA IS NULL
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   ;    

                    --42
                    WHEN '42' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'OPERACIONAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PO'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='PO'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;   
                        --order by ploss.NU_DIA_SEMANA ;

                    --usado qdo ploss com where mais especifico nao retorna valor
                    --
                    WHEN '42a' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'OPERACIONAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    0 NU_DIA_SEMANA,
                    0 NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PO'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                            order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;
                        --order by ploss.CD_ELO_AGENDAMENTO, ploss.NU_DIA_SEMANA ;

                    --43
                    WHEN '43' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'EMERGENCIAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PE'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='PE'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;
                        --order by ploss.NU_DIA_SEMANA ;


                    --44
                    WHEN '44' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'FATOR EXTERNO-PROCESSO' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='1'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='FE'
                            and
                            ploss.CD_PRODUCTION_STOP_SUBTYPE='1'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;   
                        --order by ploss.NU_DIA_SEMANA ;


                    --45
                    WHEN '45' THEN
                    OPEN P_RETORNO FOR    
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'FATOR EXTERNO-CARTEIRA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='2'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='FE'
                            and
                            ploss.CD_PRODUCTION_STOP_SUBTYPE='2'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;
                        --order by ploss.NU_DIA_SEMANA ;

                    --46
                    WHEN '46' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'FATOR EXTERNO-FLUXO CAMINHÃO' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='3'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='FE'
                            and
                            ploss.CD_PRODUCTION_STOP_SUBTYPE='3'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;
                        --order by ploss.NU_DIA_SEMANA ;


                    --47
                    WHEN '47' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'FATOR EXTERNO-MATPRIMA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='4'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='FE'
                            and
                            ploss.CD_PRODUCTION_STOP_SUBTYPE='4'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;
                        --order by ploss.NU_DIA_SEMANA ;

                    --48
                    WHEN '48' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'PERDA PRODUÇÃO' grupo,
                    'FATOR EXTERNO-OUTROS' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='5'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                            and
                            ploss.CD_PRODUCTION_STOP_TYPE='FE'
                            and
                            ploss.CD_PRODUCTION_STOP_SUBTYPE='5'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by ploss.CD_ELO_AGENDAMENTO, ploss.CD_ELO_PRODUCTION_LOSS, ploss.NU_DIA_SEMANA;
                        --order by ploss.NU_DIA_SEMANA ;


                    --49
                    WHEN '49' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'Vol.Prod(apontamento industrial)' grupo,
                    'real' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_VOLUME_PRODUZIDO,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir não tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                            ( ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by mat.CD_ELO_AGENDAMENTO, mat.CD_ELO_MATINAL, mat.NU_DIA_SEMANA;
                        --order by MAT.NU_DIA_SEMANA ;

                    --51
                    WHEN '51' THEN
                    OPEN P_RETORNO FOR
                    Select
                    'Carteira Mes Vigente' grupo,
                    'Bloqueada' item,
                    NVL(cart.CD_TIPO_AGENDAMENTO,0) CD_TIPO_AGENDAMENTO, 
                    NVL(cartday.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    NVL(cartday.NU_QUANTIDADE,0) NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI

                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on cart.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                        where   
                                ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                                and
                                cart.CD_BLOQUEIO_REMESSA <> ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO <> ''
                                and
                                cart.CD_BLOQUEIO_CREDITO <> ''
                                and
                                cart.CD_BLOQUEIO_REMESSA_ITEM <> ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO_ITEM <> ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;

                    --52
                    WHEN '52' THEN
                    OPEN P_RETORNO FOR
                    Select
                    'CARTEIRA MES VIGENTE' grupo,
                    'LIBERADA' item,
                    NVL(cart.CD_TIPO_AGENDAMENTO,0) CD_TIPO_AGENDAMENTO, 
                    NVL(cartday.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    NVL(cartday.NU_QUANTIDADE,0) NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI

                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on cart.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                        where   
                                ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                                and
                                cart.CD_BLOQUEIO_REMESSA = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO = ''
                                and
                                cart.CD_BLOQUEIO_CREDITO = ''
                                and
                                cart.CD_BLOQUEIO_REMESSA_ITEM = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO_ITEM = ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;


                    --53
                    WHEN '53' THEN
                    OPEN P_RETORNO FOR
                    Select
                    'CARTEIRA COM PROTOCOLO' grupo,
                    'REAL' item,
                    NVL(cart.CD_TIPO_AGENDAMENTO,0) CD_TIPO_AGENDAMENTO, 
                    NVL(cartday.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    NVL(cartday.NU_QUANTIDADE,0) NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI

                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on cart.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                        where   
                                ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                                and
                                cart.IC_COOPERATIVE = 'S'
                                and
                                cart.CD_INCOTERMS = 'CIF'
                                and
                                cart.CD_BLOQUEIO_REMESSA = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO = ''
                                and
                                cart.CD_BLOQUEIO_CREDITO = ''
                                and
                                cart.CD_BLOQUEIO_REMESSA_ITEM = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO_ITEM = ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;

                    --54
                    WHEN '54' THEN
                    OPEN P_RETORNO FOR
                    Select
                    'CARTEIRA NORMAL LIBERADA CIF' grupo,
                    'REAL' item,
                    NVL(cart.CD_TIPO_AGENDAMENTO,0) CD_TIPO_AGENDAMENTO, 
                    NVL(cartday.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    NVL(cartday.NU_QUANTIDADE,0) NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on cart.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                        where   
                                ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                                and
                                cart.IC_COOPERATIVE = 'N'
                                and
                                cart.CD_INCOTERMS = 'CIF'
                                and
                                cart.CD_BLOQUEIO_REMESSA = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO = ''
                                and
                                cart.CD_BLOQUEIO_CREDITO = ''
                                and
                                cart.CD_BLOQUEIO_REMESSA_ITEM = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO_ITEM = ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;

                    --55
                    WHEN '55' THEN
                    OPEN P_RETORNO FOR
                    Select
                    'CARTEIRA PROTOCOLO LIBERADO FOB' grupo,
                    'REAL' item,
                    NVL(cart.CD_TIPO_AGENDAMENTO,0) CD_TIPO_AGENDAMENTO, 
                    NVL(cartday.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    NVL(cartday.NU_QUANTIDADE,0) NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on cart.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                        where   
                                ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                                and
                                cart.IC_COOPERATIVE = 'S'
                                and
                                cart.CD_INCOTERMS = 'FOB'
                                and
                                cart.CD_BLOQUEIO_REMESSA = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO = ''
                                and
                                cart.CD_BLOQUEIO_CREDITO = ''
                                and
                                cart.CD_BLOQUEIO_REMESSA_ITEM = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO_ITEM = ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;

                     --56
                    WHEN '56' THEN
                    OPEN P_RETORNO FOR
                    Select
                    'CARTEIRA NORMAL LIBERADA FOB' grupo,
                    'REAL' item,
                    NVL(cart.CD_TIPO_AGENDAMENTO,0) CD_TIPO_AGENDAMENTO, 
                    NVL(cartday.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    NVL(cartday.NU_QUANTIDADE,0) NU_QUANTIDADE,  
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on cart.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                        where   
                                ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) ) 
                                and
                                cart.IC_COOPERATIVE = 'N'
                                and
                                cart.CD_INCOTERMS = 'FOB'
                                and
                                cart.CD_BLOQUEIO_REMESSA = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO = ''
                                and
                                cart.CD_BLOQUEIO_CREDITO = ''
                                and
                                cart.CD_BLOQUEIO_REMESSA_ITEM = ''
                                and
                                cart.CD_BLOQUEIO_FATURAMENTO_ITEM = ''
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;

                    WHEN '57' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'Capacidade' grupo,
                    'Planejada Grafico' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,
                    (
                    select distinct st.CD_ELO_TIPO_STATUS 
                    from VND.ELO_STATUS st
                                inner join VND.ELO_TIPO_STATUS tpst
                                on st.CD_ELO_TIPO_STATUS = tpst.CD_ELO_TIPO_STATUS
                             where
                             st.SG_STATUS = 'REPLAN' 
                             and
                             tpst.SG_TIPO_STATUS = 'TIPAG'
                             and 
                             st.CD_ELO_TIPO_STATUS=carteira.CD_TIPO_AGENDAMENTO

                    ) Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI

                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                            on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA

                    where       ( ag.CD_WEEK = P_CD_WEEK )
                                and
                                ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                                ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                                carteira.CD_INCOTERMS='CIF'
                                and
                                ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )   
                        order by cartday.NU_DIA_SEMANA ;

                    WHEN '58' THEN
                    OPEN P_RETORNO FOR
                    SELECT 
                    'FOB' grupo,
                    'Planejado FOB' item, 
                    carteira.CD_TIPO_AGENDAMENTO, 
                    cartday.NU_DIA_SEMANA, 
                    cartday.NU_QUANTIDADE,  
                    (
                    select distinct st.CD_ELO_TIPO_STATUS 
                    from VND.ELO_STATUS st
                                inner join VND.ELO_TIPO_STATUS tpst
                                on st.CD_ELO_TIPO_STATUS = tpst.CD_ELO_TIPO_STATUS
                             where
                             st.SG_STATUS = 'REPLAN' 
                             and
                             tpst.SG_TIPO_STATUS = 'TIPAG'
                             and 
                             st.CD_ELO_TIPO_STATUS=carteira.CD_TIPO_AGENDAMENTO

                    ) Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA carteira
                            on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                        inner join VND.ELO_CARTEIRA_DAY cartday
                    on carteira.CD_ELO_CARTEIRA = cartday.CD_ELO_CARTEIRA
                    where   (ag.CD_WEEK = P_CD_WEEK )
                            and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                            and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                            and
                            carteira.CD_INCOTERMS='FOB'
                            and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO );

            END CASE;



  END PX_GET_SEMANAL_LINHAS;



END GX_ELO_SEMANAL_PAGINA;


/