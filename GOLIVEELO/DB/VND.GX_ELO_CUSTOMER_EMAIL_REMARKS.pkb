CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_CUSTOMER_EMAIL_REMARKS AS
  
    PROCEDURE PU_EXC_GET_CLIENTE_REMARKS
            (P_CD_CUSTOMER_EMAIL OUT T_CURSOR)
    IS 
    
    BEGIN  
    OPEN P_CD_CUSTOMER_EMAIL FOR
        SELECT A.CD_ELO_CUSTOMER_EMAIL_REMARKS, 
        max(A.CD_CLIENTE) CD_CLIENTE , max(B.NO_CLIENTE) NO_CLIENTE, 
        max(A.CD_POLO)CD_POLO ,max(C.DS_POLO) DS_POLO, max(A.DS_REMARKS) DS_REMARKS ,max(A.DH_REMARKS) DH_REMARKS
        FROM VND.ELO_CUSTOMER_EMAIL_REMARKS A INNER JOIN CTF.POLO C
        ON A.CD_POLO = C. CD_POLO INNER JOIN ELO_CARTEIRA B 
        ON A.CD_CLIENTE = B.CD_CLIENTE
        GROUP BY  A.CD_ELO_CUSTOMER_EMAIL_REMARKS ORDER BY A.CD_ELO_CUSTOMER_EMAIL_REMARKS ASC ;
        
    END PU_EXC_GET_CLIENTE_REMARKS;
        
    PROCEDURE PU_EXC_GET_CLIENTE_LIST (P_CD_CLIENTE_LIST OUT T_CURSOR)
    
    IS 
    
    BEGIN  
        OPEN P_CD_CLIENTE_LIST FOR
        SELECT  DISTINCT CD_CLIENTE , NO_CLIENTE  
        FROM ELO_CARTEIRA ORDER BY CD_CLIENTE ASC ; 
        
    END PU_EXC_GET_CLIENTE_LIST;


  PROCEDURE PU_EXC_GET_PLANT_LIST
  ( 
    P_CD_CLIENTE   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,
    P_CD_PLANT_LIST OUT T_CURSOR    
  )
   IS 
    BEGIN  
    OPEN P_CD_PLANT_LIST FOR    
    SELECT DISTINCT CD_POLO FROM ELO_AGENDAMENTO
    INNER JOIN ELO_AGENDAMENTO_SUPERVISOR ON ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO 
    INNER JOIN ELO_AGENDAMENTO_ITEM ON ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO_SUPERVISOR 
    WHERE ELO_AGENDAMENTO_ITEM.CD_CLIENTE = P_CD_CLIENTE ;
     
    END PU_EXC_GET_PLANT_LIST;
    
    
    PROCEDURE PU_EXC_GET_WEEKCODE
  (     
    P_CD_CLIENTE      IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,  
    P_CD_POLO         IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO%TYPE,
    P_CD_WEEK OUT T_CURSOR
  )
    IS 
    BEGIN  
    OPEN P_CD_WEEK FOR    
    SELECT DISTINCT EA.CD_WEEK  from ELO_AGENDAMENTO EA
    INNER JOIN  ELO_AGENDAMENTO_SUPERVISOR ON EA.CD_ELO_AGENDAMENTO=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO
    INNER JOIN ELO_AGENDAMENTO_ITEM ON ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO_SUPERVISOR
    WHERE ELO_AGENDAMENTO_ITEM.CD_CLIENTE = P_CD_CLIENTE AND EA.CD_POLO = P_CD_POLO;
     
    END PU_EXC_GET_WEEKCODE;
    
    PROCEDURE PX_GET_WEEKCODE
        (P_CD_CLIENTE               IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,  
         P_CD_POLO                  IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO%TYPE,
         P_CD_CENTRO_EXPEDIDOR      IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CENTRO_EXPEDIDOR%TYPE,
         P_CD_WEEK                  OUT T_CURSOR)
    
    IS 
    
    BEGIN  
        OPEN P_CD_WEEK FOR    
        SELECT DISTINCT EA.CD_WEEK  
        FROM VND.ELO_AGENDAMENTO EA
        INNER JOIN  ELO_AGENDAMENTO_SUPERVISOR EAS ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
        INNER JOIN ELO_AGENDAMENTO_ITEM EAI ON EAI.CD_ELO_AGENDAMENTO_SUPERVISOR = EAS.CD_ELO_AGENDAMENTO_SUPERVISOR
        WHERE EAI.CD_CLIENTE = P_CD_CLIENTE 
        AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
        AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR);
         
    END PX_GET_WEEKCODE;
    
   PROCEDURE PU_EXC_GET_MACHINE_PROFILE
  (     
     P_CD_MACHINE           IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE%TYPE,   
     P_CD_MACHINE_PROFILE   OUT T_CURSOR
  )
    IS 
    BEGIN  
    OPEN P_CD_MACHINE_PROFILE FOR    
    SELECT DS_MACHINE_PROFILE FROM CTF.MACHINE_PROFILE WHERE CD_MACHINE_PROFILE IN ( SELECT DISTINCT CD_MACHINE_PROFILE  FROM CTF.MACHINE_MACHINE_PROFILE WHERE CD_MACHINE = P_CD_MACHINE );
     
    END PU_EXC_GET_MACHINE_PROFILE;
     
           
  PROCEDURE PU_EXC_UPDATE_CLIENTE_REMARKS
  (   
       P_CD_ELO_CUSTOMER_REMARKS   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_ELO_CUSTOMER_EMAIL_REMARKS%TYPE,
       P_DS_REMARKS                IN VND.ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS%TYPE ,     
       P_CD_USUARIO_INCLUSAO       IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_USUARIO_INCLUSAO%TYPE 
  )
 IS 
    BEGIN

		UPDATE VND.ELO_CUSTOMER_EMAIL_REMARKS SET
      DS_REMARKS = P_DS_REMARKS,
      DH_REMARKS = SYSDATE,
      CD_USUARIO_INCLUSAO = P_CD_USUARIO_INCLUSAO
    WHERE
      CD_ELO_CUSTOMER_EMAIL_REMARKS = P_CD_ELO_CUSTOMER_REMARKS;

  COMMIT;

	EXCEPTION
		WHEN OTHERS THEN
			BEGIN
				RAISE_APPLICATION_ERROR(-20001,	'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
				ROLLBACK;
			END;
	END; 
   
   PROCEDURE PU_EXC_GET_CLIENTE_EMAILID
   (
     P_CD_CLIENTE_ID   IN VND.ELO_CUSTOMER_EMAIL.CD_CLIENTE%TYPE,
     P_CD_CLIENTE_EMAIL OUT T_CURSOR
   )
   IS 
   BEGIN
   OPEN P_CD_CLIENTE_EMAIL FOR
        SELECT DS_EMAIL FROM VND.ELO_CUSTOMER_EMAIL WHERE CD_CLIENTE =P_CD_CLIENTE_ID  ;
       
   END PU_EXC_GET_CLIENTE_EMAILID ;
    
    
  PROCEDURE PU_EXC_MANUALEMAIL_CLIENTDTL
  (
    /* P_CD_PLANT_LIST   IN VND.ELO_AGENDAMENTO.CD_ELO_CUSTOMER_EMAIL_REMARKS%TYPE,*/
     P_CD_CLIENTE   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,
     P_CD_POLO   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO%TYPE,
     P_CD_PLANT_LIST OUT T_CURSOR
  )
  IS
  BEGIN
  OPEN P_CD_PLANT_LIST FOR 

SELECT DISTINCT CD_CLIENTE, NO_CLIENTE,CD_MACHINE ,DT_WEEK_START, CD_GRUPO_EMBALAGEM, DS_REMARKS, SEG, TER, QUA, QUI, SEX, SAB , DOM
FROM 
(
  SELECT CD_CLIENTE,NO_CLIENTE,CD_MACHINE ,DT_WEEK_START,NU_DIA_SEMANA,CD_GRUPO_EMBALAGEM,DS_REMARKS,
  (CASE WHEN NU_DIA_SEMANA=1 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SEG,
  (CASE WHEN NU_DIA_SEMANA=2 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) TER,
  (CASE WHEN NU_DIA_SEMANA=3 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) QUA,
  (CASE WHEN NU_DIA_SEMANA=4 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) QUI,
  (CASE WHEN NU_DIA_SEMANA=5 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SEX,
  (CASE WHEN NU_DIA_SEMANA=6 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SAB,
  (CASE WHEN NU_DIA_SEMANA=7 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) DOM
  FROM 
  (
    SELECT ELO_CARTEIRA.CD_CLIENTE,ELO_CARTEIRA.NO_CLIENTE, ELO_AGENDAMENTO.CD_MACHINE ,ELO_AGENDAMENTO.DT_WEEK_START,ELO_CARTEIRA_DAY.NU_DIA_SEMANA,ELO_CARTEIRA_DAY.CD_GRUPO_EMBALAGEM,ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS,
    SUM(ELO_CARTEIRA_DAY.NU_QUANTIDADE) AS GROUPED_NU_QUANTIDADE 
    FROM VND.ELO_AGENDAMENTO 
    INNER JOIN ELO_AGENDAMENTO_SUPERVISOR ON ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO
    INNER JOIN ELO_AGENDAMENTO_ITEM ON ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN ELO_CARTEIRA ON ELO_CARTEIRA.CD_ELO_AGENDAMENTO_ITEM = ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_ITEM 
      AND ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO=ELO_CARTEIRA.CD_ELO_AGENDAMENTO
    INNER JOIN ELO_CARTEIRA_DAY ON ELO_CARTEIRA.CD_ELO_CARTEIRA=ELO_CARTEIRA_DAY.CD_ELO_CARTEIRA
    INNER JOIN ELO_CUSTOMER_EMAIL_REMARKS ON ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE = ELO_CARTEIRA.CD_CLIENTE
    WHERE ELO_AGENDAMENTO.CD_ELO_STATUS =7 AND ELO_AGENDAMENTO_ITEM.IC_ATIVO='S' AND NVL(ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA,0)>0   AND ELO_CARTEIRA.CD_CLIENTE = P_CD_CLIENTE 
    AND ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO= P_CD_POLO
    GROUP BY ELO_CARTEIRA.CD_CLIENTE,ELO_CARTEIRA.NO_CLIENTE, ELO_AGENDAMENTO.CD_MACHINE , ELO_AGENDAMENTO.DT_WEEK_START,ELO_CARTEIRA_DAY.NU_DIA_SEMANA,ELO_CARTEIRA_DAY.CD_GRUPO_EMBALAGEM , ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS
  )
  GROUP BY CD_CLIENTE,NO_CLIENTE,CD_MACHINE , DT_WEEK_START,NU_DIA_SEMANA,CD_GRUPO_EMBALAGEM , DS_REMARKS
) TAB ;
  
  END;  
   
    PROCEDURE PX_MANUALEMAIL_CLIENTDTL
        (P_CD_CLIENTE               IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,
         P_CD_POLO                  IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO%TYPE,
         P_CD_CENTRO_EXPEDIDOR      IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CENTRO_EXPEDIDOR%TYPE,
         P_CD_PLANT_LIST            OUT T_CURSOR)
         
    IS
    
    BEGIN
    OPEN P_CD_PLANT_LIST FOR 

    SELECT DISTINCT CD_CLIENTE, NO_CLIENTE,CD_MACHINE ,DT_WEEK_START, CD_GRUPO_EMBALAGEM, DS_REMARKS, SEG, TER, QUA, QUI, SEX, SAB , DOM
    FROM (
        SELECT 
            CD_CLIENTE
            ,NO_CLIENTE
            ,CD_MACHINE 
            ,DT_WEEK_START
            ,NU_DIA_SEMANA
            ,CD_GRUPO_EMBALAGEM,DS_REMARKS,
            (CASE WHEN NU_DIA_SEMANA=1 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SEG,
            (CASE WHEN NU_DIA_SEMANA=2 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) TER,
            (CASE WHEN NU_DIA_SEMANA=3 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) QUA,
            (CASE WHEN NU_DIA_SEMANA=4 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) QUI,
            (CASE WHEN NU_DIA_SEMANA=5 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SEX,
            (CASE WHEN NU_DIA_SEMANA=6 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SAB,
            (CASE WHEN NU_DIA_SEMANA=7 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) DOM
        FROM (
                SELECT    EC.CD_CLIENTE
                        , EC.NO_CLIENTE
                        , EA.CD_MACHINE
                        , EA.DT_WEEK_START
                        , ECD.NU_DIA_SEMANA
                        , ECD.CD_GRUPO_EMBALAGEM
                        , CER.DS_REMARKS
                        , SUM(ECD.NU_QUANTIDADE) AS GROUPED_NU_QUANTIDADE 
                FROM VND.ELO_AGENDAMENTO EA
                INNER JOIN ELO_AGENDAMENTO_SUPERVISOR EAS ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
                INNER JOIN ELO_AGENDAMENTO_ITEM EAI ON EAI.CD_ELO_AGENDAMENTO_SUPERVISOR = EAS.CD_ELO_AGENDAMENTO_SUPERVISOR
                INNER JOIN ELO_CARTEIRA EC ON EC.CD_ELO_AGENDAMENTO_ITEM = EAI.CD_ELO_AGENDAMENTO_ITEM 
                       AND EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
                INNER JOIN ELO_CARTEIRA_DAY ECD ON EC.CD_ELO_CARTEIRA = ECD.CD_ELO_CARTEIRA
                INNER JOIN ELO_CUSTOMER_EMAIL_REMARKS CER ON CER.CD_CLIENTE = EC.CD_CLIENTE
                WHERE EA.CD_ELO_STATUS = VND.GX_ELO_COMMON.FX_ELO_STATUS('AGEND', 'PLAN') 
                AND EAI.IC_ATIVO = 'S' 
                AND NVL(EC.QT_AGENDADA_CONFIRMADA, 0) > 0
                AND EC.CD_CLIENTE = P_CD_CLIENTE 
                AND (P_CD_POLO IS NULL OR CER.CD_POLO = P_CD_POLO)
                AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR CER.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
                GROUP BY EC.CD_CLIENTE, EC.NO_CLIENTE, EA.CD_MACHINE , EA.DT_WEEK_START, ECD.NU_DIA_SEMANA, ECD.CD_GRUPO_EMBALAGEM , CER.DS_REMARKS
                )
    GROUP BY CD_CLIENTE,NO_CLIENTE,CD_MACHINE , DT_WEEK_START,NU_DIA_SEMANA,CD_GRUPO_EMBALAGEM , DS_REMARKS
    ) TAB ;
  
  END PX_MANUALEMAIL_CLIENTDTL; 
   
  PROCEDURE PU_EXC_AUTOEMAIL_CLIENTDTL
  (   
     P_CD_PLANT_LIST OUT T_CURSOR
  )
  IS
  BEGIN
  OPEN P_CD_PLANT_LIST FOR
  

SELECT DISTINCT CD_CLIENTE, NO_CLIENTE,CD_POLO, CD_MACHINE ,CD_WEEK, DS_EMAIL, DT_WEEK_START, CD_GRUPO_EMBALAGEM, DS_REMARKS, SEG, TER, QUA, QUI, SEX, SAB , DOM
FROM 
(
  SELECT CD_CLIENTE,NO_CLIENTE,CD_POLO, CD_MACHINE, CD_WEEK, DS_EMAIL, DT_WEEK_START,NU_DIA_SEMANA,CD_GRUPO_EMBALAGEM,DS_REMARKS,
  (CASE WHEN NU_DIA_SEMANA=1 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SEG,
  (CASE WHEN NU_DIA_SEMANA=2 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) TER,
  (CASE WHEN NU_DIA_SEMANA=3 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) QUA,
  (CASE WHEN NU_DIA_SEMANA=4 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) QUI,
  (CASE WHEN NU_DIA_SEMANA=5 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SEX,
  (CASE WHEN NU_DIA_SEMANA=6 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) SAB,
  (CASE WHEN NU_DIA_SEMANA=7 THEN MAX(GROUPED_NU_QUANTIDADE) ELSE 0 END) DOM
  FROM 
  (
    SELECT ELO_CARTEIRA.CD_CLIENTE,ELO_CARTEIRA.NO_CLIENTE,ELO_AGENDAMENTO.CD_POLO , ELO_AGENDAMENTO.CD_MACHINE , ELO_AGENDAMENTO.CD_WEEK , ELO_CUSTOMER_EMAIL.DS_EMAIL, ELO_AGENDAMENTO.DT_WEEK_START,ELO_CARTEIRA_DAY.NU_DIA_SEMANA,ELO_CARTEIRA_DAY.CD_GRUPO_EMBALAGEM,ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS,
    SUM(ELO_CARTEIRA_DAY.NU_QUANTIDADE) AS GROUPED_NU_QUANTIDADE 
    FROM VND.ELO_AGENDAMENTO 
    INNER JOIN ELO_AGENDAMENTO_SUPERVISOR ON ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO
    INNER JOIN ELO_AGENDAMENTO_ITEM ON ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_SUPERVISOR=ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN ELO_CARTEIRA ON ELO_CARTEIRA.CD_ELO_AGENDAMENTO_ITEM = ELO_AGENDAMENTO_ITEM.CD_ELO_AGENDAMENTO_ITEM 
    AND ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO=ELO_CARTEIRA.CD_ELO_AGENDAMENTO
    INNER JOIN ELO_CARTEIRA_DAY ON ELO_CARTEIRA.CD_ELO_CARTEIRA=ELO_CARTEIRA_DAY.CD_ELO_CARTEIRA
    INNER JOIN ELO_CUSTOMER_EMAIL_REMARKS ON ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE = ELO_CARTEIRA.CD_CLIENTE
    INNER JOIN ELO_CUSTOMER_EMAIL ON ELO_CUSTOMER_EMAIL.CD_CLIENTE = ELO_CARTEIRA.CD_CLIENTE
    WHERE ELO_AGENDAMENTO.CD_ELO_STATUS =7 AND ELO_AGENDAMENTO_ITEM.IC_ATIVO='S' AND NVL(ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA,0)>0   
    GROUP BY ELO_CARTEIRA.CD_CLIENTE,ELO_CARTEIRA.NO_CLIENTE,ELO_AGENDAMENTO.CD_POLO, ELO_AGENDAMENTO.CD_MACHINE, ELO_AGENDAMENTO.CD_WEEK , ELO_CUSTOMER_EMAIL.DS_EMAIL, ELO_AGENDAMENTO.DT_WEEK_START,ELO_CARTEIRA_DAY.NU_DIA_SEMANA,ELO_CARTEIRA_DAY.CD_GRUPO_EMBALAGEM , ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS
  )
  GROUP BY CD_CLIENTE,NO_CLIENTE, CD_POLO,CD_MACHINE, CD_WEEK , DS_EMAIL , DT_WEEK_START,NU_DIA_SEMANA,CD_GRUPO_EMBALAGEM , DS_REMARKS
) TAB ;

  END;  
   
   
    PROCEDURE PU_INS_CUSTOMER_EMAILREMARK
    (   
        P_CD_ELO_AGENDAMENTO   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_ELO_AGENDAMENTO%TYPE,
        P_CD_CLIENTE           IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,  
        P_CD_POLO              IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO%TYPE,
        P_DS_OBSERVACOES       IN VND.ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS%TYPE ,
        P_CD_USUARIO_INCLUSAO  IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_USUARIO_INCLUSAO%TYPE    
    )
    
    IS 
    
    BEGIN

    INSERT INTO VND.ELO_CUSTOMER_EMAIL_REMARKS  ( CD_ELO_CUSTOMER_EMAIL_REMARKS, CD_ELO_AGENDAMENTO, CD_CLIENTE, CD_POLO,CD_CENTRO_EXPEDIDOR, DS_REMARKS ,DH_REMARKS , CD_USUARIO_INCLUSAO )
    VALUES (SEQ_ELO_CUSTOMER_EMAIL.NEXTVAL,P_CD_ELO_AGENDAMENTO,P_CD_CLIENTE, P_CD_POLO,5006,  P_DS_OBSERVACOES , SYSDATE, P_CD_USUARIO_INCLUSAO);  
        
    COMMIT;

	EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            RAISE_APPLICATION_ERROR(-20001,'ERRO ENCONTRADO - ' || SQLCODE || ' - ERROR - ' || SQLERRM);
        ROLLBACK;
        END;
	END; 
  
    PROCEDURE PI_CUSTOMER_EMAILREMARK
    (   P_CD_ELO_AGENDAMENTO    IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_ELO_AGENDAMENTO%TYPE,
        P_CD_CLIENTE            IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CLIENTE%TYPE,  
        P_CD_POLO               IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_CENTRO_EXPEDIDOR%TYPE,
        P_DS_OBSERVACOES        IN VND.ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS%TYPE ,
        P_CD_USUARIO_INCLUSAO   IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_USUARIO_INCLUSAO%TYPE)
    
    IS 
    
    BEGIN

    INSERT INTO VND.ELO_CUSTOMER_EMAIL_REMARKS ( 
              CD_ELO_CUSTOMER_EMAIL_REMARKS
            , CD_ELO_AGENDAMENTO
            , CD_CLIENTE
            , CD_POLO
            , CD_CENTRO_EXPEDIDOR
            , DS_REMARKS
            , DH_REMARKS
            , CD_USUARIO_INCLUSAO)
    VALUES 
        (   SEQ_ELO_CUSTOMER_EMAIL.NEXTVAL
            , P_CD_ELO_AGENDAMENTO
            , P_CD_CLIENTE
            , P_CD_POLO
            , P_CD_CENTRO_EXPEDIDOR
            , P_DS_OBSERVACOES
            , SYSDATE
            , P_CD_USUARIO_INCLUSAO
        );  
        
    COMMIT;

	EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            RAISE_APPLICATION_ERROR(-20001,'ERRO ENCONTRADO - ' || SQLCODE || ' - ERROR - ' || SQLERRM);
        ROLLBACK;
        END;
	END; 
  
  
  PROCEDURE pi_saveemail (
        p_ds_email_to       IN ctf.email_service.ds_email_to%TYPE,
        p_ds_email_from     IN ctf.email_service.ds_email_from%TYPE,
        p_ds_email_cc       IN ctf.email_service.ds_email_cc%TYPE,
        p_ds_email_bcc      IN ctf.email_service.ds_email_bcc%TYPE,
        p_ds_subject        IN ctf.email_service.ds_subject%TYPE,
        p_ds_body        IN ctf.email_service.ds_body%TYPE,      
        p_retorno           OUT t_cursor
    )
    IS
        v_cd_email_service ctf.email_service.cd_email_service%TYPE;
    BEGIN

        SELECT NVL(MAX(cd_email_service), 0) + 1
          INTO v_cd_email_service
          FROM ctf.email_service;
          
        INSERT INTO ctf.email_service (
            cd_email_service,
            ds_email_to,
            ds_email_from,
            ds_email_cc,
            ds_email_bcc,
            ds_subject,
            dt_added,
            ds_body,
            IC_ACTIVE
        ) VALUES (
            v_cd_email_service,
            p_ds_email_to,
            p_ds_email_from,
            p_ds_email_cc,
            p_ds_email_bcc,
            p_ds_subject,
            SYSDATE,
            p_ds_body,
            'S'
        );

        OPEN p_retorno FOR
        SELECT * FROM ctf.email_service WHERE cd_email_service = v_cd_email_service;

    END pi_saveemail;
  


    PROCEDURE PX_DEVOLUTIVA_DATA
    (   
        P_CD_ELO_AGENDAMENTO   IN VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        P_DS_REMARKS           IN VND.ELO_CUSTOMER_EMAIL_REMARKS.DS_REMARKS%TYPE,
        P_CD_USUARIO_INCLUSAO  IN VND.ELO_CUSTOMER_EMAIL_REMARKS.CD_USUARIO_INCLUSAO%TYPE,
        P_RETORNO              OUT T_CURSOR,
        P_EMAILS_CENTROS       OUT T_CURSOR
    )
    IS
    BEGIN
        IF TRIM(NVL(p_ds_remarks, ' ')) <> '' THEN
            insert into vnd.elo_customer_email_remarks ( 
                cd_elo_customer_email_remarks,
                cd_elo_agendamento,
                cd_cliente,
                cd_polo,
                cd_centro_expedidor,
                ds_remarks,
                dh_remarks,
                cd_usuario_inclusao
            )
            select SEQ_ELO_CUSTOMER_EMAIL.NEXTVAL,
                   cd_elo_agendamento,
                   cd_cliente_pagador,
                   cd_polo,
                   cd_centro_expedidor,
                   p_ds_remarks,
                   CURRENT_DATE,
                   p_cd_usuario_inclusao
              from (
                        select cd_cliente_pagador,
                               MAX(ag.cd_elo_agendamento) cd_elo_agendamento,
                               MAX(ag.cd_polo) cd_polo,
                               MAX(ag.cd_centro_expedidor) cd_centro_expedidor
                          from elo_carteira ec
                         inner join 
                               vnd.elo_agendamento ag
                               on ag.cd_elo_agendamento = ec.cd_elo_agendamento
                         where ec.cd_elo_agendamento = p_cd_elo_agendamento
                           and nvl(ec.qt_agendada_confirmada, 0) > 0
                           and ec.cd_incoterms = 'FOB'
                           and ag.cd_elo_agendamento = p_cd_elo_agendamento
                           AND ag.ic_ativo = 'S'
                         group by cd_cliente_pagador
                   )
            ;
        END IF;
               
        OPEN P_RETORNO FOR
        WITH clientes AS
             (
                select cd_cliente_pagador,
                       no_cliente_pagador,
                       LISTAGG(cm.ds_email, ';') WITHIN GROUP (ORDER BY cm.ds_email) AS ds_email
                       
                  from elo_carteira ec
                  
                  left outer join
                       vnd.elo_customer_email cm
                       on cm.cd_cliente = ec.cd_cliente
                       
                 where ec.cd_elo_agendamento = p_cd_elo_agendamento
                   and nvl(ec.qt_agendada_confirmada, 0) > 0
                   and ec.cd_incoterms = 'FOB'
                   
                 group by cd_cliente_pagador,
                          no_cliente_pagador
             ),
             agend AS
             (
                select ag.cd_elo_agendamento,
                       ag.cd_polo,
                       ag.cd_centro_expedidor,
                       ag.dt_week_start,
                       CASE WHEN ag.cd_polo IS NOT NULL THEN 'Polo ' || po.ds_polo
                            WHEN ag.cd_centro_expedidor IS NOT NULL THEN ce.ds_centro_expedidor
                            WHEN ag.cd_machine IS NOT NULL THEN ma.ds_machine
                       END no_local
                       
                  from vnd.elo_agendamento ag
                 
                 left outer join ctf.polo po
                       on po.cd_polo = ag.cd_polo
                 
                 left outer join ctf.centro_expedidor ce
                       on ce.cd_centro_expedidor = ag.cd_centro_expedidor    
                 
                 left outer join ctf.machine ma
                       on ma.cd_machine = ag.cd_machine    
                                  
                 where ag.cd_elo_agendamento = p_cd_elo_agendamento
                   AND ag.ic_ativo = 'S'
             )
        select cl.cd_cliente_pagador cd_cliente,
               cl.no_cliente_pagador no_cliente,
               cl.ds_email,
               ag.dt_week_start,
               ag.cd_polo,
               ag.cd_centro_expedidor,
               ag.no_local,
               ad.nu_dia_semana,
               ad.cd_grupo_embalagem,
               ge.ds_grupo_embalagem,
               p_ds_remarks ds_remarks,
               LISTAGG(us.ds_email, ';') WITHIN GROUP (ORDER BY us.ds_email) AS ds_email_supervisor,
               SUM(ad.nu_quantidade) nu_quantidade

          from 
          
               vnd.elo_agendamento_day ad
               
         inner join 
               vnd.elo_agendamento_week aw    
               on ad.cd_elo_agendamento_week = aw.cd_elo_agendamento_week 
               
         inner join 
               vnd.elo_agendamento_item ai
               on aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item         
          
         inner join 
               vnd.elo_agendamento_supervisor ap
               on ai.cd_elo_agendamento_supervisor = ap.cd_elo_agendamento_supervisor       
               
         inner join agend ag
               on ap.cd_elo_agendamento = ag.cd_elo_agendamento
               
         inner join 
               clientes cl
               on cl.cd_cliente_pagador = ai.cd_cliente
       
         left outer join
               vnd.grupo_embalagem ge
               on ge.cd_grupo_embalagem = ad.cd_grupo_embalagem
               
         left outer join 
              ctf.usuario us
              on ap.cd_sales_group = us.cd_usuario_original
              
         where ai.ic_ativo = 'S'
           and ai.cd_incoterms = 'FOB'
           
         group by cl.cd_cliente_pagador,
                  cl.no_cliente_pagador,
                  cl.ds_email,
                  ag.dt_week_start,
                  ag.cd_polo,
                  ag.cd_centro_expedidor,
                  ag.no_local,
                  ad.nu_dia_semana,
                  ad.cd_grupo_embalagem,
                  ge.ds_grupo_embalagem

         order by cl.cd_cliente_pagador,
                  ad.cd_grupo_embalagem,
                  ad.nu_dia_semana
        ;

        OPEN P_EMAILS_CENTROS FOR
        select LISTAGG(ds_email, ';') WITHIN GROUP (ORDER BY ds_email) AS ds_email
          from (
                    select ce.ds_email

                      from vnd.elo_agendamento ag
                      
                      LEFT OUTER JOIN 
                           vnd.elo_agendamento_polo_centro pc
                           ON pc.cd_polo = ag.cd_polo
                           
                      LEFT outer join
                           ctf.centro_expedidor ce
                           on (ag.cd_polo IS NULL OR ce.cd_centro_expedidor = pc.cd_centro_expedidor)
                          and (ag.cd_centro_expedidor IS NULL OR ce.cd_centro_expedidor = ag.cd_centro_expedidor)
                           
                     WHERE 
                           (ag.cd_polo IS NULL OR pc.cd_polo = ag.cd_polo)
                       AND (ag.cd_centro_expedidor IS NULL OR ce.cd_centro_expedidor = ag.cd_centro_expedidor)
                       AND ag.cd_elo_agendamento = p_cd_elo_agendamento
                       
                     GROUP BY ce.DS_EMAIL
                )
        ;

    END PX_DEVOLUTIVA_DATA;
    
  
END GX_ELO_CUSTOMER_EMAIL_REMARKS;
/