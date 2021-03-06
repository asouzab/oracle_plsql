CREATE OR REPLACE PACKAGE VND."GX_ELO_FREIGHTTOWERREASON" IS
 TYPE T_CURSOR IS REF CURSOR;

   PROCEDURE PX_GET_SELECTROWVAL (P_RETURN OUT T_CURSOR);
   PROCEDURE PX_GET_SELECTALL (P_RETURN OUT T_CURSOR); 
   PROCEDURE PX_GET_SELECTDEP (P_RETURN OUT T_CURSOR);
   PROCEDURE PX_GET_SELECTDEC (P_RETURN OUT T_CURSOR);
   PROCEDURE SP_INSERT_ELO_FREIGHT_TOWER( 
      P_REASON1     IN ELO_FREIGHT_TOWER_REASON.CD_ELO_FREIGHT_TOWER_REASON%TYPE,
      P_REASON      IN ELO_FREIGHT_TOWER_REASON.DS_FREIGHT_TOWER_REASON%TYPE,   
      P_COLOR       IN ELO_FREIGHT_TOWER_REASON.DS_COLOR%TYPE,   
      P_Departament IN ELO_FREIGHT_TOWER_REASON.CD_DEPARTAMENTO%TYPE,
      P_RETURN      OUT T_CURSOR
      );

    PROCEDURE SP_UPDATE_ELO_FREIGHT_TOWER ( 
      P_REASON1     IN ELO_FREIGHT_TOWER_REASON.CD_ELO_FREIGHT_TOWER_REASON%TYPE,
      P_REASON      IN ELO_FREIGHT_TOWER_REASON.DS_FREIGHT_TOWER_REASON%TYPE,   
      P_COLOR       IN ELO_FREIGHT_TOWER_REASON.DS_COLOR%TYPE,   
      P_Departament IN ELO_FREIGHT_TOWER_REASON.CD_DEPARTAMENTO%TYPE,
      P_RETURN      OUT T_CURSOR);
     PROCEDURE SP_DELETE_ELO_FREIGHT_TOWER (    
      P_REASON IN ELO_FREIGHT_TOWER_REASON.CD_ELO_FREIGHT_TOWER_REASON%TYPE,
      P_RETURN      OUT T_CURSOR);

     PROCEDURE SP_SELECT_ELO_FREIGHT_TOWER (    
      P_REASON IN ELO_FREIGHT_TOWER_REASON.DS_FREIGHT_TOWER_REASON%TYPE,   
      ELO_FREIGHT_TOWER_REASON OUT SYS_REFCURSOR);


END GX_ELO_FREIGHTTOWERREASON;


/