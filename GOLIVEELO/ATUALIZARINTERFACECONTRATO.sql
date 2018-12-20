WITH CTE_AGENDAMENTO AS 
        (
        SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, 
        AGE.CD_MACHINE, ma.DS_MACHINE, AGE.CD_WEEK , AGE.CD_POLO,
        es.DS_STATUS, AGE.CD_ELO_STATUS, AGE.NU_CARTEIRA_VERSION
        FROM VND.ELO_AGENDAMENTO AGE 
        LEFT JOIN CTF.MACHINE ma
        on AGE.CD_MACHINE = ma.CD_MACHINE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        
        WHERE AGE.IC_ATIVO = 'S'
      
        --AND (es.SG_STATUS IN ('PLAN','AGCTR','AGENC'))
        --AND ('W192018' is null OR AGE.CD_WEEK = 'W192018')
        AND AGE.CD_WEEK in ('W18s2018', 'W1x92018', 'W202018', 'W21x2018')
         and ('P002' is null or AGE.CD_POLO = 'P002')
        --and (P_MACHINES is null OR AGE.CD_MACHINE IN (P_MACHINES))
       -- and (P_POLO is null or AGE.CD_POLO = P_POLO) 
--               and (
--              P_DT_WEEK_START is null or 
--              (
--                  to_number(to_char(to_date(AGE.DT_WEEK_START,'DD/MM/RRRR'),'IW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'IW'))
--                  and extract(year from AGE.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
--              )
--           )
        
        ),
        
        CTE_CARTEIRA AS 
        (
        
        SELECT 
        CTAF.CD_ELO_CARTEIRA ,
        CTAF.CD_PRODUTO_SAP, 
        
        CTAF.CD_ELO_AGENDAMENTO, 
        CTAF.CD_TIPO_AGENDAMENTO, 
        CTAF.CD_TIPO_REPLAN, 
        CTAF.CD_STATUS_REPLAN,
        
        CTAF.CD_ELO_AGENDAMENTO_ITEM,
        CTAF.NU_ORDEM,
        CTAF.NU_CONTRATO_SAP,
        CTAF.CD_ITEM_CONTRATO,
        CTAF.NU_ORDEM_VENDA,
        CTAF.IC_PERMITIR_CS,
        
        CTAF.QT_AGENDADA_CONFIRMADA,
        CTAF.QT_PROGRAMADA,
        CTAF.QT_ENTREGUE,
        CTAF.QT_SALDO,

        CTAF.CD_INCOTERMS,
        CTAF.CD_STATUS_CUSTOMER_SERVICE,
        CTAF.CD_STATUS_TORRE_FRETES,
        CTAF.DH_LIBERACAO_TORRE_FRETES,
        CTAF.CD_STATUS_CEL_FINAL,
        
        
        CTAF.CD_CLIENTE ,
        CTAF.NO_CLIENTE ,
        CTAF.DH_BACKLOG_CIF,
        AGEF.CD_WEEK,
        AGEF.CD_POLO,
        AGEF.CD_ELO_STATUS, 
        AGEF.NU_CARTEIRA_VERSION,           
        

        NVL((SELECT DS.DS_CENTRO_EXPEDIDOR FROM CTF.CENTRO_EXPEDIDOR DS WHERE DS.CD_CENTRO_EXPEDIDOR = CTAF.CD_CENTRO_EXPEDIDOR_FABRICA), CTAF.DS_CENTRO_EXPEDIDOR) DS_CENTRO_EXPEDIDOR,
        NVL(CTAF.CD_CENTRO_EXPEDIDOR_FABRICA, CTAF.CD_CENTRO_EXPEDIDOR) CD_CENTRO_EXPEDIDOR,
        CTAF.CD_SALES_GROUP,
        CTAF.CD_GRUPO_EMBALAGEM,
        CTAF.IC_ATIVO,
        CTAF.IC_CORTADO_FABRICA,
        CTAF.DH_REPLAN,
        CTAF.NU_PROTOCOLO,
        CTAF.NU_PROTOCOLO_ENTREGA,

        CTAF.DS_VERSAO
        FROM VND.ELO_CARTEIRA CTAF
        INNER JOIN CTE_AGENDAMENTO AGEF
        ON CTAF.CD_ELO_AGENDAMENTO = AGEF.CD_ELO_AGENDAMENTO
        WHERE
        CTAF.IC_ATIVO = 'S'
        --AND CTAF.CD_TIPO_AGENDAMENTO = 25 
         
        --AND CTAF.CD_STATUS_REPLAN IS NOT NULL
        --AND CTAF.CD_STATUS_CUSTOMER_SERVICE IS NOT NULL AND CTAF.DH_LIBERACAO_TORRE_FRETES IS NOT NULL
        --AND NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) = 0
        --and CTAF.CD_ELO_AGENDAMENTO_ITEM = 13759
        and nu_ordem_venda = '0002359599'
        
        --  and ('6100' is null or NVL(CTAF.CD_CENTRO_EXPEDIDOR_FABRICA, CTAF.CD_CENTRO_EXPEDIDOR) = '6100')
        --  AND (NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) > 0 AND (NVL(CTAF.IC_CORTADO_FABRICA,'0') = '0'))
        
        )--,
        
        SELECT * FROM CTE_CARTEIRA;
        
        CTE_AGENDAMENTO_FILTER AS 
        (
        SELECT ag.CD_ELO_AGENDAMENTO, ag.CD_CENTRO_EXPEDIDOR, ag.CD_MACHINE, ag.DS_MACHINE, ag.CD_WEEK , ag.DS_STATUS, ag.CD_ELO_STATUS
        FROM CTE_AGENDAMENTO ag
        WHERE 
            EXISTS (
                    SELECT 1 FROM CTE_CARTEIRA CTA 
                    WHERE 
                    CTA.CD_ELO_AGENDAMENTO = ag.CD_ELO_AGENDAMENTO
                    )
        
        ),
        
        --select * from CTE_AGENDAMENTO_FILTER
        
        
        CTE_CARTEIRA_DAY AS
        (
                  SELECT da.CD_ELO_CARTEIRA CD_ELO_CARTEIRA, SUM(da.NU_QUANTIDADE) NU_QUANTIDADE,  da.NU_DIA_SEMANA
          FROM VND.ELO_CARTEIRA_DAY da
          INNER JOIN CTE_CARTEIRA CTAD
          ON da.CD_ELO_CARTEIRA = CTAD.CD_ELO_CARTEIRA
          INNER JOIN CTE_AGENDAMENTO_FILTER FILAG
          ON CTAD.CD_ELO_AGENDAMENTO = FILAG.CD_ELO_AGENDAMENTO
          GROUP BY da.CD_ELO_CARTEIRA, da.NU_DIA_SEMANA
        ),
        
        ELO_AG_DAY_BY_INCOTERMS_ITEM AS 
        (

        SELECT  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA, 
        SUM(DAYY.NU_QUANTIDADE) NU_QUANTIDADE, EAG_ITEM_I.CD_CLIENTE, EAG_ITEM_I.CD_INCOTERMS,
        MAX(EAG_WE_I.QT_SEMANA) QT_SEMANA_SALDO, 
        MAX((SELECT SUM(SUD.NU_QUANTIDADE) 
            FROM VND.ELO_AGENDAMENTO_DAY SUD 
            WHERE SUD.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK)) QT_SUM_DAY_WEEK,
        MAX((SELECT SUM(SUD.NU_QUANTIDADE) 
            FROM VND.ELO_AGENDAMENTO_DAY SUD 
            WHERE SUD.CD_ELO_AGENDAMENTO_WEEK = DAYY.CD_ELO_AGENDAMENTO_WEEK
            AND SUD.CD_GRUPO_EMBALAGEM = DAYY.CD_GRUPO_EMBALAGEM
            --AND SUD.NU_DIA_SEMANA = DAYY.NU_DIA_SEMANA 
            )) QT_SUM_DAY_EMBALAGEM      
        
        FROM CTE_AGENDAMENTO_FILTER FILT
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EA_SUP_I  
        ON FILT.CD_ELO_AGENDAMENTO = EA_SUP_I.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAG_ITEM_I
        --INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAG_ITEM_I
        ON 
        EAG_ITEM_I.CD_ELO_AGENDAMENTO_SUPERVISOR = EA_SUP_I.CD_ELO_AGENDAMENTO_SUPERVISOR
        AND EAG_ITEM_I.IC_ATIVO = 'S'	
        
        INNER JOIN VND.ELO_AGENDAMENTO_WEEK EAG_WE_I
        ON EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM = EAG_WE_I.CD_ELO_AGENDAMENTO_ITEM
        
        --LEFT JOIN VND.ELO_AGENDAMENTO_GROUPING EAG_GRO_I
        --ON EAG_GRO_I.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK
        INNER JOIN VND.ELO_AGENDAMENTO_DAY DAYY
        ON 
        DAYY.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK
        
        WHERE 
        EA_SUP_I.IC_ATIVO = 'S'
                AND             EXISTS (
                    SELECT 1 FROM CTE_CARTEIRA CTA 
                    WHERE 
                    CTA.CD_ELO_AGENDAMENTO_ITEM = EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM
                    )

                                        
        GROUP BY  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA , EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM  , EAG_ITEM_I.CD_CLIENTE,
        EAG_ITEM_I.CD_INCOTERMS
        
        )--,
        SELECT * FROM ELO_AG_DAY_BY_INCOTERMS_ITEM ORDER BY CD_ELO_AGENDAMENTO_ITEM, CD_GRUPO_EMBALAGEM, NU_DIA_SEMANA;
        
       -- SELECT * FROM VND.ELO_AGENDAMENTO_DAY
       
       --select * from vnd.elo_vbak_protocolo where cd_elo_carteira = 40434;
       
       select * from vnd.elo_agendamento_item 
       where cd_elo_agendamento_item= '13759';

       select * from vnd.elo_agendamento_week 
       where cd_elo_agendamento_item= '13759';
       
       
select * from vnd.elo_carteira where 
nu_contrato_sap = '0040387703'

select * from vnd.elo_carteira_sap where 
nu_contrato_sap = '0040387703'

cd_elo_carteira in (       
40503,
40504);
       
select * from vnd.pedido
where nu_ordem_venda = '0002359599'  


update vnd.elo_carteira 
set no_sales_office = 'MAN-Alfredo Ghiraldi'
where cd_elo_carteira in (
39443,
40281
);
     

select  cd_sales_office, count(1)
from 
(
select  no_sales_office, cd_sales_office
from vnd.elo_carteira 
group by  no_sales_office, cd_sales_office
)
group by  cd_sales_office
having count(1) > 1 


select cd_elo_carteira, no_sales_office, cd_sales_office from vnd.elo_carteira
where cd_sales_office = 5913 and no_sales_office <> 'MAN-Alfredo Ghiraldi'   

select no_sales_office, cd_sales_office from vnd.elo_carteira_sap 
where  cd_sales_office = 5913 and no_sales_office <> 'MAN-Alfredo Ghiraldi'  



select 
cd_elo_carteira,
no_sales_office, cd_sales_office from vnd.elo_carteira
update vnd.elo_carteira
set no_sales_office = 'MAN-Alfredo Ghiraldi'

where 
no_sales_office <> 'MAN-Alfredo Ghiraldi' and
cd_elo_carteira in 
(
35911,
35913,
35915,
35918,
35919,
35920,
35754,
35440,
35596,
35599,
35600,
35601,
35606,
35607,
35608,
35609,
36746,
36750,
36751,
36752,
36754,
36755,
36756,
37021,
37022,
37023,
37024,
37025,
37028,
37029,
36208,
36209,
36211,
36212,
36214,
36215,
36216,
36217,
36218,
36219,
36481,
36483,
36484,
36485,
36486,
36487,
37272,
37274,
37275,
37276,
37277,
37279,
37282,
37283,
37551,
37552,
37553,
37557,
37558,
37559,
38946,
38948,
39416,
39418,
39419,
39424,
39428,
39539,
39540,
39441,
39543,
39545,
39547,
39454,
39549,
39553,
39461,
39462,
39558,
39559,
39463,
39472,
39473,
39474,
39476,
39478,
39482,
39483,
39484,
39488,
39494,
39496,
39497,
39498,
39501,
39400,
39409,
39410,
39509,
39512,
39513,
39514,
39517,
39521,
39523,
35597,
40277,
40278,
40279,
40280,
40282,
40283
);


    