CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_MATINAL_PAGINA AS

PROCEDURE PUI_ELO_MATINAL(  P_PK VARCHAR2,
                            P_FK VARCHAR2,
                            P_QTD number,
                            P_DAY number,
                            P_LINE varchar2
) AS
  BEGIN
    
    Declare contador_Matinal number := 0;
            contador_PrdLoss number :=0;
            numero_Semana number :=0; 

    Begin
        
        Select count(CD_ELO_MATINAL) into contador_Matinal from VND.ELO_MATINAL where rownum = 1 order by CD_ELO_MATINAL desc;
        Select count(CD_ELO_PRODUCTION_LOSS) into contador_PrdLoss from VND.ELO_PRODUCTION_LOSS where rownum = 1 order by CD_ELO_PRODUCTION_LOSS DESC;
        
        SELECT to_number(to_char(to_date('30/10/2017','DD/MM/YYYY'),'WW')) into numero_Semana FROM DUAL;
        
        Begin
            if contador_Matinal=0 then
                contador_Matinal:=1;
            else
                Select (CD_ELO_MATINAL+1) into contador_Matinal from VND.ELO_MATINAL where rownum = 1 order by CD_ELO_MATINAL desc;
            end if;
            
            if contador_PrdLoss=0 then
                contador_PrdLoss:=1;
            else
                Select (CD_ELO_PRODUCTION_LOSS+1) y into contador_PrdLoss from VND.ELO_PRODUCTION_LOSS  where rownum = 1 order by CD_ELO_PRODUCTION_LOSS desc;
            end if;
            
        end;
        
        IF P_PK = '0' THEN
          begin
            --insert
            CASE P_LINE
                WHEN '33' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_ANTECIPACAO_QUOTAS)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                 WHEN '34' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_TOTAL_SOBRA_DIA_ANTERIOR)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                WHEN '35' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_SOBRA_SACARIA)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                WHEN '36' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_SOBRA_BIG_BAG)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                WHEN '37' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_SOBRA_GRANEL)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                WHEN '38' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_SALDO_INGRESSAR_SAP)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                WHEN '49' THEN
                    insert into VND.ELO_MATINAL mt
                            ( mt.CD_ELO_MATINAL,    mt.CD_ELO_AGENDAMENTO,  mt.NU_DIA_SEMANA,   mt.CD_USUARIO_INCLUSAO, mt.DH_INCLUSAO, mt.NU_VOLUME_PRODUZIDO)
                    values  ( contador_Matinal,     P_FK,                   P_DAY,              1,                      sysdate       , P_QTD);
                    
                WHEN '42' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'PO',                     numero_Semana); 
                WHEN '43' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'PE'                     ,numero_Semana);
                WHEN '44' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.CD_PRODUCTION_STOP_SUBTYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'FE',                      '1'                          ,numero_Semana); 
                WHEN '45' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.CD_PRODUCTION_STOP_SUBTYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'FE',                      '2'                          ,numero_Semana );
                WHEN '46' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.CD_PRODUCTION_STOP_SUBTYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'FE',                      '3'                          ,numero_Semana); 
                WHEN '47' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.CD_PRODUCTION_STOP_SUBTYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'FE',                      '4'                          ,numero_Semana); 
                WHEN '48' THEN
                    insert into VND.ELO_PRODUCTION_LOSS pl 
                            ( pl.CD_ELO_PRODUCTION_LOSS, pl.CD_ELO_AGENDAMENTO, pl.NU_DIA_SEMANA, pl.CD_USUARIO_INCLUSAO, pl.DH_INCLUSAO, pl.NU_QUANTIDADE, pl.CD_PRODUCTION_STOP_TYPE, pl.CD_PRODUCTION_STOP_SUBTYPE, pl.NU_SEMANA)
                    values  ( contador_PrdLoss,          P_FK,                  P_DAY,            1,                       sysdate,        P_QTD,            'FE',                      '5'                          ,numero_Semana); 
               
            END CASE;   
          end;
        ELSE
          begin
            --update
            CASE P_LINE
                WHEN '33' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_ANTECIPACAO_QUOTAS = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;
                WHEN '34' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_TOTAL_SOBRA_DIA_ANTERIOR = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;
                WHEN '35' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_SOBRA_SACARIA = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;   
                WHEN '36' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_SOBRA_BIG_BAG = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;   
                WHEN '37' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_SOBRA_GRANEL = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;   
                WHEN '38' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_SALDO_INGRESSAR_SAP = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;   
                WHEN '49' THEN
                    UPDATE VND.ELO_MATINAL MT
                    SET 
                        MT.NU_VOLUME_PRODUZIDO = P_QTD,
                        MT.DH_ULT_ALTERACAO = SYSDATE,
                        MT.CD_USUARIO_ALTERACAO = 1
                    WHERE 
                        MT.CD_ELO_MATINAL=P_PK;   
                WHEN '42' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                WHEN '43' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                WHEN '44' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                WHEN '45' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                WHEN '46' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                WHEN '47' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                WHEN '48' THEN      
                    UPDATE VND.ELO_PRODUCTION_LOSS PL
                    SET
                        PL.NU_QUANTIDADE=P_QTD,
                        PL.CD_USUARIO_ALTERACAO=1,
                        PL.DH_ULT_ALTERACAO=SYSDATE
                    WHERE 
                        PL.CD_ELO_PRODUCTION_LOSS = P_PK;
                             
             END CASE;
           end;
        END IF;
        
    End;
    
  END PUI_ELO_MATINAL;

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
  
