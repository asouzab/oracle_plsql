 

CREATE GLOBAL TEMPORARY TABLE VND.ELO_CARTEIRA_SAP_AGEND_TMP
(
  
  SESSION_ID NUMBER(9)           NOT NULL ,
  CD_ELO_CARTEIRA_SAP           NUMBER(9)       NOT NULL,
  NU_CARTEIRA_VERSION           VARCHAR2(14 BYTE) NOT NULL,
  CD_CENTRO_EXPEDIDOR           CHAR(4 BYTE),
  DS_CENTRO_EXPEDIDOR           VARCHAR2(31 BYTE),
  DH_CARTEIRA                   DATE,
  CD_SALES_ORG                  CHAR(4 BYTE),
  NU_CONTRATO_SAP               CHAR(10 BYTE),
  CD_TIPO_CONTRATO              CHAR(4 BYTE),
  NU_CONTRATO_SUBSTITUI         VARCHAR2(10 BYTE),
  DT_PAGO                       DATE,
  NU_CONTRATO                   NUMBER(10),
  NU_ORDEM_VENDA                CHAR(10 BYTE),
  DS_STATUS_CONTRATO_SAP        CHAR(20 BYTE),
  CD_CLIENTE                    VARCHAR2(11 BYTE),
  NO_CLIENTE                    VARCHAR2(140 BYTE),
  CD_INCOTERMS                  CHAR(3 BYTE),
  CD_SALES_DISTRICT             CHAR(6 BYTE),
  CD_SALES_OFFICE               CHAR(4 BYTE),
  NO_SALES_OFFICE               VARCHAR2(140 BYTE),
  CD_SALES_GROUP                CHAR(3 BYTE),
  NO_SALES_GROUP                VARCHAR2(140 BYTE),
  CD_AGENTE_VENDA               VARCHAR2(10 BYTE),
  NO_AGENTE                     VARCHAR2(160 BYTE),
  DH_VENCIMENTO_PEDIDO          DATE,
  DT_CREDITO                    DATE,
  DT_INICIO                     DATE,
  DT_FIM                        DATE,
  DH_INCLUSAO                   DATE,
  DH_ENTREGA                    DATE,
  SG_ESTADO                     VARCHAR2(6 BYTE),
  NO_MUNICIPIO                  VARCHAR2(60 BYTE),
  DS_BAIRRO                     VARCHAR2(35 BYTE),
  CD_PRODUTO_SAP                CHAR(18 BYTE),
  NO_PRODUTO_SAP                VARCHAR2(44 BYTE),
  QT_PROGRAMADA                 NUMBER(15,3),
  QT_ENTREGUE                   NUMBER(15,3),
  QT_SALDO                      NUMBER(15,3),
  VL_UNITARIO                   NUMBER(13,2),
  VL_BRL                        NUMBER(13,2),
  VL_TAXA_DOLAR                 NUMBER(13,2),
  VL_USD                        NUMBER(13,2),
  PC_COMISSAO                   NUMBER(13,2),
  CD_SACARIA                    CHAR(3 BYTE),
  DS_SACARIA                    VARCHAR2(40 BYTE),
  CD_CULTURA_SAP                CHAR(3 BYTE),
  DS_CULTURA_SAP                VARCHAR2(40 BYTE),
  CD_BLOQUEIO_REMESSA           CHAR(2 BYTE),
  CD_BLOQUEIO_FATURAMENTO       CHAR(2 BYTE),
  CD_BLOQUEIO_CREDITO           CHAR(1 BYTE),
  CD_BLOQUEIO_REMESSA_ITEM      CHAR(2 BYTE),
  CD_BLOQUEIO_FATURAMENTO_ITEM  CHAR(2 BYTE),
  CD_MOTIVO_RECUSA              CHAR(2 BYTE),
  CD_LOGIN                      VARCHAR2(12 BYTE),
  CD_SEGMENTACAO_CLIENTE        CHAR(2 BYTE),
  DS_SEGMENTACAO_CLIENTE        VARCHAR2(60 BYTE),
  DS_SEGMENTO_CLIENTE_SAP       CHAR(2 BYTE),
  CD_FORMA_PAGAMENTO            VARCHAR2(4 BYTE),
  CD_TIPO_PAGAMENTO             VARCHAR2(1 BYTE),
  DS_TIPO_PAGAMENTO             VARCHAR2(50 BYTE),
  CD_AGRUPAMENTO                VARCHAR2(12 BYTE),
  CD_BLOQUEIO_ENTREGA           CHAR(2 BYTE),
  NU_CNPJ                       VARCHAR2(16 BYTE),
  NU_CPF                        VARCHAR2(11 BYTE),
  NU_INSCRICAO_ESTADUAL         VARCHAR2(18 BYTE),
  NU_INSCRICAO_MUNICIPAL        VARCHAR2(18 BYTE),
  NU_CEP                        VARCHAR2(10 BYTE),
  DS_ENDERECO_RECEBEDOR         VARCHAR2(100 BYTE),
  CD_CLIENTE_RECEBEDOR          VARCHAR2(11 BYTE),
  NO_CLIENTE_RECEBEDOR          VARCHAR2(140 BYTE),
  CD_MOEDA                      VARCHAR2(5 BYTE),
  CD_SUPPLY_GROUP               VARCHAR2(15 BYTE),
  DS_VENDA_COMPARTILHADA        VARCHAR2(20 BYTE),
  CD_STATUS_LIBERACAO           VARCHAR2(1 BYTE),
  CD_ITEM_PEDIDO                NUMBER(6),
  CD_CLIENTE_PAGADOR            VARCHAR2(11 BYTE),
  NO_CLIENTE_PAGADOR            VARCHAR2(140 BYTE),
  VL_FRETE_DISTRIBUICAO         NUMBER(13,2),
  CD_GRUPO_EMBALAGEM            CHAR(1 BYTE),
  DS_CREDIT_BLOCK_REASON        VARCHAR2(50 BYTE),
  DH_CREDIT_BLOCK               DATE,
  CD_ITEM_CONTRATO              NUMBER(6),
  DS_ROTEIRO_ENTREGA            VARCHAR2(4000 BYTE),
  DS_ENDERECO_PAGADOR           VARCHAR2(100 BYTE),
  NO_SALES_DISTRICT             VARCHAR2(140 BYTE)
)

