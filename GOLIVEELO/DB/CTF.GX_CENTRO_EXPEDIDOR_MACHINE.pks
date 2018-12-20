CREATE OR REPLACE PACKAGE CTF."GX_CENTRO_EXPEDIDOR_MACHINE" AS 

TYPE T_CURSOR IS REF CURSOR;

    /********************************************************************* 
    List all centro expedidor and its description to bind in ddl.

    AUTHOR: Santosh Hargunani

    P_RETORNO – The list of centro expedidor and its description
    /*********************************************************************/

PROCEDURE PX_CENTRO_EXPEDIDOR(P_RETORNO OUT T_CURSOR);

    /********************************************************************* 
    List all Machine and its description to bind in ddl.

    AUTHOR: Santosh Hargunani

    P_RETORNO – The list of Machine and its description 
    /*********************************************************************/

PROCEDURE PX_MACHINE(P_RETORNO OUT T_CURSOR);

   /********************************************************************* 
    List all Centro, Nome de Centro and cd machine where isactive='s'.

    AUTHOR: Santosh Hargunani

    P_RETORNO – The List of all Centro, Nome de Centro and cd machine where isactive
    /*********************************************************************/
PROCEDURE PX_CENTRO_EXPEDIDOR_MACHINE(P_RETORNO OUT T_CURSOR);

  /********************************************************************* 
    Insert Centro and Maquina 

    AUTHOR: Santosh Hargunani

    P_CD_CENTRO_EXPEDIDOR – Centro
    P_CD_MACHINE = Maquina
    /*********************************************************************/
PROCEDURE PI_INS_CENTRO_EXP_MACHINE(
                                    P_CD_CENTRO_EXPEDIDOR IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%TYPE,
                                    P_CD_MACHINE  IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_MACHINE%TYPE
                                   );

  /********************************************************************* 
    Deleting Centro and Maquina 

    AUTHOR: Santosh Hargunani

    P_CD_CENTRO_EXPEDIDOR – Centro
    P_CD_MACHINE = Maquina
    /*********************************************************************/                                          
PROCEDURE PD_DEL_CENTRO_EXP_MACHINE(
                                    P_CD_CENTRO_EXPEDIDOR IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%TYPE,
                                    P_CD_MACHINE  IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_MACHINE%TYPE
                                    );

   /********************************************************************* 
    Updating Centro and Maquina 

    AUTHOR: Santosh Hargunani

    P_CD_CENTRO_EXPEDIDOR – Centro
    P_CD_MACHINE_OLD = Old Maquina ID
    P_CD_MACHINE_NEW = New Maquina ID
    /*********************************************************************/ 

PROCEDURE PU_UPD_CENTRO_EXP_MACHINE( 
                                    P_CD_CENTRO_EXPEDIDOR IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%TYPE,
                                    P_CD_MACHINE_OLD  IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_MACHINE%TYPE,
                                    P_CD_MACHINE_NEW  IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_MACHINE%TYPE
                                    );

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

END GX_CENTRO_EXPEDIDOR_MACHINE;


/