CREATE OR REPLACE PACKAGE VND.GX_ELO_SCREEN AS 

    TYPE T_CURSOR IS REF CURSOR;




  PROCEDURE PU_SCREEN(
        P_NO_SCREEN                 IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
        P_DS_SCREEN                 IN VND.ELO_SCREEN.DS_SCREEN%TYPE,
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN(
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN(
        P_NO_SCREEN              IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
        P_RETORNO                    OUT T_CURSOR);
  PROCEDURE PX_GET_SCREEN_COLUMN(
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
		P_CD_ELO_SCREEN_COLUMN		 IN VND.ELO_SCREEN_COLUMN.CD_ELO_SCREEN_COLUMN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_COLUMN(
		P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
        P_NO_SCREEN              	IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
		P_NO_COLUMN		 			IN VND.ELO_SCREEN_COLUMN.NO_COLUMN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_COLUMN(
		P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
        P_NO_SCREEN              	IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_COLUMN(
        P_RETORNO                    OUT T_CURSOR);


  PROCEDURE PX_GET_SCREEN(
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT(
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_NO_SCREEN_LAYOUT			 IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT(
        P_NO_SCREEN              IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_NO_SCREEN_LAYOUT			 IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,		
        P_RETORNO                    OUT T_CURSOR);


   PROCEDURE PX_GET_SCREEN_LAYOUT(
        P_NO_SCREEN              IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT(
 		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT(
        P_RETORNO                    OUT T_CURSOR);


  PROCEDURE PX_GET_SCREEN_LAYOUT_COLUMN(
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_NO_SCREEN_LAYOUT			 IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,		
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT_COLUMN(
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_NO_SCREEN_LAYOUT			 IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,
		P_NO_COLUMN					 IN VND.ELO_SCREEN_LAYOUT_COLUMN.NO_COLUMN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT_COLUMN(
        P_NO_SCREEN              IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_NO_SCREEN_LAYOUT			 IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,		
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT_COLUMN(
 		P_CD_USUARIO				 IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PX_GET_SCREEN_LAYOUT_COLUMN(
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PU_SCREEN_LAYOUT(

		P_CD_ELO_SCREEN_LAYOUT	IN VND.ELO_SCREEN_LAYOUT.CD_ELO_SCREEN_LAYOUT%TYPE,
		P_NO_SCREEN             IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
		P_CD_ELO_SCREEN			IN VND.ELO_SCREEN_LAYOUT.CD_ELO_SCREEN%TYPE,
		P_NO_SCREEN_LAYOUT      IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,
		P_CD_USUARIO			IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_IC_VISIBLE			IN VND.ELO_SCREEN_LAYOUT.IC_VISIBLE%TYPE,
		P_IC_ATIVO				IN VND.ELO_SCREEN_LAYOUT.IC_ATIVO%TYPE,	

        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PU_SCREEN_LAYOUT_COLUMN(

		P_CD_ELO_SCREEN_LAYOUT_COLUMN IN VND.ELO_SCREEN_LAYOUT_COLUMN.CD_ELO_SCREEN_LAYOUT_COLUMN%TYPE,
		P_CD_ELO_SCREEN_COLUMN   IN VND.ELO_SCREEN_LAYOUT_COLUMN.CD_ELO_SCREEN_COLUMN%TYPE,
		P_CD_ELO_SCREEN_LAYOUT	IN VND.ELO_SCREEN_LAYOUT.CD_ELO_SCREEN_LAYOUT%TYPE,
		P_NO_SCREEN             IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
		P_CD_ELO_SCREEN			IN VND.ELO_SCREEN_LAYOUT.CD_ELO_SCREEN%TYPE,
		P_NO_SCREEN_LAYOUT      IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,
		P_CD_USUARIO			IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
		P_NO_COLUMN				IN VND.ELO_SCREEN_LAYOUT_COLUMN.NO_COLUMN%TYPE,
		P_NU_ORDER 				IN VND.ELO_SCREEN_LAYOUT_COLUMN.NU_ORDER%TYPE,
		P_IC_VISIBLE			IN VND.ELO_SCREEN_LAYOUT_COLUMN.IC_VISIBLE%TYPE,
		P_IC_ATIVO				IN VND.ELO_SCREEN_LAYOUT_COLUMN.IC_ATIVO%TYPE,	

        P_RETORNO                    OUT T_CURSOR);

   PROCEDURE PU_SCREEN_COLUMN(
        P_NO_SCREEN                 IN VND.ELO_SCREEN.NO_SCREEN%TYPE,
        P_CD_ELO_SCREEN              IN VND.ELO_SCREEN.CD_ELO_SCREEN%TYPE,
		P_CD_ELO_SCREEN_COLUMN		IN VND.ELO_SCREEN_COLUMN.CD_ELO_SCREEN_COLUMN%TYPE,
		P_NO_COLUMN					IN VND.ELO_SCREEN_COLUMN.NO_COLUMN%TYPE,
		P_NU_ORDER					IN VND.ELO_SCREEN_COLUMN.NU_ORDER%TYPE,
		P_IC_MANDATORY				IN VND.ELO_SCREEN_COLUMN.IC_MANDATORY%TYPE,
        P_NO_ALIAS_COLUMN           IN VND.ELO_SCREEN_COLUMN.NO_ALIAS_COLUMN%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PI_CROSS_SCREEN_LAYOUT(

		P_CD_ELO_SCREEN			IN VND.ELO_SCREEN_LAYOUT.CD_ELO_SCREEN%TYPE,
		P_NO_SCREEN_LAYOUT		IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,
		P_CD_USUARIO			IN VND.ELO_SCREEN_LAYOUT.CD_USUARIO%TYPE,
        P_RETORNO                    OUT T_CURSOR);

  PROCEDURE PU_NO_SCREEN_LAYOUT(

		P_CD_ELO_SCREEN_LAYOUT	IN VND.ELO_SCREEN_LAYOUT.CD_ELO_SCREEN_LAYOUT%TYPE,
		P_NO_SCREEN_LAYOUT      IN VND.ELO_SCREEN_LAYOUT.NO_SCREEN_LAYOUT%TYPE,

        P_RETORNO                    OUT T_CURSOR);

END GX_ELO_SCREEN;
/