       SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL(ca.qt_saldo, 0)  qt_saldo,
               ca.nu_ordem,
                nvl((SELECT NVL(SUM(cate.qt_saldo), 0) 
                FROM vnd.elo_carteira cate
                WHERE cate.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
                AND NVL(cate.qt_saldo, 0) > 0
                AND cate.ic_ativo = 'S'),0) qt_saldo_by_item ,
        NVL((SELECT NVL(SUM(aw.qt_semana), 0)
          FROM vnd.elo_agendamento_week aw 
         WHERE aw.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
           AND NVL(aw.qt_semana, 0) > 0),0) qt_semana_by_week               
                              
               
          FROM vnd.elo_carteira ca
         INNER JOIN vnd.elo_agendamento_item ai
            ON ai.cd_elo_agendamento_item = ca.cd_elo_agendamento_item
         INNER JOIN vnd.elo_agendamento_week aw
            ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item
         INNER JOIN vnd.elo_agendamento_supervisor ap
         on ap.CD_ELO_AGENDAMENTO_SUPERVISOR = ai.CD_ELO_AGENDAMENTO_SUPERVISOR
         WHERE --NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           --AND NVL(aw.qt_semana, 0) > 0
           ca.cd_elo_agendamento = 332
           AND ca.ic_ativo = 'S'
           AND ai.ic_ativo = 'S'
             and (null IS NULL OR ap.cd_sales_office = null)
               AND (831 IS NULL OR ap.cd_sales_group = 831)           
           
           
           
         ORDER BY ca.cd_elo_agendamento_item ASC, ca.nu_ordem ASC;
         
         
      
               
               
               select * from vnd.elo_agendamento_supervisor where cd_elo_agendamento = 332;
                select * from vnd.elo_agendamento where
                        cd_week = 'W172018' AND cd_centro_expedidor = '6080'
 cd_elo_agendamento = 334;
 
 
 
         SELECT COUNT(DISTINCT NU_SEMANA) FROM (

              SELECT aw.NU_SEMANA, aw.qt_emergencial, ai.cd_elo_agendamento_item

              FROM vnd.elo_agendamento_week aw

              LEFT OUTER JOIN vnd.elo_agendamento_item ai
                ON ai.cd_elo_agendamento_item = aw.cd_elo_agendamento_item

             INNER JOIN vnd.elo_agendamento_supervisor ap
                ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor

              LEFT OUTER JOIN vnd.elo_carteira ca
                ON ca.cd_elo_agendamento = ap.cd_elo_agendamento
               AND ca.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

             WHERE (null IS NULL OR ap.cd_sales_office = null)
               AND (831 IS NULL OR ap.cd_sales_group = 831)
               AND ap.cd_elo_agendamento = 332
               AND ap.ic_ativo = 'S'
               AND NVL(aw.qt_semana,0) > 0

--             GROUP BY aw.cd_elo_agendamento_week,
--                      aw.qt_semana
               GROUP BY aw.NU_SEMANA, aw.qt_semana, aw.qt_emergencial, ai.cd_elo_agendamento_item

            --HAVING (NVL(SUM(ca.qt_saldo),0) - NVL(SUM(ca.qt_agendada),0)) >= 0
             --  AND (aw.qt_semana - NVL(SUM(ca.qt_agendada),0)) >= 0
        );
        
        
        select * from vnd.elo_carteira where cd_elo_agendamento = 332
        and (qt_agendada_confirmada > 0 or qt_agendada > 0  )  and cd_incoterms = 'CIF' and cd_sales_group = 831;
        
        select * from vnd.elo_carteira where cd_elo_agendamento = 333 and qt_emergencial> 0;
        
        update vnd.elo_carteira
            set ic_emergencial = 'S',
            QT_EMERGENCIAL = 9999
 where cd_elo_agendamento = 332;
        
        select * from vnd.elo_status ;
        
        select * from vnd.elo_carteira_sap 
        where nu_carteira_version = '20180206140954';
        
UPDATE VND.ELO_CARTEIRA 
SET CD_STATUS_CEL_FINAL = 59 
WHERE CD_ELO_CARTEIRA IN (
108901,
108902,
108903,
108905,
108906,
108907,
108908

) ;       
        



        SELECT ca.cd_elo_carteira,
               ca.cd_elo_agendamento_item,
               NVL((SELECT aw.qt_emergencial 
               FROM VND.ELO_AGENDAMENTO_WEEK aw 
               where aw.CD_ELO_AGENDAMENTO_ITEM = ca.CD_ELO_AGENDAMENTO_ITEM 
               AND aw.qt_emergencial > 0 ) ,0) qt_saldo,
               nu_ordem
          FROM vnd.elo_carteira ca
         WHERE 1=1--NVL(ca.qt_saldo, 0) - NVL(ca.qt_agendada, 0) > 0
           AND ca.cd_elo_agendamento = 333
           --AND ca.cd_elo_agendamento_item = 45868
           AND ca.ic_ativo = 'S'
           --AND ca.ic_emergencial = 'S'
           AND EXISTS (SELECT 1 FROM VND.ELO_AGENDAMENTO_WEEK aws 
           WHERE aws.CD_ELO_AGENDAMENTO_ITEM = ca.CD_ELO_AGENDAMENTO_ITEM 
           AND aws.QT_EMERGENCIAL > 0 ) 
         ORDER BY ca.nu_ordem;
         
         
         update vnd.elo_agendamento_week 
         set qt_emergencial = 0312
         where cd_elo_agendamento_item = 45867;