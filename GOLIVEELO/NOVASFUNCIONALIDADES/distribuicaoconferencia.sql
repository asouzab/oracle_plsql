edit vnd.elo_agendamento
where cd_elo_agendamento = 333;

select * from vnd.elo_agendamento_day 
where cd_elo_agendamento_week in (

select 
--cd_elo_agendamento_week
*
 from vnd.elo_agendamento_week where cd_elo_agendamento_item in (
select cd_elo_agendamento_item from vnd.elo_carteira 
where cd_elo_agendamento = 723
and qt_agendada_confirmada > 0)
)

;

11694,997


select * from vnd.elo_carteira where cd_elo_agendamento_item = 45869; -- 45904;
334


select * from vnd.elo_carteira_day 
where cd_elo_carteira 
in 
(select cd_elo_carteira from vnd.elo_carteira
where cd_elo_agendamento = 318);

with cte_as as 
(
select ss.* from 
(


SELECT 
        
        ai.cd_elo_agendamento_item,
        aw.CD_ELO_AGENDAMENTO_WEEK,
        CA.CD_ELO_CARTEIRA,
        EMBINC.cd_grupo_embalagem,
        aw.nu_semana,
        EMBINC.nu_dia_semana,
        CA.QT_AGENDADA_CONFIRMADA ,
        NVL(ad.nu_quantidade,0) qt_agendamento,
        NVL((SELECT SUM(CT.QT_AGENDADA_CONFIRMADA) QT 
        FROM VND.ELO_CARTEIRA CT 
        WHERE CT.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
        AND CT.QT_AGENDADA_CONFIRMADA > 0
        ), 0) qt_disponivel, 
        
        (NVL(ad.nu_quantidade,0) / aw.qt_semana) 
        
        *  
        (NVL(CA.QT_AGENDADA_CONFIRMADA, 0) / (SELECT SUM(CT.QT_AGENDADA_CONFIRMADA) QT 
        FROM VND.ELO_CARTEIRA CT 
        WHERE CT.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
        AND CT.QT_AGENDADA_CONFIRMADA > 0
        ))
        *

        NVL((SELECT SUM(CT.QT_AGENDADA_CONFIRMADA) QT 
        FROM VND.ELO_CARTEIRA CT 
        WHERE CT.CD_ELO_AGENDAMENTO_ITEM = ai.CD_ELO_AGENDAMENTO_ITEM
        AND CT.QT_AGENDADA_CONFIRMADA > 0
        ), 0)        
      
        qt_disponivel_by_day 

        FROM elo_agendamento ag
        INNER JOIN elo_agendamento_supervisor ap
        ON ag.cd_elo_agendamento = ap.cd_elo_agendamento  
        INNER JOIN elo_agendamento_item ai
        ON ap.cd_elo_agendamento_supervisor = ai.cd_elo_agendamento_supervisor          

        INNER JOIN elo_agendamento_week aw
        ON aw.cd_elo_agendamento_item = ai.cd_elo_agendamento_item

        INNER JOIN VND.ELO_CARTEIRA CA
        ON ai.CD_ELO_AGENDAMENTO_ITEM = CA.CD_ELO_AGENDAMENTO_ITEM

        INNER JOIN VND.ELO_EMBALAGEM_INCOTERMS EMBINC    
        ON ai.CD_INCOTERMS = EMBINC.CD_INCOTERMS        

        LEFT JOIN elo_agendamento_day ad
        on ad.CD_ELO_AGENDAMENTO_WEEK = aw.CD_ELO_AGENDAMENTO_WEEK
        and ad.CD_GRUPO_EMBALAGEM = EMBINC.CD_GRUPO_EMBALAGEM
        and AD.NU_DIA_SEMANA = EMBINC.NU_DIA_SEMANA                
           

         WHERE
          1=1 
              --AND ai.cd_elo_agendamento_item = 45868-- pi_cd_elo_agendamento_item
         AND CA.QT_AGENDADA_CONFIRMADA > 0 
         AND AG.CD_ELO_AGENDAMENTO = 723
         and aw.QT_SEMANA > 0 
        -- and ag.cd_elo_status  in (8)
        -- and ca.cd_incoterms = 'FOB'
        -- AND ai.cd_cliente = '0004024442'

         GROUP BY  aw.CD_ELO_AGENDAMENTO_WEEK,
                    ai.cd_elo_agendamento_item,
                    CA.CD_ELO_CARTEIRA,
                    aw.qt_semana,
                   CA.QT_AGENDADA_CONFIRMADA,
                  --ad.cd_elo_agendamento_day,
                  EMBINC.cd_grupo_embalagem,
                  aw.nu_semana,
                  EMBINC.nu_dia_semana,
                  ad.nu_quantidade
         ORDER BY aw.CD_ELO_AGENDAMENTO_WEEK,
                  EMBINC.CD_GRUPO_EMBALAGEM,
                  EMBINC.nu_dia_semana
                  
) ss

)

select distinct aaa.*

, sst.* ,
(SELECT SUM(ts.qt_disponivel_by_day) from cte_as ts
where ts.cd_elo_agendamento_week = sst.cd_elo_agendamento_week) byweek,

(SELECT SUM(ts.qt_disponivel_by_day) from cte_as ts
where ts.cd_elo_agendamento_item = sst.cd_elo_agendamento_item) byitem


from cte_as sst
inner join vnd.elo_carteira ttt on sst.cd_elo_carteira = ttt.cd_elo_carteira 
inner join vnd.elo_agendamento aaa on ttt.cd_elo_agendamento = aaa.cd_elo_agendamento

where sst.qt_agendada_confirmada > 0 and qt_agendamento > 0 and qt_disponivel > 0 and qt_disponivel_by_day > 0 
;
                 


select qt_agendada_confirmada from vnd.elo_carteira where 
cd_elo_agendamento = 723;

14809

cd_elo_carteira = 182998 or cd_elo_agendamento_item = 78751;


select * from vnd.elo_agendamento_week where cd_elo_agendamento_item = 78751;

select * from vnd.elo_agendamento_day where cd_elo_agendamento_week = 5128;

