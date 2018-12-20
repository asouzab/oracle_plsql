    SELECT PE.NU_ORDEM_VENDA,
           PE.CD_ITEM_PEDIDO,
           PE.NU_QUANTIDADE,
           PE.NU_QUANTIDADE_ENTREGUE,
           PE.NU_QUANTIDADE_SALDO,
           DECODE(TO_CHAR(PE.DH_EMISSAO,'DD/MM/YYYY'), '31/12/9999', NULL, TO_CHAR(PE.DH_EMISSAO,'DD/MM/YYYY')) DH_EMISSAO,
           DECODE(TO_CHAR(PE.DH_ENTREGA,'DD/MM/YYYY'), '31/12/9999', NULL, TO_CHAR(PE.DH_ENTREGA,'DD/MM/YYYY')) DH_ENTREGA,
           PE.CD_CENTRO_EXPEDIDOR,
           PE.CD_SACARIA,
           CE.DS_CENTRO_EXPEDIDOR,
           SA.DS_SACARIA
      FROM VND.PEDIDO           PE,
           CTF.CENTRO_EXPEDIDOR CE,
           VND.SACARIA          SA
     WHERE PE.CD_CENTRO_EXPEDIDOR = CE.CD_CENTRO_EXPEDIDOR(+)
       AND PE.CD_SACARIA = SA.CD_SACARIA(+)
       --AND PE.CD_SITUACAO_PEDIDO <> 90
       AND TRIM(PE.NU_CONTRATO_SAP) = TRIM('0040383951')
       AND PE.CD_ITEM_CONTRATO = 10;
       
       
       select C.NU_CONTRATO_SAP, Ic.* from vnd.contrato C 
       inner join VND.ITEM_CONTRATO IC 
       ON C.CD_CONTRATO = IC.CD_CONTRATO 
       where 
       C.IC_ATIVO = 'S'
       --AND C.DT_FIM IS NULL
       --AND c.CD_USUARIO_VENDA = 19
       and c.nu_contrato_sap is not null
       AND C.CD_CONTRATO = 1597
       --AND TRIM(NU_CONTRATO_SAP) = TRIM('0040383951')
       AND CD_MOTIVO_RECUSA IS NOT NULL
       
       
        TRIM(NU_CONTRATO_SAP) = TRIM('0040383951')
        
        select * from vnd.item_contrato
        where 212405 = cd_contrato 
        
        select * from ctf.usuario
        where  NO_USUARIO LIKE 'Fernando Dessoy'
        
        740 = cd_usuario_original 740
        cd_usuario = 19
        cd_login = 'FDESSOY'
        
        update ITEM_CONTRATO
        set cd_motivo_recusa = '9G',
        IC_RECUSADO = 'S'
        where 
        cd_item_contrato = 10 
        and cd_produto_sap = '000000000000107114'
        and cd_contrato = 1597
        
        
        
