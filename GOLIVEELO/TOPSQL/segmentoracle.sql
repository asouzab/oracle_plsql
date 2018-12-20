select * from ELO_AGENDAMENTO_CEN_GRP_EMB;

SELECT * FROM V$DIAG_INFO;


          SELECT    ORIGINATING_TIMESTAMP, message_text 
          FROM       sys.X$DBGALERTEXT ORDER BY 1 DESC;
          
  begin        
DBMS_SPACE.SPACE_USAGE;
end;


SELECT *
    FROM user_SEGMENTS
    WHERE 1=1
    --SEGMENT_TYPE = 'INDEX'
    --tablespace_name = 'WEB_DATA'
    --and segment_name = 'SYS_LOB0000089242C00035$$'
    --AND OWNER='HR'
    ORDER BY SEGMENT_NAME;
    
    1048576
    
        
    SELECT *
    FROM user_FREE_SPACE
    WHERE TABLESPACE_NAME<>'SMUNDO';
    
    1048576
    393216

select * from ELO_CARTEIRA_PROT_HIST;


73072115712
2147483645

select * from all_source
where upper(text) like '%HISTORICO_CREDITO%' ;

HISTORICO_CREDITO


WEB_DATA	8	2205056	67108864	8192	8
WEB_DATA	8	1927168	67108864	8192	8
WEB_DATA	8	1598464	1578106880	192640	8
WEB_DATA	11	2449152	67108864	8192	11
WEB_DATA	12	2681856	50331648	6144	12
WEB_DATA	12	2663120	393216	    48	12

                        1048576
                        
                        
select *    FROM USER_EXTENTS	  ;                        



select table_name,
decode(partitioned,'/','NO',partitioned) partitioned,
    num_rows,
    data_mb,
    indx_mb,
    lob_mb,
    total_mb
     from (select datab.table_name,
             partitioning_type
             || decode (subpartitioning_type,
                        'none', null,
                        '/' || subpartitioning_type)
                    partitioned,
             num_rows,
             nvl(data_mb,0) data_mb,
             nvl(indx_mb,0) indx_mb,
             nvl(lob_mb,0) lob_mb,
             nvl(data_mb,0) + nvl(indx_mb,0) + nvl(lob_mb,0) total_mb
             from (  select table_name,
                   nvl(min(num_rows),0) num_rows,
                   round(sum(data_mb),2) data_mb
                      from (select table_name, num_rows, data_mb
                          from (select a.table_name,
                                a.num_rows,
                                b.bytes/1024/1024 as data_mb
                                  from user_tables a, user_segments b
                                  where a.table_name = b.segment_name))
                 group by table_name) datab,
                 (  select a.table_name,
                        round(sum(b.bytes/1024/1024),2) as indx_mb
                     from user_indexes a, user_segments b
                       where a.index_name = b.segment_name
                    group by a.table_name) indx,
                 (  select a.table_name,
                       round(sum(b.bytes/1024/1024),2) as lob_mb
                    from user_lobs a, user_segments b
                   where a.segment_name = b.segment_name
                    group by a.table_name) lobd,
                   user_part_tables part
             where     datab.table_name = indx.table_name(+)
                   and datab.table_name = lobd.table_name(+)
                   and datab.table_name = part.table_name(+))
  order by table_name;
  


  
  
  select * from VND.TOAD_PLAN_TABLE;