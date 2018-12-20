        SELECT DISTINCT AE.NU_CONTRATO,
               AE.CD_ITEM_CONTRATO,
               IC.NU_QUANTIDADE,
               IC.NO_PRODUTO,
               NVL(IC.IC_RECUSADO, 'N') IC_RECUSADO
               ,EN.NU_PROTOCOLO_ENTREGA
               --P.NU_ORDEM_VENDA
               , EN.*
          FROM VND.CONTRATO            CO,
               VND.ITEM_CONTRATO       IC,
               CPT.AUTORIZACAO_ENTREGA AE,
               CPT.ENTREGA             EN
         WHERE CO.NU_CONTRATO = AE.NU_CONTRATO
           AND CO.CD_CONTRATO = IC.CD_CONTRATO
           AND AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA
           AND AE.CD_ITEM_CONTRATO = IC.CD_ITEM_CONTRATO
          -- AND (IC.CD_ITEM_CONTRATO = 10 OR 10 IS NULL)
          -- AND (TO_NUMBER(CO.NU_CONTRATO) = NULL OR NULL IS NULL)
          -- AND (AE.NU_NOTA_FISCAL = P_NU_NOTA_FISCAL OR P_NU_NOTA_FISCAL IS NULL)
           AND (EN.NU_PROTOCOLO_ENTREGA LIKE '%R129367CU1%' )
          -- AND CO.IC_ATIVO = 'S';
          ;
          
          
              SELECT --CPT.GX_PORTAL_COOP2.FX_VERIFICA_SALDO_COOPERATIVA(P_NU_CONTRATO, P_CD_ITEM_CONTRATO) NU_QUANTIDADE_SALDO,
           IC.NU_QUANTIDADE, NU_QTY_DELIVERED
      FROM VND.CONTRATO CO,
           VND.ITEM_CONTRATO IC
     WHERE CO.CD_CONTRATO = IC.CD_CONTRATO
       AND CO.NU_CONTRATO = 3066378
       AND IC.CD_ITEM_CONTRATO = 10
       AND CO.IC_ATIVO = 'S';
       
       
    select 140  - (   140 + 35 - 35) from dual;
       
       
    SELECT 
    IC.NU_QTY_DELIVERED,
    ic.NU_QUANTIDADE
    ,
    IC.NU_QUANTIDADE - (
              NVL(AUT.TOTAL, 0) +                                 -- Total requested by cooperative
              (NVL (/*ORD.ENTREGUE_ORDEM_VENDA */IC.NU_QTY_DELIVERED, 0) - NVL (ENT.TOTAL, 0)) -- Requested directly in SAP
           ) NU_QUANTIDADE_SALDO, 
           CO.*
           
     -- INTO RESULT
      FROM VND.CONTRATO CO,
           VND.ITEM_CONTRATO IC,
           (
                SELECT NVL(SUM (AUTORIZACOES.QT_QUANTIDADE), 0) TOTAL
                  FROM (
                      SELECT DISTINCT AE.*
                        FROM CPT.AUTORIZACAO_ENTREGA AE,
                             CPT.ENTREGA EN
                       WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA(+)
                         --AND EN.SG_STATUS(+) <> 'C' -- SUMLAUF 11-Apr-2012
                         AND EN.SG_STATUS <> 'C'      -- SUMLAUF 11-Apr-2012
                         AND AE.NU_CONTRATO(+) = 2754332
                         AND AE.CD_ITEM_CONTRATO = 10
                  ) AUTORIZACOES
           ) AUT,
           (
                SELECT NVL(SUM (EN.QT_FORNECIDO), 0) TOTAL
                  FROM CPT.AUTORIZACAO_ENTREGA AE,
                       CPT.ENTREGA EN
                 WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA(+)
                   --AND EN.SG_STATUS(+) <> 'C' -- SUMLAUF 11-Apr-2012
                   AND EN.SG_STATUS <> 'C'      -- SUMLAUF 11-Apr-2012
                   AND AE.NU_CONTRATO(+) = 2754332
                   AND AE.CD_ITEM_CONTRATO = 10
           ) ENT/*,
           (
                SELECT NVL(SUM(PE.NU_QUANTIDADE_ENTREGUE),0) ENTREGUE_ORDEM_VENDA
                  FROM VND.PEDIDO PE
                 WHERE PE.NU_CONTRATO = P_NU_CONTRATO
                   AND PE.CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
                   AND PE.CD_SITUACAO_PEDIDO IN (20,25)
           ) ORD*/
     WHERE CO.CD_CONTRATO = IC.CD_CONTRATO
       AND CO.NU_CONTRATO = 2754332
       AND IC.CD_ITEM_CONTRATO = 10
       AND CO.IC_ATIVO = 'S'
       --AND (CO.CD_SITUACAO_CONTRATO IS NULL OR CO.CD_SITUACAO_CONTRATO <> 25)
       ;       
       
       
       
