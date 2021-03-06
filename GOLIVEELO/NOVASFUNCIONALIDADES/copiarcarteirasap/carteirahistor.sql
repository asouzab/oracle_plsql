SELECT -- * 
CD_ELO_STATUS_AGENDA, COUNT(1) 
FROM ELO_CARTEIRA_HIST
GROUP BY CD_ELO_STATUS_AGENDA;




CREATE TABLE VND.ELO_CARTEIRA_HIST_ENCERRADO
(
  ID                         NUMBER(9)          NOT NULL,
  CD_ELO_CARTEIRA            NUMBER(9)          NOT NULL,
  CD_ELO_AGENDAMENTO         NUMBER(9)          NOT NULL,
  CD_ELO_AGENDAMENTO_ITEM    NUMBER(9),
  CD_TIPO_AGENDAMENTO        NUMBER(9),
  NU_ORDEM_VENDA             CHAR(10 BYTE),
  DH_ULT_INTERFACE_OV        DATE,
  NU_CONTRATO_SAP            CHAR(10 BYTE),
  DH_ULT_INTERFACE_CONTRATO  DATE,
  CD_STATUS_CEL_FINAL        NUMBER(9),
  CD_ELO_STATUS_AGENDA       NUMBER(9),
  QT_AGENDADA                NUMBER(15,3),
  QT_AGENDADA_CONFIRMADA     NUMBER(15,3),
  CD_STATUS_REPLAN           NUMBER(9),
  DH_ULT_ALTERACAO           DATE               DEFAULT (CURRENT_DATE),
  DS_VERSAO                  VARCHAR2(255 BYTE)
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
MONITORING
ENABLE ROW MOVEMENT;




CREATE UNIQUE INDEX VND.UN_ELO_CARTEIRA_HIST_ENCERRADO ON VND.ELO_CARTEIRA_HIST_ENCERRADO
(ID)
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



ALTER TABLE VND.ELO_CARTEIRA_HIST_ENCERRADO ADD (
  CONSTRAINT UN_ELO_CARTEIRA_HIST_ENCERRADO
  PRIMARY KEY
  (ID)
  USING INDEX VND.UN_ELO_CARTEIRA_HIST_ENCERRADO
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON VND.ELO_CARTEIRA_HIST_ENCERRADO TO CTF;

GRANT DELETE, INSERT, SELECT, UPDATE ON VND.ELO_CARTEIRA_HIST_ENCERRADO TO ECC_USER;

GRANT DELETE, INSERT, SELECT, UPDATE ON VND.ELO_CARTEIRA_HIST_ENCERRADO TO VND_SEC;


SELECT COUNT(1) FROM ELO_CARTEIRA_HIST_ENCERRADO;
SELECT COUNT(1) FROM ELO_CARTEIRA_HIST;