PROCEDURE PX_GET_POLOS ( P_RETORNO     OUT T_CURSOR )
AS
BEGIN

    OPEN P_RETORNO FOR
    SELECT P.CD_POLO, P.DS_POLO FROM CTF.POLO P
    WHERE P.IC_ATIVO='S' 
    ORDER BY P.DS_POLO;

END PX_GET_POLOS;
  
PROCEDURE PX_GET_AGENDAMENTOS_OPT(  P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    
                                    P_RETORNO     OUT T_CURSOR
) AS
  BEGIN
  
    OPEN P_RETORNO FOR
        SELECT 
            ag.CD_ELO_AGENDAMENTO,
            ag.CD_CENTRO_EXPEDIDOR CodeCenter,
            ce.DS_CENTRO_EXPEDIDOR DescriptionCenter,   
            ag.CD_MACHINE CodeMachine,
            mac.DS_MACHINE DescriptionMachine,
            ag.CD_WEEK CodeWeek,
            ag.CD_WEEK DescriptionWeek
        from VND.ELO_AGENDAMENTO ag
        inner join CTF.CENTRO_EXPEDIDOR ce
            ON ag.CD_CENTRO_EXPEDIDOR = ce.CD_CENTRO_EXPEDIDOR
        inner join CTF.MACHINE mac 
            ON ag.CD_MACHINE = mac.CD_MACHINE
        where       ( ag.CD_WEEK = P_CD_WEEK ) 
                    and
                    ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                    ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    ( ag.IC_ATIVO='S' )   
            order by ag.CD_WEEK, ag.CD_CENTRO_EXPEDIDOR, ag.CD_MACHINE ;
    
  END PX_GET_AGENDAMENTOS_OPT;
  
  PROCEDURE PX_GET_AGEND_CAPACIDADE_MAX(P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                        P_CD_MACHINE VARCHAR2,
                                        P_CD_WEEK VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
) AS
  BEGIN
    
    IF P_CD_CENTRO_EXPEDIDOR <> '#' THEN
        BEGIN
            OPEN P_RETORNO FOR
            select  nvl( agci.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    nvl( agci.NU_CAPACIDADE_MAXIMA, 0) NU_CAPACIDADE_MAXIMA
            FROM    vnd.elo_agendamento ag
                    inner join VND.ELO_AGENDAMENTO_CENTRO agc 
                        on ag.CD_CENTRO_EXPEDIDOR = agc.CD_CENTRO_EXPEDIDOR
                            and
                           ag.DT_WEEK_START = agc.DT_WEEK_START
                    inner join VND.ELO_AGENDAMENTO_CENTRO_ITEM agci
                        on agc.CD_AGENDAMENTO_CENTRO = agci.CD_AGENDAMENTO_CENTRO
            WHERE
                    ( ag.CD_WEEK = P_CD_WEEK ) 
                    and
                    ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR )
                    and
                    ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    ag.IC_ATIVO='S'
                    and
                    agc.IC_ATIVO = 'S'
                    and
                    agci.IC_ATIVO = 'S'
            order by agci.NU_DIA_SEMANA;
        END;
    ELSE
        BEGIN
            OPEN P_RETORNO FOR
            select  nvl( agci.NU_DIA_SEMANA,0) NU_DIA_SEMANA, 
                    nvl( agci.NU_CAPACIDADE_MAXIMA, 0) NU_CAPACIDADE_MAXIMA
            FROM    vnd.elo_agendamento ag
                    inner join VND.ELO_AGENDAMENTO_CENTRO agc 
                        on ag.CD_CENTRO_EXPEDIDOR = agc.CD_CENTRO_EXPEDIDOR
                            and
                           ag.DT_WEEK_START = agc.DT_WEEK_START
                    inner join VND.ELO_AGENDAMENTO_CENTRO_ITEM agci
                        on agc.CD_AGENDAMENTO_CENTRO = agci.CD_AGENDAMENTO_CENTRO
            WHERE
                    ( ag.CD_WEEK = P_CD_WEEK ) 
                    and
                    ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                    ( ag.CD_MACHINE = P_CD_MACHINE )
                    AND
                    ag.IC_ATIVO='S'
                    and
                    agc.IC_ATIVO = 'S'
                    and
                    agci.IC_ATIVO = 'S'
            order by agci.NU_DIA_SEMANA;
        END;
    END IF;
    
  END PX_GET_AGEND_CAPACIDADE_MAX;
  
