CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_AGENDAMENTO_REPORTS" AS

  FUNCTION FX_RELACIONAMENTO (
        P_CD_ELO_CARTEIRA    IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE
    ) RETURN NUMBER
    IS
        V_RESULT NUMBER;
    BEGIN

        select aw.QT_SEMANA
          into V_RESULT
          from VND.ELO_CARTEIRA ec
         inner join VND.ELO_AGENDAMENTO_ITEM ai
            on ec.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
         inner join VND.ELO_AGENDAMENTO_WEEK aw
            on aw.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
         where ec.IC_RELACIONAMENTO = 'S'
           and ec.CD_ELO_CARTEIRA = P_CD_ELO_CARTEIRA;

        RETURN V_RESULT;

    END FX_RELACIONAMENTO;
    
  FUNCTION FX_RESERVADO (
        P_CD_ELO_CARTEIRA    IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE
    ) RETURN NUMBER
    IS
        V_RESULT NUMBER;
    BEGIN

        select sum(ec.QT_AGENDADA_CONFIRMADA)
          into V_RESULT
          from VND.ELO_CARTEIRA ec
         inner join VND.ELO_AGENDAMENTO ag
            on ec.CD_ELO_AGENDAMENTO = ag.CD_ELO_AGENDAMENTO
         where ag.CD_ELO_STATUS > 4
           and ec.CD_ELO_CARTEIRA = P_CD_ELO_CARTEIRA;

        RETURN V_RESULT;

    END FX_RESERVADO;
    
  FUNCTION FX_PROGRAMADO (
        P_CD_ELO_CARTEIRA    IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE
    ) RETURN NUMBER
    IS
        V_RESULT NUMBER;
    BEGIN

        select sum(ec.QT_AGENDADA_CONFIRMADA)
          into V_RESULT
          from VND.ELO_CARTEIRA ec
         inner join VND.ELO_AGENDAMENTO ag
            on ec.CD_ELO_AGENDAMENTO = ag.CD_ELO_AGENDAMENTO
         where ag.CD_ELO_STATUS > 5
           and ec.CD_ELO_CARTEIRA = P_CD_ELO_CARTEIRA;

        RETURN V_RESULT;

    END FX_PROGRAMADO;

  PROCEDURE PX_GET_SUPERVISORES (
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
    P_RETORNO       OUT T_CURSOR
  )
  
  IS
  BEGIN

  OPEN P_RETORNO FOR
    select distinct
           u.CD_USUARIO                  as Code,
           sup.CD_SALES_GROUP            as CodeSupervisor,
           u.NO_USUARIO                  as DescriptionSupervisor
      from VND.ELO_AGENDAMENTO_SUPERVISOR sup
     inner join VND.ELO_AGENDAMENTO ag
        on ag.CD_ELO_AGENDAMENTO = sup.CD_ELO_AGENDAMENTO
     inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP
     where ag.IC_ATIVO = 'S'
       --and u.IC_ATIVO = 'S'
       and (P_CENTRO is null OR AG.CD_CENTRO_EXPEDIDOR = P_CENTRO)
  order by u.NO_USUARIO;

  END PX_GET_SUPERVISORES;

  PROCEDURE PX_GET_GERENTES (
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
    P_RETORNO       OUT T_CURSOR
  )

  IS
  BEGIN

  OPEN P_RETORNO FOR
    select distinct
           u.CD_USUARIO                  as Code,
           sup.CD_SALES_OFFICE           as CodeGerente,
           u.NO_USUARIO                  as DescriptionGerente
      from VND.ELO_AGENDAMENTO_SUPERVISOR sup
     inner join VND.ELO_AGENDAMENTO ag
        on ag.CD_ELO_AGENDAMENTO = sup.CD_ELO_AGENDAMENTO
     inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_OFFICE
     where ag.IC_ATIVO = 'S'
       --and u.IC_ATIVO = 'S'
       and (P_CENTRO is null OR AG.CD_CENTRO_EXPEDIDOR = P_CENTRO)
  order by u.NO_USUARIO;

  END PX_GET_GERENTES;

  PROCEDURE PX_GET_FINAL_VIEW(
    P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
    P_CENTRO                IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA               IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_WEEK                  IN VARCHAR2,
    P_SUPERVISOR            IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_GERENTE               IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE,
    P_PRINCIPAL             OUT T_CURSOR,
    P_GERENCIA              OUT T_CURSOR,
    P_CHART_VOLUME          OUT T_CURSOR,
    P_CHART_EMBALAGEM       OUT T_CURSOR,
    P_CHART_EMBALAGEM_DIA   OUT T_CURSOR,
    P_CHART_CLIENTE         OUT T_CURSOR,
    P_CHART_CENTRO          OUT T_CURSOR,
    P_CHART_FAMILIA         OUT T_CURSOR
  )

  IS
  BEGIN
  
  

    OPEN P_PRINCIPAL FOR
   WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         LEFT JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_POLO  = 'P001' AND ag.CD_WEEK = 'W292018' and CD_SALES_GROUP = '730'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'
         -- and aw.qt_semana > 0 
           
    ) ,
   -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, c.CD_CENTRO_EXPEDIDOR,
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE ,
(select sum(qt_semana) qt_semana from semana dd where dd.cd_elo_agendamento = semaext.cd_elo_agendamento 
and dd.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM) qt_semana

from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

WHERE 
 C.ic_ativo = 'S'
-- and c.qt_agendada_confirmada > 0 
),
--select * from cte_carteira order by cd_elo_agendamento_item, cd_produto_sap, no_cliente


cte_resumo AS (

select  
CD_CENTRO_EXPEDIDOR,
Supervisor,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(ReservadoPorcentagem) ReservadoPorcentagem,
SUM(Reservado) Reservado,
SUM(ProgramadoPorcentagem) ProgramadoPorcentagem,
MotivoNaoProgramado,
SUM(Liberado) Liberado
FROM 
(
   
        select 
                ec.CD_CENTRO_EXPEDIDOR,
               agesem.Supervisor                                                        as Supervisor,
               ec.NO_CLIENTE                                                            as NomeCliente,
               ec.CD_CLIENTE                                                            as NumeroCliente,
               ec.CD_INCOTERMS                                                          as Incoterms,
               ps.NO_PRODUTO_SAP                                                        as Material,
               agesem.QT_SEMANA                                                    as Sugerido,
                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.cd_elo_agendamento = ec.cd_elo_agendamento
                 and c.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
                 and c.cd_centro_expedidor = ec.cd_centro_expedidor
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.cd_elo_agendamento = ec.cd_elo_agendamento
                 and c.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
                 and c.cd_centro_expedidor = ec.cd_centro_expedidor
                   and c.SG_STATUS IN ( 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,
              1 as ReservadoPorcentagem,
                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.cd_elo_agendamento = ec.cd_elo_agendamento
                                 and c.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
                                 and c.cd_centro_expedidor = ec.cd_centro_expedidor
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado,
               1 as ProgramadoPorcentagem,
               'Sem ordem liberada'                                                     as MotivoNaoProgramado
          from semana agesem
          left join (
          select CC.CD_CENTRO_EXPEDIDOR, CC.NO_CLIENTE, CC.CD_CLIENTE, CC.CD_INCOTERMS, CC.CD_PRODUTO_SAP, CD_ELO_AGENDAMENTO, CD_ELO_AGENDAMENTO_ITEM
          FROM cte_carteira CC
          WHERE QT_AGENDADA_CONFIRMADA >= 0 
          ) ec
         ON 
          ec.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO
          AND ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
            
          left join CTF.PRODUTO_RAW_MATERIAL_GROUP mg
            on mg.CD_PRODUTO_SAP = ec.CD_PRODUTO_SAP
          left join CTF.PRODUTO_SAP ps
            on ec.CD_PRODUTO_SAP = ps.CD_PRODUTO_SAP
      -- where 
      --   ec.CD_CLIENTE = agesem.CD_CLIENTE


      group by ec.CD_CENTRO_EXPEDIDOR,
                agesem.Supervisor,
               --ec.CD_ELO_CARTEIRA,
               ec.NO_CLIENTE,
               ec.CD_CLIENTE,
               ec.CD_INCOTERMS,
               ps.NO_PRODUTO_SAP,
               agesem.qt_semana,
               agesem.QT_BLOQUEADA,
               ec.cd_elo_agendamento,
               ec.cd_elo_agendamento_item
)
GROUP BY 
CD_CENTRO_EXPEDIDOR,
Supervisor,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
MotivoNaoProgramado

)

select 
CD_CENTRO_EXPEDIDOR,
Supervisor,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
Sugerido,
Programado,
case when Sugerido > 0 then  TRUNC(((Reservado / Sugerido) * 100), 2) else 0 end ReservadoPorcentagem,
Reservado,
case when Sugerido > 0 then TRUNC(((Programado / Sugerido) * 100), 2) else 0 end ProgramadoPorcentagem,
CASE 
WHEN Sugerido = Programado THEN ' '
WHEN Sugerido > Programado THEN 'Sem ordem liberado' 
WHEN Programado = Liberado THEN 'Programado apenas o que havia liberado' 
WHEN Programado > Sugerido THEN 'Intervenção manual' 
WHEN NVL(Programado,0) = 0 THEN 'Falta Capacidade' 
ELSE '-'
END  MotivoNaoProgramado,
Liberado
from cte_resumo
where (Programado >= 0 or Sugerido > 0) AND CD_CENTRO_EXPEDIDOR IS NOT NULL;

               
           
    OPEN P_GERENCIA FOR

   WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_OFFICE || '-' || u.NO_USUARIO  as Gerente,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_OFFICE,
                it.CD_CLIENTE,
                ag.cd_elo_status
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         LEFT JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_OFFICE   
            
         WHERE --ag.CD_POLO  = 'P001' AND ag.CD_WEEK = 'W292018' and CD_SALES_GROUP = '730'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'
         -- and aw.qt_semana > 0 
           
    ) ,
   -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_OFFICE, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, c.CD_CENTRO_EXPEDIDOR,
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE ,
(select sum(qt_semana) qt_semana from semana dd where dd.cd_elo_agendamento = semaext.cd_elo_agendamento 
and dd.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM) qt_semana

