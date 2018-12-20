CREATE OR REPLACE PACKAGE VND."GX_ELO_PLANNING_VS_ACTUAL" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 


 TYPE T_CURSOR IS REF CURSOR;
  /********************************************************************* 
 IF CD_POLO IS FILLED and CD_CENTRO and CD_MACHINE is blank

  Get data from table CD_AGENDAMENTO_CENTRO 
  where DT_WEEK_START = DT_WEEK_START
      and CD_POLO = POLO(SELECTION-SCREEN)
******************************************************************************/


 PROCEDURE PX_GET_CENTRO(
        P_CD_POLO        in ELO_AGENDAMENTO_CENTRO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR
 )
 ;


 PROCEDURE PX_GET_AGENDAMENTO(
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,

       P_DT_WEEK_START   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR
 );
  /********************************************************************* 
  Data from “SEMPLAN” Process
  Get data from table CD_ELO_MARCACAO
    Where CD_POLO = POLO(Selection-Screen)
            or CD_CENTRO = JOIN CD_AGENDAMENTO_CENTRO-CD_CENTRO_EXPEDIDOR 
         and DT_WEEK_START = SEMANA(Selection-Screen)
         and SG_CLASSIFICACAO = ‘SEMPLAN’
         and IC_ATIVO = ‘S’
 ******************************************************************************/
/********************************************************************* 
PROCEDURE PX_GET_MARCACAO(
        P_CD_POLO         in ELO_AGENDAMENTO_CENTRO.CD_POLO%type,
         P_CD_CENTRO_EXPEDIDOR          in ELO_AGENDAMENTO_CENTRO.CD_CENTRO_EXPEDIDOR %type,
          P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR
);
 ******************************************************************************/
  /********************************************************************* 
  ELSE

  Get data from table ELO_AGENDAMENTO 
  Where CD_POLO = POLO(Selection-Screen IF NOT BLANK)
       and CD_CENTRO_EXPEDIDOR = CENTRO(Selection-Screen IF NOT BLANK)
       and CD_MACHINE = MÁQUINA(Selection-Screen IF NOT BLANK) 
       and DT_WEEK_START = SEMANA(Selection-Screen)
       and IC_ATIVO = ‘S’
******************************************************************************/
PROCEDURE PX_GET_ALL_AGENDAMENTO(
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_CENTRO_EXPEDIDOR    in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        P_CD_MACHINE      in ELO_AGENDAMENTO.CD_MACHINE%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR
 );
  /********************************************************************* 
 Get data from table ELO_AGENDAMENTO_SUPERVISOR
  Where   JOIN ELO_AGENDAMENTO-CD_ELO_AGENDAMENTO

******************************************************************************/

PROCEDURE PX_GET_AGENDAMENTO_SUPERVISOR(
      --  P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR
);


 /********************************************************************* 
Get data from table ELO_AGENDAMENTO_ITEM
  Where CD_ELO_AGENDAMENTO_SUPERVISOR JOIN 
	ELO_AGENDAMENTO_SUPERVISOR-CD_ELO_AGENDAMENTO_SUPERVISOR
      and IC_ATIVO = ‘S’


******************************************************************************/
PROCEDURE PX_GET_AGENDAMENTO_ITEM(
      --  P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR
);
/********************************************************************* 
Get data from table CD_ELO_CARTEIRA
  where CD_ELO_AGENDAMENTO_ITEM JOIN 
ELO_AGENDAMENTO_ITEM-CD_ELO_AGENDAMENTO_ITEM
  and IC_ATIVO = ‘S’
  and QT_AGENDADA_CONFIRMADA > 0
******************************************************************************/
PROCEDURE PX_GET_CARTEIRA(


       -- P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR


);
/********************************************************************* 
Get data from table CD_ELO_CARTEIRA_DAY
  where CD_ELO_CARTEIRA JOIN CD_ELO_CARTEIRA-CD_ELO_CARTEIRA 
  and IC_ATIVO = ‘S’

******************************************************************************/

PROCEDURE PX_GET_CARTEIRA_DAY(
       -- P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR


);

