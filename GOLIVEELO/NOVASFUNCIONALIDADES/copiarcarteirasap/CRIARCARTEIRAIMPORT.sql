

CREATE TABLE VND.ELO_CARTEIRA_SAP_IMPORT
(
  CD_ELO_CARTEIRA_SAP           NUMBER(9)       NOT NULL,
  CD_SOURCE_CARTEIRA            VARCHAR2(10 BYTE) NOT NULL,
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
TABLESPACE WEB_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING;



CREATE INDEX VND.IDX_NU_CARTV_NR_SAP_IT_PR ON VND.ELO_CARTEIRA_SAP_IMPORT
(NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, CD_PRODUTO_SAP)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX VND.IX_CENTRO_VERSION_02 ON VND.ELO_CARTEIRA_SAP_IMPORT
(CD_CENTRO_EXPEDIDOR, NU_CARTEIRA_VERSION)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX VND.IX_ELO_CARTEIRA_SAP_DH_02 ON VND.ELO_CARTEIRA_SAP_IMPORT
(DH_CARTEIRA)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX VND.IX_ELO_CARTEIRA_SAP_SG_02 ON VND.ELO_CARTEIRA_SAP_IMPORT
(NU_CARTEIRA_VERSION, CD_SALES_DISTRICT, CD_SALES_GROUP, CD_SALES_OFFICE)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX VND."IX_ELO_CARTEIRA_SAP_EMBALA" ON VND.ELO_CARTEIRA_SAP_IMPORT
(CD_GRUPO_EMBALAGEM)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE UNIQUE INDEX VND."UN_CARTEIRA_SAP_PK" ON VND.ELO_CARTEIRA_SAP_IMPORT
(CD_ELO_CARTEIRA_SAP)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

ALTER TABLE VND.ELO_CARTEIRA_SAP_IMPORT ADD (
  CONSTRAINT "UN_CARTEIRA_SAP_PK"
  PRIMARY KEY
  (CD_ELO_CARTEIRA_SAP)
  USING INDEX VND."UN_CARTEIRA_SAP_PK"
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_IMPORT TO CTF;

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_IMPORT TO ECC_USER;

GRANT DELETE, INSERT, SELECT ON VND.ELO_CARTEIRA_SAP_IMPORT TO VND_SEC;

/