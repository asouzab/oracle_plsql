CREATE OR REPLACE PACKAGE CTF."GX_MACHINE_MACHINE_PROFILE" AS 

  TYPE T_CURSOR IS REF CURSOR;

  /********************************************************************* 
    List all Machine to bind in ddl.

    AUTHOR: Shiva M

    P_RETORNO – The list of Machine
    /*********************************************************************/
 PROCEDURE PX_MACHINE(P_RETORNO OUT T_CURSOR);



 /********************************************************************* 
    List all Machine_profile  bind in ddl.

    AUTHOR: Shiva M

    P_RETORNO – The list of Machine profile 
    /*********************************************************************/

 PROCEDURE PX_MACHINE_PROFILE(P_RETORNO OUT T_CURSOR);




 --GET
 PROCEDURE PX_MACHINE_MACHINE_PROFILE(P_RESULT OUT T_CURSOR);


  /********************************************************************* 
    Insert data into Machine_Machine_Profile

    AUTHOR: Shiva M
  /*********************************************************************/

 PROCEDURE PI_MACHINE_MACHINE_PROFILE(P_CD_MACHINE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE%TYPE,
                                      P_CD_MACHINE_PROFILE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE_PROFILE%TYPE);

   /********************************************************************* 
    Delete data From Machine_Machine_Profile

    AUTHOR: Shiva M
  /*********************************************************************/
 PROCEDURE PD_MACHINE_MACHINE_PROFILE(P_CD_MACHINE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE%TYPE,
                                      P_CD_MACHINE_PROFILE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE_PROFILE%TYPE);

   /********************************************************************* 
    Update data In Machine_Machine_Profile

    AUTHOR: Shiva M
  /*********************************************************************/                                    

  PROCEDURE PU_MACHINE_MACHINE_PROFILE(P_CD_MACHINE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE%TYPE,
                                        P_CD_MACHINE_PROFILE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE_PROFILE%TYPE,
                                        P_NEW_CD_MACHINE_PROFILE IN CTF.MACHINE_MACHINE_PROFILE.CD_MACHINE_PROFILE%TYPE);
END GX_MACHINE_MACHINE_PROFILE;


/