CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_INTERFACE AS
/******************************************************************************
   NAME:       GX_ELO_INTERFACE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/06/2018      adesouz2       1. Created this package body.
******************************************************************************/


PROCEDURE PI_ADD_INTERFACE
(P_IC_TIPO IN VND.INTERFACE.IC_TIPO%TYPE ,
P_NU_CODIGO IN VND.INTERFACE.NU_CODIGO%TYPE ,
P_CD_USUARIO IN VND.INTERFACE.CD_USUARIO%TYPE )
IS 
BEGIN


    BEGIN 
    INSERT INTO VND.INTERFACE 
    (
        
        IC_TIPO,    
        NU_CODIGO,    
        DH_EXECUCAO,    
        NO_USUARIO_SAP,
        CD_USUARIO,    
        DT_INCLUSAO
    )

    VALUES 
    (

    P_IC_TIPO,      --IC_TIPO,   
    P_NU_CODIGO,    --NU_CODIGO,  
    NULL,           --DH_EXECUCAO,  
    NULL,           --NO_USUARIO_SAP,
    P_CD_USUARIO,   --CD_USUARIO,   
    CURRENT_DATE    --DT_INCLUSAO

    );
    COMMIT;
    EXCEPTION 
    WHEN OTHERS THEN
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_INTERFACE.001 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    ROLLBACK;
    END;

    END;


END PI_ADD_INTERFACE;


PROCEDURE PX_INTERFACE
(P_RESULT OUT  t_cursor)
IS 
BEGIN
        OPEN p_result FOR
        SELECT 
        AI.CD_INTERFACE ID,
        AI.IC_TIPO,
        AI.NU_CODIGO,
        AI.DH_EXECUCAO,
        AI.NO_USUARIO_SAP,
        AI.CD_USUARIO,
        AI.DT_INCLUSAO

        FROM VND.INTERFACE AI
        WHERE
        ROWNUM < 100
        AND AI.DT_INCLUSAO > SYSDATE - 30;
END PX_INTERFACE;


PROCEDURE PX_INTERFACE
(P_IC_TIPO IN VND.INTERFACE.IC_TIPO%TYPE ,
P_NU_CODIGO IN VND.INTERFACE.NU_CODIGO%TYPE ,
P_RESULT OUT  t_cursor)
IS 
BEGIN
        OPEN p_result FOR
        SELECT 
        AI.CD_INTERFACE ID,
        AI.IC_TIPO,
        AI.NU_CODIGO,
        AI.DH_EXECUCAO,
        AI.NO_USUARIO_SAP,
        AI.CD_USUARIO,
        AI.DT_INCLUSAO

        FROM VND.INTERFACE AI
        WHERE
        AI.IC_TIPO = P_IC_TIPO
        AND AI.NU_CODIGO = P_NU_CODIGO
        AND AI.DT_INCLUSAO > SYSDATE - 30;
END PX_INTERFACE;


PROCEDURE PX_INTERFACE
(P_CD_USUARIO IN VND.INTERFACE.CD_USUARIO%TYPE ,
P_RESULT OUT  t_cursor)
IS 
BEGIN
        OPEN p_result FOR
        SELECT 
        AI.CD_INTERFACE ID,
        AI.IC_TIPO,
        AI.NU_CODIGO,
        AI.DH_EXECUCAO,
        AI.NO_USUARIO_SAP,
        AI.CD_USUARIO,
        AI.DT_INCLUSAO

        FROM VND.INTERFACE AI
        WHERE
        AI.CD_USUARIO = P_CD_USUARIO
        AND AI.DT_INCLUSAO > SYSDATE - 30;
        
END PX_INTERFACE;        
        
        PROCEDURE PX_TIPO
(P_RESULT OUT  t_cursor)
IS 
BEGIN
        OPEN p_result FOR
        SELECT 
        'C' ID, 'ORDEM DE VENDA' DS_TIPO
        FROM DUAL
        UNION
        SELECT 
        'G' ID , 'CONTRATO' DS_TIPO
        FROM DUAL;
         
        
END PX_TIPO;

        PROCEDURE PX_NU_CODIGO
(
P_IC_TIPO IN VND.INTERFACE.IC_TIPO%TYPE,
P_NU_CODIGO IN VND.INTERFACE.NU_CODIGO%TYPE,
P_RESULT OUT  t_cursor)
IS 
BEGIN
        OPEN p_result FOR
        SELECT DISTINCT
        AI.CD_INTERFACE ID, 
        AI.IC_TIPO,
        AI.NU_CODIGO

        FROM VND.INTERFACE AI
        WHERE
        (P_NU_CODIGO IS NULL OR (AI.NU_CODIGO = P_NU_CODIGO))
        AND (P_IC_TIPO IS NULL OR (AI.IC_TIPO = P_IC_TIPO))
        AND AI.DT_INCLUSAO > SYSDATE - 30;
         
        
END PX_NU_CODIGO;
     

END GX_ELO_INTERFACE;
/