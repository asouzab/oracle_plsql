CREATE OR REPLACE PACKAGE CTF."GX_MACHINE_PROF_LINHA_PRODUTO" AS 
TYPE T_CURSOR IS REF CURSOR; 

--List all Machine_Profile to bind in DDL

PROCEDURE PX_MACHINE_PROFILE(P_RETORNO OUT T_CURSOR);

--list all Machine_Profile_linha_produto to bind in DDL

PROCEDURE PX_MACHINE_PROF_LINHA_PRODUTO(P_RETORNO OUT T_CURSOR);

 /********************************************************************* 
    GET MACHINE_PROFILE_LINHA_PRODUTO

    AUTHOR: Shiva M

    P_RESULT – The list of MACHINE_PROFILE_LINHA_PRODUTO
  /*********************************************************************/

PROCEDURE PX_MACHINE_PROF_LIN_PROD_INF(P_RESULT OUT T_CURSOR);

/********************************************************************* 
    Insert data into Insert data into MACHINE_PROFILE_LINHA_PRODUTO

    AUTHOR: Shiva M

    /*********************************************************************/

PROCEDURE PI_MACHINE_PROF_LINHA_PRODUTO(P_CD_MACHINE_PROFILE IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_MACHINE_PROFILE%TYPE,
                                        P_CD_LINHA_PRODUTO_SAP IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_LINHA_PRODUTO_SAP%TYPE);

/********************************************************************* 
    Delete data from MACHINE_PROFILE_LINHA_PRODUTO

    AUTHOR: Shiva M

    /*********************************************************************/

PROCEDURE PD_MACHINE_PROF_LINHA_PRODUTO(P_CD_MACHINE_PROFILE IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_MACHINE_PROFILE%TYPE,
                                        P_CD_LINHA_PRODUTO_SAP IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_LINHA_PRODUTO_SAP%TYPE);

/********************************************************************* 
    Update data in MACHINE_PROFILE_LINHA_PRODUTO

    AUTHOR: Shiva M

    /*********************************************************************/

PROCEDURE PU_MACHINE_PROF_LINHA_PRODUTO(P_CD_MACHINE_PROFILE IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_MACHINE_PROFILE%TYPE,
                                        P_CD_LINHA_PRODUTO_SAP IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_LINHA_PRODUTO_SAP%TYPE,
                                        P_CD_NEW_LINHA_PRODUTO_SAP IN CTF.MACHINE_PROFILE_LINHA_PRODUTO.CD_LINHA_PRODUTO_SAP%TYPE);

END GX_MACHINE_PROF_LINHA_PRODUTO;
/