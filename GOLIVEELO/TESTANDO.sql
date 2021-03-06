        SELECT DISTINCT
            EC.CD_ELO_CARTEIRA
            ,EA.CD_ELO_AGENDAMENTO
            ,EA.CD_WEEK
            ,EA.CD_POLO
            ,EC.NU_CONTRATO_SAP
            ,EC.NU_ORDEM_VENDA
            , EA.CD_CENTRO_EXPEDIDOR
            ,EC.QT_AGENDADA_CONFIRMADA
            ,EA.CD_ELO_AGENDAMENTO
            ,EC.CD_STATUS_CEL_FINAL
            ,NVL((SELECT SUM(NVL(POT.QT_AGENDADA_PROTOCOLO,0 )) QT 
                        FROM VND.ELO_VBAK_PROTOCOLO POT 
                        WHERE POT.CD_ELO_CARTEIRA = EC.CD_ELO_CARTEIRA 
                        AND POT.IC_ATIVO='S'), 0)   QT_AGENDADA_PROTOCOLO
            ,NVL(ESCF.SG_STATUS, 'BRANCO') SG_STATUS
            ,EC.CD_ELO_AGENDAMENTO_ITEM
            ,EA.CD_ELO_STATUS
            ,EC.CD_TIPO_AGENDAMENTO 
        FROM VND.ELO_CARTEIRA EC
        INNER JOIN VND.ELO_AGENDAMENTO EA ON EC.CD_ELO_AGENDAMENTO = EA.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
        LEFT JOIN VND.ELO_STATUS ESCF
        ON ESCF.CD_ELO_STATUS = EC.CD_STATUS_CEL_FINAL
        
        INNER JOIN VND.ELO_VBAK_PROTOCOLO PROTO 
        ON PROTO.CD_ELO_CARTEIRA = EC.CD_ELO_CARTEIRA
        
        WHERE (EC.QT_AGENDADA_CONFIRMADA >= 0)  
        AND EC.CD_STATUS_CUSTOMER_SERVICE IS NOT NULL
        AND NOT(NVL(ESCF.SG_STATUS, 'BRANCO') = 'CLOOK')
        AND ((EC.CD_TIPO_AGENDAMENTO = 25 AND NOT(VND.GX_ELO_COMMON.fx_elo_status('AGEND', 'AGENC') = EA.CD_ELO_STATUS ))
            OR (EA.CD_ELO_STATUS IN ( VND.GX_ELO_COMMON.fx_elo_status('AGEND', 'AGCTR'), 
                  VND.GX_ELO_COMMON.fx_elo_status('AGEND', 'PLAN'))))
        AND (P_CD_WEEK IS NULL OR EA.CD_WEEK = P_CD_WEEK)
        AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
        AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
        AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE);
        
UPDATE VND.ELO_VBAK_PROTOCOLO 
SET QT_AGENDADA_PROTOCOLO = 3.228
WHERE CD_ELO_CARTEIRA = 134642;
/
UPDATE VND.ELO_VBAK_PROTOCOLO 
SET QT_AGENDADA_PROTOCOLO = 40
WHERE CD_ELO_CARTEIRA = 134643;
/
UPDATE VND.ELO_VBAK_PROTOCOLO 
SET QT_AGENDADA_PROTOCOLO = 230
WHERE CD_ELO_CARTEIRA = 134522;
/
UPDATE VND.ELO_VBAK_PROTOCOLO 
SET QT_AGENDADA_PROTOCOLO = 150
WHERE CD_ELO_CARTEIRA = 134622;
/

SELECT * FROM VND.ELO_VBAK_PROTOCOLO
WHERE CD_ELO_CARTEIRA IN 
(256784, 253702,
253693,
256783
)        

135
37
0,04
465


select * from vnd.elo_carteira 
where qt_agendada_confirmaDA = 0 
and 134642 = cd_elo_carteira
and NVL(CD_STATUS_CEL_FINAL, 5) <> 59
AND DS_VERSAO IS NOT NULL
AND DS_VERSAO LIKE '%07/05/2018%'


UPDATE VND.ELO_carteira 
SET QT_AGENDADA_confirmada = 3.228
WHERE CD_ELO_CARTEIRA = 134642;
/
UPDATE VND.ELO_carteira 
SET QT_AGENDADA_confirmada = 40
WHERE CD_ELO_CARTEIRA = 134643;
/
UPDATE VND.ELO_carteira 
SET QT_AGENDADA_confirmada = 230
WHERE CD_ELO_CARTEIRA = 134522;
/
UPDATE VND.ELO_carteira
SET QT_AGENDADA_confirmada = 150
WHERE CD_ELO_CARTEIRA = 134622;


