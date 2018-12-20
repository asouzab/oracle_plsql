CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_SERVICE" AS

  PROCEDURE PX_SUPERVISORMAIL_DATA (P_RESULT OUT T_CURSOR) AS
  BEGIN

   OPEN P_RESULT  FOR
   SELECT DISTINCT U.NO_USUARIO,EA.DT_WEEK_START,EA.CD_POLO,EC.NO_CLIENTE,EC.NO_PRODUTO_SAP,EAI.CD_INCOTERMS,
   A.NU_QUANTIDADE AS NU_QUANTIDADE,A.NU_DIA_SEMANA,EAS.CD_ELO_AGENDAMENTO_SUPERVISOR,EC.CD_ELO_AGENDAMENTO_ITEM,ES.DS_STATUS,
   EAS.CD_SALES_GROUP,EAI.CD_CLIENTE,
   U.DS_EMAIL,EA.CD_ELO_AGENDAMENTO,EA.NU_SEMANAS, EA.CD_WEEK,
  (SELECT SUM(ECD.NU_QUANTIDADE) ABC FROM VND.ELO_CARTEIRA_DAY ECD 
   INNER JOIN VND.ELO_CARTEIRA EC ON ECD.CD_ELO_CARTEIRA = EC.CD_ELO_CARTEIRA
   WHERE TRUNC(EC.DH_CARTEIRA) = TRUNC(SYSDATE)  AND EC.CD_ELO_AGENDAMENTO_ITEM = EAI.CD_ELO_AGENDAMENTO_ITEM) AS CURRENT_QTY
   FROM VND.ELO_AGENDAMENTO_SUPERVISOR EAS 
   INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI ON EAI.CD_ELO_AGENDAMENTO_SUPERVISOR = EAS.CD_ELO_AGENDAMENTO_SUPERVISOR
   INNER JOIN VND.ELO_CARTEIRA EC ON EAI.CD_ELO_AGENDAMENTO_ITEM = EC.CD_ELO_AGENDAMENTO_ITEM  AND EAS.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
   INNER JOIN VND.ELO_STATUS ES ON EC.CD_TIPO_AGENDAMENTO=ES.CD_ELO_STATUS
   INNER JOIN  VND.ELO_TIPO_STATUS ETS ON ETS.CD_ELO_TIPO_STATUS = ES.CD_ELO_TIPO_STATUS   
   INNER JOIN ELO_CARTEIRA_DAY ECDI ON ECDI.CD_ELO_CARTEIRA = EC.CD_ELO_CARTEIRA  
   INNER JOIN VND.ELO_AGENDAMENTO EA ON EA.CD_ELO_AGENDAMENTO =  EAS.CD_ELO_AGENDAMENTO
   INNER JOIN CTF.USUARIO U ON U.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP
   RIGHT OUTER JOIN 
   (SELECT SUM(NU_QUANTIDADE) AS NU_QUANTIDADE,CD_ELO_CARTEIRA, NU_DIA_SEMANA from ELO_CARTEIRA_DAY 
    GROUP BY CD_ELO_CARTEIRA, NU_DIA_SEMANA) A
   ON A.CD_ELO_CARTEIRA = EC.CD_ELO_CARTEIRA
   WHERE EAS.IC_ATIVO = 'S' AND EAI.IC_ATIVO = 'S' AND EC.IC_ATIVO = 'S' AND U.IC_ATIVO = 'S' AND ES.SG_STATUS IN ('APREP','RPREP') AND
   ETS.SG_TIPO_STATUS = 'TWORK' 
   AND  TRUNC(EC.DH_REPLAN ) = TRUNC(SYSDATE)   and NVL(EC.QT_AGENDADA_CONFIRMADA,0) > 0 
   ORDER BY EAS.CD_ELO_AGENDAMENTO_SUPERVISOR,EC.CD_ELO_AGENDAMENTO_ITEM,A.NU_DIA_SEMANA;
  NULL;
  END PX_SUPERVISORMAIL_DATA;

  PROCEDURE PI_EMAIL (
                    P_DS_EMAIL_TO       IN CTF.EMAIL_SERVICE.DS_EMAIL_TO%TYPE,
                    P_DS_EMAIL_FROM     IN CTF.EMAIL_SERVICE.DS_EMAIL_FROM%TYPE,
                    P_DS_EMAIL_CC       IN CTF.EMAIL_SERVICE.DS_EMAIL_CC%TYPE,
                    P_DS_EMAIL_BCC      IN CTF.EMAIL_SERVICE.DS_EMAIL_BCC%TYPE,
                    P_DS_SUBJECT        IN CTF.EMAIL_SERVICE.DS_SUBJECT%TYPE,
                    P_DS_BODY           IN CTF.EMAIL_SERVICE.DS_BODY%TYPE
                    ) 
                    AS
    BEGIN
    INSERT INTO CTF.EMAIL_SERVICE (
            CD_EMAIL_SERVICE,
            DS_EMAIL_TO,
            DS_EMAIL_FROM,
            DS_EMAIL_CC,
            DS_EMAIL_BCC,
            DS_SUBJECT,
            DT_ADDED,
            DS_BODY,
            IC_ACTIVE
        ) VALUES (
            (SELECT NVL(MAX(CD_EMAIL_SERVICE), 0) + 1 FROM CTF.EMAIL_SERVICE),
            P_DS_EMAIL_TO,
            P_DS_EMAIL_FROM,
            P_DS_EMAIL_CC,
            P_DS_EMAIL_BCC,
            P_DS_SUBJECT,
            SYSDATE,
            P_DS_BODY,
            'S'
        );
         COMMIT;
    EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
    NULL;

END PI_EMAIL;

END GX_ELO_SERVICE;


/