from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_OFFICE  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_OFFICE = semaext.CD_SALES_OFFICE
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

WHERE 
 C.ic_ativo = 'S'
-- and c.qt_agendada_confirmada > 0 
),
--select * from cte_carteira order by cd_elo_agendamento_item, cd_produto_sap, no_cliente


cte_resumo AS (

select  
CD_CENTRO_EXPEDIDOR,
Gerente,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(ReservadoPorcentagem) ReservadoPorcentagem,
SUM(Reservado) Reservado,
SUM(ProgramadoPorcentagem) ProgramadoPorcentagem,
MotivoNaoProgramado,
SUM(Liberado) Liberado
FROM 
(
   
        select 
                ec.CD_CENTRO_EXPEDIDOR,
               agesem.Gerente                                                        as Gerente,
               ec.NO_CLIENTE                                                            as NomeCliente,
               ec.CD_CLIENTE                                                            as NumeroCliente,
               ec.CD_INCOTERMS                                                          as Incoterms,
               ps.NO_PRODUTO_SAP                                                        as Material,
               agesem.QT_SEMANA                                                    as Sugerido,
                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.cd_elo_agendamento = ec.cd_elo_agendamento
                 and c.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
                 and c.cd_centro_expedidor = ec.cd_centro_expedidor
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.cd_elo_agendamento = ec.cd_elo_agendamento
                 and c.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
                 and c.cd_centro_expedidor = ec.cd_centro_expedidor
                   and c.SG_STATUS IN ( 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,
              1 as ReservadoPorcentagem,
                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.cd_elo_agendamento = ec.cd_elo_agendamento
                                 and c.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
                                 and c.cd_centro_expedidor = ec.cd_centro_expedidor
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado,
               1 as ProgramadoPorcentagem,
               'Sem ordem liberada'                                                     as MotivoNaoProgramado
          from semana agesem
          left join (
          select CC.CD_CENTRO_EXPEDIDOR, CC.NO_CLIENTE, CC.CD_CLIENTE, CC.CD_INCOTERMS, CC.CD_PRODUTO_SAP, CD_ELO_AGENDAMENTO, CD_ELO_AGENDAMENTO_ITEM
          FROM cte_carteira CC
          WHERE QT_AGENDADA_CONFIRMADA >= 0 
          ) ec
         ON 
          ec.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO
          AND ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
            
          left join CTF.PRODUTO_RAW_MATERIAL_GROUP mg
            on mg.CD_PRODUTO_SAP = ec.CD_PRODUTO_SAP
          left join CTF.PRODUTO_SAP ps
            on ec.CD_PRODUTO_SAP = ps.CD_PRODUTO_SAP
      -- where 
      --   ec.CD_CLIENTE = agesem.CD_CLIENTE


      group by ec.CD_CENTRO_EXPEDIDOR,
                agesem.Gerente,
               --ec.CD_ELO_CARTEIRA,
               ec.NO_CLIENTE,
               ec.CD_CLIENTE,
               ec.CD_INCOTERMS,
               ps.NO_PRODUTO_SAP,
               agesem.qt_semana,
               agesem.QT_BLOQUEADA,
               ec.cd_elo_agendamento,
               ec.cd_elo_agendamento_item
)
GROUP BY 
CD_CENTRO_EXPEDIDOR,
Gerente,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
MotivoNaoProgramado

)

select 
CD_CENTRO_EXPEDIDOR,
Gerente,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
NVL(Sugerido,0) Sugerido,
NVL(Programado, 0 )Programado,
case when Sugerido > 0 then  TRUNC(((Reservado / Sugerido) * 100), 2) else 0 end ReservadoPorcentagem,
NVL(Reservado,0) Reservado,
case when Sugerido > 0 then TRUNC(((Programado / Sugerido) * 100), 2) else 0 end ProgramadoPorcentagem,
CASE 
WHEN Sugerido = Programado THEN ' '
WHEN Sugerido > Programado THEN 'Sem ordem liberado' 
WHEN Programado = Liberado THEN 'Programado apenas o que havia liberado' 
WHEN Programado > Sugerido THEN 'Intervenção manual' 
WHEN NVL(Programado,0) = 0 THEN 'Falta Capacidade' 
ELSE '-'
END  MotivoNaoProgramado,
NVL(Liberado,0) Liberado
from cte_resumo
where (Programado >= 0 or Sugerido > 0) AND CD_CENTRO_EXPEDIDOR IS NOT NULL ;



--select 
--CD_CENTRO_EXPEDIDOR,
--Gerente,
--NomeCliente,
--NumeroCliente,
--Incoterms,
--Material,
--sum(Sugerido) Sugerido,
--sum(Programado) Programado,
--case when sum(Sugerido) > 0 then  TRUNC(((sum(Reservado) / sum(Sugerido)) * 100), 2) else 0 end ReservadoPorcentagem,
--sum(Reservado) Reservado,
--case when sum(Sugerido) > 0 then TRUNC(((sum(Programado) / sum(Sugerido)) * 100), 2) else 0 end ProgramadoPorcentagem,
--MotivoNaoProgramado,
--sum(Liberado) Liberado
--from cte_resumo
--where (Programado) > 0 or (Sugerido) > 0
--GROUP BY
--CD_CENTRO_EXPEDIDOR,
--Gerente,
--NomeCliente,
--NumeroCliente,
--Incoterms,
--Material,
--MotivoNaoProgramado

--;

 
           
    OPEN P_CHART_VOLUME FOR
    WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         LEFT JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_POLO  = 'P002' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'

           
    ) ,
   -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, c.cd_status_cel_final,
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE, 
NVL(C.IC_CORTADO_FABRICA, '0') IC_CORTADO 
from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

WHERE 
 C.ic_ativo = 'S'
),


cte_resumo AS (

select  
--Supervisor,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(ReservadoPorcentagem) ReservadoPorcentagem,
SUM(Reservado) Reservado,
SUM(ProgramadoPorcentagem) ProgramadoPorcentagem,
MotivoNaoProgramado,
SUM(Liberado) Liberado,
sum(SemProtocolo) SemProtocolo,
sum(SemOrdem) SemOrdem

FROM 
(
   
        select 
               --agesem.Supervisor                                                        as Supervisor,
               ec.NO_CLIENTE                                                            as NomeCliente,
               ec.CD_CLIENTE                                                            as NumeroCliente,
               ec.CD_INCOTERMS                                                          as Incoterms,
               ps.NO_PRODUTO_SAP                                                        as Material,
              (SELECT Sum(ATD.QT_SEMANA) FROM  semana ATD 
               WHERE ATD.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO 
               AND  ATD.CD_ELO_AGENDAMENTO_ITEM =agesem.CD_ELO_AGENDAMENTO_ITEM)        as Sugerido,
               max(agesem.QT_SEMANA) -   max(agesem.QT_BLOQUEADA)                                       as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO AND c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,
              1 as ReservadoPorcentagem,
                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO and c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado,
               1 as ProgramadoPorcentagem,
               'Sem ordem liberada'                                                     as MotivoNaoProgramado, 
               (select sum(stcell.QT_PROGRAMADA) 
                         from cte_carteira stcell 
                                    WHERE agesem.CD_ELO_AGENDAMENTO = stcell.CD_ELO_AGENDAMENTO and agesem.CD_ELO_AGENDAMENTO_ITEM = stcell.CD_ELO_AGENDAMENTO_ITEM
                                    AND stcell.IC_CORTADO IN ('1', 'S')
                                 
                                ) SemProtocolo,
               
               (select sum(stcell.QT_PROGRAMADA) 
                         from cte_carteira stcell 
                                    WHERE agesem.CD_ELO_AGENDAMENTO = stcell.CD_ELO_AGENDAMENTO and agesem.CD_ELO_AGENDAMENTO_ITEM = stcell.CD_ELO_AGENDAMENTO_ITEM
                                    AND NVL(stcell.CD_STATUS_CEL_FINAL, 99999)  not in ( 57, 59, 99999)
                                 
                                ) SemOrdem
          from semana agesem
          INNER join 
          (
          SELECT distinct ict.CD_ELO_AGENDAMENTO, ict.CD_ELO_AGENDAMENTO_ITEM, ict.NO_CLIENTE, ict.CD_CLIENTE, ict.CD_INCOTERMS, ict.CD_PRODUTO_SAP 
          FROM cte_carteira ict
          ) ec
          on agesem.cd_elo_agendamento = ec.cd_elo_agendamento 
          AND agesem.cd_elo_agendamento_item = ec.cd_elo_agendamento_item
          inner join CTF.PRODUTO_RAW_MATERIAL_GROUP mg
            on mg.CD_PRODUTO_SAP = ec.CD_PRODUTO_SAP
          inner join CTF.PRODUTO_SAP ps
            on ec.CD_PRODUTO_SAP = ps.CD_PRODUTO_SAP
       where 
         ec.CD_CLIENTE = agesem.CD_CLIENTE


      group by --agesem.Supervisor,
               --ec.CD_ELO_CARTEIRA,
                agesem.CD_ELO_AGENDAMENTO ,
               agesem.CD_ELO_AGENDAMENTO_ITEM,
               ec.NO_CLIENTE,
               ec.CD_CLIENTE,
               ec.CD_INCOTERMS,
               ps.NO_PRODUTO_SAP
)
GROUP BY 

--Supervisor,
NomeCliente,
NumeroCliente,
Incoterms,
Material,
MotivoNaoProgramado

)

