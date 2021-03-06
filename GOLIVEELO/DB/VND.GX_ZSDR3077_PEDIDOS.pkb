CREATE OR REPLACE PACKAGE BODY VND."GX_ZSDR3077_PEDIDOS" AS
  


    PROCEDURE PI_PEDIDO(
        P_CD_PEDIDO             IN VND.PEDIDO.CD_PEDIDO%TYPE,
        P_CD_ITEM_PEDIDO        IN VND.PEDIDO.CD_ITEM_PEDIDO%TYPE,
        P_NU_ORDEM_VENDA        IN VND.PEDIDO.NU_ORDEM_VENDA%TYPE,
        P_CD_PRODUTO_SAP        IN VND.PEDIDO.CD_PRODUTO_SAP%TYPE,
        P_DS_PRODUTO_SAP        IN VND.PEDIDO.DS_PRODUTO_SAP%TYPE,
        P_CD_SACARIA            IN VND.PEDIDO.CD_SACARIA%TYPE,
        P_NU_QUANTIDADE         IN VND.PEDIDO.NU_QUANTIDADE%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.PEDIDO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_DH_EMISSAO            IN VARCHAR2,
        P_CD_SITUACAO_PEDIDO    IN VND.PEDIDO.CD_SITUACAO_PEDIDO%TYPE,
        P_CD_AGENTE_VENDA       IN VND.PEDIDO.CD_AGENTE_VENDA%TYPE,
        P_CD_USUARIO_VENDA      IN VND.PEDIDO.CD_USUARIO_VENDA%TYPE,
        -- Bloqueios
        P_CD_BLOQUEIO_FATURAMENTO       IN VND.PEDIDO.CD_BLOQUEIO_FATURAMENTO%TYPE,         --VBAK-FAKSK
        P_CD_BLOQUEIO_REMESSA           IN VND.PEDIDO.CD_BLOQUEIO_REMESSA%TYPE,             --VBAK-LIFSK
        P_CD_BLOQUEIO_FATURAMENTO_ITEM  IN VND.PEDIDO.CD_BLOQUEIO_FATURAMENTO_ITEM%TYPE,    --VBAP-FAKSP
        P_DS_CREDIT_BLOCK_REASON        IN VND.PEDIDO.DS_CREDIT_BLOCK_REASON%TYPE,          --VBAK-ZZCRE_BLK
        P_CD_BLOQUEIO_CREDITO           IN VND.PEDIDO.CD_BLOQUEIO_CREDITO%TYPE,             --VBUK-CMGST
        P_CD_BLOQUEIO_REMESSA_ITEM      IN VND.PEDIDO.CD_BLOQUEIO_REMESSA_ITEM%TYPE,        --VBEP-LIFSP
        P_DS_ROTEIRO_ENTREGA            IN VND.PEDIDO.DS_ROTEIRO_ENTREGA%TYPE               --Text ID = Z009
    )
    IS
    BEGIN
    
        INSERT INTO VND.PEDIDO (
            CD_PEDIDO,
            CD_ITEM_PEDIDO,
            NU_ORDEM_VENDA,
            CD_PRODUTO_SAP,
            DS_PRODUTO_SAP,
            CD_SACARIA,
            NU_QUANTIDADE,
            CD_CENTRO_EXPEDIDOR,
            DH_ULT_INTERFACE,
            DH_EMISSAO,
            CD_SITUACAO_PEDIDO,
            CD_AGENTE_VENDA,
            CD_USUARIO_VENDA,
            -- Bloqueios
            CD_BLOQUEIO_FATURAMENTO,
            CD_BLOQUEIO_REMESSA,
            CD_BLOQUEIO_FATURAMENTO_ITEM,
            DS_CREDIT_BLOCK_REASON,
            CD_BLOQUEIO_CREDITO,
            CD_BLOQUEIO_REMESSA_ITEM,
            DS_ROTEIRO_ENTREGA
        ) VALUES (
            P_CD_PEDIDO,
            P_CD_ITEM_PEDIDO,
            DECODE(P_NU_ORDEM_VENDA, ' ', NULL, P_NU_ORDEM_VENDA),
            DECODE(P_CD_PRODUTO_SAP, ' ', NULL, P_CD_PRODUTO_SAP),
            DECODE(P_DS_PRODUTO_SAP, ' ', NULL, P_DS_PRODUTO_SAP),
            DECODE(P_CD_SACARIA, ' ', NULL, P_CD_SACARIA),
            DECODE(P_NU_QUANTIDADE, ' ', NULL, P_NU_QUANTIDADE),
            DECODE(P_CD_CENTRO_EXPEDIDOR, ' ', NULL, P_CD_CENTRO_EXPEDIDOR),
            SYSDATE,
            TO_DATE(P_DH_EMISSAO, 'DD/MM/YYYY'),
            DECODE(P_CD_SITUACAO_PEDIDO, 0, NULL, P_CD_SITUACAO_PEDIDO),
            DECODE(P_CD_AGENTE_VENDA, ' ', NULL, P_CD_AGENTE_VENDA),
            DECODE(P_CD_USUARIO_VENDA, ' ', NULL, P_CD_USUARIO_VENDA),
            -- Bloqueios
            DECODE(P_CD_BLOQUEIO_FATURAMENTO, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO),
            DECODE(P_CD_BLOQUEIO_REMESSA, ' ', NULL, P_CD_BLOQUEIO_REMESSA),
            DECODE(P_CD_BLOQUEIO_FATURAMENTO_ITEM, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO_ITEM),
            DECODE(P_DS_CREDIT_BLOCK_REASON, ' ', NULL, P_DS_CREDIT_BLOCK_REASON),
            DECODE(P_CD_BLOQUEIO_CREDITO, ' ', NULL, P_CD_BLOQUEIO_CREDITO),
            DECODE(P_CD_BLOQUEIO_REMESSA_ITEM, ' ', NULL, P_CD_BLOQUEIO_REMESSA_ITEM),
            DECODE(P_DS_ROTEIRO_ENTREGA, ' ', NULL, P_DS_ROTEIRO_ENTREGA)
        )
        ;
    
    END PI_PEDIDO;
    
    
    
    
    PROCEDURE PU_PEDIDO(
        P_CD_PEDIDO             IN VND.PEDIDO.CD_PEDIDO%TYPE,
        P_CD_ITEM_PEDIDO        IN VND.PEDIDO.CD_ITEM_PEDIDO%TYPE,
        P_NU_ORDEM_VENDA        IN VND.PEDIDO.NU_ORDEM_VENDA%TYPE,
        P_CD_PRODUTO_SAP        IN VND.PEDIDO.CD_PRODUTO_SAP%TYPE,
        P_DS_PRODUTO_SAP        IN VND.PEDIDO.DS_PRODUTO_SAP%TYPE,
        P_CD_SACARIA            IN VND.PEDIDO.CD_SACARIA%TYPE,
        P_NU_QUANTIDADE         IN VND.PEDIDO.NU_QUANTIDADE%TYPE,
        P_CD_CENTRO_EXPEDIDOR   IN VND.PEDIDO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_DH_EMISSAO            IN VARCHAR2,
        P_CD_SITUACAO_PEDIDO    IN VND.PEDIDO.CD_SITUACAO_PEDIDO%TYPE,
        P_CD_AGENTE_VENDA       IN VND.PEDIDO.CD_AGENTE_VENDA%TYPE,
        -- Bloqueios
        P_CD_BLOQUEIO_FATURAMENTO       IN VND.PEDIDO.CD_BLOQUEIO_FATURAMENTO%TYPE,         --VBAK-FAKSK
        P_CD_BLOQUEIO_REMESSA           IN VND.PEDIDO.CD_BLOQUEIO_REMESSA%TYPE,             --VBAK-LIFSK
        P_CD_BLOQUEIO_FATURAMENTO_ITEM  IN VND.PEDIDO.CD_BLOQUEIO_FATURAMENTO_ITEM%TYPE,    --VBAP-FAKSP
        P_DS_CREDIT_BLOCK_REASON        IN VND.PEDIDO.DS_CREDIT_BLOCK_REASON%TYPE,          --VBAK-ZZCRE_BLK
        P_CD_BLOQUEIO_CREDITO           IN VND.PEDIDO.CD_BLOQUEIO_CREDITO%TYPE,             --VBUK-CMGST
        P_CD_BLOQUEIO_REMESSA_ITEM      IN VND.PEDIDO.CD_BLOQUEIO_REMESSA_ITEM%TYPE,        --VBEP-LIFSP
        P_DS_ROTEIRO_ENTREGA            IN VND.PEDIDO.DS_ROTEIRO_ENTREGA%TYPE               --Text ID = Z009
    )
    IS
    BEGIN
    
        UPDATE VND.PEDIDO SET
               NU_ORDEM_VENDA                   = DECODE(P_NU_ORDEM_VENDA, ' ', NULL, P_NU_ORDEM_VENDA),
               CD_PRODUTO_SAP                   = DECODE(P_CD_PRODUTO_SAP, ' ', NULL, P_CD_PRODUTO_SAP),
               DS_PRODUTO_SAP                   = DECODE(P_DS_PRODUTO_SAP, ' ', NULL, P_DS_PRODUTO_SAP),
               CD_SACARIA                       = DECODE(P_CD_SACARIA, ' ', NULL, P_CD_SACARIA),
               NU_QUANTIDADE                    = DECODE(P_NU_QUANTIDADE, ' ', NULL, P_NU_QUANTIDADE),
               CD_CENTRO_EXPEDIDOR              = DECODE(P_CD_CENTRO_EXPEDIDOR, ' ', NULL, P_CD_CENTRO_EXPEDIDOR),
               DH_ULT_INTERFACE                 = SYSDATE,
               DH_EMISSAO                       = TO_DATE(P_DH_EMISSAO, 'DD/MM/YYYY'),
               CD_SITUACAO_PEDIDO               = DECODE(P_CD_SITUACAO_PEDIDO, 0, NULL, P_CD_SITUACAO_PEDIDO),
               CD_AGENTE_VENDA                  = DECODE(P_CD_AGENTE_VENDA, ' ', NULL, P_CD_AGENTE_VENDA),
               -- Bloqueios
               CD_BLOQUEIO_FATURAMENTO          = DECODE(P_CD_BLOQUEIO_FATURAMENTO, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO),
               CD_BLOQUEIO_REMESSA              = DECODE(P_CD_BLOQUEIO_REMESSA, ' ', NULL, P_CD_BLOQUEIO_REMESSA),
               CD_BLOQUEIO_FATURAMENTO_ITEM     = DECODE(P_CD_BLOQUEIO_FATURAMENTO_ITEM, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO_ITEM),
               DS_CREDIT_BLOCK_REASON           = DECODE(P_DS_CREDIT_BLOCK_REASON, ' ', NULL, P_DS_CREDIT_BLOCK_REASON),
               CD_BLOQUEIO_CREDITO              = DECODE(P_CD_BLOQUEIO_CREDITO, ' ', NULL, P_CD_BLOQUEIO_CREDITO),
               CD_BLOQUEIO_REMESSA_ITEM         = DECODE(P_CD_BLOQUEIO_REMESSA_ITEM, ' ', NULL, P_CD_BLOQUEIO_REMESSA_ITEM),
               DS_ROTEIRO_ENTREGA               = DECODE(P_DS_ROTEIRO_ENTREGA, ' ', NULL, P_DS_ROTEIRO_ENTREGA)
         WHERE CD_PEDIDO = P_CD_PEDIDO
           AND CD_ITEM_PEDIDO = P_CD_ITEM_PEDIDO
         ;
    
    END PU_PEDIDO;
    


    PROCEDURE PU_DIVISAO_REMESSA
    IS
    BEGIN
      UPDATE VND.DIVISAO_REMESSA 
         SET NU_QUANTIDADE_FORNECIDA = 0
       WHERE NU_QUANTIDADE_FORNECIDA > 0
         AND NU_QUANTIDADE_CONFIRMADA = 0
      ;
    END PU_DIVISAO_REMESSA;
    
    
    
    PROCEDURE PD_DIVISAO_REMESSA(
        P_CD_PEDIDO             IN VND.DIVISAO_REMESSA.CD_PEDIDO%TYPE
    )
    IS
    BEGIN
    
        DELETE FROM VND.DIVISAO_REMESSA WHERE CD_PEDIDO = P_CD_PEDIDO;
    
    END PD_DIVISAO_REMESSA;
    
    
    
    PROCEDURE PI_DIVISAO_REMESSA(
        P_CD_PEDIDO                     IN VND.DIVISAO_REMESSA.CD_PEDIDO%TYPE,
        P_CD_ITEM_PEDIDO                IN VND.DIVISAO_REMESSA.CD_ITEM_PEDIDO%TYPE,
        P_CD_DIVISAO_REMESSA            IN VND.DIVISAO_REMESSA.CD_DIVISAO_REMESSA%TYPE,
        P_DH_REMESSA                    IN VARCHAR2,
        P_NU_QUANTIDADE_ORDEM           IN VND.DIVISAO_REMESSA.NU_QUANTIDADE_ORDEM%TYPE,
        P_NU_QUANTIDADE_ARREDONDADA     IN VND.DIVISAO_REMESSA.NU_QUANTIDADE_ARREDONDADA%TYPE,
        P_NU_QUANTIDADE_CONFIRMADA      IN VND.DIVISAO_REMESSA.NU_QUANTIDADE_CONFIRMADA%TYPE,
        P_NU_QUANTIDADE_FORNECIDA       IN VND.DIVISAO_REMESSA.NU_QUANTIDADE_FORNECIDA%TYPE,
        P_DH_SAIDA                      IN VARCHAR2,
        P_CD_BLOQUEIO_REMESSA           IN VND.DIVISAO_REMESSA.CD_BLOQUEIO_REMESSA%TYPE
    )
    IS
    BEGIN
    
        INSERT INTO VND.DIVISAO_REMESSA (
            CD_PEDIDO,
            CD_ITEM_PEDIDO,
            CD_DIVISAO_REMESSA,
            DH_REMESSA,
            NU_QUANTIDADE_ORDEM,
            NU_QUANTIDADE_ARREDONDADA,
            NU_QUANTIDADE_CONFIRMADA,
            NU_QUANTIDADE_FORNECIDA,
            DH_SAIDA,
            CD_BLOQUEIO_REMESSA
        ) VALUES (
            P_CD_PEDIDO,
            P_CD_ITEM_PEDIDO,
            P_CD_DIVISAO_REMESSA,
            TO_DATE(P_DH_REMESSA, 'DD/MM/YYYY'),
            P_NU_QUANTIDADE_ORDEM,
            P_NU_QUANTIDADE_ARREDONDADA,
            P_NU_QUANTIDADE_CONFIRMADA,
            P_NU_QUANTIDADE_FORNECIDA,
            TO_DATE(P_DH_SAIDA, 'DD/MM/YYYY'),
            DECODE(P_CD_BLOQUEIO_REMESSA, ' ', NULL, P_CD_BLOQUEIO_REMESSA)
        );
    
    END PI_DIVISAO_REMESSA;
    
    
    
    PROCEDURE PI_FATURA(
        P_CD_FATURA                     IN VND.FATURA.CD_FATURA%TYPE
    )
    IS
    BEGIN
    
        INSERT INTO VND.FATURA (CD_FATURA) VALUES (P_CD_FATURA);
    
    END PI_FATURA;
    
    
    
    PROCEDURE PU_ITEM_FATURA(
        P_CD_FATURA                     IN VND.ITEM_FATURA.CD_FATURA%TYPE,
        P_CD_ITEM_FATURA                IN VND.ITEM_FATURA.CD_ITEM_FATURA%TYPE,
        P_CD_PEDIDO                     IN VND.ITEM_FATURA.CD_PEDIDO%TYPE,
        P_CD_ITEM_PEDIDO                IN VND.ITEM_FATURA.CD_ITEM_PEDIDO%TYPE
    )
    IS
    BEGIN
    
        UPDATE VND.ITEM_FATURA
           SET CD_PEDIDO = P_CD_PEDIDO,
               CD_ITEM_PEDIDO = P_CD_ITEM_PEDIDO
         WHERE CD_FATURA = P_CD_FATURA
           AND CD_ITEM_FATURA = P_CD_ITEM_FATURA
        ;
        
    END PU_ITEM_FATURA;
    
    
    
    PROCEDURE PI_ITEM_FATURA(
        P_CD_FATURA                     IN VND.ITEM_FATURA.CD_FATURA%TYPE,
        P_CD_ITEM_FATURA                IN VND.ITEM_FATURA.CD_ITEM_FATURA%TYPE,
        P_CD_PEDIDO                     IN VND.ITEM_FATURA.CD_PEDIDO%TYPE,
        P_CD_ITEM_PEDIDO                IN VND.ITEM_FATURA.CD_ITEM_PEDIDO%TYPE
    )
    IS
    BEGIN
    
        INSERT INTO VND.ITEM_FATURA (
            CD_FATURA,
            CD_ITEM_FATURA,
            CD_PEDIDO,
            CD_ITEM_PEDIDO
        ) VALUES (
            P_CD_FATURA,
            P_CD_ITEM_FATURA,
            P_CD_PEDIDO,
            P_CD_ITEM_PEDIDO
        );

    END PI_ITEM_FATURA;    
    
    
    
    PROCEDURE PU_PEDIDO_EXCLUIR(
        P_CD_PEDIDO                     IN VND.PEDIDO.CD_PEDIDO%TYPE
    )
    IS
    BEGIN
    
        UPDATE VND.PEDIDO
           SET CD_SITUACAO_PEDIDO = '90',
               IC_CARTEIRA        = 'N',
               DH_ULT_INTERFACE   = SYSDATE
         WHERE CD_PEDIDO = P_CD_PEDIDO
         ;
    
    END PU_PEDIDO_EXCLUIR;
    
    
    
    PROCEDURE PU_PEDIDO_REMESSA(
        P_CD_PEDIDO                     IN VND.PEDIDO.CD_PEDIDO%TYPE,
        P_CD_ITEM_PEDIDO                IN VND.PEDIDO.CD_ITEM_PEDIDO%TYPE,
        P_NU_QUANTIDADE_SALDO           IN VND.PEDIDO.NU_QUANTIDADE_SALDO%TYPE,
        P_NU_QUANTIDADE_ENTREGUE        IN VND.PEDIDO.NU_QUANTIDADE_ENTREGUE%TYPE,
        P_IC_BLOQUEIO_DIVISAO_REMESSA   IN VND.PEDIDO.IC_BLOQUEIO_DIVISAO_REMESSA%TYPE,
        P_DH_ENTREGA                    IN VARCHAR2
    )
    IS
    BEGIN
    
        UPDATE VND.PEDIDO
           SET NU_QUANTIDADE_SALDO          = P_NU_QUANTIDADE_SALDO,
               NU_QUANTIDADE_ENTREGUE       = P_NU_QUANTIDADE_ENTREGUE,
               DH_ULT_INTERFACE             = SYSDATE,
               IC_BLOQUEIO_DIVISAO_REMESSA  = P_IC_BLOQUEIO_DIVISAO_REMESSA,
               DH_ENTREGA                   = DECODE(P_DH_ENTREGA, ' ', NULL, TO_DATE(P_DH_ENTREGA, 'DD/MM/YYYY'))
         WHERE CD_PEDIDO                    = P_CD_PEDIDO
           AND CD_ITEM_PEDIDO               = P_CD_ITEM_PEDIDO
        ;
    
    END PU_PEDIDO_REMESSA;
    
    
    
    PROCEDURE PI_BLOQUEIO_CREDITO(
        P_CD_BLOQUEIO_CREDITO           IN VND.BLOQUEIO_CREDITO.CD_BLOQUEIO_CREDITO%TYPE,
        P_DS_BLOQUEIO_CREDITO           IN VND.BLOQUEIO_CREDITO.DS_BLOQUEIO_CREDITO%TYPE
    )
    IS
    BEGIN
    
        INSERT INTO VND.BLOQUEIO_CREDITO (
            CD_BLOQUEIO_CREDITO,
            DS_BLOQUEIO_CREDITO
        ) VALUES (
            P_CD_BLOQUEIO_CREDITO,
            P_DS_BLOQUEIO_CREDITO
        )
        ;
    
    END PI_BLOQUEIO_CREDITO;
    
    
    
    PROCEDURE PU_PEDIDO_CARTEIRA(
        P_NU_ORDEM_VENDA                IN VND.PEDIDO.NU_ORDEM_VENDA%TYPE,
        P_CD_ITEM_PEDIDO                IN VND.PEDIDO.CD_ITEM_PEDIDO%TYPE
    )
    IS
    BEGIN

        UPDATE VND.PEDIDO
           SET IC_CARTEIRA = 'N',
               DH_ULT_INTERFACE = SYSDATE
         WHERE NU_ORDEM_VENDA = P_NU_ORDEM_VENDA
           AND CD_ITEM_PEDIDO = P_CD_ITEM_PEDIDO
        ;
        
    END PU_PEDIDO_CARTEIRA;
    
    
    
    PROCEDURE PU_PEDIDO_CONTRATO(
        P_NU_ORDEM_VENDA                IN VND.PEDIDO.NU_ORDEM_VENDA%TYPE,
        P_CD_ITEM_PEDIDO                IN VND.PEDIDO.CD_ITEM_PEDIDO%TYPE,
        P_NU_CONTRATO                   IN VND.PEDIDO.NU_CONTRATO%TYPE,
        P_NU_CONTRATO_SAP               IN VND.PEDIDO.NU_CONTRATO_SAP%TYPE,
        P_CD_ITEM_CONTRATO              IN VND.PEDIDO.CD_ITEM_CONTRATO%TYPE
    )
    IS
    BEGIN
    
        UPDATE VND.PEDIDO
           SET NU_CONTRATO       = P_NU_CONTRATO,
               NU_CONTRATO_SAP   = P_NU_CONTRATO_SAP,
               CD_ITEM_CONTRATO  = P_CD_ITEM_CONTRATO,
               DH_ULT_INTERFACE  = SYSDATE
         WHERE NU_ORDEM_VENDA    = P_NU_ORDEM_VENDA
           AND CD_ITEM_PEDIDO    = P_CD_ITEM_PEDIDO
        ;
        
    END PU_PEDIDO_CONTRATO;
    
    
    
    PROCEDURE PU_ITEM_CONTRATO_DELIVERED(
        P_CD_CONTRATO                   IN VND.ITEM_CONTRATO.CD_CONTRATO%TYPE,
        P_CD_ITEM_CONTRATO              IN VND.ITEM_CONTRATO.CD_ITEM_CONTRATO%TYPE,
        P_NU_QTY_DELIVERED              IN VND.ITEM_CONTRATO.NU_QTY_DELIVERED%TYPE
    )
    IS
    BEGIN
    
        UPDATE VND.ITEM_CONTRATO
           SET NU_QTY_DELIVERED = TO_NUMBER(P_NU_QTY_DELIVERED),
               DH_ULT_INTERFACE = SYSDATE
         WHERE CD_CONTRATO = P_CD_CONTRATO
           AND CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
        ;
    
    END PU_ITEM_CONTRATO_DELIVERED;
    
    
    
    PROCEDURE PU_CONTRATO(
        P_CD_CONTRATO                   IN VND.CONTRATO.CD_CONTRATO%TYPE,
        P_CD_SITUACAO_CONTRATO          IN VND.CONTRATO.CD_SITUACAO_CONTRATO%TYPE,
        P_CD_BLOCKING_REASON            IN VND.CONTRATO.CD_BLOCKING_REASON%TYPE,
        P_DH_ENVIO_ADVEN                IN VARCHAR2,
        P_CD_USUARIO_VENDA              IN VND.CONTRATO.CD_USUARIO_VENDA%TYPE,
        P_CD_AGENTE_VENDA               IN VND.CONTRATO.CD_AGENTE_VENDA%TYPE,
        P_DH_ASSINATURA                 IN VARCHAR2,
        P_DT_PAGAMENTO                  IN VARCHAR2,
        P_DS_FORMA_PAGAMENTO            IN VND.CONTRATO.DS_FORMA_PAGAMENTO%TYPE,
        P_VL_FRETE_DISTRIBUICAO         IN VND.CONTRATO.VL_FRETE_DISTRIBUICAO%TYPE,
        P_CD_INCOTERMS                  IN VND.CONTRATO.CD_INCOTERMS%TYPE,
        P_DH_LISTA_PRECO                IN VARCHAR2,
        P_DS_PROTOCOLO                  IN VND.CONTRATO.DS_PROTOCOLO%TYPE,
        P_NU_CONTRATO                   IN VND.CONTRATO.NU_CONTRATO%TYPE,
        P_CD_STATUS_CONTRATO            IN VND.CONTRATO.CD_STATUS_CONTRATO%TYPE,
        P_CD_TIPO_PAGAMENTO             IN VND.CONTRATO.CD_TIPO_PAGAMENTO%TYPE,
        P_NU_CONTRATO_SAP               IN VND.CONTRATO.NU_CONTRATO_SAP%TYPE,
        P_CD_TIPO_CONTRATO              IN VND.CONTRATO.CD_TIPO_CONTRATO%TYPE,
        P_CD_CLIENTE_PO_NUMERO          IN VND.CONTRATO.CD_CLIENTE_PO_NUMERO%TYPE,
        -- Bloqueios
        P_CD_BLOQUEIO_FATURAMENTO       IN VND.CONTRATO.CD_BLOQUEIO_FATURAMENTO%TYPE,   --VBAK-FAKSK,
        P_DS_CREDIT_BLOCK_REASON        IN VND.CONTRATO.DS_CREDIT_BLOCK_REASON%TYPE,    --VBAK-ZZCRE_BLK
        P_CD_BLOQUEIO_CREDITO           IN VND.CONTRATO.CD_BLOQUEIO_CREDITO%TYPE,       --VBUK-CMGST
        P_DS_ROTEIRO_ENTREGA            IN VND.CONTRATO.DS_ROTEIRO_ENTREGA%TYPE         --Text ID = Z009
    )
    IS
    BEGIN
    
        UPDATE VND.CONTRATO
           SET CD_SITUACAO_CONTRATO = DECODE(P_CD_SITUACAO_CONTRATO, ' ', NULL, P_CD_SITUACAO_CONTRATO),
               CD_BLOCKING_REASON = DECODE(P_CD_BLOCKING_REASON, ' ', NULL, P_CD_BLOCKING_REASON),
               DH_ULT_INTERFACE = SYSDATE,
               DH_ENVIO_ADVEN = DECODE(DH_ENVIO_ADVEN, NULL, TO_DATE(P_DH_ENVIO_ADVEN,'DD/MM/YYYY'), DH_ENVIO_ADVEN),
               CD_USUARIO_VENDA = DECODE(P_CD_USUARIO_VENDA, ' ', NULL, P_CD_USUARIO_VENDA),
               CD_AGENTE_VENDA = DECODE(P_CD_AGENTE_VENDA, ' ', NULL, P_CD_AGENTE_VENDA),
               DH_ASSINATURA = DECODE(DH_ASSINATURA, NULL, TO_DATE(P_DH_ASSINATURA,'DD/MM/YYYY'), DH_ASSINATURA),
               DT_PAGAMENTO = DECODE(DT_PAGAMENTO, NULL, TO_DATE(P_DT_PAGAMENTO,'DD/MM/YYYY'), DT_PAGAMENTO),
               DS_FORMA_PAGAMENTO = DECODE(DS_FORMA_PAGAMENTO, NULL, DECODE(P_DS_FORMA_PAGAMENTO, ' ', NULL, P_DS_FORMA_PAGAMENTO), DS_FORMA_PAGAMENTO),
               VL_FRETE_DISTRIBUICAO = P_VL_FRETE_DISTRIBUICAO,
               CD_INCOTERMS = DECODE(P_CD_INCOTERMS, ' ', NULL, P_CD_INCOTERMS),
               DH_LISTA_PRECO = DECODE(DH_LISTA_PRECO, NULL, TO_DATE(P_DH_LISTA_PRECO,'DD/MM/YYYY'), DH_LISTA_PRECO),
               DS_PROTOCOLO = DECODE(DS_PROTOCOLO, NULL, P_DS_PROTOCOLO, DS_PROTOCOLO),
               IC_SIGNED = DECODE(IC_SIGNED, NULL, 'S', IC_SIGNED),
               IC_SAP_READY = DECODE(IC_SAP_READY, NULL, 'N', IC_SAP_READY),
               IC_ORIGEM_CONTRATO = DECODE(IC_ORIGEM_CONTRATO, NULL, 'F', IC_ORIGEM_CONTRATO),
               NU_CONTRATO = DECODE(IC_SAP, 'S', DECODE(P_NU_CONTRATO, ' ', NULL, P_NU_CONTRATO), NU_CONTRATO),
               CD_STATUS_CONTRATO = DECODE(P_CD_STATUS_CONTRATO, ' ', NULL, P_CD_STATUS_CONTRATO),
               CD_TIPO_PAGAMENTO = DECODE(P_CD_TIPO_PAGAMENTO, ' ', NULL, P_CD_TIPO_PAGAMENTO),
               NU_CONTRATO_SAP = DECODE(P_NU_CONTRATO_SAP, ' ', NULL, P_NU_CONTRATO_SAP),
               CD_TIPO_CONTRATO = DECODE(P_CD_TIPO_CONTRATO, ' ', NULL, P_CD_TIPO_CONTRATO),
               CD_CLIENTE_PO_NUMERO = P_CD_CLIENTE_PO_NUMERO,
               -- Bloqueios
               CD_BLOQUEIO_REMESSA = DECODE(P_CD_BLOCKING_REASON, ' ', NULL, P_CD_BLOCKING_REASON),                 --VBAK-LIFSK
               CD_BLOQUEIO_FATURAMENTO = DECODE(P_CD_BLOQUEIO_FATURAMENTO, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO),   --VBAK-FAKSK
               DS_CREDIT_BLOCK_REASON = DECODE(P_DS_CREDIT_BLOCK_REASON, ' ', NULL, P_DS_CREDIT_BLOCK_REASON),      --VBAK-ZZCRE_BLK
               CD_BLOQUEIO_CREDITO = DECODE(P_CD_BLOQUEIO_CREDITO, ' ', NULL, P_CD_BLOQUEIO_CREDITO),               --VBUK-CMGST
               DS_ROTEIRO_ENTREGA = DECODE(P_DS_ROTEIRO_ENTREGA, ' ', NULL, P_DS_ROTEIRO_ENTREGA)                   --Text ID = Z009
         WHERE CD_CONTRATO = P_CD_CONTRATO
         ;
    
    END PU_CONTRATO;
    
    
    
    PROCEDURE PI_CLIENTE_CONTRATO(
        P_CD_CLIENTE                    IN VND.CLIENTE_CONTRATO.CD_CLIENTE%TYPE,
        P_CD_CLIENTE_CONTRATO           IN VND.CLIENTE_CONTRATO.CD_CLIENTE_CONTRATO%TYPE,
        P_CD_CLIENTE_CONTRATO_PAGADOR   IN VND.CLIENTE_CONTRATO.CD_CLIENTE_CONTRATO_PAGADOR%TYPE,
        P_CD_GRUPO_CLIENTES             IN VND.CLIENTE_CONTRATO.CD_GRUPO_CLIENTES%TYPE,
        P_CD_MUNICIPIO                  IN VND.CLIENTE_CONTRATO.CD_MUNICIPIO%TYPE,
        P_CD_SEGMENTO_CLIENTE           IN VND.CLIENTE_CONTRATO.CD_SEGMENTO_CLIENTE%TYPE,
        P_DS_BAIRRO                     IN VND.CLIENTE_CONTRATO.DS_BAIRRO%TYPE,
        P_DS_ENDERECO                   IN VND.CLIENTE_CONTRATO.DS_ENDERECO%TYPE,
        P_IC_TIPO_PESSOA                IN VND.CLIENTE_CONTRATO.IC_TIPO_PESSOA%TYPE,
        P_NO_CLIENTE                    IN VND.CLIENTE_CONTRATO.NO_CLIENTE%TYPE,
        P_NO_CONTATO                    IN VND.CLIENTE_CONTRATO.NO_CONTATO%TYPE,
        P_NU_CEP                        IN VND.CLIENTE_CONTRATO.NU_CEP%TYPE,
        P_NU_RG_INSCRICAO_ESTADUAL      IN VND.CLIENTE_CONTRATO.NU_RG_INSCRICAO_ESTADUAL%TYPE,
        P_NU_CPF_CNPJ                   IN VND.CLIENTE_CONTRATO.NU_CPF_CNPJ%TYPE,
        P_NU_TELEFONE                   IN VND.CLIENTE_CONTRATO.NU_TELEFONE%TYPE,
        P_SG_TAMANHO_CLIENTE            IN VND.CLIENTE_CONTRATO.SG_TAMANHO_CLIENTE%TYPE,
        P_CD_SALES_ORG                  IN VND.CLIENTE_CONTRATO.CD_SALES_ORG%TYPE,
        P_CD_DISTRIBUTION_CHANNEL       IN VND.CLIENTE_CONTRATO.CD_DISTRIBUTION_CHANNEL%TYPE,
        P_CD_SALES_DIVISION             IN VND.CLIENTE_CONTRATO.CD_SALES_DIVISION%TYPE
    )
    IS
    BEGIN
    
        INSERT INTO VND.CLIENTE_CONTRATO (
            CD_CLIENTE,
            CD_CLIENTE_CONTRATO,
            CD_CLIENTE_CONTRATO_PAGADOR,
            CD_GRUPO_CLIENTES,
            CD_MUNICIPIO,
            CD_SEGMENTO_CLIENTE,
            DH_INCLUSAO,
            DS_BAIRRO,
            DS_ENDERECO,
            IC_TIPO_PESSOA,
            NO_CLIENTE,
            NO_CONTATO,
            NU_CEP,
            NU_RG_INSCRICAO_ESTADUAL,
            NU_CPF_CNPJ,
            NU_TELEFONE,
            SG_TAMANHO_CLIENTE,
            CD_SALES_ORG,
            CD_DISTRIBUTION_CHANNEL,
            CD_SALES_DIVISION
        ) VALUES (
            P_CD_CLIENTE,
            P_CD_CLIENTE_CONTRATO,
            DECODE(P_CD_CLIENTE_CONTRATO_PAGADOR,0, NULL, P_CD_CLIENTE_CONTRATO_PAGADOR),
            DECODE(P_CD_GRUPO_CLIENTES,' ', NULL, P_CD_GRUPO_CLIENTES),
            DECODE(P_CD_MUNICIPIO, 000000, NULL, P_CD_MUNICIPIO),
            DECODE(P_CD_SEGMENTO_CLIENTE,0 , NULL, P_CD_SEGMENTO_CLIENTE),
            SYSDATE,
            DECODE(P_DS_BAIRRO,' ', NULL, P_DS_BAIRRO),
            DECODE(P_DS_ENDERECO,' ', NULL, P_DS_ENDERECO),
            P_IC_TIPO_PESSOA,
            DECODE(P_NO_CLIENTE,' ', NULL, P_NO_CLIENTE),
            DECODE(P_NO_CONTATO,' ', NULL, P_NO_CONTATO),
            DECODE(P_NU_CEP,' ', NULL, P_NU_CEP),
            DECODE(P_NU_RG_INSCRICAO_ESTADUAL,' ', NULL, P_NU_RG_INSCRICAO_ESTADUAL),
            DECODE(P_NU_CPF_CNPJ,' ', NULL, P_NU_CPF_CNPJ),
            DECODE(P_NU_TELEFONE,' ', NULL, P_NU_TELEFONE),
            DECODE(P_SG_TAMANHO_CLIENTE,' ', NULL, P_SG_TAMANHO_CLIENTE),
            DECODE(P_CD_SALES_ORG,' ', NULL, P_CD_SALES_ORG),
            DECODE(P_CD_DISTRIBUTION_CHANNEL,' ', NULL, P_CD_DISTRIBUTION_CHANNEL),
            DECODE(P_CD_SALES_DIVISION,' ', NULL, P_CD_SALES_DIVISION)
        )
        ;
    
    END PI_CLIENTE_CONTRATO;
    
    
    
    PROCEDURE PI_CONTRATO(
        P_CD_CONTRATO                   IN VND.CONTRATO.CD_CONTRATO%TYPE,
        P_CD_CLIENTE_CONTRATO           IN VND.CONTRATO.CD_CLIENTE_CONTRATO%TYPE,
        P_CD_BLOCKING_REASON            IN VND.CONTRATO.CD_BLOCKING_REASON%TYPE,
        P_CD_DISTRIBUTION_CHANNEL       IN VND.CONTRATO.CD_DISTRIBUTION_CHANNEL%TYPE,
        P_CD_SALES_DIVISION             IN VND.CONTRATO.CD_SALES_DIVISION%TYPE,
        P_CD_SALES_ORG                  IN VND.CONTRATO.CD_SALES_ORG%TYPE,
        P_CD_STATUS_CONTRATO            IN VND.CONTRATO.CD_STATUS_CONTRATO%TYPE,
        P_CD_TIPO_CONTRATO              IN VND.CONTRATO.CD_TIPO_CONTRATO%TYPE,
        P_DH_INCLUSAO                   IN VARCHAR2,
        P_NU_CONTRATO                   IN VND.CONTRATO.NU_CONTRATO%TYPE,
        P_NU_CONTRATO_SAP               IN VND.CONTRATO.NU_CONTRATO_SAP%TYPE,
        P_DT_INICIO                     IN VARCHAR2,
        P_DT_FIM                        IN VARCHAR2,
        P_DH_ENVIO_ADVEN                IN VARCHAR2,
        P_CD_USUARIO_VENDA              IN VND.CONTRATO.CD_USUARIO_VENDA%TYPE,
        P_CD_AGENTE_VENDA               IN VND.CONTRATO.CD_AGENTE_VENDA%TYPE,
        P_DH_ASSINATURA                 IN VARCHAR2,
        P_DT_PAGAMENTO                  IN VARCHAR2,
        P_CD_FORMA_PAGAMENTO            IN VND.CONTRATO.CD_FORMA_PAGAMENTO%TYPE,
        P_DS_FORMA_PAGAMENTO            IN VND.CONTRATO.DS_FORMA_PAGAMENTO%TYPE,
        P_VL_FRETE_DISTRIBUICAO         IN VND.CONTRATO.VL_FRETE_DISTRIBUICAO%TYPE,
        P_CD_INCOTERMS                  IN VND.CONTRATO.CD_INCOTERMS%TYPE, 
        P_DH_LISTA_PRECO                IN VARCHAR2,
        P_DS_PROTOCOLO                  IN VND.CONTRATO.DS_PROTOCOLO%TYPE,
        P_CD_TIPO_PAGAMENTO             IN VND.CONTRATO.CD_TIPO_PAGAMENTO%TYPE,
        P_CD_SITUACAO_CONTRATO          IN VND.CONTRATO.CD_SITUACAO_CONTRATO%TYPE,
        P_CD_CLIENTE_PO_NUMERO          IN VND.CONTRATO.CD_CLIENTE_PO_NUMERO%TYPE,
        -- Bloqueios
        P_CD_BLOQUEIO_FATURAMENTO       IN VND.CONTRATO.CD_BLOQUEIO_FATURAMENTO%TYPE,   --VBAK-FAKSK,
        P_DS_CREDIT_BLOCK_REASON        IN VND.CONTRATO.DS_CREDIT_BLOCK_REASON%TYPE,    --VBAK-ZZCRE_BLK
        P_CD_BLOQUEIO_CREDITO           IN VND.CONTRATO.CD_BLOQUEIO_CREDITO%TYPE,       --VBUK-CMGST
        P_DS_ROTEIRO_ENTREGA            IN VND.CONTRATO.DS_ROTEIRO_ENTREGA%TYPE         --Text ID = Z009
    )
    IS
    BEGIN
    
        INSERT INTO VND.CONTRATO (
            CD_CONTRATO,
            CD_CLIENTE_CONTRATO,
            CD_BLOCKING_REASON,
            CD_DISTRIBUTION_CHANNEL,
            CD_SALES_DIVISION,
            CD_SALES_ORG,
            CD_STATUS_CONTRATO,
            CD_TIPO_CONTRATO,
            DH_INCLUSAO,
            IC_ATIVO,
            NU_CONTRATO,
            NU_CONTRATO_SAP,
            DT_INICIO,
            DT_FIM,
            IC_SAP,
            DH_ULT_INTERFACE,
            DH_ENVIO_ADVEN,
            CD_USUARIO_VENDA,
            CD_AGENTE_VENDA,
            DH_ASSINATURA,
            DT_PAGAMENTO,
            CD_FORMA_PAGAMENTO,
            DS_FORMA_PAGAMENTO,
            VL_FRETE_DISTRIBUICAO,
            CD_INCOTERMS,
            DH_LISTA_PRECO,
            DS_PROTOCOLO,
            IC_SIGNED,
            IC_SAP_READY,
            IC_ORIGEM_CONTRATO,
            CD_TIPO_PAGAMENTO,
            CD_SITUACAO_CONTRATO,
            CD_CLIENTE_PO_NUMERO,
            -- Bloqueios
            CD_BLOQUEIO_REMESSA,
            CD_BLOQUEIO_FATURAMENTO,
            DS_CREDIT_BLOCK_REASON,
            CD_BLOQUEIO_CREDITO,
            DS_ROTEIRO_ENTREGA
        ) VALUES (
            P_CD_CONTRATO,
            P_CD_CLIENTE_CONTRATO,
            DECODE(P_CD_BLOCKING_REASON, ' ', NULL, P_CD_BLOCKING_REASON),
            DECODE(P_CD_DISTRIBUTION_CHANNEL, ' ', NULL, P_CD_DISTRIBUTION_CHANNEL),
            DECODE(P_CD_SALES_DIVISION, ' ', NULL, P_CD_SALES_DIVISION),
            DECODE(P_CD_SALES_ORG, ' ', NULL, P_CD_SALES_ORG),
            DECODE(P_CD_STATUS_CONTRATO, ' ', NULL, P_CD_STATUS_CONTRATO),
            DECODE(P_CD_TIPO_CONTRATO, ' ', NULL, P_CD_TIPO_CONTRATO),
            TO_DATE(P_DH_INCLUSAO, 'DD/MM/YYYY'),
            'S',
            DECODE(P_NU_CONTRATO, ' ', NULL, P_NU_CONTRATO),
            DECODE(P_NU_CONTRATO_SAP, ' ', NULL, P_NU_CONTRATO_SAP),
            TO_DATE(P_DT_INICIO, 'DD/MM/YYYY'),
            TO_DATE(P_DT_FIM, 'DD/MM/YYYY'),
            'S',
            SYSDATE,
            TO_DATE(P_DH_ENVIO_ADVEN, 'DD/MM/YYYY'),
            DECODE(P_CD_USUARIO_VENDA, ' ', NULL, P_CD_USUARIO_VENDA),
            DECODE(P_CD_AGENTE_VENDA, ' ', NULL, P_CD_AGENTE_VENDA),
            TO_DATE(P_DH_ASSINATURA,'DD/MM/YYYY'),
            TO_DATE(P_DT_PAGAMENTO,'DD/MM/YYYY'),
            DECODE(P_CD_FORMA_PAGAMENTO, ' ', NULL, P_CD_FORMA_PAGAMENTO),
            DECODE(P_DS_FORMA_PAGAMENTO, ' ', NULL, P_DS_FORMA_PAGAMENTO),
            P_VL_FRETE_DISTRIBUICAO,
            DECODE(P_CD_INCOTERMS, ' ', NULL, P_CD_INCOTERMS),
            TO_DATE(P_DH_LISTA_PRECO,'DD/MM/YYYY'),
            P_DS_PROTOCOLO,
            'S',
            'N',
            'F',
            DECODE(P_CD_TIPO_PAGAMENTO, ' ', NULL, P_CD_TIPO_PAGAMENTO),
            DECODE(P_CD_SITUACAO_CONTRATO, ' ', NULL, P_CD_SITUACAO_CONTRATO),
            P_CD_CLIENTE_PO_NUMERO,
            -- Bloqueios
            DECODE(P_CD_BLOCKING_REASON, ' ', NULL, P_CD_BLOCKING_REASON),
            DECODE(P_CD_BLOQUEIO_FATURAMENTO, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO),
            DECODE(P_DS_CREDIT_BLOCK_REASON, ' ', NULL, P_DS_CREDIT_BLOCK_REASON),
            DECODE(P_CD_BLOQUEIO_CREDITO, ' ', NULL, P_CD_BLOQUEIO_CREDITO),
            DECODE(P_DS_ROTEIRO_ENTREGA, ' ', NULL, P_DS_ROTEIRO_ENTREGA)
        )
        ;
    
    END PI_CONTRATO;
    
    
    
    PROCEDURE PI_ITEM_CONTRATO(
        P_CD_ITEM_CONTRATO              IN VND.ITEM_CONTRATO.CD_ITEM_CONTRATO%TYPE,
        P_CD_PRODUTO_SAP                IN VND.ITEM_CONTRATO.CD_PRODUTO_SAP%TYPE,
        P_NO_PRODUTO                    IN VND.ITEM_CONTRATO.NO_PRODUTO%TYPE,
        P_NU_QUANTIDADE                 IN VND.ITEM_CONTRATO.NU_QUANTIDADE%TYPE,
        P_CD_CULTURA_SAP                IN VND.ITEM_CONTRATO.CD_CULTURA_SAP%TYPE,
        P_CD_SACARIA                    IN VND.ITEM_CONTRATO.CD_SACARIA%TYPE,
        P_CD_CENTRO_EXPEDIDOR           IN VND.ITEM_CONTRATO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_PC_COMISSAO                   IN VND.ITEM_CONTRATO.PC_COMISSAO%TYPE,
        P_VL_PRECO_NEGOCIADO            IN VND.ITEM_CONTRATO.VL_PRECO_NEGOCIADO%TYPE,
        P_CD_CONTRATO                   IN VND.ITEM_CONTRATO.CD_CONTRATO%TYPE,
        P_NU_QTY_DELIVERED              IN VND.ITEM_CONTRATO.NU_QTY_DELIVERED%TYPE,
        P_CD_MOTIVO_RECUSA              IN VND.ITEM_CONTRATO.CD_MOTIVO_RECUSA%TYPE,
        P_DT_PAGO                       IN VARCHAR2,
        P_NU_CONTRATO_SUBSTITUI         IN VND.ITEM_CONTRATO.NU_CONTRATO_SUBSTITUI%TYPE,
        P_CD_ITEN_PO_NUMERO             IN VND.ITEM_CONTRATO.CD_ITEN_PO_NUMERO%TYPE,
        -- Bloqueio
        P_CD_BLOQUEIO_FATURAMENTO_ITEM  IN VND.ITEM_CONTRATO.CD_BLOQUEIO_FATURAMENTO_ITEM%TYPE  --VBAP-FAKSP
    )
    IS
    BEGIN
    
        INSERT INTO VND.ITEM_CONTRATO (
            CD_ITEM_CONTRATO,
            CD_PRODUTO_SAP,
            NO_PRODUTO,
            NU_QUANTIDADE,
            CD_CULTURA_SAP,
            CD_SACARIA,
            CD_CENTRO_EXPEDIDOR,
            PC_COMISSAO,
            VL_PRECO_NEGOCIADO,
            CD_CONTRATO,
            NU_QTY_DELIVERED,
            DH_ULT_INTERFACE,
            CD_MOTIVO_RECUSA,
            IC_RECUSADO,
            DT_PAGO,
            NU_CONTRATO_SUBSTITUI,
            CD_ITEN_PO_NUMERO,
            CD_BLOQUEIO_FATURAMENTO_ITEM
        ) VALUES (
            P_CD_ITEM_CONTRATO,
            DECODE(P_CD_PRODUTO_SAP, ' ', NULL, P_CD_PRODUTO_SAP),
            DECODE(P_NO_PRODUTO, ' ', NULL, P_NO_PRODUTO),
            P_NU_QUANTIDADE,
            DECODE(P_CD_CULTURA_SAP, ' ', NULL, P_CD_CULTURA_SAP),
            DECODE(P_CD_SACARIA, ' ', NULL, P_CD_SACARIA),
            DECODE(P_CD_CENTRO_EXPEDIDOR, ' ', NULL, P_CD_CENTRO_EXPEDIDOR),
            P_PC_COMISSAO,
            P_VL_PRECO_NEGOCIADO,
            P_CD_CONTRATO,
            TO_NUMBER(P_NU_QTY_DELIVERED),
            SYSDATE,
            DECODE(P_CD_MOTIVO_RECUSA, ' ', NULL, P_CD_MOTIVO_RECUSA),
            DECODE(P_CD_MOTIVO_RECUSA, ' ', 'N', 'S'),
            DECODE(P_DT_PAGO, '00/00/0000', NULL, TO_DATE(P_DT_PAGO, 'DD/MM/YYYY')),
            DECODE(P_NU_CONTRATO_SUBSTITUI, ' ', NULL, P_NU_CONTRATO_SUBSTITUI),
            P_CD_ITEN_PO_NUMERO,
            DECODE(P_CD_BLOQUEIO_FATURAMENTO_ITEM, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO_ITEM)
        )
        ;
    
    END PI_ITEM_CONTRATO;
    
    
    
    PROCEDURE PU_ITEM_CONTRATO(
        P_CD_CONTRATO                   IN VND.ITEM_CONTRATO.CD_CONTRATO%TYPE,
        P_CD_ITEM_CONTRATO              IN VND.ITEM_CONTRATO.CD_ITEM_CONTRATO%TYPE,
        P_CD_PRODUTO_SAP                IN VND.ITEM_CONTRATO.CD_PRODUTO_SAP%TYPE,
        P_NO_PRODUTO                    IN VND.ITEM_CONTRATO.NO_PRODUTO%TYPE,
        P_NU_QUANTIDADE                 IN VND.ITEM_CONTRATO.NU_QUANTIDADE%TYPE,
        P_CD_CULTURA_SAP                IN VND.ITEM_CONTRATO.CD_CULTURA_SAP%TYPE,
        P_CD_SACARIA                    IN VND.ITEM_CONTRATO.CD_SACARIA%TYPE,
        P_CD_CENTRO_EXPEDIDOR           IN VND.ITEM_CONTRATO.CD_CENTRO_EXPEDIDOR%TYPE,
        P_PC_COMISSAO                   IN VND.ITEM_CONTRATO.PC_COMISSAO%TYPE,
        P_VL_PRECO_NEGOCIADO            IN VND.ITEM_CONTRATO.VL_PRECO_NEGOCIADO%TYPE,
        P_NU_QTY_DELIVERED              IN VND.ITEM_CONTRATO.NU_QTY_DELIVERED%TYPE,
        P_CD_MOTIVO_RECUSA              IN VND.ITEM_CONTRATO.CD_MOTIVO_RECUSA%TYPE,
        P_DT_PAGO                       IN VARCHAR2,
        P_NU_CONTRATO_SUBSTITUI         IN VND.ITEM_CONTRATO.NU_CONTRATO_SUBSTITUI%TYPE,
        P_CD_ITEN_PO_NUMERO             IN VND.ITEM_CONTRATO.CD_ITEN_PO_NUMERO%TYPE,
        -- Bloqueio
        P_CD_BLOQUEIO_FATURAMENTO_ITEM  IN VND.ITEM_CONTRATO.CD_BLOQUEIO_FATURAMENTO_ITEM%TYPE  --VBAP-FAKSP
    )
    IS
    BEGIN
    
        UPDATE VND.ITEM_CONTRATO
           SET CD_PRODUTO_SAP = DECODE(P_CD_PRODUTO_SAP, ' ', NULL, P_CD_PRODUTO_SAP),
               NO_PRODUTO = DECODE(P_NO_PRODUTO, ' ', NULL, P_NO_PRODUTO),
               NU_QUANTIDADE = P_NU_QUANTIDADE,
               CD_CULTURA_SAP = DECODE(P_CD_CULTURA_SAP, ' ', NULL, P_CD_CULTURA_SAP),
               CD_SACARIA = DECODE(P_CD_SACARIA, ' ', NULL, P_CD_SACARIA),
               CD_CENTRO_EXPEDIDOR = DECODE(P_CD_CENTRO_EXPEDIDOR, ' ', NULL, P_CD_CENTRO_EXPEDIDOR),
               PC_COMISSAO = P_PC_COMISSAO,
               VL_PRECO_NEGOCIADO = P_VL_PRECO_NEGOCIADO,
               NU_QTY_DELIVERED = TO_NUMBER(P_NU_QTY_DELIVERED),
               DH_ULT_INTERFACE = SYSDATE,
               CD_MOTIVO_RECUSA = DECODE(P_CD_MOTIVO_RECUSA, ' ', NULL, P_CD_MOTIVO_RECUSA),
               IC_RECUSADO = DECODE(P_CD_MOTIVO_RECUSA, ' ', 'N', 'S'),
               DT_PAGO = DECODE(P_DT_PAGO, '00/00/0000', NULL, TO_DATE(P_DT_PAGO, 'DD/MM/YYYY')),
               NU_CONTRATO_SUBSTITUI = DECODE(P_NU_CONTRATO_SUBSTITUI, ' ', NULL, P_NU_CONTRATO_SUBSTITUI),
               CD_ITEN_PO_NUMERO = P_CD_ITEN_PO_NUMERO,
               -- Bloqueio
               CD_BLOQUEIO_FATURAMENTO_ITEM = DECODE(P_CD_BLOQUEIO_FATURAMENTO_ITEM, ' ', NULL, P_CD_BLOQUEIO_FATURAMENTO_ITEM)
         WHERE CD_CONTRATO = P_CD_CONTRATO
           AND CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
        ;
    
    END PU_ITEM_CONTRATO;
    
    
    
    PROCEDURE PD_SOLICITACAO_NOVO_PRODUTO(
        P_CD_CONTRATO                   IN VND.SOLICITACAO_NOVO_PRODUTO.CD_CONTRATO%TYPE,
        P_CD_ITEM_CONTRATO              IN VND.SOLICITACAO_NOVO_PRODUTO.CD_ITEM_CONTRATO%TYPE
    )
    IS
    BEGIN
    
        DELETE FROM VND.SOLICITACAO_NOVO_PRODUTO
         WHERE CD_CONTRATO = P_CD_CONTRATO
           AND CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
        ;
    
    END PD_SOLICITACAO_NOVO_PRODUTO;
    
    
    
    PROCEDURE PD_CADENCIA(
        P_CD_CONTRATO                   IN VND.CADENCIA.CD_CONTRATO%TYPE,
        P_CD_ITEM_CONTRATO              IN VND.CADENCIA.CD_ITEM_CONTRATO%TYPE
    )
    IS
    BEGIN
    
        DELETE FROM VND.CADENCIA
         WHERE CD_CONTRATO = P_CD_CONTRATO
           AND CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
        ;
    
    END PD_CADENCIA;
    
    
    
    PROCEDURE PD_ITEM_CONTRATO(
        P_CD_CONTRATO                   IN VND.ITEM_CONTRATO.CD_CONTRATO%TYPE,
        P_CD_ITEM_CONTRATO              IN VND.ITEM_CONTRATO.CD_ITEM_CONTRATO%TYPE
    )
    IS
    BEGIN
    
        DELETE FROM VND.ITEM_CONTRATO
         WHERE CD_CONTRATO = P_CD_CONTRATO
           AND CD_ITEM_CONTRATO = P_CD_ITEM_CONTRATO
        ;
    
    END PD_ITEM_CONTRATO;
    
    
    
    PROCEDURE PU_INATIVA_CONTRATO(
        P_CD_CONTRATO                   IN VND.CONTRATO.CD_CONTRATO%TYPE
    )
    IS
    BEGIN
    
        UPDATE VND.CONTRATO
           SET CD_STATUS_CONTRATO = 9,
               IC_ATIVO           = 'N',
               DH_ULT_INTERFACE   = SYSDATE
        WHERE CD_CONTRATO = P_CD_CONTRATO
        ;
    
    END PU_INATIVA_CONTRATO;
    
    
    
    
    PROCEDURE PU_ENTREGA(
        P_IC_FORNECIDO                  IN CPT.ENTREGA.IC_FORNECIDO%TYPE,
        P_NU_PROTOCOLO_ENTREGA          IN CPT.ENTREGA.NU_PROTOCOLO_ENTREGA%TYPE
    )
    IS
    BEGIN
        FOR i IN 1..5 LOOP  -- try 5 times
            BEGIN
                SAVEPOINT start_transaction;  -- mark a savepoint
                UPDATE CPT.ENTREGA
                   SET IC_FORNECIDO = P_IC_FORNECIDO
                 WHERE NU_PROTOCOLO_ENTREGA = P_NU_PROTOCOLO_ENTREGA
                 ;
                COMMIT;
                EXIT;
            EXCEPTION
               WHEN OTHERS THEN ROLLBACK TO start_transaction;  -- undo changes
            END;
        END LOOP; -- i
    END PU_ENTREGA;
    
    
    
    
    
END GX_ZSDR3077_PEDIDOS;
/