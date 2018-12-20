CREATE OR REPLACE PACKAGE VND.GX_ELO_MENSAL_PAGINA AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  
TYPE T_CURSOR IS REF CURSOR;
 

PROCEDURE PX_GET_CENTROS (
        P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_CENTRO_FROM_MAQUINA (
                                        P_CD_MACHINE VARCHAR2,
                                        P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MAQUINAS (
         P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MAQUINAS_FROM_CENTRO (
        P_CD_CENTRO_EXPEDIDOR VARCHAR2,
        P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_SEMANAS (
         P_RETORNO     OUT T_CURSOR
    );

PROCEDURE PX_GET_POLOS (
         P_RETORNO     OUT T_CURSOR
    );

 PROCEDURE PX_GET_BLOCO_SEMANAS( 	P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_CD_WEEK_LIST VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    );
    
PROCEDURE PX_GET_MENSAL_LINHAS (   P_CD_CENTRO_EXPEDIDOR VARCHAR2,
                                    P_CD_MACHINE VARCHAR2,
                                    P_DT_DE DATE,
                                    P_DT_ATE DATE,
                                    P_LINHA_TO_EXEC VARCHAR2,
                                    P_RETORNO     OUT T_CURSOR
    );


END GX_ELO_MENSAL_PAGINA;
/