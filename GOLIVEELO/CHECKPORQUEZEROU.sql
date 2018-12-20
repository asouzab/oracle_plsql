select * from VND.ELO_AGENDAMENTO 
WHERE CD_WEEK = 'W162018' AND CD_CENTRO_EXPEDIDOR = '6023'



SELECT AGE.CD_ELO_AGENDAMENTO, AGE.CD_ELO_STATUS, NVL(PC.CD_POLO, AGE.CD_POLO) CD_POLO, E_MAR.CD_WEEK, E_MAR.CD_CENTRO_EXPEDIDOR 
FROM VND.ELO_MARCACAO E_MAR 
INNER JOIN VND.ELO_CARTEIRA CT
ON E_MAR.CD_ELO_CARTEIRA = CT.CD_ELO_CARTEIRA
INNER JOIN VND.ELO_AGENDAMENTO AGE
ON CT.CD_ELO_AGENDAMENTO = AGE.CD_ELO_AGENDAMENTO
LEFT JOIN CTF.POLO_CENTRO_EXPEDIDOR PC
ON E_MAR.CD_CENTRO_EXPEDIDOR = PC.CD_CENTRO_EXPEDIDOR
WHERE 
NVL(E_MAR.ic_desistencia, 'N') ='N' AND NVL(E_MAR.IC_DISPENSADO, 'N') = 'N' 
--AND E_MAR.DH_MARCACAO IS NOT NULL 
AND E_MAR.IC_ATIVO = 'S'
GROUP BY AGE.CD_ELO_AGENDAMENTO, AGE.CD_ELO_STATUS, NVL(PC.CD_POLO, AGE.CD_POLO) ,  E_MAR.CD_WEEK, E_MAR.CD_CENTRO_EXPEDIDOR 

select * from vnd.elo_agendamento
where cd_week = 'W162018' AND CD_POLO = 'P002'

SELECT * FROM VND.ELO_

select * from vnd.elo_status 

select * from vnd.elo_marcacao_hist


SELECT * FROM VND.ELO_CARTEIRA 
WHERE NVL(QT_AGENDADA_CONFIRMADA, 9999999) IN (0,  9999999)
AND CD_TIPO_AGENDAMENTO = 25 AND CD_STATUS_CUSTOMER_SERVICE = 11
AND QT_AGENDADA_CELULA IS NULL
AND NVL(CD_STATUS_CEL_FINAL, 44) <> 59


SELECT AG.CD_ELO_STATUS, C.* FROM VND.ELO_CARTEIRA C
INNER JOIN VND.ELO_AGENDAMENTO AG
ON C.CD_ELO_AGENDAMENTO = AG.CD_ELO_AGENDAMENTO
WHERE NVL(C.QT_AGENDADA_CONFIRMADA, 0) =0
AND C.CD_TIPO_AGENDAMENTO <> 25
AND NVL(C.QT_AGENDADA_CELULA ,0) = 0 
AND C.NU_PROTOCOLO IS NOT NULL
AND DH_MODIFICACAO_CELL_ATT IS NULL
AND C.QT_AGENDADA_CELULA IS NULL
AND (C.CD_STATUS_CEL_FINAL  = 59 OR NVL(C.IC_CORTADO_FABRICA, 0) = 0 ) 
AND (NVL(C.IC_PERMITIR_CS, 'N') = 'N' AND C.CD_STATUS_CEL_FINAL  = 59 AND CD_ELO_CARTEIRA_GROUPING IS NULL)

WITH CTE_A AS (

select distinct ss.owner, ss.name from all_source ss
where 1=1 --type like 'PACKAGE%'
and owner in ('VND','CTF', 'CPT')
and upper(text) like '%ELO_AGENDAMENTO%' 
union
select distinct ss.owner, ss.name from all_source ss
where 1=1 --type like 'PACKAGE%'
and owner in ('VND','CTF', 'CPT')
and upper(text) like '%UPDATE%'
union
select distinct ss.owner, ss.name from all_source ss
where 1=1 --type like 'PACKAGE%'
and owner in ('VND','CTF', 'CPT')
and upper(text) like '%MERGE%'
UNION
select distinct ss.owner, ss.name from all_source ss
where 1=1 --type like 'PACKAGE%'
and owner in ('VND','CTF', 'CPT')
and upper(text) like '%CD_ELO_STATUS%'
UNION
select distinct ss.owner, ss.name from all_source ss
where 1=1 --type like 'PACKAGE%'
and owner in ('VND','CTF', 'CPT')
and upper(text) like '%SET%'

)

SELECT ASS.* FROM CTE_A ASS
INNER JOIN all_source ss
ON ASS.owner= ss.owner 
AND ASS.name= ss.name 
where 1=1 --type like 'PACKAGE%'
and ss.owner in ('VND','CTF', 'CPT')
and upper(ss.text) like '%CONSUMOACUMULADOCENTRO%'


select * from vnd.elo_vbak_protocolo 
where nu_protocolo = 'R121171PE1'

--alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'
SELECT NU_ORDEM_VENDA, CD_ELO_AGENDAMENTO, CD_ELO_CARTEIRA, CD_STATUS_CEL_FINAL, QT_AGENDADA_CONFIRMADA, 
CD_STATUS_CUSTOMER_SERVICE, CD_STATUS_TORRE_FRETES, DH_LIBERACAO_TORRE_FRETES , CD_INCOTERMS , CD_TIPO_AGENDAMENTO
FROM VND.ELO_CARTEIRA WHERE
(CD_ELO_CARTEIRA = 22208 OR CD_ELO_AGENDAMENTO = 12) AND QT_AGENDADA_CONFIRMADA > 0 AND CD_STATUS_TORRE_FRETES >=10
AND CD_INCOTERMS = 'CIF'

SELECT * FROM VND.ELO_AGENDAMENTO WHERE CD_ELO_AGENDAMENTO = 12

SELECT * FROM VND.ELO_CARTEIRA WHERE CD_ELO_AGENDAMENTO = 9
AND CD_TIPO_AGENDAMENTO = 25

select * from sys.v_$session
select * from all_view

select * from ctf.polo
select * from ctf.polo_centro_expedidor






select distinct ss.owner, ss.name from all_source ss
where 1=1 --type like 'PACKAGE%'
and owner in ('VND','CTF', 'CPT')
and upper(text) like '%CONSUMOACUMULADOCENTRO%' 


