WITH MY AS (
SELECT * FROM VND.ELO_CARTEIRA_SAP S
WHERE S.DH_CARTEIRA > SYSDATE - 7000
AND 
(EXISTS (SELECT 1 FROM VND.ELO_CARTEIRA_SAP X 
WHERE S.NU_CARTEIRA_VERSION = X.NU_CARTEIRA_VERSION AND NU_ORDEM_VENDA IS NULL 
)
AND 
(EXISTS (SELECT 1 FROM VND.ELO_CARTEIRA_SAP DU
WHERE S.NU_CARTEIRA_VERSION = DU.NU_CARTEIRA_VERSION
AND DU.NU_ORDEM_VENDA IS NOT NULL 
GROUP BY DU.NU_CONTRATO_SAP, DU.CD_ITEM_CONTRATO, DU.NU_ORDEM_VENDA
HAVING COUNT(1) > 1 
))
) 
),
CTE_DUP AS (

SELECT NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, COUNT(1) FROM
(

SELECT NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, MAX(NU_ORDEM_VENDA) NU_ORDEM_VENDA
FROM MY
WHERE NU_ORDEM_VENDA IS NOT NULL 
GROUP BY NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO
UNION 
SELECT NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, NU_ORDEM_VENDA
FROM MY
WHERE NU_ORDEM_VENDA IS NULL 
GROUP BY NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, NU_ORDEM_VENDA
) 
GROUP BY 
NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO
HAVING COUNT(1) > 1 
)

/*
'INSERT INTO VND.ELO_CARTEIRA_SAP_AGEND_TMP
(CD_ELO_CARTEIRA_SAP,
       NU_CARTEIRA_VERSION,
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
       VL_FRETE_DISTRIBUICAO,
       CD_GRUPO_EMBALAGEM,
       DS_CREDIT_BLOCK_REASON,
       DH_CREDIT_BLOCK,
       CD_ITEM_CONTRATO,
       DS_ROTEIRO_ENTREGA,
       DS_ENDERECO_PAGADOR,
       NO_SALES_DISTRICT
)'
*/  