ON COMMIT PRESERVE ROWS
NOCACHE;




GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_AGEND_TMP TO CTF;

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_AGEND_TMP TO ECC_USER;

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_AGEND_TMP TO VND_SEC;



CREATE GLOBAL TEMPORARY TABLE VND.ELO_CARTEIRA_SAP_BY_OV_TMP
(
  
  SESSION_ID NUMBER(9)           NOT NULL ,
  CD_ELO_CARTEIRA_SAP           NUMBER(9)       NOT NULL,
  NU_CARTEIRA_VERSION           VARCHAR2(14 BYTE) NOT NULL,
  CD_CENTRO_EXPEDIDOR           CHAR(4 BYTE),
  DS_CENTRO_EXPEDIDOR           VARCHAR2(31 BYTE),
  DH_CARTEIRA                   DATE,
  CD_SALES_ORG                  CHAR(4 BYTE),
  NU_CONTRATO_SAP               CHAR(10 BYTE),
  CD_TIPO_CONTRATO              CHAR(4 BYTE),
  NU_CONTRATO_SUBSTITUI         VARCHAR2(10 BYTE),
  DT_PAGO                       DATE,
  NU_CONTRATO                   NUMBER(10),
  NU_ORDEM_VENDA                CHAR(10 BYTE),
  DS_STATUS_CONTRATO_SAP        CHAR(20 BYTE),
  CD_CLIENTE                    VARCHAR2(11 BYTE),
  NO_CLIENTE                    VARCHAR2(140 BYTE),
  CD_INCOTERMS                  CHAR(3 BYTE),
  CD_SALES_DISTRICT             CHAR(6 BYTE),
  CD_SALES_OFFICE               CHAR(4 BYTE),
  NO_SALES_OFFICE               VARCHAR2(140 BYTE),
  CD_SALES_GROUP                CHAR(3 BYTE),
  NO_SALES_GROUP                VARCHAR2(140 BYTE),
  CD_AGENTE_VENDA               VARCHAR2(10 BYTE),
  NO_AGENTE                     VARCHAR2(160 BYTE),
  DH_VENCIMENTO_PEDIDO          DATE,
  DT_CREDITO                    DATE,
  DT_INICIO                     DATE,
  DT_FIM                        DATE,
  DH_INCLUSAO                   DATE,
  DH_ENTREGA                    DATE,
  SG_ESTADO                     VARCHAR2(6 BYTE),
  NO_MUNICIPIO                  VARCHAR2(60 BYTE),
  DS_BAIRRO                     VARCHAR2(35 BYTE),
  CD_PRODUTO_SAP                CHAR(18 BYTE),
  NO_PRODUTO_SAP                VARCHAR2(44 BYTE),
  QT_PROGRAMADA                 NUMBER(15,3),
  QT_ENTREGUE                   NUMBER(15,3),
  QT_SALDO                      NUMBER(15,3),
  VL_UNITARIO                   NUMBER(13,2),
  VL_BRL                        NUMBER(13,2),
  VL_TAXA_DOLAR                 NUMBER(13,2),
  VL_USD                        NUMBER(13,2),
  PC_COMISSAO                   NUMBER(13,2),
  CD_SACARIA                    CHAR(3 BYTE),
  DS_SACARIA                    VARCHAR2(40 BYTE),
  CD_CULTURA_SAP                CHAR(3 BYTE),
  DS_CULTURA_SAP                VARCHAR2(40 BYTE),
  CD_BLOQUEIO_REMESSA           CHAR(2 BYTE),
  CD_BLOQUEIO_FATURAMENTO       CHAR(2 BYTE),
  CD_BLOQUEIO_CREDITO           CHAR(1 BYTE),
  CD_BLOQUEIO_REMESSA_ITEM      CHAR(2 BYTE),
  CD_BLOQUEIO_FATURAMENTO_ITEM  CHAR(2 BYTE),
  CD_MOTIVO_RECUSA              CHAR(2 BYTE),
  CD_LOGIN                      VARCHAR2(12 BYTE),
  CD_SEGMENTACAO_CLIENTE        CHAR(2 BYTE),
  DS_SEGMENTACAO_CLIENTE        VARCHAR2(60 BYTE),
  DS_SEGMENTO_CLIENTE_SAP       CHAR(2 BYTE),
  CD_FORMA_PAGAMENTO            VARCHAR2(4 BYTE),
  CD_TIPO_PAGAMENTO             VARCHAR2(1 BYTE),
  DS_TIPO_PAGAMENTO             VARCHAR2(50 BYTE),
  CD_AGRUPAMENTO                VARCHAR2(12 BYTE),
  CD_BLOQUEIO_ENTREGA           CHAR(2 BYTE),
  NU_CNPJ                       VARCHAR2(16 BYTE),
  NU_CPF                        VARCHAR2(11 BYTE),
  NU_INSCRICAO_ESTADUAL         VARCHAR2(18 BYTE),
  NU_INSCRICAO_MUNICIPAL        VARCHAR2(18 BYTE),
  NU_CEP                        VARCHAR2(10 BYTE),
  DS_ENDERECO_RECEBEDOR         VARCHAR2(100 BYTE),
  CD_CLIENTE_RECEBEDOR          VARCHAR2(11 BYTE),
  NO_CLIENTE_RECEBEDOR          VARCHAR2(140 BYTE),
  CD_MOEDA                      VARCHAR2(5 BYTE),
  CD_SUPPLY_GROUP               VARCHAR2(15 BYTE),
  DS_VENDA_COMPARTILHADA        VARCHAR2(20 BYTE),
  CD_STATUS_LIBERACAO           VARCHAR2(1 BYTE),
  CD_ITEM_PEDIDO                NUMBER(6),
  CD_CLIENTE_PAGADOR            VARCHAR2(11 BYTE),
  NO_CLIENTE_PAGADOR            VARCHAR2(140 BYTE),
  VL_FRETE_DISTRIBUICAO         NUMBER(13,2),
  CD_GRUPO_EMBALAGEM            CHAR(1 BYTE),
  DS_CREDIT_BLOCK_REASON        VARCHAR2(50 BYTE),
  DH_CREDIT_BLOCK               DATE,
  CD_ITEM_CONTRATO              NUMBER(6),
  DS_ROTEIRO_ENTREGA            VARCHAR2(4000 BYTE),
  DS_ENDERECO_PAGADOR           VARCHAR2(100 BYTE),
  NO_SALES_DISTRICT             VARCHAR2(140 BYTE)
)

