SELECT * FROM VND.ELO_AGENDAMENTO
WHERE CD_WEEK = 'W162018'
AND CD_POLO = 'P002'

SELECT qt_agendada_confirmada, c.* FROM VND.VW_ELO_CARTEIRA_ALL c
WHERE CD_ELO_AGENDAMENTO = 12
AND (CD_STATUS_CUSTOMER_SERVICE IS NOT NULL or DH_LIBERACAO_TORRE_FRETES IS NOT NULL)
AND CD_STATUS_TORRE_FRETES IS NULL
AND CD_INCOTERMS =  'CIF' AND QT_AGENDADA_CONFIRMADA > 0 AND CD_STATUS_CEL_FINAL = 59


UPDATE VND.ELO_CARTEIRA
SET CD_STATUS_TORRE_FRETES = 10 ,
DH_LIBERACAO_TORRE_FRETES = CURRENT_DATE,
NU_PROTOCOLO_ENTREGA = 'MAJUST_MAGP001162018' || TO_CHAR(CURRENT_DATE)  

WHERE 
CD_STATUS_CUSTOMER_SERVICE IS not NULL 
AND CD_STATUS_TORRE_FRETES IS NULL 
AND QT_AGENDADA_CONFIRMADA > 0 
AND CD_STATUS_CEL_FINAL = 59
AND CD_ELO_AGENDAMENTO = 12
AND CD_ELO_CARTEIRA IN (
2212,
2221,
2275,
2308,
2451,
2672,
3829,
3830,
3831,
3833,
3840,
3842
);
COMMIT;


