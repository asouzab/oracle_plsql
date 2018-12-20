        WITH CTE_AGENDAMENTO AS 
        (
        SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_POLO,
        AGE.CD_MACHINE, ma.DS_MACHINE, AGE.CD_WEEK ,
        es.DS_STATUS, AGE.CD_ELO_STATUS
        FROM VND.ELO_AGENDAMENTO AGE 
        LEFT JOIN CTF.MACHINE ma
        on AGE.CD_MACHINE = ma.CD_MACHINE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        
        WHERE AGE.IC_ATIVO = 'S'
        AND (es.SG_STATUS IN ('XPLAN','XAGCTR','AGENC'))
        --AND (P_CD_WEEK is null OR AGE.CD_WEEK = P_CD_WEEK)
         and AGE.CD_WEEK >= 'W302018' AND  AGE.CD_WEEK < 'W342018'
        --AND ('W182018' is null OR AGE.CD_WEEK = 'W182018')
        --and (P_MAQUINA is null OR AGE.CD_MACHINE IN (P_MAQUINA))
       -- and (P_CD_POLO is null OR AGE.CD_POLO IN (P_CD_POLO))
        
        ),
        --SELECT * FROM CTE_AGENDAMENTO
        
    CTE_CARTEIRA AS 
        (
        
        SELECT DISTINCT 
        CTAF.CD_ELO_CARTEIRA , 
        CTAF.CD_ELO_AGENDAMENTO, 
        CTAF.CD_TIPO_AGENDAMENTO, 
        STS.DS_STATUS DS_TIPO_AGENDAMENTO,
        CTAF.CD_TIPO_REPLAN, 
        CTAF.QT_AGENDADA_CONFIRMADA,
        CTAF.CD_ELO_AGENDAMENTO_ITEM,
        CTAF.CD_INCOTERMS,
        CTAF.CD_CLIENTE ,
        CTAF.NO_CLIENTE ,
        CTAF.CD_CLIENTE_PAGADOR,
        CTAF.NO_CLIENTE_PAGADOR,
        CTAF.CD_CLIENTE_RECEBEDOR,
        CTAF.NO_CLIENTE_RECEBEDOR,
        CASE
            WHEN TRIM(CTAF.CD_INCOTERMS) = 'FOB' THEN CTAF.CD_CLIENTE_PAGADOR
            WHEN TRIM(CTAF.CD_INCOTERMS) = 'CIF' THEN CTAF.CD_CLIENTE_RECEBEDOR
        END COD_CLIENTE, 
        
        CASE
            WHEN TRIM(CTAF.CD_INCOTERMS) = 'FOB' THEN CTAF.NO_CLIENTE_PAGADOR
            WHEN TRIM(CTAF.CD_INCOTERMS) = 'CIF' THEN CTAF.NO_CLIENTE_RECEBEDOR
        END CLIENTE,         
        
        CTAF.DH_BACKLOG_CIF,
        CTAF.DS_CENTRO_EXPEDIDOR,
        CTAF.CD_CENTRO_EXPEDIDOR,
        CTAF.CD_SALES_GROUP,
        CTAF.CD_GRUPO_EMBALAGEM,
        CTAF.IC_ATIVO,
        CTAF.QT_SALDO
        FROM VND.ELO_CARTEIRA CTAF
        INNER JOIN CTE_AGENDAMENTO AGEF
        ON CTAF.CD_ELO_AGENDAMENTO = AGEF.CD_ELO_AGENDAMENTO
        LEFT JOIN VND.ELO_STATUS STS 
        ON STS.CD_ELO_STATUS = CTAF.CD_TIPO_AGENDAMENTO
        WHERE
        CTAF.IC_ATIVO = 'S'
        AND  CTAF.QT_AGENDADA_CONFIRMADA > 0 
        --and (P_CENTRO is null or CTAF.CD_CENTRO_EXPEDIDOR = P_CENTRO)
        --and ('6060' is null or CTAF.CD_CENTRO_EXPEDIDOR = '6060')
        AND ((CTAF.CD_TIPO_AGENDAMENTO IN (22, 23, 24) or (CTAF.CD_TIPO_AGENDAMENTO = 25 AND CTAF.CD_STATUS_REPLAN = 32)
        or exists (select 1 from vnd.vw_elo_agendamento_item_adicao adicao
        where ctaf.CD_ELO_AGENDAMENTO_item = adicao.CD_ELO_AGENDAMENTO_item)        

        ) 
        
        )
        ),
        --SELECT * FROM CTE_CARTEIRA
        
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
        --SELECT * FROM CTE_AGENDAMENTO_FILTER
        
        ELO_AG_DAY_BY_INCOTERMS_ITEM  AS (
        SELECT  EA_SUP_I.CD_ELO_AGENDAMENTO, EA_SUP_I.CD_SALES_GROUP , EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, EAG_ITEM_I.CD_INCOTERMS, 
        DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA, SUM(DAYY.NU_QUANTIDADE) NU_QUANTIDADE, 
        MAX(CD_COTA_COMPARTILHADA) CD_COTA_COMPARTILHADA, EAG_ITEM_I.CD_CLIENTE
        FROM CTE_AGENDAMENTO_FILTER FILT
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EA_SUP_I  
        ON FILT.CD_ELO_AGENDAMENTO = EA_SUP_I.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAG_ITEM_I
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
                                        
        GROUP BY  EA_SUP_I.CD_ELO_AGENDAMENTO, EA_SUP_I.CD_SALES_GROUP , EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, 
        EAG_ITEM_I.CD_INCOTERMS, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA , EAG_ITEM_I.CD_CLIENTE                                   
        )   
        --SELECT * FROM ELO_AG_DAY_BY_INCOTERMS_ITEM
       

    SELECT * FROM (

    select  
    ag.CD_ELO_AGENDAMENTO ,
    
    (select d.CD_ELO_CARTEIRA 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 ) CD_ELO_CARTEIRA ,
    
    WEEKSD.CD_ELO_AGENDAMENTO_WEEK AGRUPAR_POR_SEMANA,
    
    (select sum(d.qt_agendada_confirmada)
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    ) volume_programado_carteira ,
    
    AGDAY.NU_QUANTIDADE VOLUME_DIARIO,
    
    (select sum(d.qt_semana)
    FROM VND.ELO_AGENDAMENTO_WEEK D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    ) volume_semanal ,    
    
    
    ag.CD_WEEK ,
    ag.CD_ELO_STATUS ,
    ag.DS_STATUS  ,
    --TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
    (select CASE WHEN UPPER(estrp.DS_STATUS) = 'REPLAN' THEN 'Replan' ELSE 'Plan' END
    FROM CTE_CARTEIRA D 
    INNER JOIN VND.ELO_STATUS estrp
    ON d.CD_TIPO_AGENDAMENTO = estrp.CD_ELO_STATUS
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 ) TIPO_REPLAN,
    --to_char(ec.DH_BACKLOG_CIF)  DH_BACKLOG_CIF,
    (select d.DH_BACKLOG_CIF 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 ) DH_BACKLOG_CIF,
    (select d.DS_CENTRO_EXPEDIDOR 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND d.DS_CENTRO_EXPEDIDOR is not null
    AND ROWNUM =1 ) DS_CENTRO_EXPEDIDOR ,
    NVL(ag.CD_CENTRO_EXPEDIDOR, ( select d.CD_CENTRO_EXPEDIDOR 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND d.CD_CENTRO_EXPEDIDOR is not null
    AND ROWNUM =1  )) CD_CENTRO_EXPEDIDOR,
    ma.DS_MACHINE ,
    ma.CD_MACHINE,
    AGDAY.CD_INCOTERMS ,
    AGDAY.CD_CLIENTE ,
    NVL(CLI.NO_CLIENTE, (select d.NO_CLIENTE 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 )) NO_CLIENTE  ,
    --eai.CD_COTA_COMPARTILHADA                                            as COTA,
    '' AS COTA,
    (SELECT u.CD_USUARIO || '-' || u.NO_USUARIO 
    FROM CTE_CARTEIRA d 
    INNER JOIN CTF.USUARIO u
    on D.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1) as SUPERVISOR,
    (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDAY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as DS_GRUPO_EMBALAGEM,
    AGDAY.CD_GRUPO_EMBALAGEM,
    

    AGDAY.CD_ELO_AGENDAMENTO_ITEM,
    AGDAY.CD_COTA_COMPARTILHADA,
    AGDAY.NU_DIA_SEMANA, 
    AGDAY.CD_SALES_GROUP,
    AGDAY.CD_SALES_GROUP || ' - ' || USU.NO_USUARIO NO_SUPERVISOR
    

    
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM AGDAY
    INNER JOIN CTE_AGENDAMENTO_FILTER ag
    ON 
    ag.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO
    INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEEKSD
    ON AGDAY.CD_ELO_AGENDAMENTO_ITEM = WEEKSD.CD_ELO_AGENDAMENTO_ITEM
    
    left join CTF.MACHINE ma
    on ag.CD_MACHINE = ma.CD_MACHINE
    
    left JOIN  CTF.CLIENTE CLI
    ON AGDAY.CD_CLIENTE = CLI.CD_CLIENTE
    
    left join CTF.USUARIO USU
    on
    USU.CD_USUARIO_ORIGINAL = AGDAY.CD_SALES_GROUP
    
    WHERE 
    AGDAY.CD_INCOTERMS IN( 'CIF', 'FOB')
    
    )
    
    WHERE 
    NVL(VOLUME_PROGRAMADO_CARTEIRA,0 ) <> NVL(VOLUME_SEMANAL,0)
  

;