SELECT en.*, 
ae.*
  FROM CPT.AUTORIZACAO_ENTREGA AE,
       CPT.ENTREGA EN
 WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA(+)
   --AND EN.SG_STATUS(+) <> 'C' -- SUMLAUF 11-Apr-2012
   AND EN.SG_STATUS <> 'C'      -- SUMLAUF 11-Apr-2012
   AND AE.NU_CONTRATO(+) = 2754332
   AND AE.CD_ITEM_CONTRATO = 10    
   ;
   
    select 
    co.*, 
    ic.*  
   
      FROM VND.CONTRATO CO,
           VND.ITEM_CONTRATO IC
     WHERE CO.CD_CONTRATO = IC.CD_CONTRATO
       AND CO.NU_CONTRATO = 3067426
       AND IC.CD_ITEM_CONTRATO = 10
       AND CO.IC_ATIVO = 'S';  
   
    SELECT 
    co.nu_contrato_sap,
    co.nu_contrato,
    ic.cd_item_contrato,
    ic.nu_quantidade, 
    IC.NU_QTY_DELIVERED ,
    --IC.NU_QUANTIDADE,
    AUT.TOTAL,
    ENT.TOTAL,
    
    
    IC.NU_QUANTIDADE - (
              NVL(AUT.TOTAL, 0) +                                 -- Total requested by cooperative
              (NVL (/*ORD.ENTREGUE_ORDEM_VENDA */IC.NU_QTY_DELIVERED, 0) - NVL (ENT.TOTAL, 0)) -- Requested directly in SAP
           ) NU_QUANTIDADE_SALDO_bestalhado, 
           CO.*
           
     -- INTO RESULT
      FROM VND.CONTRATO CO,
           VND.ITEM_CONTRATO IC,
           (
                SELECT AUTORIZACOES.NU_CONTRATO, AUTORIZACOES.CD_ITEM_CONTRATO, NVL(SUM (AUTORIZACOES.QT_QUANTIDADE), 0) TOTAL
                  FROM (
                      SELECT distinct AE.*
                        FROM CPT.AUTORIZACAO_ENTREGA AE,
                             CPT.ENTREGA EN
                       WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA(+)
                         --AND EN.SG_STATUS(+) <> 'C' -- SUMLAUF 11-Apr-2012
                         AND EN.SG_STATUS <> 'C'      -- SUMLAUF 11-Apr-2012
                         --AND AE.NU_CONTRATO(+) = 3066378
                         --AND AE.CD_ITEM_CONTRATO = 10
                         --group by AE.NU_CONTRATO, AE.CD_ITEM_CONTRATO
                  ) AUTORIZACOES
                 group by AUTORIZACOES.NU_CONTRATO, AUTORIZACOES.CD_ITEM_CONTRATO
                  
           ) AUT,
           (
                SELECT ae.NU_CONTRATO, ae.CD_ITEM_CONTRATO, NVL(SUM (EN.QT_FORNECIDO), 0) TOTAL
                  FROM CPT.AUTORIZACAO_ENTREGA AE,
                       CPT.ENTREGA EN
                 WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA(+)
                   --AND EN.SG_STATUS(+) <> 'C' -- SUMLAUF 11-Apr-2012
                   AND EN.SG_STATUS <> 'C'      -- SUMLAUF 11-Apr-2012
                  -- AND AE.NU_CONTRATO(+) = 3066378
                 --  AND AE.CD_ITEM_CONTRATO = 10
                   group by ae.NU_CONTRATO, ae.CD_ITEM_CONTRATO
           ) ENT/*,
           (
                SELECT NVL(SUM(PE.NU_QUANTIDADE_ENTREGUE),0) ENTREGUE_ORDEM_VENDA
                  FROM VND.PEDIDO PE
                 WHERE PE.NU_CONTRATO = P_NU_CONTRATO
                   AND PE.CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
                   AND PE.CD_SITUACAO_PEDIDO IN (20,25)
           ) ORD*/
     WHERE CO.CD_CONTRATO = IC.CD_CONTRATO
      -- AND CO.NU_CONTRATO = 3071289
     --  AND IC.CD_ITEM_CONTRATO = 10
       and nvl(ic.nu_quantidade,0) - nvl(IC.NU_QTY_DELIVERED,0) > 0
       and co.cd_status_contrato = 8 
       and co.cd_situacao_contrato in (20)
       AND CO.IC_ATIVO = 'S'
       and co.nu_contrato = AUT.nu_contrato
       and ic.cd_item_contrato = aut.cd_item_contrato

       and co.nu_contrato = ent.nu_contrato
       and ic.cd_item_contrato = ent.cd_item_contrato       
       
       
       --AND (CO.CD_SITUACAO_CONTRATO IS NULL OR CO.CD_SITUACAO_CONTRATO <> 25)
       ;        
       
       
