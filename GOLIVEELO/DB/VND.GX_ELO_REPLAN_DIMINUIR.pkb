CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_REPLAN_DIMINUIR" AS

PROCEDURE PX_REPLAN_BASIC_DATA(
  P_RETORNO OUT T_CURSOR

)
AS 
  BEGIN

    OPEN P_RETORNO FOR
    SELECT ei.CD_ELO_AGENDAMENTO_ITEM AS "AGENDAMENTO_ITEM",
      ei.CD_ELO_AGENDAMENTO_SUPERVISOR AS "AGENDAMENTO_SUPERVISOR",
      ei.CD_CLIENTE AS "CLIENTE",
      ei.CD_PRODUTO_SAP AS "PRODUTO_SAP",
      ei.CD_INCOTERMS AS "INCOTERMS",
      ew.CD_ELO_AGENDAMENTO_WEEK AS "AGENDAMENTO_WEEK",
      ew.NU_SEMANA AS "NU_SEMANA"
    FROM ELO_AGENDAMENTO_ITEM ei ,ELO_AGENDAMENTO_WEEK ew
    WHERE ei.CD_ELO_AGENDAMENTO_ITEM = ew.CD_ELO_AGENDAMENTO_ITEM
    AND ei.CD_ELO_AGENDAMENTO_SUPERVISOR = '50005'; -- TO BE PASSED FROM AGENDAMENTO PAGE
END PX_REPLAN_BASIC_DATA;

  PROCEDURE PX_REPLAN (
    P_CD_ELO_AGENDA   IN VND.ELO_AGENDAMENTO_WEEK.CD_ELO_AGENDAMENTO_WEEK %type,
    P_RETORNO         OUT T_CURSOR
) AS
  BEGIN
      OPEN P_RETORNO FOR
      SELECT 
            ead.NU_DIA_SEMANA AS "Semana",
            ead.NU_QUANTIDADE AS "Quantidade"

      FROM ELO_AGENDAMENTO ea, ELO_AGENDAMENTO_SUPERVISOR eas, ELO_AGENDAMENTO_ITEM eai, 
          ELO_AGENDAMENTO_WEEK eaw, ELO_AGENDAMENTO_DAY ead

      WHERE ea.CD_ELO_AGENDAMENTO = eas.CD_ELO_AGENDAMENTO
      AND eas.CD_ELO_AGENDAMENTO_SUPERVISOR = eai.CD_ELO_AGENDAMENTO_SUPERVISOR
      AND eai.CD_ELO_AGENDAMENTO_ITEM = eaw.CD_ELO_AGENDAMENTO_ITEM
      AND eaw.CD_ELO_AGENDAMENTO_WEEK = ead.CD_ELO_AGENDAMENTO_WEEK
      AND eaw.CD_ELO_AGENDAMENTO_WEEK = P_CD_ELO_AGENDA;

    NULL;
  END PX_REPLAN;



  PROCEDURE PI_AGENDA_ITEM (
    p_CD_AGENDA_SUPERVISOR    IN ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR %TYPE,
    p_CD_CLIENTE              IN ELO_AGENDAMENTO_ITEM.CD_CLIENTE %TYPE,
    p_CD_PRODUTO_SAP          IN ELO_AGENDAMENTO_ITEM.CD_PRODUTO_SAP %TYPE,
    p_CD_INCOTERMS            IN ELO_AGENDAMENTO_ITEM.CD_INCOTERMS %TYPE,
    p_CD_AGENDA_ITEM_ANTIGO   IN ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_ITEM_ANTIGO %TYPE,
    --AGENDAMENTO WEEK
    p_NU_SEMANA               IN ELO_AGENDAMENTO_WEEK.NU_SEMANA %TYPE,
    p_QT_SEMANA               IN ELO_AGENDAMENTO_WEEK.QT_SEMANA %TYPE,
    --p_CD_ELO_AGENDAMENTO_WEEK OUT ELO_AGENDAMENTO_WEEK.CD_ELO_AGENDAMENTO_WEEK %TYPE
    P_RETORNO OUT T_CURSOR
) AS
  V_CD_ELO_AGENDAMENTO_ITEM NUMBER :=0;
  V_CD_ELO_AGENDAMENTO_WEEK NUMBER :=0;
  BEGIN
      --INSERTING INTO AGENDAMENTO_ITEM
      SELECT NVL(MAX(CD_ELO_AGENDAMENTO_ITEM),0) + 1
			INTO V_CD_ELO_AGENDAMENTO_ITEM
			FROM VND.ELO_AGENDAMENTO_ITEM;

      INSERT INTO ELO_AGENDAMENTO_ITEM
      ("CD_ELO_AGENDAMENTO_ITEM","CD_ELO_AGENDAMENTO_SUPERVISOR","CD_CLIENTE","CD_PRODUTO_SAP",
      "CD_INCOTERMS","IC_ATIVO","CD_STATUS_REPLAN","CD_ELO_AGENDAMENTO_ITEM_ANTIGO")

      VALUES
      ( V_CD_ELO_AGENDAMENTO_ITEM, p_CD_AGENDA_SUPERVISOR, p_CD_CLIENTE, p_CD_PRODUTO_SAP, p_CD_INCOTERMS,'S',
        (SELECT CD_ELO_STATUS FROM VND.ELO_STATUS ES 
        INNER JOIN  VND.ELO_TIPO_STATUS ETS ON ETS.CD_ELO_TIPO_STATUS = ES.CD_ELO_TIPO_STATUS 
        WHERE ES.SG_STATUS = 'APREP' AND ETS.SG_TIPO_STATUS = 'TWORK') ,p_CD_AGENDA_ITEM_ANTIGO);
      --END


      --INSERTING INTO AGENDAMENTO_WEEK
      SELECT NVL(MAX(CD_ELO_AGENDAMENTO_WEEK),0) + 1
			INTO V_CD_ELO_AGENDAMENTO_WEEK
			FROM VND.ELO_AGENDAMENTO_WEEK;

      INSERT INTO ELO_AGENDAMENTO_WEEK
      ("CD_ELO_AGENDAMENTO_WEEK","CD_ELO_AGENDAMENTO_ITEM","NU_SEMANA","QT_SEMANA")

      VALUES
      ( V_CD_ELO_AGENDAMENTO_WEEK, V_CD_ELO_AGENDAMENTO_ITEM, p_NU_SEMANA, p_QT_SEMANA);
      --END

      OPEN P_RETORNO FOR
      SELECT aw.CD_ELO_AGENDAMENTO_WEEK, eai.CD_ELO_AGENDAMENTO_ITEM
      FROM VND.ELO_AGENDAMENTO_WEEK aw, ELO_AGENDAMENTO_ITEM eai
      WHERE  eai.CD_ELO_AGENDAMENTO_ITEM = aw.CD_ELO_AGENDAMENTO_ITEM
      AND aw.CD_ELO_AGENDAMENTO_WEEK = V_CD_ELO_AGENDAMENTO_WEEK
      AND eai.CD_ELO_AGENDAMENTO_ITEM = V_CD_ELO_AGENDAMENTO_ITEM;

  NULL;
  END PI_AGENDA_ITEM;


