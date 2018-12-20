CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_CONTROLLERSHIP" AS

    PROCEDURE PX_GET_CENTERS ( P_RETURN OUT T_CURSOR )
    IS
    BEGIN
        OPEN P_RETURN FOR
        
        select ce.CD_CENTRO_EXPEDIDOR,
               ce.CD_CENTRO_EXPEDIDOR || ' - ' || ce.DS_CENTRO_EXPEDIDOR DS_CENTRO_EXPEDIDOR
          from CTF.CENTRO_EXPEDIDOR ce
         where ce.IC_ATIVO = 'S'
      order by ce.CD_CENTRO_EXPEDIDOR;
    
    END PX_GET_CENTERS;
    
    PROCEDURE PX_GET_MACHINES ( P_CD_CENTRO     IN CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%type,
                                P_RETURN        OUT T_CURSOR )
    IS
    BEGIN
        OPEN P_RETURN FOR
        
        select ma.CD_MACHINE,
               ma.DS_MACHINE
          from CTF.MACHINE ma
         inner join CTF.CENTRO_EXPEDIDOR_MACHINE cem
            on ma.CD_MACHINE = cem.CD_MACHINE
         where ma.IC_ATIVO = 'S'
           and cem.IC_ATIVO = 'S'
           and cem.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
      order by ma.DS_MACHINE;
    
    END PX_GET_MACHINES;
    
    PROCEDURE PX_GET_PACKAGES (P_RETURN OUT T_CURSOR)
    
    IS
    BEGIN
        OPEN P_RETURN FOR
        
            select ge.CD_GRUPO_EMBALAGEM,
                   ge.DS_GRUPO_EMBALAGEM
              from VND.GRUPO_EMBALAGEM ge
          order by ge.DS_GRUPO_EMBALAGEM;
    
    END PX_GET_PACKAGES;
  
    PROCEDURE PX_GET_CUSTOMERS (P_CD_CENTRO  in CTF.CENTRO_EXPEDIDOR_MACHINE.CD_CENTRO_EXPEDIDOR%type,
                                P_RETURN     OUT T_CURSOR)
                                
    IS
    BEGIN
        OPEN P_RETURN FOR
        
        select 
               ec.NO_CLIENTE                                    as CodeCustomer,
               ec.NO_CLIENTE                                    as DescriptionCustomer
          from VND.ELO_CARTEIRA ec
          INNER JOIN VND.ELO_AGENDAMENTO AG 
          ON AG.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
         where ec.IC_ATIVO = 'S'
         AND AG.IC_ATIVO = 'S'
         AND (P_CD_CENTRO IS NULL OR AG.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO)
         AND ROWNUM < 20  --PLEASE DONT DELETE THIS WHERE HERE BECAUSE FIND BY CENTRO IF RETURN MORE LINE DEAD BLOCK THE WEB
         GROUP BY ec.NO_CLIENTE
      order by ec.NO_CLIENTE;
   
    END PX_GET_CUSTOMERS;
    
    PROCEDURE PX_GET_STATUS (P_SG_TIPO_STATUS   IN VND.ELO_TIPO_STATUS.SG_TIPO_STATUS%type,
                             P_RETURN           OUT T_CURSOR)
                             
    IS
    BEGIN
        OPEN P_RETURN FOR      
        
        select es.CD_ELO_STATUS     as "value",
               es.DS_STATUS         as "text"
          from VND.ELO_STATUS es
         inner join VND.ELO_TIPO_STATUS ts
            on es.CD_ELO_TIPO_STATUS = ts.CD_ELO_TIPO_STATUS
         where ts.SG_TIPO_STATUS = UPPER(TRIM(P_SG_TIPO_STATUS))
      order by es.NU_ORDER;
        
    END PX_GET_STATUS;
    
    PROCEDURE PX_GET_REASON (P_RETURN           OUT T_CURSOR)
                             
    IS
    BEGIN
        OPEN P_RETURN FOR      
        
          select cr.CD_ELO_CONTROLLERSHIP_REASON        as "value",
                 cr.DS_CONTROLLERSHIP_REASON            as text
            from VND.ELO_CONTROLLERSHIP_REASON cr
        order by cr.DS_CONTROLLERSHIP_REASON;
        
    END PX_GET_REASON;
    
    PROCEDURE PX_GET_RECEBEDOR_COOP (P_RETURN         OUT T_CURSOR)
    
    IS
    BEGIN
    
        OPEN P_RETURN FOR
            select distinct 
                   ec.CD_CLIENTE_RECEBEDOR,
                   ec.NO_CLIENTE_RECEBEDOR
              from VND.ELO_CARTEIRA ec
              WHERE ec.IC_ATIVO = 'S'
          order by ec.NO_CLIENTE_RECEBEDOR;
             
    END PX_GET_RECEBEDOR_COOP;
    
    PROCEDURE PX_GET_SUPERVISOR (P_RETURN       OUT T_CURSOR)
    
    IS
    BEGIN
    
        OPEN P_RETURN FOR
            select distinct 
                   u.CD_USUARIO,
                   u.NO_USUARIO
              from CTF.USUARIO u
             inner join VND.ELO_CARTEIRA ec
                on ec.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
                WHERE ec.IC_ATIVO = 'S'
          order by u.NO_USUARIO;
    
    END PX_GET_SUPERVISOR;
    
    PROCEDURE PX_GET_MATERIAL (P_RETURN       OUT T_CURSOR)
    
    IS
    BEGIN
    
        OPEN P_RETURN FOR
            select distinct
                   TRIM(ec.CD_PRODUTO_SAP) as CD_PRODUTO_SAP,
                   ec.NO_PRODUTO_SAP
              from VND.ELO_CARTEIRA ec
          order by ec.NO_PRODUTO_SAP;
    
    END PX_GET_MATERIAL;
    
    PROCEDURE PX_GET_SHIPPING_COMPANY (P_CD_CARTEIRA    in VND.ELO_MARCACAO.CD_ELO_CARTEIRA%type,
                                       P_RETURN         OUT T_CURSOR)
    
    IS
    BEGIN
        OPEN P_RETURN FOR
        
              select distinct
                     tr.CD_TRANSPORTADORA                                               as "value",
                     LTRIM(tr.CD_TRANSPORTADORA, '0') || ' - ' || tr.NO_TRANSPORTADORA  as text
                from VND.ELO_CARTEIRA_TORRE_FRETES tf
               inner join VND.TRANSPORTADORA tr
                  on tf.CD_TRANSPORTADORA = tr.CD_TRANSPORTADORA
               where tf.NU_QUANTIDADE > 0
                 and tf.VL_FRETE_CONTRATADO > 0
                 and (P_CD_CARTEIRA is null or tf.CD_ELO_CARTEIRA = P_CD_CARTEIRA);
    
    END PX_GET_SHIPPING_COMPANY;
    
 
    PROCEDURE PX_SEARCH_PLANNING_AAAA (
        P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MACHINES              IN VARCHAR,
----        P_WEEK                  IN INT,
        P_DT_WEEK_START         IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
        P_RETURN                OUT T_CURSOR)
        
    IS
    BEGIN
        OPEN P_RETURN FOR
        
      
        
        WITH CTE_AGENDAMENTO_FILTER AS 
        (
        SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_MACHINE, ma.DS_MACHINE, AGE.CD_WEEK , es.DS_STATUS, AGE.CD_ELO_STATUS
        FROM VND.ELO_AGENDAMENTO AGE 
        LEFT JOIN CTF.MACHINE ma
        on AGE.CD_MACHINE = ma.CD_MACHINE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        
        WHERE AGE.IC_ATIVO = 'S'
      
        AND (es.SG_STATUS IN ('PLAN','AGCTR','AGENC'))
       -- AND (P_WEEK is null OR AGE.CD_WEEK = P_WEEK)
        and (P_MACHINES is null OR AGE.CD_MACHINE IN (P_MACHINES))
        and (P_POLO is null or AGE.CD_POLO = P_POLO) 
               and (
              P_DT_WEEK_START is null or 
              (
                  to_number(to_char(to_date(AGE.DT_WEEK_START,'DD/MM/RRRR'),'IW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'IW'))
                  and extract(year from AGE.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
              )
           )
        
        ),
        
        CTE_CARTEIRA AS 
        (
        
        SELECT 
        CTAF.CD_ELO_CARTEIRA , 
        CTAF.CD_ELO_AGENDAMENTO, 
        CTAF.CD_TIPO_AGENDAMENTO, 
        CTAF.CD_TIPO_REPLAN, 
        CTAF.QT_AGENDADA_CONFIRMADA,
        CTAF.CD_ELO_AGENDAMENTO_ITEM,
        CTAF.CD_INCOTERMS,
        CTAF.CD_CLIENTE ,
        CTAF.NO_CLIENTE ,
        CTAF.DH_BACKLOG_CIF,
        CTAF.DS_CENTRO_EXPEDIDOR,
        CTAF.CD_CENTRO_EXPEDIDOR,
        CTAF.CD_SALES_GROUP,
        CTAF.CD_GRUPO_EMBALAGEM,
        CTAF.IC_ATIVO
        FROM VND.ELO_CARTEIRA CTAF
        INNER JOIN CTE_AGENDAMENTO_FILTER AGEF
        ON CTAF.CD_ELO_AGENDAMENTO = AGEF.CD_ELO_AGENDAMENTO
        WHERE
        CTAF.IC_ATIVO = 'S'
          and (P_CD_CENTRO_EXPEDIDOR is null or CTAF.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
          AND ((CTAF.QT_AGENDADA_CONFIRMADA > 0 AND CTAF.CD_TIPO_AGENDAMENTO = 25 AND CTAF.CD_STATUS_REPLAN = 32)
          OR (CTAF.CD_TIPO_AGENDAMENTO IN (22, 23, 24) AND NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (CTAF.IC_CORTADO_FABRICA <> 1 OR CTAF.IC_CORTADO_FABRICA IS NULL))
          )
        
        ),
        
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
        

        SELECT  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA, 
        SUM(DAYY.NU_QUANTIDADE) NU_QUANTIDADE, EAG_ITEM_I.CD_CLIENTE, EAG_ITEM_I.CD_INCOTERMS
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

                                        
        GROUP BY  EA_SUP_I.CD_ELO_AGENDAMENTO, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA , EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM  , EAG_ITEM_I.CD_CLIENTE,
        EAG_ITEM_I.CD_INCOTERMS
        
        ),
        
       ELO_AG_DAY AS (
        SELECT  EADBI.CD_ELO_AGENDAMENTO, EADBI.CD_GRUPO_EMBALAGEM, 
        EADBI.NU_DIA_SEMANA, SUM(EADBI.NU_QUANTIDADE) NU_QUANTIDADE,
        EADBI.CD_INCOTERMS,
        EADBI.CD_CLIENTE
        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM EADBI
        GROUP BY  EADBI.CD_ELO_AGENDAMENTO,  EADBI.CD_GRUPO_EMBALAGEM, EADBI.NU_DIA_SEMANA , 
        EADBI.CD_INCOTERMS, EADBI.CD_CLIENTE                                   
        )      
        
          SELECT 
               CodeAgendamento,
               MAX(CodeCarteira) CodeCarteira,
               SEMANA,
               CD_STATUS,
               CLASSIFICACAO,
               TIPO_REPLAN,
               BACKLOG,
               CENTRO,
               MAQUINA,
               INCOTERM,
               CD_CLIENTE,
               DS_CLIENTE,
               MAX(COTA) COTA,
               MAX(SUPERVISOR) SUPERVISOR,
               EMBALAGEM,
               MAX(DIA_EXATO) DIA_EXATO,

               SUM(VALOR) VALOR,
               SUM(SEG) SEG, 
               SUM(TER) TER,
               SUM(QUA) QUA,
               SUM(QUI) QUI,
               SUM(SEX) SEX,
               SUM(SAB) SAB,
               SUM(DOM) DOM

        
        FROM 
        (        
        
        select distinct 
               ag.CD_ELO_AGENDAMENTO                                                as CodeAgendamento,
               ec.CD_ELO_CARTEIRA                                                   as CodeCarteira,
               ag.CD_WEEK                                                           as SEMANA,
               ag.CD_ELO_STATUS                                                     as CD_STATUS,
               ag.DS_STATUS                                                         as CLASSIFICACAO,
               TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
               to_char(ec.DH_BACKLOG_CIF)                                           as BACKLOG,
               ec.DS_CENTRO_EXPEDIDOR                                               as CENTRO,
               ma.DS_MACHINE                                                        as MAQUINA,
               ec.CD_INCOTERMS                                                      as INCOTERM,
               ec.CD_CLIENTE                                                        as CD_CLIENTE,
               ec.NO_CLIENTE                                                        as DS_CLIENTE,
               --eai.CD_COTA_COMPARTILHADA                                            as COTA,
               '' AS COTA,
               u.CD_USUARIO || '-' || u.NO_USUARIO                                  as SUPERVISOR,
                 (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as EMBALAGEM,
               (CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                     THEN NVL(ec.CD_DIA_EXATO, ' ') 
                     ELSE ' ' END)                                                  as DIA_EXATO,
               --NVL(ec.QT_AGENDADA_CONFIRMADA,0)                                                as VALOR,
               NVL(
               CASE WHEN ec.CD_INCOTERMS = 'CIF' THEN 
               (SELECT SUM(CC.QT_AGENDADA_CONFIRMADA)  QT_AGENDADA_CONFIRMADA 
               FROM CTE_CARTEIRA CC 
               WHERE ec.CD_ELO_CARTEIRA = CC.CD_ELO_CARTEIRA)
               ELSE 
               (SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO)
               END 
             
               ,0) VALOR,
               
               
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 1 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as SEG,

               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 2 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as TER,
                        
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 3 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as QUA,

               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 4 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as QUI,  
                        
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 5 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as SEX,

               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 6 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as SAB, 
                        
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 7 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as DOM                       
                        
 
         from (
          SELECT intec.CD_ELO_CARTEIRA , intec.CD_ELO_AGENDAMENTO, intec.CD_ELO_AGENDAMENTO_ITEM, 
          intec.CD_INCOTERMS, intec.CD_TIPO_REPLAN,
         
          SUM(intec.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA,
           intec.CD_SALES_GROUP, 
          MAX((SELECT MAX(tf.CD_DIA_EXATO) CD_DIA_EXATO
          FROM VND.ELO_CARTEIRA_TORRE_FRETES tf 
          WHERE intec.CD_ELO_CARTEIRA = tf.CD_ELO_CARTEIRA 
          AND tf.NU_QUANTIDADE > 0
          
          ))  CD_DIA_EXATO,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR, MAX(DH_BACKLOG_CIF) DH_BACKLOG_CIF, intec.CD_GRUPO_EMBALAGEM

          FROM CTE_CARTEIRA intec
          INNER JOIN CTE_AGENDAMENTO_FILTER AGED
          ON intec.CD_ELO_AGENDAMENTO = AGED.CD_ELO_AGENDAMENTO
          
          WHERE 
          intec.IC_ATIVO = 'S'
          --and (P_CD_CENTRO_EXPEDIDOR is null or intec.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
          --AND (NVL(intec.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (intec.IC_CORTADO_FABRICA <> 1 OR intec.IC_CORTADO_FABRICA IS NULL))
          GROUP BY 
          intec.CD_ELO_AGENDAMENTO, --intec.CD_ELO_AGENDAMENTO_ITEM, 
          intec.CD_INCOTERMS, 
          intec.CD_SALES_GROUP,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR,
          intec.CD_GRUPO_EMBALAGEM,
          intec.CD_ELO_CARTEIRA, --, intec.CD_TIPO_REPLAN
          intec.CD_ELO_AGENDAMENTO_ITEM,
          intec.CD_TIPO_REPLAN
  
          ) ec   
          
            INNER JOIN CTF.USUARIO u
            on ec.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
            INNER JOIN CTE_AGENDAMENTO_FILTER ag
            on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
            
            left join VND.ELO_STATUS estrp
            on estrp.CD_ELO_STATUS = ec.CD_TIPO_REPLAN
            left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE
            INNER JOIN ELO_AG_DAY_BY_INCOTERMS_ITEM eai
            on ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
            --AND eai.CD_INCOTERMS = 'FOB'
            INNER JOIN ELO_AG_DAY AGDY
            ON eai.CD_ELO_AGENDAMENTO = AGDY.CD_ELO_AGENDAMENTO
            AND eai.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
            AND eai.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
            AND eai.CD_CLIENTE = AGDY.CD_CLIENTE
            AND eai.CD_INCOTERMS = AGDY.CD_INCOTERMS
            --AND AGDY.CD_INCOTERMS = 'FOB'             
           

           )
           GROUP BY 
              CodeAgendamento,
               --CodeCarteira,
               SEMANA,
               CD_STATUS,
               CLASSIFICACAO,
               TIPO_REPLAN,
               BACKLOG,
               CENTRO,
               MAQUINA,
               INCOTERM,
               CD_CLIENTE,
               DS_CLIENTE,
               EMBALAGEM               
               
           ;
           
           
           /*        
          SELECT 
               CodeAgendamento,
               MAX(CodeCarteira) CodeCarteira,
               SEMANA,
               CD_STATUS,
               CLASSIFICACAO,
               TIPO_REPLAN,
               BACKLOG,
               CENTRO,
               MAQUINA,
               INCOTERM,
               CD_CLIENTE,
               DS_CLIENTE,
               MAX(COTA) COTA,
               MAX(SUPERVISOR) SUPERVISOR,
               EMBALAGEM,
               MAX(DIA_EXATO) DIA_EXATO,

               SUM(VALOR) VALOR,
               SUM(SEG) SEG, 
               SUM(TER) TER,
               SUM(QUA) QUA,
               SUM(QUI) QUI,
               SUM(SEX) SEX,
               SUM(SAB) SAB,
               SUM(DOM) DOM

        
        FROM 
        (        
        
        --------------------- this scenario is FOB ---------------------------------
        select  DISTINCT 
               ag.CD_ELO_AGENDAMENTO                                                as CodeAgendamento,
               ec.CD_ELO_CARTEIRA                                                   as CodeCarteira,
               ag.CD_WEEK                                                           as SEMANA,
               ag.CD_ELO_STATUS                                                     as CD_STATUS,
               ag.DS_STATUS                                                         as CLASSIFICACAO,
               TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
               to_char(ec.DH_BACKLOG_CIF)                                           as BACKLOG,
               ec.DS_CENTRO_EXPEDIDOR                                               as CENTRO,
               ma.DS_MACHINE                                                        as MAQUINA,
               ec.CD_INCOTERMS                                                      as INCOTERM,
               ec.CD_CLIENTE                                                        as CD_CLIENTE,
               ec.NO_CLIENTE                                                        as DS_CLIENTE,
               --eai.CD_COTA_COMPARTILHADA                                            as COTA,
               '' AS COTA,
               u.CD_USUARIO || '-' || u.NO_USUARIO                                  as SUPERVISOR,
                 (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE eai.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as EMBALAGEM,
               ' '                                                 as DIA_EXATO,
               --NVL(ec.QT_AGENDADA_CONFIRMADA,0)                                                as VALOR,
               0 VALOR,
               
               
               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 1 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        --AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                        --AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as SEG,

               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 2 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                       -- AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as TER,
                        
               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 3 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        --AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as QUA,

               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 4 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        --AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as QUI,  
                        
               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 5 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        --AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as SEX,

               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 6 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        --AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as SAB, 
                        
               (NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 7 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = eai.CD_CLIENTE
                        --AND FORDAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = eai.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO),0)) as DOM                       
                        
 
         from (
          SELECT MAX(intec.CD_ELO_CARTEIRA) CD_ELO_CARTEIRA , intec.CD_ELO_AGENDAMENTO,  
          intec.CD_INCOTERMS, MAX(intec.CD_TIPO_REPLAN) CD_TIPO_REPLAN,
            intec.CD_SALES_GROUP,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR, MAX(DH_BACKLOG_CIF) DH_BACKLOG_CIF--, intec.CD_GRUPO_EMBALAGEM

          FROM CTE_CARTEIRA intec
          INNER JOIN CTE_AGENDAMENTO_FILTER AGED
          ON intec.CD_ELO_AGENDAMENTO = AGED.CD_ELO_AGENDAMENTO
          
          WHERE 
          intec.IC_ATIVO = 'S'
          AND intec.CD_INCOTERMS = 'FOB'
          --and (P_CD_CENTRO_EXPEDIDOR is null or intec.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
          --AND (NVL(intec.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (intec.IC_CORTADO_FABRICA <> 1 OR intec.IC_CORTADO_FABRICA IS NULL))
          GROUP BY 
          intec.CD_ELO_AGENDAMENTO, --intec.CD_ELO_AGENDAMENTO_ITEM, 
          intec.CD_INCOTERMS, 
          intec.CD_SALES_GROUP,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR--,
          --intec.CD_GRUPO_EMBALAGEM,
          --intec.CD_ELO_CARTEIRA--, 
          
          --intec.CD_TIPO_REPLAN
  
          ) ec   
          
            INNER JOIN CTF.USUARIO u
            on ec.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
            INNER JOIN CTE_AGENDAMENTO_FILTER ag
            on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
            
            left join VND.ELO_STATUS estrp
            on estrp.CD_ELO_STATUS = ec.CD_TIPO_REPLAN
            left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE
            INNER JOIN (
            SELECT 
            CD_ELO_AGENDAMENTO, CD_GRUPO_EMBALAGEM, CD_CLIENTE, CD_INCOTERMS
            FROM ELO_AG_DAY_BY_INCOTERMS_ITEM ADBI
            GROUP BY 
            CD_ELO_AGENDAMENTO, CD_GRUPO_EMBALAGEM,   CD_CLIENTE, CD_INCOTERMS ) eai
            
           -- ELO_AG_DAY_BY_INCOTERMS_ITEM eai
            ON eai.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
            --AND eai.CD_GRUPO_EMBALAGEM = ec.CD_GRUPO_EMBALAGEM
            --AND eai.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
            AND eai.CD_CLIENTE = ec.CD_CLIENTE
            AND eai.CD_INCOTERMS = ec.CD_INCOTERMS
            AND eai.CD_INCOTERMS = 'FOB'  
            
       --------------------- this scenario is CIF ---------------------------------     
         UNION    
           
        select  
               ag.CD_ELO_AGENDAMENTO                                                as CodeAgendamento,
               ec.CD_ELO_CARTEIRA                                                   as CodeCarteira,
               ag.CD_WEEK                                                           as SEMANA,
               ag.CD_ELO_STATUS                                                     as CD_STATUS,
               ag.DS_STATUS                                                         as CLASSIFICACAO,
               TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
               to_char(ec.DH_BACKLOG_CIF)                                           as BACKLOG,
               ec.DS_CENTRO_EXPEDIDOR                                               as CENTRO,
               ma.DS_MACHINE                                                        as MAQUINA,
               ec.CD_INCOTERMS                                                      as INCOTERM,
               ec.CD_CLIENTE                                                        as CD_CLIENTE,
               ec.NO_CLIENTE                                                        as DS_CLIENTE,
               --eai.CD_COTA_COMPARTILHADA                                            as COTA,
               '' AS COTA,
               u.CD_USUARIO || '-' || u.NO_USUARIO                                  as SUPERVISOR,
                 (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as EMBALAGEM,
               (CASE WHEN ec.CD_INCOTERMS = 'CIF' 
                     THEN NVL(ec.CD_DIA_EXATO, ' ') 
                     ELSE ' ' END)                                                  as DIA_EXATO,
               --NVL(ec.QT_AGENDADA_CONFIRMADA,0)                                                as VALOR,
               NVL(
               CASE WHEN ec.CD_INCOTERMS = 'CIF' THEN 
               (SELECT SUM(CC.QT_AGENDADA_CONFIRMADA)  QT_AGENDADA_CONFIRMADA 
               FROM CTE_CARTEIRA CC 
               WHERE ec.CD_ELO_CARTEIRA = CC.CD_ELO_CARTEIRA)
               ELSE 
               0
               END 
             
               ,0) VALOR,
               
               
               0 as SEG,

              0 as TER,
                        
               0 as QUA,

              0 QUI,  
                        
               0 SEX,

              0 SAB, 
                        
               0 as DOM                       
                        
 
         from (
          SELECT intec.CD_ELO_CARTEIRA , intec.CD_ELO_AGENDAMENTO, intec.CD_ELO_AGENDAMENTO_ITEM, 
          intec.CD_INCOTERMS, intec.CD_TIPO_REPLAN,
         
          SUM(intec.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA,
           intec.CD_SALES_GROUP, 
          MAX((SELECT MAX(tf.CD_DIA_EXATO) CD_DIA_EXATO
          FROM VND.ELO_CARTEIRA_TORRE_FRETES tf 
          WHERE intec.CD_ELO_CARTEIRA = tf.CD_ELO_CARTEIRA 
          AND tf.NU_QUANTIDADE > 0
          
          ))  CD_DIA_EXATO,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR, MAX(DH_BACKLOG_CIF) DH_BACKLOG_CIF
          FROM CTE_CARTEIRA intec
          INNER JOIN CTE_AGENDAMENTO_FILTER AGED
          ON intec.CD_ELO_AGENDAMENTO = AGED.CD_ELO_AGENDAMENTO
          
          WHERE 
          intec.IC_ATIVO = 'S'
          AND intec.CD_INCOTERMS = 'CIF'
          --and (P_CD_CENTRO_EXPEDIDOR is null or intec.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
          --AND (NVL(intec.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (intec.IC_CORTADO_FABRICA <> 1 OR intec.IC_CORTADO_FABRICA IS NULL))
          GROUP BY 
          intec.CD_ELO_AGENDAMENTO, --intec.CD_ELO_AGENDAMENTO_ITEM, 
          intec.CD_INCOTERMS, 
          intec.CD_SALES_GROUP,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR,
          
          intec.CD_ELO_CARTEIRA, --, intec.CD_TIPO_REPLAN
          intec.CD_ELO_AGENDAMENTO_ITEM,
          intec.CD_TIPO_REPLAN
  
          ) ec   
          
            INNER JOIN CTF.USUARIO u
            on ec.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
            INNER JOIN CTE_AGENDAMENTO_FILTER ag
            on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
            
            left join VND.ELO_STATUS estrp
            on estrp.CD_ELO_STATUS = ec.CD_TIPO_REPLAN
            left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE
            INNER JOIN ELO_AG_DAY_BY_INCOTERMS_ITEM eai
            on ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
            AND eai.CD_INCOTERMS = 'CIF'
            INNER JOIN ELO_AG_DAY AGDY
            ON eai.CD_ELO_AGENDAMENTO = AGDY.CD_ELO_AGENDAMENTO
            AND eai.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
            AND eai.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
            AND eai.CD_CLIENTE = AGDY.CD_CLIENTE
            AND eai.CD_INCOTERMS = AGDY.CD_INCOTERMS
            AND AGDY.CD_INCOTERMS = 'CIF'             

           )
           GROUP BY 
              CodeAgendamento,
               --CodeCarteira,
               SEMANA,
               CD_STATUS,
               CLASSIFICACAO,
               TIPO_REPLAN,
               BACKLOG,
               CENTRO,
               MAQUINA,
               INCOTERM,
               CD_CLIENTE,
               DS_CLIENTE,
               EMBALAGEM   
               */


    END PX_SEARCH_PLANNING_AAAA;
  
    
    PROCEDURE PX_SEARCH_PLANNING (
        P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MACHINES              IN VARCHAR,
----        P_WEEK                  IN INT,
        P_DT_WEEK_START         IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
        P_RETURN                OUT T_CURSOR)
        
    IS
    BEGIN
        OPEN P_RETURN FOR
        
      
        
        WITH CTE_AGENDAMENTO AS 
        (
        SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_MACHINE, ma.DS_MACHINE, AGE.CD_WEEK , es.DS_STATUS, AGE.CD_ELO_STATUS
        FROM VND.ELO_AGENDAMENTO AGE 
        LEFT JOIN CTF.MACHINE ma
        on AGE.CD_MACHINE = ma.CD_MACHINE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        
        WHERE AGE.IC_ATIVO = 'S'
      
        AND (es.SG_STATUS IN ('PLAN','AGCTR','AGENC'))
       -- AND (P_WEEK is null OR AGE.CD_WEEK = P_WEEK)
        and (P_MACHINES is null OR AGE.CD_MACHINE IN (P_MACHINES))
        and (P_POLO is null or AGE.CD_POLO = P_POLO) 
               and (
              P_DT_WEEK_START is null or 
              (
                  to_number(to_char(to_date(AGE.DT_WEEK_START,'DD/MM/RRRR'),'IW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'IW'))
                  and extract(year from AGE.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
              )
           )
        
        ),
        
        CTE_CARTEIRA AS 
        (
        
        SELECT 
        CTAF.CD_ELO_CARTEIRA , 
        CTAF.CD_ELO_AGENDAMENTO, 
        CTAF.CD_TIPO_AGENDAMENTO, 
        CTAF.CD_TIPO_REPLAN, 
        CTAF.QT_AGENDADA_CONFIRMADA,
        CTAF.CD_ELO_AGENDAMENTO_ITEM,
        CTAF.CD_INCOTERMS,
        CTAF.CD_CLIENTE ,
        CTAF.NO_CLIENTE ,
        CTAF.DH_BACKLOG_CIF,
        NVL((SELECT DS.DS_CENTRO_EXPEDIDOR FROM CTF.CENTRO_EXPEDIDOR DS WHERE DS.CD_CENTRO_EXPEDIDOR = CTAF.CD_CENTRO_EXPEDIDOR_FABRICA), CTAF.DS_CENTRO_EXPEDIDOR) DS_CENTRO_EXPEDIDOR,
        NVL(CTAF.CD_CENTRO_EXPEDIDOR_FABRICA, CTAF.CD_CENTRO_EXPEDIDOR) CD_CENTRO_EXPEDIDOR,
        CTAF.CD_SALES_GROUP,
        CTAF.CD_GRUPO_EMBALAGEM,
        CTAF.IC_ATIVO
        FROM VND.ELO_CARTEIRA CTAF
        INNER JOIN CTE_AGENDAMENTO AGEF
        ON CTAF.CD_ELO_AGENDAMENTO = AGEF.CD_ELO_AGENDAMENTO
        WHERE
        CTAF.IC_ATIVO = 'S'
          and (P_CD_CENTRO_EXPEDIDOR is null or NVL(CTAF.CD_CENTRO_EXPEDIDOR_FABRICA, CTAF.CD_CENTRO_EXPEDIDOR) = P_CD_CENTRO_EXPEDIDOR)
        --  AND (NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (CTAF.IC_CORTADO_FABRICA <> 1 OR CTAF.IC_CORTADO_FABRICA IS NULL))

          AND ((CTAF.QT_AGENDADA_CONFIRMADA > 0 AND CTAF.CD_TIPO_AGENDAMENTO = 25 AND CTAF.CD_STATUS_REPLAN = 32)
          OR (CTAF.CD_TIPO_AGENDAMENTO IN (22, 23, 24) AND NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (CTAF.IC_CORTADO_FABRICA <> 1 OR CTAF.IC_CORTADO_FABRICA IS NULL))
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

        SELECT  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA, 
        SUM(DAYY.NU_QUANTIDADE) NU_QUANTIDADE, EAG_ITEM_I.CD_CLIENTE, EAG_ITEM_I.CD_INCOTERMS
        FROM CTE_AGENDAMENTO_FILTER FILT
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EA_SUP_I  
        ON FILT.CD_ELO_AGENDAMENTO = EA_SUP_I.CD_ELO_AGENDAMENTO
        INNER JOIN VND.VW_ELO_AGENDAMENTO_ITEM_R EAG_ITEM_I
        --INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAG_ITEM_I
        ON 
        EAG_ITEM_I.CD_ELO_AGENDAMENTO_SUPERVISOR = EA_SUP_I.CD_ELO_AGENDAMENTO_SUPERVISOR
        AND EAG_ITEM_I.IC_ATIVO = 'S'	
        
        INNER JOIN VND.ELO_AGENDAMENTO_WEEK EAG_WE_I
        ON EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM = EAG_WE_I.CD_ELO_AGENDAMENTO_ITEM
        
        --LEFT JOIN VND.ELO_AGENDAMENTO_GROUPING EAG_GRO_I
        --ON EAG_GRO_I.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK
        INNER JOIN VND.VW_ELO_AGENDAMENTO_DAY_PLAN DAYY
        ON 
        DAYY.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK
        
        WHERE 
        EA_SUP_I.IC_ATIVO = 'S'
                AND             EXISTS (
                    SELECT 1 FROM CTE_CARTEIRA CTA 
                    WHERE 
                    CTA.CD_ELO_AGENDAMENTO_ITEM = EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM
                    )

                                        
        GROUP BY  EA_SUP_I.CD_ELO_AGENDAMENTO, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA , EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM  , EAG_ITEM_I.CD_CLIENTE,
        EAG_ITEM_I.CD_INCOTERMS
        
        ),
        --SELECT * FROM ELO_AG_DAY_BY_INCOTERMS_ITEM ORDER BY CD_ELO_AGENDAMENTO_ITEM, CD_GRUPO_EMBALAGEM, NU_DIA_SEMANA

        
       ELO_AG_DAY AS (
        SELECT  EADBI.CD_ELO_AGENDAMENTO, EADBI.CD_GRUPO_EMBALAGEM, 
        EADBI.NU_DIA_SEMANA, SUM(EADBI.NU_QUANTIDADE) NU_QUANTIDADE,
        EADBI.CD_INCOTERMS,
        EADBI.CD_CLIENTE
        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM EADBI
        GROUP BY  EADBI.CD_ELO_AGENDAMENTO,  EADBI.CD_GRUPO_EMBALAGEM,  
        EADBI.CD_INCOTERMS, EADBI.CD_CLIENTE                                   
        ) ,     
        
        
CTE_CENARIO_CIF AS 
(

SELECT 
CIFGROUPED.CD_ELO_AGENDAMENTO ,
MAX(CIFGROUPED.CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
CIFGROUPED.CD_WEEK, 
CIFGROUPED.CD_ELO_STATUS,
CIFGROUPED.DS_STATUS, 
CIFGROUPED.TIPO_REPLAN,
CIFGROUPED.DH_BACKLOG_CIF,
CIFGROUPED.DS_CENTRO_EXPEDIDOR,
CIFGROUPED.DS_MACHINE,
CIFGROUPED.CD_INCOTERMS,
CIFGROUPED.CD_CLIENTE,
CIFGROUPED.NO_CLIENTE, 
CIFGROUPED.COTA,
CIFGROUPED.SUPERVISOR,
CIFGROUPED.EMBALAGEM,
CIFGROUPED.DIA_EXATO,
sum(CIFGROUPED.VALOR) VALOR ,
SUM(CIFGROUPED.SEG) SEG,
SUM(CIFGROUPED.TER) TER,
SUM(CIFGROUPED.QUA) QUA,
SUM(CIFGROUPED.QUI) QUI,  
SUM(CIFGROUPED.SEX) SEX,
SUM(CIFGROUPED.SAB) SAB, 
SUM(CIFGROUPED.DOM) DOM  


FROM (


        select  
               ag.CD_ELO_AGENDAMENTO ,
               (select d.CD_ELO_CARTEIRA 
               FROM CTE_CARTEIRA D 
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND ROWNUM =1 ) CD_ELO_CARTEIRA ,
               ag.CD_WEEK ,
               ag.CD_ELO_STATUS ,
               ag.DS_STATUS  ,
               --TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
               (select d.CD_TIPO_REPLAN  || '-' || estrp.DS_STATUS
               FROM CTE_CARTEIRA D 
               INNER JOIN VND.ELO_STATUS estrp
               ON d.CD_TIPO_REPLAN = estrp.CD_ELO_STATUS
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND ROWNUM =1 ) TIPO_REPLAN,
               --to_char(ec.DH_BACKLOG_CIF)  DH_BACKLOG_CIF,
               (select d.DH_BACKLOG_CIF 
               FROM CTE_CARTEIRA D 
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND ROWNUM =1 ) DH_BACKLOG_CIF,
               (select d.CD_CENTRO_EXPEDIDOR || ' - ' || d.DS_CENTRO_EXPEDIDOR 
               FROM CTE_CARTEIRA D 
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND d.DS_CENTRO_EXPEDIDOR is not null
               AND ROWNUM =1 ) DS_CENTRO_EXPEDIDOR ,
               ma.DS_MACHINE ,
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
                 (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDAY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as EMBALAGEM,
               ''     as DIA_EXATO,
               AGDAY.NU_QUANTIDADE 
               /* (SELECT COUNT(1) QT_ITEM_CART FROM CTE_CARTEIRA CCD WHERE CCD.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM) */  as VALOR,
               
                0 SEG,
                0 TER,
                0 QUA,
                0 QUI,  
                0 SEX,
                0 SAB, 
                0 DOM                       
                        
 
            FROM ELO_AG_DAY_BY_INCOTERMS_ITEM AGDAY
            INNER JOIN CTE_AGENDAMENTO_FILTER ag
            ON 
            ag.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO
            left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE

            left JOIN  CTF.CLIENTE CLI
            ON AGDAY.CD_CLIENTE = CLI.CD_CLIENTE

            
            WHERE 
            AGDAY.CD_INCOTERMS = 'CIF'
) CIFGROUPED  
GROUP BY 
CIFGROUPED.CD_ELO_AGENDAMENTO ,--CIFGROUPED.CD_ELO_CARTEIRA,
CIFGROUPED.CD_WEEK, CIFGROUPED.CD_ELO_STATUS,CIFGROUPED.DS_STATUS, 
CIFGROUPED.TIPO_REPLAN,CIFGROUPED.DH_BACKLOG_CIF,CIFGROUPED.DS_CENTRO_EXPEDIDOR,
CIFGROUPED.DS_MACHINE,CIFGROUPED.CD_INCOTERMS,CIFGROUPED.CD_CLIENTE,
CIFGROUPED.NO_CLIENTE, CIFGROUPED.COTA,CIFGROUPED.SUPERVISOR,
CIFGROUPED.EMBALAGEM,CIFGROUPED.DIA_EXATO     
            
  
),
--select * from CTE_CENARIO_CIF

CTE_CENARIO_FOB AS 
(
SELECT 
CIFGROUPED.CD_ELO_AGENDAMENTO ,
MAX(CIFGROUPED.CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
CIFGROUPED.CD_WEEK, 
CIFGROUPED.CD_ELO_STATUS,
CIFGROUPED.DS_STATUS, 
CIFGROUPED.TIPO_REPLAN,
CIFGROUPED.DH_BACKLOG_CIF,
CIFGROUPED.DS_CENTRO_EXPEDIDOR,
CIFGROUPED.DS_MACHINE,
CIFGROUPED.CD_INCOTERMS,
CIFGROUPED.CD_CLIENTE,
CIFGROUPED.NO_CLIENTE, 
CIFGROUPED.COTA,
CIFGROUPED.SUPERVISOR,
CIFGROUPED.EMBALAGEM,
CIFGROUPED.DIA_EXATO,
SUM(CIFGROUPED.VALOR) VALOR ,
SUM(CIFGROUPED.SEG) SEG,
SUM(CIFGROUPED.TER) TER,
SUM(CIFGROUPED.QUA) QUA,
SUM(CIFGROUPED.QUI) QUI,  
SUM(CIFGROUPED.SEX) SEX,
SUM(CIFGROUPED.SAB) SAB, 
SUM(CIFGROUPED.DOM) DOM  

FROM (
    
     
        select  
               ag.CD_ELO_AGENDAMENTO ,
               (select d.CD_ELO_CARTEIRA 
               FROM CTE_CARTEIRA D 
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND ROWNUM =1 ) CD_ELO_CARTEIRA ,
               ag.CD_WEEK ,
               ag.CD_ELO_STATUS ,
               ag.DS_STATUS  ,
               --TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
               (select d.CD_TIPO_REPLAN  || '-' || estrp.DS_STATUS
               FROM CTE_CARTEIRA D 
               INNER JOIN VND.ELO_STATUS estrp
               ON d.CD_TIPO_REPLAN = estrp.CD_ELO_STATUS
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND ROWNUM =1 ) TIPO_REPLAN,
               --to_char(ec.DH_BACKLOG_CIF)  DH_BACKLOG_CIF,
               (select d.DH_BACKLOG_CIF 
               FROM CTE_CARTEIRA D 
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND ROWNUM =1 ) DH_BACKLOG_CIF,
               (select d.CD_CENTRO_EXPEDIDOR || ' - ' || d.DS_CENTRO_EXPEDIDOR 
               FROM CTE_CARTEIRA D 
               where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
               AND d.DS_CENTRO_EXPEDIDOR is not null
               AND ROWNUM =1 ) DS_CENTRO_EXPEDIDOR ,
               ma.DS_MACHINE ,
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
                 (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDAY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as EMBALAGEM,
               ''     as DIA_EXATO,
            to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0))   as VALOR,
               
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 1 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as SEG,

               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 2 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as TER,
                        
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 3 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as QUA,

               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 4 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as QUI,  
                        
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 5 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as SEX,

               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 6 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as SAB, 
                        
               to_char(NVL((SELECT SUM(FORDAY.NU_QUANTIDADE) NU_QUANTIDADE  
                        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM FORDAY 
                        WHERE  
                        FORDAY.NU_DIA_SEMANA = 7 AND FORDAY.CD_INCOTERMS = 'FOB'
                        AND FORDAY.CD_CLIENTE = AGDAY.CD_CLIENTE
                        AND FORDAY.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
                        AND FORDAY.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
                        AND FORDAY.CD_INCOTERMS = AGDAY.CD_INCOTERMS
                        AND FORDAY.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM
                        AND FORDAY.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO),0)) as DOM                       
                     
                        
 
            FROM ELO_AG_DAY_BY_INCOTERMS_ITEM AGDAY
            INNER JOIN CTE_AGENDAMENTO_FILTER ag
            ON 
            ag.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO
            left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE

            left JOIN  CTF.CLIENTE CLI
            ON AGDAY.CD_CLIENTE = CLI.CD_CLIENTE

            
            WHERE 
            AGDAY.CD_INCOTERMS = 'FOB'
) CIFGROUPED  
GROUP BY 
CIFGROUPED.CD_ELO_AGENDAMENTO ,--CIFGROUPED.CD_ELO_CARTEIRA,
CIFGROUPED.CD_WEEK, CIFGROUPED.CD_ELO_STATUS,CIFGROUPED.DS_STATUS, 
CIFGROUPED.TIPO_REPLAN,CIFGROUPED.DH_BACKLOG_CIF,CIFGROUPED.DS_CENTRO_EXPEDIDOR,
CIFGROUPED.DS_MACHINE,CIFGROUPED.CD_INCOTERMS,CIFGROUPED.CD_CLIENTE,
CIFGROUPED.NO_CLIENTE, CIFGROUPED.COTA,CIFGROUPED.SUPERVISOR,
CIFGROUPED.EMBALAGEM,CIFGROUPED.DIA_EXATO              
 
)


    --------------------------------- CIF -----------------------------------------

    SELECT 
    CTCIF.CD_ELO_AGENDAMENTO CodeAgendamento,
    MAX(CTCIF.CD_ELO_CARTEIRA) CodeCarteira,
    CTCIF.CD_WEEK SEMANA,
    CTCIF.CD_ELO_STATUS CD_STATUS,
    CTCIF.DS_STATUS CLASSIFICACAO,
    CTCIF.TIPO_REPLAN TIPO_REPLAN,
    CTCIF.DH_BACKLOG_CIF BACKLOG,
    CTCIF.DS_CENTRO_EXPEDIDOR CENTRO,
    CTCIF.DS_MACHINE MAQUINA,
    CTCIF.CD_INCOTERMS INCOTERM,
    CTCIF.CD_CLIENTE CD_CLIENTE,
    CTCIF.NO_CLIENTE DS_CLIENTE,
    MAX(CTCIF.COTA) COTA,
    MAX(CTCIF.SUPERVISOR) SUPERVISOR,
    CTCIF.EMBALAGEM,
    MAX(CTCIF.DIA_EXATO) DIA_EXATO,
    
    ROUND(SUM(CTCIF.VALOR),0) VALOR,
    SUM(CTCIF.SEG) SEG, 
    SUM(CTCIF.TER) TER,
    SUM(CTCIF.QUA) QUA,
    SUM(CTCIF.QUI) QUI,
    SUM(CTCIF.SEX) SEX,
    SUM(CTCIF.SAB) SAB,
    SUM(CTCIF.DOM) DOM
    FROM CTE_CENARIO_CIF CTCIF
    WHERE DS_CENTRO_EXPEDIDOR IS NOT NULL
    GROUP BY
    
    CTCIF.CD_ELO_AGENDAMENTO ,
    CTCIF.CD_WEEK ,
    CTCIF.CD_ELO_STATUS ,
    CTCIF.DS_STATUS ,
    CTCIF.TIPO_REPLAN ,
    CTCIF.DH_BACKLOG_CIF ,
    CTCIF.DS_CENTRO_EXPEDIDOR ,
    CTCIF.DS_MACHINE ,
    CTCIF.CD_INCOTERMS ,
    CTCIF.CD_CLIENTE ,
    CTCIF.NO_CLIENTE ,
    CTCIF.EMBALAGEM
    --------------------------------- CIF -----------------------------------------
    UNION 
    --------------------------------- FOB -----------------------------------------
    SELECT 
    CTCIF.CD_ELO_AGENDAMENTO CodeAgendamento,
    MAX(CTCIF.CD_ELO_CARTEIRA) CodeCarteira,
    CTCIF.CD_WEEK SEMANA,
    CTCIF.CD_ELO_STATUS CD_STATUS,
    CTCIF.DS_STATUS CLASSIFICACAO,
    CTCIF.TIPO_REPLAN TIPO_REPLAN,
    CTCIF.DH_BACKLOG_CIF BACKLOG,
    CTCIF.DS_CENTRO_EXPEDIDOR CENTRO,
    CTCIF.DS_MACHINE MAQUINA,
    CTCIF.CD_INCOTERMS INCOTERM,
    CTCIF.CD_CLIENTE CD_CLIENTE,
    CTCIF.NO_CLIENTE DS_CLIENTE,
    MAX(CTCIF.COTA) COTA,
    MAX(CTCIF.SUPERVISOR) SUPERVISOR,
    CTCIF.EMBALAGEM,
    MAX(CTCIF.DIA_EXATO) DIA_EXATO,
    
    ROUND(SUM(CTCIF.VALOR),0) VALOR,
    SUM(CTCIF.SEG) SEG, 
    SUM(CTCIF.TER) TER,
    SUM(CTCIF.QUA) QUA,
    SUM(CTCIF.QUI) QUI,
    SUM(CTCIF.SEX) SEX,
    SUM(CTCIF.SAB) SAB,
    SUM(CTCIF.DOM) DOM
    FROM CTE_CENARIO_FOB CTCIF
    WHERE DS_CENTRO_EXPEDIDOR IS NOT NULL
    GROUP BY
    
    CTCIF.CD_ELO_AGENDAMENTO ,
    CTCIF.CD_WEEK ,
    CTCIF.CD_ELO_STATUS ,
    CTCIF.DS_STATUS ,
    CTCIF.TIPO_REPLAN ,
    CTCIF.DH_BACKLOG_CIF ,
    CTCIF.DS_CENTRO_EXPEDIDOR ,
    CTCIF.DS_MACHINE ,
    CTCIF.CD_INCOTERMS ,
    CTCIF.CD_CLIENTE ,
    CTCIF.NO_CLIENTE ,
    CTCIF.EMBALAGEM    
        
        
        
        
               
           ;

    END PX_SEARCH_PLANNING;
  
     
    --TODO: Corrigir
    PROCEDURE PU_UPDATE_STATUS_PLANNING (
        P_POLO                  IN VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MACHINES              IN VARCHAR,
----        P_WEEK                  IN INT,
        P_DT_WEEK_START         IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
        P_STATUS                IN VARCHAR2,
        P_RETURN                OUT T_CURSOR)
        
    IS
    
        V_CD_ELO_STATUS    NUMBER(9);
        V_TRAVA VARCHAR2(1):='N';
        V_CD_ELO_AGENDAMENTO VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE;
    
    BEGIN
        
        BEGIN
        select es.CD_ELO_STATUS
          into V_CD_ELO_STATUS
          from VND.ELO_STATUS es
         where es.SG_STATUS = P_STATUS;
         EXCEPTION 
         WHEN NO_DATA_FOUND THEN
         BEGIN 
            V_CD_ELO_STATUS:= 9;
           RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - 003' || SQLCODE || ' -ERROR- ' || SQLERRM);
           END;
         WHEN OTHERS THEN 
         BEGIN
         V_CD_ELO_STATUS:= 9;
         RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - 004' || SQLCODE || ' -ERROR- ' || SQLERRM);
         END;
         END;
         
        BEGIN 
        
        
        
        SELECT AGE.CD_ELO_AGENDAMENTO 
        INTO V_CD_ELO_AGENDAMENTO -- , AGE.CD_ELO_STATUS, AGE.CD_POLO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_MACHINE
        FROM VND.ELO_AGENDAMENTO AGE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = age.CD_ELO_STATUS
        where 
        es.SG_STATUS IN ('PLAN','AGCTR','AGENC')        
        AND AGE.IC_ATIVO = 'S'
        and (P_POLO is null or AGE.CD_POLO = P_POLO)
        and (P_MACHINES is null or AGE.CD_MACHINE IN (P_MACHINES))
        and (P_CD_CENTRO_EXPEDIDOR is null or AGE.CD_CENTRO_EXPEDIDOR IN (P_CD_CENTRO_EXPEDIDOR))
        and (
         P_DT_WEEK_START is null or 
         (
             to_number(to_char(to_date(AGE.DT_WEEK_START,'DD/MM/RRRR'),'IW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'IW'))
             and extract(year from AGE.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
         )
        )        
        
        

        ;
         EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
         BEGIN
         V_CD_ELO_AGENDAMENTO:= NULL;
         RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - 005' || SQLCODE || ' -ERROR- ' || SQLERRM);
         END;
         WHEN OTHERS THEN 
         BEGIN
         V_CD_ELO_AGENDAMENTO:= NULL;
         RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - 006' || SQLCODE || ' -ERROR- ' || SQLERRM);
        END;
         END;
        
        BEGIN
        update VND.ELO_AGENDAMENTO AGE  --GX_ELO_CONTROLLER_SHIP.PU_UPDATE_STATUS_PLANNING
           set AGE.CD_ELO_STATUS = V_CD_ELO_STATUS
         where 
         AGE.CD_ELO_STATUS < V_CD_ELO_STATUS --ADD TO CHECK IF CURRENT STATUS IS ABOVE V_CD_ELO_STATUS ADRIANO 2018-04-17
         and AGE.CD_ELO_AGENDAMENTO = V_CD_ELO_AGENDAMENTO;
        COMMIT;
        
        EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
         BEGIN
         V_CD_ELO_AGENDAMENTO:= NULL;
         RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - 007' || SQLCODE || ' -ERROR- ' || SQLERRM);
         END;
         
         WHEN OTHERS THEN 
         BEGIN
         V_CD_ELO_AGENDAMENTO:= NULL;
         RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - 008' || SQLCODE || ' -ERROR- ' || SQLERRM);
         END;
        
        
        END;
                                          
        OPEN P_RETURN FOR
            select CASE WHEN V_CD_ELO_AGENDAMENTO IS NULL THEN 0 ELSE 1 END as CodeAgendamento from dual;
        
    EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO: PU_UPDATE_STATUS_PLANNING - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            ROLLBACK;
        END;
    
    END PU_UPDATE_STATUS_PLANNING;
    
    PROCEDURE PX_SEARCH_CUSTOMER (
        P_NO_CLIENTE            IN VND.ELO_CARTEIRA.NO_CLIENTE%TYPE,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    
    BEGIN
    
        OPEN P_RETURN FOR
            select DISTINCT ec.CD_CLIENTE        as CodeCustomer
              from VND.ELO_CARTEIRA ec
              
             where 
             ec.IC_ATIVO = 'S'
             AND UPPER(TRIM(ec.NO_CLIENTE)) = UPPER(TRIM(P_NO_CLIENTE));
    
    END PX_SEARCH_CUSTOMER;
    
    PROCEDURE PX_SEARCH_MARK (
        P_CD_CENTRO_EXPEDIDOR   IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_MACHINES              IN VARCHAR2,
--        P_WEEK                  IN INT,
        P_DT_WEEK_START         IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    BEGIN
        OPEN P_RETURN FOR
    
        select distinct
               ce.CD_CENTRO_EXPEDIDOR,
               ce.DS_CENTRO_EXPEDIDOR                                           as CENTRO,
               ce.DS_COLOR                                                      as COR,
               to_number(to_char(ac.DT_WEEK_START,'IW'))  as SEMANA,
               ac.TS_HORARIO_CORTE_CONFERENCIA                                  as CORTE_INICIO,
               ac.TS_HORARIO_CORTE_FINAL                                        as CORTE_FINAL,
               ac.QT_FILA_MINIMA
          from VND.ELO_AGENDAMENTO ag
         inner join VND.ELO_CARTEIRA ec
            on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
         left join VND.ELO_AGENDAMENTO_CENTRO ac
            on ac.CD_CENTRO_EXPEDIDOR = ec.CD_CENTRO_EXPEDIDOR
         inner join CTF.CENTRO_EXPEDIDOR ce
            on ac.CD_CENTRO_EXPEDIDOR = ce.CD_CENTRO_EXPEDIDOR
         inner join VND.ELO_STATUS es
            on es.CD_ELO_STATUS = ag.CD_ELO_STATUS
         where ac.IC_ATIVO = 'S'
           and es.SG_STATUS IN ('AGCTR')        
           and (P_CD_CENTRO_EXPEDIDOR is null or ce.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
--           and to_number(to_char(to_date(ac.DT_WEEK_START,'DD/MM/YYYY'),'WW')) = P_WEEK
           and to_number(to_char(to_date(ac.DT_WEEK_START,'DD/MM/RRRR'),'IW')) = to_number(to_char(to_date(P_DT_WEEK_START,'DD/MM/RRRR'),'IW'))
           and extract(year from ac.DT_WEEK_START) = extract(year from to_date(P_DT_WEEK_START,'DD/MM/RRRR'))
           and (P_MACHINES is null OR ac.CD_MACHINE IN (select regexp_substr(P_MACHINES,'[^,]+', 1, level) from dual
                                                    connect by regexp_substr(P_MACHINES, '[^,]+', 1, level) is not null ));
    
    END PX_SEARCH_MARK;
 

   PROCEDURE PX_SEARCH_NEWENTRY (
        P_CD_CENTRO             IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_WEEK                  IN VARCHAR2,
        P_NO_CLIENTE            IN VND.ELO_CARTEIRA.NO_CLIENTE%TYPE,
        P_MACHINES              IN VARCHAR2,
        P_INCOTERM              IN VND.ELO_CARTEIRA.CD_INCOTERMS%TYPE,
        P_PACKAGE               IN VND.GRUPO_EMBALAGEM.CD_GRUPO_EMBALAGEM%TYPE,
        P_VOLUME                IN NUMBER,
        P_WEEKDAYS              IN VARCHAR2,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    
    V_POLO      CTF.POLO.CD_POLO%TYPE;
    
    BEGIN
    
        IF P_CD_CENTRO IS NOT NULL THEN
            BEGIN
            select pc.CD_POLO
              into V_POLO
              from CTF.POLO_CENTRO_EXPEDIDOR pc
             where pc.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO;
             EXCEPTION 
             WHEN NO_DATA_FOUND THEN 
             V_POLO:=NULL;
             
             WHEN OTHERS THEN 
             V_POLO:=NULL;
             END;
        END IF;
    

    
        OPEN P_RETURN FOR
        
        
        
        WITH CTE_AGENDAMENTO AS 
        (
        SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, 
        AGE.CD_MACHINE, ma.DS_MACHINE, AGE.CD_WEEK ,
        es.DS_STATUS, AGE.CD_ELO_STATUS
        FROM VND.ELO_AGENDAMENTO AGE 
        LEFT JOIN CTF.MACHINE ma
        on AGE.CD_MACHINE = ma.CD_MACHINE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        
        WHERE AGE.IC_ATIVO = 'S'
        AND (es.SG_STATUS IN ('PLAN','AGCTR','AGENC'))
        AND (P_WEEK is null OR AGE.CD_WEEK = P_WEEK)
        --AND ('W182018' is null OR AGE.CD_WEEK = 'W182018')
        and (P_MACHINES is null OR AGE.CD_MACHINE IN (P_MACHINES))
        
        ),
        --SELECT * FROM CTE_AGENDAMENTO
        
    CTE_CARTEIRA AS 
        (
        
        SELECT DISTINCT 
        CTAF.CD_ELO_CARTEIRA , 
        CTAF.CD_ELO_AGENDAMENTO, 
        CTAF.CD_TIPO_AGENDAMENTO, 
        CTAF.CD_TIPO_REPLAN, 
        CTAF.QT_AGENDADA_CONFIRMADA,
        CTAF.CD_ELO_AGENDAMENTO_ITEM,
        CTAF.CD_INCOTERMS,
        CTAF.CD_CLIENTE ,
        CTAF.NO_CLIENTE ,
        CTAF.DH_BACKLOG_CIF,
        NVL((SELECT DS.DS_CENTRO_EXPEDIDOR 
        FROM CTF.CENTRO_EXPEDIDOR DS 
        WHERE DS.CD_CENTRO_EXPEDIDOR = CTAF.CD_CENTRO_EXPEDIDOR_FABRICA), CTAF.DS_CENTRO_EXPEDIDOR) DS_CENTRO_EXPEDIDOR,
        NVL(CTAF.CD_CENTRO_EXPEDIDOR_FABRICA, CTAF.CD_CENTRO_EXPEDIDOR) CD_CENTRO_EXPEDIDOR,

        CTAF.CD_SALES_GROUP,
        CTAF.CD_GRUPO_EMBALAGEM,
        CTAF.IC_ATIVO,
        CTAF.QT_SALDO
        FROM VND.ELO_CARTEIRA CTAF
        INNER JOIN CTE_AGENDAMENTO AGEF
        ON CTAF.CD_ELO_AGENDAMENTO = AGEF.CD_ELO_AGENDAMENTO
        WHERE
        CTAF.IC_ATIVO = 'S'
        --and (P_CD_CENTRO is null or CTAF.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO)
        AND (P_CD_CENTRO is null OR  EXISTS (SELECT 1 FROM CTF.POLO_CENTRO_EXPEDIDOR pc 
        WHERE pc.CD_CENTRO_EXPEDIDOR = NVL(CTAF.CD_CENTRO_EXPEDIDOR_FABRICA,CTAF.CD_CENTRO_EXPEDIDOR )
        AND pc.CD_POLO = V_POLO )) 
        --and ('6060' is null or CTAF.CD_CENTRO_EXPEDIDOR = '6060')
        --AND (NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (CTAF.IC_CORTADO_FABRICA <> 1 OR CTAF.IC_CORTADO_FABRICA IS NULL))
        
        AND ((CTAF.QT_AGENDADA_CONFIRMADA > 0 AND CTAF.CD_TIPO_AGENDAMENTO = 25 AND CTAF.CD_STATUS_REPLAN = 32)
          OR (CTAF.CD_TIPO_AGENDAMENTO IN (22, 23, 24) AND NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (CTAF.IC_CORTADO_FABRICA <> 1 OR CTAF.IC_CORTADO_FABRICA IS NULL))
          )
        
        and (P_NO_CLIENTE is null OR UPPER(CTAF.NO_CLIENTE) = UPPER(P_NO_CLIENTE))
        and ((P_INCOTERM IS NULL ) OR (P_INCOTERM = CTAF.CD_INCOTERMS ))
        --and (P_PACKAGE is null OR CTAF.CD_GRUPO_EMBALAGEM = P_PACKAGE)          
          
        
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
        SELECT  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, EAG_ITEM_I.CD_INCOTERMS, 
        DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA, SUM(DAYY.NU_QUANTIDADE) NU_QUANTIDADE, 
        MAX(CD_COTA_COMPARTILHADA) CD_COTA_COMPARTILHADA, EAG_ITEM_I.CD_CLIENTE
        FROM CTE_AGENDAMENTO_FILTER FILT
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EA_SUP_I  
        ON FILT.CD_ELO_AGENDAMENTO = EA_SUP_I.CD_ELO_AGENDAMENTO
        INNER JOIN VND.VW_ELO_AGENDAMENTO_ITEM_R EAG_ITEM_I
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
        --and ((NVL('G', '0') ='0') OR (DAYY.CD_GRUPO_EMBALAGEM = 'G'))   
        and ((NVL(P_PACKAGE, '0') = '0') OR (DAYY.CD_GRUPO_EMBALAGEM = P_PACKAGE))   
        AND             EXISTS (
                    SELECT 1 FROM CTE_CARTEIRA CTA 
                    WHERE 
                    CTA.CD_ELO_AGENDAMENTO_ITEM = EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM
                    )
                                        
        GROUP BY  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, 
        EAG_ITEM_I.CD_INCOTERMS, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA , EAG_ITEM_I.CD_CLIENTE                                   
        )   ,
        --SELECT * FROM ELO_AG_DAY_BY_INCOTERMS_ITEM

       ELO_AG_DAY AS (
        SELECT  EADBI.CD_ELO_AGENDAMENTO, EADBI.CD_GRUPO_EMBALAGEM, 
        EADBI.NU_DIA_SEMANA, SUM(EADBI.NU_QUANTIDADE) NU_QUANTIDADE,
        EADBI.CD_INCOTERMS,
        EADBI.CD_CLIENTE
        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM EADBI
        GROUP BY  EADBI.CD_ELO_AGENDAMENTO,  EADBI.CD_GRUPO_EMBALAGEM, EADBI.NU_DIA_SEMANA , 
        EADBI.CD_INCOTERMS, EADBI.CD_CLIENTE                                   
        ) ,  
        --SELECT * FROM ELO_AG_DAY
        CTE_EMB_INCOTERMS_DIA AS 
        (
        SELECT 
        EEID.CD_INCOTERMS,
        EEID.CD_GRUPO_EMBALAGEM,
        EEID.NU_DIA_SEMANA
        FROM ELO_EMBALAGEM_INCOTERMS EEID
        WHERE 
        (EEID.NU_DIA_SEMANA IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                connect by regexp_substr(P_WEEKDAYS, '[^,]+', 1, level) is not null )
                                         OR P_WEEKDAYS IS NULL)
        and ((NVL(P_PACKAGE, '0') = '0') OR (EEID.CD_GRUPO_EMBALAGEM = P_PACKAGE))                                 
                                         
        ),
        --SELECT * FROM CTE_EMB_INCOTERMS_DIA
        
       
CTE_CENARIO_CIF_FOB AS 
(
    select  
    ag.CD_ELO_AGENDAMENTO ,
    (select d.CD_ELO_CARTEIRA 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 ) CD_ELO_CARTEIRA ,
    ag.CD_WEEK ,
    ag.CD_ELO_STATUS ,
    ag.DS_STATUS  ,
    --TO_CHAR(ec.CD_TIPO_REPLAN) || '-' || estrp.DS_STATUS                 as TIPO_REPLAN,
    (select d.CD_TIPO_REPLAN  || '-' || estrp.DS_STATUS
    FROM CTE_CARTEIRA D 
    INNER JOIN VND.ELO_STATUS estrp
    ON d.CD_TIPO_REPLAN = estrp.CD_ELO_STATUS
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 ) TIPO_REPLAN,
    --------------------- ADD ADRIANO -- 2018-05-04
        (select CASE WHEN NVL(d.CD_TIPO_AGENDAMENTO,22) IN (22, 23, 24) THEN 22 ELSE d.CD_TIPO_AGENDAMENTO END 
    FROM CTE_CARTEIRA D 
    where d.CD_ELO_AGENDAMENTO_ITEM = AGDAY.CD_ELO_AGENDAMENTO_ITEM 
    AND ROWNUM =1 ) CD_TIPO_AGENDAMENTO,
    --------------------- ADD ADRIANO -- 2018-05-04    
    
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
    (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDAY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM ) as EMBALAGEM,
    ''     as DIA_EXATO,
    AGDAY.NU_QUANTIDADE   as VALOR,
    AGDAY.CD_ELO_AGENDAMENTO_ITEM,
    AGDAY.CD_COTA_COMPARTILHADA,
    AGDAY.NU_DIA_SEMANA,
    AGDAY.CD_GRUPO_EMBALAGEM
    
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM AGDAY
    INNER JOIN CTE_AGENDAMENTO_FILTER ag
    ON 
    ag.CD_ELO_AGENDAMENTO = AGDAY.CD_ELO_AGENDAMENTO
    left join CTF.MACHINE ma
    on ag.CD_MACHINE = ma.CD_MACHINE
    
    left JOIN  CTF.CLIENTE CLI
    ON AGDAY.CD_CLIENTE = CLI.CD_CLIENTE
    INNER JOIN CTE_EMB_INCOTERMS_DIA FILTRO_DIA
    ON 
    FILTRO_DIA.CD_INCOTERMS = AGDAY.CD_INCOTERMS
    AND FILTRO_DIA.CD_GRUPO_EMBALAGEM = AGDAY.CD_GRUPO_EMBALAGEM
    AND FILTRO_DIA.NU_DIA_SEMANA = AGDAY.NU_DIA_SEMANA
    
    WHERE 
    AGDAY.CD_INCOTERMS IN( 'CIF', 'FOB')
    AND FILTRO_DIA.CD_INCOTERMS IN( 'CIF', 'FOB')
   
  
),
--SELECT * FROM CTE_CENARIO_CIF_FOB

CTE_FOB AS 
(
    select --distinct 
    eai.CD_ELO_CARTEIRA  ,
    eai.CD_CENTRO_EXPEDIDOR ,
    eai.DS_CENTRO_EXPEDIDOR,
    eai.CD_CLIENTE ,
    eai.NO_CLIENTE  ,
    eai.CD_MACHINE ,
    eai.DS_MACHINE  ,
    eai.CD_INCOTERMS,
    eai.EMBALAGEM ,
    eai.CD_COTA_COMPARTILHADA,
    -----------------------------------------------------------------                        
    NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'FOB'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    
    ),0) QT_AGENDADA_CONF_OU_BYDAY ,
    -----------------------------------------------------------------
    greatest(NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'FOB'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    
    ),0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN CTE_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'FOB'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0),0) QT_AGENDADA_CORTE , 

    --------------------------------------------------------                          
    
    NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN CTE_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA  --CONSIDERAR SOMENTE FOB AQUELE CLIENTE
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'FOB'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)  SOMA_MARCACAO,
    --------------------------------------------------------
    999999999  SOMA_MARCACAO_SEMANA,

    --NVL(0,0) P_VOLUMED, 
    NVL(P_VOLUME,0) P_VOLUMED, 

    0   as SaldoReplanejado,
     
    NVL(eai.CD_COTA_COMPARTILHADA, 0)   as CompartCota,
    NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    and DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_INCOTERMS = 'FOB'
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
    
    ),0) VOLUME_MAXIMO_FOB , 
    eai.NU_DIA_SEMANA,
    eai.CD_TIPO_AGENDAMENTO

    FROM CTE_CENARIO_CIF_FOB eai
    WHERE eai.CD_INCOTERMS = 'FOB'
    AND eai.CD_TIPO_AGENDAMENTO = 22 
UNION

    select --distinct 
    eai.CD_ELO_CARTEIRA  ,
    eai.CD_CENTRO_EXPEDIDOR ,
    eai.DS_CENTRO_EXPEDIDOR,
    eai.CD_CLIENTE ,
    eai.NO_CLIENTE  ,
    eai.CD_MACHINE ,
    eai.DS_MACHINE  ,
    eai.CD_INCOTERMS,
    eai.EMBALAGEM ,
    eai.CD_COTA_COMPARTILHADA,
    -----------------------------------------------------------------                        
    NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'FOB'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    
    ),0) QT_AGENDADA_CONF_OU_BYDAY ,
    -----------------------------------------------------------------
    greatest(NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'FOB'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    
    ),0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN CTE_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'FOB'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0),0) QT_AGENDADA_CORTE , 

    --------------------------------------------------------                          
    
    NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN CTE_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA  --CONSIDERAR SOMENTE FOB AQUELE CLIENTE
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'FOB'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0)  SOMA_MARCACAO,
    --------------------------------------------------------
    999999999  SOMA_MARCACAO_SEMANA,

    --NVL(0,0) P_VOLUMED, 
    NVL(P_VOLUME,0) P_VOLUMED, 

    0   as SaldoReplanejado,
     
    NVL(eai.CD_COTA_COMPARTILHADA, 0)   as CompartCota,
    NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    and DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_INCOTERMS = 'FOB'
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
    
    ),0) VOLUME_MAXIMO_FOB , 
    eai.NU_DIA_SEMANA,
    eai.CD_TIPO_AGENDAMENTO

    FROM CTE_CENARIO_CIF_FOB eai
    WHERE eai.CD_INCOTERMS = 'FOB'
    AND eai.CD_TIPO_AGENDAMENTO = 25 

),

--SELECT * FROM CTE_FOB

CTE_CIF AS 
(
    select --distinct 
    eai.CD_ELO_CARTEIRA  ,
    eai.CD_CENTRO_EXPEDIDOR ,
    eai.DS_CENTRO_EXPEDIDOR,
    eai.CD_CLIENTE ,
    eai.NO_CLIENTE  ,
    eai.CD_MACHINE ,
    eai.DS_MACHINE  ,
    eai.CD_INCOTERMS,
    eai.EMBALAGEM ,
    eai.CD_COTA_COMPARTILHADA,
    -----------------------------------------------------------------                        
    NVL(
    NVL(((
    SELECT SUM(AGEMAT.NU_QUANTIDADE)  NU_QUANTIDADE 
     
    FROM ELO_CONTROLLERSHIP_MATINAL AGEMAT
    WHERE AGEMAT.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    --and AGEMAT.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND eai.CD_INCOTERMS = 'CIF'
    and AGEMAT.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    --AND AGEMAT.CD_INCOTERMS = eai.CD_INCOTERMS
    AND AGEMAT.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND AGEMAT.CD_CENTRO_EXPEDIDOR = eai.CD_CENTRO_EXPEDIDOR
    --AND AGEMAT.CD_CLIENTE = eai.CD_CLIENTE
    ) / (SELECT COUNT(1) TOTAL 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY 
    WHERE 
    eai.CD_INCOTERMS = DD_DAY.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    --AND DD_DAY.CD_CENTRO_EXPEDIDOR = eai.CD_CENTRO_EXPEDIDOR
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    AND DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND eai.CD_INCOTERMS = 'CIF'
    
    )
    
    
    )
    
    ,
    ( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    --AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    )
    )
    ,0) QT_AGENDADA_CONF_OU_BYDAY ,
    -----------------------------------------------------------------
    GREATEST(NVL(
    CASE 
    WHEN P_WEEKDAYS IS NULL THEN 
    (SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA 
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE)
    ELSE
    (SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    --and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA 
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    )
    END
    
    ,0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN VND.ELO_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE   --PWEE DAY IS NOT NULL
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    --AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    AND ec.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    
     AND EXISTS (SELECT 1 
                    FROM VND.ELO_EMBALAGEM_INCOTERMS FIL_DIA  --CHOOSE ALL DAYUS ANY WA
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'CIF'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0),0) QT_AGENDADA_CORTE , 


    --------------------------------------------------------                          
    
    NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN VND.ELO_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    --AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    AND ec.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA  --TODOS OS DIAS 
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'CIF'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)  SOMA_MARCACAO,
    --------------------------------------------------------
    
    NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN VND.ELO_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    --AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    --AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND ec.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM ELO_EMBALAGEM_INCOTERMS FIL_DIA  --TODOS OS DIAS 
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'CIF'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)  SOMA_MARCACAO_SEMANA,
        --------------------------------------------------------                          
    
    

    --NVL(0,0) P_VOLUMED, 
    NVL(P_VOLUME,0) P_VOLUMED, 

    0  as SaldoReplanejado,
     
    NVL(eai.CD_COTA_COMPARTILHADA, 0)   as CompartCota,
    NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    and DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
    
    ),0) VOLUME_MAXIMO_FOB   , 
    eai.NU_DIA_SEMANA,
    eai.CD_TIPO_AGENDAMENTO
    

    FROM CTE_CENARIO_CIF_FOB eai
    WHERE eai.CD_INCOTERMS = 'CIF'
    AND eai.CD_TIPO_AGENDAMENTO = 22
    
    UNION
    select --distinct 
    eai.CD_ELO_CARTEIRA  ,
    eai.CD_CENTRO_EXPEDIDOR ,
    eai.DS_CENTRO_EXPEDIDOR,
    eai.CD_CLIENTE ,
    eai.NO_CLIENTE  ,
    eai.CD_MACHINE ,
    eai.DS_MACHINE  ,
    eai.CD_INCOTERMS,
    eai.EMBALAGEM ,
    eai.CD_COTA_COMPARTILHADA,
    -----------------------------------------------------------------                        
    NVL(
    NVL(((
    SELECT SUM(AGEMAT.NU_QUANTIDADE)  NU_QUANTIDADE 
     
    FROM ELO_CONTROLLERSHIP_MATINAL AGEMAT
    WHERE AGEMAT.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    --and AGEMAT.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND eai.CD_INCOTERMS = 'CIF'
    and AGEMAT.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    --AND AGEMAT.CD_INCOTERMS = eai.CD_INCOTERMS
    AND AGEMAT.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND AGEMAT.CD_CENTRO_EXPEDIDOR = eai.CD_CENTRO_EXPEDIDOR
    --AND AGEMAT.CD_CLIENTE = eai.CD_CLIENTE
    ) / (SELECT COUNT(1) TOTAL 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY 
    WHERE 
    eai.CD_INCOTERMS = DD_DAY.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    --AND DD_DAY.CD_CENTRO_EXPEDIDOR = eai.CD_CENTRO_EXPEDIDOR
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    AND DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND eai.CD_INCOTERMS = 'CIF'
    
    )
    
    
    )
    
    ,
    ( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    --AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    )
    )
    ,0) QT_AGENDADA_CONF_OU_BYDAY ,
    -----------------------------------------------------------------
    GREATEST(NVL(
    CASE 
    WHEN P_WEEKDAYS IS NULL THEN 
    (SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA 
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE)
    ELSE
    (SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    --and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA 
    AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    )
    END
    
    ,0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN VND.ELO_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE   --PWEE DAY IS NOT NULL
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    --AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    AND ec.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    
     AND EXISTS (SELECT 1 
                    FROM VND.ELO_EMBALAGEM_INCOTERMS FIL_DIA  --CHOOSE ALL DAYUS ANY WA
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'CIF'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0),0) QT_AGENDADA_CORTE , 


    --------------------------------------------------------                          
    
    NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN VND.ELO_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    --AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    AND ec.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA  --TODOS OS DIAS 
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'CIF'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0)  SOMA_MARCACAO,
    --------------------------------------------------------
    
    NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM VND.ELO_MARCACAO E_MAR
    INNER JOIN VND.ELO_CARTEIRA ec
    ON ec.CD_ELO_CARTEIRA = E_MAR.CD_ELO_CARTEIRA
    WHERE 
    E_MAR.IC_DESISTENCIA = 'N' 
    AND E_MAR.IC_DISPENSADO = 'N'
    --AND E_MAR.CD_CLIENTE = eai.CD_CLIENTE
    AND E_MAR.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM 
    --AND ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    AND ec.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    AND E_MAR.CD_INCOTERMS = eai.CD_INCOTERMS
    
     AND EXISTS (SELECT 1 
                    FROM ELO_EMBALAGEM_INCOTERMS FIL_DIA  --TODOS OS DIAS 
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = E_MAR.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = 'CIF'
                    AND FIL_DIA.NU_DIA_SEMANA = (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW')) 
                    )
    AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0)  SOMA_MARCACAO_SEMANA,
        --------------------------------------------------------                          
    
    

    --NVL(0,0) P_VOLUMED, 
    NVL(P_VOLUME,0) P_VOLUMED, 

    0  as SaldoReplanejado,
     
    NVL(eai.CD_COTA_COMPARTILHADA, 0)   as CompartCota,
    NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
    FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
    WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
    and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
    and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
    and DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
    AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
    AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
    AND DD_DAY.CD_INCOTERMS = 'CIF'
    --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
    
    ),0) VOLUME_MAXIMO_FOB   , 
    eai.NU_DIA_SEMANA,
    eai.CD_TIPO_AGENDAMENTO
    

    FROM CTE_CENARIO_CIF_FOB eai
    WHERE eai.CD_INCOTERMS = 'CIF'
    AND eai.CD_TIPO_AGENDAMENTO = 25    
    

)