select 
/*
SELECT 'SELECT ' || CHR(39) || CD_ELO_CARTEIRA_SAP || CHR(39) || ','
 || CHR(39) ||        NU_CARTEIRA_VERSION || CHR(39) || ','
 || CHR(39) ||        CD_CENTRO_EXPEDIDOR || CHR(39) || ','
 || CHR(39) ||        DS_CENTRO_EXPEDIDOR || CHR(39) || ','
        || CHR(39) || DH_CARTEIRA || CHR(39) || ','
        || CHR(39) || CD_SALES_ORG || CHR(39) || ','
        || CHR(39) || NU_CONTRATO_SAP || CHR(39) || ','
        || CHR(39) || CD_TIPO_CONTRATO || CHR(39) || ','
        || CHR(39) || NU_CONTRATO_SUBSTITUI || CHR(39) || ','
        || CHR(39) || DT_PAGO || CHR(39) || ','
        || CHR(39) || NU_CONTRATO || CHR(39) || ','
        || CHR(39) || NU_ORDEM_VENDA || CHR(39) || ','
        || CHR(39) || DS_STATUS_CONTRATO_SAP || CHR(39) || ','
        || CHR(39) || CD_CLIENTE || CHR(39) || ','
        || CHR(39) || NO_CLIENTE || CHR(39) || ','
        || CHR(39) || CD_INCOTERMS || CHR(39) || ','
        || CHR(39) || CD_SALES_DISTRICT || CHR(39) || ','
        || CHR(39) || CD_SALES_OFFICE || CHR(39) || ','
        || CHR(39) || NO_SALES_OFFICE || CHR(39) || ','
        || CHR(39) || CD_SALES_GROUP || CHR(39) || ','
        || CHR(39) || NO_SALES_GROUP || CHR(39) || ','
        || CHR(39) || CD_AGENTE_VENDA || CHR(39) || ','
        || CHR(39) || NO_AGENTE || CHR(39) || ','
        || CHR(39) || DH_VENCIMENTO_PEDIDO || CHR(39) || ','
        || CHR(39) || DT_CREDITO || CHR(39) || ','
        || CHR(39) || DT_INICIO || CHR(39) || ','
        || CHR(39) || DT_FIM || CHR(39) || ','
        || CHR(39) || DH_INCLUSAO || CHR(39) || ','
        || CHR(39) || DH_ENTREGA || CHR(39) || ','
        || CHR(39) || SG_ESTADO || CHR(39) || ','
        || CHR(39) || NO_MUNICIPIO || CHR(39) || ','
        || CHR(39) || DS_BAIRRO || CHR(39) || ','
        || CHR(39) || CD_PRODUTO_SAP || CHR(39) || ','
        || CHR(39) || NO_PRODUTO_SAP || CHR(39) || ','
        || CHR(39) || QT_PROGRAMADA || CHR(39) || ','
        || CHR(39) || QT_ENTREGUE || CHR(39) || ','
        || CHR(39) || QT_SALDO || CHR(39) || ','
        || CHR(39) || VL_UNITARIO || CHR(39) || ','
        || CHR(39) || VL_BRL || CHR(39) || ','
        || CHR(39) || VL_TAXA_DOLAR || CHR(39) || ','
        || CHR(39) || VL_USD || CHR(39) || ','
        || CHR(39) || PC_COMISSAO || CHR(39) || ','
        || CHR(39) || CD_SACARIA || CHR(39) || ','
        || CHR(39) || DS_SACARIA || CHR(39) || ','
        || CHR(39) || CD_CULTURA_SAP || CHR(39) || ','
        || CHR(39) || DS_CULTURA_SAP || CHR(39) || ','
        || CHR(39) || CD_BLOQUEIO_REMESSA || CHR(39) || ','
        || CHR(39) || CD_BLOQUEIO_FATURAMENTO || CHR(39) || ','
        || CHR(39) || CD_BLOQUEIO_CREDITO || CHR(39) || ','
        || CHR(39) || CD_BLOQUEIO_REMESSA_ITEM || CHR(39) || ','
        || CHR(39) || CD_BLOQUEIO_FATURAMENTO_ITEM || CHR(39) || ','
        || CHR(39) || CD_MOTIVO_RECUSA || CHR(39) || ','
        || CHR(39) || CD_LOGIN || CHR(39) || ','
        || CHR(39) || CD_SEGMENTACAO_CLIENTE || CHR(39) || ','
        || CHR(39) || DS_SEGMENTACAO_CLIENTE || CHR(39) || ','
        || CHR(39) || DS_SEGMENTO_CLIENTE_SAP || CHR(39) || ','
        || CHR(39) || CD_FORMA_PAGAMENTO || CHR(39) || ','
        || CHR(39) || CD_TIPO_PAGAMENTO || CHR(39) || ','
        || CHR(39) || DS_TIPO_PAGAMENTO || CHR(39) || ','
        || CHR(39) || CD_AGRUPAMENTO || CHR(39) || ','
        || CHR(39) || CD_BLOQUEIO_ENTREGA || CHR(39) || ','
        || CHR(39) || NU_CNPJ || CHR(39) || ','
        || CHR(39) || NU_CPF || CHR(39) || ','
        || CHR(39) || NU_INSCRICAO_ESTADUAL || CHR(39) || ','
        || CHR(39) || NU_INSCRICAO_MUNICIPAL || CHR(39) || ','
        || CHR(39) || NU_CEP || CHR(39) || ','
        || CHR(39) || DS_ENDERECO_RECEBEDOR || CHR(39) || ','
        || CHR(39) || CD_CLIENTE_RECEBEDOR || CHR(39) || ','
        || CHR(39) || NO_CLIENTE_RECEBEDOR || CHR(39) || ','
        || CHR(39) || CD_MOEDA || CHR(39) || ','
        || CHR(39) || CD_SUPPLY_GROUP || CHR(39) || ','
        || CHR(39) || DS_VENDA_COMPARTILHADA || CHR(39) || ','
        || CHR(39) || CD_STATUS_LIBERACAO || CHR(39) || ','
        || CHR(39) || CD_ITEM_PEDIDO || CHR(39) || ','
        || CHR(39) || CD_CLIENTE_PAGADOR || CHR(39) || ','
        || CHR(39) || NO_CLIENTE_PAGADOR || CHR(39) || ','
        || CHR(39) || VL_FRETE_DISTRIBUICAO || CHR(39) || ','
        || CHR(39) || CD_GRUPO_EMBALAGEM || CHR(39) || ','
        || CHR(39) || DS_CREDIT_BLOCK_REASON || CHR(39) || ','
        || CHR(39) || DH_CREDIT_BLOCK || CHR(39) || ','
        || CHR(39) || CD_ITEM_CONTRATO || CHR(39) || ','
        || CHR(39) || DS_ROTEIRO_ENTREGA || CHR(39) || ','
        || CHR(39) || DS_ENDERECO_PAGADOR || CHR(39) || ','
        || CHR(39) || NO_SALES_DISTRICT || CHR(39) || ' FROM DUAL UNION ' || CHR(13) || CHR(10)
        
*/        
distinct sa.nu_carteira_version        

 FROM VND.ELO_CARTEIRA_SAP SA 
where 
exists (select 1 from CTE_DUP DD
where  
SA.NU_CARTEIRA_VERSION = DD.NU_CARTEIRA_VERSION)
AND ROWNUM < 100
;


--SELECT CHR(13) || CHR(10) FROM DUAL;


select * from vnd.elo_carteira_sap where nu_carteira_version = '20180116030024';

select * from vnd.elo_agendamento where nu_carteira_version = '20180116030024';