select 
--Supervisor,
--NomeCliente,
--NumeroCliente,
--Incoterms,
--Material,
sum(NVL(Sugerido,0)) Sugerido,
sum(NVL(SemProtocolo,0)) SemCapacidade,
sum(NVL(Reservado,0))  Reservado,
sum(NVL( SemOrdem,0)) SemOrdem, 
sum(NVL(Programado,0))  Programado,
CASE WHEN max(Sugerido) > 0 THEN sum(NVL(Sugerido,0)) - sum(NVL(Programado,0)) - sum(NVL(SemOrdem,0)) - sum(NVL(SemProtocolo,0)) ELSE 0 END SemProtocolo,
--CASE WHEN max(Sugerido) > 0 THEN sum(Sugerido) - sum(Programado) - sum(SemOrdem) - sum(SemProtocolo) ELSE 0 END
Sum(NVL(Reservado,0)) Carregavel
from cte_resumo
where Programado > 0 or Sugerido > 0

;    
    

          
    OPEN P_CHART_EMBALAGEM FOR
    WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status,
                ad.CD_GRUPO_EMBALAGEM,
                ge.DS_GRUPO_EMBALAGEM               
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         inner JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        inner join VND.ELO_AGENDAMENTO_DAY ad
          on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK   
        inner join VND.GRUPO_EMBALAGEM ge
        on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM  

            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_CENTRO_EXPEDIDOR  = '6120' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'

           
    ) ,
  -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE ,
C.CD_STATUS_CEL_FINAL
from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

WHERE 
 C.ic_ativo = 'S'
),

--select * from cte_carteira
cte_resumo AS (

select  
DS_GRUPO_EMBALAGEM,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(Reservado) Reservado,

SUM(Liberado) Liberado,
sum(SemOrdem) SemOrdem

FROM 
(
   
        select 
              agesem.DS_GRUPO_EMBALAGEM,
              (SELECT Sum(ATD.QT_SEMANA) FROM  semana ATD 
               WHERE ATD.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO 
               AND  ATD.CD_ELO_AGENDAMENTO_ITEM =agesem.CD_ELO_AGENDAMENTO_ITEM)        as Sugerido,
               max(agesem.QT_SEMANA) -   max(agesem.QT_BLOQUEADA)                                       as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO AND c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,

                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO and c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado,
                               (select sum(stcell.QT_PROGRAMADA) 
                         from cte_carteira stcell 
                                    WHERE agesem.CD_ELO_AGENDAMENTO = stcell.CD_ELO_AGENDAMENTO and agesem.CD_ELO_AGENDAMENTO_ITEM = stcell.CD_ELO_AGENDAMENTO_ITEM
                                    AND NVL(stcell.CD_STATUS_CEL_FINAL, 99999)  not in ( 57, 59, 99999)
                                 
                                )   SemOrdem                
                                   
 
          from semana agesem
          INNER join 
          (
          SELECT distinct ict.CD_ELO_AGENDAMENTO, ict.CD_ELO_AGENDAMENTO_ITEM 
          FROM cte_carteira ict
          ) ec
          on agesem.cd_elo_agendamento = ec.cd_elo_agendamento 
          AND agesem.cd_elo_agendamento_item = ec.cd_elo_agendamento_item

       where 
         ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM


      group by agesem.DS_GRUPO_EMBALAGEM,
                agesem.CD_ELO_AGENDAMENTO ,
               agesem.CD_ELO_AGENDAMENTO_ITEM

)
GROUP BY 

DS_GRUPO_EMBALAGEM

)

--SELECT * FROM cte_resumo

select 
DS_GRUPO_EMBALAGEM Embalagem,
SUM(NVL(Programado,0)) Programado,
SUM(NVL(SemOrdem,0)) SemOrdem,
SUM(NVL(Programado,0)) Total

from cte_resumo
where Programado > 0 or Sugerido > 0 
GROUP BY DS_GRUPO_EMBALAGEM
;
 
        
    OPEN P_CHART_EMBALAGEM_DIA FOR
    WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status,
                ad.CD_GRUPO_EMBALAGEM,
                ge.DS_GRUPO_EMBALAGEM ,
                ad.NU_DIA_SEMANA, 
                NVL(ad.NU_QUANTIDADE, 0) NU_QUANTIDADE
                
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         inner JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        inner join VND.ELO_AGENDAMENTO_DAY ad
          on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK   
        inner join VND.GRUPO_EMBALAGEM ge
        on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM  

            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_CENTRO_EXPEDIDOR  = '6120' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'

           
    ) ,
  -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE 

from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

WHERE 
 C.ic_ativo = 'S'
),

--select * from cte_carteira
cte_resumo AS (

select  
DS_GRUPO_EMBALAGEM,
NU_DIA_SEMANA,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(Reservado) Reservado,
SUM(NU_QUANTIDADE) NU_QUANTIDADE,
SUM(Liberado) Liberado
FROM 
(
   
        select 
              agesem.DS_GRUPO_EMBALAGEM,
              agesem.NU_DIA_SEMANA,
              SUM(agesem.NU_QUANTIDADE) NU_QUANTIDADE,
              (SELECT Sum(ATD.QT_SEMANA) FROM  semana ATD 
               WHERE ATD.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO 
               AND  ATD.CD_ELO_AGENDAMENTO_ITEM =agesem.CD_ELO_AGENDAMENTO_ITEM)        as Sugerido,
               max(agesem.QT_SEMANA) -   max(agesem.QT_BLOQUEADA)                                       as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO AND c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,

                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO and c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado
 
          from semana agesem
          INNER join 
          (
          SELECT distinct ict.CD_ELO_AGENDAMENTO, ict.CD_ELO_AGENDAMENTO_ITEM 
          FROM cte_carteira ict
          ) ec
          on agesem.cd_elo_agendamento = ec.cd_elo_agendamento 
          AND agesem.cd_elo_agendamento_item = ec.cd_elo_agendamento_item

       where 
         ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM


      group by agesem.DS_GRUPO_EMBALAGEM,
                agesem.NU_DIA_SEMANA,
                agesem.CD_ELO_AGENDAMENTO ,
               agesem.CD_ELO_AGENDAMENTO_ITEM

)
GROUP BY 

DS_GRUPO_EMBALAGEM,
NU_DIA_SEMANA

)

--SELECT * FROM cte_resumo

select 
DS_GRUPO_EMBALAGEM Embalagem,
ROUND(SUM(NVL(SEG,0)),0) SEG,
ROUND(SUM(NVL(TER,0)),0) TER,
ROUND(SUM(NVL(QUA,0)),0) QUA,
ROUND(SUM(NVL(QUI,0)),0) QUI,
ROUND(SUM(NVL(SEX,0)),0) SEX,
ROUND(SUM(NVL(SAB,0)),0) SAB,
ROUND(SUM(NVL(DOM,0)),0) DOM
from cte_resumo

PIVOT(SUM(NVL(NU_QUANTIDADE,0))
FOR NU_DIA_SEMANA in ('1' Seg, '2' Ter, '3' Qua, '4' Qui, '5' Sex, '6' Sab, '7' Dom))
GROUP BY DS_GRUPO_EMBALAGEM
;


              
    OPEN P_CHART_CLIENTE FOR
      WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status,
                ad.CD_GRUPO_EMBALAGEM,
                ge.DS_GRUPO_EMBALAGEM               
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         inner JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        inner join VND.ELO_AGENDAMENTO_DAY ad
          on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK   
        inner join VND.GRUPO_EMBALAGEM ge
        on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM  

            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_CENTRO_EXPEDIDOR  = '6120' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'

           
    ) ,
  -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE ,
C.CD_STATUS_CEL_FINAL

from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

WHERE 
 C.ic_ativo = 'S'
 AND c.IC_RELACIONAMENTO = 'S'
),

--select * from cte_carteira
cte_resumo AS (

select  
NO_CLIENTE,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(Reservado) Reservado,
sum(SemOrdem) SemOrdem,

SUM(Liberado) Liberado
FROM 
(
   
        select 
              ec.NO_CLIENTE,
              (SELECT Sum(ATD.QT_SEMANA) FROM  semana ATD 
               WHERE ATD.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO 
               AND  ATD.CD_ELO_AGENDAMENTO_ITEM =agesem.CD_ELO_AGENDAMENTO_ITEM)        as Sugerido,
               max(agesem.QT_SEMANA) -   max(agesem.QT_BLOQUEADA)                                       as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO AND c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,

                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO and c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado,
                                (select sum(stcell.QT_PROGRAMADA) 
                         from cte_carteira stcell 
                                    WHERE agesem.CD_ELO_AGENDAMENTO = stcell.CD_ELO_AGENDAMENTO and agesem.CD_ELO_AGENDAMENTO_ITEM = stcell.CD_ELO_AGENDAMENTO_ITEM
                                    AND NVL(stcell.CD_STATUS_CEL_FINAL, 99999)  not in ( 57, 59, 99999)
                                 
                                )   SemOrdem                                    
                                   
 
          from semana agesem
          INNER join 
          (
          SELECT distinct ict.CD_ELO_AGENDAMENTO, ict.CD_ELO_AGENDAMENTO_ITEM , ict.NO_CLIENTE
          FROM cte_carteira ict
          ) ec
          on agesem.cd_elo_agendamento = ec.cd_elo_agendamento 
          AND agesem.cd_elo_agendamento_item = ec.cd_elo_agendamento_item

       where 
         ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM


      group by ec.NO_CLIENTE,
                agesem.CD_ELO_AGENDAMENTO ,
               agesem.CD_ELO_AGENDAMENTO_ITEM

)
GROUP BY 

NO_CLIENTE

)