ON COMMIT PRESERVE ROWS
NOCACHE;




GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_BY_OV_TMP TO CTF;

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_BY_OV_TMP TO ECC_USER;

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_BY_OV_TMP TO VND_SEC;
/


DECLARE 
P_NU_CARTEIRA_VERSION VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE:='20180117082728';
V_TRAVA VARCHAR2(1):='N';

   TYPE carteira_sap_t IS TABLE OF VND.ELO_CARTEIRA_SAP_AGEND_TMP%ROWTYPE
      INDEX BY BINARY_INTEGER;
      
   tof_carteira_sap   carteira_sap_t; 
      
   
CURSOR c_carteira 
IS
SELECT TMP.*
FROM VND.ELO_CARTEIRA_SAP_AGEND_TMP TMP
INNER JOIN (
SELECT AGEND.NU_CONTRATO_SAP, AGEND.CD_ITEM_CONTRATO, MAX(AGEND.NU_ORDEM_VENDA) NU_ORDEM_VENDA 
FROM VND.ELO_CARTEIRA_SAP_AGEND_TMP AGEND
WHERE 
AGEND.NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
AND AGEND.NU_ORDEM_VENDA IS NOT NULL
GROUP BY AGEND.NU_CONTRATO_SAP, AGEND.CD_ITEM_CONTRATO
) MAXIM
ON MAXIM.NU_CONTRATO_SAP = TMP.NU_CONTRATO_SAP
AND MAXIM.CD_ITEM_CONTRATO = TMP.CD_ITEM_CONTRATO
AND MAXIM.NU_ORDEM_VENDA = TMP.NU_ORDEM_VENDA