R102179VS1 74/0 REMESSA DE CONTA E ORDEM PROCESSADA   COPACOL NOVA AURORA 
  
R104412IO1 
       
WITH CTE_CONTRATO AS 
    (
    SELECT 
    co.nu_contrato_sap so_nu_contrato_sap,
    co.nu_contrato so_nu_contrato,
    ic.cd_item_contrato,
    ic.nu_quantidade, 
    NVL(IC.NU_QTY_DELIVERED,0) NU_QTY_DELIVERED ,
    NVL(AUT.TOTAL,0) AUTTOTAL,
    AUT.CD_AUTORIZACAO_ENTREGA AUT_CD_AUTORIZACAO,
    NVL(ENT.TOTAL,0) ENTTOTAL,
    ENT.CD_AUTORIZACAO_ENTREGA ENT_CD_AUTORIZACAO,
    
    
    IC.NU_QUANTIDADE - (
              NVL(AUT.TOTAL, 0) +                                 -- Total requested by cooperative
              (NVL (/*ORD.ENTREGUE_ORDEM_VENDA */IC.NU_QTY_DELIVERED, 0) - NVL (ENT.TOTAL, 0)) -- Requested directly in SAP
           ) NU_QUANTIDADE_SALDO_bestalhado, 
--           CO.*
    CO.CD_CONTRATO,  CO.CD_STATUS_CONTRATO, CO.CD_CLIENTE_CONTRATO,  CO.CD_TIPO_ORDEM,
    CO.CD_CENTRO_EXPEDIDOR, CO.DH_ASSINATURA, CO.DT_INICIO, CO.DT_FIM, CO.CD_INCOTERMS,       
    CO.DH_ULT_INTERFACE, CO.CD_BLOCKING_REASON, CO.CD_SITUACAO_CONTRATO,  
    CO.CD_BLOQUEIO_CREDITO, CO.CD_BLOQUEIO_ENTREGA, CO.CD_BLOQUEIO_FATURAMENTO, 
    CO.CD_BLOQUEIO_REMESSA, CO.DS_CREDIT_BLOCK_REASON           
           
     -- INTO RESULT
      FROM VND.CONTRATO CO
      inner join VND.ITEM_CONTRATO IC
      on CO.CD_CONTRATO = IC.CD_CONTRATO
      INNER JOIN VND.TIPO_ORDEM ORT
      ON 
      ORT.CD_DISTRIBUTION_CHANNEL = CO.CD_DISTRIBUTION_CHANNEL
      AND ORT.CD_SALES_DIVISION = CO.CD_SALES_DIVISION
      AND ORT.CD_SALES_ORG = CO.CD_SALES_ORG
      AND ORT.CD_TIPO_ORDEM = CO.CD_TIPO_CONTRATO
     -- AND ORT.IC_COOPERATIVE = 'S'
      left join (
                SELECT AUTORIZACOES.NU_CONTRATO, AUTORIZACOES.CD_ITEM_CONTRATO, NVL(SUM (AUTORIZACOES.QT_QUANTIDADE), 0) TOTAL,
                MAX(AUTORIZACOES.CD_AUTORIZACAO_ENTREGA) CD_AUTORIZACAO_ENTREGA
                  FROM (
                      SELECT distinct AE.*
                        FROM CPT.AUTORIZACAO_ENTREGA AE,
                             CPT.ENTREGA EN
                       WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA(+)
                         --AND EN.SG_STATUS(+) <> 'C' -- SUMLAUF 11-Apr-2012
                         AND EN.SG_STATUS <> 'C'      -- SUMLAUF 11-Apr-2012
                         --AND AE.NU_CONTRATO(+) = 3066378
                         --AND AE.CD_ITEM_CONTRATO = 10
                         --group by AE.NU_CONTRATO, AE.CD_ITEM_CONTRATO
                  ) AUTORIZACOES
                 group by AUTORIZACOES.NU_CONTRATO, AUTORIZACOES.CD_ITEM_CONTRATO
                  
           ) AUT
           on 
           co.nu_contrato = AUT.nu_contrato
           and ic.cd_item_contrato = aut.cd_item_contrato
           
           left join            
           (
                SELECT EED.NU_CONTRATO, EED.CD_ITEM_CONTRATO, SUM(EED.TOTAL) TOTAL, 0 CD_AUTORIZACAO_ENTREGA 
                FROM 
                (
                SELECT ae.NU_CONTRATO, ae.CD_ITEM_CONTRATO, 
                NVL((SELECT SUM(EN.QT_FORNECIDO) FORC
                FROM CPT.ENTREGA EN
                WHERE EN.CD_AUTORIZACAO_ENTREGA = AE.CD_AUTORIZACAO_ENTREGA
                AND EN.SG_STATUS <> 'C')
                , 0) TOTAL 
                
                  FROM CPT.AUTORIZACAO_ENTREGA AE
                  WHERE 
                 EXISTS (SELECT 1 FROM CPT.ENTREGA EN 
                 WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA 
                   AND EN.SG_STATUS <> 'C' 
                   )
                  -- AND AE.NU_CONTRATO(+) = 3066378
                 --  AND AE.CD_ITEM_CONTRATO = 10
                 ) EED
                   group by EED.NU_CONTRATO, EED.CD_ITEM_CONTRATO
           ) ENT
           on 
           co.nu_contrato = ent.nu_contrato
           and ic.cd_item_contrato = ent.cd_item_contrato 

     WHERE 1=1
       AND CO.NU_CONTRATO = 3069608
       AND IC.CD_ITEM_CONTRATO = 10
       and nvl(ic.nu_quantidade,0) - nvl(IC.NU_QTY_DELIVERED,0) >=0
       and co.cd_status_contrato = 8 
       and co.cd_situacao_contrato in (20)
       AND CO.IC_ATIVO = 'S'
       AND CO.DT_FIM BETWEEN CURRENT_DATE - 360 AND CURRENT_DATE + 360
       )

