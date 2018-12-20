CREATE TABLE VND.ELO_BACKLOG
(
  CD_BACKLOG           NUMBER(9),
  DT_WEEK_START        DATE                     NOT NULL,
  CD_WEEK              VARCHAR2(10),
  CD_POLO              CHAR(4),
  CD_CENTRO_EXPEDIDOR  CHAR(4),
  CD_MACHINE           CHAR(4),
  SG_TIPO_DOCUMENTO    CHAR(1)                  NOT NULL,
  NU_DOCUMENTO         VARCHAR2(30)             NOT NULL,
  NU_ITEM_DOCUMENTO    NUMBER(6),
  QT_CONTRATADA        NUMBER(10,3)             DEFAULT 0                     NOT NULL,
  QT_FORNECIDA         NUMBER(10,3)             DEFAULT 0                     NOT NULL,
  QT_AGENDADA          NUMBER(10,3)             DEFAULT 0                     NOT NULL,
  QT_BACKLOG           NUMBER(10,3)             DEFAULT 0                     NOT NULL,
  QT_REJEITADA         NUMBER(10,3)             DEFAULT 0,
  DH_BACKLOG           DATE                     NOT NULL
)
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOCOMPRESS 
NOCACHE
RESULT_CACHE (MODE DEFAULT)
NOPARALLEL
NOMONITORING;


ALTER TABLE VND.ELO_BACKLOG ADD (
  CONSTRAINT ELO_BACKLOG_PK
  PRIMARY KEY
  (CD_BACKLOG)
  ENABLE VALIDATE);

COMMENT ON COLUMN VND.ELO_BACKLOG.SG_TIPO_DOCUMENTO IS 'P = Protocolo; C = Contrato Não Desdobramento e Não Venda Ordem; D = Contrato Desdobramento';