WHERE 
TMP.SESSION_ID = sys_context('USERENV','SID') 
AND TMP.NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
AND TMP.NU_ORDEM_VENDA IS NOT NULL;
   

BEGIN 

BEGIN 

DELETE FROM VND.ELO_CARTEIRA_SAP_AGEND_TMP
WHERE SESSION_ID = sys_context('USERENV','SID') 
AND NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION  
;
--COMMIT;
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
V_TRAVA:='N';
WHEN OTHERS THEN
V_TRAVA:='N';
END;

BEGIN
DELETE FROM VND.ELO_CARTEIRA_SAP_BY_OV_TMP
WHERE SESSION_ID = sys_context('USERENV','SID')
AND NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
;
--COMMIT;

EXCEPTION 
WHEN NO_DATA_FOUND THEN 
V_TRAVA:='N';
WHEN OTHERS THEN
V_TRAVA:='N';
END;



BEGIN 
INSERT INTO VND.ELO_CARTEIRA_SAP_AGEND_TMP 
(SESSION_ID,
    CD_ELO_CARTEIRA_SAP,
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
    NO_SALES_DISTRICT)
SELECT   
    sys_context('USERENV','SID')  SESSION_ID,
    SAPS.CD_ELO_CARTEIRA_SAP,
    SAPS.NU_CARTEIRA_VERSION,
    SAPS.CD_CENTRO_EXPEDIDOR,
    NVL((SELECT CC.DS_CENTRO_EXPEDIDOR 
        FROM CTF.CENTRO_EXPEDIDOR CC 
        WHERE SAP.CD_CENTRO_EXPEDIDOR = CC.CD_CENTRO_EXPEDIDOR),  SAPS.DS_CENTRO_EXPEDIDOR ) DS_CENTRO_EXPEDIDOR,
    SAPS.DH_CARTEIRA,
    SAPS.CD_SALES_ORG,
    SAPS.NU_CONTRATO_SAP,
    SAPS.CD_TIPO_CONTRATO,
    SAPS.NU_CONTRATO_SUBSTITUI,
    SAPS.DT_PAGO,
    SAPS.NU_CONTRATO,
    SAPS.NU_ORDEM_VENDA,
    SAPS.DS_STATUS_CONTRATO_SAP,
    SAPS.CD_CLIENTE,
    SAPS.NO_CLIENTE,
    SAPS.CD_INCOTERMS,
    SAPS.CD_SALES_DISTRICT,
    SAPS.CD_SALES_OFFICE,
    SAPS.NO_SALES_OFFICE,
    SAPS.CD_SALES_GROUP,
    SAPS.NO_SALES_GROUP,
    SAPS.CD_AGENTE_VENDA,
    SAPS.NO_AGENTE,
    SAPS.DH_VENCIMENTO_PEDIDO,
    SAPS.DT_CREDITO,
    SAPS.DT_INICIO,
    SAPS.DT_FIM,
    SAPS.DH_INCLUSAO,
    SAPS.DH_ENTREGA,
    SAPS.SG_ESTADO,
    SAPS.NO_MUNICIPIO,
    SAPS.DS_BAIRRO,
    SAPS.CD_PRODUTO_SAP,
    SAPS.NO_PRODUTO_SAP,
    SAPS.QT_PROGRAMADA,
    SAPS.QT_ENTREGUE,
    SAPS.QT_SALDO,
    SAPS.VL_UNITARIO,
    SAPS.VL_BRL,
    SAPS.VL_TAXA_DOLAR,
    SAPS.VL_USD,
    SAPS.PC_COMISSAO,
    SAPS.CD_SACARIA,
    SAPS.DS_SACARIA,
    SAPS.CD_CULTURA_SAP,
    SAPS.DS_CULTURA_SAP,
    SAPS.CD_BLOQUEIO_REMESSA,
    SAPS.CD_BLOQUEIO_FATURAMENTO,
    SAPS.CD_BLOQUEIO_CREDITO,
    SAPS.CD_BLOQUEIO_REMESSA_ITEM,
    SAPS.CD_BLOQUEIO_FATURAMENTO_ITEM,
    SAPS.CD_MOTIVO_RECUSA,
    SAPS.CD_LOGIN,
    SAPS.CD_SEGMENTACAO_CLIENTE,
    SAPS.DS_SEGMENTACAO_CLIENTE,
    SAPS.DS_SEGMENTO_CLIENTE_SAP,
    SAPS.CD_FORMA_PAGAMENTO,
    SAPS.CD_TIPO_PAGAMENTO,
    SAPS.DS_TIPO_PAGAMENTO,
    SAPS.CD_AGRUPAMENTO,
    SAPS.CD_BLOQUEIO_ENTREGA,
    SAPS.NU_CNPJ,
    SAPS.NU_CPF,
    SAPS.NU_INSCRICAO_ESTADUAL,
    SAPS.NU_INSCRICAO_MUNICIPAL,
    SAPS.NU_CEP,
    SAPS.DS_ENDERECO_RECEBEDOR,
    SAPS.CD_CLIENTE_RECEBEDOR,
    SAPS.NO_CLIENTE_RECEBEDOR,
    SAPS.CD_MOEDA,
    SAPS.CD_SUPPLY_GROUP,
    SAPS.DS_VENDA_COMPARTILHADA,
    SAPS.CD_STATUS_LIBERACAO,
    SAPS.CD_ITEM_PEDIDO,
    SAPS.CD_CLIENTE_PAGADOR,
    SAPS.NO_CLIENTE_PAGADOR,
    SAPS.VL_FRETE_DISTRIBUICAO,
    SAPS.CD_GRUPO_EMBALAGEM,
    SAPS.DS_CREDIT_BLOCK_REASON,
    SAPS.DH_CREDIT_BLOCK,
    SAPS.CD_ITEM_CONTRATO,
    SAPS.DS_ROTEIRO_ENTREGA,
    SAPS.DS_ENDERECO_PAGADOR,
    SAPS.NO_SALES_DISTRICT
    FROM VND.ELO_CARTEIRA_SAP SAPS
    LEFT JOIN VND.ELO_CARTEIRA_SAP_AGEND_TMP TMPS
    ON 
    SAPS.CD_ELO_CARTEIRA_SAP = TMPS.CD_ELO_CARTEIRA_SAP 
    AND TMPS.SESSION_ID = sys_context('USERENV','SID')
    WHERE 
    SAPS.NU_CARTEIRA_VERSION = P_NU_CARTEIRA_VERSION
    AND TMPS.SESSION_ID IS NULL
    ;
    --            COMMIT;
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
V_TRAVA:='N';
WHEN OTHERS THEN
V_TRAVA:='N';
END;



