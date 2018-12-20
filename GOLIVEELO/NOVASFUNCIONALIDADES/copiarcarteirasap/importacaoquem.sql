alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';

--PROCEDURE PI_ELO_CARTEIRA_SAP_IMPORT NAO EEH ESSE
--(
--P_NU_CARTEIRA_VERSION VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE
--)

--IS
declare

P_NU_CARTEIRA_VERSION VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE:='20180112170149';
V_ADD_DAY_CARTEIRA_FILTER NUMBER:=3;
V_ADD_DAY_SALES_GROUP NUMBER:=30;
V_DH_LIMITE VND.ELO_CARTEIRA_SAP.DH_CARTEIRA%TYPE;



CURSOR VERS 
IS 

SELECT 
NU_CARTEIRA_VERSION ,
TEMPARCIAL
FROM 
(

SELECT 
DI.NU_CARTEIRA_VERSION,
DI.TEMPARCIAL, 

(SELECT COUNT(1) 
            FROM VND.ELO_CARTEIRA_SAP TEMPARCIAL 
            WHERE 
            TEMPARCIAL.NU_CARTEIRA_VERSION = DI.NU_CARTEIRA_VERSION) QT_CARTEIRA 
 
FROM (
select sap.NU_CARTEIRA_VERSION , 
CASE WHEN (SELECT COUNT(1) 
            FROM VND.ELO_CARTEIRA_SAP_IMPORT TEMPARCIAL 
            WHERE TEMPARCIAL.NU_CARTEIRA_VERSION = sap.NU_CARTEIRA_VERSION) >= 1 THEN 1
ELSE 0 END TEMPARCIAL 

from vnd.elo_carteira_sap sap
left join vnd.elo_carteira_sap_import impor
on sap.nu_carteira_version = impor.nu_carteira_version 
and sap.nu_contrato_sap = impor.nu_contrato_sap
and sap.cd_item_contrato = impor.cd_item_contrato
and sap.cd_produto_sap = impor.cd_produto_sap 
and NVL(sap.NU_ORDEM_VENDA, '0') = NVL(impor.NU_ORDEM_VENDA,'0')

WHERE 1=1
--AND NU_CARTEIRA_VERSION = '20180405060009'
and sap.dh_carteira > current_date - V_ADD_DAY_CARTEIRA_FILTER  
AND sap.dh_carteira <= V_DH_LIMITE 
and impor.nu_carteira_version is null 
GROUP BY sap.nu_carteira_version

) DI

)
ORDER BY QT_CARTEIRA DESC 
;


TYPE elo_sap_r IS RECORD
(
NU_CARTEIRA_VERSION 			VND.ELO_CARTEIRA_SAP_IMPORT.NU_CARTEIRA_VERSION%TYPE,
TEM_PARCIAL  NUMBER
);

TYPE elo_sap_T IS TABLE OF elo_sap_r
INDEX BY PLS_INTEGER;
tof_elo_sap elo_sap_T;

tof_tem_parcial_elo_sap elo_sap_T;


CURSOR C_DELETEIMPORT (PI_NU_CARTEIRA_VERSION VND.ELO_CARTEIRA_SAP_IMPORT.NU_CARTEIRA_VERSION%TYPE) IS 
SELECT 
impor.CD_ELO_CARTEIRA_SAP 
FROM VND.ELO_CARTEIRA_SAP_IMPORT impor
WHERE impor.NU_CARTEIRA_VERSION = PI_NU_CARTEIRA_VERSION;



TYPE elo_delete_import_r IS RECORD
(
CD_ELO_CARTEIRA_SAP 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_ELO_CARTEIRA_SAP%TYPE
);

TYPE elo_delete_import_t IS TABLE OF elo_delete_import_r
INDEX BY PLS_INTEGER;
tof_delete_import elo_delete_import_t;



CURSOR C_WHO_UPDATE (PI_NU_CARTEIRA_VERSION VND.ELO_CARTEIRA_SAP.NU_CARTEIRA_VERSION%TYPE) IS  

WITH
    CTE_SALES_GROUP_INI   AS
        (SELECT DISTINCT CTX.NU_CARTEIRA_VERSION,
                         CTX.CD_SALES_DISTRICT,
                         CTX.NO_SALES_DISTRICT,
                         CTX.CD_SALES_OFFICE,
                         CTX.NO_SALES_OFFICE,
                         CTX.CD_SALES_GROUP,
                         CTX.NO_SALES_GROUP
           FROM VND.ELO_CARTEIRA_SAP CTX
          WHERE CTX.NU_CARTEIRA_VERSION = PI_NU_CARTEIRA_VERSION),
          --WHERE CTX.NU_CARTEIRA_VERSION > (CURRENT_DATE - 7)),
    CTE_SALES_GROUP_PASS   AS
        (  SELECT CTX.NU_CARTEIRA_VERSION,
                  MAX (CTX.CD_SALES_DISTRICT) CD_SALES_DISTRICT,
                  MAX (CTX.NO_SALES_DISTRICT) NO_SALES_DISTRICT,
                  MAX (CTX.CD_SALES_OFFICE) CD_SALES_OFFICE,
                  MAX (CTX.NO_SALES_OFFICE) NO_SALES_OFFICE,
                  CTX.CD_SALES_GROUP        CD_SALES_GROUP,
                  MAX (CTX.NO_SALES_GROUP)  NO_SALES_GROUP
             FROM CTE_SALES_GROUP_INI CTX
            WHERE     CTX.NO_SALES_OFFICE IS NOT NULL
                  AND NOT (CTX.NO_SALES_OFFICE = ' ')
                  AND CTX.NO_SALES_GROUP IS NOT NULL
                  AND NOT (CTX.NO_SALES_GROUP = ' ')
         GROUP BY CTX.NU_CARTEIRA_VERSION, CTX.CD_SALES_GROUP),
CTE_IS_VIEW_SAP_SALESGROUP AS (         
SELECT CTX.NU_CARTEIRA_VERSION,
       CTX.CD_SALES_DISTRICT,
       CTX.NO_SALES_DISTRICT,
       CTX.CD_SALES_OFFICE,
       CTX.NO_SALES_OFFICE,
       CTX.CD_SALES_GROUP,
       CTX.NO_SALES_GROUP
  FROM CTE_SALES_GROUP_PASS CTX
UNION
SELECT XCTX.NU_CARTEIRA_VERSION,
       XCTX.CD_SALES_DISTRICT,
       XCTX.NO_SALES_DISTRICT,
       XCTX.CD_SALES_OFFICE,
       XCTX.NO_SALES_OFFICE,
       XCTX.CD_SALES_GROUP,
       CASE
           WHEN XCTX.NO_SALES_GROUP IS NULL
           THEN
               (SELECT C.NO_SALES_GROUP
                  FROM CTE_SALES_GROUP_PASS C
                 WHERE C.CD_SALES_GROUP = XCTX.CD_SALES_GROUP AND ROWNUM = 1)
           WHEN XCTX.NO_SALES_GROUP = ' '
           THEN
               (SELECT C.NO_SALES_GROUP
                  FROM CTE_SALES_GROUP_PASS C
                 WHERE C.CD_SALES_GROUP = XCTX.CD_SALES_GROUP AND ROWNUM = 1)
           WHEN TRIM (XCTX.NO_SALES_GROUP) = ''
           THEN
               (SELECT C.NO_SALES_GROUP
                  FROM CTE_SALES_GROUP_PASS C
                 WHERE C.CD_SALES_GROUP = XCTX.CD_SALES_GROUP AND ROWNUM = 1)
           WHEN LENGTH (XCTX.NO_SALES_GROUP) < 3
           THEN
               (SELECT C.NO_SALES_GROUP
                  FROM CTE_SALES_GROUP_PASS C
                 WHERE C.CD_SALES_GROUP = XCTX.CD_SALES_GROUP AND ROWNUM = 1)
           ELSE
               XCTX.NO_SALES_GROUP
       END
           NO_SALES_GROUP
  FROM CTE_SALES_GROUP_INI XCTX
 WHERE NOT EXISTS
           (SELECT 1
              FROM CTE_SALES_GROUP_PASS JAFO
             WHERE     JAFO.CD_SALES_GROUP = XCTX.CD_SALES_GROUP
                   AND JAFO.NU_CARTEIRA_VERSION = XCTX.NU_CARTEIRA_VERSION)
),

        CTE_SALES_GROUP
        AS
            (SELECT DISTINCT PB.NU_CARTEIRA_VERSION,
                             PB.CD_SALES_DISTRICT,
                             PB.NO_SALES_DISTRICT,
                             PB.CD_SALES_OFFICE,
                             PB.NO_SALES_OFFICE,
                             PB.CD_SALES_GROUP,
                             PB.NO_SALES_GROUP
               FROM CTE_IS_VIEW_SAP_SALESGROUP PB
              WHERE     PB.NO_SALES_GROUP IS NOT NULL
                    AND PB.NO_SALES_GROUP <> ' '
                    AND LENGTH (PB.NO_SALES_GROUP) > 3
             UNION
             SELECT DISTINCT PB.NU_CARTEIRA_VERSION,
                             PB.CD_SALES_DISTRICT,
                             PB.NO_SALES_DISTRICT,
                             PB.CD_SALES_OFFICE,
                             PB.NO_SALES_OFFICE,
                             PB.CD_SALES_GROUP,
                             PB.NO_SALES_GROUP
               FROM VND.ELO_CARTEIRA_SAP PB
               
              --WHERE PB.DH_CARTEIRA > (CURRENT_DATE - 7))
              WHERE PB.NU_CARTEIRA_VERSION =  PI_NU_CARTEIRA_VERSION)
                
