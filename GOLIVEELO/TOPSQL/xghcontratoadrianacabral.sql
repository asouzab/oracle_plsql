SELECT *
  FROM VND.CONTRATO
 WHERE     1 = 1
       --AND NU_CONTRATO_SAP IS NULL AND NU_CONTRATO IS NULL
       --AND IC_ATIVO = 'S'
       --AND CD_AGENTE_VENDA = '0040410004'
       --AND DH_INCLUSAO > CURRENT_DATE - 10
       --AND NU_CONTRATO_SAP IN ('0040414806')
       AND NU_CONTRATO IN (2790255 )
--AND CD_CONTRATO = 3254
;
SELECT *
  FROM VND.ITEM_CONTRATO
 WHERE CD_CONTRATO = 214457;
 
 
 UPDATE VND.CONTRATO
SET DS_PDF = NULL
 WHERE CD_CONTRATO = 214457;

--COMMIT;


UPDATE VND.ITEM_CONTRATO
SET VL_PRECO_NEGOCIADO = 683.00, 
CD_MOTIVO_RECUSA = NULL,  -- 9G 
nu_quantidade =  1000.00 , 
IC_RECUSADO = 'N'         -- S    
WHERE
CD_CONTRATO = 214457
--AND CD_ITEM_CONTRATO = 10 AND CD_PRODUTO_SAP = '000000000000117849' --so ativo item 10   qty 1095
--AND CD_ITEM_CONTRATO = 20 AND CD_PRODUTO_SAP = '000000000000117908'
--AND CD_ITEM_CONTRATO = 30 AND CD_PRODUTO_SAP = '000000000000117853'
AND CD_ITEM_CONTRATO = 40 AND CD_PRODUTO_SAP = '000000000000117854'
;
COMMIT;



  update VND.TIPO_ORDEM
  set ic_usd_tipo_ordem = 'S'
  
 WHERE     1 = 1
       AND CD_TIPO_ORDEM = 'ZCQN'
       AND CD_SALES_ORG = 'PY01'
       AND CD_DISTRIBUTION_CHANNEL = '10'
       AND CD_SALES_DIVISION = '10'