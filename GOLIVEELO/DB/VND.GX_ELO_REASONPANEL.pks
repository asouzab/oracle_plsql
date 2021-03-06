CREATE OR REPLACE PACKAGE VND."GX_ELO_REASONPANEL" IS 
  /* This package create srinu for  Requirements number: 403 */ 
TYPE T_CURSOR IS REF CURSOR;
PROCEDURE PX_GET_SELECT (P_RETURN OUT T_CURSOR); 
PROCEDURE PX_GET_REPORT(   P_CD_ELO_CONTROLLERSHIP_REASON in ELO_CONTROLLERSHIP_REASON.CD_ELO_CONTROLLERSHIP_REASON%type,
P_CD_ELO_MARCACAO in ELO_MARCACAO.CD_MOTIVO_STATUS%type,
P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
P_RETIRNO         out T_CURSOR);

PROCEDURE PX_CAPACIDADE_REPORT(   
  P_CD_POLO in ELO_AGENDAMENTO.CD_POLO%type,
  P_CD_CENTRO in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
  P_CD_MACHINE   in ELO_AGENDAMENTO.CD_MACHINE%type,
  P_CD_WEEK         in ELO_AGENDAMENTO.CD_WEEK%type,
  P_RETORNO         out T_CURSOR,
  P_RETORNO1         out T_CURSOR
);

END GX_ELO_REASONPANEL;


/