OPEN    c_carteira;                               
FETCH   c_carteira BULK COLLECT INTO tof_carteira_sap LIMIT 10000;
CLOSE   c_carteira;



BEGIN 

FORALL i_cart in INDICES OF tof_carteira_sap
            
UPDATE VND.ELO_CARTEIRA_SAP_AGEND_TMP S
SET S.NU_ORDEM_VENDA =  '0',
DS_CREDIT_BLOCK_REASON = 'ALTERADO'
WHERE S.NU_ORDEM_VENDA IS NULL
AND S.SESSION_ID = tof_carteira_sap(i_cart).SESSION_ID
AND S.NU_CARTEIRA_VERSION = tof_carteira_sap(i_cart).NU_CARTEIRA_VERSION 
AND S.NU_CONTRATO_SAP = tof_carteira_sap(i_cart).NU_CONTRATO_SAP
AND S.CD_ITEM_CONTRATO = tof_carteira_sap(i_cart).CD_ITEM_CONTRATO
AND S.CD_PRODUTO_SAP = tof_carteira_sap(i_cart).CD_PRODUTO_SAP
;  
COMMIT;                      
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
V_TRAVA:='N';
WHEN OTHERS THEN
V_TRAVA:='N';
END;


BEGIN             
INSERT INTO VND.ELO_CARTEIRA_SAP_BY_OV_TMP 
(
SESSION_ID,
    CD_ELO_CARTEIRA_SAP,
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
    NO_SALES_DISTRICT)