PROCEDURE PX_GET_PREFILTRO_AGENDAMENTOS(    P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                            P_CD_MACHINE VARCHAR2,
                                            P_CD_WEEK VARCHAR2,
                                            P_CD_POLO VARCHAR2,
                                            P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN
  
    OPEN P_RETORNO FOR
        SELECT 
            ' ' grupo,
            ' ' item,
            ' ' CD_TIPO_AGENDAMENTO,
            0 NU_DIA_SEMANA,
            0 NU_QUANTIDADE,
            0 Tipo_De_Status,
            0 PKTAB,
            NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
        from VND.ELO_AGENDAMENTO ag
        left join CTF.CENTRO_EXPEDIDOR ce
            ON ag.CD_CENTRO_EXPEDIDOR = ce.CD_CENTRO_EXPEDIDOR
        left join CTF.MACHINE mac 
            ON ag.CD_MACHINE = mac.CD_MACHINE
        where       ( ag.CD_WEEK = P_CD_WEEK ) 
                    and
                    ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                    ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                    and
                    ( ag.IC_ATIVO='S' )   
            order by ag.CD_ELO_AGENDAMENTO ;
    
  END PX_GET_PREFILTRO_AGENDAMENTOS;

    PROCEDURE PX_GET_DAY_START_WEEK(P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN
  
    OPEN P_RETORNO FOR
        SELECT 
        ag.DT_WEEK_START
        from VND.ELO_AGENDAMENTO ag
        where       ( ag.CD_WEEK = P_CD_WEEK )
                    and
                    ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                    ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    --com esse param nao seriam necessarios outros mas entrou por ultimo
                    and
                    ( ag.IC_ATIVO='S' );
    
  END PX_GET_DAY_START_WEEK;

PROCEDURE PX_GET_MATINAL_LINHAS (   P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_CD_POLO VARCHAR2,
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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

                    where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    
                where       ( ag.CD_WEEK = P_CD_WEEK )  and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                'MARCA플O CIF ' item, 
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
                    
                where       ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O FOB' item, 
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
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O TOTAL DIA' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O SACARIA' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O BIG BAG' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O GRANEL' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'ANTECIPADO TONS' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_ANTECIPACAO_QUOTAS,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                    --inner join VND.ELO_MATINAL mat
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                    where   
                         ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'TOTAL SOBRAS DIA ANTERIOR' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_TOTAL_SOBRA_DIA_ANTERIOR,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SOBRAS SACARIA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_SACARIA,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SOBRAS BIG BAG' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_BIG_BAG,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SOBRAS GRANEL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_GRANEL,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SALDO A INGRESSAR NO SAP' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SALDO_INGRESSAR_SAP,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
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
                        
                    where    ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) ) 
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
                    'MARCA플O' grupo,
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
                        
                    where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'OPERACIONAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PO'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'OPERACIONAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    0 NU_DIA_SEMANA,
                    0 NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PO'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'EMERGENCIAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PE'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-PROCESSO' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='1'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-CARTEIRA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='2'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-FLUXO CAMINH?' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='3'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-MATPRIMA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='4'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-OUTROS' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='5'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    
                    
    
            END CASE;
  
                
    
  END PX_GET_MATINAL_LINHAS;

PROCEDURE PX_GET_MATINAL_LINHAS_NEW(P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK VARCHAR2,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_CD_ELO_AGENDAMENTO VARCHAR,
                                    P_CD_POLO VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    ) AS

  BEGIN
  
  
            CASE P_LINHA_TO_EXEC
                --01
                WHEN '01' THEN
                    OPEN P_RETORNO FOR
                    WITH A as (
                    SELECT distinct
                        'Faturamento Total' grupo,
                        'Capacidade Planejada' item, 
                        0 CD_TIPO_AGENDAMENTO, --carteira.CD_TIPO_AGENDAMENTO,
                        CASE agday.NU_DIA_SEMANA WHEN 1 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                        CASE agday.NU_DIA_SEMANA WHEN 2 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                        CASE agday.NU_DIA_SEMANA WHEN 3 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                        CASE agday.NU_DIA_SEMANA WHEN 4 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                        CASE agday.NU_DIA_SEMANA WHEN 5 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                        CASE agday.NU_DIA_SEMANA WHEN 6 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                        CASE agday.NU_DIA_SEMANA WHEN 7 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,
                        0 Tipo_De_Status,
                        0 PKTAB,
                        0 FKTABPAI
                            from VND.ELO_AGENDAMENTO ag
                            
                            inner join VND.ELO_CARTEIRA carteira
                                on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                                    
                WHEN '02' THEN
                    OPEN P_RETORNO FOR
                    WITH A AS (
                    SELECT distinct
                    'FATURAMENTO TOTAL' grupo,
                    'ASSERT.TOTAL FAT ' item, 
                    0 CD_TIPO_AGENDAMENTO,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 1 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_SEG,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 2 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_TER,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 3 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_QUA,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 4 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_QUI,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 5 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_SEX,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 6 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_SAB,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 7 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_DOM,                    
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                                    
                --04
                WHEN '04' THEN
                    OPEN P_RETORNO FOR
                    WITH A as (
                    SELECT distinct
                        'Faturamento Total' grupo,
						'Assertiv.Total Fat.' item, 
						carteira.CD_TIPO_AGENDAMENTO, 
                        CASE agday.NU_DIA_SEMANA WHEN 1 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                        CASE agday.NU_DIA_SEMANA WHEN 2 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                        CASE agday.NU_DIA_SEMANA WHEN 3 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                        CASE agday.NU_DIA_SEMANA WHEN 4 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                        CASE agday.NU_DIA_SEMANA WHEN 5 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                        CASE agday.NU_DIA_SEMANA WHEN 6 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                        CASE agday.NU_DIA_SEMANA WHEN 7 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,
                        0 Tipo_De_Status,
                        0 PKTAB,
                        0 FKTABPAI
                            from VND.ELO_AGENDAMENTO ag
                            
                            inner join VND.ELO_CARTEIRA carteira
                                on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                
                --05
                WHEN '05' THEN
                    OPEN P_RETORNO FOR
                    WITH A as (
                    SELECT distinct
                        'CIF' grupo,
						'Total CIF' item, 
						carteira.CD_TIPO_AGENDAMENTO, 
                        CASE agday.NU_DIA_SEMANA WHEN 1 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                        CASE agday.NU_DIA_SEMANA WHEN 2 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                        CASE agday.NU_DIA_SEMANA WHEN 3 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                        CASE agday.NU_DIA_SEMANA WHEN 4 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                        CASE agday.NU_DIA_SEMANA WHEN 5 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                        CASE agday.NU_DIA_SEMANA WHEN 6 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                        CASE agday.NU_DIA_SEMANA WHEN 7 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,
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
                            
                            inner join VND.ELO_CARTEIRA carteira
                                on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            carteira.CD_INCOTERMS='CIF'
					and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                    
                --06
                WHEN '06' THEN
                OPEN P_RETORNO FOR
                WITH A as (
                    SELECT distinct
                        'CIF' grupo,
						'Planejado CIF' item, 
						carteira.CD_TIPO_AGENDAMENTO, 
                        CASE agday.NU_DIA_SEMANA WHEN 1 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                        CASE agday.NU_DIA_SEMANA WHEN 2 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                        CASE agday.NU_DIA_SEMANA WHEN 3 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                        CASE agday.NU_DIA_SEMANA WHEN 4 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                        CASE agday.NU_DIA_SEMANA WHEN 5 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                        CASE agday.NU_DIA_SEMANA WHEN 6 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                        CASE agday.NU_DIA_SEMANA WHEN 7 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,
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
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            carteira.CD_INCOTERMS='CIF'
					and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                
                WHEN '07' THEN
                OPEN P_RETORNO FOR
                WITH A as (
						SELECT distinct
                        'CIF' grupo,
						'Backlog' item, 
						0 CD_TIPO_AGENDAMENTO,
						carteira.QT_BACKLOG_CIF NU_QUANTIDADE_SEG,
						0 NU_QUANTIDADE_TER,
						0 NU_QUANTIDADE_QUA,
						0 NU_QUANTIDADE_QUI,
						0 NU_QUANTIDADE_SEX,
						0 NU_QUANTIDADE_SAB,
						0 NU_QUANTIDADE_DOM,
						0 Tipo_De_Status,
						0 PKTAB,
						0 FKTABPAI
                            from VND.ELO_AGENDAMENTO ag
                            
                            inner join VND.ELO_CARTEIRA carteira
                                on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            carteira.CD_INCOTERMS='CIF'
					and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
    
                WHEN '08' THEN
                OPEN P_RETORNO FOR
                WITH A AS (
                    SELECT distinct
                    'CIF' grupo,
					'FATURADO CIF ' item, 
                    0 CD_TIPO_AGENDAMENTO,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 1 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_SEG,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 2 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_TER,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 3 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_QUA,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 4 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_QUI,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 5 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_SEX,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 6 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_SAB,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 7 THEN marc.QT_FATURADO ELSE 0 END AS NU_QUANTIDADE_DOM,                    
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
							and
                            cart.CD_INCOTERMS='CIF'
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                
                --09
                WHEN '09' THEN
                OPEN P_RETORNO FOR
                WITH A AS (
                    SELECT distinct
                    'CIF' grupo,
					'MARCA플O CIF ' item, 
                    0 CD_TIPO_AGENDAMENTO,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 1 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 2 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 3 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 4 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 5 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 6 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                     CASE ( 1 + TRUNC(marc.DH_FATURAMENTO) - TRUNC(marc.DH_FATURAMENTO)) WHEN 7 THEN marc.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,                    
                    0 Tipo_De_Status,
                    0 PKTAB,
                    0 FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_CARTEIRA cart
                            on ag.CD_ELO_AGENDAMENTO = cart.CD_ELO_AGENDAMENTO and cart.IC_ATIVO='S'
                        inner join VND.ELO_MARCACAO marc
                            on cart.CD_ELO_CARTEIRA = marc.CD_ELO_CARTEIRA and marc.IC_ATIVO = 'S'
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                                and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                                and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
							and
                            cart.CD_INCOTERMS='CIF'
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                            
                --13            
                WHEN '13' THEN
                OPEN P_RETORNO FOR
                    WITH A as (
                    SELECT distinct
                        'FOB' grupo,
						'TOTAL FOB' item, 
						carteira.CD_TIPO_AGENDAMENTO, 
                        CASE agday.NU_DIA_SEMANA WHEN 1 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                        CASE agday.NU_DIA_SEMANA WHEN 2 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                        CASE agday.NU_DIA_SEMANA WHEN 3 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                        CASE agday.NU_DIA_SEMANA WHEN 4 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                        CASE agday.NU_DIA_SEMANA WHEN 5 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                        CASE agday.NU_DIA_SEMANA WHEN 6 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                        CASE agday.NU_DIA_SEMANA WHEN 7 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,
                        0 Tipo_De_Status,
                        0 PKTAB,
                        0 FKTABPAI
                            from VND.ELO_AGENDAMENTO ag
                            
                            inner join VND.ELO_CARTEIRA carteira
                                on ag.CD_ELO_AGENDAMENTO = carteira.CD_ELO_AGENDAMENTO and carteira.IC_ATIVO='S'
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            carteira.CD_INCOTERMS='FOB'
					and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                    
                    --14
                    WHEN '14' THEN
                    OPEN P_RETORNO FOR
                    WITH A as (
                    SELECT distinct
                        'FOB' grupo,
						'Planejado FOB' item,  
						carteira.CD_TIPO_AGENDAMENTO, 
                        CASE agday.NU_DIA_SEMANA WHEN 1 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEG,
                        CASE agday.NU_DIA_SEMANA WHEN 2 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_TER,
                        CASE agday.NU_DIA_SEMANA WHEN 3 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUA,
                        CASE agday.NU_DIA_SEMANA WHEN 4 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_QUI,
                        CASE agday.NU_DIA_SEMANA WHEN 5 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SEX,
                        CASE agday.NU_DIA_SEMANA WHEN 6 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_SAB,
                        CASE agday.NU_DIA_SEMANA WHEN 7 THEN agday.NU_QUANTIDADE ELSE 0 END AS NU_QUANTIDADE_DOM,
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
                                    
                            --novos joins    
                            inner join VND.ELO_AGENDAMENTO_SUPERVISOR agsup
                                on ag.CD_ELO_AGENDAMENTO = agsup.CD_ELO_AGENDAMENTO
                                
                            inner join VND.ELO_AGENDAMENTO_ITEM agitem
                                on agitem.CD_ELO_AGENDAMENTO_SUPERVISOR = agsup.CD_ELO_AGENDAMENTO_SUPERVISOR
                                
                            inner join VND.ELO_AGENDAMENTO_WEEK agweek
                                on agitem.CD_ELO_AGENDAMENTO_ITEM = agweek.CD_ELO_AGENDAMENTO_ITEM
                                
                            inner join VND.ELO_AGENDAMENTO_DAY agday
                                on agday.CD_ELO_AGENDAMENTO_WEEK = agweek.CD_ELO_AGENDAMENTO_WEEK
                    
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
                                and
                            ( ( P_CD_CENTRO_EXPEDIDOR = '#' ) or ( ag.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR ) )
                    and
                            ( ( P_CD_MACHINE = '#' ) or ( ag.CD_MACHINE = P_CD_MACHINE ) )
                    and
                    
                            carteira.CD_INCOTERMS='FOB'
					and
                            ag.IC_ATIVO='S' and  ( ag.CD_ELO_AGENDAMENTO = P_CD_ELO_AGENDAMENTO )
                    )
                    select GRUPO, ITEM, CD_TIPO_AGENDAMENTO, 
                     SUM(NU_QUANTIDADE_SEG) NU_QUANTIDADE_SEG, 
                     SUM(NU_QUANTIDADE_TER) NU_QUANTIDADE_TER, 
                     SUM(NU_QUANTIDADE_QUA) NU_QUANTIDADE_QUA, 
                     SUM(NU_QUANTIDADE_QUI) NU_QUANTIDADE_QUI, 
                     SUM(NU_QUANTIDADE_SEX) NU_QUANTIDADE_SEX, 
                     SUM(NU_QUANTIDADE_SAB) NU_QUANTIDADE_SAB, 
                     SUM(NU_QUANTIDADE_DOM) NU_QUANTIDADE_DOM
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI 
                    FROM A
                    GROUP BY GRUPO
                    ,ITEM
                    ,CD_TIPO_AGENDAMENTO
                    ,TIPO_DE_STATUS
                    ,PKTAB
                    ,FKTABPAI;
                            
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    where   ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O FOB' item, 
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
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O TOTAL DIA' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O SACARIA' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O BIG BAG' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'MARCA플O GRANEL' item, 
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
                        
                    where   (ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'ANTECIPADO TONS' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_ANTECIPACAO_QUOTAS,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                    from VND.ELO_AGENDAMENTO ag
                    --inner join VND.ELO_MATINAL mat
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                    where   
                         ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'TOTAL SOBRAS DIA ANTERIOR' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_TOTAL_SOBRA_DIA_ANTERIOR,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SOBRAS SACARIA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_SACARIA,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SOBRAS BIG BAG' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_BIG_BAG,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SOBRAS GRANEL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SOBRA_GRANEL,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
                    'SALDO A INGRESSAR NO SAP' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(mat.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(mat.NU_SALDO_INGRESSAR_SAP,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(mat.CD_ELO_MATINAL,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'MARCA플O' grupo,
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
                        
                    where    ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) ) 
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
                    'MARCA플O' grupo,
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
                        
                    where        ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'OPERACIONAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PO'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'OPERACIONAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    0 NU_DIA_SEMANA,
                    0 NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PO'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'EMERGENCIAL' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='PE'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-PROCESSO' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='1'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-CARTEIRA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='2'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-FLUXO CAMINH?' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='3'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-MATPRIMA' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='4'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    'PERDA PRODU플O' grupo,
                    'FATOR EXTERNO-OUTROS' item,
                    '' CD_TIPO_AGENDAMENTO,
                    NVL(ploss.NU_DIA_SEMANA,0) NU_DIA_SEMANA,
                    NVL(ploss.NU_QUANTIDADE,0) NU_QUANTIDADE,
                    0 Tipo_De_Status,
                    --se pktab=0 registro novo
                    NVL(ploss.CD_ELO_PRODUCTION_LOSS,0) PKTAB,
                    --usar fk para inserir ou alterar registro
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    --ao inserir colocar CD_PRODUCTION_STOP_TYPE='FE'
                    --ao inserir colocar CD_PRODUCTION_STOP_SUBTYPE='5'
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_PRODUCTION_LOSS ploss
                            on ag.CD_ELO_AGENDAMENTO = ploss.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    --ao inserir n? tem sequence, tem que ver o ultimo e somar 1
                    NVL(AG.CD_ELO_AGENDAMENTO,0) FKTABPAI
                        from VND.ELO_AGENDAMENTO ag
                        inner join VND.ELO_MATINAL mat
                            on ag.CD_ELO_AGENDAMENTO = mat.CD_ELO_AGENDAMENTO
                        where   
                             ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                                 ( ag.CD_WEEK = P_CD_WEEK ) and ( ( P_CD_POLO = '#' ) or ( ag.CD_POLO = P_CD_POLO ) )
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
                    
                    
    
            END CASE;
  
                
    
  END PX_GET_MATINAL_LINHAS_NEW;


END GX_ELO_MATINAL_PAGINA;
/