134622	52070
134522	52078
134643	52082
134642	52082


select * from vnd.elo_vbak_protocolo 
where cd_elo_carteira in 
(

134622,
134522,
134643,
134642

)

;

        WITH CTE_CARTEIRA AS 
        (
        SELECT 
        CT.CD_ELO_CARTEIRA, CT.CD_ELO_AGENDAMENTO_ITEM, CT.CD_STATUS_CEL_FINAL,
        CT.QT_AGENDADA_CONFIRMADA, CT.CD_ELO_AGENDAMENTO
        FROM VND.ELO_CARTEIRA CT
        INNER JOIN VND.ELO_AGENDAMENTO AGE
        ON CT.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_STATUS AGESTAT
        ON AGESTAT.CD_ELO_STATUS = AGE.CD_ELO_STATUS
        LEFT JOIN VND.ELO_STATUS STCELL 
        ON STCELL.CD_ELO_STATUS = CT.CD_STATUS_CEL_FINAL 
        WHERE 
        CT.IC_ATIVO = 'S'
        AND AGE.IC_ATIVO = 'S'
        AND NOT(STCELL.SG_STATUS = 'AGENC')
        AND CT.CD_ELO_CARTEIRA = 134642
        AND CT.CD_ELO_AGENDAMENTO_ITEM = 52082
        AND CT.CD_TIPO_AGENDAMENTO = 25 
        AND NOT(NVL(STCELL.SG_STATUS, 'BRANCO') = 'CLOOK')
        AND NVL(CT.QT_AGENDADA_CONFIRMADA ,0) >= 0 
        )

        SELECT 
        IGROUP.CD_ELO_AGENDAMENTO_GROUPING, 
        CT.CD_ELO_CARTEIRA, 
        CT.CD_ELO_AGENDAMENTO_ITEM, 
        PROTO.CD_ELO_VBAK_PROTOCOLO,
        PROTO.NU_PROTOCOLO, 
        PROTO.QT_AGENDADA_PROTOCOLO, 
        IGROUP.QT_AGENDADA 
        --CT.QT_AGENDADA_CONFIRMADA, --CENT.QT_QUANTIDADE, --CENT.QT_FORNECIDO, --CENT.CD_AUTORIZACAO_ENTREGA
        --CT.CD_STATUS_CEL_FINAL, --IGROUP.CD_ELO_AGENDAMENTO_WEEK,

        FROM CTE_CARTEIRA CT
        INNER JOIN VND.ELO_VBAK_PROTOCOLO PROTO
        ON CT.CD_ELO_CARTEIRA = PROTO.CD_ELO_CARTEIRA
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR AGSUP
        ON AGSUP.CD_ELO_AGENDAMENTO = CT.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_AGENDAMENTO_ITEM AGITEM
        ON AGSUP.CD_ELO_AGENDAMENTO_SUPERVISOR = AGITEM.CD_ELO_AGENDAMENTO_SUPERVISOR
        INNER JOIN VND.ELO_AGENDAMENTO_WEEK WEESK
        ON AGITEM.CD_ELO_AGENDAMENTO_ITEM = WEESK.CD_ELO_AGENDAMENTO_ITEM
        AND WEESK.CD_ELO_AGENDAMENTO_ITEM = CT.CD_ELO_AGENDAMENTO_ITEM
        INNER JOIN VND.ELO_AGENDAMENTO_GROUPING  IGROUP
        ON WEESK.CD_ELO_AGENDAMENTO_WEEK = IGROUP.CD_ELO_AGENDAMENTO_WEEK
        --INNER JOIN CPT.ENTREGA CENT
        --ON PROTO.NU_PROTOCOLO = CENT.NU_PROTOCOLO_ENTREGA
        --AND PROTO.CD_ENTREGA = CENT.CD_AUTORIZACAO_ENTREGA

        WHERE 
        PROTO.QT_AGENDADA_PROTOCOLO > 0 
        AND PROTO.IC_ATIVO = 'S'
        --AND CENT.SG_STATUS NOT IN ('C')
        AND IGROUP.SG_TIPO_DOCUMENTO = 'P'
        AND IGROUP.NU_DOCUMENTO IS NOT NULL --= V_NU_DOCUMENTO
        AND AGSUP.IC_ATIVO = 'S'
        AND AGITEM.IC_ATIVO = 'S'
        ORDER BY IGROUP.CD_ELO_AGENDAMENTO_GROUPING DESC;


SELECT * FROM VW_CARTEIRA_SEMANAL_PLAN