SELECT 
    sys_context('USERENV','SID')  SESSION_ID,
    MAX(SAPS.CD_ELO_CARTEIRA_SAP),
    SAPS.NU_CARTEIRA_VERSION,
    SAPS.CD_CENTRO_EXPEDIDOR,
    SAPS.DS_CENTRO_EXPEDIDOR,
    SAPS.DH_CARTEIRA,
    SAPS.CD_SALES_ORG,
    SAPS.NU_CONTRATO_SAP,
    SAPS.CD_TIPO_CONTRATO,
    SAPS.NU_CONTRATO_SUBSTITUI,
    MAX(SAPS.DT_PAGO),
    SAPS.NU_CONTRATO,
    SAPS.NU_ORDEM_VENDA,
    SAPS.DS_STATUS_CONTRATO_SAP,
    SAPS.CD_CLIENTE,
    SAPS.NO_CLIENTE,
    SAPS.CD_INCOTERMS,
    SAPS.CD_SALES_DISTRICT,
    SAPS.CD_SALES_OFFICE,
    SAPS.NO_SALES_OFFICE,
    SAPS.CD_SALES_GROUP,
    SAPS.NO_SALES_GROUP,
    SAPS.CD_AGENTE_VENDA,
    SAPS.NO_AGENTE,
    MAX(SAPS.DH_VENCIMENTO_PEDIDO),
    SAPS.DT_CREDITO,
    SAPS.DT_INICIO,
    SAPS.DT_FIM,
    SAPS.DH_INCLUSAO,
    MAX(SAPS.DH_ENTREGA),
    SAPS.SG_ESTADO,
    SAPS.NO_MUNICIPIO,
    SAPS.DS_BAIRRO,
    SAPS.CD_PRODUTO_SAP,
    SAPS.NO_PRODUTO_SAP,
    SUM(SAPS.QT_PROGRAMADA),
    SUM(SAPS.QT_ENTREGUE),
    SUM(SAPS.QT_SALDO),
    MAX(SAPS.VL_UNITARIO),
    SUM(SAPS.VL_BRL),
    MAX(SAPS.VL_TAXA_DOLAR),
    SUM(SAPS.VL_USD),
    SAPS.PC_COMISSAO,
    SAPS.CD_SACARIA,
    SAPS.DS_SACARIA,
    SAPS.CD_CULTURA_SAP,
    SAPS.DS_CULTURA_SAP,
    MAX(SAPS.CD_BLOQUEIO_REMESSA),
    MAX(SAPS.CD_BLOQUEIO_FATURAMENTO),
    MAX(SAPS.CD_BLOQUEIO_CREDITO),
    MAX(SAPS.CD_BLOQUEIO_REMESSA_ITEM),
    MAX(SAPS.CD_BLOQUEIO_FATURAMENTO_ITEM),
    SAPS.CD_MOTIVO_RECUSA,
    MAX(SAPS.CD_LOGIN),
    SAPS.CD_SEGMENTACAO_CLIENTE,
    SAPS.DS_SEGMENTACAO_CLIENTE,
    SAPS.DS_SEGMENTO_CLIENTE_SAP,
    SAPS.CD_FORMA_PAGAMENTO,
    SAPS.CD_TIPO_PAGAMENTO,
    SAPS.DS_TIPO_PAGAMENTO,
    SAPS.CD_AGRUPAMENTO,
    MAX(SAPS.CD_BLOQUEIO_ENTREGA),
    SAPS.NU_CNPJ,
    SAPS.NU_CPF,
    SAPS.NU_INSCRICAO_ESTADUAL,
    SAPS.NU_INSCRICAO_MUNICIPAL,
    SAPS.NU_CEP,
    SAPS.DS_ENDERECO_RECEBEDOR,
    SAPS.CD_CLIENTE_RECEBEDOR,
    SAPS.NO_CLIENTE_RECEBEDOR,
    SAPS.CD_MOEDA,
    SAPS.CD_SUPPLY_GROUP,
    SAPS.DS_VENDA_COMPARTILHADA,
    SAPS.CD_STATUS_LIBERACAO,
    9999 AS CD_ITEM_PEDIDO,
    SAPS.CD_CLIENTE_PAGADOR,
    SAPS.NO_CLIENTE_PAGADOR,
    MAX(SAPS.VL_FRETE_DISTRIBUICAO),
    SAPS.CD_GRUPO_EMBALAGEM,
    MAX(SAPS.DS_CREDIT_BLOCK_REASON),
    SAPS.DH_CREDIT_BLOCK,
    SAPS.CD_ITEM_CONTRATO,
    SAPS.DS_ROTEIRO_ENTREGA,
    SAPS.DS_ENDERECO_PAGADOR,
    SAPS.NO_SALES_DISTRICT

    FROM VND.ELO_CARTEIRA_SAP_AGEND_TMP SAPS
    LEFT JOIN VND.ELO_CARTEIRA_SAP_BY_OV_TMP TMPS
    ON 
    SAPS.CD_ELO_CARTEIRA_SAP = TMPS.CD_ELO_CARTEIRA_SAP 
    AND TMPS.SESSION_ID = SAPS.SESSION_ID
    --AND SAPS.SESSION_ID = sys_context('USERENV','SID')
    WHERE 
    --SAPS.NU_CARTEIRA_VERSION = :NU_CARTEIRA_VERSION
    TMPS.SESSION_ID IS NULL

    GROUP BY 
    --MAX(SAPS.CD_ELO_CARTEIRA_SAP),
    SAPS.NU_CARTEIRA_VERSION,
    SAPS.CD_CENTRO_EXPEDIDOR,
    SAPS.DS_CENTRO_EXPEDIDOR,
    SAPS.DH_CARTEIRA,
    SAPS.CD_SALES_ORG,
    SAPS.NU_CONTRATO_SAP,
    SAPS.CD_TIPO_CONTRATO,
    SAPS.NU_CONTRATO_SUBSTITUI,
    --MAX(SAPS.DT_PAGO),
    SAPS.NU_CONTRATO,
    SAPS.NU_ORDEM_VENDA,
    SAPS.DS_STATUS_CONTRATO_SAP,
    SAPS.CD_CLIENTE,
    SAPS.NO_CLIENTE,
    SAPS.CD_INCOTERMS,
    SAPS.CD_SALES_DISTRICT,
    SAPS.CD_SALES_OFFICE,
    SAPS.NO_SALES_OFFICE,
    SAPS.CD_SALES_GROUP,
    SAPS.NO_SALES_GROUP,
    SAPS.CD_AGENTE_VENDA,
    SAPS.NO_AGENTE,
    --MAX(SAPS.DH_VENCIMENTO_PEDIDO),
    SAPS.DT_CREDITO,
    SAPS.DT_INICIO,
    SAPS.DT_FIM,
    SAPS.DH_INCLUSAO,
    --MAX(SAPS.DH_ENTREGA),
    SAPS.SG_ESTADO,
    SAPS.NO_MUNICIPIO,
    SAPS.DS_BAIRRO,
    SAPS.CD_PRODUTO_SAP,
    SAPS.NO_PRODUTO_SAP,
    --SUM(SAPS.QT_PROGRAMADA),
    -- SUM(SAPS.QT_ENTREGUE),
    -- SUM(SAPS.QT_SALDO),
    -- MAX(SAPS.VL_UNITARIO),
    -- SUM(SAPS.VL_BRL),
    -- MAX(SAPS.VL_TAXA_DOLAR),
    -- SUM(SAPS.VL_USD),
    SAPS.PC_COMISSAO,
    SAPS.CD_SACARIA,
    SAPS.DS_SACARIA,
    SAPS.CD_CULTURA_SAP,
    SAPS.DS_CULTURA_SAP,
    -- MAX(SAPS.CD_BLOQUEIO_REMESSA),
    -- MAX(SAPS.CD_BLOQUEIO_FATURAMENTO),
    -- MAX(SAPS.CD_BLOQUEIO_CREDITO),
    -- MAX(SAPS.CD_BLOQUEIO_REMESSA_ITEM),
    -- MAX(SAPS.CD_BLOQUEIO_FATURAMENTO_ITEM),
    SAPS.CD_MOTIVO_RECUSA,
    -- MAX(SAPS.CD_LOGIN),
    SAPS.CD_SEGMENTACAO_CLIENTE,
    SAPS.DS_SEGMENTACAO_CLIENTE,
    SAPS.DS_SEGMENTO_CLIENTE_SAP,
    SAPS.CD_FORMA_PAGAMENTO,
    SAPS.CD_TIPO_PAGAMENTO,
    SAPS.DS_TIPO_PAGAMENTO,
    SAPS.CD_AGRUPAMENTO,
    -- MAX(SAPS.CD_BLOQUEIO_ENTREGA),
    SAPS.NU_CNPJ,
    SAPS.NU_CPF,
    SAPS.NU_INSCRICAO_ESTADUAL,
    SAPS.NU_INSCRICAO_MUNICIPAL,
    SAPS.NU_CEP,
    SAPS.DS_ENDERECO_RECEBEDOR,
    SAPS.CD_CLIENTE_RECEBEDOR,
    SAPS.NO_CLIENTE_RECEBEDOR,
    SAPS.CD_MOEDA,
    SAPS.CD_SUPPLY_GROUP,
    SAPS.DS_VENDA_COMPARTILHADA,
    SAPS.CD_STATUS_LIBERACAO,
    --9999 CD_ITEM_PEDIDO,
    SAPS.CD_CLIENTE_PAGADOR,
    SAPS.NO_CLIENTE_PAGADOR,
    --MAX(SAPS.VL_FRETE_DISTRIBUICAO),
    SAPS.CD_GRUPO_EMBALAGEM,
    --SAPS.DS_CREDIT_BLOCK_REASON,
    SAPS.DH_CREDIT_BLOCK,
    SAPS.CD_ITEM_CONTRATO,
    SAPS.DS_ROTEIRO_ENTREGA,
    SAPS.DS_ENDERECO_PAGADOR,
    SAPS.NO_SALES_DISTRICT             

    ;
    --            COMMIT;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    V_TRAVA:='N';
    WHEN OTHERS THEN
    V_TRAVA:='N';
