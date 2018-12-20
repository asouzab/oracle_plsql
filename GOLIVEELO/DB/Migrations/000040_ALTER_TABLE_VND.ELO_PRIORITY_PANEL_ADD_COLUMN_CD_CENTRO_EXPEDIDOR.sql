ALTER TABLE VND.ELO_PRIORITY_PANEL
ADD
    CD_CENTRO_EXPEDIDOR CHAR(4)
;

CREATE UNIQUE INDEX VND.XUCCENTRO_EXPEDIDOR ON VND.ELO_PRIORITY_PANEL
(CD_ELO_PRIORITY_OPTION, NU_ORDER, CD_CENTRO_EXPEDIDOR);

ALTER TABLE VND.ELO_PRIORITY_PANEL ADD (
  CONSTRAINT XUCCENTRO_EXPEDIDOR
  UNIQUE (CD_ELO_PRIORITY_OPTION, NU_ORDER, CD_CENTRO_EXPEDIDOR)
  USING INDEX VND.XUCCENTRO_EXPEDIDOR
  ENABLE VALIDATE);

ALTER TABLE VND.ELO_PRIORITY_PANEL ADD (
  CONSTRAINT "Relationship39" 
  FOREIGN KEY (CD_ELO_PRIORITY_OPTION) 
  REFERENCES VND.ELO_PRIORITY_OPTION (CD_ELO_PRIORITY_OPTION)
  ENABLE VALIDATE);