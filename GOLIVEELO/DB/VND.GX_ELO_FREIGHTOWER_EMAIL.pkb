CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_FREIGHTOWER_EMAIL" AS

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


PROCEDURE SEND_ELO_FREIGHTOWER_EMAIL (
P_CD_DEPARTAMENTO IN VARCHAR2,
P_GRIDTORREFRETES_TABLE IN CTF.EMAIL_SERVICE.DS_BODY%TYPE,
P_RETORNO                       OUT T_CURSOR )
IS


numMax NUMBER :=0 ;
numLinhas NUMBER := 0;
cod_email NUMBER := 0;
msg_codusuario VARCHAR(8) := '  ';
msg_coddepartamento VARCHAR(8) := '  ';
msg_nmusuario VARCHAR(140):= '  ';
msg_emailusuario VARCHAR(4000):= ' ';
msg_email CTF.EMAIL_SERVICE.DS_BODY%TYPE;
msg_title VARCHAR(100):= '  ';

P_EMAIL_TO         VARCHAR2(4000);
P_EMAIL_FROM       VARCHAR2(200);
P_EMAIL_SUBJECT    VARCHAR2(200);
P_EMAIL_MENSAGEM   CTF.EMAIL_SERVICE.DS_BODY%TYPE;
P_IC_ATIVO         VARCHAR2(200);
SIGLA CTF.SIGLA.SG_SIGLA%TYPE;
V_EXEC NUMBER:=1;

C_DEPARTAMENTO     T_CURSOR;
R_DEPT R_DEPARTAMENTO_MENSAGEM;

BEGIN 

msg_email:= '<!DOCTYPE html> <html lang="en" xmlns="http://www.w3.org/1999/xhtml"> <head>     <meta charset="utf-8">     <meta http-equiv="X-UA-Compatible" content="IE=edge">';
msg_email:=  msg_email  || '<meta name="viewport" content="width=device-width, initial-scale=1">     <title>Mosaic Fertilizantes do Brasil</title> ';

msg_email:=  msg_email  || '
<style type="text/css">
body {font-family:arial,sans-serif;} 
#tbTorreFretes {    font-family: arial, sans-serif;    border-collapse: collapse;    width: 100%;}
#tbTorreFretes td, #tbTorreFretes th {    border: 1px solid #ddd;    padding: 8px;  width: 150px;}
#tbTorreFretes tr:nth-child(even){background-color: #f2f2f2;}
#tbTorreFretes tr:hover {background-color: #ddd;}
#tbTorreFretes th {    padding-top: 10px;    padding-bottom: 10px;    text-align: left;    background-color: gray;    color: black;}
</style>';

msg_email:=  msg_email  || '</head> <body>     <p>Prezados ,</p>     <p>{{titlemsg}} <p> {{GRIDTORREFRETES_TABLE}} '; 
msg_email:=  msg_email  || '</p><p>Atenciosamente,</p><p>Mosaic Fertilizantes do Brasil</p> </body> </html>';