, 

CTE_BEFORE_GROUP9999 AS 
(

SELECT
SPA.CD_ELO_CARTEIRA_SAP, 'SAP' CD_SOURCE_CARTEIRA,
SPA.NU_CARTEIRA_VERSION, 
SPA.CD_CENTRO_EXPEDIDOR,
SPA.DS_CENTRO_EXPEDIDOR, SPA.DH_CARTEIRA,
SPA.CD_SALES_ORG, SPA.NU_CONTRATO_SAP, 
SPA.CD_TIPO_CONTRATO, SPA.NU_CONTRATO_SUBSTITUI,
SPA.DT_PAGO, SPA.NU_CONTRATO,
SPA.NU_ORDEM_VENDA, SPA.DS_STATUS_CONTRATO_SAP,
SPA.CD_CLIENTE, SPA.NO_CLIENTE,
--SPA.CD_SALES_DISTRICT, 
           NVL (
               (SELECT PB.CD_SALES_DISTRICT
                  FROM CTE_SALES_GROUP PB
                 WHERE     PB.CD_SALES_GROUP = SPA.CD_SALES_GROUP
                       AND PB.NU_CARTEIRA_VERSION = SPA.NU_CARTEIRA_VERSION
                       AND ROWNUM = 1), SPA.CD_SALES_DISTRICT )
               CD_SALES_DISTRICT,

SPA.CD_INCOTERMS,
           NVL (
               (SELECT PB.CD_SALES_OFFICE
                  FROM CTE_SALES_GROUP PB
                 WHERE     PB.CD_SALES_GROUP = SPA.CD_SALES_GROUP
                       AND PB.NU_CARTEIRA_VERSION = SPA.NU_CARTEIRA_VERSION
                       AND ROWNUM = 1), SPA.CD_SALES_OFFICE )
               CD_SALES_OFFICE,
           NVL (
               (SELECT PB.NO_SALES_OFFICE
                  FROM CTE_SALES_GROUP PB
                 WHERE     PB.CD_SALES_GROUP = SPA.CD_SALES_GROUP
                       AND PB.NU_CARTEIRA_VERSION = SPA.NU_CARTEIRA_VERSION
                       AND ROWNUM = 1), SPA.NO_SALES_OFFICE)
               NO_SALES_OFFICE,
               
               SPA.CD_SALES_GROUP,
                NVL((SELECT PB.NO_SALES_GROUP
                      FROM CTE_SALES_GROUP PB
                     WHERE     PB.CD_SALES_GROUP = SPA.CD_SALES_GROUP
                           AND PB.NU_CARTEIRA_VERSION =
                               SPA.NU_CARTEIRA_VERSION
                           AND ROWNUM = 1),  SPA.NO_SALES_GROUP) NO_SALES_GROUP,

SPA.CD_AGENTE_VENDA, SPA.NO_AGENTE,
SPA.DH_VENCIMENTO_PEDIDO, SPA.DT_CREDITO,
SPA.DT_INICIO, SPA.DT_FIM, SPA.DH_INCLUSAO, SPA.DH_ENTREGA,
SPA.SG_ESTADO, SPA.NO_MUNICIPIO,
SPA.DS_BAIRRO, SPA.CD_PRODUTO_SAP,
SPA.QT_PROGRAMADA, SPA.NO_PRODUTO_SAP, SPA.QT_ENTREGUE, SPA.QT_SALDO,
SPA.VL_UNITARIO,SPA.VL_BRL, SPA.VL_TAXA_DOLAR, SPA.VL_USD,
SPA.PC_COMISSAO, SPA.CD_SACARIA, SPA.DS_SACARIA,
SPA.CD_CULTURA_SAP, SPA.DS_CULTURA_SAP,
SPA.CD_BLOQUEIO_REMESSA, SPA.CD_BLOQUEIO_FATURAMENTO,
SPA.CD_BLOQUEIO_CREDITO, SPA.CD_BLOQUEIO_REMESSA_ITEM,
SPA.CD_BLOQUEIO_FATURAMENTO_ITEM, SPA.CD_MOTIVO_RECUSA,
SPA.CD_LOGIN,
SPA.CD_SEGMENTACAO_CLIENTE, SPA.DS_SEGMENTACAO_CLIENTE,
SPA.DS_SEGMENTO_CLIENTE_SAP, SPA.CD_FORMA_PAGAMENTO,
SPA.CD_TIPO_PAGAMENTO, SPA.DS_TIPO_PAGAMENTO,
SPA.CD_AGRUPAMENTO, SPA.CD_BLOQUEIO_ENTREGA,
SPA.NU_CNPJ, SPA.NU_CPF,
SPA.NU_INSCRICAO_ESTADUAL, SPA.NU_INSCRICAO_MUNICIPAL,
SPA.NU_CEP, SPA.DS_ENDERECO_RECEBEDOR,
SPA.CD_CLIENTE_RECEBEDOR, SPA.NO_CLIENTE_RECEBEDOR,
SPA.CD_MOEDA, SPA.CD_SUPPLY_GROUP,
SPA.DS_VENDA_COMPARTILHADA,  SPA.CD_STATUS_LIBERACAO,
SPA.CD_ITEM_PEDIDO, 
SPA.CD_CLIENTE_PAGADOR, SPA.NO_CLIENTE_PAGADOR,
SPA.VL_FRETE_DISTRIBUICAO,  SPA.CD_GRUPO_EMBALAGEM,
SPA.DS_CREDIT_BLOCK_REASON, SPA.DH_CREDIT_BLOCK,
         
SPA.CD_ITEM_CONTRATO , 

SPA.DS_ROTEIRO_ENTREGA,
SPA.DS_ENDERECO_PAGADOR, 

           NVL (
               (SELECT PB.NO_SALES_DISTRICT
                  FROM CTE_SALES_GROUP PB
                 WHERE     PB.CD_SALES_GROUP = SPA.CD_SALES_GROUP
                       AND PB.NU_CARTEIRA_VERSION = SPA.NU_CARTEIRA_VERSION
                       AND ROWNUM = 1), SPA.NO_SALES_DISTRICT)
               NO_SALES_DISTRICT,

--(NVL((SELECT CE.DS_CENTRO_EXPEDIDOR 
--FROM CTF.CENTRO_EXPEDIDOR CE 
--WHERE CE.CD_CENTRO_EXPEDIDOR = SPA.CD_CENTRO_EXPEDIDOR), SPA.DS_CENTRO_EXPEDIDOR)) DS_CENTRO_EXPEDIDOR_FIX
'----'  DS_CENTRO_EXPEDIDOR_FIX,
'0000' CD_CENTRO_EXPEDIDOR_FIX
  

FROM VND.ELO_CARTEIRA_SAP SPA
WHERE SPA.NU_CARTEIRA_VERSION = PI_NU_CARTEIRA_VERSION
), 

CTE_UNIQUE_PRODUTO AS 
(
SELECT 
GRP.CD_SALES_ORG, 
GRP.CD_PRODUTO_SAP, 
MAX(GRP.NO_PRODUTO_SAP) NO_PRODUTO_SAP
FROM CTE_BEFORE_GROUP9999 GRP
WHERE GRP.CD_MOEDA  = 'BRL'
GROUP BY 
GRP.CD_SALES_ORG, 
GRP.CD_PRODUTO_SAP
UNION 

SELECT 
XGRP.CD_SALES_ORG,
XGRP.CD_PRODUTO_SAP, 
MAX(XGRP.NO_PRODUTO_SAP) NO_PRODUTO_SAP
FROM CTE_BEFORE_GROUP9999 XGRP
WHERE NVL(XGRP.CD_MOEDA, 'XXX') <> 'BRL'
AND NOT EXISTS (SELECT DISTINCT 1 
                    FROM CTE_BEFORE_GROUP9999 TR 
                    WHERE TR.CD_SALES_ORG = XGRP.CD_SALES_ORG
                    AND TR.CD_PRODUTO_SAP = XGRP.CD_PRODUTO_SAP
                    AND TR.CD_MOEDA = 'BRL'
                )

GROUP BY 
XGRP.CD_SALES_ORG,
XGRP.CD_PRODUTO_SAP

)


SELECT 

