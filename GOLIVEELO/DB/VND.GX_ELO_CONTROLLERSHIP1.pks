CREATE OR REPLACE PACKAGE VND.GX_ELO_CONTROLLERSHIP1 AS 

   TYPE T_CURSOR IS REF CURSOR;
 
/********************************************************************* 
    GET ELO_CONTROLLERSHIP_REASON
    
    AUTHOR: Priyanka Gupta
    
    P_CONTROLLERSHIP_INFO – The items of ELO_CONTROLLERSHIP_REASON
  /*********************************************************************/ 
 PROCEDURE PX_CONTROLLERSHIP_INFO(
      P_CONTROLLERSHIP_INFO OUT T_CURSOR );
      
      /********************************************************************* 
    INSERT ELO_CONTROLLERSHIP_REASON
    
    AUTHOR: Priyanka Gupta
    
     p_DS_CONTROLLERSHIP_REASON – The list of motivo field
     p_CD_DEPARTAMENTO- The list of Deparatamento no
  /*********************************************************************/ 
      
      PROCEDURE PI_INS_CONTROLLERSHIP_PROFILE(
      p_DS_CONTROLLERSHIP_REASON IN VND.ELO_CONTROLLERSHIP_REASON.DS_CONTROLLERSHIP_REASON%TYPE,
      p_CD_DEPARTAMENTO IN VND.ELO_CONTROLLERSHIP_REASON.CD_DEPARTAMENTO%TYPE);
      
        /********************************************************************* 
    DELETE ELO_CONTROLLERSHIP_REASON
    
    AUTHOR: Priyanka Gupta
   
     p_CD_DEPARTAMENTO- The list of ELO_CONTROLLERSHIP_REASON
  /*********************************************************************/ 
      
      PROCEDURE PD_DEL_CONTROLLERSHIP_PROFILE(p_CD_DEPARTAMENTO IN VND.ELO_CONTROLLERSHIP_REASON.CD_ELO_CONTROLLERSHIP_REASON%TYPE
       );
       
          /********************************************************************* 
    SELECT DEPARATAMENTO ELO_CONTROLLERSHIP_REASON
    
    AUTHOR: Priyanka Gupta
   
      P_CONTROLLERSHIP_SELECT- The list of DEPARATAMENTO
  /*********************************************************************/ 
      PROCEDURE PX_CONTROLLERSHIP_SELECT(
      P_CONTROLLERSHIP_SELECT OUT T_CURSOR ); 
      
       /********************************************************************* 
    UPDATE ELO_CONTROLLERSHIP_REASON
    
    AUTHOR: Priyanka Gupta
    p_CD_ELO_CONTROLLERSHIP_REASON- The list of CD_ELO_CONTROLLERSHIP_REASON
     p_DS_CONTROLLERSHIP_REASON – The list of motivo field
     p_CD_DEPARTAMENTO- The list of Deparatamento no
  /*********************************************************************/ 
       PROCEDURE PU_UPD_CONTROLLERSHIP_PROFILE( p_CD_ELO_CONTROLLERSHIP_REASON IN VND.ELO_CONTROLLERSHIP_REASON.CD_ELO_CONTROLLERSHIP_REASON%TYPE,
       p_DS_CONTROLLERSHIP_REASON IN VND.ELO_CONTROLLERSHIP_REASON.DS_CONTROLLERSHIP_REASON%TYPE
      ,p_CD_DEPARTAMENTO IN VND.ELO_CONTROLLERSHIP_REASON.CD_DEPARTAMENTO%TYPE);
      
     
   
   END GX_ELO_CONTROLLERSHIP1;
/