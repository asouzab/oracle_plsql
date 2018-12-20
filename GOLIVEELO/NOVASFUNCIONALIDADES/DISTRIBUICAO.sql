select * from vnd.elo_agendamento 
where cd_elo_status = 2;

--edit vnd.elo_agendamento 
select * from vnd.elo_agendamento
where 
--cd_elo_agendamento = 78;
cd_week = 'W412018' AND cd_centro_expedidor = '6000'
CD_POLO = 'P002';
--cd_elo_agendamento = 78;


select * from v$session
where 
;

select CD_PRODUTO_SAP, nu_contrato_sap, nu_ordem_venda, qt_programada, qt_entregue, qt_saldo, qt_agendada, qt_agendada_confirmada
 from vnd.elo_carteira where cd_elo_agendamento_item in 
(

select item.cd_elo_agendamento_item from vnd.elo_agendamento age
inner join vnd.elo_agendamento_supervisor sup
on age.cd_elo_agendamento = sup.cd_elo_agendamento
inner join vnd.elo_agendamento_item item
on sup.cd_elo_agendamento_supervisor = item.cd_elo_agendamento_supervisor
inner join vnd.elo_agendamento_week wee
on 
item.cd_elo_agendamento_item = wee.cd_elo_agendamento_item 
inner join vnd.elo_agendamento_day da
on 
wee.cd_elo_agendamento_week = da.cd_elo_agendamento_week
where 
--item.cd_elo_agendamento_item = 13079

age.cd_elo_agendamento = 454


--and sup.cd_sales_group in ('706', '705', '709')
--and item.CD_PRODUTO_SAP in ('000000000000119200', '000000000000118869', '000000000000108600')
--and item.cd_cliente in ('0004023275', '0004028212', '0004024069')
)
and nu_ordem_venda = '0002164912'
and CD_STATUS_CEL_FINAL > 1 AND CD_TIPO_AGENDAMENTO IS NOT NULL  AND  QT_AGENDADA_CONFIRMADA >= 0 AND CD_INCOTERMS = 'FOB'
;


select  * from vnd.elo_carteira 
where cd_elo_agendamento = 145
and qt_agendada_confirmada >=0
AND nu_contrato_sap in ('0040387059', '0040389095', '0040390272') ;

--update vnd.elo_carteira 
set qt_agendada = null,
qt_agendada_confirmada = null
where cd_elo_agendamento = 22;


select * from vnd.elo_carteira_day
where cd_elo_carteira in 

(
select  cd_elo_carteira from vnd.elo_carteira 
where cd_elo_agendamento = 22
--and qt_agendada_confirmada > 0 
)

; 


delete from vnd.elo_carteira_day where cd_elo_carteira_day in 
(
61748,
61749,
61750,
61751,
61752,
61753,
61754

);



        SELECT COUNT(DISTINCT NU_SEMANA) FROM (

              SELECT aw.NU_SEMANA

              FROM vnd.elo_agendamento_week aw

              LEFT OUTER JOIN vnd.elo_agendamento_item ai
                ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

             INNER JOIN vnd.elo_agendamento_supervisor ap
                ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor

              LEFT OUTER JOIN vnd.elo_carteira ca
                ON ca.cd_elo_agendamento = ap.cd_elo_agendamento
               AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

             WHERE
             -- (p_cd_sales_office IS NULL OR ap.cd_sales_office = p_cd_sales_office)
             --  AND (p_cd_sales_group IS NULL OR ap.cd_sales_group = p_cd_sales_group)
             --  AND ap.cd_elo_agendamento = v_cd_elo_agendamento
                ap.cd_elo_agendamento = 22
               AND ap.ic_ativo = 'S'
               AND NVL(aw.qt_semana,0) > 0

--             GROUP BY aw.cd_elo_agendamento_week,
--                      aw.qt_semana
               GROUP BY aw.NU_SEMANA, aw.qt_semana

            HAVING (NVL(SUM(ca.qt_saldo),0) - NVL(SUM(ca.qt_agendada),0)) > 0
               AND (aw.qt_semana - NVL(SUM(ca.qt_agendada),0)) > 0
        )
        ;
        
        
SELECT NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, NU_ORDEM_VENDA , COUNT(1) 
FROM VND.VW_ELO_CARTEIRA_SAP 
GROUP BY NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, NU_ORDEM_VENDA
HAVING COUNT(1) > 1;


AND ROWNUM < 10;    


DROP INDEX VND.IDX_NU_CARTEIRA_VERSIONSTATUS;

CREATE INDEX VND.IDX_NU_CARTEIRA_VERSIONSTATUS ON VND.ELO_AGENDAMENTO
(NU_CARTEIRA_VERSION, CD_ELO_STATUS)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );   
        

CREATE INDEX VND.IDX_NU_CARTV_NR_SAP_ITEM_PROD ON VND.ELO_CARTEIRA_SAP
(NU_CARTEIRA_VERSION, NU_CONTRATO_SAP, CD_ITEM_CONTRATO, CD_PRODUTO_SAP)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );   
        


SELECT * FROM V$SESSION