MAX(SAP99.CD_ELO_CARTEIRA_SAP)  CD_ELO_CARTEIRA_SAP ,
SAP99.CD_SOURCE_CARTEIRA 	,
SAP99.NU_CARTEIRA_VERSION   ,
MAX(SAP99.CD_CENTRO_EXPEDIDOR) CD_CENTRO_EXPEDIDOR ,
MAX(SAP99.DS_CENTRO_EXPEDIDOR) DS_CENTRO_EXPEDIDOR	,
SAP99.DH_CARTEIRA 		    ,
SAP99.CD_SALES_ORG 		    ,
SAP99.NU_CONTRATO_SAP  	    ,
SAP99.CD_TIPO_CONTRATO 	    ,
SAP99.NU_CONTRATO_SUBSTITUI ,
MAX(SAP99.DT_PAGO) DT_PAGO  ,
SAP99.NU_CONTRATO		    ,	
SAP99.NU_ORDEM_VENDA 	    ,
SAP99.DS_STATUS_CONTRATO_SAP,
SAP99.CD_CLIENTE 			,	
SAP99.NO_CLIENTE 			,	
SAP99.CD_SALES_DISTRICT 	,	
SAP99.CD_INCOTERMS 			,
SAP99.CD_SALES_OFFICE		,	
SAP99.NO_SALES_OFFICE 		,
SAP99.CD_SALES_GROUP 		,	
SAP99.NO_SALES_GROUP 		,	
SAP99.CD_AGENTE_VENDA		,	
SAP99.NO_AGENTE 			,	
MAX(SAP99.DH_VENCIMENTO_PEDIDO ) DH_VENCIMENTO_PEDIDO	,
MAX(SAP99.DT_CREDITO) DT_CREDITO 			,	
SAP99.DT_INICIO 			,	
SAP99.DT_FIM				,	
MAX(SAP99.DH_INCLUSAO ) DH_INCLUSAO			,
MAX(SAP99.DH_ENTREGA) DH_ENTREGA 			,	
SAP99.SG_ESTADO 			,	
SAP99.NO_MUNICIPIO 			,
SAP99.DS_BAIRRO 			,	
SAP99.CD_PRODUTO_SAP		,	
sum(nvl(SAP99.QT_PROGRAMADA,0)) QT_PROGRAMADA 		,
	
--max(SAP99.NO_PRODUTO_SAP) NO_PRODUTO_SAP		,	
MAX(
NVL((SELECT UPS.NO_PRODUTO_SAP 
FROM CTE_UNIQUE_PRODUTO UPS
WHERE UPS.CD_SALES_ORG = SAP99.CD_SALES_ORG
AND UPS.CD_PRODUTO_SAP = SAP99.CD_PRODUTO_SAP
AND ROWNUM = 1 
), SAP99.NO_PRODUTO_SAP)
) NO_PRODUTO_SAP,

SUM(NVL(SAP99.QT_ENTREGUE,0)) QT_ENTREGUE  			,
SUM(NVL(SAP99.QT_SALDO,0)) QT_SALDO 				,
MAX(SAP99.VL_UNITARIO) VL_UNITARIO 			,
SUM(NVL(SAP99.VL_BRL,0)) VL_BRL				,	
MAX(SAP99.VL_TAXA_DOLAR) VL_TAXA_DOLAR 		,	
SUM(NVL(SAP99.VL_USD,0)) VL_USD 				,	
SAP99.PC_COMISSAO 			,
MAX(SAP99.CD_SACARIA) CD_SACARIA 			,	
MAX(SAP99.DS_SACARIA) DS_SACARIA 			,	
SAP99.CD_CULTURA_SAP 	        ,
SAP99.DS_CULTURA_SAP 	        ,
MAX(SAP99.CD_BLOQUEIO_REMESSA) CD_BLOQUEIO_REMESSA       ,
MAX(SAP99.CD_BLOQUEIO_FATURAMENTO ) CD_BLOQUEIO_FATURAMENTO  ,
MAX(SAP99.CD_BLOQUEIO_CREDITO) CD_BLOQUEIO_CREDITO		,
MAX(SAP99.CD_BLOQUEIO_REMESSA_ITEM) CD_BLOQUEIO_REMESSA_ITEM  ,
MAX(SAP99.CD_BLOQUEIO_FATURAMENTO_ITEM) CD_BLOQUEIO_FATURAMENTO_ITEM, 
MAX(SAP99.CD_MOTIVO_RECUSA) CD_MOTIVO_RECUSA			,
SAP99.CD_LOGIN 					,
SAP99.CD_SEGMENTACAO_CLIENTE 	,	
SAP99.DS_SEGMENTACAO_CLIENTE 	,	
SAP99.DS_SEGMENTO_CLIENTE_SAP	,	
SAP99.CD_FORMA_PAGAMENTO 		,	
SAP99.CD_TIPO_PAGAMENTO 		,	
SAP99.DS_TIPO_PAGAMENTO 		,	
SAP99.CD_AGRUPAMENTO			,	
MAX(SAP99.CD_BLOQUEIO_ENTREGA) CD_BLOQUEIO_ENTREGA 		,
SAP99.NU_CNPJ 					,
SAP99.NU_CPF 					,	
SAP99.NU_INSCRICAO_ESTADUAL 	,	
SAP99.NU_INSCRICAO_MUNICIPAL	,	
SAP99.NU_CEP 					,	
SAP99.DS_ENDERECO_RECEBEDOR 	,	
SAP99.CD_CLIENTE_RECEBEDOR 		,
SAP99.NO_CLIENTE_RECEBEDOR		,
SAP99.CD_MOEDA 					,
MAX(SAP99.CD_SUPPLY_GROUP)  CD_SUPPLY_GROUP,
MAX(SAP99.DS_VENDA_COMPARTILHADA) DS_VENDA_COMPARTILHADA	,	
SAP99.CD_STATUS_LIBERACAO		,	
--SAP99.CD_ITEM_PEDIDO 			,

CASE WHEN (SELECT COUNT(CC.CD_ITEM_PEDIDO) CD_ITEM_PEDIDO 
    FROM CTE_BEFORE_GROUP9999 CC
    WHERE 
    CC.NU_CARTEIRA_VERSION = SAP99.NU_CARTEIRA_VERSION
    AND CC.NU_CONTRATO_SAP = SAP99.NU_CONTRATO_SAP
    AND CC.CD_ITEM_CONTRATO = SAP99.CD_ITEM_CONTRATO
    AND CC.NU_ORDEM_VENDA = SAP99.NU_ORDEM_VENDA
    AND CC.CD_PRODUTO_SAP = SAP99.CD_PRODUTO_SAP) <= 1 THEN MAX(SAP99.CD_ITEM_PEDIDO)
     
ELSE 9999 END CD_ITEM_PEDIDO,	
SAP99.CD_CLIENTE_PAGADOR		,	
SAP99.NO_CLIENTE_PAGADOR 		,	
MAX(SAP99.VL_FRETE_DISTRIBUICAO) VL_FRETE_DISTRIBUICAO		,
MAX(SAP99.CD_GRUPO_EMBALAGEM) CD_GRUPO_EMBALAGEM 		,	
MAX(SAP99.DS_CREDIT_BLOCK_REASON) DS_CREDIT_BLOCK_REASON 	,	
MAX(SAP99.DH_CREDIT_BLOCK ) DH_CREDIT_BLOCK			,
SAP99.CD_ITEM_CONTRATO			,


MAX(SAP99.DS_ROTEIRO_ENTREGA) DS_ROTEIRO_ENTREGA 		,	
SAP99.DS_ENDERECO_PAGADOR 		,
SAP99.NO_SALES_DISTRICT			,

MAX(( 
SELECT CE.DS_CENTRO_EXPEDIDOR 
FROM CTF.CENTRO_EXPEDIDOR CE 
WHERE CE.CD_CENTRO_EXPEDIDOR = 
    (SELECT MAX(CC.CD_CENTRO_EXPEDIDOR) CD_CENTRO 
    FROM CTE_BEFORE_GROUP9999 CC
    WHERE 
    CC.NU_CARTEIRA_VERSION = SAP99.NU_CARTEIRA_VERSION
    AND CC.NU_CONTRATO_SAP = SAP99.NU_CONTRATO_SAP
    AND CC.CD_ITEM_CONTRATO = SAP99.CD_ITEM_CONTRATO
    AND NVL(CC.NU_ORDEM_VENDA,'0') = NVL(SAP99.NU_ORDEM_VENDA,'0')
    AND CC.CD_PRODUTO_SAP = SAP99.CD_PRODUTO_SAP))) DS_CENTRO_EXPEDIDOR_FIX,

MAX((SELECT MAX(CC.CD_CENTRO_EXPEDIDOR) CD_CENTRO 
    FROM CTE_BEFORE_GROUP9999 CC
    WHERE 
    CC.NU_CARTEIRA_VERSION = SAP99.NU_CARTEIRA_VERSION
    AND CC.NU_CONTRATO_SAP = SAP99.NU_CONTRATO_SAP
    AND CC.CD_ITEM_CONTRATO = SAP99.CD_ITEM_CONTRATO
    AND NVL(CC.NU_ORDEM_VENDA,'0') = NVL(SAP99.NU_ORDEM_VENDA, '0')
    AND CC.CD_PRODUTO_SAP = SAP99.CD_PRODUTO_SAP)) CD_CENTRO_EXPEDIDOR_FIX      

