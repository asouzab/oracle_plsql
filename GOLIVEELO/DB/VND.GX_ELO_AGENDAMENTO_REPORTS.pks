CREATE OR REPLACE PACKAGE VND."GX_ELO_AGENDAMENTO_REPORTS" AS 

  TYPE T_CURSOR IS REF CURSOR;

  FUNCTION FX_RELACIONAMENTO (
        P_CD_ELO_CARTEIRA    IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE
    ) RETURN NUMBER;
    
  FUNCTION FX_RESERVADO (
        P_CD_ELO_CARTEIRA    IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE
    ) RETURN NUMBER;
    
  FUNCTION FX_PROGRAMADO (
        P_CD_ELO_CARTEIRA    IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE
    ) RETURN NUMBER;

  PROCEDURE PX_GET_SUPERVISORES (
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
    P_RETORNO       OUT T_CURSOR
  );

  PROCEDURE PX_GET_GERENTES (
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
    P_RETORNO       OUT T_CURSOR
  );

  PROCEDURE PX_GET_FINAL_VIEW(
    P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
    P_CENTRO                IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA               IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_WEEK                  IN VARCHAR2,
    P_SUPERVISOR            IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_GERENTE               IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE,
    P_PRINCIPAL             OUT T_CURSOR,
    P_GERENCIA              OUT T_CURSOR,
    P_CHART_VOLUME          OUT T_CURSOR,
    P_CHART_EMBALAGEM       OUT T_CURSOR,
    P_CHART_EMBALAGEM_DIA   OUT T_CURSOR,
    P_CHART_CLIENTE         OUT T_CURSOR,
    P_CHART_CENTRO          OUT T_CURSOR,
    P_CHART_FAMILIA         OUT T_CURSOR
  );

  PROCEDURE PX_GET_SUPERVISOR_QUOTA (
    P_POLO          IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
--    P_WEEK          IN INT,
    P_DT_WEEK_START IN ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
    P_GERENTE       IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE, 
    P_SUPERVISOR    IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_RETORNO       OUT T_CURSOR
  );

  PROCEDURE PU_UPDATE_SUPERVISOR_QUOTA (
    P_CD_AGENDAMENTO_SUPERVISOR     IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO_SUPERVISOR%TYPE,
    P_QT_COTA_AJUSTADA              IN VND.ELO_AGENDAMENTO_SUPERVISOR.QT_COTA_AJUSTADA%TYPE,
    P_RETORNO                       OUT T_CURSOR
  );

  PROCEDURE PX_GET_CHART_VOLUME (
    P_POLO          IN CTF.POLO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_SEMANA        IN VARCHAR2,
    P_SUPERVISOR    IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_TIPO          OUT T_CURSOR,
    P_INCOTERM      OUT T_CURSOR,
    P_EMBALAGEM     OUT T_CURSOR
  );

  PROCEDURE PX_GET_SUPERVISOR_PROGRAMACAO (
    P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
    P_CENTRO                IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA               IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_WEEK                  IN VARCHAR2,
    P_SUPERVISOR            IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_GERENTE               IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE, 
    C_SUPERVISOR            OUT T_CURSOR,
    C_WEEK_DAY              OUT T_CURSOR
  );



  PROCEDURE PX_REPORT_AGEND_BAL_CENTRO (
    P_POLO          IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE, 
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_CD_WEEK       IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
    P_RETORNO       OUT T_CURSOR
  );

  PROCEDURE PX_GET_CHART_VOLUME_EXIBIR (
    P_POLO          IN CTF.POLO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_SEMANA        IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
    P_TRAVADO       OUT T_CURSOR

  );

END GX_ELO_AGENDAMENTO_REPORTS;
/