--SELECT * FROM cte_resumo

select 
NO_CLIENTE "name",
SUM(NVL(Programado,0)) Programado,
SUM(NVL(SemOrdem,0)) SemOrdem,
SUM(NVL(Programado,0)) Total

from cte_resumo
where Programado > 0 or Sugerido > 0
GROUP BY NO_CLIENTE
;
        
    OPEN P_CHART_CENTRO FOR
 
           WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status,
                ad.CD_GRUPO_EMBALAGEM,
                ge.DS_GRUPO_EMBALAGEM ,
                ad.NU_DIA_SEMANA, 
                NVL(ad.NU_QUANTIDADE, 0) NU_QUANTIDADE
                
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         inner JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        inner join VND.ELO_AGENDAMENTO_DAY ad
          on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK   
        inner join VND.GRUPO_EMBALAGEM ge
        on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM  

            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_CENTRO_EXPEDIDOR  = '6120' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'

           
    ) ,
  -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE , 
NVL(ce.DS_COLOR, '#b21515')        as color, 
ce.CD_CENTRO_EXPEDIDOR,
ce.DS_CENTRO_EXPEDIDOR

from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

inner join CTF.CENTRO_EXPEDIDOR ce
on c.CD_CENTRO_EXPEDIDOR = ce.CD_CENTRO_EXPEDIDOR

WHERE 
 C.ic_ativo = 'S'
),

--select * from cte_carteira
cte_resumo AS (

select  
DS_CENTRO_EXPEDIDOR,
COLOR,
NU_DIA_SEMANA,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(Reservado) Reservado,
SUM(NU_QUANTIDADE) NU_QUANTIDADE,
SUM(Liberado) Liberado
FROM 
(
   
        select 
              DS_CENTRO_EXPEDIDOR,
              COLOR,
              agesem.NU_DIA_SEMANA,
              SUM(agesem.NU_QUANTIDADE) NU_QUANTIDADE,
              (SELECT Sum(ATD.QT_SEMANA) FROM  semana ATD 
               WHERE ATD.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO 
               AND  ATD.CD_ELO_AGENDAMENTO_ITEM =agesem.CD_ELO_AGENDAMENTO_ITEM)        as Sugerido,
               max(agesem.QT_SEMANA) -   max(agesem.QT_BLOQUEADA)                                       as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO AND c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,

                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO and c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado
 
          from semana agesem
          INNER join 
          (
          SELECT distinct ict.CD_ELO_AGENDAMENTO, ict.CD_ELO_AGENDAMENTO_ITEM , ict.DS_CENTRO_EXPEDIDOR, ict.color
          FROM cte_carteira ict
          ) ec
          on agesem.cd_elo_agendamento = ec.cd_elo_agendamento 
          AND agesem.cd_elo_agendamento_item = ec.cd_elo_agendamento_item

       where 
         ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM


      group by ec.DS_CENTRO_EXPEDIDOR, ec.color,
      
                agesem.NU_DIA_SEMANA,
                agesem.CD_ELO_AGENDAMENTO ,
               agesem.CD_ELO_AGENDAMENTO_ITEM

)
GROUP BY 

DS_CENTRO_EXPEDIDOR,
COLOR,
NU_DIA_SEMANA

)

--SELECT * FROM cte_resumo

select 
DS_CENTRO_EXPEDIDOR "name",
COLOR,
ROUND(SUM(NVL(SEG,0)),0) SEG,
ROUND(SUM(NVL(TER,0)),0) TER,
ROUND(SUM(NVL(QUA,0)),0) QUA,
ROUND(SUM(NVL(QUI,0)),0) QUI,
ROUND(SUM(NVL(SEX,0)),0) SEX,
ROUND(SUM(NVL(SAB,0)),0) SAB,
ROUND(SUM(NVL(DOM,0)),0) DOM
from cte_resumo

PIVOT(SUM(NVL(NU_QUANTIDADE,0))
FOR NU_DIA_SEMANA in ('1' Seg, '2' Ter, '3' Qua, '4' Qui, '5' Sex, '6' Sab, '7' Dom))
GROUP BY DS_CENTRO_EXPEDIDOR, COLOR
;
       
    OPEN P_CHART_FAMILIA FOR
     WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status,
                ad.CD_GRUPO_EMBALAGEM,
                ge.DS_GRUPO_EMBALAGEM ,
                ad.NU_DIA_SEMANA, 
                NVL(ad.NU_QUANTIDADE, 0) NU_QUANTIDADE
                
                
          FROM  vnd.elo_agendamento ag
          INNER JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        INNER JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
         inner JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        inner join VND.ELO_AGENDAMENTO_DAY ad
          on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK   
        inner join VND.GRUPO_EMBALAGEM ge
        on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM  

            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_CENTRO_EXPEDIDOR  = '6120' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'

           
    ) ,
  -- SELECT * FROM semana
   
cte_carteira as 
(
select DISTINCT c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
c.QT_AGENDADA_CONFIRMADA, c.ic_ativo, 
c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.NU_ORDEM, c.CD_INCOTERMS, ST_AGEND.CD_ELO_STATUS, ST_AGEND.SG_STATUS,
c.CD_PRODUTO_SAP, 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.cd_cliente_pagador else c.cd_cliente_recebedor end cd_cliente , 
CASE WHEN c.CD_INCOTERMS = 'FOB' THEN c.no_cliente_pagador else c.no_cliente_recebedor end NO_CLIENTE , 
NVL(ce.DS_COLOR, '#b21515')        as color, 
ce.CD_CENTRO_EXPEDIDOR,
ce.DS_CENTRO_EXPEDIDOR,
prm.QT_PERCENTAGE,
rmg.NO_RAW_MATERIAL_GROUP

from VND.ELO_CARTEIRA c
INNER JOIN
(
select distinct se.cd_elo_agendamento, se.CD_ELO_AGENDAMENTO_ITEM, se.cd_elo_status, se.CD_SALES_GROUP  
from semana se 
) semaext
ON
c.cd_elo_agendamento = semaext.cd_elo_agendamento
AND c.CD_ELO_AGENDAMENTO_ITEM = semaext.CD_ELO_AGENDAMENTO_ITEM
and c.CD_SALES_GROUP = semaext.CD_SALES_GROUP
INNER JOIN VND.ELO_STATUS ST_AGEND
ON
semaext.CD_ELO_STATUS = ST_AGEND.CD_ELO_STATUS

inner join CTF.CENTRO_EXPEDIDOR ce
on c.CD_CENTRO_EXPEDIDOR = ce.CD_CENTRO_EXPEDIDOR

inner join CTF.PRODUTO_RAW_MATERIAL_GROUP prm
on prm.CD_PRODUTO_SAP = C.CD_PRODUTO_SAP
inner join CTF.RAW_MATERIAL_GROUP rmg
on rmg.CD_RAW_MATERIAL_GROUP = prm.CD_RAW_MATERIAL_GROUP

WHERE 
 C.ic_ativo = 'S'
 AND prm.QT_PERCENTAGE > 0
),

