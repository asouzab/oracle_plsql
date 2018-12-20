CREATE OR REPLACE PACKAGE VND.GX_ELO_PRIORITY_PANEL AS 

TYPE T_CURSOR IS REF CURSOR;

/********************************************************************* 
    Insert into ELO_PRIORITY_PANEL
    
    AUTHOR: SACHIN
    
    p_PriorityOption – Priority Option    
    p_NUOrder - Sequence
/*********************************************************************/
PROCEDURE PI_PRIORITY(
        p_PriorityOption            IN VND.ELO_PRIORITY_PANEL.CD_ELO_PRIORITY_OPTION%TYPE,
        p_NUOrder                   IN VND.ELO_PRIORITY_PANEL.NU_ORDER%TYPE,
        P_CD_CENTRO_EXPEDIDOR       IN VND.ELO_PRIORITY_PANEL.CD_CENTRO_EXPEDIDOR%TYPE
    );


/********************************************************************* 
    List all Priority Option along with Sequence
    
    AUTHOR: SACHIN
    
    P_RETORNO - List of all Priority Option with Sequence
/*********************************************************************/
PROCEDURE PX_PRIORITY (P_RETORNO OUT T_CURSOR);


/********************************************************************* 
    Delete PRIORITY OPTION AND SEQUENCE In PRIORITY_PANEL
    
    AUTHOR: SACHIN
    
    p_CD_ELO_PRIORITY_PANEL – Priority Panel Key   
/*********************************************************************/
PROCEDURE PD_PRIORITY (
    p_CD_ELO_PRIORITY_PANEL     IN VND.ELO_PRIORITY_PANEL.CD_ELO_PRIORITY_PANEL%TYPE);
                    
/********************************************************************* 
    Update Sequence or Priority Option
    
    AUTHOR: SACHIN
    
    p_PriorityOption – New Priority Option   
    p_NUOrder - New Sequence
    p_CD_ELO_PRIORITY_PANEL - Primary key
/*********************************************************************/                    
PROCEDURE PU_PRIORITY(
   -- p_PriorityOption IN ELO_PRIORITY_PANEL.CD_ELO_PRIORITY_OPTION%TYPE,
    p_NUOrder                   IN VND.ELO_PRIORITY_PANEL.NU_ORDER%TYPE,
    p_CD_ELO_PRIORITY_PANEL     IN ELO_PRIORITY_PANEL.CD_ELO_PRIORITY_PANEL%TYPE,
    P_CD_CENTRO_EXPEDIDOR       IN VND.ELO_PRIORITY_PANEL.CD_CENTRO_EXPEDIDOR%TYPE
);


/********************************************************************* 
    List all Priority Option FROM PRIORITY OPTION TABLE
    
    AUTHOR: SACHIN
    
    P_RETORNO - List of all Priority Option 
/*********************************************************************/
PROCEDURE PX_PRIORITY_PANEL (P_RETORNO OUT T_CURSOR);



END GX_ELO_PRIORITY_PANEL;
/