END;



 
           
            
            
END;
   




SELECT 



(SELECT MAX(T.NU_ORDEM_VENDA) FROM VND.ELO_CARTEIRA_SAP_AGEND_TMP T
WHERE
S.SESSION_ID = T.SESSION_ID
AND S.NU_CARTEIRA_VERSION = T.NU_CARTEIRA_VERSION 
AND S.NU_CONTRATO_SAP = T.NU_CONTRATO_SAP
AND S.CD_ITEM_CONTRATO = T.CD_ITEM_CONTRATO
AND T.NU_ORDEM_VENDA IS NOT NULL
AND S.CD_PRODUTO_SAP = T.CD_PRODUTO_SAP) NEWOV, 

S.NU_CONTRATO_SAP,
S.CD_ITEM_CONTRATO, 
S.CD_PRODUTO_SAP,

SSS.*,

S.*

FROM VND.ELO_CARTEIRA_SAP SSS
LEFT JOIN VND.ELO_CARTEIRA_SAP_BY_OV_TMP S
ON SSS.NU_CARTEIRA_VERSION = S.NU_CARTEIRA_VERSION 
AND SSS.CD_ELO_CARTEIRA_SAP = S.CD_ELO_CARTEIRA_SAP


WHERE 1=1
AND SSS.NU_CARTEIRA_VERSION = '20180117082728' 
AND S.CD_ELO_CARTEIRA_SAP IS NULL
 --S.NU_ORDEM_VENDA IS NULL
