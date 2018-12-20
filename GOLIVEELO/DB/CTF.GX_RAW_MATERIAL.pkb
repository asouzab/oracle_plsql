CREATE OR REPLACE PACKAGE BODY CTF.GX_RAW_MATERIAL
IS
    PROCEDURE PX_RAW_MATERIAL (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT SUBSTR (PS.CD_PRODUTO_SAP, 10, 9) "CD_PRODUTO_SAP",
                     PS.NO_PRODUTO_SAP,
                     PR.CD_RAW_MATERIAL_GROUP,
                     MG.NO_RAW_MATERIAL_GROUP,
                     PR.QT_PERCENTAGE
                FROM CTF.PRODUTO_SAP PS
                     INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PR
                         ON PS.CD_PRODUTO_SAP = PR.CD_PRODUTO_SAP
                     INNER JOIN CTF.RAW_MATERIAL_GROUP MG
                         ON MG.CD_RAW_MATERIAL_GROUP = PR.CD_RAW_MATERIAL_GROUP
            ORDER BY PS.CD_PRODUTO_SAP, MG.NO_RAW_MATERIAL_GROUP DESC;
    END PX_RAW_MATERIAL;

    PROCEDURE PX_PRODUTO_SAP (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR   SELECT CD_PRODUTO_SAP, NO_PRODUTO_SAP
                               FROM CTF.PRODUTO_SAP
                           ORDER BY CD_PRODUTO_SAP, NO_PRODUTO_SAP DESC;
    END PX_PRODUTO_SAP;

    PROCEDURE PX_PRODUTO_SAP_AUTOCOMPLETE (P_FILTRO    IN     VARCHAR2,
                                           P_RETORNO      OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT CD_PRODUTO_SAP,
                     SUBSTR (CD_PRODUTO_SAP, 10, 9) || ' - ' || NO_PRODUTO_SAP
                         "NO_PRODUTO_SAP"
                FROM CTF.PRODUTO_SAP
               WHERE     (   CD_PRODUTO_SAP LIKE '%' || P_FILTRO || '%'
                          OR UPPER (NO_PRODUTO_SAP) LIKE '%' || P_FILTRO || '%')
                     AND IC_ATIVO = 'S'
            --AND ROWNUM <= 100
            ORDER BY NO_PRODUTO_SAP DESC;
    END PX_PRODUTO_SAP_AUTOCOMPLETE;

    PROCEDURE PX_PRODUTO_SAP_AUTOCOMPLETE2 (P_FILTRO    IN     VARCHAR2,
                                            P_RETORNO      OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR   SELECT CD_PRODUTO_SAP, NO_PRODUTO_SAP
                               FROM CTF.PRODUTO_SAP
                           ORDER BY CD_PRODUTO_SAP;
    END PX_PRODUTO_SAP_AUTOCOMPLETE2;

    PROCEDURE PX_RAW_MATERIAL_GROUP (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT CD_RAW_MATERIAL_GROUP, NO_RAW_MATERIAL_GROUP
                FROM CTF.RAW_MATERIAL_GROUP
            ORDER BY CD_RAW_MATERIAL_GROUP, NO_RAW_MATERIAL_GROUP ASC;
    END PX_RAW_MATERIAL_GROUP;

    PROCEDURE PU_RAW_MATERIAL_GROUP (
        P_CD_PRODUTO_SAP          IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_PRODUTO_SAP%TYPE,
        P_CD_RAW_MATERIAL_GROUP   IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_RAW_MATERIAL_GROUP%TYPE,
        P_QT_PERCENTAGE           IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.QT_PERCENTAGE%TYPE,
        P_RETORNO                    OUT T_CURSOR)
    AS
    BEGIN
        DECLARE
            dPerc   NUMERIC;
        BEGIN
              /*VERIFICA SE O REGISTRO EXISTE, SE O VALOR TOTAL GRAVADO, SOMADO AO PERCENTUAL PASSADO,
              NAO ULTRAPASSA 100%*/
              SELECT SUM (QT_PERCENTAGE)
                INTO dPerc
                FROM CTF.PRODUTO_RAW_MATERIAL_GROUP
               WHERE     CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
                     AND CD_RAW_MATERIAL_GROUP = P_CD_RAW_MATERIAL_GROUP
            GROUP BY CD_PRODUTO_SAP, QT_PERCENTAGE;

            IF (dPerc >= 100 OR P_QT_PERCENTAGE >= 100)
            THEN
                OPEN P_RETORNO FOR SELECT '2' AS P_SUCESSO FROM DUAL;

                RETURN;
            ELSE
                UPDATE CTF.PRODUTO_RAW_MATERIAL_GROUP
                   SET QT_PERCENTAGE = P_QT_PERCENTAGE
                 WHERE     CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
                       AND CD_RAW_MATERIAL_GROUP = P_CD_RAW_MATERIAL_GROUP;

                COMMIT;

                OPEN P_RETORNO FOR SELECT '1' AS P_SUCESSO FROM DUAL;
            END IF;
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                RAISE_APPLICATION_ERROR (
                    -20001,
                    'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                ROLLBACK;
            END;
    END PU_RAW_MATERIAL_GROUP;

    PROCEDURE PD_RAW_MATERIAL_GROUP (
        P_CD_PRODUTO_SAP          IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_PRODUTO_SAP%TYPE,
        P_CD_RAW_MATERIAL_GROUP   IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_RAW_MATERIAL_GROUP%TYPE,
        P_RETORNO                    OUT T_CURSOR)
    AS
    BEGIN
        DELETE CTF.PRODUTO_RAW_MATERIAL_GROUP
         WHERE     CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
               AND CD_RAW_MATERIAL_GROUP = P_CD_RAW_MATERIAL_GROUP;

        COMMIT;

        OPEN P_RETORNO FOR SELECT '1' AS P_SUCESSO FROM DUAL;
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                RAISE_APPLICATION_ERROR (
                    -20001,
                    'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                ROLLBACK;
            END;
    END PD_RAW_MATERIAL_GROUP;

    PROCEDURE PI_RAW_MATERIAL_GROUP (
        P_CD_PRODUTO_SAP          IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_PRODUTO_SAP%TYPE,
        P_CD_RAW_MATERIAL_GROUP   IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_RAW_MATERIAL_GROUP%TYPE,
        P_QT_PERCENTAGE           IN     CTF.PRODUTO_RAW_MATERIAL_GROUP.QT_PERCENTAGE%TYPE,
        P_RETORNO                    OUT T_CURSOR)
    AS
    BEGIN
        DECLARE
            l_exists    FLOAT;
            dPerc       DECIMAL;
            dAgregado   DECIMAL;
        BEGIN
            SELECT CASE
                       WHEN EXISTS
                                (SELECT CD_PRODUTO_SAP
                                   FROM CTF.PRODUTO_RAW_MATERIAL_GROUP
                                  WHERE     CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
                                        AND CD_RAW_MATERIAL_GROUP =
                                            P_CD_RAW_MATERIAL_GROUP)
                       THEN
                           1
                       ELSE
                           0
                   END
              INTO l_exists
              FROM DUAL;

            /*VERIFICA SE O REGISTRO EXISTE, SE O VALOR TOTAL GRAVADO, SOMADO AO PERCENTUAL PASSADO,
                NAO ULTRAPASSA 100%*/
            SELECT NVL (SUM (QT_PERCENTAGE), 0)
              INTO dPerc
              FROM CTF.PRODUTO_RAW_MATERIAL_GROUP
             WHERE CD_PRODUTO_SAP LIKE '%' || P_CD_PRODUTO_SAP || '%';

            --AND   CD_RAW_MATERIAL_GROUP = P_CD_RAW_MATERIAL_GROUP;
            --GROUP BY CD_PRODUTO_SAP, QT_PERCENTAGE;

            SELECT dPerc + P_QT_PERCENTAGE
              INTO dAgregado
              FROM DUAL;

            IF (dPerc > 100 OR P_QT_PERCENTAGE > 100 OR dAgregado > 100)
            THEN
                OPEN P_RETORNO FOR SELECT '2' AS P_SUCESSO FROM DUAL;

                RETURN;
            ELSE
                /*SE O REGISTRO NAO EXISTE, CODIGO DE PRODUTO SAP + CODIGO DA MATERIA PRIMA, INCLUIR*/
                IF (l_exists = 0)
                THEN
                    INSERT INTO CTF.PRODUTO_RAW_MATERIAL_GROUP (
                                    CD_PRODUTO_SAP,
                                    CD_RAW_MATERIAL_GROUP,
                                    QT_PERCENTAGE)
                             VALUES (P_CD_PRODUTO_SAP,
                                     P_CD_RAW_MATERIAL_GROUP,
                                     P_QT_PERCENTAGE);

                    COMMIT;

                    OPEN P_RETORNO FOR SELECT '1' AS P_SUCESSO FROM DUAL;
                ELSE
                    OPEN P_RETORNO FOR SELECT '0' AS P_SUCESSO FROM DUAL;
                END IF;
            END IF;
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                RAISE_APPLICATION_ERROR (
                    -20001,
                    'ERRO ENCONTRADO - ' || SQLCODE || ' -ERROR- ' || SQLERRM);
                ROLLBACK;
            END;
    END PI_RAW_MATERIAL_GROUP;

    PROCEDURE PX_RAW_MATERIAL_MATRIX_COLUMNS (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT LISTAGG ('' || NO_RAW_MATERIAL_GROUP || '|')
                       WITHIN GROUP (ORDER BY NO_RAW_MATERIAL_GROUP)
                       "COLUNAS"
              FROM CTF.RAW_MATERIAL_GROUP;
    END PX_RAW_MATERIAL_MATRIX_COLUMNS;


    PROCEDURE PX_RAW_MATERIAL_MATRIX (
        P_CD_POLO               IN     VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   IN     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            IN     VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_CD_WEEK               IN     VND.ELO_AGENDAMENTO.CD_WEEK%TYPE DEFAULT NULL,
        P_RETORNO                  OUT T_CURSOR)
    IS
        lista     VARCHAR2 (500);
        qry       VARCHAR2 (1000);
        bFilter   CHAR (1);
    BEGIN
        bFilter := '';

        SELECT LISTAGG ('''' || NO_RAW_MATERIAL_GROUP || ''',')
                   WITHIN GROUP (ORDER BY NO_RAW_MATERIAL_GROUP)
          INTO lista
          FROM CTF.RAW_MATERIAL_GROUP;

        lista := SUBSTR (lista, 1, LENGTH (lista) - 1);

        qry :=
               'SELECT * '
            || 'FROM ( '
            || ' SELECT DISTINCT RMG.NO_RAW_MATERIAL_GROUP, SUBSTR(PMG.CD_PRODUTO_SAP, 10,9) "CD_PRODUTO_SAP", ROUND(QT_PERCENTAGE, 1) "QT_PERCENTAGE" '
            || ' FROM CTF.PRODUTO_RAW_MATERIAL_GROUP PMG '
            || ' INNER JOIN CTF.RAW_MATERIAL_GROUP RMG ON RMG.CD_RAW_MATERIAL_GROUP = PMG.CD_RAW_MATERIAL_GROUP '
            || ' LEFT JOIN VND.ELO_CARTEIRA EC ON PMG.CD_PRODUTO_SAP = EC.CD_PRODUTO_SAP '
            || ' LEFT JOIN VND.ELO_AGENDAMENTO EA ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO ';

        IF (   P_CD_POLO <> 'null'
            OR P_CD_CENTRO_EXPEDIDOR <> 'null'
            OR P_CD_MACHINE <> 'null'
            OR P_CD_WEEK <> 'null')
        THEN
            qry := qry || ' WHERE ';
        END IF;

        IF (P_CD_POLO <> 'null')
        THEN
            qry := qry || ' EA.CD_POLO = ''' || P_CD_POLO || '''';
            bFilter := 'S';
        END IF;

        IF (P_CD_CENTRO_EXPEDIDOR <> 'null')
        THEN
            IF bFilter = 'S'
            THEN
                qry :=
                       qry
                    || ' AND EA.CD_CENTRO_EXPEDIDOR = '''
                    || P_CD_CENTRO_EXPEDIDOR
                    || '''';
            ELSE
                qry :=
                       qry
                    || ' EA.CD_CENTRO_EXPEDIDOR = '''
                    || P_CD_CENTRO_EXPEDIDOR
                    || '''';
                bFilter := 'S';
            END IF;
        END IF;

        IF (P_CD_MACHINE <> 'null')
        THEN
            IF bFilter = 'S'
            THEN
                qry := qry || ' AND CD_MACHINE = ''' || P_CD_MACHINE || '''';
            ELSE
                qry := qry || ' CD_MACHINE = ''' || P_CD_MACHINE || '''';
                bFilter := 'S';
            END IF;
        END IF;

        IF (P_CD_WEEK <> 'null')
        THEN
            IF bFilter = 'S'
            THEN
                qry := qry || ' AND EA.CD_WEEK = ''' || P_CD_WEEK || '''';
            ELSE
                qry := qry || ' EA.CD_WEEK = ''' || P_CD_WEEK || '''';
                bFilter := 'S';
            END IF;
        END IF;

        qry :=
               qry
            || ' GROUP BY CUBE(RMG.NO_RAW_MATERIAL_GROUP, PMG.CD_PRODUTO_SAP, QT_PERCENTAGE) ';
        qry :=
            qry || ' ORDER BY PMG.CD_PRODUTO_SAP, RMG.NO_RAW_MATERIAL_GROUP ';

        qry :=
               qry
            || ' ) PIVOT '
            || ' ( '
            || ' SUM(QT_PERCENTAGE) '
            || ' FOR NO_RAW_MATERIAL_GROUP IN ('
            || lista
            || ', '''' AS TOTAL)'
            || ' )';

        qry := qry || ' WHERE CD_PRODUTO_SAP IS NOT NULL ';

        OPEN P_RETORNO FOR qry;
    END PX_RAW_MATERIAL_MATRIX;


    PROCEDURE PX_RAW_PRODUTO_SAP_EXCEPTION (
        P_CD_POLO               IN     VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   IN     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            IN     VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_CD_WEEK               IN     VND.ELO_AGENDAMENTO.CD_WEEK%TYPE DEFAULT NULL,
        P_RETORNO                  OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT DISTINCT
                     EAI.CD_PRODUTO_SAP,
                     SUBSTR (EAI.CD_PRODUTO_SAP, 10, 9) "PRODUTO_SAP"
                FROM VND.ELO_AGENDAMENTO_ITEM EAI
                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                         ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                            EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
                     INNER JOIN VND.ELO_AGENDAMENTO EA
                         ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
               WHERE     EAI.CD_PRODUTO_SAP NOT IN
                             (SELECT DISTINCT RMG.CD_PRODUTO_SAP
                                FROM CTF.PRODUTO_RAW_MATERIAL_GROUP RMG)
                     AND (P_CD_WEEK IS NULL OR EA.CD_WEEK = P_CD_WEEK)
                     AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
                     AND (   P_CD_CENTRO_EXPEDIDOR IS NULL
                          OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
                     AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE)
            ORDER BY EAI.CD_PRODUTO_SAP;
    END PX_RAW_PRODUTO_SAP_EXCEPTION;

    PROCEDURE PX_GERENTE_NACIONAL (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT DISTINCT
                     USU.CD_USUARIO_ORIGINAL,
                     USU.CD_USUARIO_ORIGINAL || ' - ' || USU.NO_USUARIO
                         "NO_USUARIO"
                FROM CTF.USUARIO USU
                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                         ON USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_DISTRICT
               WHERE USU.IC_ATIVO <> 'N'
            ORDER BY 1;
    END PX_GERENTE_NACIONAL;

    PROCEDURE PX_GERENTE_REGIONAL (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT DISTINCT
                     USU.CD_USUARIO_ORIGINAL,
                     USU.CD_USUARIO_ORIGINAL || ' - ' || USU.NO_USUARIO
                         "NO_USUARIO"
                FROM CTF.USUARIO USU
                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                         ON USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_OFFICE
               WHERE USU.IC_ATIVO <> 'N'
            ORDER BY 2;
    END PX_GERENTE_REGIONAL;

    PROCEDURE PX_SUPERVISORES (P_RETORNO OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT DISTINCT
                     USU.CD_USUARIO_ORIGINAL,
                     USU.CD_USUARIO_ORIGINAL || ' - ' || USU.NO_USUARIO
                         "NO_USUARIO"
                FROM CTF.USUARIO USU
                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                         ON USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP
               WHERE USU.IC_ATIVO <> 'N'
            ORDER BY 2;
    END PX_SUPERVISORES;

    PROCEDURE PX_RAW_MATERIAL_COTA_OLD (
        P_CD_POLO               IN     VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   IN     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            IN     VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_CD_WEEK               IN     VND.ELO_AGENDAMENTO.CD_WEEK%TYPE DEFAULT NULL,
        P_RETORNO                  OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT DISTINCT
                     EAI.CD_PRODUTO_SAP,
                     EA.CD_POLO,
                     EA.CD_CENTRO_EXPEDIDOR,
                     EAPC.CD_CENTRO_EXPEDIDOR
                         AS "EXPEDIDOR CENTRO POLO",
                     EACM.CD_CENTRO_EXPEDIDOR
                         AS "EXPEDIDOR CENTRO MAQUINA",
                     EA.CD_MACHINE,
                     EA.DT_WEEK_START,
                     EAS.CD_SALES_DISTRICT
                         AS "GERENTE NACIONAL",
                     EAS.CD_SALES_OFFICE
                         AS "GERENTE REGIONAL",
                     EAS.CD_SALES_GROUP
                         AS "SUPERVISOR"--, SUM(RMG.QT_PERCENTAGE) AS "ORCADO"
                                        ,
                     COUNT (RMG.CD_RAW_MATERIAL_GROUP)
                         AS "ORCADO",
                     CASE
                         WHEN NF.CD_TIPO_NOTA_FISCAL = 'N1'
                         THEN
                             '+ ' || NFI.NU_QUANTIDADE
                         WHEN NF.CD_TIPO_NOTA_FISCAL = 'N4'
                         THEN
                             '- ' || NFI.NU_QUANTIDADE
                         ELSE
                             '1'
                     END
                         AS NU_QUANTIDADE,
                     COUNT (RMG2.CD_RAW_MATERIAL_GROUP)
                         AS "ACUMULADO",
                     CASE
                         WHEN COUNT (RMG.CD_RAW_MATERIAL_GROUP) = 0
                         THEN
                             0
                         WHEN COUNT (RMG2.CD_RAW_MATERIAL_GROUP) = 0
                         THEN
                             0
                         ELSE
                             (  COUNT (RMG2.CD_RAW_MATERIAL_GROUP)
                              / COUNT (RMG.CD_RAW_MATERIAL_GROUP))
                     END
                         "STATUS ACUMULADO",
                     COUNT (RMG.CD_RAW_MATERIAL_GROUP)
                         "AGENDADO",
                     CASE
                         WHEN COUNT (RMG2.CD_RAW_MATERIAL_GROUP) = 0
                         THEN
                             NULL
                         WHEN COUNT (RMG2.CD_RAW_MATERIAL_GROUP) = 0
                         THEN
                             NULL
                         ELSE
                             (  (  COUNT (RMG2.CD_RAW_MATERIAL_GROUP)
                                 + COUNT (RMG.CD_RAW_MATERIAL_GROUP))
                              / NFI.NU_QUANTIDADE)
                     END
                         "STATUS POS-PLAN"
                FROM VND.ELO_AGENDAMENTO EA
                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                         ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
                     INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI
                         ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                            EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
                     LEFT JOIN VND.ELO_AGENDAMENTO_POLO_CENTRO EAPC
                         ON (    EA.CD_ELO_AGENDAMENTO =
                                 EAPC.CD_ELO_AGENDAMENTO
                             AND EA.CD_POLO = EAPC.CD_POLO)
                     LEFT JOIN VND.ELO_AGENDAMENTO_CENTRO_MACHINE EACM
                         ON (EA.CD_ELO_AGENDAMENTO = EACM.CD_ELO_AGENDAMENTO)
                     INNER JOIN VND.PLANEJAMENTO PLANEJ
                         ON EA.CD_CENTRO_EXPEDIDOR = PLANEJ.CD_CENTRO_EXPEDIDOR
                     INNER JOIN VND.PERIODO PER
                         ON PER.CD_PERIODO = PLANEJ.CD_PERIODO
                     INNER JOIN CTF.USUARIO USU
                         ON USU.CD_USUARIO = PLANEJ.CD_USUARIO
                     INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                         ON (   USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_DISTRICT
                             OR USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_OFFICE
                             OR USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP)
                     INNER JOIN VND.DETALHE_PLANEJAMENTO DETPLAN
                         ON PLANEJ.CD_PLANEJAMENTO = DETPLAN.CD_PLANEJAMENTO
                     LEFT JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP RMG
                         ON EAI.CD_PRODUTO_SAP = RMG.CD_PRODUTO_SAP
                     LEFT JOIN VND.ITEM_NOTA_FISCAL NFI
                         ON EAI.CD_PRODUTO_SAP = NFI.CD_PRODUTO_SAP
                     LEFT JOIN VND.NOTA_FISCAL NF
                         ON NF.CD_NF_CONTROLE = NFI.CD_NF_CONTROLE
                     LEFT JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP RMG2
                         ON RMG2.CD_PRODUTO_SAP = NFI.CD_PRODUTO_SAP
               WHERE     (EA.IC_ATIVO <> 'N')
                     AND (EAI.IC_ATIVO <> 'N')
                     AND PER.CD_TIPO_PLANEJAMENTO = 3
                     AND DETPLAN.IC_ATIVO <> 'N'
            --AND (NF.CD_TIPO_NOTA_FISCAL = 'N1' OR NF.CD_TIPO_NOTA_FISCAL = 'N2')
            --AND NF.IC_CARTEIRA = 'S'
            GROUP BY EAI.CD_PRODUTO_SAP,
                     EA.CD_POLO,
                     EA.CD_CENTRO_EXPEDIDOR,
                     EAPC.CD_CENTRO_EXPEDIDOR,
                     EACM.CD_CENTRO_EXPEDIDOR,
                     EA.CD_MACHINE,
                     EA.DT_WEEK_START,
                     EAS.CD_SALES_DISTRICT,
                     EAS.CD_SALES_OFFICE,
                     EAS.CD_SALES_GROUP,
                     NF.CD_TIPO_NOTA_FISCAL,
                     NU_QUANTIDADE,
                     RMG.CD_RAW_MATERIAL_GROUP,
                     RMG2.CD_RAW_MATERIAL_GROUP;
    END PX_RAW_MATERIAL_COTA_OLD;

    PROCEDURE PX_RAW_MATERIAL_COTA (
        P_CD_WEEK               IN     VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_DH_EMISSAO            IN     VARCHAR2,
        P_CD_POLO               IN     VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   IN     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            IN     VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_CD_SALES_DISTRICT     IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_DISTRICT%TYPE DEFAULT NULL,
        P_CD_SALES_OFFICE       IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE DEFAULT NULL,
        P_CD_SALES_GROUP        IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE DEFAULT NULL,
        P_RETORNO                  OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
            SELECT DISTINCT
                   EA.CD_CENTRO_EXPEDIDOR
                       "Centro",
                   USU.NO_USUARIO
                       "Gerente Nacional",
                   USU2.NO_USUARIO
                       AS "Gerente Regional",
                   USU3.NO_USUARIO
                       AS "Supervisor",
                   RMG.NO_RAW_MATERIAL_GROUP
                       "Insumo",
                   GX_RAW_MATERIAL.FX_GET_ORCADO_COTA (PRMG.CD_PRODUTO_SAP,
                                                       EA.DT_WEEK_START)
                       "Orçado",
                   NVL (
                       GX_RAW_MATERIAL.FX_GET_ACUMULADO_COTA (
                           PRMG.CD_PRODUTO_SAP,
                           EA.DT_WEEK_START),
                       0)
                       "Acumulado",
                   GX_RAW_MATERIAL.FX_GET_AGENDADO_COTA (
                       RMG.CD_RAW_MATERIAL_GROUP,
                       EA.CD_WEEK)
                       "Plan W+1"
              --, RMG.CD_RAW_MATERIAL_GROUP "NO INSUMO"
              --, EA.DT_WEEK_START
              --,TO_NUMBER(TO_CHAR(EA.DT_WEEK_START,'MM')) "MES"
              --, PRMG.CD_PRODUTO_SAP "Produto"
              --, EA.CD_ELO_STATUS
              FROM VND.ELO_CARTEIRA  EC
                   INNER JOIN VND.ELO_AGENDAMENTO EA
                       ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
                   INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI
                       ON EAI.CD_ELO_AGENDAMENTO_ITEM =
                          EC.CD_ELO_AGENDAMENTO_ITEM
                   LEFT JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                       ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                          EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
                   LEFT JOIN CTF.USUARIO USU
                       ON USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_DISTRICT
                   INNER JOIN CTF.USUARIO USU2
                       ON USU2.CD_USUARIO_ORIGINAL = EAS.CD_SALES_OFFICE
                   LEFT JOIN CTF.USUARIO USU3
                       ON USU3.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP
                   INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                       ON PRMG.CD_PRODUTO_SAP =
                          LPAD (TRIM (EC.CD_PRODUTO_SAP), 18, '0')
                   INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                       ON RMG.CD_RAW_MATERIAL_GROUP =
                          PRMG.CD_RAW_MATERIAL_GROUP
             WHERE     (P_CD_WEEK IS NULL OR EA.CD_WEEK = P_CD_WEEK)
                   AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
                   AND (   P_CD_CENTRO_EXPEDIDOR IS NULL
                        OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
                   AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE)
                   AND (   P_CD_SALES_DISTRICT IS NULL
                        OR EAS.CD_SALES_DISTRICT = P_CD_SALES_DISTRICT)
                   AND (   P_CD_SALES_OFFICE IS NULL
                        OR EAS.CD_SALES_OFFICE = P_CD_SALES_OFFICE)
                   AND (   P_CD_SALES_GROUP IS NULL
                        OR EAS.CD_SALES_GROUP = P_CD_SALES_GROUP);
    END PX_RAW_MATERIAL_COTA;

    PROCEDURE PX_RAW_MATERIAL_COTA_AGRUPADO (
        P_CD_WEEK               IN     VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_DH_EMISSAO            IN     VARCHAR2,
        P_CD_POLO               IN     VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   IN     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            IN     VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_CD_SALES_DISTRICT     IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_DISTRICT%TYPE DEFAULT NULL,
        P_CD_SALES_OFFICE       IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE DEFAULT NULL,
        P_CD_SALES_GROUP        IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE DEFAULT NULL,
        P_RETORNO                  OUT T_CURSOR)
    IS
        iCont   NUMBER;
        dWEEK   VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE;
    BEGIN
        SELECT COUNT (EA.DT_WEEK_START)
          INTO iCont
          FROM VND.ELO_AGENDAMENTO EA
         WHERE     EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
               AND EA.CD_WEEK = P_CD_WEEK;

        IF (iCont > 0)
        THEN
            iCont := 0;

            SELECT EA.DT_WEEK_START
              INTO dWEEK
              FROM VND.ELO_AGENDAMENTO EA
             WHERE     EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
                   AND EA.CD_WEEK = P_CD_WEEK;

            SELECT COUNT (PLA.CD_PERIODO)
              INTO iCont
              FROM VND.PLANEJAMENTO PLA
             WHERE PLA.CD_PERIODO =
                   (SELECT cd_periodo
                      FROM (  SELECT pe.cd_periodo
                                FROM vnd.periodo pe
                                     INNER JOIN vnd.tipo_planejamento tp
                                         ON tp.cd_tipo_planejamento =
                                            pe.cd_tipo_planejamento
                               WHERE     UPPER (tp.sg_tipo_planejamento) =
                                         'MENSAL'
                                     AND (    pe.dt_periodo_de <=
                                              TRUNC (dWEEK, 'MM')
                                          AND pe.dt_periodo_ate >=
                                              TRUNC (dWEEK, 'MM'))
                            ORDER BY pe.dt_referencia DESC)
                     WHERE ROWNUM = 1);

            IF (iCont > 0)
            THEN
                OPEN P_RETORNO FOR
                      SELECT DISTINCT
                             RESULTADO.CD_CENTRO_EXPEDIDOR,
                             RESULTADO.CD_PRODUTO_SAP,
                             "GERENTE NACIONAL",
                             "GERENTE REGIONAL",
                             "SUPERVISOR",
                             RMG.NO_RAW_MATERIAL_GROUP
                                 "Insumo",
                             DT_WEEK_START,
                             TO_CHAR (
                                 ((PRMG.QT_PERCENTAGE * DET.QT_VALOR) / 100),
                                 '99999D99')
                                 "Orcado",
                             TO_CHAR (
                                 (  (PRMG.QT_PERCENTAGE * INF.NU_QUANTIDADE)
                                  / 100),
                                 '99999D99')
                                 "Acumulado",
                             TO_CHAR (
                                 (  (  (  (  PRMG.QT_PERCENTAGE
                                           * INF.NU_QUANTIDADE)
                                        / 100)
                                     * (  (PRMG.QT_PERCENTAGE * DET.QT_VALOR)
                                        / 100))
                                  / 100),
                                 '99999D99')
                                 "Status Acumulado",
                             TO_CHAR (
                                 (  (  PRMG.QT_PERCENTAGE
                                     * QT_AGENDADA_CONFIRMADA)
                                  / 100),
                                 '99999D99')
                                 "Plan W+1"
                        FROM (SELECT EA.CD_CENTRO_EXPEDIDOR,
                                     EC.CD_PRODUTO_SAP,
                                     USU1.NO_USUARIO "GERENTE NACIONAL",
                                     USU2.NO_USUARIO "GERENTE REGIONAL",
                                     USU3.NO_USUARIO "SUPERVISOR",
                                     EA.DT_WEEK_START,
                                     EC.QT_AGENDADA_CONFIRMADA
                                FROM VND.ELO_CARTEIRA EC
                                     INNER JOIN VND.ELO_AGENDAMENTO EA
                                         ON EA.CD_ELO_AGENDAMENTO =
                                            EC.CD_ELO_AGENDAMENTO
                                     INNER JOIN
                                     VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                                         ON EAS.CD_ELO_AGENDAMENTO =
                                            EA.CD_ELO_AGENDAMENTO
                                     INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI
                                         ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                                            EAI.CD_ELO_AGENDAMENTO_ITEM
                                     LEFT JOIN CTF.USUARIO USU1
                                         ON USU1.CD_USUARIO_ORIGINAL =
                                            EAS.CD_SALES_DISTRICT
                                     INNER JOIN CTF.USUARIO USU2
                                         ON USU2.CD_USUARIO_ORIGINAL =
                                            EAS.CD_SALES_OFFICE
                                     INNER JOIN CTF.USUARIO USU3
                                         ON USU3.CD_USUARIO_ORIGINAL =
                                            EAS.CD_SALES_GROUP
                               WHERE     (   EC.QT_AGENDADA_CONFIRMADA
                                                 IS NOT NULL
                                          OR EC.QT_AGENDADA_CONFIRMADA <> 0)
                                     AND EA.CD_WEEK = P_CD_WEEK
                                     AND (   P_CD_POLO IS NULL
                                          OR EA.CD_POLO = P_CD_POLO)
                                     AND (   P_CD_CENTRO_EXPEDIDOR IS NULL
                                          OR EA.CD_CENTRO_EXPEDIDOR =
                                             P_CD_CENTRO_EXPEDIDOR)
                                     AND (   P_CD_MACHINE IS NULL
                                          OR EA.CD_MACHINE = P_CD_MACHINE)
                                     AND (   P_CD_SALES_DISTRICT IS NULL
                                          OR EAS.CD_SALES_DISTRICT =
                                             P_CD_SALES_DISTRICT)
                                     AND (   P_CD_SALES_OFFICE IS NULL
                                          OR EAS.CD_SALES_OFFICE =
                                             P_CD_SALES_OFFICE)
                                     AND (   P_CD_SALES_GROUP IS NULL
                                          OR EAS.CD_SALES_GROUP =
                                             P_CD_SALES_GROUP)) Resultado
                             -- ITEM NOTA FISCAL
                             INNER JOIN VND.ITEM_NOTA_FISCAL INF
                                 ON INF.CD_PRODUTO_SAP =
                                    RESULTADO.CD_PRODUTO_SAP
                             INNER JOIN VND.NOTA_FISCAL NF
                                 ON NF.CD_NF_CONTROLE = INF.CD_NF_CONTROLE
                             -- PRODUTO MATERIA PRIMA
                             INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                                 ON RESULTADO.CD_PRODUTO_SAP =
                                    PRMG.CD_PRODUTO_SAP
                             INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                                 ON RMG.CD_RAW_MATERIAL_GROUP =
                                    PRMG.CD_RAW_MATERIAL_GROUP
                             --DETALHE
                             INNER JOIN VND.DETALHE_PLANEJAMENTO DET
                                 ON PRMG.CD_PRODUTO_SAP = DET.CD_PRODUTO_SAP
                             LEFT JOIN VND.PLANEJAMENTO PLA
                                 ON PLA.CD_PLANEJAMENTO = DET.CD_PLANEJAMENTO
                       --
                       WHERE     INF.CD_CENTRO_EXPEDIDOR =
                                 RESULTADO.CD_CENTRO_EXPEDIDOR
                             AND (   CD_TIPO_NOTA_FISCAL = 'N1'
                                  OR CD_TIPO_NOTA_FISCAL = 'N4')
                             AND NF.IC_CARTEIRA = 'S'
                             AND PRMG.QT_PERCENTAGE <> 0
                             AND TO_NUMBER (TO_CHAR (NF.DH_EMISSAO, 'MM')) =
                                 TO_NUMBER (TO_CHAR (DT_WEEK_START, 'MM'))
                             --
                             AND DET.IC_ATIVO = 'S'
                             AND PLA.CD_CENTRO_EXPEDIDOR =
                                 RESULTADO.CD_CENTRO_EXPEDIDOR
                             AND PLA.CD_PERIODO =
                                 (SELECT cd_periodo
                                    FROM (  SELECT pe.cd_periodo
                                              FROM vnd.periodo pe
                                                   INNER JOIN
                                                   vnd.tipo_planejamento tp
                                                       ON tp.cd_tipo_planejamento =
                                                          pe.cd_tipo_planejamento
                                             WHERE     UPPER (
                                                           tp.sg_tipo_planejamento) =
                                                       'MENSAL'
                                                   AND (    pe.dt_periodo_de <=
                                                            TRUNC (dWEEK, 'MM')
                                                        AND pe.dt_periodo_ate >=
                                                            TRUNC (dWEEK, 'MM'))
                                          ORDER BY pe.dt_referencia DESC)
                                   WHERE ROWNUM = 1)
                    ORDER BY "GERENTE REGIONAL", "SUPERVISOR";
            ELSE
                OPEN P_RETORNO FOR
                    SELECT 'Não existe planejamento para os parametros informados.'
                               AS P_SUCESSO
                      FROM DUAL;
            END IF;
        ELSE
            OPEN P_RETORNO FOR
                SELECT 'Não há dados para o filtro informado.' AS P_SUCESSO
                  FROM DUAL;
        END IF;
    /*
    BEGIN

    OPEN P_RETORNO FOR
    SELECT
          "Centro"
        , "Gerente Nacional"
        , "Gerente Regional"
        , "Supervisor"
        , "Insumo"
        , SUM("Orcado") "Orcado"
        , SUM("Acumulado") "Acumulado"
        , "Status Acumulado"
        , SUM("Plan W+1") "Plan W+1"
        , "Status Pos Plan"
    FROM
    (
        SELECT EA.CD_CENTRO_EXPEDIDOR "Centro"
        , USU1.NO_USUARIO "Gerente Nacional"
        , USU2.NO_USUARIO AS "Gerente Regional"
        , USU3.NO_USUARIO AS "Supervisor"
        , RMG.NO_RAW_MATERIAL_GROUP "Insumo"
        , TO_CHAR(((PRMG.QT_PERCENTAGE * DET.QT_VALOR)/100),'99999D99') "Orcado"
        , TO_CHAR(((PRMG.QT_PERCENTAGE * INF.NU_QUANTIDADE)/100),'99999D99') "Acumulado"
        , TO_CHAR(((((PRMG.QT_PERCENTAGE * INF.NU_QUANTIDADE)/100) * ((PRMG.QT_PERCENTAGE * DET.QT_VALOR)/100))/100),'99999D99') "Status Acumulado"
        , TO_CHAR(((PRMG.QT_PERCENTAGE * EC.QT_AGENDADA_CONFIRMADA)/100),'99999D99') "Plan W+1"
        , TO_CHAR(((((PRMG.QT_PERCENTAGE * EC.QT_AGENDADA_CONFIRMADA)/100)) + (((PRMG.QT_PERCENTAGE * INF.NU_QUANTIDADE)/100))/((PRMG.QT_PERCENTAGE * DET.QT_VALOR)/100)),'99999D99') "Status Pos Plan"
        FROM CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
        INNER JOIN CTF.RAW_MATERIAL_GROUP RMG ON RMG.CD_RAW_MATERIAL_GROUP = PRMG.CD_RAW_MATERIAL_GROUP
        LEFT JOIN VND.ITEM_NOTA_FISCAL INF ON PRMG.CD_PRODUTO_SAP = INF.CD_PRODUTO_SAP
        INNER JOIN VND.NOTA_FISCAL NF ON NF.CD_NF_CONTROLE = INF.CD_NF_CONTROLE
        INNER JOIN VND.ELO_CARTEIRA EC ON EC.CD_PRODUTO_SAP = INF.CD_PRODUTO_SAP
        INNER JOIN VND.ELO_AGENDAMENTO EA ON EA.CD_ELO_AGENDAMENTO =  EC.CD_ELO_AGENDAMENTO
        INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI ON EAI.CD_ELO_AGENDAMENTO_ITEM = EC.CD_ELO_AGENDAMENTO_ITEM
        INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR = EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
        LEFT JOIN CTF.USUARIO USU1 ON USU1.CD_USUARIO_ORIGINAL = EAS.CD_SALES_OFFICE
        INNER JOIN CTF.USUARIO USU2 ON USU2.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP
        INNER JOIN CTF.USUARIO USU3 ON USU3.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP
        --
        LEFT JOIN VND.DETALHE_PLANEJAMENTO DET ON PRMG.CD_PRODUTO_SAP = DET.CD_PRODUTO_SAP
        INNER JOIN VND.PLANEJAMENTO PLA ON PLA.CD_PLANEJAMENTO = DET.CD_PLANEJAMENTO
        LEFT JOIN (SELECT cd_periodo
                            FROM (  SELECT pe.cd_periodo
                                    FROM vnd.periodo pe
                                    INNER JOIN vnd.tipo_planejamento tp ON tp.cd_tipo_planejamento = pe.cd_tipo_planejamento
                                    WHERE UPPER(tp.sg_tipo_planejamento) = 'MENSAL'
                                    --AND (   pe.dt_periodo_de <= TRUNC(P_DT_WEEK_START, 'MM')
                                    --        AND pe.dt_periodo_ate >= TRUNC(P_DT_WEEK_START, 'MM'))
                                    ORDER BY pe.dt_referencia DESC)
                            WHERE ROWNUM = 1) PER ON PER.CD_PERIODO = PLA.CD_PERIODO
        WHERE (EC.QT_AGENDADA_CONFIRMADA IS NOT NULL OR EC.QT_AGENDADA_CONFIRMADA <> 0)
        AND EA.CD_WEEK = P_CD_WEEK
        AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
        AND (P_CD_CENTRO_EXPEDIDOR IS NULL OR EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR)
        AND (P_CD_MACHINE IS NULL OR EA.CD_MACHINE = P_CD_MACHINE)
        AND (P_CD_SALES_DISTRICT IS NULL OR EAS.CD_SALES_DISTRICT = P_CD_SALES_DISTRICT)
        AND (P_CD_SALES_OFFICE IS NULL OR EAS.CD_SALES_OFFICE = P_CD_SALES_OFFICE)
        AND (P_CD_SALES_GROUP IS NULL OR EAS.CD_SALES_GROUP = P_CD_SALES_GROUP)
        AND INF.CD_CENTRO_EXPEDIDOR = EA.CD_CENTRO_EXPEDIDOR
        AND PRMG.QT_PERCENTAGE <> 0
        AND NF.IC_CARTEIRA = 'S'
        AND DET.IC_ATIVO = 'S'
        AND NF.CD_USUARIO_VENDA = USU3.CD_USUARIO
        AND (CD_TIPO_NOTA_FISCAL = 'N1' OR CD_TIPO_NOTA_FISCAL = 'N4')
        AND TO_NUMBER(TO_CHAR(NF.DH_EMISSAO,'MM')) = TO_NUMBER(TO_CHAR(EA.DT_WEEK_START, 'MM'))
    )
    Resultado
    GROUP BY "Centro", "Gerente Nacional", "Gerente Regional", "Supervisor", "Insumo", "Status Acumulado", "Status Pos Plan"
    ORDER BY 1, 2, 3, 4, 5;*/

    END PX_RAW_MATERIAL_COTA_AGRUPADO;

    PROCEDURE PX_RAW_MATERIAL_COTA_DETALHADO (
        P_CD_WEEK               IN     VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_POLO               IN     VND.ELO_AGENDAMENTO.CD_POLO%TYPE DEFAULT NULL,
        P_CD_CENTRO_EXPEDIDOR   IN     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE DEFAULT NULL,
        P_CD_MACHINE            IN     VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE DEFAULT NULL,
        P_CD_SALES_DISTRICT     IN     VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_DISTRICT%TYPE DEFAULT NULL,
        P_CD_SALES_OFFICE       IN     VND.ELO_CARTEIRA.CD_SALES_OFFICE%TYPE DEFAULT NULL,
        P_CD_SALES_GROUP        IN     VND.ELO_CARTEIRA.CD_SALES_GROUP%TYPE DEFAULT NULL,
        P_RETORNO                  OUT T_CURSOR)
    IS
    BEGIN
        OPEN P_RETORNO FOR
              SELECT INSUMOS_QTD.CD_CENTRO_EXPEDIDOR,
                     INSUMOS_QTD."GERENTE NACIONAL",
                     INSUMOS_QTD."GERENTE REGIONAL",
                     INSUMOS_QTD."SUPERVISOR",
                     INSUMOS_QTD."INSUMO",
                     NVL (ROUND (SUM (INSUMOS_QTD."AGENDADO"), 2), 0)
                         "AGENDADO",
                     NVL (ROUND (SUM (INSUMOS_QTD."ACUMULADO"), 2), 0)
                         "ACUMULADO",
                     NVL (
                         ROUND (
                             (  SUM (INSUMOS_QTD."ACUMULADO")
                              / SUM (INSUMOS_QTD."ORCADO")),
                             2),
                         0)
                         "STATUS ACUMULADO",
                     NVL (ROUND (SUM (INSUMOS_QTD."ORCADO"), 2), 0)
                         "ORCADO",
                     NVL (
                         ROUND (
                             (  (  SUM (INSUMOS_QTD."ACUMULADO")
                                 + SUM (INSUMOS_QTD."AGENDADO"))
                              / SUM (INSUMOS_QTD."ORCADO")),
                             2),
                         0)
                         "STATUS PÓS-PLAN"
                FROM (  SELECT EC.CD_CENTRO_EXPEDIDOR,
                               NULL
                                   "GERENTE NACIONAL",
                               EC.NO_SALES_OFFICE
                                   "GERENTE REGIONAL",
                               EC.NO_SALES_GROUP
                                   "SUPERVISOR",
                               RMG.NO_RAW_MATERIAL_GROUP
                                   "INSUMO",
                               DECODE (
                                   EA.CD_ELO_STATUS,
                                   VND.GX_ELO_COMMON.FX_ELO_STATUS ('AGEND',
                                                                    'AGOPN'), SUM (
                                                                                  (  (  EAW.QT_SEMANA
                                                                                      * PRMG.QT_PERCENTAGE)
                                                                                   / 100)),
                                   SUM (
                                       (  (  EC.QT_AGENDADA_CONFIRMADA
                                           * PRMG.QT_PERCENTAGE)
                                        / 100)))
                                   "AGENDADO",
                               NULL
                                   "ACUMULADO",
                               NULL
                                   "ORCADO"
                          FROM VND.ELO_CARTEIRA EC
                               INNER JOIN VND.ELO_AGENDAMENTO EA
                                   ON EA.CD_ELO_AGENDAMENTO =
                                      EC.CD_ELO_AGENDAMENTO
                               INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                                   ON     EAS.CD_ELO_AGENDAMENTO =
                                          EA.CD_ELO_AGENDAMENTO
                                      AND EAS.CD_SALES_GROUP = EC.CD_SALES_GROUP
                                      AND EAS.IC_ATIVO = 'S'
                               INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI
                                   ON     EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                                          EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
                                      AND EAI.IC_ATIVO = 'S'
                                      AND EAI.CD_ELO_AGENDAMENTO_ITEM =
                                          EC.CD_ELO_AGENDAMENTO_ITEM
                               INNER JOIN VND.ELO_AGENDAMENTO_WEEK EAW
                                   ON EAI.CD_ELO_AGENDAMENTO_ITEM =
                                      EAW.CD_ELO_AGENDAMENTO_ITEM
                               INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                                   ON EC.CD_PRODUTO_SAP = PRMG.CD_PRODUTO_SAP
                               INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                                   ON PRMG.CD_RAW_MATERIAL_GROUP =
                                      RMG.CD_RAW_MATERIAL_GROUP
                         WHERE     (   (    EA.CD_ELO_STATUS <>
                                            VND.GX_ELO_COMMON.FX_ELO_STATUS (
                                                'AGEND',
                                                'AGOPN')
                                        AND EC.QT_AGENDADA_CONFIRMADA IS NOT NULL
                                        AND EC.QT_AGENDADA_CONFIRMADA <> 0)
                                    OR EA.CD_ELO_STATUS =
                                       VND.GX_ELO_COMMON.FX_ELO_STATUS ('AGEND',
                                                                        'AGOPN'))
                               AND EA.CD_WEEK = P_CD_WEEK
                               AND (   P_CD_CENTRO_EXPEDIDOR IS NULL
                                    OR EA.CD_CENTRO_EXPEDIDOR =
                                       P_CD_CENTRO_EXPEDIDOR)
                               AND (P_CD_POLO IS NULL OR EA.CD_POLO = P_CD_POLO)
                               AND (   P_CD_SALES_OFFICE IS NULL
                                    OR EC.CD_SALES_OFFICE = P_CD_SALES_OFFICE)
                               AND (   P_CD_SALES_GROUP IS NULL
                                    OR EC.CD_SALES_GROUP = P_CD_SALES_GROUP)
                               AND PRMG.QT_PERCENTAGE <> 0
                      GROUP BY EC.CD_CENTRO_EXPEDIDOR,
                               EC.NO_SALES_OFFICE,
                               EC.NO_SALES_GROUP,
                               RMG.NO_RAW_MATERIAL_GROUP,
                               RMG.CD_RAW_MATERIAL_GROUP,
                               EA.CD_ELO_STATUS
                      UNION
                        SELECT INF.CD_CENTRO_EXPEDIDOR,
                               NULL
                                   "GERENTE NACIONAL",
                               USU2.NO_USUARIO
                                   "GERENTE REGIONAL",
                               USU.NO_USUARIO
                                   "SUPERVISOR",
                               RMG.NO_RAW_MATERIAL_GROUP
                                   "INSUMO",
                               NULL
                                   "AGENDADO",
                               SUM (
                                   (  (PRMG.QT_PERCENTAGE * INF.NU_QUANTIDADE)
                                    / 100))
                                   "ACUMULADO",
                               NULL
                                   "ORCADO"
                          FROM VND.NOTA_FISCAL NF
                               INNER JOIN VND.ITEM_NOTA_FISCAL INF
                                   ON NF.CD_NF_CONTROLE = INF.CD_NF_CONTROLE
                               INNER JOIN CTF.USUARIO USU
                                   ON USU.CD_USUARIO = NF.CD_USUARIO_VENDA
                               INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                                   ON INF.CD_PRODUTO_SAP = PRMG.CD_PRODUTO_SAP
                               INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                                   ON RMG.CD_RAW_MATERIAL_GROUP =
                                      PRMG.CD_RAW_MATERIAL_GROUP
                               INNER JOIN CTF.USUARIO USU2
                                   ON USU.CD_USUARIO_SUPERIOR = USU2.CD_USUARIO
                         WHERE     NF.NU_ANO_EMISSAO =
                                   SUBSTR (
                                       TO_CHAR (
                                             (  TO_DATE (
                                                    CONCAT (
                                                        CONCAT (
                                                            '20',
                                                            SUBSTR (P_CD_WEEK,
                                                                    6,
                                                                    2)),
                                                        '/01/01'),
                                                    'YYYY/MM/DD')
                                              + (    TO_NUMBER (
                                                         SUBSTR (P_CD_WEEK, 2, 2))
                                                   * 7
                                                 - 7
                                                 + 1))
                                           + 2,
                                           'DD-MM-YY'),
                                       7,
                                       2)
                               AND NF.NU_MES_EMISSAO =
                                   SUBSTR (
                                       TO_CHAR (
                                             (  TO_DATE (
                                                    CONCAT (
                                                        CONCAT (
                                                            '20',
                                                            SUBSTR (P_CD_WEEK,
                                                                    6,
                                                                    2)),
                                                        '/01/01'),
                                                    'YYYY/MM/DD')
                                              + (    TO_NUMBER (
                                                         SUBSTR (P_CD_WEEK, 2, 2))
                                                   * 7
                                                 - 7
                                                 + 1))
                                           + 2,
                                           'DD-MM-YY'),
                                       4,
                                       2)
                               AND PRMG.QT_PERCENTAGE <> 0
                               AND (   (    P_CD_POLO IS NOT NULL
                                        AND INF.CD_CENTRO_EXPEDIDOR IN
                                                (SELECT CD_CENTRO_EXPEDIDOR
                                                   FROM CTF.POLO_CENTRO_EXPEDIDOR
                                                        PCE
                                                  WHERE     PCE.CD_POLO =
                                                            P_CD_POLO
                                                        AND PCE.IC_ATIVO = 'S'
                                                        AND (   P_CD_CENTRO_EXPEDIDOR
                                                                    IS NULL
                                                             OR PCE.CD_CENTRO_EXPEDIDOR =
                                                                P_CD_CENTRO_EXPEDIDOR)))
                                    OR INF.CD_CENTRO_EXPEDIDOR =
                                       P_CD_CENTRO_EXPEDIDOR)
                               AND (       P_CD_SALES_OFFICE IS NOT NULL
                                       AND USU.CD_USUARIO_ORIGINAL IN
                                               (SELECT CD_USUARIO_ORIGINAL
                                                  FROM CTF.USUARIO
                                                 WHERE     CD_USUARIO_SUPERIOR =
                                                           (SELECT CD_USUARIO
                                                              FROM CTF.USUARIO
                                                             WHERE CD_USUARIO_ORIGINAL =
                                                                   P_CD_SALES_OFFICE)
                                                       AND CD_USUARIO_ORIGINAL
                                                               IS NOT NULL
                                                       AND (   P_CD_SALES_GROUP
                                                                   IS NULL
                                                            OR CD_USUARIO_ORIGINAL =
                                                               P_CD_SALES_GROUP))
                                    OR (USU.CD_USUARIO_ORIGINAL =
                                        P_CD_SALES_GROUP))
                               AND (   NF.CD_TIPO_NOTA_FISCAL = 'N1'
                                    OR NF.CD_TIPO_NOTA_FISCAL = 'N4')
                               AND NF.IC_CARTEIRA = 'S'
                      GROUP BY INF.CD_CENTRO_EXPEDIDOR,
                               RMG.NO_RAW_MATERIAL_GROUP,
                               USU.NO_USUARIO,
                               USU2.NO_USUARIO,
                               USU.CD_USUARIO,
                               USU2.CD_USUARIO,
                               RMG.CD_RAW_MATERIAL_GROUP
                      UNION
                        SELECT CD_CENTRO_EXPEDIDOR
                                   "CD_CENTRO_EXPEDIDOR",
                               NULL
                                   "GERENTE NACIONAL",
                               USU2.NO_USUARIO
                                   "GERENTE REGIONAL",
                               USU1.NO_USUARIO
                                   "SUPERVISOR",
                               RMG.NO_RAW_MATERIAL_GROUP
                                   "INSUMO",
                               NULL
                                   "AGENDADO",
                               NULL
                                   "ACUMULADO",
                               SUM (((PRMG.QT_PERCENTAGE * DET.QT_VALOR) / 100))
                                   "ORCADO"
                          FROM VND.DETALHE_PLANEJAMENTO DET
                               INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                                   ON PRMG.CD_PRODUTO_SAP = DET.CD_PRODUTO_SAP
                               INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                                   ON PRMG.CD_RAW_MATERIAL_GROUP =
                                      RMG.CD_RAW_MATERIAL_GROUP
                               INNER JOIN VND.PLANEJAMENTO PLA
                                   ON PLA.CD_PLANEJAMENTO = DET.CD_PLANEJAMENTO
                               INNER JOIN CTF.USUARIO USU1
                                   ON PLA.CD_USUARIO = USU1.CD_USUARIO
                               INNER JOIN CTF.USUARIO USU2
                                   ON USU1.CD_USUARIO_SUPERIOR = USU2.CD_USUARIO
                         WHERE     PRMG.QT_PERCENTAGE <> 0
                               AND DET.IC_ATIVO = 'S'
                               AND (PLA.CD_CENTRO_EXPEDIDOR =
                                    P_CD_CENTRO_EXPEDIDOR)
                               AND PLA.CD_PERIODO =
                                   (SELECT CD_PERIODO
                                      FROM (  SELECT pe.cd_periodo
                                                FROM vnd.periodo pe
                                                     INNER JOIN
                                                     vnd.tipo_planejamento tp
                                                         ON tp.cd_tipo_planejamento =
                                                            pe.cd_tipo_planejamento
                                               WHERE     UPPER (
                                                             TP.SG_TIPO_PLANEJAMENTO) =
                                                         'MENSAL'
                                                     AND (    TO_CHAR (
                                                                  PE.DT_PERIODO_DE,
                                                                  'MM') <=
                                                              SUBSTR (
                                                                  TO_CHAR (
                                                                        (  TO_DATE (
                                                                               CONCAT (
                                                                                   CONCAT (
                                                                                       '20',
                                                                                       SUBSTR (
                                                                                           P_CD_WEEK,
                                                                                           6,
                                                                                           2)),
                                                                                   '/01/01'),
                                                                               'YYYY/MM/DD')
                                                                         + (    TO_NUMBER (
                                                                                    SUBSTR (
                                                                                        P_CD_WEEK,
                                                                                        2,
                                                                                        2))
                                                                              * 7
                                                                            - 7
                                                                            + 1))
                                                                      + 2,
                                                                      'DD-MM-YY'),
                                                                  4,
                                                                  2)
                                                          AND TO_CHAR (
                                                                  PE.DT_PERIODO_DE,
                                                                  'YY') <=
                                                              SUBSTR (
                                                                  TO_CHAR (
                                                                        (  TO_DATE (
                                                                               CONCAT (
                                                                                   CONCAT (
                                                                                       '20',
                                                                                       SUBSTR (
                                                                                           P_CD_WEEK,
                                                                                           6,
                                                                                           2)),
                                                                                   '/01/01'),
                                                                               'YYYY/MM/DD')
                                                                         + (    TO_NUMBER (
                                                                                    SUBSTR (
                                                                                        P_CD_WEEK,
                                                                                        2,
                                                                                        2))
                                                                              * 7
                                                                            - 7
                                                                            + 1))
                                                                      + 2,
                                                                      'DD-MM-YY'),
                                                                  7,
                                                                  2)
                                                          AND TO_CHAR (
                                                                  PE.DT_PERIODO_ATE,
                                                                  'MM') >=
                                                              SUBSTR (
                                                                  TO_CHAR (
                                                                        (  TO_DATE (
                                                                               CONCAT (
                                                                                   CONCAT (
                                                                                       '20',
                                                                                       SUBSTR (
                                                                                           P_CD_WEEK,
                                                                                           6,
                                                                                           2)),
                                                                                   '/01/01'),
                                                                               'YYYY/MM/DD')
                                                                         + (    TO_NUMBER (
                                                                                    SUBSTR (
                                                                                        P_CD_WEEK,
                                                                                        2,
                                                                                        2))
                                                                              * 7
                                                                            - 7
                                                                            + 1))
                                                                      + 2,
                                                                      'DD-MM-YY'),
                                                                  4,
                                                                  2)
                                                          AND TO_CHAR (
                                                                  PE.DT_PERIODO_ATE,
                                                                  'YY') >=
                                                              SUBSTR (
                                                                  TO_CHAR (
                                                                        (  TO_DATE (
                                                                               CONCAT (
                                                                                   CONCAT (
                                                                                       '20',
                                                                                       SUBSTR (
                                                                                           P_CD_WEEK,
                                                                                           6,
                                                                                           2)),
                                                                                   '/01/01'),
                                                                               'YYYY/MM/DD')
                                                                         + (    TO_NUMBER (
                                                                                    SUBSTR (
                                                                                        P_CD_WEEK,
                                                                                        2,
                                                                                        2))
                                                                              * 7
                                                                            - 7
                                                                            + 1))
                                                                      + 2,
                                                                      'DD-MM-YY'),
                                                                  7,
                                                                  2))
                                            ORDER BY pe.dt_referencia DESC)
                                     WHERE ROWNUM = 1)
                               AND (   (    P_CD_POLO IS NOT NULL
                                        AND PLA.CD_CENTRO_EXPEDIDOR IN
                                                (SELECT CD_CENTRO_EXPEDIDOR
                                                   FROM CTF.POLO_CENTRO_EXPEDIDOR
                                                        PCE
                                                  WHERE     PCE.CD_POLO =
                                                            P_CD_POLO
                                                        AND PCE.IC_ATIVO = 'S'
                                                        AND (   P_CD_CENTRO_EXPEDIDOR
                                                                    IS NULL
                                                             OR PCE.CD_CENTRO_EXPEDIDOR =
                                                                P_CD_CENTRO_EXPEDIDOR)))
                                    OR PLA.CD_CENTRO_EXPEDIDOR =
                                       P_CD_CENTRO_EXPEDIDOR)
                               AND (       P_CD_SALES_OFFICE IS NOT NULL
                                       AND USU1.CD_USUARIO_ORIGINAL IN
                                               (SELECT CD_USUARIO_ORIGINAL
                                                  FROM CTF.USUARIO
                                                 WHERE     CD_USUARIO_SUPERIOR =
                                                           (SELECT CD_USUARIO
                                                              FROM CTF.USUARIO
                                                             WHERE CD_USUARIO_ORIGINAL =
                                                                   P_CD_SALES_OFFICE)
                                                       AND CD_USUARIO_ORIGINAL
                                                               IS NOT NULL
                                                       AND (   P_CD_SALES_GROUP
                                                                   IS NULL
                                                            OR CD_USUARIO_ORIGINAL =
                                                               P_CD_SALES_GROUP))
                                    OR (USU1.CD_USUARIO_ORIGINAL =
                                        P_CD_SALES_GROUP))
                      GROUP BY RMG.NO_RAW_MATERIAL_GROUP,
                               CD_CENTRO_EXPEDIDOR,
                               USU1.NO_USUARIO,
                               USU1.CD_USUARIO,
                               USU2.NO_USUARIO,
                               USU2.CD_USUARIO,
                               RMG.NO_RAW_MATERIAL_GROUP,
                               RMG.CD_RAW_MATERIAL_GROUP) INSUMOS_QTD
            GROUP BY INSUMOS_QTD.CD_CENTRO_EXPEDIDOR,
                     INSUMOS_QTD."GERENTE NACIONAL",
                     INSUMOS_QTD."GERENTE REGIONAL",
                     INSUMOS_QTD."SUPERVISOR",
                     INSUMOS_QTD."INSUMO";
    END PX_RAW_MATERIAL_COTA_DETALHADO;

    FUNCTION FX_GET_ORCADO (P_CD_PRODUTO_SAP          IN CHAR,
                            P_NO_RAW_MATERIAL_GROUP   IN CHAR)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
        SELECT DISTINCT NVL ((DET.QT_VALOR * (PRMG.QT_PERCENTAGE / 100)), 0)
          INTO P_RETORNO
          FROM VND.DETALHE_PLANEJAMENTO  DET
               INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                   ON PRMG.CD_PRODUTO_SAP = DET.CD_PRODUTO_SAP
               INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                   ON RMG.CD_RAW_MATERIAL_GROUP = PRMG.CD_RAW_MATERIAL_GROUP
         WHERE     DET.IC_ATIVO <> 'N'
               AND PRMG.CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
               AND RMG.NO_RAW_MATERIAL_GROUP = P_NO_RAW_MATERIAL_GROUP;

        RETURN NVL (P_RETORNO, 0);
    END FX_GET_ORCADO;

    FUNCTION FX_GET_ORCADO_COTA (
        P_CD_PRODUTO_SAP   IN VND.DETALHE_PLANEJAMENTO.CD_PRODUTO_SAP%TYPE,
        P_DT_WEEK_START    IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE,
        P_CD_SALES_GROUP   IN VND.ELO_CARTEIRA.CD_SALES_GROUP%TYPE DEFAULT NULL)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
        SELECT NVL (SUM (DET.QT_VALOR), 0)
          INTO P_RETORNO
          FROM VND.DETALHE_PLANEJAMENTO  DET
               INNER JOIN VND.PLANEJAMENTO PLA
                   ON PLA.CD_PLANEJAMENTO = DET.CD_PLANEJAMENTO
               INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP RMG
                   ON RMG.CD_PRODUTO_SAP = DET.CD_PRODUTO_SAP
               INNER JOIN VND.PERIODO PER ON PER.CD_PERIODO = PLA.CD_PERIODO
               INNER JOIN CTF.USUARIO USU ON USU.CD_USUARIO = PLA.CD_USUARIO
         WHERE     RMG.CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
               AND USU.CD_USUARIO_ORIGINAL = P_CD_SALES_GROUP
               AND PER.CD_PERIODO =
                   (SELECT cd_periodo
                      FROM (  SELECT pe.cd_periodo
                                FROM vnd.periodo pe
                                     INNER JOIN vnd.tipo_planejamento tp
                                         ON tp.cd_tipo_planejamento =
                                            pe.cd_tipo_planejamento
                               WHERE     UPPER (tp.sg_tipo_planejamento) =
                                         'MENSAL'
                                     AND (    pe.dt_periodo_de <=
                                              TRUNC (P_DT_WEEK_START, 'MM')
                                          AND pe.dt_periodo_ate >=
                                              TRUNC (P_DT_WEEK_START, 'MM'))
                            ORDER BY pe.dt_referencia DESC)
                     WHERE ROWNUM = 1)
               AND PER.CD_TIPO_PLANEJAMENTO = 3;

        RETURN NVL (P_RETORNO, 0);
    END FX_GET_ORCADO_COTA;

    FUNCTION FX_GET_ACUMULADO (P_CD_CENTRO_EXPEDIDOR   IN CHAR,
                               P_MES                   IN VARCHAR2)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
        SELECT DISTINCT
               NVL ((INF.NU_QUANTIDADE * (PRMG.QT_PERCENTAGE / 100)), 0)
          INTO P_RETORNO
          FROM VND.NOTA_FISCAL  NF
               INNER JOIN VND.ITEM_NOTA_FISCAL INF
                   ON NF.CD_NF_CONTROLE = INF.CD_NF_CONTROLE
               INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
                   ON PRMG.CD_PRODUTO_SAP = INF.CD_PRODUTO_SAP
               INNER JOIN CTF.RAW_MATERIAL_GROUP RMG
                   ON RMG.CD_RAW_MATERIAL_GROUP = PRMG.CD_RAW_MATERIAL_GROUP
               LEFT JOIN CTF.USUARIO USU
                   ON USU.CD_USUARIO_ORIGINAL = TO_CHAR (NF.CD_USUARIO_VENDA)
         WHERE     NF.IC_CARTEIRA = 'S'
               AND USU.IC_ATIVO <> 'N'
               AND (   NF.CD_TIPO_NOTA_FISCAL = 'N1'
                    OR NF.CD_TIPO_NOTA_FISCAL = 'N4')
               AND INF.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
               AND TO_NUMBER (TO_CHAR (NF.DH_EMISSAO, 'MM')) =
                   TO_NUMBER (P_MES);

        RETURN P_RETORNO;
    END FX_GET_ACUMULADO;

    FUNCTION FX_GET_ACUMULADO_COTA (
        P_CD_PRODUTO_SAP   IN VND.DETALHE_PLANEJAMENTO.CD_PRODUTO_SAP%TYPE,
        P_DT_WEEK_START    IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
          SELECT DISTINCT SUM (NVL (NFI.NU_QUANTIDADE, 0))
            INTO P_RETORNO
            /*CASE CD_TIPO_NOTA_FISCAL
                WHEN 'N1' THEN  NVL(SUM(NFI.NU_QUANTIDADE), 0)
                WHEN 'N2' THEN  NVL(SUM(NFI.NU_QUANTIDADE), 0)
            END TOTAL*/
            FROM VND.NOTA_FISCAL NF
                 INNER JOIN VND.ITEM_NOTA_FISCAL NFI
                     ON NF.CD_NF_CONTROLE = NFI.CD_NF_CONTROLE
           WHERE     IC_CARTEIRA = 'S'
                 AND (CD_TIPO_NOTA_FISCAL = 'N1' OR CD_TIPO_NOTA_FISCAL = 'N4')
                 AND CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
                 AND TO_NUMBER (TO_CHAR (NF.DH_EMISSAO, 'MM')) =
                     TO_NUMBER (TO_CHAR (P_DT_WEEK_START, 'MM'))
        GROUP BY CD_PRODUTO_SAP;

        RETURN NVL (P_RETORNO, 0);
    END FX_GET_ACUMULADO_COTA;

    FUNCTION FX_GET_ACUMULADO_COTA_AGRUP (
        P_CD_RAW_MATERIAL_GROUP   IN CTF.PRODUTO_RAW_MATERIAL_GROUP.CD_RAW_MATERIAL_GROUP%TYPE,
        P_DT_WEEK_START           IN VND.ELO_AGENDAMENTO.DT_WEEK_START%TYPE)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
          SELECT DISTINCT SUM (NFI.NU_QUANTIDADE)
            INTO P_RETORNO
            FROM VND.NOTA_FISCAL NF
                 INNER JOIN VND.ITEM_NOTA_FISCAL NFI
                     ON NF.CD_NF_CONTROLE = NFI.CD_NF_CONTROLE
                 INNER JOIN CTF.PRODUTO_RAW_MATERIAL_GROUP MG
                     ON MG.CD_PRODUTO_SAP = NFI.CD_PRODUTO_SAP
           WHERE     IC_CARTEIRA = 'S'
                 AND (CD_TIPO_NOTA_FISCAL = 'N1' OR CD_TIPO_NOTA_FISCAL = 'N4')
                 AND MG.CD_RAW_MATERIAL_GROUP = P_CD_RAW_MATERIAL_GROUP
                 AND TO_NUMBER (TO_CHAR (NF.DH_EMISSAO, 'MM')) =
                     TO_NUMBER (TO_CHAR (P_DT_WEEK_START, 'MM'))
        GROUP BY MG.CD_RAW_MATERIAL_GROUP;

        RETURN NVL (P_RETORNO, 0);
    END FX_GET_ACUMULADO_COTA_AGRUP;

    FUNCTION FX_GET_AGENDADO (P_CD_CODIGO_SAP         IN CHAR,
                              P_CD_CENTRO_EXPEDIDOR   IN CHAR,
                              P_CD_SALES_DISTRICT     IN CHAR DEFAULT NULL,
                              P_CD_SALES_OFFICE       IN CHAR DEFAULT NULL,
                              P_CD_SALES_GROUP        IN CHAR DEFAULT NULL,
                              P_CD_WEEK               IN CHAR DEFAULT NULL)
        RETURN DECIMAL
    IS
        P_STATUS    CHAR (1);
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
        SELECT DISTINCT EA.CD_ELO_STATUS
          INTO P_STATUS
          FROM VND.ELO_AGENDAMENTO EA
         WHERE     EA.IC_ATIVO <> 'N'
               AND EA.CD_WEEK = P_CD_WEEK
               AND EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR;

        /*STATUS AGENDAMENTO ABERTO*/
        IF P_STATUS = '2'
        THEN
            SELECT DISTINCT NVL (EAW.QT_SEMANA, 0)
              INTO P_RETORNO
              FROM VND.ELO_AGENDAMENTO  EA
                   INNER JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                       ON EA.CD_ELO_AGENDAMENTO = EAS.CD_ELO_AGENDAMENTO
                   INNER JOIN VND.ELO_AGENDAMENTO_ITEM EAI
                       ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                          EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
                   LEFT JOIN VND.ELO_AGENDAMENTO_WEEK EAW
                       ON EAI.CD_ELO_AGENDAMENTO_ITEM =
                          EAW.CD_ELO_AGENDAMENTO_ITEM
             WHERE     EA.IC_ATIVO <> 'N'
                   AND EAI.IC_ATIVO <> 'N'
                   AND EA.CD_WEEK = P_CD_WEEK
                   AND EA.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR;
        /*STATUS AGENDAMENTO DIFERENTE DE ABERTO*/
        ELSE
            SELECT DISTINCT NVL (EC.QT_AGENDADA_CONFIRMADA, 0)
              INTO P_RETORNO
              FROM VND.ELO_CARTEIRA EC
             WHERE     EC.IC_ATIVO <> 'N'
                   AND EC.CD_SALES_DISTRICT = P_CD_SALES_DISTRICT
                   AND EC.CD_SALES_OFFICE = P_CD_SALES_OFFICE
                   AND EC.CD_SALES_GROUP = P_CD_SALES_GROUP
                   AND EC.CD_CENTRO_EXPEDIDOR = P_CD_CENTRO_EXPEDIDOR
                   AND LPAD (TRIM (EC.CD_PRODUTO_SAP), 18, '0') =
                       P_CD_CODIGO_SAP;
        END IF;

        RETURN P_RETORNO;
    END FX_GET_AGENDADO;

    FUNCTION FX_GET_AGENDADO_COTA (
        --P_CD_PRODUTO_SAP        IN  VND.DETALHE_PLANEJAMENTO.CD_PRODUTO_SAP%TYPE,
        P_CD_RAW_MATERIAL_GROUP   IN CTF.RAW_MATERIAL_GROUP.CD_RAW_MATERIAL_GROUP%TYPE,
        --P_CD_ELO_CARTEIRA       IN  VND.ELO_CARTEIRA.CD_ELO_CARTEIRA%TYPE,
        P_CD_WEEK                 IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
        SELECT DISTINCT
               (  SUM (EC.QT_AGENDADA_CONFIRMADA)
                * SUM (PRMG.QT_PERCENTAGE)
                / 100)
          INTO P_RETORNO
          FROM CTF.PRODUTO_RAW_MATERIAL_GROUP  PRMG
               INNER JOIN VND.ELO_CARTEIRA EC
                   ON PRMG.CD_PRODUTO_SAP =
                      LPAD (TRIM (EC.CD_PRODUTO_SAP), 18, '0')
               INNER JOIN VND.ELO_AGENDAMENTO EA
                   ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
         WHERE     EA.CD_WEEK = P_CD_WEEK
               AND PRMG.CD_RAW_MATERIAL_GROUP = P_CD_RAW_MATERIAL_GROUP
               AND QT_AGENDADA_CONFIRMADA IS NOT NULL;

        /*SELECT DISTINCT ((EC.QT_AGENDADA_CONFIRMADA * PRMG.QT_PERCENTAGE)/100) INTO P_RETORNO
        FROM CTF.PRODUTO_RAW_MATERIAL_GROUP PRMG
        INNER JOIN VND.ELO_CARTEIRA EC ON PRMG.CD_PRODUTO_SAP = LPAD(TRIM(EC.CD_PRODUTO_SAP), 18, '0')
        INNER JOIN VND.ELO_AGENDAMENTO EA ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
        WHERE EA.CD_WEEK = P_CD_WEEK
        --AND EC.CD_ELO_CARTEIRA = P_CD_ELO_CARTEIRA
        AND QT_AGENDADA_CONFIRMADA IS NOT NULL
        AND ROWNUM = 1;*/

        RETURN P_RETORNO;
    END FX_GET_AGENDADO_COTA;

    FUNCTION FX_GET_AGENDADO_COTA_AGRUP (
        P_CD_PRODUTO_SAP      IN VND.DETALHE_PLANEJAMENTO.CD_PRODUTO_SAP%TYPE,
        P_CD_WEEK             IN VND.ELO_AGENDAMENTO.CD_WEEK%TYPE,
        P_CD_SALES_DISTRICT   IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_DISTRICT%TYPE,
        P_CD_SALES_OFFICE     IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_OFFICE%TYPE,
        P_CD_SALES_GROUP      IN VND.ELO_AGENDAMENTO_SUPERVISOR.CD_SALES_GROUP%TYPE)
        RETURN DECIMAL
    IS
        P_RETORNO   DECIMAL DEFAULT 0;
    BEGIN
        SELECT DISTINCT ((QT_AGENDADA_CONFIRMADA * PRMG.QT_PERCENTAGE) / 100)
          INTO P_RETORNO
          FROM CTF.PRODUTO_RAW_MATERIAL_GROUP  PRMG
               LEFT JOIN CTF.RAW_MATERIAL_GROUP RMG
                   ON RMG.CD_RAW_MATERIAL_GROUP = PRMG.CD_RAW_MATERIAL_GROUP
               LEFT JOIN VND.ELO_CARTEIRA EC
                   ON PRMG.CD_PRODUTO_SAP =
                      LPAD (TRIM (EC.CD_PRODUTO_SAP), 18, '0')
               LEFT JOIN VND.ELO_AGENDAMENTO EA
                   ON EA.CD_ELO_AGENDAMENTO = EC.CD_ELO_AGENDAMENTO
               LEFT JOIN VND.ELO_AGENDAMENTO_ITEM EAI
                   ON EAI.CD_ELO_AGENDAMENTO_ITEM =
                      EC.CD_ELO_AGENDAMENTO_ITEM
               LEFT JOIN VND.ELO_AGENDAMENTO_SUPERVISOR EAS
                   ON EAS.CD_ELO_AGENDAMENTO_SUPERVISOR =
                      EAI.CD_ELO_AGENDAMENTO_SUPERVISOR
               LEFT JOIN CTF.USUARIO USU
                   ON USU.CD_USUARIO_ORIGINAL = EAS.CD_SALES_DISTRICT
               LEFT JOIN CTF.USUARIO USU2
                   ON USU2.CD_USUARIO_ORIGINAL = EAS.CD_SALES_OFFICE
               LEFT JOIN CTF.USUARIO USU3
                   ON USU3.CD_USUARIO_ORIGINAL = EAS.CD_SALES_GROUP
         WHERE     PRMG.CD_PRODUTO_SAP = P_CD_PRODUTO_SAP
               AND EA.CD_WEEK = P_CD_WEEK
               AND EC.QT_AGENDADA_CONFIRMADA IS NOT NULL
               AND (   P_CD_SALES_DISTRICT IS NULL
                    OR EAS.CD_SALES_DISTRICT = P_CD_SALES_DISTRICT)
               --AND (P_CD_SALES_OFFICE IS NULL OR EAS.CD_SALES_OFFICE = P_CD_SALES_OFFICE)
               --AND (P_CD_SALES_GROUP IS NULL OR EAS.CD_SALES_GROUP = P_CD_SALES_GROUP)
               AND ROWNUM = 1;

        RETURN P_RETORNO;
    END FX_GET_AGENDADO_COTA_AGRUP;
END GX_RAW_MATERIAL;
/