SELECT RESULT.* FROM CTE_CONTRATO RESULT
WHERE 
((RESULT.NU_QUANTIDADE - (RESULT.AUTTOTAL + RESULT.NU_QTY_DELIVERED - RESULT.ENTTOTAL   )) <> 0 AND 
ABS(NU_QUANTIDADE_SALDO_BESTALHADO) > 1)

AND ((RESULT.NU_QTY_DELIVERED <> 0 OR RESULT.ENTTOTAL <> 0) OR RESULT.NU_QTY_DELIVERED <> RESULT.ENTTOTAL )

;        
       

select * from vnd.pedido
where 
nu_contrato_sap = '0040127033'
and cd_item_contrato = '10'
and cd_situacao_pedido in (20, 25) ;


SELECT *
  FROM vnd.contrato
 WHERE 1 = 1 --and nu_contrato_sap is null and nu_contrato is null
             --and ic_ativo = 'S'
            -- and cd_agente_venda = '0040410004'
             --and dh_inclusao > current_date - 10
           -- and nu_contrato_sap IN( '0040408241')
             AND NU_CONTRATO IN ('3069608','993070980')
--and cd_contrato = 3254
;


SELECT *
  FROM vnd.item_contrato
 WHERE cd_contrato = 232914;
 
 select * from VND.SITUACAO_PEDIDO;


