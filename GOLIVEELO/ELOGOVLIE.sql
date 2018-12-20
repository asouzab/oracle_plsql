select * from vnd.contrato
where 
--nu_contrato_sap like '%0040354202%'

(nu_contrato_sap = '0040385303'  ) or
(nu_contrato_sap ='0040385303'  ) or 
(nu_contrato_sap ='0040384614' ) or
(nu_contrato_sap ='0040354202'  )


000000000000103673	0002342023

select * from vnd.item_contrato 
where cd_contrato = 187383

select nu_contrato_sap, nu_ordem_venda, cd_produto_sap, nu_quantidade, nu_quantidade_saldo , dh_entrega, P.* from vnd.pedido P
where 
nu_contrato_sap = '0040385069' and 
nu_ordem_venda = '0002344588'


40385069	2344588

0040382017 
0002336728

select nu_contrato_sap, nu_ordem_venda, cd_produto_sap, nu_quantidade, nu_quantidade_saldo , dh_entrega, C.* from vnd.pedido C
where 

(nu_contrato_sap = '0040385303'  and nu_ordem_venda = 	'0002345367') or
(nu_contrato_sap ='0040385303'  and nu_ordem_venda = 	'0002345371') or 
(nu_contrato_sap ='0040384614'  and nu_ordem_venda = 	'0002342022') or
(nu_contrato_sap ='0040354202'  and nu_ordem_venda = 	'0002218076')




40354202	2218076


[?12/?04/?2018 11:13] Kalil, Paulo - Sao Paulo: 
0040384614  
0002342023 


select CD_ELO_CARTEIRA, nu_contrato_sap, cd_item_contrato, cd_produto_sap, nu_ordem_venda, cd_item_pedido 
qt_agendada_confirmada, cd_status_customer_service, cd_elo_agendamento,nu_protocolo, cd_status_cel_final,
dh_liberacao_torre_fretes , qt_saldo_refresh, IC_COOPERATIVE, c.*
from vnd.elo_carteira c
where 
--nu_ordem_venda like  '%2329331%'
nu_contrato_sap in ( '--0040384616'  , '0040354202')

[?12/?04/?2018 11:48] Kalil, Paulo - Sao Paulo: 
0040354202 
0002218076 


10	000000000000108722	0002345367
20	000000000000119098	0002345371


SELECT * FROM VND.ELO_AGENDAMENTO WHERE

0002346187
0002346186

nu_ordem_venda is null
and cd_incoterms = 'CIF'
AND (CD_STATUS_CEL_FINAL = 59 OR CD_STATUS_TORRE_FRETES IS NOT NULL OR DH_LIBERACAO_TORRE_FRETES IS NOT NULL) 






SELECT GX_ELO_FREIGHTOWER.FX_GET_PROTOCOLO_TORRE_DATA('R121092HF1','DESTINO') FROM DUAL;


   select  CASE e.IC_ENTREGA_OUTRA_FILIAL when 'S' then cf.no_cooperativa_filial 
    else C.NO_COOPERADO end Cooperado, 
    CASE e.IC_ENTREGA_OUTRA_FILIAL when 'S' then upper(concat(concat(m.no_municipio,'-'), es.sg_estado))
    else upper(concat(concat(cfm.no_municipio,'-'), cfes.sg_estado)) end "Destino", 
    e.DS_ROTEIRO "Roteiro" , nvl(e.QT_QUANTIDADE,0)  - nvl(e.QT_FORNECIDO,0) SALDO, 
    (SELECT EMBL.CD_GRUPO_EMBALAGEM || '-' || EMBL.DS_GRUPO_EMBALAGEM  
    FROM vnd.sacaria SAC 
    INNER JOIN VND.GRUPO_EMBALAGEM EMBL
    ON 
    EMBL.CD_GRUPO_EMBALAGEM = SAC.CD_GRUPO_EMBALAGEM
    WHERE 
    SAC.CD_SACARIA = ae.CD_SACARIA
    AND ROWNUM =1) CD_GRUPO_EMBALAGEM,
    e.IC_ENTREGA_OUTRA_FILIAL,
    
    C.NO_COOPERADO,
    m.no_municipio MUNICIIPOIO_S,
    cfm.no_municipio MUNICICIOPO_n
    
    --INTO V_COOPERADO, V_DESTINO,V_ROTEIRO, V_SALDO, V_CD_GRUPO_EMBALAGEM
    from cpt.entrega e, cpt.autorizacao_entrega ae, cpt.cooperado c, 
    cpt.propriedade_cooperado p, ctf.municipio m, 
    ctf.estado es, cpt.cooperativa_filial cf, ctf.municipio cfm, 
    ctf.estado cfes
    where e.nu_protocolo_entrega IN('R121092HF1') --'R1163LL1'
    and ae.cd_autorizacao_entrega = e.cd_autorizacao_entrega
    and c.cd_cooperado = ae.cd_cooperado
    and p.cd_propriedade = ae.cd_propriedade
    and m.cd_municipio = p.cd_municipio
    and es.cd_estado = m.cd_estado
    and cf.cd_cooperativa_filial = ae.cd_cooperativa_filial
    and cfm.cd_municipio = cf.cd_municipio
    and cfes.cd_estado = cfm.cd_estado

select * from ELO_BLOCKING_TYPES_COLUMNS


select * from vnd.elo_AGENDAMENTO 
WHERE CD_ELO_AGENDAMENTO = 12

SELECT * FROM VND.ELO_STATUS WHERE CD_ELO_STATUS = 5



UPDATE ELO_CARTEIRA 
SET CD_STATUS_CEL_FINAL = 59
WHERE 
CD_ELO_CARTEIRA IN
(
2725,
2726
)


SELECT * FROM ELO_agendamento 
where 1=1
--cd_week >= 'W012018'
AND CD_CENTRO_EXPEDIDOR = '6082'
AND CD_POLO = 'P001'






select * from vnd.elo_carteira

where 

((nu_contrato_sap = '0040385303'  ) or
(nu_contrato_sap ='0040385303'  ) or 
(nu_contrato_sap ='0040384614' ) or
(nu_contrato_sap ='0040354202'  ))
--and ic_COOPERATIVE = 'S'
AND QT_agendada_confirmada > 0


SELECT *FROM CPT.ENTREGA 
WHERE NU_PROTOCOLO_ENTREGA IS NULL

