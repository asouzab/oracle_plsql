WITH MY AS (
SELECT * FROM VND.ELO_CARTEIRA_SAP S
WHERE S.DH_CARTEIRA > SYSDATE - 7
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

SELECT * FROM VND.ELO_CARTEIRA_SAP SA 
INNER JOIN CTE_DUP DD
ON 
SA.NU_CARTEIRA_VERSION = DD.NU_CARTEIRA_VERSION
AND SA.NU_CONTRATO_SAP = DD.NU_CONTRATO_SAP
AND SA.CD_ITEM_CONTRATO = DD.CD_ITEM_CONTRATO

 ;