FROM CTE_BEFORE_GROUP9999 SAP99

GROUP BY 

SAP99.CD_SOURCE_CARTEIRA 	,
SAP99.NU_CARTEIRA_VERSION   ,
--SAP99.CD_CENTRO_EXPEDIDOR   ,
--SAP99.DS_CENTRO_EXPEDIDOR	,
SAP99.DH_CARTEIRA 		    ,
SAP99.CD_SALES_ORG 		    ,
SAP99.NU_CONTRATO_SAP  	    ,
SAP99.CD_TIPO_CONTRATO 	    ,
SAP99.NU_CONTRATO_SUBSTITUI ,
SAP99.NU_CONTRATO		    ,	
SAP99.NU_ORDEM_VENDA 	    ,
SAP99.DS_STATUS_CONTRATO_SAP,
SAP99.CD_CLIENTE 			,	
SAP99.NO_CLIENTE 			,	
SAP99.CD_SALES_DISTRICT 	,	
SAP99.CD_INCOTERMS 			,
SAP99.CD_SALES_OFFICE		,	
SAP99.NO_SALES_OFFICE 		,
SAP99.CD_SALES_GROUP 		,	
SAP99.NO_SALES_GROUP 		,	
SAP99.CD_AGENTE_VENDA		,	
SAP99.NO_AGENTE 			,	
SAP99.DT_INICIO 			,	
SAP99.DT_FIM				,	
SAP99.SG_ESTADO 			,	
SAP99.NO_MUNICIPIO 			,
SAP99.DS_BAIRRO 			,	
SAP99.CD_PRODUTO_SAP		,	
--SAP99.NO_PRODUTO_SAP 		,	
SAP99.PC_COMISSAO 			,
SAP99.CD_CULTURA_SAP 	        ,
SAP99.DS_CULTURA_SAP 	        ,
SAP99.CD_LOGIN 					,
SAP99.CD_SEGMENTACAO_CLIENTE 	,	
SAP99.DS_SEGMENTACAO_CLIENTE 	,	
SAP99.DS_SEGMENTO_CLIENTE_SAP	,	
SAP99.CD_FORMA_PAGAMENTO 		,	
SAP99.CD_TIPO_PAGAMENTO 		,	
SAP99.DS_TIPO_PAGAMENTO 		,	
SAP99.CD_AGRUPAMENTO			,	
SAP99.NU_CNPJ 					,
SAP99.NU_CPF 					,	
SAP99.NU_INSCRICAO_ESTADUAL 	,	
SAP99.NU_INSCRICAO_MUNICIPAL	,	
SAP99.NU_CEP 					,	
SAP99.DS_ENDERECO_RECEBEDOR 	,	
SAP99.CD_CLIENTE_RECEBEDOR 		,
SAP99.NO_CLIENTE_RECEBEDOR		,
SAP99.CD_MOEDA 					,

SAP99.CD_STATUS_LIBERACAO		,	
SAP99.CD_CLIENTE_PAGADOR		,	
SAP99.NO_CLIENTE_PAGADOR 		,	

SAP99.CD_ITEM_CONTRATO			,
SAP99.DS_ENDERECO_PAGADOR 		,
SAP99.NO_SALES_DISTRICT			--,
--SAP99.DS_CENTRO_EXPEDIDOR_FIX  

;

V_LIMIT NUMBER:=30000;


