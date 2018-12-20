declare 

cursor acharatua is 
with cte_sap as 
(
select  age.cd_elo_agendamento , sap.*
from vnd.elo_agendamento age
inner join vnd.elo_carteira_sap sap 
on age.nu_carteira_version = sap.nu_carteira_version

where 
age.cd_elo_status in (1,2,3,4,5)
AND (NOT(NVL(sap.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) and sap.nu_ordem_venda is not null)
 
),

--select * from  cte_sap

cte_contrato_ativos as 
(
select age.nu_contrato_sap, age.cd_item_contrato
from cte_sap age
left join 
(select ec.cd_elo_agendamento, ec.nu_contrato_sap, ec.cd_item_contrato, ec.nu_ordem_venda
from vnd.elo_carteira ec
left join ctf.centro_expedidor cc 
on ec.cd_centro_expedidor = cc.cd_centro_expedidor
where 
ec.ic_ativo ='S' 
and exists (select distinct 1 from cte_sap g where g.cd_elo_agendamento = ec.cd_elo_agendamento)

--AND age.cd_week = 'W362018'
--AND (ec.cd_centro_expedidor in ('60220') or age.cd_polo = 'P002')
--AND nu_contrato_sap in ('0040397213' )
and nvl(ec.qt_agendada_confirmada,0) >= 0
AND NOT(NVL(ec.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND (ec.cd_tipo_agendamento in (22,23,24) or (ec.cd_tipo_agendamento = 25 and ec.cd_status_replan = 32)  )
and (substr(nvl(ec.ds_credit_block_reason, ' '),1,2)  in ( '', ' ', '  ') )  
group by ec.cd_elo_agendamento, ec.nu_contrato_sap, ec.cd_item_contrato, ec.nu_ordem_venda
) carte 
on carte.cd_elo_agendamento = age.cd_elo_agendamento 
and carte.nu_contrato_sap = age.nu_contrato_sap 
and carte.cd_item_contrato = age.cd_item_contrato
and carte.nu_ordem_venda = age.nu_ordem_venda
),
--select * from cte_contrato
cte_contratos as 
(
select ativos.nu_contrato_sap , ativos.cd_item_contrato, cont.CD_STATUS_CONTRATO, cont.DH_ULT_INTERFACE,
cont.CD_BLOQUEIO_CREDITO ,  cont.CD_BLOQUEIO_ENTREGA  ,cont.CD_BLOQUEIO_FATURAMENTO,
cont.CD_BLOQUEIO_REMESSA, cont.DS_CREDIT_BLOCK_REASON,

ic.cd_item_contrato existenocontrato  , ic.NU_QUANTIDADE, 
ic.NU_QTY_DELIVERED, ic.CD_MOTIVO_RECUSA, ic.IC_RECUSADO, ic.CD_BLOQUEIO_FATURAMENTO_ITEM,
cont.cd_situacao_contrato
from cte_contrato_ativos ativos 
left join vnd.contrato cont
on ativos.nu_contrato_sap = cont.nu_contrato_sap
left join vnd.item_contrato ic
on cont.cd_contrato = ic.cd_contrato
and ativos.cd_item_contrato = ic.cd_item_contrato 
where nvl(cont.CD_SITUACAO_CONTRATO, 99) in (5, 10,15,20, 99,25) 
),
--5	Comercial
--10	Crédito
--15	Cobrança
--20	Liberado
--25	Finalizado
--30	Recusado/Cancelado
--99	Verificar erro status
--35	Bloqueio de Material
--90	Contrato Excluido no SAP
--40	Incompleto



--select * from cte_contratos

cte_pedidos_ativos as 
(
select age.nu_contrato_sap, age.cd_item_contrato, age.nu_ordem_venda, age.cd_item_pedido
from cte_sap age 
left join 
(select ec.cd_elo_agendamento, ec.nu_contrato_sap, ec.cd_item_contrato, ec.nu_ordem_venda, ec.cd_item_pedido
from vnd.elo_carteira ec
left join ctf.centro_expedidor cc 
on ec.cd_centro_expedidor = cc.cd_centro_expedidor
where 
ec.ic_ativo ='S' 
and exists (select distinct 1 from cte_sap g where g.cd_elo_agendamento = ec.cd_elo_agendamento)
--AND age.cd_week = 'W362018'
--AND (ec.cd_centro_expedidor in ('60220') or age.cd_polo = 'P002')
--AND nu_contrato_sap in ('0040397213' )
and nvl(ec.qt_agendada_confirmada,0) >= 0
AND NOT(NVL(ec.NU_ORDEM_VENDA, '0') IN ('          ', '0', '0         ' )) 
AND (ec.cd_tipo_agendamento in (22,23,24) or (ec.cd_tipo_agendamento = 25 and ec.cd_status_replan = 32)  )
and (substr(nvl(ec.ds_credit_block_reason, ' '),1,2)  in ( '', ' ', '  ') )  
group by ec.cd_elo_agendamento, ec.nu_contrato_sap, ec.cd_item_contrato, ec.nu_ordem_venda, ec.cd_item_pedido
) carte 
on carte.cd_elo_agendamento = age.cd_elo_agendamento 
and carte.nu_contrato_sap = age.nu_contrato_sap 
and carte.cd_item_contrato = age.cd_item_contrato
and carte.nu_ordem_venda = age.nu_ordem_venda
and age.cd_item_pedido = case 
when carte.cd_item_pedido = 9999 then  age.cd_item_pedido
else  carte.cd_item_pedido end

),
--select * from cte_pedidos_ativos
cte_pedidos as 
(
SELECT pedat.nu_contrato_sap, pedat.cd_item_contrato, pedat.nu_ordem_venda , pedat.cd_item_pedido,
ped.NU_ORDEM_VENDA existeov,  ped.DH_ULT_INTERFACE, ped.NU_QUANTIDADE, ped.NU_QUANTIDADE_SALDO, ped.CD_SITUACAO_PEDIDO, ped.IC_CANCELAMENTO, 
ped.CD_BLOQUEIO_REMESSA ,ped.CD_BLOQUEIO_FATURAMENTO ,
ped.CD_BLOQUEIO_CREDITO , ped.CD_MOTIVO_RECUSA  , CD_MOTIVO_BLOQUEIO_CREDITO,
ped.CD_BLOQUEIO_ENTREGA, ped.CD_BLOQUEIO_FATURAMENTO_ITEM,
ped.CD_BLOQUEIO_REMESSA_ITEM, ped.DS_CREDIT_BLOCK_REASON  


from cte_pedidos_ativos pedat
left join vnd.pedido ped 
on
ped.nu_ordem_venda = pedat.nu_ordem_venda
and ped.cd_item_pedido = case 
when pedat.cd_item_pedido = 9999 then  ped.cd_item_pedido
else  pedat.cd_item_pedido end

)

SELECT distinct nu_ordem_venda_ped from 
(

select distinct ped.nu_contrato_sap nu_contrato_sap_ped, ped.cd_item_contrato cd_item_contrato_ped, 
ped.nu_ordem_venda nu_ordem_venda_ped, ped.cd_item_pedido cd_item_pedido_ped,
ped.existeov, ped.dh_ult_interface dh_ult_interface_ped, ped.nu_quantidade nu_quantidade_ped, 
ped.nu_quantidade_saldo nu_quantidade_saldo_ped, ped.cd_situacao_pedido cd_situacao_pedido_ped,
ped.ic_cancelamento ic_cancelamento_ped, ped.cd_bloqueio_remessa cd_bloqueio_remessa_ped, 
ped.cd_bloqueio_faturamento cd_bloqueio_faturamento_ped, ped.cd_bloqueio_credito cd_bloqueio_credito_ped, 
ped.cd_motivo_recusa cd_motivo_recusa_ped, ped.cd_motivo_bloqueio_credito cd_motivo_bloqueio_credito_ped, 
ped.cd_bloqueio_entrega cd_bloqueio_entrega_ped, ped.cd_bloqueio_faturamento_item cd_bloqueio_fatura_item_ped, 
ped.cd_bloqueio_remessa_item cd_bloqueio_remessa_item_ped, ped.ds_credit_block_reason ds_credit_block_reason_ped,
contr.nu_contrato_sap nu_contrato_sap_ic, contr.cd_item_contrato cd_item_contrato_ic, 
contr.CD_STATUS_CONTRATO CD_STATUS_CONTRATO_ic, contr.DH_ULT_INTERFACE DH_ULT_INTERFACE_ic,
contr.CD_BLOQUEIO_CREDITO CD_BLOQUEIO_CREDITO_ic,  contr.CD_BLOQUEIO_ENTREGA  CD_BLOQUEIO_ENTREGA_ic ,
contr.CD_BLOQUEIO_FATURAMENTO CD_BLOQUEIO_FATURAMENTO_ic, contr.CD_BLOQUEIO_REMESSA CD_BLOQUEIO_REMESSA_ic, 
contr.DS_CREDIT_BLOCK_REASON DS_CREDIT_BLOCK_REASON_ic,
contr.cd_item_contrato existenocontrato  , contr.NU_QUANTIDADE NU_QUANTIDADE_ic, 
contr.NU_QTY_DELIVERED NU_QTY_DELIVERED_ic, contr.CD_MOTIVO_RECUSA CD_MOTIVO_RECUSA_ic, 
contr.IC_RECUSADO IC_RECUSADO_ic, contr.CD_BLOQUEIO_FATURAMENTO_ITEM CD_BLOQUEIO_FATURA_ITEM_ic,
contr.cd_situacao_contrato cd_situacao_contrato_ic

from cte_pedidos ped
full join cte_contratos contr
on ped.nu_contrato_sap = contr.nu_contrato_sap 
and ped.cd_item_contrato = contr.cd_item_contrato
 

where 
nvl(ped.dh_ult_interface, current_date - 60) < current_date - 30
or nvl(contr.dh_ult_interface, current_date - 60) < current_date - 30
--order by ped.dh_ult_interface
order by contr.dh_ult_interface
);

TYPE elo_interface_t IS TABLE OF acharatua%rowtype
INDEX BY PLS_INTEGER;
tof_elo_interface elo_interface_t;

V_LIMIT NUMBER:=800;
V_MAX_CD_INTERFACE  VND.INTERFACE.CD_INTERFACE%TYPE;

begin 

    select max(cd_interface) + 1 INTO V_MAX_CD_INTERFACE from vnd.interface;

    BEGIN 
        OPEN    acharatua;                               
        FETCH   acharatua BULK COLLECT INTO tof_elo_interface LIMIT V_LIMIT;
        CLOSE   acharatua;
    EXCEPTION  
        WHEN OTHERS THEN 
        BEGIN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.303 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
        --ROLLBACK;
        END;
    END;
    
    IF tof_elo_interface.COUNT > 0 THEN 
    BEGIN
    
		FOR i_cart in tof_elo_interface.FIRST .. tof_elo_interface.LAST
		LOOP
		
            BEGIN
                INSERT INTO  VND.INTERFACE 
                (cd_interface, ic_tipo, nu_codigo)
                VALUES
                ( 
                V_MAX_CD_INTERFACE,
                'C',
                tof_elo_interface(i_cart).NU_ORDEM_VENDA_ped
                );
		
            COMMIT;  

--DBMS_OUTPUT.PUT_LINE('{Toad_204889402_4}');
--DBMS_OUTPUT.PUT_LINE('{Toad_204889402_4}[---' || V_MAX_CD_INTERFACE || ' ---]');
--DBMS_OUTPUT.PUT_LINE('{Toad_204889402_4}');

            
            V_MAX_CD_INTERFACE:=V_MAX_CD_INTERFACE+1;
                  
            EXCEPTION  
            WHEN OTHERS THEN 
            BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: GX_ELO_BATCH_ISSUE.304 - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
            END;
            END;
		
		
		
		END LOOP;
    
    
    END;
    
    END IF;
    
    
    
end;



--select ped.*, INTT.*, err.* from vnd.interface intt
--left join vnd.pedido ped
--on 
--ped.nu_ordem_venda = intt.NU_CODIGO
--left join vnd.job_error err
--on err.ds_key = intt.nu_codigo
--
--where intt.DH_EXECUCAO > current_date -1
--and intt.IC_TIPO = 'C';
--
--
--'0002379840'
--'0040395774'
--ITEM_CONTRATO = 10
--6303
--000000000000119098
--ES - Ureia  46 N Granulada
--
--SELECT * FROM VND.CONTRATO 
--WHERE NU_CONTRATO_SAP = '0040395774';
--
--SELECT * FROM VND.ITEM_CONTRATO
--WHERE CD_CONTRATO = 220920;
--
--select * from vnd.pedido 
--where nu_ordem_venda = '0002379840';
--
--select * from vnd.interface
--where NU_CODIGO = '0002379840';
--
--
--select * from vnd.job_error
--where ds_key = '0002379840';