with cte_pedido as (
select nu_contrato_sap, nu_ordem_venda, max(dh_ult_interface) dhh 
from vnd.pedido
where cd_situacao_pedido in (5,10,15, 20) 
group by nu_contrato_sap, nu_ordem_venda

), 
cte_dup as (

select --nu_contrato_sap, cd_item_contrato, 
nu_ordem_venda, count(1)
from cte_pedido
group by nu_ordem_venda 
having count(1) > 1
), 
cte_porov as (

select 'porov' portipo, nu_contrato_sap, cd_item_contrato, nu_ordem_venda, cd_item_pedido, 
cd_centro_expedidor, nu_quantidade, nu_quantidade_saldo,
dh_ult_interface
 from vnd.pedido d
where 
exists (select 1 from cte_dup dup where dup.nu_ordem_venda = d.nu_ordem_venda)
)

select 'porov' portipo, nu_contrato_sap, cd_item_contrato, nu_ordem_venda, cd_item_pedido, cd_centro_expedidor, nu_quantidade, 
nu_quantidade_saldo, dh_ult_interface
from cte_porov

union
select 'porpo' portipo, nu_contrato_sap, cd_item_contrato, nu_ordem_venda, cd_item_pedido, cd_centro_expedidor, nu_quantidade, 
nu_quantidade_saldo, dh_ult_interface
 from vnd.pedido d
where 
exists (select 1 from cte_porov dup where dup.nu_contrato_sap = d.nu_contrato_sap)

order by nu_ordem_venda
; 




with cte_pedido as (
select nu_contrato_sap, nu_ordem_venda, max(dh_carteira) dhh 
from vnd.elo_carteira_sap
--where cd_situacao_pedido in (5,10,15, 20) 
where dh_carteira > current_date - 2
group by nu_contrato_sap, nu_ordem_venda

), 
cte_dup as (

select --nu_contrato_sap, cd_item_contrato, 
nu_ordem_venda, count(1)
from cte_pedido
group by nu_ordem_venda 
having count(1) > 1
), 
cte_porov as (

select 'porov' portipo, nu_contrato_sap, cd_item_contrato, nu_ordem_venda, cd_item_pedido, 
cd_centro_expedidor, nu_quantidade, nu_quantidade_saldo,
dh_ult_interface
 from vnd.pedido d
where 
exists (select 1 from cte_dup dup where dup.nu_ordem_venda = d.nu_ordem_venda)
)

select 'porov' portipo, nu_contrato_sap, cd_item_contrato, nu_ordem_venda, cd_item_pedido, cd_centro_expedidor, nu_quantidade, 
nu_quantidade_saldo, dh_ult_interface
from cte_porov

union
select 'porpo' portipo, nu_contrato_sap, cd_item_contrato, nu_ordem_venda, cd_item_pedido, cd_centro_expedidor, nu_quantidade, 
nu_quantidade_saldo, dh_ult_interface
 from vnd.pedido d
where 
exists (select 1 from cte_porov dup where dup.nu_contrato_sap = d.nu_contrato_sap)

order by nu_ordem_venda
; 





