CREATE OR REPLACE PACKAGE VND."GX_ELO_CONTROLLERSHIP_PLANEJA" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

TYPE T_CURSOR IS REF CURSOR;

PROCEDURE PX_GET_REPORT(
        p_CD_POLO               in ELO_AGENDAMENTO.CD_POLO%type,
        p_DT_WEEK_START         in ELO_AGENDAMENTO.DT_WEEK_START%type,
        p_CD_CENTRO_EXPEDIDOR   in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        p_CD_MACHINE            in ELO_AGENDAMENTO.CD_MACHINE%type,
        p_RETORNO               out T_CURSOR
);

PROCEDURE PX_GET_REPORT2(
        p_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        p_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        p_RETORNO         out T_CURSOR
);

END GX_ELO_CONTROLLERSHIP_PLANEJA;


/