--AND EXISTS (SELECT 1 FROM ELO_CARTEIRA_SAP_BY_OV_TMP X
--WHERE
--S.NU_CARTEIRA_VERSION = X.NU_CARTEIRA_VERSION 
--AND S.NU_CONTRATO_SAP = X.NU_CONTRATO_SAP
--AND S.CD_ITEM_CONTRATO = X.CD_ITEM_CONTRATO
--AND S.CD_PRODUTO_SAP = X.CD_PRODUTO_SAP 
----AND X.NU_ORDEM_VENDA IS NOT NULL
--)
--ORDER BY 
--S.NU_CONTRATO_SAP,
-- S.CD_ITEM_CONTRATO
;
 
SELECT * FROM ELO_CARTEIRA_SAP_BY_OV_TMP
WHERE 
NU_CARTEIRA_VERSION = '20180117082728'
AND DS_CREDIT_BLOCK_REASON LIKE '%ALTERADO%'
AND NU_CONTRATO_SAP    = '0040317866'
AND CD_ITEM_CONTRATO = 0 

SELECT * FROM VND.ELO_CARTEIRA_SAP 
WHERE 
NU_CARTEIRA_VERSION = '20180117082728'
AND NU_CONTRATO_SAP    = '0040317866'
AND CD_ITEM_CONTRATO = 0 
1714
 
SELECT * FROM ELO_CARTEIRA_SAP_AGEND_TMP


UPDATE VND.ELO_CARTEIRA_SAP_BY_OV_TMP S
SET S.NU_ORDEM_VENDA = 
(SELECT MAX(T.NU_ORDEM_VENDA) 
FROM VND.ELO_CARTEIRA_SAP_AGEND_TMP T
WHERE
S.SESSION_ID = T.SESSION_ID
AND S.NU_CARTEIRA_VERSION = T.NU_CARTEIRA_VERSION 
AND S.NU_CONTRATO_SAP = T.NU_CONTRATO_SAP
AND S.CD_ITEM_CONTRATO = T.CD_ITEM_CONTRATO
AND T.NU_ORDEM_VENDA IS NOT NULL
AND S.CD_PRODUTO_SAP = T.CD_PRODUTO_SAP)
WHERE S.NU_ORDEM_VENDA IS NULL
;  
COMMIT;
