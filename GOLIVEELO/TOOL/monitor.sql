select count(1) from vnd.elo_carteira_hist;

--select * from  table(dbms_xplan.display_cursor);

SELECT
*
  FROM   
  user_tab_cols
  WHERE 
  hidden_column = 'YES'
  --table_name = 'ELO_CARTEIRA_HIST'
  
  ;
  
  
  SELECT SYS_NC00003$, SYS_NC00004$ FROM   VW_ELO_CD_WEEK_SEMANAL;
  
--   
  
select 
S.*,
o.object_name,
 s.row_wait_obj#,
 s.row_wait_file#,
 s.row_wait_block#,
  s.row_wait_row#--,
-- dbms_rowid.rowid_create ( 1, s.ROW_WAIT_OBJ#, s.ROW_WAIT_FILE#, s.ROW_WAIT_BLOCK#, s.ROW_WAIT_ROW# ) as "ROWID"
,AE.SQL_TEXT
,AE.sql_fulltext
,AEP.SQL_TEXT

from v$session s LEFT JOIN  ALL_objects o
ON s.ROW_WAIT_OBJ# = o.OBJECT_ID
LEFT JOIN v$sqlAREA AE
ON (AE.SQL_ID = s.SQL_ID OR AE.ADDRESS = s.PADDR OR AE.ADDRESS = s.SADDR)
LEFT JOIN v$sqlAREA AEP
ON AEP.SQL_ID = s.PREV_SQL_ID
LEFT JOIN v$sqlAREA AEP
ON AEP.SQL_ID = s.PREV_SQL_ID

 where 1=1 
 --s.sid=51
 AND SCHEMANAME IN ( 'ECC_USER', 'VND', 'VND_SEC', 'PIC', 'CTFx', 'CPTx', 'WEBx','WCMx', 'TIVPRODx', 'AGPx', 
 'EDX_USERx', 'GPRIGNONx', 'BACKUPADMINx' )
 ;
 
 
 select * from v$sqlAREA 
 where 
 last_active_time > sysdate - 0.1
 and is_obsolete = 'N'
 --and USERS_OPENING > =0
 AND (USERS_OPENING >= 0 AND EXECUTIONS > 1000)
 
 --sql_id='55r7qbp3mpdxw'
 ;
 
 
 
 SELECT * FROM ALL_OBJECTS 
 WHERE OBJECT_ID = 105971;
 
 89041
89170
89169
89190
89171
89155
89081

 
 select * from vnd.carteira;
 
 SELECT * FROM ALL_USERS;



select 

CASE WHEN nu_contrato IS NOT NULL THEN 'S' ELSE 'N' END TEM_PO,
CASE WHEN nu_contrato_SAP IS NOT NULL THEN 'S' ELSE 'N' END TEM_CONTRATO_SAP,

max(trunc(greatest(cont.dh_inclusao, cont.dh_geracao, cont.dh_assinatura, cont.dh_envio_adven, dh_ult_interface),'YEAR')) ultima_modificacao,
cont.cd_sales_org,
cont.cd_status_contrato,
stc.ds_status_contrato,
cont.cd_situacao_contrato,
sc.ds_situacao_contrato,
cont.ic_ativo,
CASE WHEN DS_PDF IS NOT NULL THEN 'S' ELSE 'N' END TEM_PDF,
trunc(NVL(cont.dt_fim, cont.dt_inicio), 'YEAR') FIM_CONTRATO,
trunc(cont.dt_inicio,'YEAR') INICIO_CONTRATO,
count(1) QUANTIDADE from vnd.contrato cont
left join vnd.situacao_contrato sc on sc.cd_situacao_contrato = cont.cd_situacao_contrato  
left join vnd.status_contrato stc on stc.cd_status_contrato = cont.cd_status_contrato
group by 
trunc(nvl(cont.dt_fim, cont.dt_inicio), 'YEAR'),
trunc(cont.dt_inicio,'YEAR'), 
cont.cd_status_contrato, cont.ic_ativo, 
cont.cd_sales_org,
cont.cd_situacao_contrato,
sc.ds_situacao_contrato,
stc.ds_status_contrato,
CASE WHEN DS_PDF IS NOT NULL THEN 'S' ELSE 'N' END ,
CASE WHEN nu_contrato IS NOT NULL THEN 'S' ELSE 'N' END, -- TEM_PO,
CASE WHEN nu_contrato_SAP IS NOT NULL THEN 'S' ELSE 'N' END -- TEM_CONTRATO_SAP,
;


select * from  vnd.contrato
where 
--nu_contrato_sap IN( '0040403609')
nu_contrato = '3065643'
;

select * from vnd.contrato_logger
where sg_level = 'ERROR' AND DH_LOG > CURRENT_DATE - 365;



 select * from vnd.carteira
 where aa_compensacao = '2018' and dh_lancto_documento > current_date - 1;
 
 
 NU_PROTOCOLO_ENTREGA = :B2 AND CD_AUTORIZACAO_ENTREGA = :B1
 
 
 
 SELECT SYSDATE FROM DUAL;
 
  select * from vnd.ELO_carteira_SAP WHERE DH_CARTEIRA > CURRENT_DATE-1;
  
  
  
  select * from sys.v_$locked_object ;
  
  select * from sys.V_$LOCK;
  
  select * from sys.v_$SESSION_WAIT;
  
  
  select * from v$sqlAREA
  where upper(sql_text) like '%ELO_CARTEIRA_PROT_HIST%';
  
  select * from sys.V_$SESSTAT;
  
  
  105971 object_id   ELO_CARTEIRA_SAP_CENTRO
  session_id 396
  
  select * from dual;
  
  
  
SELECT 
    PLANS.SQL_HASH_VALUE, 
    --NVL(MAX(CARD.CARDINALITY),0) AS CARDINALITY , 
    NVL((PLANS.elapsed_seconds),0) AS elapsed_seconds, 
    '2' AS origem_hash,
    plans.*
FROM V$SESSION_LONGOPS PLANS
--LEFT JOIN OPERACAO.STATS_CARDINALITY CARD
--ON CARD.HASH_VALUE    = PLANS.SQL_HASH_VALUE

WHERE 

(NOT(PLANS.sql_hash_value =0) AND
 NOT(PLANS.USERNAME = 'SYS'));  
 
 
 select /*+ ORDERED USE_NL(st) */ 
 ses.*,
 st.sql_text, st.*
  from v$session ses,
       v$sqltext st
  where st.address = ses.sql_address
   and st.hash_value=ses.sql_hash_value
   --and ses.sid= 25
order by st.SQL_ID , st.piece;


select * from v$sqltext where sql_id = '5xph033r91d41'
order by SQL_ID , piece;

select vs.audsid audsid,
to_char(locks.sid) sid,
to_char(vs.serial#) serial,
vs.username oracle_user,
vs.osuser os_user,
vs.program program,
vs.module module,
vs.action action,
vs.process process,
decode(locks.lmode,
       1, NULL,
       2, 'Row Share',
       3, 'Row Exclusive',
       4, 'Share',
       5, 'Share Row Exclusive',
       6, 'Exclusive', 'None') lock_mode_held,
 decode(locks.request,
       1, NULL,
       2, 'Row Share',
       3, 'Row Exclusive',
       4, 'Share',
       5, 'Share Row Exclusive',
       6, 'Exclusive', 'None') lock_mode_requested,
 decode(locks.type,
       'MR', 'Media Recovery',
       'RT', 'Redo Thread',
       'UN', 'User Name',
       'TX', 'Transaction',
       'TM', 'DML',
       'UL', 'PL/SQL User Lock',
       'DX', 'Distributed Xaction',
       'CF', 'Control File',
       'IS', 'Instance State',
       'FS', 'File Set',
       'IR', 'Instance Recovery',
       'ST', 'Disk Space Transaction',
       'TS', 'Temp Segment',
       'IV', 'Library Cache Invalidation',
       'LS', 'Log Start or Log Switch',
       'RW', 'Row Wait',
       'SQ', 'Sequence Number',
       'TE', 'Extend Table',
       'TT', 'Temp Table',
       locks.type) lock_type,
 objs.owner object_owner,
 objs.object_name object_name,
 objs.object_type object_type,
 round( locks.ctime/60, 2 ) lock_time_in_minutes
from v$session vs,
         v$lock locks,
         all_objects objs,
         all_tables tbls
where locks.id1 = objs.object_id
 and vs.sid = locks.sid
 and objs.owner = tbls.owner
 and objs.object_name =  tbls.table_name
 and objs.owner != 'SYS'
 and locks.type = 'TM'
 order by lock_time_in_minutes;
 
 
 

  select 
   (select username from v$session where sid=a.sid) blocker,
   a.sid,
   ' is blocking ',
   (select username from v$session where sid=b.sid) blockee,
   b.sid
from 
   v$lock a, 
   v$lock b
where 
   a.block = 1
and 
   b.request > 0
and 
   a.id1 = b.id1
and 
   a.id2 = b.id2;
   
   
   select
   c.owner,
   c.object_name,
   c.object_type,
   b.sid,
   b.serial#,
   b.status,
   b.osuser,
   b.machine
from
   
   v$locked_object a ,
   v$session b,
   all_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id;
   
   
   
   --SET SERVEROUTPUT ON

BEGIN   
DBMS_OUTPUT.ENABLE (1000000);   
  DBMS_OUTPUT.put_line ('start ' || current_date); 
    FOR do_loop IN (SELECT session_id,   
    a.object_id,  
    xidsqn,   
    oracle_username,   
    b.OWNER OWNER,   
    b.object_name object_name, 
    b.object_type object_type  
    FROM v$locked_object A, all_objects b  
    WHERE xidsqn != 0 AND b.object_id = a.object_id) 
    LOOP  
        DBMS_OUTPUT.put_line ('.'); 
        DBMS_OUTPUT.put_line ('Blocking Session   : ' || do_loop.session_id);  
        DBMS_OUTPUT.put_line (
        'Object (Owner/Name): ' 
        || do_loop.OWNER 
        || '.' 
        || do_loop.object_name); 
        DBMS_OUTPUT.put_line ('Object Type        : ' || do_loop.object_type);  
        FOR next_loop 
        IN (SELECT SID  
        FROM v$lock 
        WHERE id2 = do_loop.xidsqn AND SID != do_loop.session_id)  
        LOOP 
            DBMS_OUTPUT.put_line ( 
            'Sessions being blocked   :  ' || next_loop.SID); 
        END LOOP; 
    END LOOP; 
END;



 select * from v$sqlAREA