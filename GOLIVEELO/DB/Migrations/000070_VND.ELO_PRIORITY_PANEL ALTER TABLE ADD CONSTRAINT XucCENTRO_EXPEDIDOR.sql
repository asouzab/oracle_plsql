ALTER TABLE VND.ELO_PRIORITY_PANEL
DROP CONSTRAINT ELO_PRIORITY_PANEL_U01;

ALTER TABLE VND.ELO_PRIORITY_PANEL
ADD CONSTRAINT XucCENTRO_EXPEDIDOR 
UNIQUE (CD_ELO_PRIORITY_OPTION, NU_ORDER, CD_CENTRO_EXPEDIDOR);

COMMIT;