--SELECT * FROM CTE_CIF WHERE CD_ELO_CARTEIRA IS NOT NULL
--AND CD_CLIENTE = '0004055408'
--AND EMBALAGEM = 'Ensacado'

      
        
        SELECT --G_TOTAL.* 
                G_TOTAL.CodeCarteira,
                G_TOTAL.CodeCenter,
                G_TOTAL.DescriptionCenter,
                G_TOTAL.CodeCustomer,
                G_TOTAL.DescriptionCustomer,
                G_TOTAL.CodeMachine,
                G_TOTAL.DescriptionMachine,
                G_TOTAL.DescriptionIncoterms,
                G_TOTAL.DescriptionPackage,
                CASE WHEN ROUND(G_TOTAL.SaldoPlanejado,0) > 0 THEN ROUND(G_TOTAL.SaldoPlanejado,0) ELSE 0 END SaldoPlanejado ,
                CASE WHEN ROUND(G_TOTAL.SaldoReplanejado,0) > 0 THEN ROUND(G_TOTAL.SaldoReplanejado,0) ELSE 0 END SaldoReplanejado ,
                G_TOTAL.CompartCota,
                G_TOTAL.VOLUME_MAXIMO_FOB
        
        FROM 
        (
        ---------------- THIS SCENARIO IS PLAN -----------------        
        -------- this scenario is FOB-------------------
        
         select MAX(CD_ELO_CARTEIRA) CodeCarteira,
                CD_CENTRO_EXPEDIDOR CodeCenter,
                DS_CENTRO_EXPEDIDOR DescriptionCenter,
                CD_CLIENTE CodeCustomer,
                NO_CLIENTE DescriptionCustomer,
                CD_MACHINE CodeMachine,
                DS_MACHINE DescriptionMachine,
                CD_INCOTERMS DescriptionIncoterms,
                EMBALAGEM DescriptionPackage,

                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO ) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO  
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO ) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                )             
                
                as SaldoPlanejado,

                SaldoReplanejado,
                CD_COTA_COMPARTILHADA CompartCota,

                SUM(VOLUME_MAXIMO_FOB)  VOLUME_MAXIMO_FOB
 
                from 
                (
                SELECT 
                MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                QT_AGENDADA_CORTE,
                QT_AGENDADA_CONF_OU_BYDAY,
                SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                VOLUME_MAXIMO_FOB,
                P_VOLUMED,
                SaldoReplanejado, 
                NU_DIA_SEMANA
                
                FROM CTE_FOB
                WHERE CD_TIPO_AGENDAMENTO = 22 
                GROUP BY 
                --CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                QT_AGENDADA_CORTE,
                QT_AGENDADA_CONF_OU_BYDAY,
                SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                VOLUME_MAXIMO_FOB,
                P_VOLUMED,
                SaldoReplanejado,
                NU_DIA_SEMANA
                
                )
        
        group by CD_CENTRO_EXPEDIDOR,
                 DS_CENTRO_EXPEDIDOR,
                 CD_CLIENTE,
                 NO_CLIENTE,
                 CD_MACHINE,
                 DS_MACHINE,
                 CD_INCOTERMS,
                 EMBALAGEM,
                 SaldoReplanejado,
                 CD_COTA_COMPARTILHADA--, 
                 --VOLUME_MAXIMO_FOB