--    IF P_CD_DEPARTAMENTO IS NOT NULL THEN 
--        BEGIN
--        SELECT d.CD_DEPARTAMENTO, dm.CD_USUARIO 
--        INTO msg_coddepartamento, msg_codusuario
--        FROM CTF.DEPARTAMENTO d
--        INNER JOIN CTF.DEPARTAMENTO_MENSAGEM dm
--        ON
--        D.CD_DEPARTAMENTO = dm.CD_DEPARTAMENTO
--        
--        WHERE 
--        d.CD_DEPARTAMENTO = TO_NUMBER(P_CD_DEPARTAMENTO)
--        AND dm.CD_USUARIO IS NOT NULL AND ROWNUM =1 
--        ;
--        EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--        SIGLA:='BLANK';
--        msg_coddepartamento:=0;
--        msg_codusuario:=0;
--        V_EXEC:=0;
--        --RAISE_APPLICATION_ERROR(-20000,'MENSAGEM'||SQLERRM);
--        WHEN OTHERS THEN
--        SIGLA:='BLANK';
--        msg_coddepartamento:=0;
--        msg_codusuario:=0;
--        V_EXEC:=0;
--        END;

        OPEN C_DEPARTAMENTO FOR 
        SELECT dm.CD_USUARIO_MENSAGEM, dm.CD_DEPARTAMENTO, dm.CD_USUARIO, dm.IC_LOGIN, u.ds_email 

        FROM CTF.DEPARTAMENTO d
        INNER JOIN CTF.DEPARTAMENTO_MENSAGEM dm
        ON
        D.CD_DEPARTAMENTO = dm.CD_DEPARTAMENTO
        INNER JOIN CTF.USUARIO u 
        ON
        u.CD_USUARIO = dm.CD_USUARIO


        WHERE 
        d.CD_DEPARTAMENTO = TO_NUMBER(P_CD_DEPARTAMENTO)
        AND dm.CD_USUARIO IS NOT NULL ;



        LOOP
            FETCH C_DEPARTAMENTO
             INTO R_DEPT.CD_USUARIO_MENSAGEM,
                  R_DEPT.CD_DEPARTAMENTO,
                  R_DEPT.CD_USUARIO,
                  R_DEPT.IC_LOGIN,
                  R_DEPT.DS_EMAIL
                  ;

            EXIT WHEN C_DEPARTAMENTO%NOTFOUND;
            --PIPE ROW(R_OUT);
            msg_emailusuario:=msg_emailusuario || NVL(R_DEPT.DS_EMAIL, ' ') || ';';

        END LOOP;

        IF C_DEPARTAMENTO%ISOPEN THEN
            CLOSE C_DEPARTAMENTO;
        END IF;

        IF  NVL(msg_emailusuario, ' ') = ' ' THEN 
            V_EXEC:=0;
            ELSE
            msg_emailusuario:= LTRIM(msg_emailusuario);
            msg_emailusuario:= substr(msg_emailusuario,1,length(msg_emailusuario)-1);

        END IF;

--     END IF;   

--    IF V_EXEC=1 THEN   
--        BEGIN
--        SELECT u.no_usuario, u.ds_email 
--            INTO msg_nmusuario, msg_emailusuario 
--        
--        FROM CTF.USUARIO u 
--        WHERE u.CD_USUARIO = msg_codusuario;
--            EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--        SIGLA:='BLANK';
--        msg_nmusuario:=0;
--        msg_emailusuario:=0;
--        V_EXEC:=0;
--        --RAISE_APPLICATION_ERROR(-20000,'MENSAGEM'||SQLERRM);
--        WHEN OTHERS THEN
--        SIGLA:='BLANK';
--        msg_nmusuario:=0;
--        msg_emailusuario:=0;
--        V_EXEC:=0;
--        
--        RAISE_APPLICATION_ERROR(-20000,'MENSAGEM'||SQLERRM);
--        END;
--        ELSE 
--        V_EXEC:=0;
--    
--    END IF;

    IF V_EXEC=1 THEN 

        BEGIN
        SELECT 
        SG.SG_SIGLA INTO SIGLA
        FROM CTF.DEPARTAMENTO DEP
        INNER JOIN CTF.SIGLA SG
        ON 
        SG.CD_SIGLA = DEP.CD_SIGLA
        INNER JOIN CTF.TIPO_SIGLA TSG
        ON SG.CD_TIPO_SIGLA = TSG.CD_TIPO_SIGLA 
        WHERE 
        TSG.IC_ATIVO = 'S'
        AND SG.IC_ATIVO = 'S'
        AND TSG.CD_TIPO_SIGLA = 7
        AND DEP.CD_DEPARTAMENTO = TO_NUMBER(P_CD_DEPARTAMENTO) ;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        SIGLA:='BLANK';
        V_EXEC:=0;
        --RAISE_APPLICATION_ERROR(-20000,'MENSAGEM'||SQLERRM);
        WHEN OTHERS THEN
        SIGLA:='BLANK';
        V_EXEC:=0;
        RAISE_APPLICATION_ERROR(-20000,'MENSAGEM'||SQLERRM);
        END;

    END IF;


    msg_title:='Segue Lista de Contratos para conferência e ações';   -- customer service  gestao de carteira 31

    IF SIGLA = 'EMCSG' OR SIGLA = 'EMCTR' THEN 
    msg_title:='Segue Lista de Contratos Referente ao BackLog CIF';   -- customer service  13 e 30 
    END IF;

    msg_email := replace( msg_email, '{{titlemsg}}', msg_title );

    msg_email := replace( msg_email, '{{GRIDTORREFRETES_TABLE}}', P_GRIDTORREFRETES_TABLE );

    IF V_EXEC = 1 THEN 
       BEGIN
        BEGIN

            P_EMAIL_TO := msg_emailusuario;
            P_EMAIL_FROM := 'noreply@mosaicco.com';
            P_EMAIL_SUBJECT := 'Atualização dos Contratados do Mosaic ELO';
            P_EMAIL_MENSAGEM := msg_email;
            P_IC_ATIVO := 'S';
            PI_ELO_FREIGHTOWER_EMAIL(
                P_EMAIL_TO         => P_EMAIL_TO,
                P_EMAIL_FROM       => P_EMAIL_FROM,
                P_EMAIL_SUBJECT    => P_EMAIL_SUBJECT,
                P_EMAIL_MENSAGEM   => P_EMAIL_MENSAGEM,
                P_IC_ATIVO         => P_IC_ATIVO
            );
    --SELECT '1' INTO P_EMAIL_TO FROM DUAL ;

        EXCEPTION
        WHEN OTHERS THEN
        V_EXEC:=0;
        RAISE_APPLICATION_ERROR(-20000,'MENSAGEM'||SQLERRM);

        END;
        END;

    END IF;


        OPEN P_RETORNO FOR
        SELECT V_EXEC  AS P_SUCESSO
        FROM DUAL;


