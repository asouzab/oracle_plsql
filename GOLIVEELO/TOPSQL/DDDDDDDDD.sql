
DECLARE 

V_QUINZENA NUMBER:=15;
V_SEMANAL NUMBER:=7;
V_MENSAL NUMBER:=30;
V_ABRIRAGENDAMENTO NUMBER:=15;
V_LIMITENA_INTERFACE NUMBER:= 15;


CURSOR C_WHO_UPDATE IS 
WITH AGENDAMENTO AS 
(

SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_WEEK, AGE.CD_POLO, AGE.CD_MACHINE, AGE.CD_CENTRO_EXPEDIDOR, 
AGE.CD_ELO_STATUS, AGE.NU_CARTEIRA_VERSION
FROM VND.ELO_AGENDAMENTO AGE
WHERE 
AGE.IC_ATIVO = 'S'
AND AGE.DT_WEEK_START > CURRENT_DATE - V_ABRIRAGENDAMENTO
AND AGE.CD_ELO_STATUS IN (1,2,3,4,5,6,70,80 )  --2 PASSO SEM ERRO STATUS 59 
),
--select * from AGENDAMENTO

CTE_CARTEIRA_PO_PEDIDO_STATUS AS 
(
SELECT DISTINCT 
CT.NU_CONTRATO_SAP, 
CT.NU_ORDEM_VENDA

FROM VND.ELO_CARTEIRA CT
INNER JOIN AGENDAMENTO AG
ON 
AG.CD_ELO_AGENDAMENTO = CT.CD_ELO_AGENDAMENTO
WHERE 
CT.IC_ATIVO = 'S'

AND CT.QT_AGENDADA_CONFIRMADA >= 0
AND CT.QT_AGENDADA >= 0
--AND NVL(CT.CD_STATUS_CEL_FINAL, 40)  IN (40, 41, 59, 57, 58, 59 )
AND NVL(CT.CD_STATUS_CEL_FINAL, 99)  NOT IN ( 59 )
AND CT.CD_MOTIVO_RECUSA IS NULL
AND NOT(NVL(CT.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND (CT.CD_TIPO_AGENDAMENTO IN (22,23,24) 
        OR (CT.CD_TIPO_AGENDAMENTO = 25 AND CT.CD_STATUS_REPLAN = 32))

UNION

select DISTINCT  HIS.NU_CONTRATO_SAP, HIS.NU_ORDEM_VENDA 
FROM VND.ELO_CARTEIRA_hist HIS 
INNER JOIN (
    SELECT MAXID.CD_ELO_CARTEIRA, MAX(MAXID.ID) ID 
    FROM VND.ELO_CARTEIRA_HIST MAXID GROUP BY MAXID.CD_ELO_CARTEIRA 
    ) MAXD 
	ON MAXD.ID = HIS.ID    
INNER JOIN AGENDAMENTO AGC
ON 
AGC.CD_ELO_AGENDAMENTO = HIS.CD_ELO_AGENDAMENTO
WHERE 
HIS.QT_AGENDADA_CONFIRMADA > 0
AND HIS.QT_AGENDADA > 0
and AGC.CD_ELO_STATUS IN (1,2, 3,4,5,6)
and HIS.CD_STATUS_CEL_FINAL NOT IN (59) 
AND NOT(NVL(HIS.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND (HIS.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (HIS.CD_TIPO_AGENDAMENTO = 25 AND HIS.CD_STATUS_REPLAN = 32)
        OR (HIS.CD_TIPO_AGENDAMENTO IS NULL 
        AND EXISTS (SELECT 1 FROM VND.VW_ELO_AGENDAMENTO_ITEM_ADICAO IIS 
					WHERE IIS.CD_ELO_AGENDAMENTO_ITEM = HIS.CD_ELO_AGENDAMENTO_ITEM)) )

UNION 
SELECT DISTINCT
SAP.NU_CONTRATO_SAP, 
SAP.NU_ORDEM_VENDA
FROM VND.ELO_CARTEIRA SAP
INNER JOIN VND.PEDIDO PEDI
ON PEDI.NU_ORDEM_VENDA =SAP.NU_ORDEM_VENDA
AND PEDI.CD_PRODUTO_SAP = SAP.CD_PRODUTO_SAP
AND PEDI.CD_ITEM_PEDIDO = CASE 
WHEN SAP.CD_ITEM_PEDIDO = 9999 THEN PEDI.CD_ITEM_PEDIDO
ELSE  SAP.CD_ITEM_PEDIDO  END

LEFT JOIN VND.CONTRATO CONT
ON CONT.NU_CONTRATO_SAP =SAP.NU_CONTRATO_SAP
AND  CONT.CD_STATUS_CONTRATO = '8' 
--AND CONT.CD_SITUACAO_CONTRATO IN (5, 10, 15, 20) 
LEFT JOIN VND.ITEM_CONTRATO IC 
ON 
CONT.CD_CONTRATO = IC.CD_CONTRATO
AND IC.CD_ITEM_CONTRATO = SAP.CD_ITEM_CONTRATO
AND nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) > 0

WHERE 
SAP.DH_CARTEIRA > CURRENT_DATE - V_SEMANAL
AND EXISTS (SELECT 1 FROM AGENDAMENTO AGE WHERE AGE.CD_ELO_AGENDAMENTO = SAP.CD_ELO_AGENDAMENTO)
AND SAP.CD_TIPO_AGENDAMENTO IS NULL AND SAP.QT_AGENDADA IS NULL
AND NVL(PEDI.NU_QUANTIDADE_SALDO, 0) <> SAP.QT_SALDO 
AND nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) > 1
AND NOT(NVL(SAP.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND (NVL(PEDI.DH_ULT_INTERFACE, CURRENT_DATE - V_MENSAL *2) < CURRENT_DATE - V_MENSAL 
        OR NVL(CONT.DH_ULT_INTERFACE, CURRENT_DATE - V_MENSAL*2) < CURRENT_DATE - V_MENSAL)

UNION

SELECT DISTINCT 
CT.NU_CONTRATO_SAP, 
CT.NU_ORDEM_VENDA

FROM VND.ELO_CARTEIRA CT
INNER JOIN VND.ELO_AGENDAMENTO AG
ON 
AG.CD_ELO_AGENDAMENTO = CT.CD_ELO_AGENDAMENTO
WHERE 
CT.IC_ATIVO = 'S'
AND AG.IC_ATIVO= 'S'
AND AG.CD_ELO_STATUS IN (7,8)
AND AG.DT_WEEK_START > CURRENT_DATE - V_ABRIRAGENDAMENTO
AND CT.QT_AGENDADA_CONFIRMADA > 0
AND CT.QT_AGENDADA > 0
AND NOT(NVL(CT.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND ((CT.CD_TIPO_AGENDAMENTO = 25 AND CT.CD_STATUS_REPLAN = 32))
UNION

SELECT DISTINCT  
TODOSCT.NU_CONTRATO_SAP, 
--TODOSCT.CD_ITEM_CONTRATO, 
--TODOSCT.CD_PRODUTO_SAP, 
TODOSCT.NU_ORDEM_VENDA 
FROM 
(
SELECT  
NOVOSAP.NU_CONTRATO_SAP, 
NOVOSAP.CD_ITEM_CONTRATO,
NOVOSAP.CD_PRODUTO_SAP,
NOVOSAP.NU_ORDEM_VENDA

FROM VND.ELO_CARTEIRA_SAP NOVOSAP
INNER JOIN AGENDAMENTO AG
ON 
AG.NU_CARTEIRA_VERSION = NOVOSAP.NU_CARTEIRA_VERSION

WHERE 
NOT(NVL(NOVOSAP.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' ))
AND AG.CD_ELO_STATUS IN (3,4,5)
GROUP BY
NOVOSAP.NU_CONTRATO_SAP, 
NOVOSAP.CD_ITEM_CONTRATO,
NOVOSAP.CD_PRODUTO_SAP,
NOVOSAP.NU_ORDEM_VENDA

) TODOSCT
LEFT JOIN 
 
(
SELECT  
NOVOSAP.NU_CONTRATO_SAP, 
NOVOSAP.CD_ITEM_CONTRATO,
NOVOSAP.CD_PRODUTO_SAP,
NOVOSAP.NU_ORDEM_VENDA

FROM VND.ELO_CARTEIRA NOVOSAP
INNER JOIN AGENDAMENTO AG
ON 
AG.CD_ELO_AGENDAMENTO = NOVOSAP.CD_ELO_AGENDAMENTO

WHERE 
NOT (NVL(NOVOSAP.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' ))
AND NVL(NOVOSAP.CD_STATUS_CEL_FINAL , 99) NOT IN (59)
AND (NOVOSAP.QT_AGENDADA_CONFIRMADA > 0 ) 
AND (NOVOSAP.CD_TIPO_AGENDAMENTO IN (22,23,24) OR (NOVOSAP.CD_TIPO_AGENDAMENTO = 25 AND NOVOSAP.CD_STATUS_REPLAN = 32))
AND AG.CD_ELO_STATUS IN (3,4,5)
GROUP BY
NOVOSAP.NU_CONTRATO_SAP, 
NOVOSAP.CD_ITEM_CONTRATO,
NOVOSAP.CD_PRODUTO_SAP,
NOVOSAP.NU_ORDEM_VENDA

) SEMCONT

ON 

SEMCONT.NU_CONTRATO_SAP =  TODOSCT.NU_CONTRATO_SAP AND
SEMCONT.CD_ITEM_CONTRATO = TODOSCT.CD_ITEM_CONTRATO AND
SEMCONT.CD_PRODUTO_SAP = TODOSCT.CD_PRODUTO_SAP 
--SEMCONT.NU_ORDEM_VENDA = NU_ORDEM_VENDA

WHERE SEMCONT.NU_CONTRATO_SAP IS NULL 



		
),
--SELECT COUNT(1) FROM CTE_CARTEIRA_PO_PEDIDO_STATUS


CTE_CONTRATO_TODOS AS 
(

SELECT LADOfora.* FROM (

SELECT CONT.CD_CONTRATO,        CONT.NU_CONTRATO,        CONT.CD_STATUS_CONTRATO,
       CONT.CD_CLIENTE_CONTRATO,       -- CONT.CD_CLIENTE_EMISSOR,        CONT.CD_TIPO_ORDEM,
       CONT.CD_CENTRO_EXPEDIDOR,        --CONT.CD_USUARIO_VENDA,        CONT.CD_AGENTE_VENDA,
      -- CONT.CD_USUARIO_INCLUSAO,        CONT.DH_INCLUSAO,        CONT.DH_GERACAO,
     --  CONT.DH_IMPRESSAO,        CONT.DH_ASSINATURA,        CONT.DH_ENVIO_ADVEN,
     --  CONT.DH_ENVIO_SAP,        CONT.DH_PROCESSAMENTO,        CONT.DT_PAGAMENTO,
    --   CONT.DS_FORMA_PAGAMENTO,        CONT.DS_COND_ESP_PAGTO,       
     CONT.DT_INICIO,        CONT.DT_FIM,  
       --      CONT.VL_FRETE_DISTRIBUICAO,       
       CONT.IC_ATIVO,
    --   CONT.CD_MOTIVO_ORDEM,        CONT.IC_ALTERA_SUBSTITUI,        CONT.DH_LISTA_PRECO,
       CONT.CD_INCOTERMS,       
       -- CONT.DS_GARANTIAS,        CONT.DH_PRAZO_GARANTIA,
     --  CONT.VL_FACIL,        
       CONT.CD_SALES_ORG,        CONT.CD_DISTRIBUTION_CHANNEL,
       CONT.CD_SALES_DIVISION,        --CONT.IC_NEW_PRODUCT,        CONT.IC_NEW_CUSTOMER,
       CONT.IC_SIGNED,       
        CONT.IC_SAP_READY,        CONT.DH_NEW_PRODUCT,
       --CONT.DH_NEW_CUSTOMER,        CONT.DH_SAP_READY,        CONT.DH_EMAIL_MASTERDATA,
       --CONT.DH_EMAIL_ADVEN,      
        CONT.NU_CONTRATO_SAP,       -- CONT.CD_TIPO_CONTRATO,
       --CONT.DH_CANCELAMENTO,        CONT.CD_USUARIO_CANCELAMENTO,       
        CONT.DH_ULT_INTERFACE,
       CONT.CD_BLOCKING_REASON,        CONT.CD_SITUACAO_CONTRATO,       -- CONT.CD_FORMA_PAGAMENTO,
      -- CONT.IC_SAP,        CONT.CD_STATUS_CONTRATO_SAP,        CONT.CD_USUARIO_RECEBIMENTO,
      -- CONT.DH_RECEBIMENTO,        CONT.IC_RECEBIDO,        CONT.DH_ULT_ALTERACAO,
     --  CONT.IC_ORIGEM_CONTRATO,        CONT.CD_TIPO_PAGAMENTO,        CONT.CD_CLIENTE_PO_NUMERO,
     --  CONT.DH_ENVIO_ASSINATURA,        CONT.DH_REENVIO_ASSINATURA,       CONT.CD_USUARIO_APROVACAO_CLIENTE,
     --  CONT.CD_USUARIO_REJEICAO_CLIENTE,        CONT.CD_USUARIO_REJEICAO_SUPERVISOR,
     --  CONT.DH_APROVACAO_CLIENTE,        CONT.DH_REJEICAO_CLIENTE,        CONT.DH_REJEICAO_SUPERVISOR,
     --  CONT.IC_ASSINATURA_ELETRONICA,        CONT.CD_USUARIO_APROVACAO_SUPERV,
     --  CONT.DH_APROVACAO_SUPERVISOR,       
        CONT.CD_BLOQUEIO_CREDITO,        CONT.CD_BLOQUEIO_ENTREGA,
       CONT.CD_BLOQUEIO_FATURAMENTO,        CONT.CD_BLOQUEIO_REMESSA,        CONT.DS_CREDIT_BLOCK_REASON
  FROM VND.CONTRATO CONT
 WHERE CONT.IC_ATIVO = 'S'
and exists (select 1 
            from vnd.item_contrato ic 
            where ic.cd_contrato = cont.cd_contrato 
            and nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) > 1)  
AND  CONT.CD_STATUS_CONTRATO = '8' 
AND CONT.CD_SITUACAO_CONTRATO IN (5, 10, 15, 20) 
AND TRUNC(NVL(cont.dt_fim, CURRENT_DATE), 'YEAR') > trunc(current_date - 400, 'YEAR')

) LADOfora
WHERE LADOfora.DH_ULT_INTERFACE < current_date -V_QUINZENA  

 
) ,
--SELECT * FROM CTE_CONTRATO_TODOS

 
CTE_PEDIDO_TODOS AS 
(

SELECT FORAOV.* FROM (

SELECT OV.CD_PEDIDO,        OV.CD_ITEM_PEDIDO,        OV.CD_CONTRATO,
       OV.CD_SITUACAO_PEDIDO,        OV.CD_CLIENTE_RECEBEDOR,       OV.CD_CLIENTE_PAGADOR, 
       OV.CD_PRODUTO_SAP,        OV.DS_PRODUTO_SAP,
       OV.CD_CLIENTE_EMISSOR,        OV.CD_CENTRO_EXPEDIDOR,
       OV.NU_ORDEM_VENDA,        OV.DH_PEDIDO,       OV.CD_INCOTERMS,        OV.NU_QUANTIDADE,
       OV.NU_QUANTIDADE_SALDO,        OV.CD_TIPO_ORDEM,       OV.IC_CANCELAMENTO,
       OV.DH_CANCELAMENTO, 
              --OV.DS_ROTEIRO_ENTREGA,
       OV.CD_BLOQUEIO_REMESSA,        OV.CD_BLOQUEIO_FATURAMENTO,        OV.CD_BLOQUEIO_CREDITO,
       OV.CD_MOTIVO_RECUSA,        OV.CD_SACARIA,        OV.DH_ULT_ALTERACAO,        OV.DH_INCLUSAO,
       OV.CD_MOTIVO_BLOQUEIO_CREDITO,        OV.DH_ULT_INTERFACE,        OV.NU_CONTRATO,
       OV.NU_CONTRATO_SAP,        OV.NU_QUANTIDADE_ENTREGUE,        OV.CD_ITEM_CONTRATO,
       OV.CD_BLOQUEIO_ENTREGA,        OV.CD_BLOQUEIO_FATURAMENTO_ITEM,
       OV.CD_BLOQUEIO_REMESSA_ITEM,        OV.DS_CREDIT_BLOCK_REASON,
       OV.CD_MOTIVO_ORDEM
  FROM VND.PEDIDO OV

where 1=1 
and ov.CD_SITUACAO_PEDIDO in (5, 10,15,20,25) 
AND ov.NU_QUANTIDADE_SALDO > 1 
and TRUNC(NVL(OV.dh_entrega, CURRENT_DATE), 'YEAR') > trunc(current_date - 400, 'YEAR')
) FORAOV
WHERE FORAOV.DH_ULT_INTERFACE < CURRENT_DATE - V_QUINZENA
--ov.nu_quantidade_saldo > 1
--5	Comercial
--10	Crédito
--15	Cobrança
--20	Liberado
--25	Finalizado
--30	Recusado/Cancelado
--99	Verificar erro status
--35	Bloqueio de Material
--90	Pedido Excluido no SAP

)
--SELECT * FROM CTE_PEDIDO_TODOS


SELECT QQ.IC_TIPO, SUBSTR(QQ.NU_CODIGO, 1, 10) NU_CODIGO , 1 cd_interface
FROM 
(
SELECT  'G' IC_TIPO, GG.NU_CONTRATO_SAP NU_CODIGO
FROM CTE_CARTEIRA_PO_PEDIDO_STATUS GG
UNION 
SELECT  'G' IC_TIPO, CTR.NU_CONTRATO_SAP NU_CODIGO
FROM CTE_CONTRATO_TODOS CTR
UNION
SELECT  'C' IC_TIPO, CC.NU_ORDEM_VENDA NU_CODIGO
FROM CTE_CARTEIRA_PO_PEDIDO_STATUS CC
UNION
SELECT 'C' IC_TIPO, PTR.NU_ORDEM_VENDA NU_CODIGO
FROM CTE_PEDIDO_TODOS PTR

UNION 

select 'C' IC_TIPO, intt.nu_ordem_venda
from vnd.elo_carteira_sap intt
left join vnd.pedido ped
on intt.nu_ordem_venda = ped.nu_ordem_venda

where

(intt.dh_carteira > current_date - 4 )
AND NOT(NVL(intt.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
and ped.nu_ordem_venda IS NULL

UNION
select 'G' IC_TIPO, intt.NU_CONTRATO_SAP
from vnd.elo_carteira_sap intt
left join vnd.contrato ped
on intt.nu_contrato_sap = ped.nu_contrato_sap

where

(intt.dh_carteira > current_date - 4 )
and ped.nu_contrato_sap IS NULL

------------------------
union
SELECT DISTINCT 'G' IC_TIPO, cont.nu_contrato_sap 


  FROM vnd.contrato cont
 WHERE     cont.ic_ativo = 'S'
       and exists (select 1 from vnd.item_contrato ic where ic.cd_contrato = cont.cd_contrato and 
       nvl(ic.NU_QUANTIDADE,0) - nvl(ic.NU_QTY_DELIVERED,0) > 1 )
       AND cont.CD_STATUS_CONTRATO = '8'
       AND cont.dt_fim < CURRENT_DATE - 180
       --AND IC_SIGNED = 'S'
       --AND IC_SAP_READY = 'S'
       AND cont.CD_SITUACAO_CONTRATO IN (50,
                                    100,
                                    150,
                                    20)
      -- AND DH_ULT_INTERFACE < CURRENT_DATE - 30
      -- AND CD_BLOQUEIO_CREDITO IS NULL
       AND cont.CD_BLOQUEIO_ENTREGA IS NULL
       AND cont.CD_BLOQUEIO_FATURAMENTO IS NULL
       AND cont.CD_BLOQUEIO_REMESSA IS NULL
       AND cont.DS_CREDIT_BLOCK_REASON IS NULL

------------------------


) QQ 
GROUP BY QQ.IC_TIPO, SUBSTR(QQ.NU_CODIGO, 1, 10) 
ORDER BY QQ.IC_TIPO, SUBSTR(QQ.NU_CODIGO, 1, 10)

;



V_LIMIT NUMBER:=11000;

TYPE elo_interface_r IS RECORD
(
ic_tipo     VND.INTERFACE.IC_TIPO%TYPE,
nu_codigo   VND.INTERFACE.NU_CODIGO%TYPE,
cd_interface VND.INTERFACE.CD_INTERFACE%TYPE

); 

TYPE elo_interface_t IS TABLE OF elo_interface_r
INDEX BY PLS_INTEGER;
tof_elo_interface elo_interface_t;

tof_elo_interface_todos elo_interface_t;

V_INTERFACE    NUMBER;
V_QTDE_VALID NUMBER;
V_MAX_CD_INTERFACE  VND.INTERFACE.CD_INTERFACE%TYPE;

V_IS_VALID VARCHAR2(1);

PROCEDURE RANGEVALID (pi_ic_tipo     VND.INTERFACE.IC_TIPO%TYPE,
pi_nu_codigo   VND.INTERFACE.NU_CODIGO%TYPE, IS_VALID OUT VARCHAR2 )
IS 

V_QTDE NUMBER:=0;
V_CODIGOPO VND.CONTRATO.NU_CONTRATO_SAP%TYPE;
V_CODIGOOV VND.PEDIDO.NU_ORDEM_VENDA%TYPE; 



BEGIN

IS_VALID:='N';



IF pi_ic_tipo = 'G' THEN 
    V_CODIGOPO:=SUBSTR(TRIM(pi_nu_codigo),1,10);

    BEGIN
    SELECT COUNT(1) INTO V_QTDE
    FROM VND.CONTRATO CONT
    WHERE 
    CONT.NU_CONTRATO_SAP = V_CODIGOPO;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    V_QTDE:= -1;
    WHEN OTHERS THEN 
    V_QTDE:= -1;
    
    END;
    
    IF V_QTDE > 0 THEN
    
        BEGIN
        SELECT COUNT(1) INTO V_QTDE
        FROM VND.CONTRATO CONT
        INNER JOIN VND.ITEM_CONTRATO IC 
        ON CONT.CD_CONTRATO = IC.CD_CONTRATO
        WHERE 
        CONT.NU_CONTRATO_SAP = V_CODIGOPO
        AND CONT.IC_ATIVO = 'S'
        AND CONT.CD_STATUS_CONTRATO = '8' 
        AND NVL(IC.NU_QUANTIDADE,0) - NVL(IC.NU_QTY_DELIVERED,0) > 1
        AND (CONT.dt_fim > current_date -180  
        AND CONT.CD_SITUACAO_CONTRATO IN (5, 10, 15, 20)
        AND CONT.DH_ULT_INTERFACE < CURRENT_DATE - V_SEMANAL); 
        
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        V_QTDE:= 0;
        WHEN OTHERS THEN 
        V_QTDE:= 0;

        END;
        
        if V_CODIGOPO = '0040404782' then
        IS_VALID:='N';  
        end if;        
        
        
    elsif V_QTDE = 0 THEN 

            IS_VALID:='S'; 
    
    END IF;
    
    

ELSE 
    V_CODIGOOV:=SUBSTR(TRIM(pi_nu_codigo),1,10);

    BEGIN
    SELECT COUNT(1) INTO V_QTDE
    FROM VND.PEDIDO CONT
    WHERE 
    CONT.NU_ORDEM_VENDA = V_CODIGOOV;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    V_QTDE:= -1;
    WHEN OTHERS THEN 
    V_QTDE:= -1;
    
    END;
    
    IF V_QTDE > 0 THEN

    BEGIN
    SELECT COUNT(1) INTO V_QTDE
    FROM VND.PEDIDO PED
    WHERE 
    PED.NU_ORDEM_VENDA = V_CODIGOOV
    and (PED.CD_SITUACAO_PEDIDO in (5, 10,15,20,25) 
    AND PED.NU_QUANTIDADE_SALDO > 0 
    AND PED.DH_ULT_INTERFACE < CURRENT_DATE - V_SEMANAL)
    AND EXISTS (SELECT 1 
                FROM VND.CONTRATO CONT 
                INNER JOIN VND.ITEM_CONTRATO IC 
                ON CONT.CD_CONTRATO = IC.CD_CONTRATO
                WHERE CONT.NU_CONTRATO_SAP = PED.NU_CONTRATO_SAP 
                AND CONT.CD_SITUACAO_CONTRATO IN (5, 10, 15, 20, 25) 
                AND NVL(IC.NU_QUANTIDADE,0) - NVL(IC.NU_QTY_DELIVERED,0) > 0
                AND  CONT.CD_STATUS_CONTRATO = '8'
                AND PED.CD_ITEM_CONTRATO = IC.CD_ITEM_CONTRATO)
    ;
                      
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    V_QTDE:= 0;
    WHEN OTHERS THEN 
    V_QTDE:= 0;
    
    END;    
    
    elsif   V_QTDE = 0 THEN   
       IS_VALID:='S';   
       
     
    END IF;
    
    
IF pi_ic_tipo = 'G' and IS_VALID ='S'  THEN


        BEGIN
        SELECT COUNT(1) INTO V_QTDE
        FROM VND.CONTRATO CONT
        INNER JOIN VND.ITEM_CONTRATO IC 
        ON CONT.CD_CONTRATO = IC.CD_CONTRATO
        WHERE 
        CONT.NU_CONTRATO_SAP = V_CODIGOPO
        AND CONT.IC_ATIVO = 'S'
        AND CONT.CD_STATUS_CONTRATO = '8' 
        AND NVL(IC.NU_QUANTIDADE,0) - NVL(IC.NU_QTY_DELIVERED,0) > 1
        AND CONT.CD_SITUACAO_CONTRATO IN ( 10, 5, 25 )
        AND CONT.DH_ULT_INTERFACE < CURRENT_DATE - 60; 
        
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        V_QTDE:= 0;
        WHEN OTHERS THEN 
        V_QTDE:= 0;

        END;
        
        IF NVL(V_QTDE,0) = 0 THEN 
        IS_VALID:='S';
        ELSE 
        IS_VALID:='N';
        END IF;


 
END IF;    
    
    

END IF;    
    
    IF NVL(V_QTDE, 1) > 0 OR V_QTDE < 0 THEN 

		IF NVL(V_QTDE, 1) > 0 THEN 
			BEGIN
			SELECT COUNT(1) INTO V_QTDE 
			FROM VND.INTERFACE TR
			WHERE TR.NU_CODIGO = pi_nu_codigo
			AND TR.DH_EXECUCAO > CURRENT_DATE - V_LIMITENA_INTERFACE;
			EXCEPTION 
			WHEN NO_DATA_FOUND THEN 
			V_QTDE:= -1;
			WHEN OTHERS THEN 
			V_QTDE:= -1;
			END;
			
			IF NVL(V_QTDE,0) = 0 THEN 
				IS_VALID:='S';
            else
                IS_VALID:='N';
            
			END IF;		
		
		ELSE 
			IS_VALID:='S';
		END IF;
		
	
        
    END IF ;

END;


BEGIN

BEGIN 
SELECT COUNT(1) INTO V_INTERFACE 
FROM VND.INTERFACE 
WHERE 
DH_EXECUCAO IS NULL;
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
V_INTERFACE:=0;
WHEN OTHERS THEN 
V_INTERFACE:=0;
END;
    
IF V_INTERFACE < 200 THEN 
BEGIN

    V_QTDE_VALID:=1;
    select max(cd_interface)  INTO V_MAX_CD_INTERFACE from vnd.interface;
    
    OPEN    C_WHO_UPDATE;  
    LOOP<<MAIN_WHO>>
    
    BEGIN 
                             
    FETCH   C_WHO_UPDATE BULK COLLECT INTO tof_elo_interface_todos LIMIT V_LIMIT;

    EXCEPTION  
    WHEN OTHERS THEN 
    BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    --ROLLBACK;
    END;
    
    END;
    

    IF tof_elo_interface_todos.COUNT > 0 THEN 
        V_IS_VALID:='N';
        
        FOR i_cartT in tof_elo_interface_todos.FIRST .. tof_elo_interface_todos.LAST
        LOOP
            RANGEVALID(tof_elo_interface_todos(i_cartT).IC_TIPO, tof_elo_interface_todos(i_cartT).NU_CODIGO, V_IS_VALID);
            IF V_IS_VALID = 'S' AND V_QTDE_VALID < 801 THEN 
                tof_elo_interface(tof_elo_interface.COUNT +1):=tof_elo_interface_todos(i_cartT); 
                tof_elo_interface(tof_elo_interface.COUNT).CD_INTERFACE:= V_MAX_CD_INTERFACE+V_QTDE_VALID;
                V_QTDE_VALID:=V_QTDE_VALID+1;       
            END IF;
        
        END LOOP;
        
    
    
    END IF;
    
    --select max(cd_interface) + 1 INTO V_MAX_CD_INTERFACE from vnd.interface;
 
	EXIT WHEN C_WHO_UPDATE%NOTFOUND  OR V_QTDE_VALID > 801 OR tof_elo_interface_todos.COUNT = 0;
	
	
	END LOOP; 
	CLOSE   C_WHO_UPDATE;
    
   
	IF tof_elo_interface.COUNT > 0 THEN 
	BEGIN 
        
	BEGIN
		FORALL i_cart IN INDICES OF tof_elo_interface
                INSERT INTO  VND.INTERFACE 
                (cd_interface, ic_tipo, nu_codigo)
                VALUES
                ( 
                tof_elo_interface(i_cart).cd_interface,
                tof_elo_interface(i_cart).ic_tipo,
                tof_elo_interface(i_cart).nu_codigo
                );
		
            COMMIT;  
                  
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.304 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
            END;
    END;


	END;
	END IF;   
		
	
	
END;
END IF; --V_INTERFACE < 200 END

DBMS_SESSION.free_unused_user_memory;

END;

--select * from vnd.interface where dh_execucao is null;


select intt.*, ped.* from vnd.interface intt
left join vnd.pedido ped
on intt.nu_codigo = ped.nu_ordem_venda

where

(intt.dh_execucao > current_date - 100 or intt.dh_execucao is null)
and intt.ic_tipo = 'C' 
and ped.nu_ordem_venda IS NULL;


select intt.*, ped.* from vnd.interface intt
left join vnd.contrato ped
on intt.nu_codigo = ped.nu_contrato_sap

where

nvl(intt.dh_execucao, current_date - 2) > current_date - 2
and intt.ic_tipo = 'G' 
and ped.nu_contrato_sap IS NULL;

select intt.nu_codigo, count(1) from vnd.interface intt

where
intt.dh_execucao > current_date - 20
group by intt.nu_codigo;



select intt.nu_contrato_sap, intt.cd_item_contrato, intt.nu_ordem_venda, ped.* from vnd.elo_carteira_sap intt
left join vnd.pedido ped
on intt.nu_ordem_venda = ped.nu_ordem_venda

where

(intt.dh_carteira > current_date - 300 )
AND NOT(NVL(intt.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
and ped.nu_ordem_venda IS NULL;


select distinct intt.nu_contrato_sap, intt.cd_item_contrato, ped.nu_contrato_sap from vnd.elo_carteira_sap intt
left join vnd.contrato ped
on intt.nu_contrato_sap = ped.nu_contrato_sap
left join VND.ITEM_CONTRATO ic 
on ped.cd_contrato = ic.cd_contrato
and ic.cd_produto_sap = intt.cd_produto_sap
and ic.cd_item_contrato = intt.cd_item_contrato

where

(intt.dh_carteira > current_date - 300 )
 and ped.nu_contrato_sap IS NULL;


select count(1) from vnd.elo_carteira_sap 
where 

dh_carteira > current_date - 1
--and (nu_contrato_sap in (
--'0040407283'
--)
-- or
  and nu_ordem_venda in 
 (

'0002437776'

-- )
 ) ;



select * from vnd.interface
where nu_codigo  in
(
'0002437693'
);