--------------------------------UNION  -------------------------                 
        UNION 
        
-------- this scenario is CIF----P_WEEKDAY IS NULL ---------------     
        
         select MAX(CD_ELO_CARTEIRA) CodeCarteira,
                CD_CENTRO_EXPEDIDOR CodeCenter,
                DS_CENTRO_EXPEDIDOR DescriptionCenter,
                CD_CLIENTE CodeCustomer,
                NO_CLIENTE DescriptionCustomer,
                CD_MACHINE CodeMachine,
                DS_MACHINE DescriptionMachine,
                CD_INCOTERMS DescriptionIncoterms,
                EMBALAGEM DescriptionPackage,

                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */ 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */) THEN QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */)  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */ 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */) THEN QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */)  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                )             
                
                as SaldoPlanejado,

                SaldoReplanejado,
                CD_COTA_COMPARTILHADA CompartCota,

                SUM(VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB
 
                from 
                (
                SELECT 
                MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                 
                
                SUM(QT_AGENDADA_CORTE) QT_AGENDADA_CORTE,
                SUM(QT_AGENDADA_CONF_OU_BYDAY) QT_AGENDADA_CONF_OU_BYDAY,
                SUM(SOMA_MARCACAO) SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                SUM( VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB,
                P_VOLUMED, 
                SaldoReplanejado,
                1 NU_DIA_SEMANA
                
                FROM CTE_CIF
                
                WHERE CD_ELO_CARTEIRA IS NOT NULL
                AND P_WEEKDAYS IS NULL
                AND CD_TIPO_AGENDAMENTO = 22
                GROUP BY
                                --CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                --QT_AGENDADA_CORTE,
                --QT_AGENDADA_CONF_OU_BYDAY,
                --SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                --VOLUME_MAXIMO_FOB,
                P_VOLUMED, 
                SaldoReplanejado--, 
                --NU_DIA_SEMANA
                
                )
        
        group by CD_CENTRO_EXPEDIDOR,
                 DS_CENTRO_EXPEDIDOR,
                 CD_CLIENTE,
                 NO_CLIENTE,
                 CD_MACHINE,
                 DS_MACHINE,
                 CD_INCOTERMS,
                 EMBALAGEM,
                 SaldoReplanejado,
                 CD_COTA_COMPARTILHADA--, 
                 --VOLUME_MAXIMO_FOB        
UNION 

-------- this scenario is CIF----P_WEEKDAY IS NOT NULL ---------------     
        
         select MAX(CD_ELO_CARTEIRA) CodeCarteira,
                CD_CENTRO_EXPEDIDOR CodeCenter,
                DS_CENTRO_EXPEDIDOR DescriptionCenter,
                CD_CLIENTE CodeCustomer,
                NO_CLIENTE DescriptionCustomer,
                CD_MACHINE CodeMachine,
                DS_MACHINE DescriptionMachine,
                CD_INCOTERMS DescriptionIncoterms,
                EMBALAGEM DescriptionPackage,

                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO  
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO)  THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO  
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO ) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                )             
                
                as SaldoPlanejado,

                SaldoReplanejado,
                CD_COTA_COMPARTILHADA CompartCota,

                SUM(VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB
 
                from 
                (
                SELECT 
                MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                 
                
                sum( QT_AGENDADA_CORTE )* 1 /*MAX(NU_DIA_SEMANA)*/ QT_AGENDADA_CORTE,
                SUM(QT_AGENDADA_CONF_OU_BYDAY) QT_AGENDADA_CONF_OU_BYDAY,
                SUM(SOMA_MARCACAO) SOMA_MARCACAO ,
                CD_COTA_COMPARTILHADA,
                SUM(VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB ,
                P_VOLUMED, 
                SaldoReplanejado,
                1 NU_DIA_SEMANA
                
                FROM CTE_CIF
                
                WHERE CD_ELO_CARTEIRA IS NOT NULL
                AND P_WEEKDAYS IS NOT NULL
                AND CD_TIPO_AGENDAMENTO = 22
                GROUP BY
                                --CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                --QT_AGENDADA_CORTE,
                --QT_AGENDADA_CONF_OU_BYDAY,
                --SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                --VOLUME_MAXIMO_FOB,
                P_VOLUMED, 
                SaldoReplanejado--, 
                --NU_DIA_SEMANA
                
                )
        
        group by CD_CENTRO_EXPEDIDOR,
                 DS_CENTRO_EXPEDIDOR,
                 CD_CLIENTE,
                 NO_CLIENTE,
                 CD_MACHINE,
                 DS_MACHINE,
                 CD_INCOTERMS,
                 EMBALAGEM,
                 SaldoReplanejado,
                 CD_COTA_COMPARTILHADA--, 
                 --VOLUME_MAXIMO_FOB      
---------------- THIS SCENARIO IS PLAN -----------------        
UNION 

        ---------------- THIS SCENARIO IS REPLAN -----------------        
        -------- this scenario is FOB-------------------
        
         select MAX(CD_ELO_CARTEIRA) CodeCarteira,
                CD_CENTRO_EXPEDIDOR CodeCenter,
                DS_CENTRO_EXPEDIDOR DescriptionCenter,
                CD_CLIENTE CodeCustomer,
                NO_CLIENTE DescriptionCustomer,
                CD_MACHINE CodeMachine,
                DS_MACHINE DescriptionMachine,
                CD_INCOTERMS DescriptionIncoterms,
                EMBALAGEM DescriptionPackage,

                0 SaldoPlanejado,
                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO ) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO  
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO ) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                ) AS  SaldoReplanejado,
                CD_COTA_COMPARTILHADA CompartCota,

                SUM(VOLUME_MAXIMO_FOB)  VOLUME_MAXIMO_FOB
 
                from 
                (
                SELECT 
                MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                QT_AGENDADA_CORTE,
                QT_AGENDADA_CONF_OU_BYDAY,
                SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                VOLUME_MAXIMO_FOB,
                P_VOLUMED,
                SaldoReplanejado, 
                NU_DIA_SEMANA
                
                FROM CTE_FOB
                WHERE CD_TIPO_AGENDAMENTO = 25 
                GROUP BY 
                --CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                QT_AGENDADA_CORTE,
                QT_AGENDADA_CONF_OU_BYDAY,
                SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                VOLUME_MAXIMO_FOB,
                P_VOLUMED,
                SaldoReplanejado,
                NU_DIA_SEMANA
                
                )
        
        group by CD_CENTRO_EXPEDIDOR,
                 DS_CENTRO_EXPEDIDOR,
                 CD_CLIENTE,
                 NO_CLIENTE,
                 CD_MACHINE,
                 DS_MACHINE,
                 CD_INCOTERMS,
                 EMBALAGEM,
                 SaldoReplanejado,
                 CD_COTA_COMPARTILHADA--, 
                 --VOLUME_MAXIMO_FOB
