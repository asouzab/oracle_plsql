
SELECT 
--LADOfora.* 
LADOfora.NU_CONTRATO, ladofora.nu_contrato_sap, 
cd_item_contrato, cd_produto_sap, saldoporitem,
saldoitem, qtdeitem, dt_inicio, dt_fim, cd_incoterms, DH_ULT_INTERFACE


FROM (
SELECT 

            (select sum(nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0))
            from vnd.item_contrato ic 
            where ic.cd_contrato = cont.cd_contrato 
            and contrai.cd_item_contrato = ic.cd_item_contrato
            )  saldoitem,
            
            (select case when sum(nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0)) < 1 
            then 'menor1:' || 0 || ' bom:' ||   max(ic.cd_produto_sap)  
            else 'maior1:' || count(1) || ' bom:' || min(ic.cd_produto_sap) end
            from vnd.item_contrato ic 
            where ic.cd_contrato = cont.cd_contrato 
            and contrai.cd_item_contrato = ic.cd_item_contrato
            )  qtdeitem,            
            
            contrai.cd_item_contrato,
            contrai.cd_produto_sap,
            nvl(contrai.NU_QUANTIDADE,0) - nvl(contrai.NU_QTY_DELIVERED,0) saldoporitem,

CONT.CD_CONTRATO,        CONT.NU_CONTRATO,        CONT.CD_STATUS_CONTRATO,
       CONT.CD_CLIENTE_CONTRATO,       -- CONT.CD_CLIENTE_EMISSOR,        CONT.CD_TIPO_ORDEM,
       CONT.CD_CENTRO_EXPEDIDOR,        --CONT.CD_USUARIO_VENDA,        CONT.CD_AGENTE_VENDA,
      -- CONT.CD_USUARIO_INCLUSAO,        CONT.DH_INCLUSAO,        CONT.DH_GERACAO,
     --  CONT.DH_IMPRESSAO,        CONT.DH_ASSINATURA,        CONT.DH_ENVIO_ADVEN,
     --  CONT.DH_ENVIO_SAP,        CONT.DH_PROCESSAMENTO,        CONT.DT_PAGAMENTO,
    --   CONT.DS_FORMA_PAGAMENTO,        CONT.DS_COND_ESP_PAGTO,       
     CONT.DT_INICIO,        CONT.DT_FIM,  
       --      CONT.VL_FRETE_DISTRIBUICAO,       
       CONT.IC_ATIVO,
    --   CONT.CD_MOTIVO_ORDEM,        CONT.IC_ALTERA_SUBSTITUI,        CONT.DH_LISTA_PRECO,
       CONT.CD_INCOTERMS,       
       -- CONT.DS_GARANTIAS,        CONT.DH_PRAZO_GARANTIA,
     --  CONT.VL_FACIL,        
       CONT.CD_SALES_ORG,        CONT.CD_DISTRIBUTION_CHANNEL,
       CONT.CD_SALES_DIVISION,        --CONT.IC_NEW_PRODUCT,        CONT.IC_NEW_CUSTOMER,
       CONT.IC_SIGNED,       
        CONT.IC_SAP_READY,        CONT.DH_NEW_PRODUCT,
       --CONT.DH_NEW_CUSTOMER,        CONT.DH_SAP_READY,        CONT.DH_EMAIL_MASTERDATA,
       --CONT.DH_EMAIL_ADVEN,      
        CONT.NU_CONTRATO_SAP,       -- CONT.CD_TIPO_CONTRATO,
       --CONT.DH_CANCELAMENTO,        CONT.CD_USUARIO_CANCELAMENTO,       
        CONT.DH_ULT_INTERFACE,
       CONT.CD_BLOCKING_REASON,        CONT.CD_SITUACAO_CONTRATO,       -- CONT.CD_FORMA_PAGAMENTO,
      -- CONT.IC_SAP,        CONT.CD_STATUS_CONTRATO_SAP,        CONT.CD_USUARIO_RECEBIMENTO,
      -- CONT.DH_RECEBIMENTO,        CONT.IC_RECEBIDO,        CONT.DH_ULT_ALTERACAO,
     --  CONT.IC_ORIGEM_CONTRATO,        CONT.CD_TIPO_PAGAMENTO,        CONT.CD_CLIENTE_PO_NUMERO,
     --  CONT.DH_ENVIO_ASSINATURA,        CONT.DH_REENVIO_ASSINATURA,       CONT.CD_USUARIO_APROVACAO_CLIENTE,
     --  CONT.CD_USUARIO_REJEICAO_CLIENTE,        CONT.CD_USUARIO_REJEICAO_SUPERVISOR,
     --  CONT.DH_APROVACAO_CLIENTE,        CONT.DH_REJEICAO_CLIENTE,        CONT.DH_REJEICAO_SUPERVISOR,
     --  CONT.IC_ASSINATURA_ELETRONICA,        CONT.CD_USUARIO_APROVACAO_SUPERV,
     --  CONT.DH_APROVACAO_SUPERVISOR,       
        CONT.CD_BLOQUEIO_CREDITO,        CONT.CD_BLOQUEIO_ENTREGA,
       CONT.CD_BLOQUEIO_FATURAMENTO,        CONT.CD_BLOQUEIO_REMESSA,        CONT.DS_CREDIT_BLOCK_REASON
  FROM VND.CONTRATO CONT 
  inner join vnd.item_contrato contrai on cont.cd_contrato = contrai.cd_contrato
 WHERE CONT.IC_ATIVO = 'S'
and exists (select 1 
            from vnd.item_contrato ic 
            where ic.cd_contrato = cont.cd_contrato 
            and nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) <1
            and (nvl(ic.ic_recusado, 'N') = 'N' OR ic.CD_MOTIVO_RECUSA IS NULL))
AND  CONT.CD_STATUS_CONTRATO = '8' 
AND CONT.CD_SITUACAO_CONTRATO IN (20) 
--AND TRUNC(NVL(cont.dt_fim, CURRENT_DATE), 'YEAR') > trunc(current_date - 400, 'YEAR')

) LADOfora
  