END SEND_ELO_FREIGHTOWER_EMAIL;


PROCEDURE PI_ELO_FREIGHTOWER_EMAIL
(
 P_EMAIL_TO IN VARCHAR2 ,
 P_EMAIL_FROM IN VARCHAR2 DEFAULT 'noreply@mosaicco.com' ,
 P_EMAIL_SUBJECT IN VARCHAR2 ,
 P_EMAIL_MENSAGEM IN CTF.EMAIL_SERVICE.DS_BODY%TYPE,
 P_IC_ATIVO IN VARCHAR2 DEFAULT 'S' 
) IS 

BEGIN
  INSERT INTO CTF.EMAIL_SERVICE 
  (CD_EMAIL_SERVICE, DS_EMAIL_TO, DS_EMAIL_FROM, DS_SUBJECT, DS_BODY, IC_ACTIVE, DT_ADDED)
    VALUES
    ((SELECT NVL(MAX(CD_EMAIL_SERVICE), 0) + 1 FROM CTF.EMAIL_SERVICE), 
    P_EMAIL_TO, 
    P_EMAIL_FROM, 
    P_EMAIL_SUBJECT, 
    P_EMAIL_MENSAGEM, 
    P_IC_ATIVO,
    SYSDATE);




END PI_ELO_FREIGHTOWER_EMAIL;


	PROCEDURE PX_GET_BACKLOG_CIF_DEPTO (  
	P_RETURN OUT T_CURSOR )
    IS
    BEGIN

    OPEN P_RETURN FOR

    SELECT 
    DEP.CD_DEPARTAMENTO, 
    DEP.DS_DEPARTAMENTO, 
    DEP.CD_SIGLA , 
    SG.NO_SIGLA, 
    SG.SG_SIGLA, 
    SG.CD_TIPO_SIGLA 

    FROM CTF.DEPARTAMENTO DEP
    INNER JOIN CTF.SIGLA SG
    ON 
    SG.CD_SIGLA = DEP.CD_SIGLA
    INNER JOIN CTF.TIPO_SIGLA TSG
    ON SG.CD_TIPO_SIGLA = TSG.CD_TIPO_SIGLA 
    WHERE 
    TSG.IC_ATIVO = 'S'
    AND SG.IC_ATIVO = 'S'
    AND TSG.CD_TIPO_SIGLA = 7;

    END PX_GET_BACKLOG_CIF_DEPTO;



END GX_ELO_FREIGHTOWER_EMAIL;


/