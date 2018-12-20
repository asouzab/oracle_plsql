CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_CAPACITY_REPORT" AS

  PROCEDURE PX_GET_POLO
    (
    P_RETORNO     OUT T_CURSOR
    ) AS
  BEGIN
  OPEN P_RETORNO FOR
              SELECT DISTINCT
                CD_POLO
              FROM
                ELO_AGENDAMENTO
              WHERE IC_ATIVO='S';
    NULL;
  END PX_GET_POLO;

  PROCEDURE PX_GET_CENTRO
    (
    P_RETORNO OUT T_CURSOR
    ) AS
    BEGIN
    OPEN P_RETORNO FOR
          SELECT DISTINCT
              CD_CENTRO_EXPEDIDOR
          FROM
              ELO_AGENDAMENTO
          WHERE IC_ATIVO='S';
      NULL;
  END PX_GET_CENTRO;

END GX_ELO_CAPACITY_REPORT;


/