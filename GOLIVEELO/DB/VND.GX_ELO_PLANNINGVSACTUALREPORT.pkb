CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_PLANNINGVSACTUALREPORT" AS


 PROCEDURE GET_PLANNINGVSACTUALREPORT(
        P_CD_POLO        in ELO_AGENDAMENTO_CENTRO.CD_POLO%type,
        P_DT_WEEK_START   in ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%type,
       -- P_CD_CENTRO_EXPEDIDOR    in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        -- P_ELO_AGENDAMENTO in ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO%type,
         
       --  P_CD_MACHINE      in ELO_AGENDAMENTO.CD_MACHINE%type,
       P_RETORNO         out T_CURSOR
      -- P_RETORNO1         out T_CURSOR,
      -- P_RETORNO2         out T_CURSOR,
        --  P_RETORNO3         out T_CURSOR,
        --  P_RETORNO4         out T_CURSOR,
        --  P_RETORNO5         out T_CURSOR,
--P_RETORNO6         out T_CURSOR
 )
 IS
script varchar(4000);
  BEGIN 


--EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE Temp150
--ON COMMIT PRESERVE ROWS
--as select * from ELO_AGENDAMENTO';
EXECUTE IMMEDIATE 'INSERT INTO TempAgendamento (id) VALUES (select * from ELO_AGENDAMENTO)';
Open P_RETORNO for
select * from TempAgendamento;


commit;


END GET_PLANNINGVSACTUALREPORT;




END GX_ELO_PLANNINGVSACTUALREPORT;


/