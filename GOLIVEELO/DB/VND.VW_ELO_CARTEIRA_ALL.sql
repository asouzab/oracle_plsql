DROP VIEW VND.VW_ELO_CARTEIRA_ALL;

/* Formatted on 09/05/2018 12:25:11 (QP5 v5.318) */
CREATE OR REPLACE FORCE VIEW VND.VW_ELO_CARTEIRA_ALL
(
    CD_ELO_CARTEIRA,
    CD_ELO_AGENDAMENTO_ITEM,
    CD_CENTRO_EXPEDIDOR,
    DS_CENTRO_EXPEDIDOR,
    DH_CARTEIRA,
    CD_SALES_ORG,
    NU_CONTRATO_SAP,
    CD_TIPO_CONTRATO,
    NU_CONTRATO_SUBSTITUI,
    DT_PAGO,
    NU_CONTRATO,
    NU_ORDEM_VENDA,
    IC_SEM_ORDEM_VENDA,
    DS_STATUS_CONTRATO_SAP,
    CD_CLIENTE,
    NO_CLIENTE,
    CD_INCOTERMS,
    CD_SALES_DISTRICT,
    CD_SALES_OFFICE,
    NO_SALES_OFFICE,
    CD_SALES_GROUP,
    NO_SALES_GROUP,
    CD_AGENTE_VENDA,
    NO_AGENTE,
    DH_VENCIMENTO_PEDIDO,
    DT_CREDITO,
    DT_INICIO,
    DT_FIM,
    DH_INCLUSAO,
    DH_ENTREGA,
    SG_ESTADO,
    NO_MUNICIPIO,
    DS_BAIRRO,
    CD_PRODUTO_SAP,
    NO_PRODUTO_SAP,
    QT_PROGRAMADA,
    QT_ENTREGUE,
    QT_SALDO,
    VL_UNITARIO,
    VL_BRL,
    VL_TAXA_DOLAR,
    VL_USD,
    PC_COMISSAO,
    CD_SACARIA,
    DS_SACARIA,
    CD_CULTURA_SAP,
    DS_CULTURA_SAP,
    CD_BLOQUEIO_REMESSA,
    CD_BLOQUEIO_FATURAMENTO,
    CD_BLOQUEIO_CREDITO,
    CD_BLOQUEIO_REMESSA_ITEM,
    CD_BLOQUEIO_FATURAMENTO_ITEM,
    CD_MOTIVO_RECUSA,
    CD_LOGIN,
    CD_SEGMENTACAO_CLIENTE,
    DS_SEGMENTACAO_CLIENTE,
    DS_SEGMENTO_CLIENTE_SAP,
    CD_FORMA_PAGAMENTO,
    CD_TIPO_PAGAMENTO,
    DS_TIPO_PAGAMENTO,
    CD_AGRUPAMENTO,
    CD_BLOQUEIO_ENTREGA,
    NU_CNPJ,
    NU_CPF,
    NU_INSCRICAO_ESTADUAL,
    NU_INSCRICAO_MUNICIPAL,
    NU_CEP,
    DS_ENDERECO_RECEBEDOR,
    CD_CLIENTE_RECEBEDOR,
    NO_CLIENTE_RECEBEDOR,
    CD_MOEDA,
    CD_SUPPLY_GROUP,
    DS_VENDA_COMPARTILHADA,
    CD_STATUS_LIBERACAO,
    CD_ITEM_PEDIDO,
    CD_CLIENTE_PAGADOR,
    NO_CLIENTE_PAGADOR,
    IC_RELACIONAMENTO,
    NU_ORDEM,
    QT_AGENDADA,
    QT_AGENDADA_FABRICA,
    QT_AGENDADA_SAP,
    CD_USUARIO_REFRESH,
    DH_REFRESH,
    QT_PROGRAMADA_REFRESH,
    QT_ENTREGUE_REFRESH,
    QT_SALDO_REFRESH,
    QT_AGENDADA_CONFIRMADA,
    CD_TIPO_AGENDAMENTO,
    CD_TIPO_REPLAN,
    CD_BLOQUEIO_REMESSA_R,
    CD_BLOQUEIO_FATURAMENTO_R,
    CD_BLOQUEIO_CREDITO_R,
    CD_BLOQUEIO_REMESSA_ITEM_R,
    CD_BLOQUEIO_FATURAMENTO_ITEM_R,
    DS_OBSERVACAO_ADVEN,
    IC_PERMITIR_CS,
    DH_LIBERACAO_TORRE_FRETES,
    DH_MODIFICACAO_TORRE_FRETES,
    DH_CONTRATACAO_TORRE_FRETES,
    CD_ELO_FREIGHT_TOWER_REASON,
    VL_FRETE_CONTRATADO,
    IC_NAO_LIBERADA_SEM_PROTOCOLO,
    IC_ENTREGA_CADENCIADA_CLIENTE,
    IC_DIFICULDADE_CONTRATACAO,
    IC_OUTROS,
    CD_STATUS_CUSTOMER_SERVICE,
    CD_STATUS_TORRE_FRETES,
    CD_STATUS_CONTROLADORIA,
    IC_ATIVO,
    CD_GRUPO_EMBALAGEM,
    DS_CREDIT_BLOCK_REASON,
    DH_CREDIT_BLOCK,
    SG_DESTINO_BACKLOG_CIF,
    CD_STATUS_BACKLOG_CIF,
    QT_AGENDADA_ANTERIOR,
    DH_BACKLOG_CIF,
    QT_BACKLOG_CIF,
    CD_ELO_AGENDAMENTO,
    QT_AGENDADA_REFRESH,
    CD_USUARIO_FABRICA,
    DH_FABRICA,
    CD_USUARIO_CORTADO_FABRICA,
    DH_CORTADO_FABRICA,
    CD_USUARIO_AJUSTE_SAP,
    DH_AJUSTE_SAP,
    CD_ITEM_CONTRATO,
    CD_STATUS_LOGISTICA,
    IC_CORTADO_FABRICA,
    IC_COOPERATIVE,
    IC_SPLIT,
    IC_EMERGENCIAL,
    DS_ROTEIRO_ENTREGA,
    CD_ELO_PRIORITY_OPTION,
    QT_AJUSTADA_FABRICA,
    QT_AJUSTADA_SAP,
    IC_FA,
    CD_CENTRO_EXPEDIDOR_FABRICA,
    DS_CENTRO_EXPEDIDOR_FABRICA,
    NU_ORDEM_VENDA_FABRICA,
    DH_REPLAN,
    CD_STATUS_REPLAN,
    CD_ELO_AGENDAMENTO_REPLAN,
    VL_FRETE_DISTRIBUICAO,
    CD_MOTIVO_RECUSA_REFRESH,
    IC_EXPORT,
    DS_CREDIT_BLOCK_REASON_R,
    CD_STATUS_CEL_INITIAL,
    CD_STATUS_CEL_FINAL,
    DS_ENDERECO_PAGADOR,
    NO_SALES_DISTRICT,
    DS_OBSERVACAO_TORRE_FRETES,
    QT_AGENDADA_CELULA,
    DH_MODIFICACAO_CELL_ATT,
    CD_USUARIO_MODIF_CELL_ATT,
    NU_PROTOCOLO,
    QT_AGENDADA_PROTOCOLO,
    NU_PROTOCOLO_ENTREGA,
    CD_ELO_CARTEIRA_GROUPING,
    CD_ELO_CARTEIRA_ANTIGO,
    DS_CAPACIDADE,
    QT_EMERGENCIAL
)
AS
    SELECT CD_ELO_CARTEIRA,
           CD_ELO_AGENDAMENTO_ITEM,
           CD_CENTRO_EXPEDIDOR,
           DS_CENTRO_EXPEDIDOR,
           DH_CARTEIRA,
           CD_SALES_ORG,
           NU_CONTRATO_SAP,
           CD_TIPO_CONTRATO,
           NU_CONTRATO_SUBSTITUI,
           DT_PAGO,
           NU_CONTRATO,
           CASE
               WHEN NVL (TRIM (NU_ORDEM_VENDA), '0') = '0' THEN 'X'
               ELSE NU_ORDEM_VENDA
           END
               NU_ORDEM_VENDA,
           IC_SEM_ORDEM_VENDA,
           DS_STATUS_CONTRATO_SAP,
           CD_CLIENTE,
           NO_CLIENTE,
           CD_INCOTERMS,
           CD_SALES_DISTRICT,
           CD_SALES_OFFICE,
           NO_SALES_OFFICE,
           CD_SALES_GROUP,
           NO_SALES_GROUP,
           CD_AGENTE_VENDA,
           NO_AGENTE,
           DH_VENCIMENTO_PEDIDO,
           DT_CREDITO,
           DT_INICIO,
           DT_FIM,
           DH_INCLUSAO,
           DH_ENTREGA,
           SG_ESTADO,
           NO_MUNICIPIO,
           DS_BAIRRO,
           CD_PRODUTO_SAP,
           NO_PRODUTO_SAP,
           QT_PROGRAMADA,
           QT_ENTREGUE,
           QT_SALDO,
           VL_UNITARIO,
           VL_BRL,
           VL_TAXA_DOLAR,
           VL_USD,
           PC_COMISSAO,
           CD_SACARIA,
           DS_SACARIA,
           CD_CULTURA_SAP,
           DS_CULTURA_SAP,
           CD_BLOQUEIO_REMESSA,
           CD_BLOQUEIO_FATURAMENTO,
           CD_BLOQUEIO_CREDITO,
           CD_BLOQUEIO_REMESSA_ITEM,
           CD_BLOQUEIO_FATURAMENTO_ITEM,
           CD_MOTIVO_RECUSA,
           CD_LOGIN,
           CD_SEGMENTACAO_CLIENTE,
           DS_SEGMENTACAO_CLIENTE,
           DS_SEGMENTO_CLIENTE_SAP,
           CD_FORMA_PAGAMENTO,
           CD_TIPO_PAGAMENTO,
           DS_TIPO_PAGAMENTO,
           CD_AGRUPAMENTO,
           CD_BLOQUEIO_ENTREGA,
           NU_CNPJ,
           NU_CPF,
           NU_INSCRICAO_ESTADUAL,
           NU_INSCRICAO_MUNICIPAL,
           NU_CEP,
           DS_ENDERECO_RECEBEDOR,
           CD_CLIENTE_RECEBEDOR,
           NO_CLIENTE_RECEBEDOR,
           CD_MOEDA,
           CD_SUPPLY_GROUP,
           DS_VENDA_COMPARTILHADA,
           CD_STATUS_LIBERACAO,
           CD_ITEM_PEDIDO,
           CD_CLIENTE_PAGADOR,
           NO_CLIENTE_PAGADOR,
           IC_RELACIONAMENTO,
           NU_ORDEM,
           QT_AGENDADA,
           QT_AGENDADA_FABRICA,
           QT_AGENDADA_SAP,
           CD_USUARIO_REFRESH,
           DH_REFRESH,
           QT_PROGRAMADA_REFRESH,
           QT_ENTREGUE_REFRESH,
           QT_SALDO_REFRESH,
           QT_AGENDADA_CONFIRMADA,
           CD_TIPO_AGENDAMENTO,
           CD_TIPO_REPLAN,
           CD_BLOQUEIO_REMESSA_R,
           CD_BLOQUEIO_FATURAMENTO_R,
           CD_BLOQUEIO_CREDITO_R,
           CD_BLOQUEIO_REMESSA_ITEM_R,
           CD_BLOQUEIO_FATURAMENTO_ITEM_R,
           DS_OBSERVACAO_ADVEN,
           IC_PERMITIR_CS,
           DH_LIBERACAO_TORRE_FRETES,
           DH_MODIFICACAO_TORRE_FRETES,
           DH_CONTRATACAO_TORRE_FRETES,
           CD_ELO_FREIGHT_TOWER_REASON,
           VL_FRETE_CONTRATADO,
           IC_NAO_LIBERADA_SEM_PROTOCOLO,
           IC_ENTREGA_CADENCIADA_CLIENTE,
           IC_DIFICULDADE_CONTRATACAO,
           IC_OUTROS,
           CASE
               WHEN     CD_STATUS_CUSTOMER_SERVICE IS NULL
                    AND DH_LIBERACAO_TORRE_FRETES IS NOT NULL
                    AND CD_INCOTERMS = 'CIF'
               THEN
                   12
               WHEN     CD_STATUS_CUSTOMER_SERVICE IS NULL
                    AND CD_STATUS_CEL_FINAL = 59
                    AND CD_INCOTERMS = 'CIF'
                    AND DH_LIBERACAO_TORRE_FRETES IS NULL
               THEN
                   10
               WHEN (    CD_TIPO_AGENDAMENTO = 25
                     AND CD_STATUS_REPLAN = 32
                     AND CD_INCOTERMS = 'CIF'
                     AND CD_STATUS_CUSTOMER_SERVICE IS NULL
                     AND CD_STATUS_CEL_FINAL IS NOT NULL
                     AND DH_LIBERACAO_TORRE_FRETES IS NULL)
               THEN
                   10
               WHEN     CD_STATUS_CUSTOMER_SERVICE IS NULL
                    AND CD_STATUS_CEL_FINAL IS NOT NULL
                    AND CD_INCOTERMS = 'CIF'
               THEN
                   10
               ELSE
                   CD_STATUS_CUSTOMER_SERVICE
           END
               CD_STATUS_CUSTOMER_SERVICE,
           CD_STATUS_TORRE_FRETES,
           CD_STATUS_CONTROLADORIA,
           IC_ATIVO,
           CD_GRUPO_EMBALAGEM,
           DS_CREDIT_BLOCK_REASON,
           DH_CREDIT_BLOCK,
           SG_DESTINO_BACKLOG_CIF,
           CD_STATUS_BACKLOG_CIF,
           QT_AGENDADA_ANTERIOR,
           DH_BACKLOG_CIF,
           QT_BACKLOG_CIF,
           CD_ELO_AGENDAMENTO,
           QT_AGENDADA_REFRESH,
           CD_USUARIO_FABRICA,
           DH_FABRICA,
           CD_USUARIO_CORTADO_FABRICA,
           DH_CORTADO_FABRICA,
           CD_USUARIO_AJUSTE_SAP,
           DH_AJUSTE_SAP,
           CD_ITEM_CONTRATO,
           CD_STATUS_LOGISTICA,
           IC_CORTADO_FABRICA,
           IC_COOPERATIVE,
           IC_SPLIT,
           IC_EMERGENCIAL,
           DS_ROTEIRO_ENTREGA,
           CD_ELO_PRIORITY_OPTION,
           QT_AJUSTADA_FABRICA,
           QT_AJUSTADA_SAP,
           IC_FA,
           CD_CENTRO_EXPEDIDOR_FABRICA,
           DS_CENTRO_EXPEDIDOR_FABRICA,
           NU_ORDEM_VENDA_FABRICA,
           DH_REPLAN,
           CD_STATUS_REPLAN,
           CD_ELO_AGENDAMENTO_REPLAN,
           VL_FRETE_DISTRIBUICAO,
           CD_MOTIVO_RECUSA_REFRESH,
           IC_EXPORT,
           DS_CREDIT_BLOCK_REASON_R,
           CD_STATUS_CEL_INITIAL,
           CD_STATUS_CEL_FINAL,
           DS_ENDERECO_PAGADOR,
           NO_SALES_DISTRICT,
           DS_OBSERVACAO_TORRE_FRETES,
           QT_AGENDADA_CELULA,
           DH_MODIFICACAO_CELL_ATT,
           CD_USUARIO_MODIF_CELL_ATT,
           NU_PROTOCOLO,
           QT_AGENDADA_PROTOCOLO,
           NU_PROTOCOLO_ENTREGA,
           CD_ELO_CARTEIRA_GROUPING,
           CD_ELO_CARTEIRA_ANTIGO,
           DS_CAPACIDADE,
           QT_EMERGENCIAL
      FROM VND.ELO_CARTEIRA CT
     WHERE CT.QT_AGENDADA_CONFIRMADA > 0;


GRANT SELECT ON VND.VW_ELO_CARTEIRA_ALL TO VND_SEC;