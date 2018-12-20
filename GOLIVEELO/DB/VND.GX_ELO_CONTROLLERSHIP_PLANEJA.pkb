CREATE OR REPLACE PACKAGE BODY VND."GX_ELO_CONTROLLERSHIP_PLANEJA" AS

  PROCEDURE PX_GET_REPORT(
        p_CD_POLO               in ELO_AGENDAMENTO.CD_POLO%type,
        p_DT_WEEK_START         in ELO_AGENDAMENTO.DT_WEEK_START%type,
        p_CD_CENTRO_EXPEDIDOR   in ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%type,
        p_CD_MACHINE            in ELO_AGENDAMENTO.CD_MACHINE%type,
        p_RETORNO               out T_CURSOR
) IS
  BEGIN

  OPEN P_RETORNO FOR
           SELECT 
           ag.DT_WEEK_START AS "Semana",
           car.CD_TIPO_AGENDAMENTO AS "Classificação",
           car.CD_TIPO_REPLAN AS "Tipo de Replan",
           car.DH_BACKLOG_CIF AS "Backlog desde",
           car.CD_CENTRO_EXPEDIDOR AS "Centro",
           ag.CD_MACHINE AS "Máquina",
           car.CD_INCOTERMS AS "Mod",
           CASE WHEN car.CD_INCOTERMS = 'FOB' 
                THEN car.CD_CLIENTE_PAGADOR  
                WHEN car.CD_INCOTERMS = 'CIF'
                THEN car.CD_CLIENTE_RECEBEDOR
           END AS "Num Cliente", 
           --car.NO_CLIENTE_PAGADOR AS "Nome Cliente",
           cli.NO_CLIENTE AS "Nome Cliente",
           agi.CD_COTA_COMPARTILHADA AS "Compartilhamento de Cota",
           car.CD_SALES_GROUP ||'-'|| us.NO_USUARIO AS "Supervisor",
           gre.DS_GRUPO_EMBALAGEM AS "Embalagem",
           CASE WHEN car.CD_INCOTERMS = 'CIF' 
                THEN ctf.CD_DIA_EXATO  
                ELSE NULL 
           END AS "Dia Exato(CIF)",        
           CASE WHEN car.CD_TIPO_AGENDAMENTO = 'REPLAN' AND SUBSTR(car.CD_TIPO_AGENDAMENTO ,1,8) != 'Inclusão'
                THEN (car.QT_PROGRAMADA * -1 ) 
                ELSE car.QT_PROGRAMADA
           END AS "Valor",

            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =1
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =1 
                 THEN crd.NU_QUANTIDADE 
            END AS "SEG",
            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =2
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =2 
                 THEN crd.NU_QUANTIDADE 
            END AS "TER",
            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =3
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =3 
                 THEN crd.NU_QUANTIDADE 
            END AS "QUA",
            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =4
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =4 
                 THEN crd.NU_QUANTIDADE 
            END AS "QUI",
            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =5
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =5 
                 THEN crd.NU_QUANTIDADE 
            END AS "SEX",
            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =6
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =6 
                 THEN crd.NU_QUANTIDADE 
            END AS "SÁB",
            CASE WHEN car.CD_INCOTERMS = 'CIF' AND ctf.NU_DIA_SEMANA IS NOT NULL AND ctf.NU_DIA_SEMANA =7
                 THEN ctf.NU_QUANTIDADE
                 WHEN crd.NU_DIA_SEMANA =7 
                 THEN crd.NU_QUANTIDADE 
            END AS "DOM"






           FROM ELO_AGENDAMENTO ag, ELO_AGENDAMENTO_SUPERVISOR ags, ELO_AGENDAMENTO_ITEM agi, ELO_CARTEIRA car,
                CTF.USUARIO us,GRUPO_EMBALAGEM gre, ELO_CARTEIRA_TORRE_FRETES ctf, ELO_CARTEIRA_DAY crd,
                ELO_AGENDAMENTO_CENTRO eac, CTF.CLIENTE cli 


           WHERE 
            trunc(eac.DT_WEEK_START) = trunc(p_DT_WEEK_START) AND eac.CD_POLO = p_CD_POLO
            AND ag.CD_POLO = p_CD_POLO AND  ag.CD_CENTRO_EXPEDIDOR=eac.CD_CENTRO_EXPEDIDOR
            AND ag.DT_WEEK_START=trunc(p_DT_WEEK_START) AND ag.IC_ATIVO='S'
            AND NVL(ag.CD_CENTRO_EXPEDIDOR,'') LIKE (CASE WHEN NVL(p_CD_CENTRO_EXPEDIDOR,'')='' THEN '%' ELSE p_CD_CENTRO_EXPEDIDOR END)
           -- AND CHAR(NVL(ag.CD_MACHINE,0)) LIKE CHAR((CASE WHEN CHAR(NVL(p_CD_MACHINE,0))='' THEN '%' ELSE CHAR(p_CD_MACHINE) END))
            AND (NVL(ag.CD_MACHINE,0)) LIKE ((CASE WHEN (NVL(p_CD_MACHINE,0))='' THEN '%' ELSE TO_CHAR(p_CD_MACHINE) END))
            /*(ag.CD_POLO = p_CD_POLO OR ag.CD_CENTRO_EXPEDIDOR IN (SELECT CD_CENTRO_EXPEDIDOR
                                          FROM ELO_AGENDAMENTO_CENTRO
                                          WHERE trim(CD_POLO) = NVL(trim(p_CD_POLO), null)
                                          AND trunc(DT_WEEK_START) = NVL(trunc(p_DT_WEEK_START),DT_WEEK_START)))

         AND ag.DT_WEEK_START = NVL(trunc(p_DT_WEEK_START),ag.DT_WEEK_START)
         AND ag.IC_ATIVO='S'

         /*AND ag.CD_ELO_AGENDAMENTO=car.CD_ELO_AGENDAMENTO 
         AND car.IC_ATIVO='S'*/

         AND ag.CD_ELO_AGENDAMENTO=ags.CD_ELO_AGENDAMENTO

         AND ags.CD_ELO_AGENDAMENTO_SUPERVISOR=agi.CD_ELO_AGENDAMENTO_SUPERVISOR
         AND agi.IC_ATIVO ='S'

         AND car.CD_ELO_AGENDAMENTO_ITEM = agi.CD_ELO_AGENDAMENTO_ITEM
         AND car.IC_ATIVO='S'
         AND car.QT_AGENDADA_CONFIRMADA > 0

         AND ags.CD_ELO_AGENDAMENTO_SUPERVISOR= us.CD_USUARIO

         AND car.CD_GRUPO_EMBALAGEM = gre.CD_GRUPO_EMBALAGEM
         AND gre.IC_ATIVO='S'

         AND ctf.CD_ELO_CARTEIRA=car.CD_ELO_CARTEIRA

         AND crd.CD_ELO_CARTEIRA = car.CD_ELO_CARTEIRA

         AND cli.CD_CLIENTE  = car.CD_CLIENTE 
         AND (cli.CD_CLIENTE  = car.CD_CLIENTE_PAGADOR  OR cli.CD_CLIENTE  = car.CD_CLIENTE_RECEBEDOR);
         null;
  END PX_GET_REPORT;



PROCEDURE PX_GET_REPORT2(
        p_CD_POLO         in ELO_AGENDAMENTO.CD_POLO%type,
        p_DT_WEEK_START   in ELO_AGENDAMENTO.DT_WEEK_START%type,
        p_RETORNO         out T_CURSOR
)
IS
  BEGIN

  OPEN P_RETORNO FOR
            SELECT * FROM ELO_AGENDAMENTO ag
           WHERE
           (ag.CD_POLO=p_CD_POLO OR 
           ag.CD_CENTRO_EXPEDIDOR IN (SELECT CD_CENTRO_EXPEDIDOR
                                                                FROM ELO_AGENDAMENTO_CENTRO
                                                               WHERE
                                                                trim(CD_POLO) = NVL(trim(p_CD_POLO),null)
                                                                   AND
                                                                      trunc(DT_WEEK_START) = NVL(trunc(p_DT_WEEK_START),DT_WEEK_START)))
          and ag.DT_WEEK_START = NVL(trunc(p_DT_WEEK_START),ag.DT_WEEK_START)
         and ag.IC_ATIVO='S';  
          null;
  END PX_GET_REPORT2;

END GX_ELO_CONTROLLERSHIP_PLANEJA;


/