TYPE elo_carteira_sap_r IS RECORD
(

CD_ELO_CARTEIRA_SAP 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_ELO_CARTEIRA_SAP%TYPE,
CD_SOURCE_CARTEIRA 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_SOURCE_CARTEIRA%TYPE,
NU_CARTEIRA_VERSION 			VND.ELO_CARTEIRA_SAP_IMPORT.NU_CARTEIRA_VERSION%TYPE,
CD_CENTRO_EXPEDIDOR 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_CENTRO_EXPEDIDOR%TYPE,
DS_CENTRO_EXPEDIDOR				VND.ELO_CARTEIRA_SAP_IMPORT.DS_CENTRO_EXPEDIDOR%TYPE,
DH_CARTEIRA 					VND.ELO_CARTEIRA_SAP_IMPORT.DH_CARTEIRA%TYPE,
CD_SALES_ORG 					VND.ELO_CARTEIRA_SAP_IMPORT.CD_SALES_ORG%TYPE,
NU_CONTRATO_SAP  				VND.ELO_CARTEIRA_SAP_IMPORT.NU_CONTRATO_SAP%TYPE,
CD_TIPO_CONTRATO 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_TIPO_CONTRATO%TYPE,
NU_CONTRATO_SUBSTITUI			VND.ELO_CARTEIRA_SAP_IMPORT.NU_CONTRATO_SUBSTITUI%TYPE,
DT_PAGO 						VND.ELO_CARTEIRA_SAP_IMPORT.DT_PAGO%TYPE,
NU_CONTRATO						VND.ELO_CARTEIRA_SAP_IMPORT.NU_CONTRATO%TYPE,
 NU_ORDEM_VENDA 				VND.ELO_CARTEIRA_SAP_IMPORT.NU_ORDEM_VENDA%TYPE,
 DS_STATUS_CONTRATO_SAP			VND.ELO_CARTEIRA_SAP_IMPORT.DS_STATUS_CONTRATO_SAP%TYPE,
CD_CLIENTE 						VND.ELO_CARTEIRA_SAP_IMPORT.CD_CLIENTE%TYPE,
NO_CLIENTE 						VND.ELO_CARTEIRA_SAP_IMPORT.NO_CLIENTE%TYPE,
CD_SALES_DISTRICT 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_SALES_DISTRICT%TYPE,
CD_INCOTERMS 					VND.ELO_CARTEIRA_SAP_IMPORT.CD_INCOTERMS%TYPE,
CD_SALES_OFFICE					VND.ELO_CARTEIRA_SAP_IMPORT.CD_SALES_OFFICE%TYPE,
NO_SALES_OFFICE 				VND.ELO_CARTEIRA_SAP_IMPORT.NO_SALES_OFFICE%TYPE,
CD_SALES_GROUP 					VND.ELO_CARTEIRA_SAP_IMPORT.CD_SALES_GROUP%TYPE,
NO_SALES_GROUP 					VND.ELO_CARTEIRA_SAP_IMPORT.NO_SALES_GROUP%TYPE,
CD_AGENTE_VENDA					VND.ELO_CARTEIRA_SAP_IMPORT.CD_AGENTE_VENDA%TYPE,
NO_AGENTE 						VND.ELO_CARTEIRA_SAP_IMPORT.NO_AGENTE%TYPE,
DH_VENCIMENTO_PEDIDO 			VND.ELO_CARTEIRA_SAP_IMPORT.DH_VENCIMENTO_PEDIDO%TYPE,
DT_CREDITO 						VND.ELO_CARTEIRA_SAP_IMPORT.DT_CREDITO%TYPE ,
DT_INICIO 						VND.ELO_CARTEIRA_SAP_IMPORT.DT_INICIO%TYPE,
DT_FIM							VND.ELO_CARTEIRA_SAP_IMPORT.DT_FIM%TYPE,
DH_INCLUSAO 					VND.ELO_CARTEIRA_SAP_IMPORT.DH_INCLUSAO%TYPE,
DH_ENTREGA 						VND.ELO_CARTEIRA_SAP_IMPORT.DH_ENTREGA%TYPE,
SG_ESTADO 						VND.ELO_CARTEIRA_SAP_IMPORT.SG_ESTADO%TYPE,
NO_MUNICIPIO 					VND.ELO_CARTEIRA_SAP_IMPORT.NO_MUNICIPIO%TYPE,
DS_BAIRRO 						VND.ELO_CARTEIRA_SAP_IMPORT.DS_BAIRRO%TYPE,
CD_PRODUTO_SAP					VND.ELO_CARTEIRA_SAP_IMPORT.CD_PRODUTO_SAP%TYPE,
QT_PROGRAMADA 					VND.ELO_CARTEIRA_SAP_IMPORT.QT_PROGRAMADA%TYPE,
NO_PRODUTO_SAP 					VND.ELO_CARTEIRA_SAP_IMPORT.NO_PRODUTO_SAP%TYPE,
QT_ENTREGUE 					VND.ELO_CARTEIRA_SAP_IMPORT.QT_ENTREGUE%TYPE,
QT_SALDO 						VND.ELO_CARTEIRA_SAP_IMPORT.QT_SALDO%TYPE,
VL_UNITARIO 					VND.ELO_CARTEIRA_SAP_IMPORT.VL_UNITARIO%TYPE,
VL_BRL							VND.ELO_CARTEIRA_SAP_IMPORT.VL_BRL%TYPE,
VL_TAXA_DOLAR 					VND.ELO_CARTEIRA_SAP_IMPORT.VL_TAXA_DOLAR%TYPE,
VL_USD 							VND.ELO_CARTEIRA_SAP_IMPORT.VL_USD%TYPE,
PC_COMISSAO 					VND.ELO_CARTEIRA_SAP_IMPORT.PC_COMISSAO%TYPE,
CD_SACARIA 						VND.ELO_CARTEIRA_SAP_IMPORT.CD_SACARIA%TYPE,
DS_SACARIA 						VND.ELO_CARTEIRA_SAP_IMPORT.DS_SACARIA%TYPE,
CD_CULTURA_SAP					VND.ELO_CARTEIRA_SAP_IMPORT.CD_CULTURA_SAP%TYPE,
DS_CULTURA_SAP 					VND.ELO_CARTEIRA_SAP_IMPORT.DS_CULTURA_SAP%TYPE,
CD_BLOQUEIO_REMESSA 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_BLOQUEIO_REMESSA%TYPE,
CD_BLOQUEIO_FATURAMENTO 		VND.ELO_CARTEIRA_SAP_IMPORT.CD_BLOQUEIO_FATURAMENTO%TYPE,
CD_BLOQUEIO_CREDITO				VND.ELO_CARTEIRA_SAP_IMPORT.CD_BLOQUEIO_CREDITO%TYPE,
CD_BLOQUEIO_REMESSA_ITEM 		VND.ELO_CARTEIRA_SAP_IMPORT.CD_BLOQUEIO_REMESSA_ITEM%TYPE,
CD_BLOQUEIO_FATURAMENTO_ITEM 	VND.ELO_CARTEIRA_SAP_IMPORT.CD_BLOQUEIO_FATURAMENTO_ITEM%TYPE,
CD_MOTIVO_RECUSA				VND.ELO_CARTEIRA_SAP_IMPORT.CD_MOTIVO_RECUSA%TYPE,
CD_LOGIN 						VND.ELO_CARTEIRA_SAP_IMPORT.CD_LOGIN%TYPE,
CD_SEGMENTACAO_CLIENTE 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_SEGMENTACAO_CLIENTE%TYPE,
DS_SEGMENTACAO_CLIENTE 			VND.ELO_CARTEIRA_SAP_IMPORT.DS_SEGMENTACAO_CLIENTE%TYPE,
DS_SEGMENTO_CLIENTE_SAP			VND.ELO_CARTEIRA_SAP_IMPORT.DS_SEGMENTO_CLIENTE_SAP%TYPE,
CD_FORMA_PAGAMENTO 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_FORMA_PAGAMENTO%TYPE,
CD_TIPO_PAGAMENTO 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_TIPO_PAGAMENTO%TYPE,
DS_TIPO_PAGAMENTO 				VND.ELO_CARTEIRA_SAP_IMPORT.DS_TIPO_PAGAMENTO%TYPE,
CD_AGRUPAMENTO					VND.ELO_CARTEIRA_SAP_IMPORT.CD_AGRUPAMENTO%TYPE,
CD_BLOQUEIO_ENTREGA 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_BLOQUEIO_ENTREGA%TYPE,
NU_CNPJ 						VND.ELO_CARTEIRA_SAP_IMPORT.NU_CNPJ%TYPE,
NU_CPF 							VND.ELO_CARTEIRA_SAP_IMPORT.NU_CPF%TYPE,
NU_INSCRICAO_ESTADUAL 			VND.ELO_CARTEIRA_SAP_IMPORT.NU_INSCRICAO_ESTADUAL%TYPE,
NU_INSCRICAO_MUNICIPAL			VND.ELO_CARTEIRA_SAP_IMPORT.NU_INSCRICAO_MUNICIPAL%TYPE,
NU_CEP 							VND.ELO_CARTEIRA_SAP_IMPORT.NU_CEP%TYPE,
DS_ENDERECO_RECEBEDOR 			VND.ELO_CARTEIRA_SAP_IMPORT.DS_ENDERECO_RECEBEDOR%TYPE,
CD_CLIENTE_RECEBEDOR 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_CLIENTE_RECEBEDOR%TYPE,
NO_CLIENTE_RECEBEDOR			VND.ELO_CARTEIRA_SAP_IMPORT.NO_CLIENTE_RECEBEDOR%TYPE,
CD_MOEDA 						VND.ELO_CARTEIRA_SAP_IMPORT.CD_MOEDA%TYPE,
CD_SUPPLY_GROUP 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_SUPPLY_GROUP%TYPE,
DS_VENDA_COMPARTILHADA 			VND.ELO_CARTEIRA_SAP_IMPORT.DS_VENDA_COMPARTILHADA%TYPE,
CD_STATUS_LIBERACAO				VND.ELO_CARTEIRA_SAP_IMPORT.CD_STATUS_LIBERACAO%TYPE,
CD_ITEM_PEDIDO 					VND.ELO_CARTEIRA_SAP_IMPORT.CD_ITEM_PEDIDO%TYPE,
CD_CLIENTE_PAGADOR				VND.ELO_CARTEIRA_SAP_IMPORT.CD_CLIENTE_PAGADOR%TYPE,
NO_CLIENTE_PAGADOR 				VND.ELO_CARTEIRA_SAP_IMPORT.NO_CLIENTE_PAGADOR%TYPE,
VL_FRETE_DISTRIBUICAO			VND.ELO_CARTEIRA_SAP_IMPORT.VL_FRETE_DISTRIBUICAO%TYPE,
CD_GRUPO_EMBALAGEM 				VND.ELO_CARTEIRA_SAP_IMPORT.CD_GRUPO_EMBALAGEM%TYPE,
DS_CREDIT_BLOCK_REASON 			VND.ELO_CARTEIRA_SAP_IMPORT.DS_CREDIT_BLOCK_REASON%TYPE,
DH_CREDIT_BLOCK 				VND.ELO_CARTEIRA_SAP_IMPORT.DH_CREDIT_BLOCK%TYPE,
CD_ITEM_CONTRATO					VND.ELO_CARTEIRA_SAP_IMPORT.CD_ITEM_CONTRATO%TYPE,
DS_ROTEIRO_ENTREGA 				VND.ELO_CARTEIRA_SAP_IMPORT.DS_ROTEIRO_ENTREGA%TYPE,
DS_ENDERECO_PAGADOR 			VND.ELO_CARTEIRA_SAP_IMPORT.DS_ENDERECO_PAGADOR%TYPE,
NO_SALES_DISTRICT				VND.ELO_CARTEIRA_SAP_IMPORT.NO_SALES_DISTRICT%TYPE,
DS_CENTRO_EXPEDIDOR_FIX         VND.ELO_CARTEIRA_SAP_IMPORT.DS_CENTRO_EXPEDIDOR%TYPE,
CD_CENTRO_EXPEDIDOR_FIX 			VND.ELO_CARTEIRA_SAP_IMPORT.CD_CENTRO_EXPEDIDOR%TYPE

); 

TYPE elo_carteira_sap_t IS TABLE OF elo_carteira_sap_r
INDEX BY PLS_INTEGER;
tof_elo_carteira_sap elo_carteira_sap_t;

tof_elo_carteira_sap_parcial elo_carteira_sap_t;





