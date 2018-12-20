CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_SECURITY IS

    
     PROCEDURE PX_MENU(
        P_CD_USUARIO  IN CTF.USUARIO.CD_USUARIO%TYPE,
        P_SIGLA_SIS   IN STRING,
        P_RETORNO     OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT LEAD(LEVEL, 1, 1) OVER (ORDER BY ROWNUM) NXT,            
               X.CD_ACAO,
               X.CD_ACAO_SUPERIOR,
               X.DS_ACAO,
               X.DS_MENU,
               X.DS_PROGRAMA,
               X.CD_ORDEM
          FROM (
                  SELECT DISTINCT AC.CD_ACAO,
                                  AC.DS_MENU,
                                  AC.DS_ACAO,
                                  AC.DS_PROGRAMA,
                                  CASE WHEN UPPER(DS_ACAO) = 'SUBMENU' THEN 0
                                       ELSE AC.CD_ACAO_SUPERIOR
                                  END CD_ACAO_SUPERIOR,
                                  AC.CD_ORDEM
                    FROM CTF.ACAO           AC,
                         CTF.SISTEMA        SI,
                         CTF.SIGLA          SG,
                         CTF.PERFIL         PF,
                         CTF.PERFIL_ACAO    PA,
                         CTF.USUARIO_PERFIL UP
                   WHERE AC.CD_SISTEMA = SI.CD_SISTEMA
                     AND PF.CD_SISTEMA = SI.CD_SISTEMA
                     AND PF.CD_PERFIL = UP.CD_PERFIL
                     AND AC.CD_ACAO = PA.CD_ACAO
                     AND PA.CD_PERFIL = PF.CD_PERFIL
                     AND SI.CD_SIGLA = SG.CD_SIGLA
                     AND AC.CD_ACAO NOT IN
                         (SELECT AA.CD_ACAO
                            FROM CTF.ACAO AA, 
                                 CTF.SIGLA SS
                           WHERE AA.CD_SIGLA = SS.CD_SIGLA
                         )
                     AND UP.CD_USUARIO = P_CD_USUARIO
                     AND SG.SG_SIGLA = P_SIGLA_SIS
                     AND PF.IC_ATIVO = 'S'
                     AND AC.IC_ATIVO = 'S'
                     AND AC.IC_EXIBIR = 'S'
               ) X
          START WITH X.CD_ACAO_SUPERIOR = 0
        CONNECT BY PRIOR X.CD_ACAO = X.CD_ACAO_SUPERIOR
        ;
    END PX_MENU;


    PROCEDURE PX_EFETUA_LOGIN(
        P_CD_LOGIN          IN CTF.USUARIO.CD_LOGIN%TYPE,
        P_DS_SENHA          IN CTF.USUARIO.DS_SENHA%TYPE,
        P_IP_USUARIO        IN CTF.LOGIN_ERRO.CD_ENDERECO_IP%TYPE,
        P_RETORNO           OUT T_CURSOR,
        P_PERFIS            OUT T_CURSOR
    )
    IS
        V_DS_SENHA_CRIPTOGRAFADA VARCHAR(1000);
        V_CD_USUARIO             CTF.USUARIO.CD_USUARIO%TYPE;
        V_NO_USUARIO             CTF.USUARIO.NO_USUARIO%TYPE;
        V_IC_ATIVO               CTF.USUARIO.IC_ATIVO%TYPE;
        V_CD_TIPO_USUARIO        CTF.USUARIO.CD_TIPO_USUARIO%TYPE;
        V_CD_USUARIO_SUPERIOR    CTF.USUARIO.CD_USUARIO_SUPERIOR%TYPE;
        V_CD_LOGIN               CTF.USUARIO.CD_LOGIN%TYPE;
        V_DS_SENHA               CTF.USUARIO.DS_SENHA%TYPE;
        V_DS_LEMBRETE_SENHA      CTF.USUARIO.DS_LEMBRETE_SENHA%TYPE;
        V_IC_BLOQUEADO           CTF.USUARIO.IC_BLOQUEADO%TYPE;
        V_DH_ULTIMO_ACESSO       CTF.USUARIO.DH_ULTIMO_ACESSO%TYPE;
        V_DT_EXPIRACAO           CTF.USUARIO_SENHA.DT_EXPIRACAO%TYPE;
        V_TENTATIVAS_ERRO_LOGON  NUMBER;
    BEGIN
        BEGIN
            SELECT CTF.GX_SEGURANCA.FX_CRIPTO(UPPER(P_DS_SENHA))
              INTO V_DS_SENHA_CRIPTOGRAFADA
              FROM DUAL;
          
            BEGIN
                SELECT US.CD_USUARIO,
                       US.NO_USUARIO,
                       US.IC_ATIVO,
                       US.CD_TIPO_USUARIO,
                       US.CD_USUARIO_SUPERIOR,
                       US.CD_LOGIN,
                       US.DS_SENHA,
                       US.DS_LEMBRETE_SENHA,
                       US.IC_BLOQUEADO,
                       US.DH_ULTIMO_ACESSO,
                       SE.DT_EXPIRACAO
                  INTO V_CD_USUARIO,
                       V_NO_USUARIO,
                       V_IC_ATIVO,
                       V_CD_TIPO_USUARIO,
                       V_CD_USUARIO_SUPERIOR,
                       V_CD_LOGIN,
                       V_DS_SENHA,
                       V_DS_LEMBRETE_SENHA,
                       V_IC_BLOQUEADO,
                       V_DH_ULTIMO_ACESSO,
                       V_DT_EXPIRACAO
                  FROM CTF.USUARIO US, CTF.USUARIO_SENHA SE
                 WHERE (
                          (INSTR(P_CD_LOGIN,'@') > 0 AND UPPER(US.DS_EMAIL) = UPPER(P_CD_LOGIN))
                          OR UPPER(US.CD_LOGIN) = UPPER(P_CD_LOGIN)
                       )
                   AND SE.CD_USUARIO = US.CD_USUARIO
                   AND SE.DS_SENHA = US.DS_SENHA
                   AND SE.IC_ATIVO = 'S';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Login inválido.');
                WHEN TOO_MANY_ROWS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Mais de um usuário encontrado para o login informado. Por favor, clique em «Ajuda» e informe o ocorrido.');
            END;
          
            BEGIN
                IF V_IC_BLOQUEADO = 'S' THEN
                    RAISE_APPLICATION_ERROR(-20000, 'Seu usuário está bloqueado. Por favor clique em «Solicite nova senha» para gerar uma nova senha.');
                ELSE
                    IF V_DS_SENHA <> V_DS_SENHA_CRIPTOGRAFADA THEN
                    
                    SELECT COUNT(CD_USUARIO)
                      INTO V_TENTATIVAS_ERRO_LOGON
                      FROM CTF.LOGIN_ERRO
                     WHERE CD_USUARIO = V_CD_USUARIO;
                 
                    IF V_TENTATIVAS_ERRO_LOGON > 3 THEN
                      UPDATE CTF.USUARIO
                         SET IC_BLOQUEADO = 'S'
                       WHERE CD_USUARIO = V_CD_USUARIO;
                      COMMIT;
                      RAISE_APPLICATION_ERROR(-20000, 'Seu usuário foi bloqueado por 3 tentativas de logon. Por favor clique em «Solicite nova senha» para gerar uma nova senha.');
                    ELSE
                      INSERT INTO CTF.LOGIN_ERRO
                        (CD_USUARIO, DH_TENTATIVA_LOGIN, CD_ENDERECO_IP)
                      VALUES
                        (V_CD_USUARIO, SYSDATE, P_IP_USUARIO);
                      COMMIT;
                      RAISE_APPLICATION_ERROR(-20000, 'Senha incorreta. Seu lembrete de senha é: ' || V_DS_LEMBRETE_SENHA);
                    END IF;
                ELSE
                    IF SYSDATE >= V_DT_EXPIRACAO THEN
                        IF SYSDATE = V_DT_EXPIRACAO THEN
                            RAISE_APPLICATION_ERROR(-20001, 'Sua senha expira hoje. Por favor troque sua senha.');
                        ELSE
                            RAISE_APPLICATION_ERROR(-20001, 'Sua senha expirou no dia ' || TO_CHAR(V_DT_EXPIRACAO, 'DD/MM/YYYY') || '. Por favor troque sua senha.');
                        END IF;
                    ELSE
                        DELETE FROM CTF.LOGIN_ERRO WHERE CD_USUARIO = V_CD_USUARIO;
                        -- Atualiza o numero de visitas do usuario
                        UPDATE CTF.USUARIO
                           SET DH_ULTIMO_ACESSO = SYSDATE,
                               NU_VISITAS       = (SELECT MAX(NVL(NU_VISITAS, 0) + 1)
                                                   FROM CTF.USUARIO
                                                  WHERE CD_USUARIO = V_CD_USUARIO)
                         WHERE CD_USUARIO = V_CD_USUARIO;
                        END IF;
                    END IF;
                END IF;
            END;
        END;

        OPEN P_RETORNO FOR
        SELECT US.CD_USUARIO, 
               US.NO_USUARIO, 
               US.DS_LEMBRETE_SENHA, 
               US.DH_ULTIMO_ACESSO, 
               US.IC_CONCORDA_TERMO,
               US.CD_TIPO_USUARIO,
               US.CD_USUARIO_ORIGINAL
          FROM CTF.USUARIO US
         WHERE (
                  (INSTR(P_CD_LOGIN,'@') > 0 AND UPPER(US.DS_EMAIL) = UPPER(P_CD_LOGIN))
                  OR UPPER(US.CD_LOGIN) = UPPER(P_CD_LOGIN)
               );
               
        OPEN P_PERFIS FOR
        SELECT PF.CD_PERFIL,
               SG.SG_SIGLA
          FROM CTF.USUARIO_PERFIL UP
         INNER JOIN
               CTF.PERFIL PF
               ON PF.CD_PERFIL = UP.CD_PERFIL
         INNER JOIN
               CTF.SIGLA SG
               ON SG.CD_SIGLA = PF.CD_SIGLA
         WHERE UP.CD_USUARIO = V_CD_USUARIO
        ;
               
    END PX_EFETUA_LOGIN;
    
    
    PROCEDURE PX_IS_PROFILE_GRANTED (
        P_CD_USUARIO        IN CTF.USUARIO.CD_USUARIO%TYPE,
        P_SG_SIGLA_SISTEMA  IN CTF.SIGLA.SG_SIGLA%TYPE,
        P_SG_SIGLA_PERFIL   IN CTF.SIGLA.SG_SIGLA%TYPE,
        P_RETORNO           OUT T_CURSOR
    )
    IS
    BEGIN
        OPEN P_RETORNO FOR
        SELECT CASE COUNT(UP.CD_PERFIL)
                    WHEN  0 THEN 'N'
                    ELSE 'S'
               END AS "GRANTED"
          FROM CTF.USUARIO_PERFIL UP
         INNER JOIN
               CTF.USUARIO US
               ON US.CD_USUARIO = UP.CD_USUARIO
         INNER JOIN
               CTF.PERFIL PF
               ON PF.CD_PERFIL = UP.CD_PERFIL
         INNER JOIN
               CTF.SISTEMA SI
               ON SI.CD_SISTEMA = UP.CD_SISTEMA
              AND SI.CD_SISTEMA = PF.CD_SISTEMA
         INNER JOIN
               CTF.SIGLA SG_SI
               ON SG_SI.CD_SIGLA = SI.CD_SIGLA
         INNER JOIN
               CTF.SIGLA SG_PF
               ON SG_PF.CD_SIGLA = PF.CD_SIGLA
         WHERE SG_SI.SG_SIGLA = P_SG_SIGLA_SISTEMA
           AND SG_PF.SG_SIGLA = P_SG_SIGLA_PERFIL
           AND US.CD_USUARIO = P_CD_USUARIO
        ;
    END PX_IS_PROFILE_GRANTED;

END GX_ELO_SECURITY;
/