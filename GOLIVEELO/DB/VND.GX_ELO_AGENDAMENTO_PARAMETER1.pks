CREATE OR REPLACE PACKAGE VND."GX_ELO_AGENDAMENTO_PARAMETER1" AS 

/******************************************************************************
   NAME:       GX_ELO_AGENDAMENTO_PARAMETER1
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/23/2017      sfernan1       Created this package.
   1.1        10/30/2017      sfernan1       Added procedures for Parameters per plant
******************************************************************************/

 TYPE T_CURSOR IS REF CURSOR;
 TYPE SPLIT_TBL IS TABLE OF VARCHAR2(300);

FUNCTION FX_SPLIT2(
        LIST IN VARCHAR2,
        DELIMITER IN VARCHAR2 DEFAULT ','
    ) RETURN SPLIT_TBL;

    /********************************************************************* 
    To get default template values from table: VND.ELO_TEMPLATE_CENTRO and VND.ELO_TEMPLATE_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_RESULT – List the Template values based on the Plant and Machine
    /*********************************************************************/

  PROCEDURE PX_GET_DEFAULTPARAMETERS(
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_TEMPLATE_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_RESULT                OUT T_CURSOR
    );

  /********************************************************************* 
    To insert default template values to table: VND.ELO_TEMPLATE_CENTRO and VND.ELO_TEMPLATE_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_QT_FILA_MINIMA - Minimum queue Fila mínima
    P_TS_HORARIO_CORTE_CONFERENCIA - First Cut time Horário de corte
    P_TS_HORARIO_CORTE_FINAL - Final Cut time Horário final de corte
    P_IC_COTA_POR_EMBALAGEM - Quota per packing type Cota por embalagem 'S' = Yes 'N' = No"
    P_IC_ATIVO - "'S' = Yes (default) 'N' = No (Inactive record)"
    P_NU_DIA_SEMANA -
    P_NU_CAPACIDADE - List of Plant daily capacity
    P_NU_CAPACIDADE_MAXIMA - List of Plant max daily capacity
    P_NU_ENSACADO - List of Plant small bag daily capacity Capacidade Ensacado por dia
    P_QT_OVERBOOKING - List of Plant overbooking (%)
    P_CD_PERFIL_MAQUINA - List of Machine profile
    P_NU_HORAS_PRODUCAO - List of Production hours
    P_DH_INICIO_PRODUCAO - List of Production starting date and time
    P_DH_FIM_PRODUCAO - List of Production ending date and time
    P_RESULT – returns the ID from VND.ELO_TEMPLATE_CENTRO table
    /*********************************************************************/

  PROCEDURE PI_DEFAULTPARAMETERS
  (
      P_CD_CENTRO_EXPEDIDOR IN VND.ELO_TEMPLATE_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE,
      P_QT_FILA_MINIMA IN VND.ELO_TEMPLATE_CENTRO.QT_FILA_MINIMA%TYPE,
      P_TS_HORARIO_CORTE_CONFERENCIA IN VND.ELO_TEMPLATE_CENTRO.TS_HORARIO_CORTE_CONFERENCIA%TYPE,
      P_TS_HORARIO_CORTE_FINAL IN VND.ELO_TEMPLATE_CENTRO.TS_HORARIO_CORTE_FINAL%TYPE,
      P_IC_COTA_POR_EMBALAGEM IN VND.ELO_TEMPLATE_CENTRO.IC_COTA_POR_EMBALAGEM%TYPE,
      P_IC_ATIVO IN VND.ELO_TEMPLATE_CENTRO.IC_ATIVO%TYPE,
      P_NU_DIA_SEMANA IN VARCHAR,
      P_NU_CAPACIDADE IN VARCHAR,
      P_NU_CAPACIDADE_MAXIMA IN VARCHAR,
      P_NU_ENSACADO IN VARCHAR,
      P_QT_OVERBOOKING IN VARCHAR,
      P_CD_PERFIL_MAQUINA IN VARCHAR,
      P_NU_HORAS_PRODUCAO IN VARCHAR,
      P_DH_INICIO_PRODUCAO IN VARCHAR,
      P_DH_FIM_PRODUCAO IN VARCHAR,
      P_CD_USUARIO_INCLUSAO IN CTF.USUARIO.CD_USUARIO%TYPE,
      P_RESULT OUT T_CURSOR 
  );

  /********************************************************************* 
    To update default template values to table: VND.ELO_TEMPLATE_CENTRO and VND.ELO_TEMPLATE_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_QT_FILA_MINIMA - Minimum queue Fila mínima
    P_TS_HORARIO_CORTE_CONFERENCIA - First Cut time Horário de corte
    P_TS_HORARIO_CORTE_FINAL - Final Cut time Horário final de corte
    P_IC_COTA_POR_EMBALAGEM - Quota per packing type Cota por embalagem 'S' = Yes 'N' = No"
    P_IC_ATIVO - "'S' = Yes (default) 'N' = No (Inactive record)"
    P_NU_DIA_SEMANA -
    P_NU_CAPACIDADE - List of Plant daily capacity
    P_NU_CAPACIDADE_MAXIMA - List of Plant max daily capacity
    P_NU_ENSACADO - List of Plant small bag daily capacity Capacidade Ensacado por dia
    P_QT_OVERBOOKING - List of Plant overbooking (%)
    P_CD_PERFIL_MAQUINA - List of Machine profile
    P_NU_HORAS_PRODUCAO - List of Production hours
    P_DH_INICIO_PRODUCAO - List of Production starting date and time
    P_DH_FIM_PRODUCAO - List of Production ending date and time
    P_RESULT – returns the ID from VND.ELO_TEMPLATE_CENTRO table
    /*********************************************************************/

  PROCEDURE PU_DEFAULTPARAMETERS
  (
      P_CD_TEMPLATE_CENTRO IN VND.ELO_TEMPLATE_CENTRO.CD_TEMPLATE_CENTRO%TYPE,
      P_CD_CENTRO_EXPEDIDOR IN VND.ELO_TEMPLATE_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE,
      P_QT_FILA_MINIMA IN VND.ELO_TEMPLATE_CENTRO.QT_FILA_MINIMA%TYPE,
      P_TS_HORARIO_CORTE_CONFERENCIA IN VND.ELO_TEMPLATE_CENTRO.TS_HORARIO_CORTE_CONFERENCIA%TYPE,
      P_TS_HORARIO_CORTE_FINAL IN VND.ELO_TEMPLATE_CENTRO.TS_HORARIO_CORTE_FINAL%TYPE,
      P_IC_COTA_POR_EMBALAGEM IN VND.ELO_TEMPLATE_CENTRO.IC_COTA_POR_EMBALAGEM%TYPE,
      P_NU_DIA_SEMANA IN VARCHAR,
      P_NU_CAPACIDADE IN VARCHAR,
      P_NU_CAPACIDADE_MAXIMA IN VARCHAR,
      P_NU_ENSACADO IN VARCHAR,
      P_QT_OVERBOOKING IN VARCHAR,
      P_CD_PERFIL_MAQUINA IN VARCHAR,
      P_NU_HORAS_PRODUCAO IN VARCHAR,
      P_DH_INICIO_PRODUCAO IN VARCHAR,
      P_DH_FIM_PRODUCAO IN VARCHAR,
      P_CD_USUARIO_ALTERACAO IN CTF.USUARIO.CD_USUARIO%TYPE,
      P_RESULT OUT T_CURSOR 
  );

   /********************************************************************* 
    To delete default template values from table: VND.ELO_TEMPLATE_CENTRO and VND.ELO_TEMPLATE_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_RESULT – returns the ID from VND.ELO_TEMPLATE_CENTRO table
    /*********************************************************************/

  PROCEDURE PD_DEFAULTPARAMETERS
  (
      P_CD_TEMPLATE_CENTRO IN VND.ELO_TEMPLATE_CENTRO.CD_TEMPLATE_CENTRO%TYPE,
      P_CD_CENTRO_EXPEDIDOR IN VND.ELO_TEMPLATE_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE,
      P_CD_USUARIO_ALTERACAO IN CTF.USUARIO.CD_USUARIO%TYPE,
      P_RESULT       OUT T_CURSOR
  );

   /********************************************************************* 
    To get parameter values per plant from table: VND.ELO_AGENDAMENTO_CENTRO and VND.ELO_AGENDAMENTO_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO – Plant ID
    P_CD_MACHINE - Machine No
    P_DT_WEEK_START - Week Start
    P_RESULT – List the values based on the Plant, Machine and Week Start
    /*********************************************************************/
  PROCEDURE PX_AGENDAMENTO_CENTRO_ITEMS
  (
      P_CD_CENTRO       IN ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
      P_CD_MACHINE      IN ELO_AGENDAMENTO_CENTRO.CD_MACHINE%TYPE DEFAULT NULL,
      --P_WEEK            IN INT,
      P_DT_WEEK_START   IN ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%TYPE,
      P_RESULT          OUT T_CURSOR
  );

  /********************************************************************* 
    To insert parameter values per plant to table: VND.ELO_AGENDAMENTO_CENTRO and VND.ELO_AGENDAMENTO_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_DT_WEEK_START - Week Semana First week day, like DD/MM/YYYY
    P_QT_FILA_MINIMA - Minimum queue Fila mínima0
    P_TS_HORARIO_CORTE_CONFERENCIA - First Cut time Horário de corte
    P_TS_HORARIO_CORTE_FINAL - Final Cut time Horário final de corte
    P_IC_COTA_POR_EMBALAGEM - Quota per packing type Cota por embalagem 'S' = Yes 'N' = No"
    P_IC_ATIVO - "'S' = Yes (default) 'N' = No (Inactive record)"
    P_NU_DIA_SEMANA -
    P_NU_CAPACIDADE - List of Plant daily capacity
    P_NU_CAPACIDADE_MAXIMA - List of Plant max daily capacity
    P_NU_ENSACADO - List of Plant small bag daily capacity Capacidade Ensacado por dia
    P_QT_OVERBOOKING - List of Plant overbooking (%)
    P_CD_PERFIL_MAQUINA - List of Machine profile
    P_NU_HORAS_PRODUCAO - List of Production hours
    P_DH_INICIO_PRODUCAO - List of Production starting date and time
    P_DH_FIM_PRODUCAO - List of Production ending date and time
    P_RESULT – returns the ID from VND.ELO_TEMPLATE_CENTRO table
    /*********************************************************************/

  PROCEDURE PI_AGENDAMENTO_CENTRO_ITEMS
  (
      P_CD_CENTRO_EXPEDIDOR IN VND.ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE,
      P_CD_MACHINE IN VND.ELO_AGENDAMENTO_CENTRO.CD_MACHINE%TYPE,
      P_DT_WEEK_START IN VND.ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%TYPE,
      P_QT_FILA_MINIMA IN VND.ELO_AGENDAMENTO_CENTRO.QT_FILA_MINIMA%TYPE,
      P_TS_HORARIO_CORTE_CONFERENCIA IN VND.ELO_AGENDAMENTO_CENTRO.TS_HORARIO_CORTE_CONFERENCIA%TYPE,
      P_TS_HORARIO_CORTE_FINAL IN VND.ELO_AGENDAMENTO_CENTRO.TS_HORARIO_CORTE_FINAL%TYPE,
      P_IC_COTA_POR_EMBALAGEM IN VND.ELO_AGENDAMENTO_CENTRO.IC_COTA_POR_EMBALAGEM%TYPE,
      P_NU_DIA_SEMANA IN VARCHAR,
      P_NU_CAPACIDADE IN VARCHAR,
      P_NU_CAPACIDADE_MAXIMA IN VARCHAR,
      P_NU_ENSACADO IN VARCHAR,
      P_QT_OVERBOOKING IN VARCHAR,
      P_CD_PERFIL_MAQUINA IN VARCHAR,
      P_NU_HORAS_PRODUCAO IN VARCHAR,
      P_DH_INICIO_PRODUCAO IN VARCHAR,
      P_DH_FIM_PRODUCAO IN VARCHAR,
      P_CD_USUARIO_INCLUSAO IN CTF.USUARIO.CD_USUARIO%TYPE,
      P_RESULT OUT T_CURSOR 
  );

   /********************************************************************* 
    To update parameter values per plant to table: VND.ELO_AGENDAMENTO_CENTRO and VND.ELO_AGENDAMENTO_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_DT_WEEK_START - Week Semana First week day, like DD/MM/YYYY
    P_QT_FILA_MINIMA - Minimum queue Fila mínima
    P_TS_HORARIO_CORTE_CONFERENCIA - First Cut time Horário de corte
    P_TS_HORARIO_CORTE_FINAL - Final Cut time Horário final de corte
    P_IC_COTA_POR_EMBALAGEM - Quota per packing type Cota por embalagem 'S' = Yes 'N' = No"
    P_IC_ATIVO - "'S' = Yes (default) 'N' = No (Inactive record)"
    P_NU_DIA_SEMANA -
    P_NU_CAPACIDADE - List of Plant daily capacity
    P_NU_CAPACIDADE_MAXIMA - List of Plant max daily capacity
    P_NU_ENSACADO - List of Plant small bag daily capacity Capacidade Ensacado por dia
    P_QT_OVERBOOKING - List of Plant overbooking (%)
    P_CD_PERFIL_MAQUINA - List of Machine profile
    P_NU_HORAS_PRODUCAO - List of Production hours
    P_DH_INICIO_PRODUCAO - List of Production starting date and time
    P_DH_FIM_PRODUCAO - List of Production ending date and time
    P_RESULT – returns the ID from VND.ELO_TEMPLATE_CENTRO table
    /*********************************************************************/

  PROCEDURE PU_AGENDAMENTO_CENTRO_ITEMS
  (
      P_CD_AGENDAMENTO_CENTRO IN VND.ELO_AGENDAMENTO_CENTRO.CD_AGENDAMENTO_CENTRO%TYPE,
      P_CD_CENTRO_EXPEDIDOR IN VND.ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE,
      P_CD_MACHINE IN VND.ELO_AGENDAMENTO_CENTRO.CD_MACHINE%TYPE,
      P_DT_WEEK_START IN VND.ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%TYPE,
      P_QT_FILA_MINIMA IN VND.ELO_AGENDAMENTO_CENTRO.QT_FILA_MINIMA%TYPE,
      P_TS_HORARIO_CORTE_CONFERENCIA IN VND.ELO_AGENDAMENTO_CENTRO.TS_HORARIO_CORTE_CONFERENCIA%TYPE,
      P_TS_HORARIO_CORTE_FINAL IN VND.ELO_AGENDAMENTO_CENTRO.TS_HORARIO_CORTE_FINAL%TYPE,
      P_IC_COTA_POR_EMBALAGEM IN VND.ELO_AGENDAMENTO_CENTRO.IC_COTA_POR_EMBALAGEM%TYPE,
      P_IC_ATIVO IN VND.ELO_AGENDAMENTO_CENTRO.IC_ATIVO%TYPE,
      P_NU_DIA_SEMANA IN VARCHAR,
      P_NU_CAPACIDADE IN VARCHAR,
      P_NU_CAPACIDADE_MAXIMA IN VARCHAR,
      P_NU_ENSACADO IN VARCHAR,
      P_QT_OVERBOOKING IN VARCHAR,
      P_CD_PERFIL_MAQUINA IN VARCHAR,
      P_NU_HORAS_PRODUCAO IN VARCHAR,
      P_DH_INICIO_PRODUCAO IN VARCHAR,
      P_DH_FIM_PRODUCAO IN VARCHAR,
      P_CD_USUARIO_ALTERACAO IN CTF.USUARIO.CD_USUARIO%TYPE,
      P_RESULT OUT T_CURSOR 


  );

   /********************************************************************* 
    To delete parameter values per plant from table: VND.ELO_TEMPLATE_CENTRO and VND.ELO_TEMPLATE_CENTRO_ITEM

    AUTHOR: Sheryl Fernandes

    P_CD_CENTRO_EXPEDIDOR – Plant ID
    P_CD_MACHINE - Machine No
    P_DT_WEEK_START - Week Semana First week day, like DD/MM/YYYY
    P_RESULT – returns the ID from VND.ELO_TEMPLATE_CENTRO table
    /*********************************************************************/

  PROCEDURE PD_AGENDAMENTO_CENTRO_ITEMS
  (
      P_CD_AGENDAMENTO_CENTRO       IN VND.ELO_AGENDAMENTO_CENTRO.CD_AGENDAMENTO_CENTRO%TYPE DEFAULT NULL,
      P_CD_CENTRO_EXPEDIDOR         IN VND.ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
      P_CD_MACHINE                  IN VND.ELO_AGENDAMENTO_CENTRO.CD_MACHINE%TYPE DEFAULT NULL,
      P_CD_USUARIO_ALTERACAO        IN CTF.USUARIO.CD_USUARIO%TYPE DEFAULT NULL,
      P_RESULT                      OUT T_CURSOR
  );

  PROCEDURE PX_GET_MACHINE_PROFILE
  (
      P_MACHINE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE%TYPE,
      P_RESULT  OUT T_CURSOR
  );

END GX_ELO_AGENDAMENTO_PARAMETER1;
/