--------------------------------UNION  -------------------------                 
        UNION 
        
-------- this scenario is CIF----P_WEEKDAY IS NULL ---------------     
        
         select MAX(CD_ELO_CARTEIRA) CodeCarteira,
                CD_CENTRO_EXPEDIDOR CodeCenter,
                DS_CENTRO_EXPEDIDOR DescriptionCenter,
                CD_CLIENTE CodeCustomer,
                NO_CLIENTE DescriptionCustomer,
                CD_MACHINE CodeMachine,
                DS_MACHINE DescriptionMachine,
                CD_INCOTERMS DescriptionIncoterms,
                EMBALAGEM DescriptionPackage,
                0 SaldoPlanejado,

                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */ 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */) THEN QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */)  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */ 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */) THEN QT_AGENDADA_CONF_OU_BYDAY  /*- SOMA_MARCACAO */
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY /*- SOMA_MARCACAO */)  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                )             
                
                as SaldoReplanejado,
                CD_COTA_COMPARTILHADA CompartCota,

                SUM(VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB
 
                from 
                (
                SELECT 
                MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                 
                
                SUM(QT_AGENDADA_CORTE) QT_AGENDADA_CORTE,
                SUM(QT_AGENDADA_CONF_OU_BYDAY) QT_AGENDADA_CONF_OU_BYDAY,
                SUM(SOMA_MARCACAO) SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                SUM( VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB,
                P_VOLUMED, 
                SaldoReplanejado,
                1 NU_DIA_SEMANA
                
                FROM CTE_CIF
                
                WHERE CD_ELO_CARTEIRA IS NOT NULL
                AND P_WEEKDAYS IS NULL
                AND CD_TIPO_AGENDAMENTO = 25
                GROUP BY
                                --CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                --QT_AGENDADA_CORTE,
                --QT_AGENDADA_CONF_OU_BYDAY,
                --SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                --VOLUME_MAXIMO_FOB,
                P_VOLUMED, 
                SaldoReplanejado--, 
                --NU_DIA_SEMANA
                
                )
        
        group by CD_CENTRO_EXPEDIDOR,
                 DS_CENTRO_EXPEDIDOR,
                 CD_CLIENTE,
                 NO_CLIENTE,
                 CD_MACHINE,
                 DS_MACHINE,
                 CD_INCOTERMS,
                 EMBALAGEM,
                 SaldoReplanejado,
                 CD_COTA_COMPARTILHADA--, 
                 --VOLUME_MAXIMO_FOB        
UNION 

-------- this scenario is CIF----P_WEEKDAY IS NOT NULL ---------------     
        
         select MAX(CD_ELO_CARTEIRA) CodeCarteira,
                CD_CENTRO_EXPEDIDOR CodeCenter,
                DS_CENTRO_EXPEDIDOR DescriptionCenter,
                CD_CLIENTE CodeCustomer,
                NO_CLIENTE DescriptionCustomer,
                CD_MACHINE CodeMachine,
                DS_MACHINE DescriptionMachine,
                CD_INCOTERMS DescriptionIncoterms,
                EMBALAGEM DescriptionPackage,
                0 SaldoPlanejado,
                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO  
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO)  THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO  
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO ) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO 
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO )  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                )             
                
                as SaldoReplanejado,
                CD_COTA_COMPARTILHADA CompartCota,

                SUM(VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB
 
                from 
                (
                SELECT 
                MAX(CD_ELO_CARTEIRA) CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                 
                
                sum( QT_AGENDADA_CORTE )* 1 /*MAX(NU_DIA_SEMANA)*/ QT_AGENDADA_CORTE,
                SUM(QT_AGENDADA_CONF_OU_BYDAY) QT_AGENDADA_CONF_OU_BYDAY,
                SUM(SOMA_MARCACAO) SOMA_MARCACAO ,
                CD_COTA_COMPARTILHADA,
                SUM(VOLUME_MAXIMO_FOB) VOLUME_MAXIMO_FOB ,
                P_VOLUMED, 
                SaldoReplanejado,
                1 NU_DIA_SEMANA
                
                FROM CTE_CIF
                
                WHERE CD_ELO_CARTEIRA IS NOT NULL
                AND P_WEEKDAYS IS NOT NULL
                AND CD_TIPO_AGENDAMENTO = 25
                GROUP BY
                                --CD_ELO_CARTEIRA,
                CD_CENTRO_EXPEDIDOR,
                DS_CENTRO_EXPEDIDOR,
                CD_CLIENTE,
                NO_CLIENTE,
                CD_MACHINE,
                DS_MACHINE,
                CD_INCOTERMS,
                EMBALAGEM,
                --QT_AGENDADA_CORTE,
                --QT_AGENDADA_CONF_OU_BYDAY,
                --SOMA_MARCACAO,
                CD_COTA_COMPARTILHADA,
                --VOLUME_MAXIMO_FOB,
                P_VOLUMED, 
                SaldoReplanejado--, 
                --NU_DIA_SEMANA
                
                )
        
        group by CD_CENTRO_EXPEDIDOR,
                 DS_CENTRO_EXPEDIDOR,
                 CD_CLIENTE,
                 NO_CLIENTE,
                 CD_MACHINE,
                 DS_MACHINE,
                 CD_INCOTERMS,
                 EMBALAGEM,
                 SaldoReplanejado,
                 CD_COTA_COMPARTILHADA--, 
                 --VOLUME_MAXIMO_FOB      
---------------- THIS SCENARIO IS REPLAN -----------------    

        
 
 ) G_TOTAL
                 
        order by CodeCustomer,
                 DescriptionCustomer;
                 
                 
                                                                
    END PX_SEARCH_NEWENTRY;
  
      
     
     
    PROCEDURE PX_SEARCH_NEWENTRY_OLD (
        P_CD_CENTRO             IN CTF.CENTRO_EXPEDIDOR.CD_CENTRO_EXPEDIDOR%TYPE,
        P_WEEK                  IN VARCHAR2,
        P_NO_CLIENTE            IN VND.ELO_CARTEIRA.NO_CLIENTE%TYPE,
        P_MACHINES              IN VARCHAR2,
        P_INCOTERM              IN VND.ELO_CARTEIRA.CD_INCOTERMS%TYPE,
        P_PACKAGE               IN VND.GRUPO_EMBALAGEM.CD_GRUPO_EMBALAGEM%TYPE,
        P_VOLUME                IN INT,
        P_WEEKDAYS              IN VARCHAR2,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    
    V_POLO      CTF.POLO.CD_POLO%TYPE;
    
    BEGIN
    
        IF P_CD_CENTRO IS NOT NULL THEN
            BEGIN
            select pc.CD_POLO
              into V_POLO
              from CTF.POLO_CENTRO_EXPEDIDOR pc
             where pc.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO;
             EXCEPTION 
             WHEN NO_DATA_FOUND THEN 
             V_POLO:=NULL;
             
             WHEN OTHERS THEN 
             V_POLO:=NULL;
             END;
        END IF;
    

    
        OPEN P_RETURN FOR
        
        WITH CTE_AGENDAMENTO_FILTER AS 
        (
        SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_MACHINE, ma.DS_MACHINE, AGE.CD_WEEK 
        FROM VND.ELO_AGENDAMENTO AGE 
        LEFT JOIN CTF.MACHINE ma
        on AGE.CD_MACHINE = ma.CD_MACHINE
        inner join VND.ELO_STATUS es
        on es.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        
        WHERE AGE.IC_ATIVO = 'S'
        AND (es.SG_STATUS IN ('PLAN','AGCTR','AGENC'))
        AND (P_WEEK is null OR AGE.CD_WEEK = P_WEEK)
        and (P_MACHINES is null OR AGE.CD_MACHINE IN (P_MACHINES))
        
        ),
        
        CTE_AGENDAMENTO AS 
        (
            SELECT DISTINCT AGE.CD_ELO_AGENDAMENTO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_MACHINE, AGE.DS_MACHINE, AGE.CD_WEEK
            FROM CTE_AGENDAMENTO_FILTER AGE
            WHERE 
            (EXISTS 
            (SELECT 1 FROM VND.ELO_CARTEIRA CTA 
            INNER JOIN (
            SELECT DISTINCT pc.CD_CENTRO_EXPEDIDOR 
            FROM CTF.CENTRO_EXPEDIDOR pc
            WHERE pc.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
            UNION 
            SELECT DISTINCT pc.CD_CENTRO_EXPEDIDOR 
            FROM CTF.POLO_CENTRO_EXPEDIDOR pc
            INNER JOIN CTF.POLO_CENTRO_EXPEDIDOR PESQPORPOLO
            ON pc.CD_POLO = PESQPORPOLO.CD_POLO
            WHERE 
            PESQPORPOLO.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
            ) ACDENTRO
            ON ACDENTRO.CD_CENTRO_EXPEDIDOR = CTA.CD_CENTRO_EXPEDIDOR
            WHERE CTA.IC_ATIVO = 'S'
            AND AGE.CD_ELO_AGENDAMENTO = CTA.CD_ELO_AGENDAMENTO
        
            ) OR (P_CD_CENTRO IS NULL))
        
        ),
        
        
               CTE_CARTEIRA AS 
        (
        
        SELECT DISTINCT 
        CTAF.CD_ELO_CARTEIRA , 
        CTAF.CD_ELO_AGENDAMENTO, 
        CTAF.CD_TIPO_AGENDAMENTO, 
        CTAF.CD_TIPO_REPLAN, 
        CTAF.QT_AGENDADA_CONFIRMADA,
        CTAF.CD_ELO_AGENDAMENTO_ITEM,
        CTAF.CD_INCOTERMS,
        CTAF.CD_CLIENTE ,
        CTAF.NO_CLIENTE ,
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
        WHERE
        CTAF.IC_ATIVO = 'S'
          and (P_CD_CENTRO is null or CTAF.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO)
          AND (NVL(CTAF.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (CTAF.IC_CORTADO_FABRICA <> 1 OR CTAF.IC_CORTADO_FABRICA IS NULL))
        
        ),
        
        ELO_AG_DAY_BY_INCOTERMS_ITEM  AS (
        SELECT  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, EAG_ITEM_I.CD_INCOTERMS, 
        DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA, SUM(DAYY.NU_QUANTIDADE) NU_QUANTIDADE, 
        MAX(CD_COTA_COMPARTILHADA) CD_COTA_COMPARTILHADA, EAG_ITEM_I.CD_CLIENTE
        FROM CTE_AGENDAMENTO FILT
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
        AND (DAYY.NU_DIA_SEMANA IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                        connect by regexp_substr(1, '[^,]+', 1, level) is not null )
                                        OR P_WEEKDAYS  IS NULL)
                                        
        GROUP BY  EA_SUP_I.CD_ELO_AGENDAMENTO, EAG_ITEM_I.CD_ELO_AGENDAMENTO_ITEM, 
        EAG_ITEM_I.CD_INCOTERMS, DAYY.CD_GRUPO_EMBALAGEM, DAYY.NU_DIA_SEMANA , EAG_ITEM_I.CD_CLIENTE                                   
        )   ,
        --SELECT * FROM ELO_AG_DAY_BY_INCOTERMS_ITEM

       ELO_AG_DAY AS (
        SELECT  EADBI.CD_ELO_AGENDAMENTO, EADBI.CD_GRUPO_EMBALAGEM, 
        EADBI.NU_DIA_SEMANA, SUM(EADBI.NU_QUANTIDADE) NU_QUANTIDADE,
        EADBI.CD_INCOTERMS,
        EADBI.CD_CLIENTE
        FROM ELO_AG_DAY_BY_INCOTERMS_ITEM EADBI
        GROUP BY  EADBI.CD_ELO_AGENDAMENTO,  EADBI.CD_GRUPO_EMBALAGEM, EADBI.NU_DIA_SEMANA , 
        EADBI.CD_INCOTERMS, EADBI.CD_CLIENTE                                   
        )   
        --SELECT * FROM ELO_AG_DAY
 
 
        
        -------- this scenario is FOB-------------------
        SELECT --G_TOTAL.* 
                G_TOTAL.CodeCarteira,
                G_TOTAL.CodeCenter,
                G_TOTAL.DescriptionCenter,
                G_TOTAL.CodeCustomer,
                G_TOTAL.DescriptionCustomer,
                G_TOTAL.CodeMachine,
                G_TOTAL.DescriptionMachine,
                G_TOTAL.DescriptionIncoterms,
                G_TOTAL.DescriptionPackage,
                CASE WHEN G_TOTAL.SaldoPlanejado > 0 THEN G_TOTAL.SaldoPlanejado ELSE 0 END SaldoPlanejado ,
                G_TOTAL.SaldoReplanejado,
                G_TOTAL.CompartCota,
                G_TOTAL.VOLUME_MAXIMO_FOB
        
        FROM 
        (
        
        
         select MAX(CodeCarteira)       as CodeCarteira,
                CodeCenter,
                DescriptionCenter,
                CodeCustomer,
                DescriptionCustomer,
                CodeMachine,
                DescriptionMachine,
                DescriptionIncoterms,
                DescriptionPackage,
                CASE 
                WHEN P_WEEKDAYS IS NULL THEN 
                
                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                ) 
                ELSE 
                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE  <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END)
                END
                
              
                ) END            
                
                as SaldoPlanejado,


                SaldoReplanejado,
                CompartCota,
                CASE 
                WHEN P_WEEKDAYS IS NULL THEN 
                SUM(VOLUME_MAXIMO_FOB)
                ELSE MAX(VOLUME_MAXIMO_FOB) END
                VOLUME_MAXIMO_FOB
                --VOLUME_MAXIMO_FOB
           from (
                select --distinct 
                       ec.CD_ELO_CARTEIRA                                                                       as CodeCarteira,
                       ec.CD_CENTRO_EXPEDIDOR                                                                   as CodeCenter,
                       ec.DS_CENTRO_EXPEDIDOR                                                                   as DescriptionCenter,
                       ec.CD_CLIENTE                                                                            as CodeCustomer,
                       ec.NO_CLIENTE                                                                            as DescriptionCustomer,
                       NVL(ag.CD_MACHINE, 0)                                                                    as CodeMachine,
                       ag.DS_MACHINE                                                                            as DescriptionMachine,
                       ec.CD_INCOTERMS                                                                          as DescriptionIncoterms,
                 (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM )  as DescriptionPackage,
                        CASE WHEN P_WEEKDAYS IS NULL THEN 
                     
                            NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
                            FROM ELO_AG_DAY DD_DAY
                            WHERE DD_DAY.CD_ELO_AGENDAMENTO = AGDY.CD_ELO_AGENDAMENTO
                            --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                            AND DD_DAY.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                            AND DD_DAY.CD_INCOTERMS = 'FOB'
                            and DD_DAY.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
                            AND DD_DAY.CD_INCOTERMS = AGDY.CD_INCOTERMS
                            AND DD_DAY.CD_CLIENTE = AGDY.CD_CLIENTE
                        ),0)                        
                        
                        
                        ELSE 
                        
                            NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
                            FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
                            WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
                            and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                            AND DD_DAY.CD_INCOTERMS = 'FOB'
                            and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                            AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
                            AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE

                            --AND DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
                            
                            ),0)  END QT_AGENDADA_CONF_OU_BYDAY ,
                            -----------------------------------------------------------------
                            NVL(ec.QT_AGENDADA_CONFIRMADA,0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.CD_CLIENTE = AGDY.CD_CLIENTE
                         AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM 
                                                AND (((1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW'))  

                        IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                        connect by regexp_substr(P_WEEKDAYS, '[^,]+', 1, level) is not null )
                                        ) OR P_WEEKDAYS IS NULL) 
                      
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0) QT_AGENDADA_CORTE , 
                        ---------------------------------------------------
                        
                        ---------------------------------------------------                           
                        CASE WHEN P_WEEKDAYS IS NOT NULL THEN      
                        NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        INNER JOIN VND.ELO_CARTEIRA CCC 
                        ON E_MAR.CD_ELO_CARTEIRA = CCC.CD_ELO_CARTEIRA
                        INNER JOIN CTE_AGENDAMENTO AGEND
                        ON AGEND.CD_ELO_AGENDAMENTO = CCC.CD_ELO_AGENDAMENTO 
                        
                        WHERE 
                        CCC.IC_ATIVO = 'S' AND CCC.CD_INCOTERMS = 'FOB'
                        AND CCC.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                        AND E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                         AND E_MAR.CD_CLIENTE = AGDY.CD_CLIENTE
                        AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM 
                        AND ((1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW'))  

                        IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                        connect by regexp_substr(P_WEEKDAYS, '[^,]+', 1, level) is not null )
                                        )
                        
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)
                        ELSE   -- CASE P_WEEKDAYS
                        NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM 
                        AND E_MAR.CD_CLIENTE = AGDY.CD_CLIENTE
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)                        
                        END  SOMA_MARCACAO,
                        --------------------------------------------
                        
                        NVL(P_VOLUME,0) P_VOLUMED, 
                        
                             
                       ((NVL((CASE WHEN ec.CD_TIPO_REPLAN = GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','INCLUSAO')
                             THEN ec.QT_SALDO END), 0) +
                       NVL((CASE WHEN ec.CD_TIPO_REPLAN = GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','DIMREPLAN')
                             THEN ec.QT_SALDO END), 0)) +
                       NVL((CASE WHEN ec.CD_TIPO_AGENDAMENTO = GX_ELO_COMMON.FX_ELO_STATUS('TIPAG','REPLAN')
                             THEN ec.QT_SALDO END),0))                                                         
                             - 
                       NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0)   as SaldoReplanejado,
                             
                       NVL(eai.CD_COTA_COMPARTILHADA, 0)                                                        as CompartCota,
                            NVL(( SELECT SUM(DD_DAY.NU_QUANTIDADE) NU_QUANTIDADE 
                            FROM ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
                            WHERE DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
                            and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                            and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                            AND DD_DAY.CD_INCOTERMS = 'FOB'
                            --and DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
                            
                            ),0) VOLUME_MAXIMO_FOB        
                       
                     from 
                     (
                    SELECT intec.CD_ELO_AGENDAMENTO, (intec.CD_ELO_CARTEIRA) CD_ELO_CARTEIRA , SUM(intec.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA,
                    intec.CD_ELO_AGENDAMENTO_ITEM, intec.IC_ATIVO, MIN(NVL(intec.IC_CORTADO_FABRICA, 0)) IC_CORTADO_FABRICA , intec.CD_INCOTERMS,
                    intec.CD_GRUPO_EMBALAGEM, SUM(intec.QT_SALDO) QT_SALDO,  intec.CD_CENTRO_EXPEDIDOR ,
                    intec.DS_CENTRO_EXPEDIDOR , 
                    intec.CD_CLIENTE  ,
                    intec.NO_CLIENTE , intec.CD_TIPO_AGENDAMENTO,
                    intec.CD_TIPO_REPLAN
                 
                  FROM VND.ELO_CARTEIRA intec
                  INNER JOIN CTE_AGENDAMENTO CAGE
                  ON CAGE.CD_ELO_AGENDAMENTO = intec.CD_ELO_AGENDAMENTO
                  GROUP BY 
                    intec.CD_ELO_AGENDAMENTO, 
                    intec.IC_ATIVO, intec.CD_INCOTERMS,
                    intec.CD_GRUPO_EMBALAGEM,  intec.CD_CENTRO_EXPEDIDOR ,
                    intec.DS_CENTRO_EXPEDIDOR , 
                    intec.CD_CLIENTE  ,
                    intec.NO_CLIENTE ,
                    intec.CD_TIPO_AGENDAMENTO,
                    intec.CD_TIPO_REPLAN,
                    intec.CD_ELO_AGENDAMENTO_ITEM,
                    intec.CD_ELO_CARTEIRA
                  ) ec
                       
                  
--                  left join VND.ELO_MARCACAO ma
--                    on ec.CD_ELO_CARTEIRA = ma.CD_ELO_CARTEIRA
                 -- left join VND.ELO_CARTEIRA_DAY ecd
                 --   on ec.CD_ELO_CARTEIRA = ecd.CD_ELO_CARTEIRA
    

                 inner join CTE_AGENDAMENTO ag
                    on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                 inner join ELO_AG_DAY_BY_INCOTERMS_ITEM eai
                    on ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                    AND eai.CD_INCOTERMS = 'FOB'
                INNER JOIN ELO_AG_DAY AGDY
                 ON eai.CD_ELO_AGENDAMENTO = AGDY.CD_ELO_AGENDAMENTO
                 AND eai.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                 AND eai.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
                 AND eai.CD_CLIENTE = AGDY.CD_CLIENTE
                 AND AGDY.CD_INCOTERMS = 'FOB'    
                    

                 where 
                    ec.IC_ATIVO = 'S'
                   
                   and (NVL(ec.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (ec.IC_CORTADO_FABRICA <> 1 OR ec.IC_CORTADO_FABRICA IS NULL))
                   and (P_NO_CLIENTE is null OR UPPER(ec.NO_CLIENTE) = UPPER(P_NO_CLIENTE))

                   and ((P_INCOTERM IS NULL AND ec.CD_INCOTERMS = 'FOB') OR (P_INCOTERM = 'FOB' AND ec.CD_INCOTERMS = 'FOB'))
                   and (P_PACKAGE is null OR ec.CD_GRUPO_EMBALAGEM = P_PACKAGE)
                   --and (P_VOLUME is null OR ec.QT_SALDO >= P_VOLUME)
        )
        group by CodeCenter,
                 DescriptionCenter,
                 CodeCustomer,
                 DescriptionCustomer,
                 CodeMachine,
                 DescriptionMachine,
                 DescriptionIncoterms,
                 DescriptionPackage,
                 SaldoReplanejado,
                 CompartCota--, 
                 --VOLUME_MAXIMO_FOB
 
        -------- this scenario is CIF--WEEKDAY IS NULL-----------------
        UNION
 
         select MAX(CodeCarteira)       as CodeCarteira,
                CodeCenter,
                DescriptionCenter,
                CodeCustomer,
                DescriptionCustomer,
                CodeMachine,
                DescriptionMachine,
                DescriptionIncoterms,
                DescriptionPackage,
                
                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END) THEN QT_AGENDADA_CORTE 
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END)
                END)
                     as SaldoPlanejado,
                SaldoReplanejado,
                CompartCota,
                SUM(VOLUME_MAXIMO_CIF) VOLUME_MAXIMO_CIF
           from (
           
           
                select distinct 
                       ec.CD_ELO_CARTEIRA                                                                       as CodeCarteira,
                       ec.CD_CENTRO_EXPEDIDOR                                                                   as CodeCenter,
                       ec.DS_CENTRO_EXPEDIDOR                                                                   as DescriptionCenter,
                       ec.CD_CLIENTE                                                                            as CodeCustomer,
                       ec.NO_CLIENTE                                                                            as DescriptionCustomer,
                       NVL(ag.CD_MACHINE, 0)                                                                    as CodeMachine,
                       ag.DS_MACHINE                                                                            as DescriptionMachine,
                       ec.CD_INCOTERMS                                                                          as DescriptionIncoterms,
                (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM )   as DescriptionPackage,
                        NVL(ec.QT_AGENDADA_CONFIRMADA,0)  QT_AGENDADA_CONF_OU_BYDAY , 
                            -----------------------------------------------------------------
                            NVL(ec.QT_AGENDADA_CONFIRMADA,0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                      
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0) QT_AGENDADA_CORTE , 
                        ---------------------------------------------------                           
                        NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)                        
                        SOMA_MARCACAO,
                        --------------------------------------------
                        
                        NVL(0,0) P_VOLUMED, 
                        
                             
                       ((NVL((CASE WHEN ec.CD_TIPO_REPLAN = GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','INCLUSAO')
                             THEN ec.QT_SALDO END), 0) +
                       NVL((CASE WHEN ec.CD_TIPO_REPLAN = GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','DIMREPLAN')
                             THEN ec.QT_SALDO END), 0)) +
                       NVL((CASE WHEN ec.CD_TIPO_AGENDAMENTO = GX_ELO_COMMON.FX_ELO_STATUS('TIPAG','REPLAN')
                             THEN ec.QT_SALDO END),0))                                                         
                             - 
                       NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0)   as SaldoReplanejado,
                             
                       NVL((SELECT MAX(eai.CD_COTA_COMPARTILHADA)  
                            FROM ELO_AG_DAY_BY_INCOTERMS_ITEM eai WHERE eai.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM) , 0)  as CompartCota,
                            NVL(( SELECT SUM(AGEMAT.NU_QUANTIDADE) NU_QUANTIDADE 
                            FROM VND.ELO_CONTROLLERSHIP_MATINAL AGEMAT
--                            INNER JOIN VND.ELO_CARTEIRA CATE
--                            ON CATE.CD_ELO_CARTEIRA = AGEMAT.CD_ELO_CARTEIRA
                            INNER JOIN ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
                            ON DD_DAY.CD_ELO_AGENDAMENTO = AGEMAT.CD_ELO_AGENDAMENTO
                            AND DD_DAY.NU_DIA_SEMANA = AGEMAT.NU_DIA_SEMANA
                            AND DD_DAY.CD_GRUPO_EMBALAGEM = AGEMAT.CD_GRUPO_EMBALAGEM
                           -- WHERE CATE.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                           WHERE AGEMAT.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                           AND DD_DAY.CD_ELO_AGENDAMENTO_ITEM = ec.CD_ELO_AGENDAMENTO_ITEM
                           AND DD_DAY.CD_INCOTERMS = 'CIF'
                            
                            ),0) VOLUME_MAXIMO_CIF       
            
            
         from (
         
         
          SELECT intec.CD_ELO_CARTEIRA , 
          intec.CD_ELO_AGENDAMENTO, 
          intec.CD_ELO_AGENDAMENTO_ITEM, 
          intec.CD_INCOTERMS, 
          intec.CD_TIPO_REPLAN, 
          SUM(intec.QT_SALDO) QT_SALDO, 
          --intec.CD_TIPO_AGENDAMENTO,
         
          SUM(intec.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA,
          
           intec.CD_SALES_GROUP, 

          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR, MAX(intec.DH_BACKLOG_CIF) DH_BACKLOG_CIF, intec.CD_GRUPO_EMBALAGEM,
          intec.CD_TIPO_AGENDAMENTO, intec.CD_CENTRO_EXPEDIDOR

          FROM CTE_CARTEIRA intec
          INNER JOIN CTE_AGENDAMENTO AGED
          ON intec.CD_ELO_AGENDAMENTO = AGED.CD_ELO_AGENDAMENTO
          

          GROUP BY 
          intec.CD_ELO_AGENDAMENTO, 
          intec.CD_INCOTERMS, 
          intec.CD_SALES_GROUP,
          intec.CD_CLIENTE, intec.NO_CLIENTE, intec.DS_CENTRO_EXPEDIDOR, intec.CD_CENTRO_EXPEDIDOR,
          intec.CD_GRUPO_EMBALAGEM,
          intec.CD_ELO_CARTEIRA, 
          intec.CD_ELO_AGENDAMENTO_ITEM,
          intec.CD_TIPO_REPLAN,
          intec.CD_TIPO_AGENDAMENTO
  
          ) ec  
          

           INNER JOIN CTF.USUARIO u
            on ec.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL
            INNER JOIN CTE_AGENDAMENTO_FILTER ag
            on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
            
            left join VND.ELO_STATUS estrp
            on estrp.CD_ELO_STATUS = ec.CD_TIPO_REPLAN
            left join CTF.MACHINE ma
            on ag.CD_MACHINE = ma.CD_MACHINE
            INNER JOIN ELO_AG_DAY_BY_INCOTERMS_ITEM eai
            on ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
            --AND eai.CD_INCOTERMS = 'FOB'
            INNER JOIN ELO_AG_DAY AGDY
            ON eai.CD_ELO_AGENDAMENTO = AGDY.CD_ELO_AGENDAMENTO
            AND eai.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
            AND eai.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
            AND eai.CD_CLIENTE = AGDY.CD_CLIENTE
            AND eai.CD_INCOTERMS = AGDY.CD_INCOTERMS
            
            
            WHERE 
                   
                   --and (NVL(ec.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (ec.IC_CORTADO_FABRICA <> 1 OR ec.IC_CORTADO_FABRICA IS NULL))
                   --and (P_NO_CLIENTE is null OR UPPER(ec.NO_CLIENTE) = UPPER(P_NO_CLIENTE))

                    (('CIF' IS NULL AND ec.CD_INCOTERMS = 'CIF') OR ('CIF' = 'CIF' AND ec.CD_INCOTERMS = 'CIF'))
                   --and (P_PACKAGE is null OR ec.CD_GRUPO_EMBALAGEM = P_PACKAGE)
                   --and (P_VOLUME is null OR ec.QT_SALDO >= P_VOLUME)

                  
        )
        
        WHERE P_WEEKDAYS IS NULL
        group by CodeCenter,
                 DescriptionCenter,
                 CodeCustomer,
                 DescriptionCustomer,
                 CodeMachine,
                 DescriptionMachine,
                 DescriptionIncoterms,
                 DescriptionPackage,
                 SaldoReplanejado,
                 CompartCota--, 
                 --VOLUME_MAXIMO_CIF

        -------- this scenario is CIF--WEEKDAY IS NULL-----------------
        
        -------- this scenario is CIF--WEEKDAY IS NOT NULL---------------------------------
        -----------------------------------------------------------------------------------
        UNION
         select MAX(CodeCarteira)       as CodeCarteira,
                CodeCenter,
                DescriptionCenter,
                CodeCustomer,
                DescriptionCustomer,
                CodeMachine,
                DescriptionMachine,
                DescriptionIncoterms,
                DescriptionPackage,
                
                SUM(
                CASE 
                WHEN QT_AGENDADA_CORTE <
                
                (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END) AND QT_AGENDADA_CORTE < QT_AGENDADA_CONF_OU_BYDAY - MARCADOS THEN QT_AGENDADA_CORTE 
                
                WHEN QT_AGENDADA_CORTE > QT_AGENDADA_CONF_OU_BYDAY - MARCADOS THEN QT_AGENDADA_CONF_OU_BYDAY - MARCADOS
                
                ELSE 
                 (CASE 
                WHEN P_VOLUMED = 0 THEN QT_AGENDADA_CONF_OU_BYDAY - SOMA_MARCACAO 
                WHEN P_VOLUMED > (QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO) THEN QT_AGENDADA_CONF_OU_BYDAY  - SOMA_MARCACAO
                WHEN P_VOLUMED <=(QT_AGENDADA_CONF_OU_BYDAY -SOMA_MARCACAO)  THEN P_VOLUMED
                ELSE 0 END)
                END)
                     as SaldoPlanejado,
                SaldoReplanejado,
                CompartCota,
                SUM(VOLUME_MAXIMO_CIF) VOLUME_MAXIMO_CIF
                
           from (
                select distinct 
                       ec.CD_ELO_CARTEIRA                                                                       as CodeCarteira,
                       ec.CD_CENTRO_EXPEDIDOR                                                                   as CodeCenter,
                       ec.DS_CENTRO_EXPEDIDOR                                                                   as DescriptionCenter,
                       ec.CD_CLIENTE                                                                            as CodeCustomer,
                       ec.NO_CLIENTE                                                                            as DescriptionCustomer,
                       NVL(ag.CD_MACHINE, 0)                                                                    as CodeMachine,
                       ag.DS_MACHINE                                                                            as DescriptionMachine,
                       ec.CD_INCOTERMS                                                                          as DescriptionIncoterms,
                (SELECT GEI.DS_GRUPO_EMBALAGEM FROM VND.GRUPO_EMBALAGEM GEI WHERE AGDY.CD_GRUPO_EMBALAGEM = GEI.CD_GRUPO_EMBALAGEM )   as DescriptionPackage,
                        CASE WHEN P_WEEKDAYS IS NULL THEN 
                        NVL(ec.QT_AGENDADA_CONFIRMADA,0) ELSE 
                            NVL(( SELECT MAX(AGEMAT.NU_QUANTIDADE) NU_QUANTIDADE 
                            FROM VND.ELO_CONTROLLERSHIP_MATINAL AGEMAT
--                            INNER JOIN VND.ELO_CARTEIRA CATE
--                            ON CATE.CD_ELO_CARTEIRA = AGEMAT.CD_ELO_CARTEIRA
                            INNER JOIN ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
                            ON DD_DAY.CD_ELO_AGENDAMENTO = AGEMAT.CD_ELO_AGENDAMENTO
                            AND DD_DAY.NU_DIA_SEMANA = AGEMAT.NU_DIA_SEMANA
                            AND DD_DAY.CD_GRUPO_EMBALAGEM = AGEMAT.CD_GRUPO_EMBALAGEM
                            
                            
--                            WHERE CATE.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                            WHERE 
                            DD_DAY.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
                            AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
                            AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
                            AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                            AND DD_DAY.CD_INCOTERMS = 'CIF'
                            and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                            AND AGEMAT.NU_DIA_SEMANA IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                        connect by regexp_substr(P_WEEKDAYS, '[^,]+', 1, level) is not null )
                                         
                            ),0)  END QT_AGENDADA_CONF_OU_BYDAY , 
                            -----------------------------------------------------------------
                            NVL(ec.QT_AGENDADA_CONFIRMADA,0) -  NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                                                AND ((1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW'))  

                        IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                        connect by regexp_substr(P_WEEKDAYS, '[^,]+', 1, level) is not null )
                                        ) 
                      
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0) QT_AGENDADA_CORTE , 
                        ---------------------------------------------------                           
                        CASE WHEN P_WEEKDAYS IS NOT NULL THEN      
                        NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        INNER JOIN VND.ELO_CARTEIRA CCC 
                        ON E_MAR.CD_ELO_CARTEIRA = CCC.CD_ELO_CARTEIRA
                        INNER JOIN CTE_AGENDAMENTO AGEND
                        ON AGEND.CD_ELO_AGENDAMENTO = CCC.CD_ELO_AGENDAMENTO 
                        
                        WHERE 
                        CCC.IC_ATIVO = 'S' AND CCC.CD_INCOTERMS = 'CIF'
                        AND CCC.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                        AND ((1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW'))  

                        IN (select regexp_substr(P_WEEKDAYS,'[^,]+', 1, level) from dual
                                        connect by regexp_substr(P_WEEKDAYS, '[^,]+', 1, level) is not null )
                                        )
                        
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)
                        ELSE   -- CASE P_WEEKDAYS
                        NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)  
                        
                        END  SOMA_MARCACAO,
                        --------------------------------------------
                        
                        NVL(P_VOLUME,0) P_VOLUMED, 
                        
                             
                       ((NVL((CASE WHEN ec.CD_TIPO_REPLAN = GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','INCLUSAO')
                             THEN ec.QT_SALDO END), 0) +
                       NVL((CASE WHEN ec.CD_TIPO_REPLAN = GX_ELO_COMMON.FX_ELO_STATUS('TIPRP','DIMREPLAN')
                             THEN ec.QT_SALDO END), 0)) +
                       NVL((CASE WHEN ec.CD_TIPO_AGENDAMENTO = GX_ELO_COMMON.FX_ELO_STATUS('TIPAG','REPLAN')
                             THEN ec.QT_SALDO END),0))                                                         
                             - 
                       NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        WHERE 
                        E_MAR.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.SG_CLASSIFICACAO = 'Replan')  ,0)   as SaldoReplanejado,
                             
                       NVL(eai.CD_COTA_COMPARTILHADA, 0)                                                        as CompartCota,
                            NVL(( SELECT SUM(AGEMAT.NU_QUANTIDADE) NU_QUANTIDADE 
                            FROM VND.ELO_CONTROLLERSHIP_MATINAL AGEMAT
--                            INNER JOIN VND.ELO_CARTEIRA CATE
--                            ON CATE.CD_ELO_CARTEIRA = AGEMAT.CD_ELO_CARTEIRA
                            INNER JOIN ELO_AG_DAY_BY_INCOTERMS_ITEM DD_DAY
                            ON DD_DAY.CD_ELO_AGENDAMENTO = AGEMAT.CD_ELO_AGENDAMENTO
                            AND DD_DAY.NU_DIA_SEMANA = AGEMAT.NU_DIA_SEMANA
                            AND DD_DAY.CD_GRUPO_EMBALAGEM = AGEMAT.CD_GRUPO_EMBALAGEM
                           -- WHERE CATE.CD_ELO_CARTEIRA = ec.CD_ELO_CARTEIRA
                           WHERE AGEMAT.CD_ELO_AGENDAMENTO = eai.CD_ELO_AGENDAMENTO
                           AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
                           AND DD_DAY.CD_CLIENTE = eai.CD_CLIENTE
                           AND DD_DAY.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                           AND DD_DAY.CD_INCOTERMS = eai.CD_INCOTERMS
                           AND DD_DAY.CD_INCOTERMS = 'CIF'
                           and DD_DAY.NU_DIA_SEMANA = eai.NU_DIA_SEMANA
                            
                            ),0) VOLUME_MAXIMO_CIF  ,
                            
                      NVL((SELECT SUM(E_MAR.NU_QUANTIDADE) NU_QUANTIDADE 
                        FROM VND.ELO_MARCACAO E_MAR
                        INNER JOIN VND.ELO_CARTEIRA CCC 
                        ON E_MAR.CD_ELO_CARTEIRA = CCC.CD_ELO_CARTEIRA
                        INNER JOIN CTE_AGENDAMENTO AGEND
                        ON AGEND.CD_ELO_AGENDAMENTO = CCC.CD_ELO_AGENDAMENTO 
                        
                        WHERE 
                        CCC.IC_ATIVO = 'S' AND CCC.CD_INCOTERMS = 'CIF'
                        AND CCC.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                        AND E_MAR.IC_DESISTENCIA = 'N' 
                        AND E_MAR.IC_DISPENSADO = 'N'
                        AND E_MAR.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                        AND E_MAR.CD_CLIENTE = ec.CD_CLIENTE
                        AND E_MAR.SG_CLASSIFICACAO = 'Plan')  ,0)  MARCADOS                          
                       
                       
                  from 
                  (
                    SELECT intec.CD_ELO_AGENDAMENTO, (intec.CD_ELO_CARTEIRA) CD_ELO_CARTEIRA , SUM(intec.QT_AGENDADA_CONFIRMADA) QT_AGENDADA_CONFIRMADA,
                    intec.CD_ELO_AGENDAMENTO_ITEM , intec.IC_ATIVO, --MIN(NVL(intec.IC_CORTADO_FABRICA, 0)) IC_CORTADO_FABRICA , 
                    intec.CD_INCOTERMS,
                    intec.CD_GRUPO_EMBALAGEM, SUM(intec.QT_SALDO) QT_SALDO,  intec.CD_CENTRO_EXPEDIDOR ,
                    intec.DS_CENTRO_EXPEDIDOR , 
                    intec.CD_CLIENTE  ,
                    intec.NO_CLIENTE , intec.CD_TIPO_AGENDAMENTO,
                    intec.CD_TIPO_REPLAN
                 
                  FROM CTE_CARTEIRA intec
                  INNER JOIN CTE_AGENDAMENTO CAGE
                  ON CAGE.CD_ELO_AGENDAMENTO = intec.CD_ELO_AGENDAMENTO
                  GROUP BY 
                    intec.CD_ELO_AGENDAMENTO, 
                    intec.IC_ATIVO, intec.CD_INCOTERMS,
                    intec.CD_GRUPO_EMBALAGEM,  intec.CD_CENTRO_EXPEDIDOR ,
                    intec.DS_CENTRO_EXPEDIDOR , 
                    intec.CD_CLIENTE  ,
                    intec.NO_CLIENTE ,
                    intec.CD_TIPO_AGENDAMENTO,
                    intec.CD_TIPO_REPLAN,
                    intec.CD_ELO_AGENDAMENTO_ITEM, intec.CD_ELO_CARTEIRA
                  ) ec
  

                 inner join CTE_AGENDAMENTO ag
                    on ag.CD_ELO_AGENDAMENTO = ec.CD_ELO_AGENDAMENTO
                 inner join ELO_AG_DAY_BY_INCOTERMS_ITEM eai
                    on ec.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                   -- AND ec.CD_GRUPO_EMBALAGEM = eai.CD_GRUPO_EMBALAGEM
                    AND ec.CD_CLIENTE = eai.CD_CLIENTE
                    AND ec.CD_INCOTERMS = 'CIF'
                    AND eai.CD_INCOTERMS = 'CIF'
                  
                INNER JOIN ELO_AG_DAY AGDY
                 ON eai.CD_ELO_AGENDAMENTO = AGDY.CD_ELO_AGENDAMENTO
                 AND eai.CD_GRUPO_EMBALAGEM = AGDY.CD_GRUPO_EMBALAGEM
                 AND eai.NU_DIA_SEMANA = AGDY.NU_DIA_SEMANA
                 AND eai.CD_CLIENTE = AGDY.CD_CLIENTE  
                 AND eai.CD_INCOTERMS = AGDY.CD_INCOTERMS
                 AND AGDY.CD_INCOTERMS = 'CIF'

                 where 
                    ec.IC_ATIVO = 'S'
                   
                   --and (NVL(ec.QT_AGENDADA_CONFIRMADA,0) <> 0 AND (ec.IC_CORTADO_FABRICA <> 1 OR ec.IC_CORTADO_FABRICA IS NULL))
                   and (P_NO_CLIENTE is null OR UPPER(ec.NO_CLIENTE) = UPPER(P_NO_CLIENTE))

                   and ((P_INCOTERM IS NULL AND ec.CD_INCOTERMS = 'CIF') OR (P_INCOTERM = 'CIF' AND ec.CD_INCOTERMS = 'CIF'))
                   and (P_PACKAGE is null OR ec.CD_GRUPO_EMBALAGEM = P_PACKAGE)
                   --and (P_VOLUME is null OR ec.QT_SALDO >= P_VOLUME)
        )
		WHERE P_WEEKDAYS IS NOT NULL
        
        group by CodeCenter,
                 DescriptionCenter,
                 CodeCustomer,
                 DescriptionCustomer,
                 CodeMachine,
                 DescriptionMachine,
                 DescriptionIncoterms,
                 DescriptionPackage,
                 SaldoReplanejado,
                 CompartCota--, 
                 --VOLUME_MAXIMO_CIF
        
        
        
        -------- this scenario is CIF--WEEKDAY IS NOT NULL---------------------------------
        
 
 ) G_TOTAL
                 
        order by CodeCustomer,
                 DescriptionCustomer;
                 
                 
                                                                
    END PX_SEARCH_NEWENTRY_OLD;
    
    PROCEDURE PX_SEARCH_DOCUMENT (
        P_CD_CARTEIRA           IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
        P_CD_CENTRO             IN VND.ELO_CARTEIRA.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_CLIENTE            IN VND.ELO_CARTEIRA.CD_CLIENTE%TYPE,
        P_DOCUMENT              IN VARCHAR2,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    BEGIN
    
        OPEN P_RETURN FOR
        
        select ec.CD_ELO_CARTEIRA,
               ec.CD_CENTRO_EXPEDIDOR,
               ec.CD_CLIENTE,
               ec.NU_CONTRATO          as PEDIDO,
               ec.NU_CONTRATO_SAP      as CONTRATO,
               ec.NU_ORDEM_VENDA       as ORDEM_VENDA
          from VND.ELO_CARTEIRA ec
         where IC_ATIVO = 'S'
         AND (ec.CD_ELO_CARTEIRA = P_CD_CARTEIRA)
           and (ec.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO)
           and (ec.CD_CLIENTE = lpad(P_CD_CLIENTE, 10, '0'))
           and (ec.NU_CONTRATO = P_DOCUMENT
            or  ec.NU_CONTRATO_SAP = P_DOCUMENT
            or  ec.NU_ORDEM_VENDA = P_DOCUMENT);
    
    END PX_SEARCH_DOCUMENT;
    
    PROCEDURE PI_CREATE_MARKING (
        P_CD_CARTEIRA           IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
        P_CD_CENTRO             IN VND.ELO_CARTEIRA.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_CLIENTE            IN VND.ELO_CARTEIRA.CD_CLIENTE%TYPE,
        P_NU_CONTRATO           IN VND.ELO_CARTEIRA.NU_CONTRATO%TYPE,
        P_NU_CONTRATO_SAP       IN VND.ELO_CARTEIRA.NU_CONTRATO_SAP%TYPE,
        P_NU_ORDEM_VENDA        IN VND.ELO_CARTEIRA.NU_ORDEM_VENDA%TYPE,
        
        P_CD_EMBALAGEM          IN VND.ELO_MARCACAO.CD_GRUPO_EMBALAGEM%TYPE DEFAULT NULL,
        P_CD_INCOTERMS          IN VND.ELO_MARCACAO.CD_INCOTERMS%TYPE DEFAULT NULL,
        P_CD_WEEK               IN VND.ELO_MARCACAO.CD_WEEK%TYPE DEFAULT NULL,
        
        P_RETURN                OUT T_CURSOR
    )
    
    IS
        V_VOLUME_INFORMADO VND.ELO_CARTEIRA.QT_SALDO%TYPE;
        V_NU_DIAS_SEMANA VARCHAR2(100);
        
    BEGIN
    
V_VOLUME_INFORMADO:=0;
V_NU_DIAS_SEMANA:='0';
    
    PI_CREATE_MARKING(
        P_CD_CARTEIRA ,
        P_CD_CENTRO   ,
        P_CD_CLIENTE   ,
        P_NU_CONTRATO   ,
        P_NU_CONTRATO_SAP   ,
        P_NU_ORDEM_VENDA,
        P_CD_EMBALAGEM ,
        P_CD_INCOTERMS  ,
        P_CD_WEEK  ,
        V_VOLUME_INFORMADO,
        V_NU_DIAS_SEMANA,
         
        P_RETURN  );
    
    
    END PI_CREATE_MARKING;
    
    
    
    PROCEDURE PI_CREATE_MARKING (
        P_CD_CARTEIRA           IN VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
        P_CD_CENTRO             IN VND.ELO_CARTEIRA.CD_CENTRO_EXPEDIDOR%TYPE,
        P_CD_CLIENTE            IN VND.ELO_CARTEIRA.CD_CLIENTE%TYPE,
        P_NU_CONTRATO           IN VND.ELO_CARTEIRA.NU_CONTRATO%TYPE,
        P_NU_CONTRATO_SAP       IN VND.ELO_CARTEIRA.NU_CONTRATO_SAP%TYPE,
        P_NU_ORDEM_VENDA        IN VND.ELO_CARTEIRA.NU_ORDEM_VENDA%TYPE,
        
        P_CD_EMBALAGEM          IN VND.ELO_MARCACAO.CD_GRUPO_EMBALAGEM%TYPE DEFAULT NULL,
        P_CD_INCOTERMS          IN VND.ELO_MARCACAO.CD_INCOTERMS%TYPE DEFAULT NULL,
        P_CD_WEEK               IN VND.ELO_MARCACAO.CD_WEEK%TYPE DEFAULT NULL,
        P_VOLUME_INFORMADO      IN VND.ELO_CARTEIRA.QT_SALDO%TYPE DEFAULT 0,
        p_MULTI_NU_DIAS_SEMANA  VARCHAR2,
        
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    
        V_CD_ELO_MARCACAO           VND.ELO_MARCACAO.CD_ELO_MARCACAO%TYPE;
        V_QT_SALDO                  VND.ELO_CARTEIRA.QT_SALDO%TYPE;
        V_CLASSIFICACAO             VND.ELO_STATUS.DS_STATUS%TYPE;
        
        V_DS_CENTRO                 VND.ELO_MARCACAO.DS_CENTRO_EXPEDIDOR%TYPE;
        V_CD_CENTRO_EXPEDIDOR       VND.ELO_MARCACAO.CD_CENTRO_EXPEDIDOR%TYPE;
        V_DS_CLIENTE                VND.ELO_MARCACAO.NO_CLIENTE%TYPE;
        V_QT_AGENDADA_PLAN          VND.ELO_CARTEIRA.QT_AGENDADA%TYPE;
        V_QT_AGENDADA_REPLAN        VND.ELO_CARTEIRA.QT_AGENDADA%TYPE; 
        V_CD_INCOTERMS              VND.ELO_CARTEIRA.CD_INCOTERMS%TYPE; 
        V_VOLUME_MAXIMO_MATINAL     VND.ELO_CARTEIRA.QT_SALDO%TYPE;
        V_VOLUME_MAXIMO             VND.ELO_CARTEIRA.QT_SALDO%TYPE;
        V_RESULT                    T_CURSOR;
        V_CD_MACHINE                VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE;
        V_CD_GRUPO_EMBALAGEM        VND.GRUPO_EMBALAGEM.CD_GRUPO_EMBALAGEM%TYPE;
        V_CD_CLIENTE                VND.ELO_CARTEIRA.CD_CLIENTE%TYPE;
        V_CD_GRUPO_EMBALAGEM_FIX  VND.GRUPO_EMBALAGEM.CD_GRUPO_EMBALAGEM%TYPE;
        
        --RECORDING 
        
        CODECARTEIRA VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE;
        CODECENTER VND.ELO_CARTEIRA.CD_CENTRO_EXPEDIDOR%TYPE;
        DESCRIPTIONCENTER VND.ELO_CARTEIRA.DS_CENTRO_EXPEDIDOR%TYPE;
        CODECUSTOMER VND.ELO_CARTEIRA.CD_CLIENTE%TYPE;
        DESCRIPTIONCUSTOMER VND.ELO_CARTEIRA.NO_CLIENTE%TYPE;
        CODEMACHINE VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE;
        DESCRIPTIONMACHINE CTF.MACHINE.DS_MACHINE%TYPE;
        DESCRIPTIONINCOTERMS VND.ELO_CARTEIRA.CD_INCOTERMS%TYPE;
        DESCRIPTIONPACKAGE   VND.GRUPO_EMBALAGEM.DS_GRUPO_EMBALAGEM%TYPE;
        SALDOPLANEJADO VND.ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA%TYPE;
        SALDOREPLANEJADO VND.ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA%TYPE;
        COMPARTCOTA VND.ELO_AGENDAMENTO_ITEM.CD_COTA_COMPARTILHADA%TYPE;
        VOLUME_MAXIMO VND.ELO_CARTEIRA.QT_AGENDADA_CONFIRMADA%TYPE;
        
        /*  BLOCO ELO_MARCACAO_HIST */
        

        G_APP_ID VND.ELO_MARCACAO_HIST.APP_ID%TYPE;--VARCHAR2(10 BYTE),
        G_SEQ_CRIACAO VND.ELO_MARCACAO_HIST.SEQ_CRIACAO%TYPE;--NUMBER(15,0), 
        G_DH_MODIFICACAO VND.ELO_MARCACAO_HIST.DH_MODIFICACAO%TYPE;--DATE DEFAULT CURRENT_DATE,
        G_DS_PARAMETROS_MARCACAO VND.ELO_MARCACAO_HIST.DS_PARAMETROS_MARCACAO%TYPE;--VARCHAR2(4000),
        G_DS_RETURN_NEWENTRY VND.ELO_MARCACAO_HIST.DS_RETURN_NEWENTRY%TYPE; --VARCHAR2(4000),
        G_DS_RESERVADO_01 VND.ELO_MARCACAO_HIST.DS_RESERVADO_01%TYPE;--VARCHAR2(100)
        
        /*  BLOCO ELO_MARCACAO_HIST */
        
    BEGIN
             
        
        V_CD_GRUPO_EMBALAGEM_FIX:= 
        CASE    
            WHEN P_CD_EMBALAGEM = 'TODOS' THEN '0'
            WHEN P_CD_EMBALAGEM = '0' THEN '0'
            WHEN P_CD_EMBALAGEM = NULL THEN '0'
            WHEN UPPER(P_CD_EMBALAGEM) = 'E' THEN 'S'
            WHEN LENGTH(P_CD_EMBALAGEM) > 1 THEN SUBSTR(UPPER(P_CD_EMBALAGEM), 1, 1)
            ELSE UPPER(P_CD_EMBALAGEM) END;
            
      BEGIN
      
        G_APP_ID:='GXE_CSICM' ;--VARCHAR2(10 BYTE),
        G_SEQ_CRIACAO:=1 ;--NUMBER(15,0), 
        G_DH_MODIFICACAO:=CURRENT_DATE ;--DATE DEFAULT CURRENT_DATE,
        G_DS_PARAMETROS_MARCACAO:= 'CD_ELO_CARTEIRA:' || TO_CHAR( P_CD_CARTEIRA) || 'CD_CENTRO_EXPEDIDOR:'||  P_CD_CENTRO ;
        G_DS_PARAMETROS_MARCACAO:= G_DS_PARAMETROS_MARCACAO || 'CD_CLIENTE:' || P_CD_CLIENTE || 'CD_GRUPO_EMBALAGEM:' || P_CD_EMBALAGEM ;
        G_DS_PARAMETROS_MARCACAO:= G_DS_PARAMETROS_MARCACAO || 'CD_INCOTERMS:' || P_CD_INCOTERMS || 'CD_WEEK:' || P_CD_WEEK ;
        G_DS_PARAMETROS_MARCACAO:= G_DS_PARAMETROS_MARCACAO || 'VOLUME_INFORMADO:' || P_VOLUME_INFORMADO || 'P_MULTI_NU_DIAS_SEMANA:' || p_MULTI_NU_DIAS_SEMANA ;

        G_DS_RETURN_NEWENTRY:='' ; --VARCHAR2(4000),
        G_DS_RESERVADO_01:='';--VARCHAR2(100)
      
      
      END;
            
            
        IF P_CD_CENTRO is null or P_CD_WEEK is null or P_CD_EMBALAGEM is null or P_CD_INCOTERMS is null THEN
        
        BEGIN 
        
            RAISE_APPLICATION_ERROR(
            -20002,
            'ERRO Parametros Obrigatórios - Centro Expedidor:'
            || NVL(P_CD_CENTRO, '-') || ' Semana: ' || nvl(P_CD_WEEK, '-') 
            || ' Embalagem: ' || nvl(P_CD_EMBALAGEM, '-') || ' Incoterms: ' || nvl(P_CD_INCOTERMS, '-') 
            );
        
        END;
        END IF;
            
        
        IF P_CD_CARTEIRA is not null THEN
             
       BEGIN     
       
               
            V_QT_SALDO:=0;
            V_QT_AGENDADA_PLAN:=0;
            V_QT_AGENDADA_REPLAN:=0;
        
            
            
            
        
            BEGIN
            
        WITH  CTE_EMB_INCOTERMS_DIA AS 
        (
        SELECT 
        EEID.CD_INCOTERMS,
        EEID.CD_GRUPO_EMBALAGEM,
        EEID.NU_DIA_SEMANA
        FROM ELO_EMBALAGEM_INCOTERMS EEID
        WHERE 
        (EEID.NU_DIA_SEMANA IN (select regexp_substr(p_MULTI_NU_DIAS_SEMANA,'[^,]+', 1, level) from dual
                                connect by regexp_substr(p_MULTI_NU_DIAS_SEMANA, '[^,]+', 1, level) is not null )
                                         OR p_MULTI_NU_DIAS_SEMANA IS NULL)
        
        AND ((NVL(V_CD_GRUPO_EMBALAGEM_FIX, '0') = '0') OR (EEID.CD_GRUPO_EMBALAGEM  = V_CD_GRUPO_EMBALAGEM_FIX))                                  

                                         
        )
            SELECT AGE.CD_MACHINE, NVL(AGE.CD_CENTRO_EXPEDIDOR, CT.CD_CENTRO_EXPEDIDOR), CT.CD_CLIENTE,
            CT.NO_CLIENTE , CT.CD_INCOTERMS,
            NVL((SELECT DAYY.CD_GRUPO_EMBALAGEM 
                FROM VND.ELO_AGENDAMENTO_WEEK EAG_WE_I
                INNER JOIN VND.ELO_AGENDAMENTO_ITEM eai
                on EAG_WE_I.CD_ELO_AGENDAMENTO_ITEM = eai.CD_ELO_AGENDAMENTO_ITEM
                --LEFT JOIN VND.ELO_AGENDAMENTO_GROUPING EAG_GRO_I
                --ON EAG_GRO_I.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK
                INNER JOIN VND.ELO_AGENDAMENTO_DAY DAYY
                ON 
                DAYY.CD_ELO_AGENDAMENTO_WEEK = EAG_WE_I.CD_ELO_AGENDAMENTO_WEEK

                WHERE 
                EAG_WE_I.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM
                     AND EXISTS (SELECT 1 
                    FROM CTE_EMB_INCOTERMS_DIA FIL_DIA
                    WHERE 
                    FIL_DIA.CD_GRUPO_EMBALAGEM = DAYY.CD_GRUPO_EMBALAGEM
                    AND FIL_DIA.CD_INCOTERMS = eai.CD_INCOTERMS
                    AND FIL_DIA.NU_DIA_SEMANA =  DAYY.NU_DIA_SEMANA
                    )
                
                
                AND ROWNUM =1 ), V_CD_GRUPO_EMBALAGEM_FIX) CD_GRUPO_EMBALAGEM
            
            INTO V_CD_MACHINE, V_CD_CENTRO_EXPEDIDOR,V_CD_CLIENTE, V_DS_CLIENTE, V_CD_INCOTERMS, V_CD_GRUPO_EMBALAGEM
            FROM VND.ELO_AGENDAMENTO AGE
            INNER JOIN VND.ELO_CARTEIRA CT
            ON AGE.CD_ELO_AGENDAMENTO = CT.CD_ELO_AGENDAMENTO 
            WHERE 
            CT.CD_ELO_CARTEIRA = P_CD_CARTEIRA;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN 
            BEGIN
            V_CD_MACHINE:=NULL;
            V_CD_CENTRO_EXPEDIDOR:=NULL;
            V_DS_CLIENTE:=NULL;
            V_CD_INCOTERMS:=null;
            V_CD_CLIENTE:=NULL;
            END;
            WHEN OTHERS THEN 
            V_CD_MACHINE:=NULL;
            V_CD_CENTRO_EXPEDIDOR:=NULL;
            V_DS_CLIENTE:=NULL;
            V_CD_INCOTERMS:=null;
            V_CD_CLIENTE:=NULL;
            END;
        
            V_CD_GRUPO_EMBALAGEM:= CASE WHEN NVL( P_CD_EMBALAGEM, '0') = '0' THEN V_CD_GRUPO_EMBALAGEM ELSE P_CD_EMBALAGEM END ;
            V_CD_GRUPO_EMBALAGEM:= CASE WHEN NVL( V_CD_GRUPO_EMBALAGEM, 'TODOS') = 'TODOS' THEN 'B' ELSE P_CD_EMBALAGEM END ;
            V_CD_CENTRO_EXPEDIDOR:= CASE WHEN NVL( P_CD_CENTRO, '0') = '0' THEN V_CD_CENTRO_EXPEDIDOR ELSE P_CD_CENTRO END  ;
            V_CD_INCOTERMS:= CASE WHEN NVL(P_CD_INCOTERMS, '0') = '0' THEN V_CD_INCOTERMS ELSE P_CD_INCOTERMS END ;
            
                
            BEGIN         
            PX_SEARCH_NEWENTRY (
            V_CD_CENTRO_EXPEDIDOR         ,  --OK
            P_CD_WEEK               ,  --0K
            V_DS_CLIENTE            ,  --OK
            V_CD_MACHINE            ,  --OK
            V_CD_INCOTERMS          ,  --OK
            V_CD_GRUPO_EMBALAGEM   ,  --OK
            P_VOLUME_INFORMADO      ,  --OK
            p_MULTI_NU_DIAS_SEMANA  ,  --OK
            V_RESULT                    --OK
            ) ;
            
            EXCEPTION 
            WHEN OTHERS THEN 
            RAISE_APPLICATION_ERROR(
            -20001,
            'ERRO ENCONTRAPXSEARCHNEWENTRY - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM
            );
            
            END; 
 
        LOOP
   
            FETCH V_RESULT 
            INTO CODECARTEIRA, CODECENTER, DESCRIPTIONCENTER, CODECUSTOMER, DESCRIPTIONCUSTOMER, 
            CODEMACHINE,DESCRIPTIONMACHINE, DESCRIPTIONINCOTERMS, DESCRIPTIONPACKAGE,
            SALDOPLANEJADO, SALDOREPLANEJADO,COMPARTCOTA, VOLUME_MAXIMO;
        
            EXIT WHEN CODECARTEIRA = P_CD_CARTEIRA;
        
            EXIT WHEN V_RESULT%NOTFOUND;
    
            END LOOP;
    
        CLOSE V_RESULT;
        
        G_DS_RETURN_NEWENTRY:= 'CD_ELO_CARTEIRA:' || TO_CHAR( CODECARTEIRA) || 'CD_CENTRO_EXPEDIDOR:'||  CODECENTER ;
        G_DS_RETURN_NEWENTRY:= G_DS_RETURN_NEWENTRY || 'CD_CLIENTE:' || CODECUSTOMER || 'CD_GRUPO_EMBALAGEM:' || DESCRIPTIONPACKAGE ;
        G_DS_RETURN_NEWENTRY:= G_DS_RETURN_NEWENTRY || 'CD_INCOTERMS:' || DESCRIPTIONINCOTERMS || 'CD_WEEK:' || P_CD_WEEK ;
        G_DS_RETURN_NEWENTRY:= G_DS_RETURN_NEWENTRY || 'SALDOPLANEJADO:' || TO_CHAR(SALDOPLANEJADO) || 'SALDOREPLANEJADO:' || TO_CHAR(SALDOREPLANEJADO) ;
 
 
 
      
            IF SALDOPLANEJADO > 0 THEN 
            
                
                    V_VOLUME_MAXIMO_MATINAL:= SALDOPLANEJADO;
      
            
                IF NVL(P_VOLUME_INFORMADO, 0)  > NVL(V_VOLUME_MAXIMO_MATINAL, 0) THEN 
                    V_QT_SALDO:= V_VOLUME_MAXIMO_MATINAL;
                ELSIF  P_VOLUME_INFORMADO IS NULL THEN 
                    V_QT_SALDO:=SALDOPLANEJADO;
                ELSE    
                    V_QT_SALDO:=P_VOLUME_INFORMADO;
                END IF;
            
                V_CLASSIFICACAO:='Plan';
                
            ELSE 
                IF SALDOREPLANEJADO > 0 THEN 
                
                  
                        V_VOLUME_MAXIMO_MATINAL:=SALDOREPLANEJADO;
            
                    
                
                    IF NVL(P_VOLUME_INFORMADO, 0)  > NVL(V_VOLUME_MAXIMO_MATINAL, 0) THEN 
                        V_QT_SALDO:= V_VOLUME_MAXIMO_MATINAL;
                    ELSIF  P_VOLUME_INFORMADO IS NULL THEN 
                        V_QT_SALDO:=SALDOREPLANEJADO;
                    ELSE    
                        V_QT_SALDO:=P_VOLUME_INFORMADO;
                    END IF;                
 
                    V_CLASSIFICACAO:='Replan';
                    
                ELSE
                    V_CLASSIFICACAO:='Sem cota';
                    V_QT_SALDO:=NVL(P_VOLUME_INFORMADO,0);
                END IF;
            END IF;
  
            
            INSERT INTO VND.ELO_MARCACAO (CD_ELO_MARCACAO, 
                                      CD_ELO_CARTEIRA, 
                                      NU_ORDEM_VENDA,
                                      NU_PROTOCOLO_ENTREGA,
                                      CD_TRANSPORTADORA,
                                      NU_QUANTIDADE,
                                      SG_CLASSIFICACAO,
                                      DH_ENTRADA,
                                      CD_ELO_STATUS,
                                      CD_MOTIVO_STATUS,
                                      IC_DESISTENCIA,
                                      IC_DISPENSADO,
                                      DH_DISPENSA,
                                      DS_MOTIVO_DISPENSA,
                                      DH_MARCACAO,
                                      DS_SENHA,
                                      DH_PRODUCAO,
                                      NU_ORDEM_PRODUCAO,
                                      DS_OBSERVACAO_ORDEM_PRODUCAO,
                                      DH_SAIDA,        
                                      DS_PLACA_CAMINHAO,
                                      IC_PRIORIDADE,
                                      DS_OBSERVACAO,
                                      IT_TMAC_CLIENTE,
                                      IT_TMAC_MOSAIC,
                                      IT_TMAC_PRODUCAO,
                                      IT_TMAC_ADMINISTRATIVO,
                                      DH_FATURAMENTO,
                                      NU_NOTA_FISCAL,
                                      NU_SERIE,
                                      IC_ATIVO,
                                      QT_FATURADO,
                                      CD_CENTRO_EXPEDIDOR,
                                      CD_CLIENTE,
                                      NO_CLIENTE,
                                      CD_GRUPO_EMBALAGEM,
                                      CD_INCOTERMS,
                                      CD_WEEK)
             VALUES (SEQ_ELO_MARCACAO.NEXTVAL, 
                     P_CD_CARTEIRA,
                     P_NU_ORDEM_VENDA,
                     '',
                     '',
                     NVL(V_QT_SALDO, 0),
                     NVL(V_CLASSIFICACAO, 'Sem cota'),
                     '',
                     GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MANAO'), 
                     '',
                     'N',
                     'N',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     'N',
                     V_CLASSIFICACAO  || 'SP:' || TO_CHAR(SALDOPLANEJADO) || 'SR:' ||  TO_CHAR(SALDOREPLANEJADO),  --OBSERVACAO
                     '', 
                     '',
                     '',
                     '',
                     '',
                     null,
                     '',
                     'S',
                     '',
                     V_CD_CENTRO_EXPEDIDOR,
                     NVL(LPAD(CODECUSTOMER, 10, '0'), LPAD(P_CD_CLIENTE, 10, '0')),
                     V_DS_CLIENTE,
                     NVL(V_CD_GRUPO_EMBALAGEM, P_CD_EMBALAGEM),
                     V_CD_INCOTERMS,
                     P_CD_WEEK) RETURNING CD_ELO_MARCACAO INTO V_CD_ELO_MARCACAO;
                     COMMIT;
                     
                     BEGIN
                     
                        INSERT INTO VND.ELO_MARCACAO_HIST (CD_ELO_MARCACAO, 
                          CD_ELO_CARTEIRA, 
                          NU_ORDEM_VENDA,
                          NU_PROTOCOLO_ENTREGA,
                          CD_TRANSPORTADORA,
                          NU_QUANTIDADE,
                          SG_CLASSIFICACAO,
                          DH_ENTRADA,
                          CD_ELO_STATUS,
                          CD_MOTIVO_STATUS,
                          IC_DESISTENCIA,
                          IC_DISPENSADO,
                          DH_DISPENSA,
                          DS_MOTIVO_DISPENSA,
                          DH_MARCACAO,
                          DS_SENHA,
                          DH_PRODUCAO,
                          NU_ORDEM_PRODUCAO,
                          DS_OBSERVACAO_ORDEM_PRODUCAO,
                          DH_SAIDA,        
                          DS_PLACA_CAMINHAO,
                          IC_PRIORIDADE,
                          DS_OBSERVACAO,
                          IT_TMAC_CLIENTE,
                          IT_TMAC_MOSAIC,
                          IT_TMAC_PRODUCAO,
                          IT_TMAC_ADMINISTRATIVO,
                          DH_FATURAMENTO,
                          NU_NOTA_FISCAL,
                          NU_SERIE,
                          IC_ATIVO,
                          QT_FATURADO,
                          CD_CENTRO_EXPEDIDOR,
                          CD_CLIENTE,
                          NO_CLIENTE,
                          CD_GRUPO_EMBALAGEM,
                          CD_INCOTERMS,
                          CD_WEEK,
                        APP_ID, --VARCHAR2(10 BYTE),
                        SEQ_CRIACAO, --NUMBER(15,0), 
                        DH_MODIFICACAO ,--DATE DEFAULT CURRENT_DATE,
                        DS_PARAMETROS_MARCACAO, --VARCHAR2(4000),
                        DS_RETURN_NEWENTRY, --VARCHAR2(4000),
                        DS_RESERVADO_01--VARCHAR2(100)
                          )
                    VALUES (V_CD_ELO_MARCACAO, 
                     P_CD_CARTEIRA,
                     P_NU_ORDEM_VENDA,
                     '',
                     '',
                     NVL(V_QT_SALDO, 0),
                     NVL(V_CLASSIFICACAO, 'Sem cota'),
                     '',
                     GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MANAO'), 
                     '',
                     'N',
                     'N',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     'N',
                     V_CLASSIFICACAO  || 'SP:' || TO_CHAR(SALDOPLANEJADO) || 'SR:' ||  TO_CHAR(SALDOREPLANEJADO),  --OBSERVACAO
                     '', 
                     '',
                     '',
                     '',
                     '',
                     null,
                     '',
                     'S',
                     '',
                     V_CD_CENTRO_EXPEDIDOR,
                     NVL(LPAD(CODECUSTOMER, 10, '0'), LPAD(P_CD_CLIENTE, 10, '0')),
                     V_DS_CLIENTE,
                     NVL(V_CD_GRUPO_EMBALAGEM, P_CD_EMBALAGEM),
                     V_CD_INCOTERMS,
                     P_CD_WEEK,
                    G_APP_ID, --VARCHAR2(10 BYTE),
                    G_SEQ_CRIACAO, --NUMBER(15,0), 
                    CURRENT_DATE, --DH_MODIFICACAO ,--DATE DEFAULT CURRENT_DATE,
                    G_DS_PARAMETROS_MARCACAO, --VARCHAR2(4000),
                    G_DS_RETURN_NEWENTRY || 'V_CD_GRUPO_EMBALAGEM_FIX:' || V_CD_GRUPO_EMBALAGEM_FIX || 'V_CD_GRUPO_EMBALAGEM:' || V_CD_GRUPO_EMBALAGEM, --G_DS_RETURN_NEWENTRY, --VARCHAR2(4000),
                    G_DS_RESERVADO_01--VARCHAR2(100)
                     
                     ) ;
                     COMMIT;
                     
                     
                     END;
                     
        
        END;             
        ELSE
        
        BEGIN 
        
        V_CD_GRUPO_EMBALAGEM:= CASE WHEN NVL( P_CD_EMBALAGEM, 'TODOS') = 'TODOS' THEN 'B' ELSE P_CD_EMBALAGEM END ;
        V_CD_GRUPO_EMBALAGEM:= CASE WHEN NVL( V_CD_GRUPO_EMBALAGEM, '0') = '0' THEN 'B' ELSE V_CD_GRUPO_EMBALAGEM END ;
        V_CD_CENTRO_EXPEDIDOR:= CASE WHEN NVL( P_CD_CENTRO, '0') = '0' THEN V_CD_CENTRO_EXPEDIDOR ELSE P_CD_CENTRO END  ;
        
        
        BEGIN
            select ce.DS_CENTRO_EXPEDIDOR
              into V_DS_CENTRO
              from CTF.CENTRO_EXPEDIDOR ce
             where ce.CD_CENTRO_EXPEDIDOR = V_CD_CENTRO_EXPEDIDOR;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        V_DS_CENTRO:=NULL;
        WHEN OTHERS THEN 
        V_DS_CENTRO:=NULL;
        END;      
             
      
        BEGIN
            select distinct
                   ec.NO_CLIENTE
              into V_DS_CLIENTE
              from VND.ELO_CARTEIRA ec
             where ec.CD_CLIENTE = NVL(LPAD(CODECUSTOMER, 10, '0'), LPAD(P_CD_CLIENTE, 10, '0'))
             and ec.NO_CLIENTE is NOT NULL 

             AND ROWNUM=1;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        V_DS_CLIENTE:=NULL;
        WHEN OTHERS THEN 
        V_DS_CLIENTE:=NULL;
        END;
        
    
            INSERT INTO VND.ELO_MARCACAO (CD_ELO_MARCACAO, 
                                          SG_CLASSIFICACAO,
                                          CD_ELO_STATUS,
                                          IC_DESISTENCIA,
                                          IC_DISPENSADO,
                                          IC_PRIORIDADE,
                                          IC_ATIVO,
                                          CD_CENTRO_EXPEDIDOR,
                                          DS_CENTRO_EXPEDIDOR,
                                          CD_CLIENTE,
                                          NO_CLIENTE,         
                                          CD_GRUPO_EMBALAGEM,
                                          CD_INCOTERMS,
                                          CD_CLIENTE_RECEBEDOR,
                                          CD_SALES_GROUP,
                                          CD_PRODUTO_SAP,
                                          NU_QUANTIDADE ,
                                          CD_WEEK)
             VALUES (SEQ_ELO_MARCACAO.NEXTVAL, 
                     'Sem cota',
                     GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MACOT'), 
                     'N',
                     'N',
                     'N',
                     'S',
                     V_CD_CENTRO_EXPEDIDOR,
                     V_DS_CENTRO,
                     NVL(CODECUSTOMER, P_CD_CLIENTE),
                     V_DS_CLIENTE,
                     NVL(V_CD_GRUPO_EMBALAGEM, P_CD_EMBALAGEM),
                     NVL(V_CD_INCOTERMS, P_CD_INCOTERMS),
                     '0',
                     '0',
                     '0',
                     P_VOLUME_INFORMADO,                    

                     P_CD_WEEK) RETURNING CD_ELO_MARCACAO INTO V_CD_ELO_MARCACAO;
                     COMMIT;
                     
            BEGIN
            INSERT INTO VND.ELO_MARCACAO_HIST (CD_ELO_MARCACAO, 
                                          SG_CLASSIFICACAO,
                                          CD_ELO_STATUS,
                                          IC_DESISTENCIA,
                                          IC_DISPENSADO,
                                          IC_PRIORIDADE,
                                          IC_ATIVO,
                                          CD_CENTRO_EXPEDIDOR,
                                          DS_CENTRO_EXPEDIDOR,
                                          CD_CLIENTE,
                                          NO_CLIENTE,         
                                          CD_GRUPO_EMBALAGEM,
                                          CD_INCOTERMS,
                                          CD_CLIENTE_RECEBEDOR,
                                          CD_SALES_GROUP,
                                          CD_PRODUTO_SAP,
                                          NU_QUANTIDADE ,
                                          CD_WEEK,
                                        APP_ID, --VARCHAR2(10 BYTE),
                                        SEQ_CRIACAO, --NUMBER(15,0), 
                                        DH_MODIFICACAO ,--DATE DEFAULT CURRENT_DATE,
                                        DS_PARAMETROS_MARCACAO, --VARCHAR2(4000),
                                        DS_RETURN_NEWENTRY, --VARCHAR2(4000),
                                        DS_RESERVADO_01--VARCHAR2(100)
                                          
                                          
                                          )
             VALUES (V_CD_ELO_MARCACAO, 
                     'Sem cota',
                     GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MACOT'), 
                     'N',
                     'N',
                     'N',
                     'S',
                     V_CD_CENTRO_EXPEDIDOR,
                     V_DS_CENTRO,
                     NVL(CODECUSTOMER, P_CD_CLIENTE),
                     V_DS_CLIENTE,
                     NVL(V_CD_GRUPO_EMBALAGEM, P_CD_EMBALAGEM),
                     NVL(V_CD_INCOTERMS, P_CD_INCOTERMS),
                     '0',
                     '0',
                     '0',
                     P_VOLUME_INFORMADO,                    

                     P_CD_WEEK,
                    G_APP_ID, --VARCHAR2(10 BYTE),
                    G_SEQ_CRIACAO, --NUMBER(15,0), 
                    CURRENT_DATE, --DH_MODIFICACAO ,--DATE DEFAULT CURRENT_DATE,
                    G_DS_PARAMETROS_MARCACAO, --VARCHAR2(4000),
                    'SEM_CARTEIRA_SEM_COTA', --G_DS_RETURN_NEWENTRY, --VARCHAR2(4000),
                    G_DS_RESERVADO_01--VARCHAR2(100)
                     
                     
                     ) ;
                     COMMIT;                     
             END;        
                     
        
        END;           
        END IF;
                     
        OPEN P_RETURN FOR
            SELECT V_CD_ELO_MARCACAO AS CD_ELO_MARCACAO FROM DUAL;
         
    /*
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'ERRO ENCONTRADO - '
                     || SQLCODE
                     || ' -ERROR- '
                     || SQLERRM
                );
                ROLLBACK;
            END;
            */
    
    END PI_CREATE_MARKING;
    
    PROCEDURE PU_UPDATE_MARKING (
        P_CD_MARCACAO           IN VND.ELO_MARCACAO.CD_ELO_MARCACAO%TYPE DEFAULT NULL,
        P_CD_EMBALAGEM          IN VND.ELO_MARCACAO.CD_GRUPO_EMBALAGEM%TYPE DEFAULT NULL,
        P_INCOTERMS             IN VND.ELO_MARCACAO.CD_INCOTERMS%TYPE DEFAULT NULL,
        P_NU_QUANTIDADE         IN VND.ELO_MARCACAO.NU_QUANTIDADE%TYPE DEFAULT NULL,
        P_DH_ENTRADA            IN VARCHAR2 DEFAULT NULL,
        P_CD_STATUS             IN VND.ELO_MARCACAO.CD_ELO_STATUS%TYPE DEFAULT NULL,
        P_CD_MOTIVO             IN VND.ELO_MARCACAO.CD_MOTIVO_STATUS%TYPE DEFAULT NULL,
        P_DESISTENCIA           IN VND.ELO_MARCACAO.IC_DESISTENCIA%TYPE DEFAULT NULL,
        P_DISPENSADO            IN VND.ELO_MARCACAO.IC_DISPENSADO%TYPE DEFAULT NULL,
        P_DH_DISPENSA           IN VARCHAR2 DEFAULT NULL,
        P_DS_MOTIVO_DISPENSA    IN VND.ELO_MARCACAO.DS_MOTIVO_DISPENSA%TYPE DEFAULT NULL,
        P_DH_MARCACAO           IN VARCHAR2 DEFAULT NULL,
        P_DS_SENHA              IN VND.ELO_MARCACAO.DS_SENHA%TYPE DEFAULT NULL,
        P_DH_PRODUCAO           IN VARCHAR2 DEFAULT NULL,
        P_NU_ORDEM_PRODUCAO     IN VND.ELO_MARCACAO.NU_ORDEM_PRODUCAO%TYPE DEFAULT NULL,
        P_DH_SAIDA              IN VARCHAR2 DEFAULT NULL,
        P_PRIORIDADE            IN VND.ELO_MARCACAO.IC_PRIORIDADE%TYPE DEFAULT NULL,
        P_RECEBEDOR             IN VND.ELO_MARCACAO.CD_CLIENTE_RECEBEDOR%TYPE DEFAULT NULL,
        P_SUPERVISOR            IN VND.ELO_MARCACAO.CD_SALES_GROUP%TYPE DEFAULT NULL,
        P_MATERIAL              IN VND.ELO_MARCACAO.CD_PRODUTO_SAP%TYPE DEFAULT NULL,
        P_DS_PLACA              IN VND.ELO_MARCACAO.DS_PLACA_CAMINHAO%TYPE DEFAULT NULL,
        P_DS_OBSERVACAO         IN VND.ELO_MARCACAO.DS_OBSERVACAO%TYPE DEFAULT NULL,
        P_TIPO_ORDEM            IN VARCHAR2 DEFAULT NULL,
        P_DH_FATURAMENTO        IN VARCHAR2 DEFAULT NULL,
        P_NF                    IN VND.ELO_MARCACAO.NU_NOTA_FISCAL%TYPE DEFAULT NULL,
        P_QT_FATURADO           IN VND.ELO_MARCACAO.QT_FATURADO%TYPE DEFAULT NULL,
        P_CD_TRANSPORTADORA     IN VND.ELO_MARCACAO.CD_TRANSPORTADORA%TYPE DEFAULT NULL,
        P_PO                    IN VARCHAR2 DEFAULT NULL,
        P_FORNECIMENTO          IN VARCHAR2 DEFAULT NULL,
        P_SEQUENCIA             IN VARCHAR2 DEFAULT NULL,
        P_OBS_PRODUCAO          IN VND.ELO_MARCACAO.DS_OBSERVACAO_ORDEM_PRODUCAO%TYPE DEFAULT NULL,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
 
    V_TMAC_CLIENTE      INTERVAL DAY(3) TO SECOND(6);
    V_TMAC_MOSAIC       INTERVAL DAY(3) TO SECOND(6);
    V_TMAC_PRODUCAO     INTERVAL DAY(3) TO SECOND(6);
    V_TMAC_ADMIN        INTERVAL DAY(3) TO SECOND(6);
    
    V_STATUS            NUMBER(9);
 
    BEGIN
        
        -- TMACCliente
        -- Plant exit date and time minus Plant arrival date and time
        IF (P_DH_SAIDA is not null AND P_DH_ENTRADA is not null) THEN
            select NUMTODSINTERVAL(24 * (ma.DH_SAIDA - ma.DH_ENTRADA), 'hour')
              into V_TMAC_CLIENTE
              from VND.ELO_MARCACAO ma
             where ma.CD_ELO_MARCACAO = P_CD_MARCACAO;
        END IF;
        
       -- TMACMosaic
       -- (Plant exit date and time minus Appointment date and time) - Plant and Administrative eficiency
       IF (P_DH_SAIDA is not null AND P_DH_MARCACAO is not null) THEN
           select NUMTODSINTERVAL(24 * (to_date(to_char(ma.DH_SAIDA, 'YYYY-MM-DD hh24:mi'), 'YYYY-MM-DD hh24:mi') - 
                        to_date(to_char(ma.DH_MARCACAO, 'YYYY-MM-DD hh24:mi'), 'YYYY-MM-DD hh24:mi')), 'hour')
              into V_TMAC_MOSAIC
              from VND.ELO_MARCACAO ma
             where ma.CD_ELO_MARCACAO = P_CD_MARCACAO;
       END IF;
       
       -- TMACProducao
       -- Production TMAC (Plant exit date and time minus column Production Order date and time) - Plant efficiency
       IF (P_DH_SAIDA is not null AND P_DH_PRODUCAO is not null) THEN
           select NUMTODSINTERVAL(24 * (to_date(to_char(ma.DH_SAIDA, 'YYYY-MM-DD hh24:mi'), 'YYYY-MM-DD hh24:mi') - 
                        to_date(to_char(ma.DH_PRODUCAO, 'YYYY-MM-DD hh24:mi'), 'YYYY-MM-DD hh24:mi')), 'hour')
              into V_TMAC_PRODUCAO
              from VND.ELO_MARCACAO ma
             where ma.CD_ELO_MARCACAO = P_CD_MARCACAO;
       END IF;

       -- TMACAdm
       -- Administrative TCMA (Column Production Order date and time minus Appointment date and time)
       IF (P_DH_PRODUCAO is not null AND P_DH_MARCACAO is not null) THEN
            select NUMTODSINTERVAL(24 * (to_date(to_char(ma.DH_PRODUCAO, 'YYYY-MM-DD hh24:mi'), 'YYYY-MM-DD hh24:mi') - 
                        to_date(to_char(ma.DH_MARCACAO, 'YYYY-MM-DD hh24:mi'), 'YYYY-MM-DD hh24:mi')), 'hour')
              into V_TMAC_ADMIN
              from VND.ELO_MARCACAO ma
             where ma.CD_ELO_MARCACAO = P_CD_MARCACAO;
       END IF;
       
       IF (P_NU_ORDEM_PRODUCAO is not null AND P_DH_SAIDA is null) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAMKD')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_CD_MOTIVO = 1 AND P_DH_SAIDA is null) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MACOT')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_CD_MOTIVO <> 1 AND P_NU_ORDEM_PRODUCAO is null) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRB')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_DH_SAIDA is not null AND (P_DESISTENCIA = 'N' AND P_DISPENSADO = 'N')) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_DESISTENCIA = 'S') THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MADES')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_DISPENSADO = 'S') THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MADIS')
              into V_STATUS
              from dual;
       END IF;
       