PROCEDURE PI_AGENDA_DAY (
  p_CD_ELO_AGENDAMENTO_WEEK     IN ELO_AGENDAMENTO_DAY.CD_ELO_AGENDAMENTO_WEEK %TYPE,
  p_NU_DIA_SEMANA               IN VND.ELO_AGENDAMENTO_DAY.NU_DIA_SEMANA %TYPE,
  p_CD_GRUPO_EMBALAGEM          IN ELO_AGENDAMENTO_DAY.CD_GRUPO_EMBALAGEM %TYPE,
  p_NU_QUANTIDADE               IN ELO_AGENDAMENTO_DAY.NU_QUANTIDADE %TYPE
) AS
  V_CD_ELO_AGENDAMENTO_DAY NUMBER :=0;
  BEGIN

      SELECT NVL(MAX(CD_ELO_AGENDAMENTO_DAY),0) + 1
			INTO V_CD_ELO_AGENDAMENTO_DAY
			FROM VND.ELO_AGENDAMENTO_DAY;

    INSERT INTO ELO_AGENDAMENTO_DAY
    ("CD_ELO_AGENDAMENTO_DAY","CD_ELO_AGENDAMENTO_WEEK","NU_DIA_SEMANA","CD_GRUPO_EMBALAGEM","NU_QUANTIDADE")

    VALUES
    (V_CD_ELO_AGENDAMENTO_DAY,p_CD_ELO_AGENDAMENTO_WEEK,p_NU_DIA_SEMANA,p_CD_GRUPO_EMBALAGEM,p_NU_QUANTIDADE);

  NULL;
  END PI_AGENDA_DAY;


PROCEDURE PX_GETGROUPO (
    P_CD_ELO_AGENDAMENTO_WEEK IN VND.ELO_AGENDAMENTO_DAY.CD_ELO_AGENDAMENTO_WEEK %type,
    P_RETORNO OUT T_CURSOR
)AS
  BEGIN
      OPEN P_RETORNO FOR
      SELECT CD_GRUPO_EMBALAGEM
      FROM ELO_AGENDAMENTO_DAY
      WHERE CD_ELO_AGENDAMENTO_WEEK = P_CD_ELO_AGENDAMENTO_WEEK;
END PX_GETGROUPO;


PROCEDURE PI_CARTERIA (
  p_CD_ELO_AGENDAMENTO_ITEM   IN ELO_CARTEIRA.CD_ELO_AGENDAMENTO_ITEM %TYPE
)
AS
v_CD_ELO_CARTEIRA NUMBER(9,0) :=0;
  BEGIN
        SELECT NVL(MAX(CD_ELO_CARTEIRA),0) + 1
        INTO v_CD_ELO_CARTEIRA
        FROM ELO_CARTEIRA;

       -- INSERT INTO ELO_CARTEIRA
      --  ("CD_ELO_CARTEIRA","IC_ATIVO","CD_TIPO_AGENDAMENTO","CD_TIPO_REPLAN","CD_ELO_AGENDAMENTO_ITEM")

      --  VALUES
       -- (v_CD_ELO_CARTEIRA,'S','Diminuição de Replanejamento',p_CD_ELO_AGENDAMENTO_ITEM);

      INSERT INTO ELO_CARTEIRA
      ("CD_ELO_CARTEIRA","IC_ATIVO","CD_ELO_AGENDAMENTO_ITEM")

      VALUES
      (v_CD_ELO_CARTEIRA,'S',p_CD_ELO_AGENDAMENTO_ITEM);

END PI_CARTERIA;

END GX_ELO_REPLAN_DIMINUIR;


/