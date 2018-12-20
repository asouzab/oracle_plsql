/* Formatted on 13/08/2018 09:37:12 (QP5 v5.318) */
SELECT DISTINCT
       AC.CD_ACAO,
       AC.DS_MENU,
       CASE
           WHEN X.IS_ADM_PROFILE = 1
           THEN
               (CASE
                    WHEN UPPER (AC.DS_ACAO) IN
                             (UPPER ('Pedidos/Home.aspx'),
                              UPPER ('NotasFiscais/Home.aspx'),
                              UPPER ('ContratoEletronico/Home.aspx'))
                    THEN
                        NULL
                    ELSE
                        AC.DS_ACAO
                END)
           ELSE
               AC.DS_ACAO
       END
           DS_ACAO,
       AC.DS_PROGRAMA,
       CASE
           WHEN UPPER (DS_ACAO) = 'SUBMENU' THEN NULL
           ELSE AC.CD_ACAO_SUPERIOR
       END
           CD_ACAO_SUPERIOR,
       AC.CD_ORDEM
  FROM CTF.ACAO            AC,
       CTF.SISTEMA         SI,
       CTF.SIGLA           SG,
       CTF.PERFIL          PF,
       CTF.PERFIL_ACAO     PA,
       CTF.USUARIO_PERFIL  UP,
       (SELECT COUNT (US_SIGLA.SG_SIGLA) IS_ADM_PROFILE
          FROM (SELECT S1.SG_SIGLA SG_SIGLA
                  FROM CTF.SIGLA  S1
                       INNER JOIN CTF.PERFIL P1 ON P1.CD_SIGLA = S1.CD_SIGLA
                       INNER JOIN CTF.USUARIO_PERFIL UP1
                           ON UP1.CD_PERFIL = P1.CD_PERFIL
                 WHERE UP1.CD_USUARIO = 3977) US_SIGLA
         WHERE UPPER (US_SIGLA.SG_SIGLA) = UPPER ('TUADM')) X
 WHERE     AC.CD_SISTEMA = SI.CD_SISTEMA
       AND PF.CD_SISTEMA = SI.CD_SISTEMA
       AND PF.CD_PERFIL = UP.CD_PERFIL
       AND AC.CD_ACAO = PA.CD_ACAO
       AND PA.CD_PERFIL = PF.CD_PERFIL
       AND SI.CD_SIGLA = SG.CD_SIGLA
 ;