--       BEGIN 
--       
--       SELECT 
--       
--       E_MAR.CD_CENTRO_EXPEDIDOR,
--       E_MAR.CD_WEEK, 
--       E_MAR.NO_CLIENTE,
--       NULL CD_MACHINE,
--       (1 + TRUNC (E_MAR.DH_MARCACAO) - TRUNC (E_MAR.DH_MARCACAO, 'IW'))  DH_MARCACAO
--       INTO V_CD_CENTRO_EXPEDIDOR, V_CD_WEEK, V_DS_CLIENTE, V_CD_MACHINE, V_MULTI_NU_DIAS_SEMANA
--       
--       FROM VND.ELO_MARCACAO E_MAR
--       WHERE E_MAR.CD_ELO_MARCACAO = P_CD_MARCACAO;
--       
--       END;
       
       
       
        update VND.ELO_MARCACAO ma
           set CD_GRUPO_EMBALAGEM           = P_CD_EMBALAGEM,
               CD_INCOTERMS                 = P_INCOTERMS,
               NU_QUANTIDADE                = P_NU_QUANTIDADE,
               DH_ENTRADA                   = TO_DATE(P_DH_ENTRADA,'DD/MM/YYYY HH24:MI'),
               CD_ELO_STATUS                = NVL(V_STATUS, P_CD_STATUS),
               CD_MOTIVO_STATUS             = P_CD_MOTIVO,
               IC_DESISTENCIA               = P_DESISTENCIA,
               IC_DISPENSADO                = P_DISPENSADO,
               DH_DISPENSA                  = TO_DATE(P_DH_DISPENSA,'DD/MM/YYYY HH24:MI'),
               DS_MOTIVO_DISPENSA           = P_DS_MOTIVO_DISPENSA,
               DH_MARCACAO                  = TO_DATE(P_DH_MARCACAO,'DD/MM/YYYY HH24:MI'),
               DS_SENHA                     = P_DS_SENHA,
               DH_PRODUCAO                  = TO_DATE(P_DH_PRODUCAO,'DD/MM/YYYY HH24:MI'),
               NU_ORDEM_PRODUCAO            = P_NU_ORDEM_PRODUCAO,
               DH_SAIDA                     = TO_DATE(P_DH_SAIDA,'DD/MM/YYYY HH24:MI'),
               DS_PLACA_CAMINHAO            = P_DS_PLACA,
               DS_OBSERVACAO                = P_DS_OBSERVACAO,
               IC_PRIORIDADE                = P_PRIORIDADE,
               CD_CLIENTE_RECEBEDOR         = P_RECEBEDOR,
               CD_SALES_GROUP               = P_SUPERVISOR,
               CD_PRODUTO_SAP               = P_MATERIAL,
               IT_TMAC_CLIENTE              = V_TMAC_CLIENTE,
               IT_TMAC_MOSAIC               = V_TMAC_MOSAIC,
               IT_TMAC_PRODUCAO             = V_TMAC_PRODUCAO,
               IT_TMAC_ADMINISTRATIVO       = V_TMAC_ADMIN,
               DH_FATURAMENTO               = TO_DATE(P_DH_FATURAMENTO,'DD/MM/YYYY HH24:MI'),
               NU_NOTA_FISCAL               = NVL(P_NF, 0),
               QT_FATURADO                  = P_QT_FATURADO,
               CD_TRANSPORTADORA            = P_CD_TRANSPORTADORA,
               DS_OBSERVACAO_ORDEM_PRODUCAO = P_OBS_PRODUCAO
         where ma.CD_ELO_MARCACAO = P_CD_MARCACAO;
         COMMIT;
        
    
        OPEN P_RETURN FOR
            select P_CD_MARCACAO as CodeMarcacao from dual;
            
    EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
           ROLLBACK;
        END;
    
    END PU_UPDATE_MARKING;
    
    PROCEDURE PU_UPDATE_PRODUCTION_ORDER (
        P_CD_CARTEIRA                   IN VND.ELO_MARCACAO.CD_ELO_CARTEIRA%TYPE DEFAULT NULL,
        P_CD_MARCACAO                   IN VND.ELO_MARCACAO.CD_ELO_MARCACAO%TYPE DEFAULT NULL,
        P_ORDEM_PRODUCAO                IN VND.ELO_MARCACAO.NU_ORDEM_PRODUCAO%TYPE DEFAULT NULL,
        P_CD_CLIENTE                    IN VND.ELO_MARCACAO.CD_CLIENTE%TYPE DEFAULT NULL,
        P_CD_PRODUTO                    IN VND.ELO_MARCACAO.CD_PRODUTO_SAP%TYPE DEFAULT NULL,
        P_CD_RECEBEDOR                  IN VND.ELO_MARCACAO.CD_CLIENTE_RECEBEDOR%TYPE DEFAULT NULL,
        P_CD_TRANSPORTADORA             IN VND.ELO_MARCACAO.CD_TRANSPORTADORA%TYPE DEFAULT NULL,
        P_DH_FATURAMENTO                IN VND.ELO_MARCACAO.DH_FATURAMENTO%TYPE DEFAULT NULL,
        P_CD_FORNECIMENTO               IN VND.ELO_MARCACAO.CD_FORNECIMENTO%TYPE DEFAULT NULL,
        P_CD_INCOTERMS                  IN VND.ELO_MARCACAO.CD_INCOTERMS%TYPE DEFAULT NULL,
        P_NU_NOTA_FISCAL                IN VND.ELO_MARCACAO.NU_NOTA_FISCAL%TYPE DEFAULT NULL,
        P_DS_OBSERVACAO_ORDEM_PRODUCAO  IN VND.ELO_MARCACAO.DS_OBSERVACAO_ORDEM_PRODUCAO%TYPE DEFAULT NULL,
        P_CD_PEDIDO                     IN VND.ELO_MARCACAO.CD_PEDIDO%TYPE DEFAULT NULL,
        P_DS_PLACA_CAMINHAO             IN VND.ELO_MARCACAO.DS_PLACA_CAMINHAO%TYPE DEFAULT NULL,
        P_NU_PROTOCOLO_ENTREGA          IN VND.ELO_MARCACAO.NU_PROTOCOLO_ENTREGA%TYPE DEFAULT NULL,
        P_QT_FATURADO                   IN VND.ELO_MARCACAO.QT_FATURADO%TYPE DEFAULT NULL,
        P_CD_SEQUENCIA_AC               IN VND.ELO_MARCACAO.CD_SEQUENCIA_AC%TYPE DEFAULT NULL,
        P_RETURN                        OUT T_CURSOR
    )
    
    IS
    
    -- 1: Sem cota e atualizado com sucesso
    -- 2: Com cota, clientes diferentes
    -- 3: Com cota, clientes iguais
    V_RETORNO       NUMBER(9);
    V_CLIENTE       VND.ELO_MARCACAO.CD_CLIENTE%TYPE;
    V_NO_CLIENTE       VND.ELO_MARCACAO.NO_CLIENTE%TYPE;
    V_STATUS            NUMBER(9);

    P_DH_SAIDA  VND.ELO_MARCACAO.DH_SAIDA%TYPE;
    P_CD_MOTIVO VND.ELO_MARCACAO.CD_MOTIVO_STATUS%TYPE;
    P_DESISTENCIA VND.ELO_MARCACAO.IC_DESISTENCIA%TYPE;
    P_DISPENSADO VND.ELO_MARCACAO.IC_DISPENSADO%TYPE;
    P_DH_MARCACAO  VND.ELO_MARCACAO.DH_MARCACAO%TYPE;  
    
    
    BEGIN
    
    
        BEGIN 
        SELECT DH_SAIDA, CD_MOTIVO_STATUS, NVL(IC_DESISTENCIA, 'N') IC_DESISTENCIA, 
        NVL(IC_DISPENSADO, 'N') IC_DISPENSADO, DH_MARCACAO
        INTO P_DH_SAIDA, P_CD_MOTIVO, P_DESISTENCIA, P_DISPENSADO, P_DH_MARCACAO
        
        FROM VND.ELO_MARCACAO 
        WHERE CD_ELO_MARCACAO = P_CD_MARCACAO
        AND IC_ATIVO = 'S';
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        BEGIN
        P_DH_SAIDA:=NULL;
        P_CD_MOTIVO:=NULL;
        P_DESISTENCIA:=NULL;
        P_DISPENSADO:=NULL;
        P_DH_MARCACAO:=NULL;
        END;
        END;
        
    
    
        IF (P_ORDEM_PRODUCAO is not null AND P_DH_SAIDA is null) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAMKD')
              into V_STATUS
              from dual;
       END IF;
       
        IF (P_CD_MOTIVO = 1 AND P_DH_SAIDA is null) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MACOT')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_CD_MOTIVO <> 1 AND P_ORDEM_PRODUCAO is null) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRB')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_DH_SAIDA is not null AND (P_DESISTENCIA = 'N' AND P_DISPENSADO = 'N')) THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_DESISTENCIA = 'S') THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MADES')
              into V_STATUS
              from dual;
       END IF;
       
       IF (P_DISPENSADO = 'S') THEN
            select GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MADIS')
              into V_STATUS
              from dual;
       END IF;
       
       
    
    
        IF P_CD_CARTEIRA IS NULL THEN
        
        BEGIN
        SELECT NO_CLIENTE INTO V_NO_CLIENTE
        FROM VND.ELO_CARTEIRA 
        WHERE CD_ELO_CARTEIRA = P_CD_CARTEIRA;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        V_NO_CLIENTE:='';
        WHEN OTHERS THEN 
        V_NO_CLIENTE:='';
        END ;
            BEGIN
            update VND.ELO_MARCACAO ma
               set NU_ORDEM_PRODUCAO            = P_ORDEM_PRODUCAO,
                   CD_CLIENTE                   = LPAD(P_CD_CLIENTE, 11, '0'),
                   NO_CLIENTE                   = V_NO_CLIENTE,
                   CD_PRODUTO_SAP               = LPAD(P_CD_PRODUTO, 18, '0'),
                   CD_CLIENTE_RECEBEDOR         = P_CD_RECEBEDOR,
                   CD_TRANSPORTADORA            = P_CD_TRANSPORTADORA,
                   DH_FATURAMENTO               = P_DH_FATURAMENTO,
                   CD_FORNECIMENTO              = P_CD_FORNECIMENTO,
                   CD_INCOTERMS                 = P_CD_INCOTERMS,
                   NU_NOTA_FISCAL               = P_NU_NOTA_FISCAL,
                   DS_OBSERVACAO_ORDEM_PRODUCAO = P_DS_OBSERVACAO_ORDEM_PRODUCAO,
                   CD_PEDIDO                    = P_CD_PEDIDO,
                   DS_PLACA_CAMINHAO            = P_DS_PLACA_CAMINHAO,
                   NU_PROTOCOLO_ENTREGA         = P_NU_PROTOCOLO_ENTREGA,
                   QT_FATURADO                  = P_QT_FATURADO,
                   CD_SEQUENCIA_AC              = P_CD_SEQUENCIA_AC, 
                   CD_ELO_STATUS                = NVL(V_STATUS, CD_ELO_STATUS)
             where ma.CD_ELO_MARCACAO           = P_CD_MARCACAO;
             COMMIT;
             EXCEPTION
             WHEN OTHERS THEN 
                BEGIN
                    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                   ROLLBACK;
                END;
                END;
             
             V_RETORNO := 1;
             
        ELSE
               BEGIN
            update VND.ELO_MARCACAO ma
               set NU_ORDEM_PRODUCAO            = P_ORDEM_PRODUCAO,
                   CD_TRANSPORTADORA            = P_CD_TRANSPORTADORA,
                   DH_FATURAMENTO               = P_DH_FATURAMENTO,
                   CD_FORNECIMENTO              = P_CD_FORNECIMENTO,
                   NU_NOTA_FISCAL               = P_NU_NOTA_FISCAL,
                   DS_OBSERVACAO_ORDEM_PRODUCAO = P_DS_OBSERVACAO_ORDEM_PRODUCAO,
                   CD_PEDIDO                    = P_CD_PEDIDO,
                   DS_PLACA_CAMINHAO            = P_DS_PLACA_CAMINHAO,
                   NU_PROTOCOLO_ENTREGA         = P_NU_PROTOCOLO_ENTREGA,
                   QT_FATURADO                  = P_QT_FATURADO,
                   CD_SEQUENCIA_AC              = P_CD_SEQUENCIA_AC, 
                   CD_ELO_STATUS                = NVL(V_STATUS, CD_ELO_STATUS)
             where ma.CD_ELO_MARCACAO           = P_CD_MARCACAO;
             COMMIT;
            EXCEPTION
            WHEN OTHERS THEN 
                BEGIN
                    RAISE_APPLICATION_ERROR(-20001, 'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                   ROLLBACK;
                END;
             END;
             
            select ca.CD_CLIENTE
              into V_CLIENTE
              from VND.ELO_MARCACAO ma
             inner join VND.ELO_CARTEIRA ca
                on ma.CD_ELO_CARTEIRA = ca.CD_ELO_CARTEIRA
             where ma.CD_ELO_MARCACAO = P_CD_MARCACAO;
             
             IF P_CD_CLIENTE != V_CLIENTE THEN
                V_RETORNO := 2;
             ELSE
                V_RETORNO := 3;
             END IF;
             
        END IF;
        
        
        OPEN P_RETURN FOR
            select V_RETORNO as Retorno from dual;
        
    END PU_UPDATE_PRODUCTION_ORDER;
    
    PROCEDURE PX_GET_MARKING (
        P_CD_CENTRO             IN VND.ELO_CARTEIRA.CD_CENTRO_EXPEDIDOR%TYPE,
        P_WEEK                  IN VND.ELO_MARCACAO.CD_WEEK%TYPE,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
    BEGIN
    
    OPEN P_RETURN FOR
        
        select * from
        (
            select 
                   em.CD_ELO_MARCACAO                                                           as CodeMarcacao,
                   em.CD_ELO_CARTEIRA                                                           as CodeCarteira,
                   ec.DS_POLO                                                                   as Polo,
                   ce.CD_CENTRO_EXPEDIDOR                                                       as Plant,
                   ec.DS_MACHINE                                                                as Machine,
                   LPAD(em.CD_CLIENTE, 10, '0')                                                 as CodeCliente,
                   NVL(em.NO_CLIENTE, ec.NO_CLIENTE)                                            as DescriptionCliente,
                   em.CD_GRUPO_EMBALAGEM                                                        as Sacaria,
                   em.CD_INCOTERMS                                                              as "Mod",
                   NVL(em.NU_QUANTIDADE, 0)                                                     as Quant,
                   TO_CHAR(em.DH_ENTRADA,'DD/MM/YYYY HH24:MI')                                  as DiaEntrada,
                   ec.QT_SALDO                                                                  as SaldoEntrada,
                   em.CD_ELO_STATUS                                                             as StatusELO,
                   est_marcacao.DS_STATUS                                                       as Ds_StatusMarcacao,
                   NVL(em.CD_MOTIVO_STATUS, 0)                                                  as Motivo,
                   CASE WHEN em.IC_DESISTENCIA = 'S' 
                    THEN 'true' ELSE 'false' END                                                as Desistencia,
                   CASE WHEN em.IC_DISPENSADO = 'S' 
                    THEN 'true' ELSE 'false' END                                                as Dispensado,
                   TO_CHAR(em.DH_DISPENSA,'DD/MM/YYYY HH24:MI')                                 as DiaDispensa,
                   em.DS_MOTIVO_DISPENSA                                                        as MotivoDispensa,
                   TO_CHAR(em.DH_MARCACAO,'DD/MM/YYYY HH24:MI')                                 as DiaMarcacao,
                   em.DS_SENHA                                                                  as Senha,
                   TO_CHAR(em.DH_PRODUCAO,'DD/MM/YYYY HH24:MI')                                 as DiaProducao,
                   em.NU_ORDEM_PRODUCAO                                                         as OrdemProd,
                   TO_CHAR(em.DH_SAIDA,'DD/MM/YYYY HH24:MI')                                    as DiaSaida,
                   em.SG_CLASSIFICACAO                                                          as Classificacao,
                   NVL(ec.CD_CLIENTE_RECEBEDOR, '0')                                            as CodeRecebedor,
                   em.DS_PLACA_CAMINHAO                                                         as PlacaCaminhao,
                   em.DS_OBSERVACAO                                                             as Observacao,
                   NVL(ec.CD_USUARIO, '0')                                                       as CodeSupervisor,
                   NVL(TRIM(em.CD_PRODUTO_SAP), '0')                                            as CodeMaterial,
                   em.NU_PROTOCOLO_ENTREGA                                                      as Protocolo,
                   ''                                                                           as CompCarga,
                   'N'                                                                          as DiaExato,
                   ''                                                                           as TipoReplan,
                   CASE WHEN em.IC_PRIORIDADE = 'S' 
                    THEN 'true' ELSE 'false' END                                                as Prioridade,
                   em.DS_OBSERVACAO                                                             as ContratoPlaca,
                   VND.GX_ELO_CONTROLLERSHIP.FX_INTERVAL_TO_HOUR(em.IT_TMAC_CLIENTE)            as TMACCliente,
                   VND.GX_ELO_CONTROLLERSHIP.FX_INTERVAL_TO_HOUR(em.IT_TMAC_MOSAIC)             as TMACMosaic,
                   VND.GX_ELO_CONTROLLERSHIP.FX_INTERVAL_TO_HOUR(em.IT_TMAC_PRODUCAO)           as TMACProducao,
                   VND.GX_ELO_CONTROLLERSHIP.FX_INTERVAL_TO_HOUR(em.IT_TMAC_ADMINISTRATIVO)     as TMACAdm,
                   ''                                                                           as TipoOrdem,
                   TO_CHAR(em.DH_FATURAMENTO,'DD/MM/YYYY HH24:MI')                              as DataFaturamento,
                   em.NU_NOTA_FISCAL                                                            as NotaFiscal,
                   em.QT_FATURADO                                                               as QtdeFaturada,
                   em.CD_TRANSPORTADORA                                                         as CodTransportadora,
                   LTRIM(tr.CD_TRANSPORTADORA, '0') || ' - ' || tr.NO_TRANSPORTADORA            as Transportadora,
                   em.CD_PEDIDO                                                                 as PO,
                   em.CD_FORNECIMENTO                                                           as Fornecimento,
                   em.CD_SEQUENCIA_AC                                                           as SequencAC,
                   em.DS_OBSERVACAO_ORDEM_PRODUCAO                                              as ObsOrdemProducao
              from VND.ELO_MARCACAO em
              left join (
              SELECT eci.CD_ELO_CARTEIRA, eci.CD_ELO_AGENDAMENTO,
              ag.CD_MACHINE, ma.DS_MACHINE, ag.CD_POLO,po.DS_POLO, eci.CD_SALES_GROUP,
              eci.QT_SALDO, eci.CD_CLIENTE_RECEBEDOR, eci.CD_INCOTERMS, u.CD_USUARIO, eci.NO_CLIENTE, eci.CD_CLIENTE
              FROM VND.ELO_CARTEIRA eci
              INNER JOIN VND.ELO_AGENDAMENTO ag
              on eci.CD_ELO_AGENDAMENTO = ag.CD_ELO_AGENDAMENTO
            
              left join CTF.MACHINE ma
                on ag.CD_MACHINE = ma.CD_MACHINE
              left join CTF.POLO po
                on ag.CD_POLO = po.CD_POLO

             inner join CTF.USUARIO u
                on eci.CD_SALES_GROUP = u.CD_USUARIO_ORIGINAL

             where eci.IC_ATIVO = 'S'
             and ag.IC_ATIVO = 'S'
             and ag.CD_WEEK = P_WEEK
             and eci.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
             
             ) ec 
             ON ec.CD_ELO_CARTEIRA = em.CD_ELO_CARTEIRA
            inner join CTF.CENTRO_EXPEDIDOR ce
            on em.CD_CENTRO_EXPEDIDOR = ce.CD_CENTRO_EXPEDIDOR
            inner join VND.GRUPO_EMBALAGEM ge
            on em.CD_GRUPO_EMBALAGEM = ge.CD_GRUPO_EMBALAGEM
            left join VND.TRANSPORTADORA tr
            on tr.CD_TRANSPORTADORA = em.CD_TRANSPORTADORA
            left join VND.ELO_STATUS est_marcacao
            on est_marcacao.cd_elo_status = em.cd_elo_status 
            WHERE
             
               em.IC_ATIVO = 'S'
               and em.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
               and em.CD_WEEK = P_WEEK
      

    ) order by CodeMarcacao desc;
         
    END PX_GET_MARKING;
    
    PROCEDURE PX_GET_MARKING_HEADER (
        P_CD_CENTRO             IN VND.ELO_CARTEIRA.CD_CENTRO_EXPEDIDOR%TYPE,
        P_DT_WEEK_START         IN VND.ELO_AGENDAMENTO_CENTRO.DT_WEEK_START%TYPE,
        P_WEEK_DAY              IN INT,
        P_WEEK                  IN INT,
        P_RETURN                OUT T_CURSOR
    )
    
    IS
 
    V_CINZA         int;
    V_VERDE         int;
    V_AMARELO       int;
    V_VERMELHO      int;
    V_RESPIRO       int;
    V_AZUL          int;
    
    V_BAG           int;
    V_ENSACADO      int;
    V_GRANEL        int;
    
    V_PRIORIDADE    int;
    V_FOB           int;
    V_CIF           int;
    
    BEGIN
            --CINZA: Capacidade restante
            BEGIN 
             select NVL(ROUND(((ci.NU_CAPACIDADE_MAXIMA / ci.NU_HORAS_PRODUCAO / 60) * 
                (((to_number(to_char(CURRENT_DATE, 'HH24')) - (CASE WHEN to_number(to_char(DH_FIM_PRODUCAO, 'HH24')) = '00' THEN 24 END)) * 60) * -1)) 
                    - (ci.NU_CAPACIDADE_MAXIMA / ci.NU_HORAS_PRODUCAO / 60),0),0)                                      as CAPACIDADE
              into V_CINZA
              from VND.ELO_AGENDAMENTO_CENTRO ac
             inner join VND.ELO_AGENDAMENTO_CENTRO_ITEM ci
                on ac.CD_AGENDAMENTO_CENTRO = ci.CD_AGENDAMENTO_CENTRO
             where rownum = 1
               and ac.IC_ATIVO = 'S'
               and ci.IC_ATIVO = 'S'
               --and to_date(ac.DT_WEEK_START,'DD/MM/YYYY') = to_date(P_DT_WEEK_START,'DD/MM/YYYY')
               AND TO_CHAR(ac.DT_WEEK_START,'YYYYWW') = TO_CHAR(to_date(P_DT_WEEK_START,'YYYY-MM-DD'),'YYYYWW')
               and ci.NU_DIA_SEMANA = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
               and EXISTS  (SELECT 1 
                            FROM CTF.POLO_CENTRO_EXPEDIDOR PC WHERE 
                            PC.CD_CENTRO_EXPEDIDOR = ac.CD_CENTRO_EXPEDIDOR
                            AND EXISTS 
                            (SELECT 1 FROM CTF.POLO_CENTRO_EXPEDIDOR WHOPC 
                            WHERE WHOPC.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                            AND WHOPC.CD_POLO = PC.CD_POLO));
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_CINZA := 0;
            END;
        
            --VERDE: Disponível para produção 
            BEGIN
            select NVL(sum(ma.NU_QUANTIDADE),0) as DISPONIVEL
              into V_VERDE
            from VND.ELO_MARCACAO ma
            where 
            ma.IC_ATIVO = 'S'
            and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
            and NVL(ma.IC_DISPENSADO, 'N') = 'N'
            --and ma.CD_INCOTERMS = 'CIF'
            and ma.DH_DISPENSA is null
            and ma.DH_SAIDA is null
            AND ma.NU_ORDEM_PRODUCAO IS NOT NULL
            AND ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
            AND  ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAMKD')
            AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
            and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY');
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_VERDE := 0;
            END;               
               
           --AMARELO: Aguardando Cota 
           BEGIN
            select NVL(sum(ma.NU_QUANTIDADE),0) as DISPONIVEL
              into V_AMARELO
            from VND.ELO_MARCACAO ma
            where 
            ma.IC_ATIVO = 'S'              
            AND ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
            AND  ma.CD_MOTIVO_STATUS  = 1
            AND ma.dh_saida is  null
            AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
            and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY');


            EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_AMARELO := 0;
            END;               

               
           --VERMELHO: Marcado com Problema 
           BEGIN
            select NVL(sum(ma.NU_QUANTIDADE),0) as PROBLEMA
              into V_VERMELHO
              from VND.ELO_MARCACAO ma

             where 
                ma.IC_ATIVO = 'S'
                and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
                and NVL(ma.IC_DISPENSADO, 'N') = 'N'
                --and ma.CD_INCOTERMS = 'CIF'
                and ma.DH_DISPENSA is null
                and ma.DH_SAIDA is null
                and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRB')
                AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
                and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY');               
               
               
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_VERMELHO := 0;
            END;               
               
           --RESPIRO
           BEGIN
           select ac.QT_FILA_MINIMA
             into V_RESPIRO
             from VND.ELO_AGENDAMENTO_CENTRO ac
            where rownum = 1
              and ac.IC_ATIVO = 'S'
              and ac.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
              and to_date(ac.DT_WEEK_START,'DD/MM/YYYY') = to_date(P_DT_WEEK_START,'DD/MM/YYYY');
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_RESPIRO := 0;
            END;
           
           --AZUL
           BEGIN 
            select NVL(sum(ma.NU_QUANTIDADE),0) as CARREGADO
            into V_AZUL
            from VND.ELO_MARCACAO ma
            where 
            ma.IC_ATIVO = 'S'
            and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
            and NVL(ma.IC_DISPENSADO, 'N') = 'N'
            and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
            and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
            and ma.DH_DISPENSA is null
            and ma.DH_SAIDA is NOT null
            and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY')
            AND (1 + TRUNC (ma.DH_SAIDA) - TRUNC (ma.DH_SAIDA, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW')) ;           

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_AZUL := 0;
            END;            
              
           --PRIORIDADE
           select NVL(sum(ma.NU_QUANTIDADE),0) as PRIORIDADE
             into V_PRIORIDADE
             from VND.ELO_MARCACAO ma
            inner join VND.ELO_CARTEIRA ca
               on ca.CD_ELO_CARTEIRA = ma.CD_ELO_CARTEIRA
            --inner join VND.ELO_AGENDAMENTO_CENTRO ac
            --   on ca.CD_CENTRO_EXPEDIDOR = ac.CD_CENTRO_EXPEDIDOR
            inner join VND.ELO_AGENDAMENTO ag
               on ag.CD_ELO_AGENDAMENTO = ca.CD_ELO_AGENDAMENTO
            where --ac.IC_ATIVO = 'S'
               ma.IC_PRIORIDADE = 'S'
              and ca.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
              and to_date(ag.DT_WEEK_START,'DD/MM/YYYY') = to_date(P_DT_WEEK_START,'DD/MM/YYYY');
              
           -- FOB
           BEGIN
                select NVL(sum(ma.NU_QUANTIDADE),0)      as FOB
                --P_WEEK_DAY
                into V_FOB
                from VND.ELO_MARCACAO ma
                where 
                ma.IC_ATIVO = 'S'
                and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
                and NVL(ma.IC_DISPENSADO, 'N') = 'N'
                and ma.CD_INCOTERMS = 'FOB'
                and ma.DH_DISPENSA is null
                --and ma.DH_SAIDA is null
                --and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
                and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY')
                AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
                group by ma.CD_INCOTERMS;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_FOB := 0;
          END;
        
           --CIF
          BEGIN
                select NVL(sum(ma.NU_QUANTIDADE),0)      as CIF
                --P_WEEK_DAY
                into V_CIF
                from VND.ELO_MARCACAO ma
                where 
                ma.IC_ATIVO = 'S'
                and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
                and NVL(ma.IC_DISPENSADO, 'N') = 'N'
                and ma.CD_INCOTERMS = 'CIF'
                and ma.DH_DISPENSA is null
                and ma.DH_SAIDA is null
                --and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
                and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY')
                AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
                group by ma.CD_INCOTERMS;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_CIF := 0;
          END;
          
          --BIG BAG
          BEGIN
                select NVL(sum(ma.NU_QUANTIDADE),0)      as BAG
                --P_WEEK_DAY
                into V_BAG
                from VND.ELO_MARCACAO ma
                where 
                ma.IC_ATIVO = 'S'
                and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
                and NVL(ma.IC_DISPENSADO, 'N') = 'N'
                --and ma.CD_INCOTERMS = 'CIF'
                and ma.DH_DISPENSA is null
                --and ma.DH_SAIDA is null
                and ma.CD_GRUPO_EMBALAGEM = 'B'
                
                --and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
                and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY')
                AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
                group by ma.CD_GRUPO_EMBALAGEM;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_BAG := 0;
          END;
          
          --ENSACADO
          BEGIN
                select NVL(sum(ma.NU_QUANTIDADE),0)      as ENSACADO
                --P_WEEK_DAY
                into V_ENSACADO
                from VND.ELO_MARCACAO ma
                where 
                ma.IC_ATIVO = 'S'
                and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
                and NVL(ma.IC_DISPENSADO, 'N') = 'N'
                --and ma.CD_INCOTERMS = 'CIF'
                and ma.DH_DISPENSA is null
               -- and ma.DH_SAIDA is null
                and ma.CD_GRUPO_EMBALAGEM = 'S'
                
                --and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
                and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY')
                AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
                group by ma.CD_GRUPO_EMBALAGEM;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_ENSACADO := 0;
          END;
          
          --GRANEL
          BEGIN
                select NVL(sum(ma.NU_QUANTIDADE),0)      as V_GRANEL
                --P_WEEK_DAY
                into V_GRANEL
                from VND.ELO_MARCACAO ma
                where 
                ma.IC_ATIVO = 'S'
                and NVL(ma.IC_DESISTENCIA, 'N') = 'N'
                and NVL(ma.IC_DISPENSADO, 'N') = 'N'
                --and ma.CD_INCOTERMS = 'CIF'
                and ma.DH_DISPENSA is null
                --and ma.DH_SAIDA is null
                and ma.CD_GRUPO_EMBALAGEM = 'G'
                
                --and ma.CD_ELO_STATUS = GX_ELO_COMMON.FX_ELO_STATUS('MARCA','MAPRD')
                and ma.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO
                and ma.CD_WEEK = 'W' || TO_CHAR(P_DT_WEEK_START, 'IWYYYY')
                AND (1 + TRUNC (ma.DH_MARCACAO) - TRUNC (ma.DH_MARCACAO, 'IW')) = (1 + TRUNC (CURRENT_DATE) - TRUNC (CURRENT_DATE, 'IW'))
                group by ma.CD_GRUPO_EMBALAGEM;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             V_GRANEL := 0;
          END;
                      
          OPEN P_RETURN FOR
           select V_BAG                 as BAG,
                  V_ENSACADO            as ENSACADO,
                  V_GRANEL              as GRANEL,
                  V_CINZA               as CAPACIDADE,
                  V_VERDE               as DISPONIVEL,
                  V_AMARELO             as SEM_COTA,
                  V_VERMELHO            as PROBLEMA,
                  V_RESPIRO             as RESPIRO,
                  V_AZUL                as CARREGADO,
                  V_PRIORIDADE          as PRIORIDADE,
                  V_CIF                 as CIF,
                  V_FOB                 as FOB
             from dual;
    
    END PX_GET_MARKING_HEADER;
    
    FUNCTION FX_INTERVAL_TO_HOUR (P_INTERVAL_DAY IN VND.ELO_MARCACAO.IT_TMAC_CLIENTE%TYPE) RETURN varchar2
    IS
        V_RESULT VARCHAR2(10);
    BEGIN
    
        IF (P_INTERVAL_DAY IS NOT NULL) THEN
            select LPAD(EXTRACT(HOUR FROM P_INTERVAL_DAY),2,'0') || ':' || LPAD(EXTRACT(MINUTE FROM P_INTERVAL_DAY),2,'0')
              into V_RESULT
              from dual;
        ELSE
            V_RESULT := '';
        END IF;
    
        RETURN v_result;
    
    END FX_INTERVAL_TO_HOUR;
    
 
    PROCEDURE PX_GET_CUSTOMERSBY_NAME (P_NO_CLIENTE IN VND.ELO_CARTEIRA.NO_CLIENTE%type,
                                P_RETURN     OUT T_CURSOR)
                                
    IS
    BEGIN
        OPEN P_RETURN FOR
        
        select 
               ec.NO_CLIENTE                                    as CodeCustomer,
               ec.NO_CLIENTE                                    as DescriptionCustomer
          from VND.ELO_CARTEIRA ec
          INNER JOIN VND.ELO_AGENDAMENTO AG 
          ON AG.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
         where ec.IC_ATIVO = 'S'
         AND AG.IC_ATIVO = 'S'
         AND UPPER(ec.NO_CLIENTE) LIKE '%' ||  UPPER(P_NO_CLIENTE) ||  '%'
         GROUP BY ec.NO_CLIENTE
      order by ec.NO_CLIENTE;
   
    END PX_GET_CUSTOMERSBY_NAME;  
      
  
END GX_ELO_CONTROLLERSHIP;
/