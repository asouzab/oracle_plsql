CREATE OR REPLACE PACKAGE VND.GX_ELO_BATCH_ISSUE AS
/******************************************************************************
   NAME:       GX_ELO_BATCH_ISSUE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/06/2018      adesouz2       1. Created this package.
******************************************************************************/

    TYPE t_cursor IS REF CURSOR;
    
    TYPE elo_agendamento_week_r IS RECORD
    (
        cd_elo_agendamento_week         vnd.elo_agendamento_week.cd_elo_agendamento_week%TYPE, 
        cd_elo_agendamento_item         vnd.elo_agendamento_week.cd_elo_agendamento_item%TYPE, 
        nu_semana                       vnd.elo_agendamento_week.nu_semana%TYPE,
        qt_cota                         vnd.elo_agendamento_week.qt_cota%TYPE, 
        qt_semana                       vnd.elo_agendamento_week.qt_semana%TYPE ,     
        qt_emergencial                  vnd.elo_agendamento_week.qt_emergencial%type             
    );

    TYPE elo_agendamento_week_t IS TABLE OF elo_agendamento_week_r
    INDEX BY PLS_INTEGER    ;
    
PROCEDURE PU_UPDATE_QT_SEMANA
( 
p_result        OUT t_cursor
);

PROCEDURE PU_UPDATE_QT_SEMANA_CIF
( 
p_result        OUT t_cursor
);

PROCEDURE PU_UPDATE_QT_SEMANA_MONTH_CIF
( 
p_result        OUT t_cursor

);

PROCEDURE PI_AGENDAMENTO_WEEKDAY_FROZZEN;

PROCEDURE PI_AGENDAMENTO_BATCH;

PROCEDURE PI_AGENDAMENTO_BATCH_MONTH;

PROCEDURE PI_AGENDAMENTO_WEEKDAY_FROZZEN
(
P_CD_ELO_AGENDAMENTO IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE 
);


END GX_ELO_BATCH_ISSUE;
/