/********************************************************************* 
Get data from CD_CLIENTE
  where CD_CLIENTE JOIN CD_ELO_CARTEIRA where
  CD_CLIENTE = CD_ELO_CARTEIRA-CD_CLIENTE_PAGADOR or
  CD_CLIENTE = CD_ELO_CARTEIRA-CD_CLIENTE_RECEBEDOR


******************************************************************************/
PROCEDURE PX_GET_CLIENTE(
       -- P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR


);
PROCEDURE PX_GET_MARCACAO(
      -- P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR


);
PROCEDURE PX_GET_CLINTE_MARCACAO(
        -- P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        P_RETORNO         out T_CURSOR

);
/********************************************************************* 
Summarize the field CD_ELO_CARTEIRA_DAY-NU_QUANTIDADE with keys CD_TIPO_AGENDAMENTO, CD_CLIENTE, CD_INCOTERMS and CD_ELO_CARTEIRA_DAY-NU_DIA_SEMANA 
where CD_ELO_CARTEIRA JOIN CD_ELO_CARTEIRA-CD_ELO_CARTEIRA 
INTO A SUMMARIZED CD_ELO_CARTEIRA TABLE



******************************************************************************/
PROCEDURE PX_SUM_ELO_CARTEIRA_DAY (
        --P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR
);

PROCEDURE PX_SUM_ELO_MARCACAO (
      --  P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR
);

PROCEDURE PX_SUM_GET_CARTEIRA(
        P_CD_POLO           in VND.ELO_AGENDAMENTO.CD_POLO%type,
        P_CENTRO            IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MAQUINA           IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_CD_WEEK           in VND.ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO           out T_CURSOR
);
PROCEDURE PX_SUM_ALL_GET_CARTEIRA(

      P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_CENTRO_EXPEDIDOR    in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        P_CD_MACHINE      in ELO_AGENDAMENTO.CD_MACHINE%type,
        P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR



);
PROCEDURE PX_SUM_ALL_ELO_MARCACAO (
       P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_CENTRO_EXPEDIDOR    in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        P_CD_MACHINE      in ELO_AGENDAMENTO.CD_MACHINE%type,
        P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR
);
PROCEDURE PX_SUM_GET_SEMPLANMARCACO(
       P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
      P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,

      -- P_CD_INCOTERMS    in ELO_CARTEIRA.CD_INCOTERMS %TYPE,
        P_RETORNO         out T_CURSOR



);
PROCEDURE PX_SUM_GET_ALL_SEMPLANMARCACO(
         P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_CENTRO_EXPEDIDOR    in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        P_CD_MACHINE      in ELO_AGENDAMENTO.CD_MACHINE%type,
        P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR
 );

PROCEDURE PX_GET_Num_Cliente(
 P_RETORNO         out T_CURSOR
);
PROCEDURE PX_GET_NumCliente(
P_CD_CLIENTE   in ELO_CARTEIRA.CD_CLIENTE_PAGADOR%TYPE,
 P_RETORNO         out T_CURSOR
);




/********procedures related to 403***/


PROCEDURE PX_GET_ALL_REPORTDETAILS(
 P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
 P_CD_WEEK          in ELO_AGENDAMENTO.CD_WEEK%type,
 P_RETORNO         out T_CURSOR
 );


PROCEDURE PX_GET_CONTROLLERSHIP_MARCACAO(
P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
 P_CD_WEEK          in ELO_AGENDAMENTO.CD_WEEK%type,
 P_RETORNO         out T_CURSOR

);

PROCEDURE PX_GET_REASONPANELREPORT(
 P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
 P_CD_WEEK          in ELO_AGENDAMENTO.CD_WEEK%type,


 P_RETORNO         out T_CURSOR

);
PROCEDURE PX_GET_ALLREASONPANELREPORT(
        P_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        P_CD_CENTRO_EXPEDIDOR    in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        P_CD_MACHINE      in ELO_AGENDAMENTO.CD_MACHINE%type,
        P_CD_WEEK   in ELO_AGENDAMENTO.CD_WEEK%type,
        P_RETORNO         out T_CURSOR

);
PROCEDURE PX_GET_CONTROLLERSHIP_REASON(

 P_RETORNO         out T_CURSOR

);

  PROCEDURE PX_SUM_GET_CARTEIRA(
        P_CD_POLO           in VND.ELO_AGENDAMENTO.CD_POLO%type,
        P_CENTRO            IN VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MAQUINA           IN VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE,
        P_CD_WEEK           in VND.ELO_AGENDAMENTO.CD_WEEK%type,
        P_SUPERVISOR        IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
        P_RETORNO           out T_CURSOR
        );

END GX_ELO_PLANNING_VS_ACTUAL;
/