WITH CTE_CONTRATO AS 
    (
    SELECT 
    ORT.CD_TIPO_ORDEM, ORT.IC_COOPERATIVE , ORT.IC_SPLIT , ORT.SG_CATEGORY,
    co.nu_contrato_sap so_nu_contrato_sap,
    co.nu_contrato so_nu_contrato,
    ic.cd_item_contrato,
    ic.nu_quantidade, 
    --co.cd_contrato,
    
    NVL(IC.NU_QTY_DELIVERED,0) NU_QTY_DELIVERED ,

    
    
    IC.NU_QUANTIDADE - IC.NU_QTY_DELIVERED saldoa,
    CO.CD_CONTRATO,  CO.CD_STATUS_CONTRATO, CO.CD_CLIENTE_CONTRATO,  --CO.CD_TIPO_ORDEM,
    CO.CD_CENTRO_EXPEDIDOR, CO.DH_ASSINATURA, CO.DT_INICIO, CO.DT_FIM, CO.CD_INCOTERMS,       
    CO.DH_ULT_INTERFACE, CO.CD_BLOCKING_REASON, CO.CD_SITUACAO_CONTRATO,  
    CO.CD_BLOQUEIO_CREDITO, CO.CD_BLOQUEIO_ENTREGA, CO.CD_BLOQUEIO_FATURAMENTO, 
    CO.CD_BLOQUEIO_REMESSA, CO.DS_CREDIT_BLOCK_REASON           
           
     -- INTO RESULT
      FROM VND.CONTRATO CO
      inner join VND.ITEM_CONTRATO IC
      on CO.CD_CONTRATO = IC.CD_CONTRATO
      INNER JOIN VND.TIPO_ORDEM ORT
      ON 
      ORT.CD_DISTRIBUTION_CHANNEL = CO.CD_DISTRIBUTION_CHANNEL
      AND ORT.CD_SALES_DIVISION = CO.CD_SALES_DIVISION
      AND ORT.CD_SALES_ORG = CO.CD_SALES_ORG
      AND ORT.CD_TIPO_ORDEM = CO.CD_TIPO_CONTRATO
      where 1=1
       and exists (select 1 
                from vnd.desdobramento dd 
                where dd.cd_contrato = ic.cd_contrato and dd.cd_item_contrato = ic.cd_item_contrato
                --and dd.ic_ativo = 'S'-- AND dd.sg_status in ('P')
                )
       and nvl(ic.nu_quantidade,0) - nvl(IC.NU_QTY_DELIVERED,0) > 0
       and co.cd_status_contrato = 8 
       and co.cd_situacao_contrato in (20)
       AND CO.IC_ATIVO = 'S'
       AND CO.DT_FIM BETWEEN CURRENT_DATE - 360 AND CURRENT_DATE + 360
            
      
)
select 
--coc.*,
coc.so_nu_contrato_sap, 
dd.*, 
ped.* 
from  CTE_CONTRATO  coc
left join vnd.desdobramento dd
on coc.cd_contrato = dd.cd_contrato 
and coc.cd_item_contrato = dd.cd_item_contrato  

left join vnd.pedido ped
on 
ped.nu_contrato_sap = coc.so_nu_contrato_sap
and ped.cd_item_contrato = coc.cd_item_contrato 
and ped.nu_ordem_venda = dd.nu_ordem_venda
and ped.cd_situacao_pedido <> 90

--where 
--ped.nu_ordem_venda is null

where 
exists (

select 1 from (

select pefg.nu_contrato_sap, pefg.cd_item_contrato, sum(pefg.nu_quantidade) quant
from vnd.pedido pefg
where 
pefg.cd_situacao_pedido <> 90
and exists (select 1 from CTE_CONTRATO cox
where 
pefg.nu_contrato_sap = cox.so_nu_contrato_sap
and pefg.cd_item_contrato = cox.cd_item_contrato
)

group by 
pefg.nu_contrato_sap, pefg.cd_item_contrato

) dg
where 
dg.nu_contrato_sap = coc.so_nu_contrato_sap
and dg.cd_item_contrato = coc.cd_item_contrato
and nvl(dg.quant,0) - nvl(coc.NU_QUANTIDADE,0)  > 10)

;