BEGIN 

    BEGIN
    SELECT min(DD.dh_carteira) + 2.22 INTO  V_DH_LIMITE
    FROM VND.ELO_CARTEIRA_SAP DD 
    WHERE DD.dh_carteira > (CURRENT_DATE - V_ADD_DAY_CARTEIRA_FILTER);
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        V_DH_LIMITE:=CURRENT_DATE +2.22;
    WHEN OTHERS THEN 
        V_DH_LIMITE:=CURRENT_DATE +2.22;
    END;

    


    open VERS ;
    fetch VERS bulk collect into tof_elo_sap limit 1; 
    close VERS; 
    
    IF tof_elo_sap.COUNT > 0 THEN 
    BEGIN 
    
        FOR i_elo_sap in tof_elo_sap.FIRST .. tof_elo_sap.LAST
        LOOP
        
            IF tof_elo_sap(i_elo_sap).TEM_PARCIAL >= 1 THEN 
                tof_tem_parcial_elo_sap(tof_tem_parcial_elo_sap.COUNT+1).NU_CARTEIRA_VERSION:=tof_elo_sap(i_elo_sap).NU_CARTEIRA_VERSION;
                tof_tem_parcial_elo_sap(tof_tem_parcial_elo_sap.COUNT).TEM_PARCIAL:=tof_elo_sap(i_elo_sap).TEM_PARCIAL;
            END IF;
        
        END LOOP;
        
        IF tof_tem_parcial_elo_sap.COUNT > 0 THEN 
        BEGIN
        
            FOR i_parcial in tof_tem_parcial_elo_sap.FIRST .. tof_tem_parcial_elo_sap.LAST
            LOOP
                BEGIN
                    open C_DELETEIMPORT(tof_tem_parcial_elo_sap(i_parcial).NU_CARTEIRA_VERSION) ;
                    fetch C_DELETEIMPORT bulk collect into tof_delete_import limit V_LIMIT; 
                    close C_DELETEIMPORT; 
                    
                    IF tof_delete_import.COUNT > 0 THEN 
                
                        BEGIN
                            FORALL i_ctdelete in INDICES OF tof_delete_import
                            DELETE FROM VND.ELO_CARTEIRA_SAP_IMPORT imp
                            WHERE imp.CD_ELO_CARTEIRA_SAP = tof_delete_import(i_ctdelete).CD_ELO_CARTEIRA_SAP; 
                            COMMIT;
                            
                            EXCEPTION  
                            WHEN OTHERS THEN 
                            BEGIN
                            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.603 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                            ROLLBACK;
                            END;
                            
                        END;
                    
                    END IF;
                    
                END;


            END LOOP;
            
        
        
   
        
        END;
        END IF;
        
        
        tof_elo_carteira_sap.DELETE;

        FOR i_ctupdate in tof_elo_sap.FIRST .. tof_elo_sap.LAST
        LOOP    
        begin 


            P_NU_CARTEIRA_VERSION:=tof_elo_sap(i_ctupdate).NU_CARTEIRA_VERSION;
            
            BEGIN 
            OPEN    C_WHO_UPDATE (P_NU_CARTEIRA_VERSION);                               
            FETCH   C_WHO_UPDATE BULK COLLECT INTO tof_elo_carteira_sap_parcial LIMIT V_LIMIT;
            CLOSE   C_WHO_UPDATE;
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            --ROLLBACK;
            END;
            
            END;
            
            IF tof_elo_carteira_sap_parcial.COUNT > 0 THEN 
            
            

            
                FOR i_cartrepl in tof_elo_carteira_sap_parcial.FIRST .. tof_elo_carteira_sap_parcial.LAST
                LOOP
                BEGIN

                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT +1).CD_ELO_CARTEIRA_SAP:=tof_elo_carteira_sap_parcial(i_cartrepl).CD_ELO_CARTEIRA_SAP;

                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SOURCE_CARTEIRA :=  tof_elo_carteira_sap_parcial(i_cartrepl).CD_SOURCE_CARTEIRA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CARTEIRA_VERSION := tof_elo_carteira_sap_parcial(i_cartrepl).NU_CARTEIRA_VERSION ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_CENTRO_EXPEDIDOR := tof_elo_carteira_sap_parcial(i_cartrepl).CD_CENTRO_EXPEDIDOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_CENTRO_EXPEDIDOR := tof_elo_carteira_sap_parcial(i_cartrepl).DS_CENTRO_EXPEDIDOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DH_CARTEIRA :=         tof_elo_carteira_sap_parcial(i_cartrepl).DH_CARTEIRA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SALES_ORG :=        tof_elo_carteira_sap_parcial(i_cartrepl).CD_SALES_ORG ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CONTRATO_SAP :=     tof_elo_carteira_sap_parcial(i_cartrepl).NU_CONTRATO_SAP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_TIPO_CONTRATO :=    tof_elo_carteira_sap_parcial(i_cartrepl).CD_TIPO_CONTRATO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CONTRATO_SUBSTITUI :=  tof_elo_carteira_sap_parcial(i_cartrepl).NU_CONTRATO_SUBSTITUI ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DT_PAGO :=             tof_elo_carteira_sap_parcial(i_cartrepl).DT_PAGO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CONTRATO :=         tof_elo_carteira_sap_parcial(i_cartrepl).NU_CONTRATO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_ORDEM_VENDA :=      tof_elo_carteira_sap_parcial(i_cartrepl).NU_ORDEM_VENDA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_STATUS_CONTRATO_SAP := tof_elo_carteira_sap_parcial(i_cartrepl).DS_STATUS_CONTRATO_SAP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_CLIENTE :=          tof_elo_carteira_sap_parcial(i_cartrepl).CD_CLIENTE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_CLIENTE :=          tof_elo_carteira_sap_parcial(i_cartrepl).NO_CLIENTE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SALES_DISTRICT :=   tof_elo_carteira_sap_parcial(i_cartrepl).CD_SALES_DISTRICT ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_INCOTERMS :=        tof_elo_carteira_sap_parcial(i_cartrepl).CD_INCOTERMS ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SALES_OFFICE :=     tof_elo_carteira_sap_parcial(i_cartrepl).CD_SALES_OFFICE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_SALES_OFFICE :=     tof_elo_carteira_sap_parcial(i_cartrepl).NO_SALES_OFFICE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SALES_GROUP :=      tof_elo_carteira_sap_parcial(i_cartrepl).CD_SALES_GROUP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_SALES_GROUP :=      tof_elo_carteira_sap_parcial(i_cartrepl).NO_SALES_GROUP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_AGENTE_VENDA  :=    tof_elo_carteira_sap_parcial(i_cartrepl).CD_AGENTE_VENDA  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_AGENTE :=           tof_elo_carteira_sap_parcial(i_cartrepl).NO_AGENTE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DH_VENCIMENTO_PEDIDO  :=  tof_elo_carteira_sap_parcial(i_cartrepl).DH_VENCIMENTO_PEDIDO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DT_CREDITO :=          tof_elo_carteira_sap_parcial(i_cartrepl).DT_CREDITO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DT_INICIO  :=          tof_elo_carteira_sap_parcial(i_cartrepl).DT_INICIO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DT_FIM :=              tof_elo_carteira_sap_parcial(i_cartrepl).DT_FIM ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DH_INCLUSAO  :=        tof_elo_carteira_sap_parcial(i_cartrepl).DH_INCLUSAO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DH_ENTREGA :=          tof_elo_carteira_sap_parcial(i_cartrepl).DH_ENTREGA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).SG_ESTADO  :=          tof_elo_carteira_sap_parcial(i_cartrepl).SG_ESTADO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_MUNICIPIO :=        tof_elo_carteira_sap_parcial(i_cartrepl).NO_MUNICIPIO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_BAIRRO :=           tof_elo_carteira_sap_parcial(i_cartrepl).DS_BAIRRO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_PRODUTO_SAP :=      tof_elo_carteira_sap_parcial(i_cartrepl).CD_PRODUTO_SAP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).QT_PROGRAMADA  :=      tof_elo_carteira_sap_parcial(i_cartrepl).QT_PROGRAMADA  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_PRODUTO_SAP  :=     tof_elo_carteira_sap_parcial(i_cartrepl).NO_PRODUTO_SAP  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).QT_ENTREGUE :=         tof_elo_carteira_sap_parcial(i_cartrepl).QT_ENTREGUE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).QT_SALDO :=            tof_elo_carteira_sap_parcial(i_cartrepl).QT_SALDO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).VL_UNITARIO :=         tof_elo_carteira_sap_parcial(i_cartrepl).VL_UNITARIO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).VL_BRL  :=             tof_elo_carteira_sap_parcial(i_cartrepl).VL_BRL  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).VL_TAXA_DOLAR  :=      tof_elo_carteira_sap_parcial(i_cartrepl).VL_TAXA_DOLAR  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).VL_USD :=              tof_elo_carteira_sap_parcial(i_cartrepl).VL_USD ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).PC_COMISSAO  :=        tof_elo_carteira_sap_parcial(i_cartrepl).PC_COMISSAO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SACARIA :=          tof_elo_carteira_sap_parcial(i_cartrepl).CD_SACARIA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_SACARIA :=          tof_elo_carteira_sap_parcial(i_cartrepl).DS_SACARIA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_CULTURA_SAP  :=     tof_elo_carteira_sap_parcial(i_cartrepl).CD_CULTURA_SAP  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_CULTURA_SAP :=      tof_elo_carteira_sap_parcial(i_cartrepl).DS_CULTURA_SAP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_BLOQUEIO_REMESSA  :=tof_elo_carteira_sap_parcial(i_cartrepl).CD_BLOQUEIO_REMESSA  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_BLOQUEIO_FATURAMENTO :=tof_elo_carteira_sap_parcial(i_cartrepl).CD_BLOQUEIO_FATURAMENTO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_BLOQUEIO_CREDITO  :=tof_elo_carteira_sap_parcial(i_cartrepl).CD_BLOQUEIO_CREDITO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_BLOQUEIO_REMESSA_ITEM:=tof_elo_carteira_sap_parcial(i_cartrepl).CD_BLOQUEIO_REMESSA_ITEM ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_BLOQUEIO_FATURAMENTO_ITEM:= tof_elo_carteira_sap_parcial(i_cartrepl).CD_BLOQUEIO_FATURAMENTO_ITEM  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_MOTIVO_RECUSA :=    tof_elo_carteira_sap_parcial(i_cartrepl).CD_MOTIVO_RECUSA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_LOGIN :=            tof_elo_carteira_sap_parcial(i_cartrepl).CD_LOGIN ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SEGMENTACAO_CLIENTE := tof_elo_carteira_sap_parcial(i_cartrepl).CD_SEGMENTACAO_CLIENTE  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_SEGMENTACAO_CLIENTE := tof_elo_carteira_sap_parcial(i_cartrepl).DS_SEGMENTACAO_CLIENTE ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_SEGMENTO_CLIENTE_SAP :=   tof_elo_carteira_sap_parcial(i_cartrepl).DS_SEGMENTO_CLIENTE_SAP  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_FORMA_PAGAMENTO :=  tof_elo_carteira_sap_parcial(i_cartrepl).CD_FORMA_PAGAMENTO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_TIPO_PAGAMENTO :=   tof_elo_carteira_sap_parcial(i_cartrepl).CD_TIPO_PAGAMENTO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_TIPO_PAGAMENTO :=   tof_elo_carteira_sap_parcial(i_cartrepl).DS_TIPO_PAGAMENTO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_AGRUPAMENTO  :=     tof_elo_carteira_sap_parcial(i_cartrepl).CD_AGRUPAMENTO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_BLOQUEIO_ENTREGA := tof_elo_carteira_sap_parcial(i_cartrepl).CD_BLOQUEIO_ENTREGA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CNPJ  :=            tof_elo_carteira_sap_parcial(i_cartrepl).NU_CNPJ  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CPF :=              tof_elo_carteira_sap_parcial(i_cartrepl).NU_CPF ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_INSCRICAO_ESTADUAL:=tof_elo_carteira_sap_parcial(i_cartrepl).NU_INSCRICAO_ESTADUAL  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_INSCRICAO_MUNICIPAL:=  tof_elo_carteira_sap_parcial(i_cartrepl).NU_INSCRICAO_MUNICIPAL ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NU_CEP  :=             tof_elo_carteira_sap_parcial(i_cartrepl).NU_CEP  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_ENDERECO_RECEBEDOR:=tof_elo_carteira_sap_parcial(i_cartrepl).DS_ENDERECO_RECEBEDOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_CLIENTE_RECEBEDOR :=tof_elo_carteira_sap_parcial(i_cartrepl).CD_CLIENTE_RECEBEDOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_CLIENTE_RECEBEDOR :=tof_elo_carteira_sap_parcial(i_cartrepl).NO_CLIENTE_RECEBEDOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_MOEDA :=            tof_elo_carteira_sap_parcial(i_cartrepl).CD_MOEDA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_SUPPLY_GROUP :=     tof_elo_carteira_sap_parcial(i_cartrepl).CD_SUPPLY_GROUP ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_VENDA_COMPARTILHADA := tof_elo_carteira_sap_parcial(i_cartrepl).DS_VENDA_COMPARTILHADA  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_STATUS_LIBERACAO := tof_elo_carteira_sap_parcial(i_cartrepl).CD_STATUS_LIBERACAO ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_ITEM_PEDIDO  :=     tof_elo_carteira_sap_parcial(i_cartrepl).CD_ITEM_PEDIDO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_CLIENTE_PAGADOR  := tof_elo_carteira_sap_parcial(i_cartrepl).CD_CLIENTE_PAGADOR  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_CLIENTE_PAGADOR :=  tof_elo_carteira_sap_parcial(i_cartrepl).NO_CLIENTE_PAGADOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).VL_FRETE_DISTRIBUICAO:=tof_elo_carteira_sap_parcial(i_cartrepl).VL_FRETE_DISTRIBUICAO   ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_GRUPO_EMBALAGEM :=  tof_elo_carteira_sap_parcial(i_cartrepl).CD_GRUPO_EMBALAGEM ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_CREDIT_BLOCK_REASON:=  tof_elo_carteira_sap_parcial(i_cartrepl).DS_CREDIT_BLOCK_REASON  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DH_CREDIT_BLOCK :=     tof_elo_carteira_sap_parcial(i_cartrepl).DH_CREDIT_BLOCK ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_ITEM_CONTRATO  :=   tof_elo_carteira_sap_parcial(i_cartrepl).CD_ITEM_CONTRATO  ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_ROTEIRO_ENTREGA :=  tof_elo_carteira_sap_parcial(i_cartrepl).DS_ROTEIRO_ENTREGA ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_ENDERECO_PAGADOR := tof_elo_carteira_sap_parcial(i_cartrepl).DS_ENDERECO_PAGADOR ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).NO_SALES_DISTRICT :=   tof_elo_carteira_sap_parcial(i_cartrepl).NO_SALES_DISTRICT ;                

                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).DS_CENTRO_EXPEDIDOR_FIX := tof_elo_carteira_sap_parcial(i_cartrepl).DS_CENTRO_EXPEDIDOR_FIX ;
                tof_elo_carteira_sap(tof_elo_carteira_sap.COUNT).CD_CENTRO_EXPEDIDOR_FIX :=   tof_elo_carteira_sap_parcial(i_cartrepl).CD_CENTRO_EXPEDIDOR_FIX ;                

 
                
                END;
                END LOOP;  
                
                tof_elo_carteira_sap_parcial.DELETE;          
            
            END IF;

            
        END;
        END LOOP;    
        
        
            
            
            IF tof_elo_carteira_sap.COUNT > 0 THEN
            
            
            
                FOR i_cccart in tof_elo_carteira_sap.FIRST .. tof_elo_carteira_sap.LAST
                LOOP
                    tof_elo_carteira_sap(i_cccart).DS_CENTRO_EXPEDIDOR:= 
                            NVL(tof_elo_carteira_sap(i_cccart).DS_CENTRO_EXPEDIDOR_FIX, tof_elo_carteira_sap(i_cccart).DS_CENTRO_EXPEDIDOR);
                    tof_elo_carteira_sap(i_cccart).CD_CENTRO_EXPEDIDOR:= 
                            NVL(tof_elo_carteira_sap(i_cccart).CD_CENTRO_EXPEDIDOR_FIX, tof_elo_carteira_sap(i_cccart).CD_CENTRO_EXPEDIDOR );
                END LOOP;
            


                BEGIN
                FORALL i_cart in INDICES OF tof_elo_carteira_sap

                INSERT INTO VND.ELO_CARTEIRA_SAP_IMPORT
                (CD_ELO_CARTEIRA_SAP, CD_SOURCE_CARTEIRA, NU_CARTEIRA_VERSION, CD_CENTRO_EXPEDIDOR, DS_CENTRO_EXPEDIDOR,
                DH_CARTEIRA, CD_SALES_ORG, NU_CONTRATO_SAP,  CD_TIPO_CONTRATO, NU_CONTRATO_SUBSTITUI,
                DT_PAGO, NU_CONTRATO, NU_ORDEM_VENDA, DS_STATUS_CONTRATO_SAP,
                CD_CLIENTE, NO_CLIENTE, CD_SALES_DISTRICT, CD_INCOTERMS, CD_SALES_OFFICE,
                NO_SALES_OFFICE, CD_SALES_GROUP, NO_SALES_GROUP, CD_AGENTE_VENDA,
                NO_AGENTE, DH_VENCIMENTO_PEDIDO, DT_CREDITO, DT_INICIO, DT_FIM,
                DH_INCLUSAO, DH_ENTREGA, SG_ESTADO, NO_MUNICIPIO, DS_BAIRRO, CD_PRODUTO_SAP,
                QT_PROGRAMADA, NO_PRODUTO_SAP, QT_ENTREGUE, QT_SALDO, VL_UNITARIO, VL_BRL,
                VL_TAXA_DOLAR, VL_USD, PC_COMISSAO, CD_SACARIA, DS_SACARIA, CD_CULTURA_SAP,
                DS_CULTURA_SAP, CD_BLOQUEIO_REMESSA, CD_BLOQUEIO_FATURAMENTO, CD_BLOQUEIO_CREDITO,
                CD_BLOQUEIO_REMESSA_ITEM, CD_BLOQUEIO_FATURAMENTO_ITEM, CD_MOTIVO_RECUSA,
                CD_LOGIN, CD_SEGMENTACAO_CLIENTE, DS_SEGMENTACAO_CLIENTE, DS_SEGMENTO_CLIENTE_SAP,
                CD_FORMA_PAGAMENTO, CD_TIPO_PAGAMENTO, DS_TIPO_PAGAMENTO, CD_AGRUPAMENTO,
                CD_BLOQUEIO_ENTREGA, NU_CNPJ, NU_CPF, NU_INSCRICAO_ESTADUAL, NU_INSCRICAO_MUNICIPAL,
                NU_CEP, DS_ENDERECO_RECEBEDOR, CD_CLIENTE_RECEBEDOR, NO_CLIENTE_RECEBEDOR,
                CD_MOEDA, CD_SUPPLY_GROUP, DS_VENDA_COMPARTILHADA, CD_STATUS_LIBERACAO,
                CD_ITEM_PEDIDO, CD_CLIENTE_PAGADOR, NO_CLIENTE_PAGADOR, VL_FRETE_DISTRIBUICAO,
                CD_GRUPO_EMBALAGEM, DS_CREDIT_BLOCK_REASON, DH_CREDIT_BLOCK, CD_ITEM_CONTRATO,
                DS_ROTEIRO_ENTREGA, DS_ENDERECO_PAGADOR, NO_SALES_DISTRICT)
               values(
                tof_elo_carteira_sap(i_cart).CD_ELO_CARTEIRA_SAP, tof_elo_carteira_sap(i_cart).CD_SOURCE_CARTEIRA,
                tof_elo_carteira_sap(i_cart).NU_CARTEIRA_VERSION, tof_elo_carteira_sap(i_cart).CD_CENTRO_EXPEDIDOR,
                tof_elo_carteira_sap(i_cart).DS_CENTRO_EXPEDIDOR, tof_elo_carteira_sap(i_cart).DH_CARTEIRA,
                tof_elo_carteira_sap(i_cart).CD_SALES_ORG, tof_elo_carteira_sap(i_cart).NU_CONTRATO_SAP, 
                tof_elo_carteira_sap(i_cart).CD_TIPO_CONTRATO, tof_elo_carteira_sap(i_cart).NU_CONTRATO_SUBSTITUI,
                tof_elo_carteira_sap(i_cart).DT_PAGO, tof_elo_carteira_sap(i_cart).NU_CONTRATO,
                tof_elo_carteira_sap(i_cart).NU_ORDEM_VENDA, tof_elo_carteira_sap(i_cart).DS_STATUS_CONTRATO_SAP,
                tof_elo_carteira_sap(i_cart).CD_CLIENTE, tof_elo_carteira_sap(i_cart).NO_CLIENTE,
                tof_elo_carteira_sap(i_cart).CD_SALES_DISTRICT, tof_elo_carteira_sap(i_cart).CD_INCOTERMS,
                tof_elo_carteira_sap(i_cart).CD_SALES_OFFICE, tof_elo_carteira_sap(i_cart).NO_SALES_OFFICE,
                tof_elo_carteira_sap(i_cart).CD_SALES_GROUP, tof_elo_carteira_sap(i_cart).NO_SALES_GROUP,
                tof_elo_carteira_sap(i_cart).CD_AGENTE_VENDA, tof_elo_carteira_sap(i_cart).NO_AGENTE,
                tof_elo_carteira_sap(i_cart).DH_VENCIMENTO_PEDIDO, tof_elo_carteira_sap(i_cart).DT_CREDITO,
                tof_elo_carteira_sap(i_cart).DT_INICIO, tof_elo_carteira_sap(i_cart).DT_FIM, 
                tof_elo_carteira_sap(i_cart).DH_INCLUSAO, tof_elo_carteira_sap(i_cart).DH_ENTREGA,
                tof_elo_carteira_sap(i_cart).SG_ESTADO, tof_elo_carteira_sap(i_cart).NO_MUNICIPIO,
                tof_elo_carteira_sap(i_cart).DS_BAIRRO, tof_elo_carteira_sap(i_cart).CD_PRODUTO_SAP,
                tof_elo_carteira_sap(i_cart).QT_PROGRAMADA, tof_elo_carteira_sap(i_cart).NO_PRODUTO_SAP, 
                tof_elo_carteira_sap(i_cart).QT_ENTREGUE, tof_elo_carteira_sap(i_cart).QT_SALDO,
                tof_elo_carteira_sap(i_cart).VL_UNITARIO,tof_elo_carteira_sap(i_cart).VL_BRL, 
                tof_elo_carteira_sap(i_cart).VL_TAXA_DOLAR, tof_elo_carteira_sap(i_cart).VL_USD,
                tof_elo_carteira_sap(i_cart).PC_COMISSAO, tof_elo_carteira_sap(i_cart).CD_SACARIA,
                tof_elo_carteira_sap(i_cart).DS_SACARIA,
                tof_elo_carteira_sap(i_cart).CD_CULTURA_SAP, tof_elo_carteira_sap(i_cart).DS_CULTURA_SAP,
                tof_elo_carteira_sap(i_cart).CD_BLOQUEIO_REMESSA, tof_elo_carteira_sap(i_cart).CD_BLOQUEIO_FATURAMENTO,
                tof_elo_carteira_sap(i_cart).CD_BLOQUEIO_CREDITO, tof_elo_carteira_sap(i_cart).CD_BLOQUEIO_REMESSA_ITEM,
                tof_elo_carteira_sap(i_cart).CD_BLOQUEIO_FATURAMENTO_ITEM, tof_elo_carteira_sap(i_cart).CD_MOTIVO_RECUSA,
                tof_elo_carteira_sap(i_cart).CD_LOGIN,
                tof_elo_carteira_sap(i_cart).CD_SEGMENTACAO_CLIENTE, tof_elo_carteira_sap(i_cart).DS_SEGMENTACAO_CLIENTE,
                tof_elo_carteira_sap(i_cart).DS_SEGMENTO_CLIENTE_SAP, tof_elo_carteira_sap(i_cart).CD_FORMA_PAGAMENTO,
                tof_elo_carteira_sap(i_cart).CD_TIPO_PAGAMENTO, tof_elo_carteira_sap(i_cart).DS_TIPO_PAGAMENTO,
                tof_elo_carteira_sap(i_cart).CD_AGRUPAMENTO, tof_elo_carteira_sap(i_cart).CD_BLOQUEIO_ENTREGA,
                tof_elo_carteira_sap(i_cart).NU_CNPJ, tof_elo_carteira_sap(i_cart).NU_CPF,
                tof_elo_carteira_sap(i_cart).NU_INSCRICAO_ESTADUAL, tof_elo_carteira_sap(i_cart).NU_INSCRICAO_MUNICIPAL,
                tof_elo_carteira_sap(i_cart).NU_CEP, tof_elo_carteira_sap(i_cart).DS_ENDERECO_RECEBEDOR,
                tof_elo_carteira_sap(i_cart).CD_CLIENTE_RECEBEDOR, tof_elo_carteira_sap(i_cart).NO_CLIENTE_RECEBEDOR,
                tof_elo_carteira_sap(i_cart).CD_MOEDA, tof_elo_carteira_sap(i_cart).CD_SUPPLY_GROUP,
                tof_elo_carteira_sap(i_cart).DS_VENDA_COMPARTILHADA,  tof_elo_carteira_sap(i_cart).CD_STATUS_LIBERACAO,
                tof_elo_carteira_sap(i_cart).CD_ITEM_PEDIDO, 
                tof_elo_carteira_sap(i_cart).CD_CLIENTE_PAGADOR, tof_elo_carteira_sap(i_cart).NO_CLIENTE_PAGADOR,
                tof_elo_carteira_sap(i_cart).VL_FRETE_DISTRIBUICAO,  tof_elo_carteira_sap(i_cart).CD_GRUPO_EMBALAGEM,
                tof_elo_carteira_sap(i_cart).DS_CREDIT_BLOCK_REASON, tof_elo_carteira_sap(i_cart).DH_CREDIT_BLOCK,
                tof_elo_carteira_sap(i_cart).CD_ITEM_CONTRATO, tof_elo_carteira_sap(i_cart).DS_ROTEIRO_ENTREGA,
                tof_elo_carteira_sap(i_cart).DS_ENDERECO_PAGADOR, tof_elo_carteira_sap(i_cart).NO_SALES_DISTRICT
                )

                ;

                COMMIT;

                EXCEPTION  
                WHEN OTHERS THEN 
                BEGIN
                RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.604 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                ROLLBACK;
                END;
                END;

            END IF;

    
    END;
    END IF;
    

