select * from vnd.pedido
where 
nu_ordem_venda IN( 
'0002358228'
);


INSERT INTO VND.INTERFACE (
  CD_INTERFACE, 
   IC_TIPO, 
   NU_CODIGO
)
select
(select max(CD_INTERFACE) from interface) + rownum,
 'C',
 '0002358228' nu_ordem_venda
from DUAL;

select * from interface where dh_execucao is null;


INSERT INTO VND.INTERFACE (
  CD_INTERFACE, 
   IC_TIPO, 
   NU_CODIGO
)
select
(select max(CD_INTERFACE) from interface) + rownum,
 'G',
 '0040378411' nu_ordem_venda
from DUAL;


select * from vnd.contrato C
where 
cd_status_contrato = 8 and ic_ativo = 'S' AND IC_SIGNED = 'S' AND 
IC_SAP_READY = 'S' 
--AND DH_SAP_READY > CURRENT_DATE - 100 
AND NU_CONTRATO_SAP IS NOT NULL
--AND DH_ULT_INTERFACE > CURRENT_DATE - 100 
AND CD_BLOQUEIO_REMESSA IS NULL AND CD_BLOQUEIO_FATURAMENTO IS NULL
AND CD_BLOQUEIO_CREDITO IS NULL AND CD_BLOQUEIO_ENTREGA IS NULL
AND DS_CREDIT_BLOCK_REASON IS NULL
--nu_contrato_sap = '0040378411';
AND EXISTS (SELECT 1 FROM VND.PEDIDO P 
            , VND.ITEM_CONTRATO IC 
            WHERE P.NU_CONTRATO_SAP = C.NU_CONTRATO_SAP
            AND IC.CD_CONTRATO = C.CD_CONTRATO
            --AND IC.CD_ITEM_CONTRATO = P.CD_ITEM_CONTRATO
            AND P.CD_PRODUTO_SAP = IC.CD_PRODUTO_SAP
            AND P.NU_QUANTIDADE_SALDO > 0 
            AND IC.NU_QUANTIDADE - NU_QTY_DELIVERED > 0
            
            );

SELECT * FROM ITEM_CONTRATO;

select * from ctf.usuario 

--order by cd_login;
where cd_tipo_usuario = 21;


update ctf.usuario
set ds_senha = '301010707'
where cd_usuario = '3682';