--select * from cte_carteira
cte_resumo AS (

select  
NO_RAW_MATERIAL_GROUP,
NU_DIA_SEMANA,
SUM(Sugerido) Sugerido,
SUM(Programado) Programado,
SUM(Reservado) Reservado,
SUM(NU_QUANTIDADE) NU_QUANTIDADE,
SUM(Liberado) Liberado
FROM 
(
   
        select 
              EC.NO_RAW_MATERIAL_GROUP,
              
              agesem.NU_DIA_SEMANA,
              SUM(agesem.NU_QUANTIDADE) NU_QUANTIDADE,
              (SELECT Sum(ATD.QT_SEMANA) FROM  semana ATD 
               WHERE ATD.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO 
               AND  ATD.CD_ELO_AGENDAMENTO_ITEM =agesem.CD_ELO_AGENDAMENTO_ITEM)        as Sugerido,
               max(agesem.QT_SEMANA) -   max(agesem.QT_BLOQUEADA)                                       as Liberado,
               (select sum(c.QT_AGENDADA_CONFIRMADA) 
                  from cte_carteira c
                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO AND c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC'  ) )                                         as Programado,

                (select sum(c.QT_AGENDADA_CONFIRMADA) 
                                  from cte_carteira c
                                 where c.CD_ELO_AGENDAMENTO = agesem.CD_ELO_AGENDAMENTO and c.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM
                                   and c.SG_STATUS IN ('AGCEL', 'PLAN', 'AGCTR', 'AGENC', 'AGLOG' ))  as Reservado
 
          from semana agesem
          INNER join 
          (
          SELECT distinct ict.CD_ELO_AGENDAMENTO, ict.CD_ELO_AGENDAMENTO_ITEM , ict.DS_CENTRO_EXPEDIDOR, ict.color, ict.NO_RAW_MATERIAL_GROUP
          FROM cte_carteira ict
          ) ec
          on agesem.cd_elo_agendamento = ec.cd_elo_agendamento 
          AND agesem.cd_elo_agendamento_item = ec.cd_elo_agendamento_item

       where 
         ec.CD_ELO_AGENDAMENTO_ITEM = agesem.CD_ELO_AGENDAMENTO_ITEM


      group by ec.NO_RAW_MATERIAL_GROUP, 
      
                agesem.NU_DIA_SEMANA,
                agesem.CD_ELO_AGENDAMENTO ,
               agesem.CD_ELO_AGENDAMENTO_ITEM

)
GROUP BY 

NO_RAW_MATERIAL_GROUP,
NU_DIA_SEMANA

)

--SELECT * FROM cte_resumo

select 
NO_RAW_MATERIAL_GROUP "name",
ROUND(SUM(NVL(SEG,0)),0) SEG,
ROUND(SUM(NVL(TER,0)),0) TER,
ROUND(SUM(NVL(QUA,0)),0) QUA,
ROUND(SUM(NVL(QUI,0)),0) QUI,
ROUND(SUM(NVL(SEX,0)),0) SEX,
ROUND(SUM(NVL(SAB,0)),0) SAB,
ROUND(SUM(NVL(DOM,0)),0) DOM
from cte_resumo

PIVOT(SUM(NVL(NU_QUANTIDADE,0))
FOR NU_DIA_SEMANA in ('1' Seg, '2' Ter, '3' Qua, '4' Qui, '5' Sex, '6' Sab, '7' Dom))
GROUP BY NO_RAW_MATERIAL_GROUP;


  END PX_GET_FINAL_VIEW;


  PROCEDURE PX_GET_SUPERVISOR_QUOTA (
    P_POLO          IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
--    P_WEEK          IN INT,
    P_DT_WEEK_START IN ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
    P_GERENTE       IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE, 
    P_SUPERVISOR    IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_RETORNO       OUT T_CURSOR
  )

  IS

  V_CENTROS         VARCHAR2(100);

  BEGIN

    /*
    IF P_POLO is not null THEN

        select LISTAGG(pce.CD_CENTRO_EXPEDIDOR,',') WITHIN GROUP (ORDER BY pce.CD_CENTRO_EXPEDIDOR)
          into V_CENTROS
          from CTF.POLO_CENTRO_EXPEDIDOR pce
         where pce.CD_POLO = P_POLO;

    END IF;
    */

    OPEN P_RETORNO FOR
    WITH CTE_AGE AS 
(
       select sup.CD_ELO_AGENDAMENTO_SUPERVISOR                as AgendamentoSupervisor,
               sup.CD_SALES_GROUP || '-' || u.NO_USUARIO        as SupervisorVenda,
               sup.QT_FORECAST                                  as Forecast,
               sup.QT_COTA                                      as Cota,
               sup.QT_COTA_AJUSTADA                             as CotaAjustada
          from VND.ELO_AGENDAMENTO_SUPERVISOR sup
         inner join VND.ELO_AGENDAMENTO ag
            on ag.CD_ELO_AGENDAMENTO = sup.CD_ELO_AGENDAMENTO
         inner join CTF.USUARIO u
            on sup.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
          left join CTF.CENTRO_EXPEDIDOR ex
            on ag.CD_CENTRO_EXPEDIDOR = ex.CD_CENTRO_EXPEDIDOR
         where sup.IC_ATIVO = 'S'
           and (P_POLO is null or ag.CD_CENTRO_EXPEDIDOR IN (select pc.CD_CENTRO_EXPEDIDOR 
                                                               from CTF.POLO_CENTRO_EXPEDIDOR pc 
                                                              where CD_POLO = P_POLO) or ag.CD_POLO = P_POLO)
           -- AND ag.CD_WEEK =  'W272018'     
          and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO) 
--           and to_number(to_char(to_date(ag.DT_WEEK_START,'DD/MM/YYYY'),'WW')) = P_WEEK
           and to_number(to_char(to_date(ag.DT_WEEK_START,'DD/MM/RRRR'),'WW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'WW'))
           and extract(year from ag.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
)
SELECT AgendamentoSupervisor,SupervisorVenda, Forecast, Cota, CotaAjustada FROM CTE_AGE AGE
WHERE AGE.Cota > 0 OR AGE.CotaAjustada > 0
UNION ALL
SELECT MAX(AgendamentoSupervisor),SupervisorVenda, Sum(Forecast) Forecast, Sum(Cota) Cota, Sum(CotaAjustada) CotaAjustada FROM CTE_AGE AGE
WHERE NVL(AGE.Cota,0) =0 AND  NVL(AGE.CotaAjustada,0 ) =0
GROUP BY SupervisorVenda
order by SupervisorVenda;
    
    
  

  END PX_GET_SUPERVISOR_QUOTA;

  PROCEDURE PU_UPDATE_SUPERVISOR_QUOTA (
    P_CD_AGENDAMENTO_SUPERVISOR     IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_ELO_AGENDAMENTO_SUPERVISOR%TYPE,
    P_QT_COTA_AJUSTADA              IN VND.ELO_AGENDAMENTO_SUPERVISOR.QT_COTA_AJUSTADA%TYPE,
    P_RETORNO                       OUT T_CURSOR
  )

  IS

    V_RETORNO CHAR;

  BEGIN

    update VND.ELO_AGENDAMENTO_SUPERVISOR
       set QT_COTA_AJUSTADA = P_QT_COTA_AJUSTADA
     where CD_ELO_AGENDAMENTO_SUPERVISOR = P_CD_AGENDAMENTO_SUPERVISOR;
     commit;

    V_RETORNO := 'T';

    OPEN P_RETORNO FOR
        select V_RETORNO as RETORNO from dual;

    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            V_RETORNO := 'F';
            ROLLBACK;
        END;

  END PU_UPDATE_SUPERVISOR_QUOTA;

  PROCEDURE PX_GET_CHART_VOLUME (
    P_POLO          IN CTF.POLO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_SEMANA        IN VARCHAR2,
    P_SUPERVISOR    IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_TIPO          OUT T_CURSOR,
    P_INCOTERM      OUT T_CURSOR,
    P_EMBALAGEM     OUT T_CURSOR
  )

  IS

  BEGIN

    OPEN P_TIPO FOR
    WITH semana AS (
        SELECT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial
                
          FROM vnd.elo_agendamento_week aw
          
         INNER JOIN vnd.elo_agendamento_item it
            ON aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
            
         INNER JOIN vnd.elo_agendamento_supervisor sup
            ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
            
         INNER JOIN vnd.elo_agendamento ag
            ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
            
         WHERE 
               (p_polo IS NULL OR ag.cd_polo = p_polo)
           AND (p_centro IS NULL OR ag.cd_centro_expedidor = p_centro)
           AND (p_maquina IS NULL OR ag.cd_machine = p_maquina)
           AND (p_semana IS NULL OR ag.cd_week = p_semana)
           AND (p_supervisor IS NULL OR sup.cd_sales_group = p_supervisor)
           AND it.ic_ativo = 'S'
           AND sup.ic_ativo = 'S'
    )
    SELECT NVL(SUM(qt_relacionamento), 0)                                                                   AS Relacionamento,
           NVL(SUM(qt_emergencial) , 0)                                                                     AS Emergencial,
           (NVL(SUM(qt_semana), 0) - NVL(SUM(qt_relacionamento), 0) - NVL(SUM(qt_emergencial) , 0))         AS Outros
      FROM (
                SELECT se.cd_elo_agendamento_week,
                       se.qt_semana,
                       se.qt_emergencial,
                       MAX(ca.ic_relacionamento) ic_relacionamento,
                       CASE WHEN MAX(ca.ic_relacionamento) = 'S' THEN se.qt_semana
                            ELSE 0
                       END qt_relacionamento
                  FROM semana se
                 INNER JOIN vnd.elo_carteira ca
                    ON ca.cd_elo_agendamento = se.cd_elo_agendamento
                   AND ca.cd_elo_agendamento_item = se.cd_elo_agendamento_item
                 WHERE ca.ic_ativo = 'S'
                 GROUP BY se.cd_elo_agendamento_week,
                          se.qt_semana,
                          se.qt_emergencial
           )
    ;

    OPEN P_INCOTERM FOR
WITH CTE_DAY AS 
(
    SELECT 1 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 2 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 3 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 4 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 5 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 6 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 7 NU_DIA_SEMANA FROM DUAL
)

    SELECT DIASEMANA, SUM(CIF) CIF, SUM(FOB) FOB 
    FROM (

       select distinct DIASEMANA,
                        NVL(CIF, 0) AS CIF,
                        NVL(FOB, 0) AS FOB
          from
        (
          select distinct 
                 NVL(SUM(ad.NU_QUANTIDADE),0)      as NU_QUANTIDADE,
                 ad.NU_DIA_SEMANA                  as DiaSemana,
                 ai.CD_INCOTERMS                   as CD_INCOTERMS
            from VND.ELO_AGENDAMENTO_ITEM ai
           inner join VND.ELO_AGENDAMENTO_WEEK aw
              on aw.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
           inner join VND.ELO_AGENDAMENTO_SUPERVISOR sup
              on sup.CD_ELO_AGENDAMENTO_SUPERVISOR = ai.CD_ELO_AGENDAMENTO_SUPERVISOR
           inner join VND.ELO_AGENDAMENTO ag
              on sup.CD_ELO_AGENDAMENTO = ag.CD_ELO_AGENDAMENTO
           inner join VND.ELO_AGENDAMENTO_DAY ad
              on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK
           inner join VND.GRUPO_EMBALAGEM ge
              on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM
           where ag.IC_ATIVO = 'S'
           --AND ag.CD_CENTRO_EXPEDIDOR = '6023' AND ag.CD_WEEK = 'W242018'
          -- AND  sup.CD_SALES_GROUP = '706'
             and (P_POLO is null or ag.CD_POLO = P_POLO)
             and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
             and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
             and (P_SEMANA is null or ag.CD_WEEK = P_SEMANA)
             and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
             and sup.IC_ATIVO = 'S'
             and ag.IC_ATIVO = 'S'
             and ai.IC_ATIVO = 'S'
        group by ad.NU_DIA_SEMANA,
                 ai.CD_INCOTERMS
           ) 
              PIVOT(SUM(NVL(NU_QUANTIDADE,0))
              FOR CD_INCOTERMS in ('CIF' CIF, 'FOB' FOB)
      )
      UNION 
      SELECT NU_DIA_SEMANA , 0, 0 FROM CTE_DAY DD
      )
      GROUP BY DIASEMANA
     
      ORDER BY DiaSemana;

    OPEN P_EMBALAGEM FOR
    
WITH CTE_DAY AS 
(
    SELECT 1 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 2 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 3 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 4 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 5 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 6 NU_DIA_SEMANA FROM DUAL
    UNION
    SELECT 7 NU_DIA_SEMANA FROM DUAL
)

    SELECT DIASEMANA, SUM(Bag) Bag, SUM(Ensacado) Ensacado, SUM(Granel) Granel 
    FROM (
    
    
    
        select distinct DIASEMANA,
                        NVL(Bag, 0)         AS Bag,
                        NVL(Ensacado, 0)    AS Ensacado,
                        NVL(Granel, 0)      AS Granel
          from
        (
          select distinct 
                 NVL(SUM(ad.NU_QUANTIDADE),0)      as NU_QUANTIDADE,
                 ad.NU_DIA_SEMANA                  as DiaSemana,
                 ad.CD_GRUPO_EMBALAGEM             as CD_GRUPO_EMBALAGEM
            from VND.ELO_AGENDAMENTO_ITEM ai
           inner join VND.ELO_AGENDAMENTO_WEEK aw
              on aw.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
           inner join VND.ELO_AGENDAMENTO_SUPERVISOR sup
              on sup.CD_ELO_AGENDAMENTO_SUPERVISOR = ai.CD_ELO_AGENDAMENTO_SUPERVISOR
           inner join VND.ELO_AGENDAMENTO ag
              on sup.CD_ELO_AGENDAMENTO = ag.CD_ELO_AGENDAMENTO
           inner join VND.ELO_AGENDAMENTO_DAY ad
              on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK
           inner join VND.GRUPO_EMBALAGEM ge
              on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM
           where ag.IC_ATIVO = 'S'
             and (P_POLO is null or ag.CD_POLO = P_POLO)
             and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
             and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
             and (P_SEMANA is null or ag.CD_WEEK = P_SEMANA)
             and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
        group by ad.NU_DIA_SEMANA,
                 ad.CD_GRUPO_EMBALAGEM
           ) 
              PIVOT(SUM(NVL(NU_QUANTIDADE,0))
              FOR CD_GRUPO_EMBALAGEM in ('B' Bag, 'S' Ensacado, 'G' Granel))
              
      UNION 
      SELECT NU_DIA_SEMANA , 0, 0, 0 FROM CTE_DAY DD
      )
      GROUP BY DIASEMANA             
              
                    
      ORDER BY DiaSemana;


  END PX_GET_CHART_VOLUME;

  PROCEDURE PX_GET_CHART_VOLUME_EXIBIR (
    P_POLO          IN CTF.POLO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_SEMANA        IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
    P_TRAVADO       OUT T_CURSOR

  )

  IS

    V_TRAVADO VARCHAR2(1):='N';
    
  BEGIN
 
    BEGIN 
    SELECT 'S' INTO V_TRAVADO
    FROM vnd.elo_agendamento ag
    INNER JOIN VND.ELO_STATUS st
    on 
    ag.cd_elo_status = st.cd_elo_status 
    
    WHERE 
    (p_polo IS NULL OR ag.cd_polo = p_polo)
    AND (p_centro IS NULL OR ag.cd_centro_expedidor = p_centro)
    AND (p_maquina IS NULL OR ag.cd_machine = p_maquina)
    AND (p_semana IS NULL OR ag.cd_week = p_semana)
    AND ag.ic_ativo = 'S'
    AND st.SG_STATUS IN('PLAN','AGCTR','AGENC')
    AND ROWNUM = 1;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    V_TRAVADO:='N';
    WHEN OTHERS THEN
    V_TRAVADO:='N';
    
    END;
    
    OPEN P_TRAVADO FOR 
    SELECT 1 "value" , V_TRAVADO "text" FROM DUAL;


  END PX_GET_CHART_VOLUME_EXIBIR;



  PROCEDURE PX_GET_SUPERVISOR_PROGRAMACAO (
    P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
    P_CENTRO                IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,   
    P_MAQUINA               IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_WEEK                  IN VARCHAR2,
    P_SUPERVISOR            IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE,
    P_GERENTE               IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE, 
    C_SUPERVISOR            OUT T_CURSOR,
    C_WEEK_DAY              OUT T_CURSOR
  )

  IS
  BEGIN

    OPEN C_SUPERVISOR FOR
    WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP
                
        FROM vnd.elo_agendamento ag
        left  JOIN vnd.elo_agendamento_supervisor sup
        ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
        AND sup.ic_ativo = 'S'
        left JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
        AND it.ic_ativo = 'S'
        left join vnd.elo_agendamento_week aw
        ON aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        
        left join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_POLO  = 'P002' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         
           
    ) ,
   -- SELECT * FROM semana
   
cte_carteira as 
(
select c.cd_elo_agendamento, c.cd_elo_carteira, c.cd_elo_agendamento_item, c.QT_PROGRAMADA, 
NVL(c.QT_AGENDADA_CONFIRMADA, 0) QT_AGENDADA_CONFIRMADA, c.ic_ativo, c.IC_RELACIONAMENTO, c.CD_SALES_GROUP, c.QT_EMERGENCIAL
from VND.ELO_CARTEIRA c
WHERE exists (select 1 from semana se where c.cd_elo_agendamento = se.cd_elo_agendamento
and c.CD_SALES_GROUP = se.CD_SALES_GROUP
and C.ic_ativo = 'S')
)  ,
 --  select * from cte_carteira
    
cte_resumo AS ( 

SELECT distinct 
Supervisor,
Cota,
Bloqueado, 
Cortado,
Relacionamento,
Emergencial,
DemaisOrdens,
TotalSugerido,
PorcentagemCota,
QT_AGENDADA_CONFIRMADA

from 
(
        select agesem.Supervisor   as Supervisor,
               max(agesem.QT_COTA )  as Cota,
               sum(agesem.QT_BLOQUEADA) as Bloqueado,
               NVL(sum(nvl(agesem.QT_SEMANA,0)) - (SELECT sum(nvl(c.QT_AGENDADA_CONFIRMADA,0))  
                  from cte_carteira c
                 where c.cd_elo_agendamento = agesem.cd_elo_agendamento
                 and c.CD_SALES_GROUP = agesem.CD_SALES_GROUP
                 and c.ic_ativo = 'S' ),0) as Cortado,
               NVL((select sum(c.QT_AGENDADA_CONFIRMADA)
                  from cte_carteira c
                 where c.cd_elo_agendamento = agesem.cd_elo_agendamento
                 and c.CD_SALES_GROUP = agesem.CD_SALES_GROUP
                 and c.ic_ativo = 'S'
                   and c.IC_RELACIONAMENTO = 'S'), 0)   as Relacionamento,
               NVL((SELECT sum(c.QT_EMERGENCIAL) 
               from cte_carteira c
               where c.CD_SALES_GROUP = agesem.CD_SALES_GROUP
               AND c.ic_ativo = 'S'),0)  as Emergencial,
               ----------------------------------------------------------------------------------------------------------------------
        0 as DemaisOrdens,
           ----------------------------------------------------------------------------------------------------------------------------
               sum(agesem.qt_semana) as TotalSugerido,
               0 as PorcentagemCota,
               --((sum(ec.QT_PROGRAMADA) / sup.QT_COTA) * 100)                                                        as PorcentagemCota
                         NVL((select sum(c.QT_AGENDADA_CONFIRMADA)
                  from cte_carteira c
                 where c.cd_elo_agendamento = agesem.cd_elo_agendamento
                 and c.CD_SALES_GROUP = agesem.CD_SALES_GROUP
                 and c.ic_ativo = 'S' ), 0)   as QT_AGENDADA_CONFIRMADA   
               
               
          from semana agesem

      group by agesem.Supervisor,
                agesem.cd_elo_agendamento,
                agesem.CD_SALES_GROUP


)
               
)   
--select * from cte_resumo  order by supervisor

select Supervisor, 
               Cota, 
               sum(Bloqueado)           as Bloqueado, 
               sum(Cortado)             as Cortado, 
               sum(Relacionamento)      as Relacionamento, 
               sum(Emergencial)         as Emergencial, 
               sum(QT_AGENDADA_CONFIRMADA) -  sum(Emergencial)  - sum(Relacionamento)   as DemaisOrdens,
               sum(TotalSugerido)       as TotalSugerido,
               case
               WHEN Cota > 0 THEN ROUND(sum(TotalSugerido) / Cota, 2) *100 ELSE 0 END PorcentagemCota ,
               sum(QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA
          from cte_resumo

    group by Supervisor,
             Cota, 
             PorcentagemCota;
  

    OPEN C_WEEK_DAY FOR
     WITH semana AS (
        SELECT DISTINCT 
                ag.cd_elo_agendamento,
                it.cd_elo_agendamento_item,
                aw.cd_elo_agendamento_week,
                NVL(aw.qt_semana, 0) qt_semana,
                NVL(aw.qt_emergencial, 0) qt_emergencial,
                sup.CD_SALES_GROUP || '-' || u.NO_USUARIO  as Supervisor,
                nvl(sup.qt_cota_ajustada, sup.QT_COTA) QT_COTA,
                0 QT_BLOQUEADA,
                sup.CD_SALES_GROUP,
                it.CD_CLIENTE,
                ag.cd_elo_status,
                ad.CD_GRUPO_EMBALAGEM,
                ge.DS_GRUPO_EMBALAGEM ,
                ad.NU_DIA_SEMANA, 
                NVL(ad.NU_QUANTIDADE, 0) NU_QUANTIDADE
                
                
          FROM  vnd.elo_agendamento ag
          left JOIN vnd.elo_agendamento_supervisor sup
          ON sup.cd_elo_agendamento = ag.cd_elo_agendamento
          AND sup.ic_ativo = 'S'
        left JOIN vnd.elo_agendamento_item it
        ON it.cd_elo_agendamento_supervisor = sup.cd_elo_agendamento_supervisor
        AND it.ic_ativo = 'S'
         left JOIN vnd.elo_agendamento_week aw
         ON
         aw.cd_elo_agendamento_item = it.cd_elo_agendamento_item
        left join VND.ELO_AGENDAMENTO_DAY ad
          on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK   
        left join VND.GRUPO_EMBALAGEM ge
        on ad.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM  

            
        inner join CTF.USUARIO u
        on u.CD_USUARIO_ORIGINAL = sup.CD_SALES_GROUP   
            
         WHERE --ag.CD_CENTRO_EXPEDIDOR  = '6120' AND ag.CD_WEEK = 'W132018'
         (P_POLO is null or ag.CD_POLO = P_POLO)
           and (P_CENTRO is null or ag.CD_CENTRO_EXPEDIDOR = P_CENTRO)
           and (P_MAQUINA is null or ag.CD_MACHINE = P_MAQUINA)
           and (P_WEEK is null or ag.CD_WEEK = P_WEEK)
           and (P_SUPERVISOR is null or sup.CD_SALES_GROUP = P_SUPERVISOR)
           and (P_GERENTE is null or sup.CD_SALES_OFFICE = P_GERENTE)         

 )      
 
        select distinct * from
        (
          select distinct
                 Supervisor "name",
                 NU_QUANTIDADE as Quantidade,
                 NU_DIA_SEMANA 
           from semana

           ) 
              PIVOT(SUM(NVL(Quantidade,0))
              FOR NU_DIA_SEMANA in ('1' Seg, '2' Ter, '3' Qua, '4' Qui, '5' Sex, '6' Sab, '7' Dom));


  END PX_GET_SUPERVISOR_PROGRAMACAO;  
  
  
  
  PROCEDURE PX_REPORT_AGEND_BAL_CENTRO (
    P_POLO          IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE, 
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_CD_WEEK       IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
    P_RETORNO       OUT T_CURSOR
  )

  IS
 
  BEGIN
  
    OPEN P_RETORNO FOR
    WITH CTE_RESULT AS (
    SELECT 
        CASE    WHEN AGE.CD_POLO IS NOT NULL THEN (SELECT PP.DS_POLO FROM CTF.POLO PP WHERE PP.CD_POLO = AGE.CD_POLO) 
                WHEN AGE.CD_CENTRO_EXPEDIDOR IS NOT NULL THEN (SELECT CC.DS_CENTRO_EXPEDIDOR FROM CTF.CENTRO_EXPEDIDOR CC WHERE CC.CD_CENTRO_EXPEDIDOR = AGE.CD_CENTRO_EXPEDIDOR)
                WHEN AGE.CD_MACHINE IS NOT NULL THEN (SELECT MM.DS_MACHINE FROM CTF.MACHINE MM WHERE MM.CD_MACHINE = AGE.CD_MACHINE)
                ELSE 'N/A' END AS FABRICA,
        ECI.CD_ELO_CARTEIRA, 
        ECI.CD_ELO_AGENDAMENTO,
        ECI.CD_ELO_AGENDAMENTO_ITEM,
        ECI.DS_CENTRO_EXPEDIDOR,
        ECI.CD_CENTRO_EXPEDIDOR , 
        ECI.NO_SALES_OFFICE, --GERENCIA, 
        ECI.NO_SALES_GROUP,
        ECI.IC_FA,  --FA,
        ECI.NU_CONTRATO, --CONTRATO, 
        ECI.NU_ORDEM_VENDA, -- ORDEM,
        CASE WHEN ECI.IC_RELACIONAMENTO = 'S' THEN 'RELACIONAMENTO' ELSE 'GERAL' END IC_RELACIONAMENTO,
        ECI.CD_INCOTERMS,
        ECI.CD_PRODUTO_SAP,
        ECI.NO_PRODUTO_SAP,
        ECI.CD_GRUPO_EMBALAGEM,
        PS.CD_LINHA_PRODUTO_SAP,
        SUMOFAG.SEG, SUMOFAG.TER, SUMOFAG.QUA,  SUMOFAG.QUI, 
        SUMOFAG.SEX,  SUMOFAG.SAB,  SUMOFAG.DOM
        , NVL(TOT_QT.NU_QUANTIDADE,'0') "NU_QUANTIDADE"
    FROM VND.ELO_CARTEIRA ECI
    INNER JOIN VND.ELO_AGENDAMENTO AGE ON ECI.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
    INNER JOIN CTF.PRODUTO_SAP PS ON PS.CD_PRODUTO_SAP = ECI.CD_PRODUTO_SAP
    INNER JOIN (SELECT  
                EA.CD_ELO_AGENDAMENTO,
                EAI.CD_ELO_AGENDAMENTO_ITEM,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 1 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS SEG,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 2 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS TER,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 3 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS QUA,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 4 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS QUI,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 5 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS SEX,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 6 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS SAB,
                SUM(CASE EAD.NU_DIA_SEMANA WHEN 7 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS DOM
                FROM VND.ELO_AGENDAMENTO EA 
                INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
                INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI ON (EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =  EAI.CD_ELO_AGENDAMENTO_SUPERVISOR)
                INNER JOIN VND.ELO_AGENDAMENTO_WEEK EAW ON EAI.CD_ELO_AGENDAMENTO_ITEM = EAW.CD_ELO_AGENDAMENTO_ITEM
                INNER JOIN VND.ELO_AGENDAMENTO_DAY EAD ON EAW.CD_ELO_AGENDAMENTO_WEEK = EAD.CD_ELO_AGENDAMENTO_WEEK
                /*INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
                INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR = EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
                INNER JOIN VND.ELO_AGENDAMENTO_WEEK EAW ON EAI.CD_ELO_AGENDAMENTO_ITEM = EAW.CD_ELO_AGENDAMENTO_ITEM
                INNER JOIN VND.ELO_CARTEIRA EC ON (EAI.CD_ELO_AGENDAMENTO_ITEM =  EC.CD_ELO_AGENDAMENTO_ITEM
                                                AND EAI.CD_PRODUTO_SAP = EC.CD_PRODUTO_SAP)
                LEFT JOIN VND.ELO_CARTEIRA_DAY EAD ON EC.CD_ELO_CARTEIRA = EAD.CD_ELO_CARTEIRA*/
                WHERE EA.IC_ATIVO ='S'
                GROUP BY EA.CD_ELO_AGENDAMENTO, EAI.CD_ELO_AGENDAMENTO_ITEM ) SUMOFAG
        ON SUMOFAG.CD_ELO_AGENDAMENTO = ECI.CD_ELO_AGENDAMENTO AND SUMOFAG.CD_ELO_AGENDAMENTO_ITEM = ECI.CD_ELO_AGENDAMENTO_ITEM 
    LEFT JOIN(
                SELECT   
                EA.CD_ELO_AGENDAMENTO,
                EC.NU_CONTRATO,
                EC.NU_ORDEM_VENDA,
                EC.CD_ELO_CARTEIRA,
                SUM(NVL(EC.QT_AGENDADA_CONFIRMADA,0)) AS NU_QUANTIDADE
                FROM VND.ELO_CARTEIRA EC
                INNER JOIN VND.ELO_AGENDAMENTO EA ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
                GROUP BY EA.CD_ELO_AGENDAMENTO, EC.NU_CONTRATO, EC.NU_ORDEM_VENDA, EC.CD_ELO_CARTEIRA) TOT_QT
        ON (TOT_QT.CD_ELO_AGENDAMENTO = ECI.CD_ELO_AGENDAMENTO AND TOT_QT.NU_CONTRATO = ECI.NU_CONTRATO AND TOT_QT.NU_ORDEM_VENDA = ECI.NU_ORDEM_VENDA AND
            TOT_QT.CD_ELO_CARTEIRA = ECI.CD_ELO_CARTEIRA)
    WHERE ( AGE.IC_ATIVO ='S' )
    AND (ECI.IC_ATIVO = 'S')
    AND (ECI.QT_AGENDADA_CONFIRMADA > 0 )
    AND (AGE.CD_WEEK = P_CD_WEEK) 
    AND (P_CENTRO IS NULL OR AGE.CD_CENTRO_EXPEDIDOR = P_CENTRO)
    AND (P_POLO IS NULL OR AGE.CD_POLO = P_POLO)
    AND (P_MAQUINA IS NULL OR AGE.CD_MACHINE = P_MAQUINA)
    )
    
    SELECT DISTINCT
        MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA
        , CD_ELO_AGENDAMENTO
        , FABRICA
        , CD_CENTRO_EXPEDIDOR
        , NO_SALES_OFFICE
        , IC_FA
        , MAX(NU_CONTRATO) NU_CONTRATO
        , MAX(NU_ORDEM_VENDA) NU_ORDEM_VENDA
        , IC_RELACIONAMENTO
        , CD_INCOTERMS
        , NO_PRODUTO_SAP "CD_PRODUTO_SAP"
        , CD_GRUPO_EMBALAGEM
        , CD_LINHA_PRODUTO_SAP
        , ROUND(SEG,2) SEG
        , ROUND(TER,2) TER
        , ROUND(QUA,2) QUA
        , ROUND(QUI,2) QUI
        , ROUND(SEX,2) SEX
        , ROUND(SAB,2) SAB
        , ROUND(DOM,2) DOM
        , ROUND(NU_QUANTIDADE,2) NU_QUANTIDADE
    FROM CTE_RESULT 
    GROUP BY CD_ELO_AGENDAMENTO, FABRICA,CD_CENTRO_EXPEDIDOR, NO_SALES_OFFICE, IC_FA, IC_RELACIONAMENTO, CD_INCOTERMS,
    CD_PRODUTO_SAP, NO_PRODUTO_SAP, CD_GRUPO_EMBALAGEM, CD_LINHA_PRODUTO_SAP, SEG, TER, QUA,  QUI, SEX,  SAB,  DOM, NU_QUANTIDADE
    ORDER BY 3, 5, 7, 8, 9, 10;   

  END PX_REPORT_AGEND_BAL_CENTRO;

 
  PROCEDURE PX_REPORT_AGEND_BAL_CENTROOLD (
    P_POLO          IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
    P_CENTRO        IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE, 
    P_MAQUINA       IN CTF.MACHINE.CD_MACHINE%TYPE,
    P_CD_WEEK       IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
    P_RETORNO       OUT T_CURSOR
  )

  IS
 
  BEGIN
  
    OPEN P_RETORNO FOR
    WITH CTE_FILTER AS (
    SELECT DISTINCT 
        EA.CD_WEEK, EC.CD_ELO_CARTEIRA, EC.CD_ELO_AGENDAMENTO,
        CASE WHEN EA.CD_POLO IS NOT NULL THEN (SELECT DS_POLO FROM CTF.POLO WHERE CD_POLO=EA.CD_POLO) 
             WHEN EA.CD_CENTRO_EXPEDIDOR IS NOT NULL THEN (SELECT DS_CENTRO_EXPEDIDOR FROM CTF.CENTRO_EXPEDIDOR WHERE CD_CENTRO_EXPEDIDOR=EA.CD_CENTRO_EXPEDIDOR)
             WHEN EA.CD_MACHINE IS NOT NULL THEN (SELECT DS_MACHINE FROM CTF.MACHINE WHERE CD_MACHINE=EA.CD_MACHINE)
        ELSE 'N/A' END AS FABRICA,
        EC.DS_CENTRO_EXPEDIDOR,
        EC.CD_CENTRO_EXPEDIDOR , 
        EC.NO_SALES_OFFICE, --GERENCIA, 
        EC.NO_SALES_GROUP,
        EC.IC_FA,  --FA,
        NU_CONTRATO, --CONTRATO, 
        EC.NU_ORDEM_VENDA, -- ORDEM,
        CASE WHEN EC.IC_RELACIONAMENTO = 'S' THEN 'RELACIONAMENTO' ELSE 'GERAL' END IC_RELACIONAMENTO, --AS CLIENTE_ATENCAO, 
        EC.CD_INCOTERMS, --AS MOD, 
        TO_CHAR(to_number(EC.CD_PRODUTO_SAP)) || '-' || EC.NO_PRODUTO_SAP "CD_PRODUTO_SAP", --AS PRODUTO, 
        EC.CD_GRUPO_EMBALAGEM,
        PS.CD_LINHA_PRODUTO_SAP,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 1 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS SEG,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 2 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS TER,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 3 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS QUA,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 4 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS QUI,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 5 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS SEX,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 6 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS SAB,
        SUM(CASE EAD.NU_DIA_SEMANA WHEN 7 THEN EAD.NU_QUANTIDADE ELSE 0 END) AS DOM                   
    FROM ELO_AGENDAMENTO EA 
    INNER JOIN ELO_AGENDAMENTO_SUPERVISOR EAS ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
    INNER JOIN ELO_AGENDAMENTO_ITEM EAI ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR = EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
    INNER JOIN ELO_AGENDAMENTO_WEEK EAW ON EAI.CD_ELO_AGENDAMENTO_ITEM = EAW.CD_ELO_AGENDAMENTO_ITEM
    INNER JOIN ELO_AGENDAMENTO_DAY EAD ON EAW.CD_ELO_AGENDAMENTO_WEEK = EAD.CD_ELO_AGENDAMENTO_WEEK
    INNER JOIN CTF.PRODUTO_SAP PS ON PS.CD_PRODUTO_SAP = EAI.CD_PRODUTO_SAP
    INNER JOIN ELO_CARTEIRA EC ON EC.CD_ELO_AGENDAMENTO = EA.CD_ELO_AGENDAMENTO AND EAI.CD_ELO_AGENDAMENTO_ITEM = EC.CD_ELO_AGENDAMENTO_ITEM 
    WHERE (
    EA.IC_ATIVO ='S' AND EA.CD_WEEK=P_CD_WEEK) 
    AND    (P_CENTRO IS NULL OR EA.CD_CENTRO_EXPEDIDOR=P_CENTRO)
    AND    (P_POLO IS NULL OR EA.CD_POLO=P_POLO)
    AND    (P_MAQUINA IS NULL OR EA.CD_MACHINE=P_MAQUINA)
    GROUP BY EA.CD_WEEK, EC.CD_ELO_CARTEIRA, EC.CD_ELO_AGENDAMENTO, EA.CD_POLO, EA.CD_CENTRO_EXPEDIDOR, EA.CD_MACHINE, EC.DS_CENTRO_EXPEDIDOR,
    EC.CD_CENTRO_EXPEDIDOR ,     EC.NO_SALES_OFFICE,    EC.NO_SALES_GROUP,    EC.IC_FA,    NU_CONTRATO,    EC.NU_ORDEM_VENDA,
    EC.IC_RELACIONAMENTO, EC.CD_INCOTERMS,     TO_CHAR(to_number(EC.CD_PRODUTO_SAP)) || '-' || EC.NO_PRODUTO_SAP,    EC.CD_GRUPO_EMBALAGEM,    PS.CD_LINHA_PRODUTO_SAP, EAD.NU_DIA_SEMANA
    ),
    RESULTADO AS (
    SELECT CD_ELO_CARTEIRA, CD_ELO_AGENDAMENTO, 
    FABRICA, CD_CENTRO_EXPEDIDOR, NO_SALES_OFFICE, IC_FA,NU_CONTRATO, 
    NU_ORDEM_VENDA,  IC_RELACIONAMENTO, 
    CD_INCOTERMS, CD_PRODUTO_SAP, CD_GRUPO_EMBALAGEM,CD_LINHA_PRODUTO_SAP,
    SUM(SEG) SEG, SUM(TER) TER, SUM(QUA) QUA, SUM(QUI) QUI, SUM(SEX) SEX, SUM(SAB) SAB, SUM(DOM) DOM
    FROM CTE_FILTER 
    GROUP BY 
    CD_ELO_CARTEIRA, CD_ELO_AGENDAMENTO, 
    FABRICA,CD_CENTRO_EXPEDIDOR, NO_SALES_OFFICE, IC_FA,NU_CONTRATO, 
    NU_ORDEM_VENDA, IC_RELACIONAMENTO, CD_INCOTERMS, 
    CD_PRODUTO_SAP, CD_GRUPO_EMBALAGEM,
    CD_LINHA_PRODUTO_SAP  )
    
    SELECT 
    CD_ELO_CARTEIRA, 
    CD_ELO_AGENDAMENTO,
    FABRICA,
    CD_CENTRO_EXPEDIDOR, 
    NO_SALES_OFFICE, 
    IC_FA,
    NU_CONTRATO, 
    NU_ORDEM_VENDA,
    IC_RELACIONAMENTO, 
    CD_INCOTERMS, 
    CD_PRODUTO_SAP, 
    CD_GRUPO_EMBALAGEM ,
    CD_LINHA_PRODUTO_SAP ,
    SEG, TER, QUA, QUI, SEX, SAB, DOM,
    SEG+TER+QUA+QUI+SEX+SAB+DOM NU_QUANTIDADE 
    FROM RESULTADO;  
 

  END PX_REPORT_AGEND_BAL_CENTROOLD;



END GX_ELO_AGENDAMENTO_REPORTS;
/