--END PI_ELO_CARTEIRA_SAP_IMPORT;
end;


SELECT impor.*, spa.* FROM ELO_CARTEIRA_SAP_IMPORT IMPOR
inner join ELO_CARTEIRA_SAP spa
on spa.cd_elo_carteira_sap = impor.cd_elo_carteira_sap 
where  1=1
--and impor.no_sales_group <> spa.no_sales_group
--and impor.cd_sales_office <> spa.cd_sales_office
--and impor.cd_sales_district <> spa.cd_sales_district 
and impor.ds_centro_expedidor <> spa.ds_centro_expedidor; 

rdias2         romilda.dias
avillabo          copia lzumckel


SELECT 
IMPOR.nu_carteira_version, 
IMPOR.nu_contrato_sap,
IMPOR.cd_item_contrato, 
IMPOR.nu_ordem_venda,
IMPOR.cd_item_pedido,
IMPOR.*
--count(1) 
FROM ELO_CARTEIRA_SAP_IMPORT IMPOR
where 1=1
--and ( nu_ordem_venda <> ' ' and nu_ordem_venda is not null and nu_ordem_venda <> '          ' and cd_item_pedido  > 0)
and nu_carteira_version = '20180724110026'
and nu_contrato_sap = '0040317866'
and cd_item_contrato = '10'
and nu_ordem_venda = '0002146501'
group by 
nu_carteira_version, 
nu_contrato_sap,
cd_item_contrato, 
nu_ordem_venda,
cd_item_pedido
having count(1) > 1
;

20180120010048	0040332386	40	9999	0002142407



--TRUNCATE TABLE ELO_CARTEIRA_SAP_IMPORT;


SELECT NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, DT_PAGO, NU_ORDEM_VENDA, COUNT(1)
FROM (

SELECT NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO,  NU_ORDEM_VENDA, DT_PAGO 
FROM VND.ELO_CARTEIRA_SAP_import
where dh_carteira > current_date - 30
)

GROUP BY 
NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, DT_PAGO, NU_ORDEM_VENDA
HAVING COUNT(1) > 1;