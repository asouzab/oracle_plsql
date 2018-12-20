SELECT distinct cp.cd_cooperativa,
       cp.no_cooperativa,
       at.cd_autorizacao_entrega,
       at.cd_pedido,
       ic.cd_item_contrato,
       at.nu_nota_fiscal,
       at.vl_valor_unitario,
       at.ic_desdobramento,
       at.cd_sacaria,
       at.ds_cadencia,
       TO_CHAR (at.dt_nota_fiscal, 'DD.MM.YYYY'),
       at.cd_pedido,
       DECODE (cl.cd_cliente, NULL, cl1.cd_cliente, cl.cd_cliente),
       DECODE (cl.no_cliente, NULL, cl1.no_cliente, cl.no_cliente),
       co.cd_cooperado,
       co.No_cooperado,
       at.cd_cooperativa_filial,
       cf.no_cooperativa_filial,
       at.cd_usuario,
       us.no_usuario,
       us.ds_email,
       us.nu_telefone,
       us.nu_prefixo,
       en.qt_quantidade,
       TO_CHAR (en.dt_sugestao_entrega, 'DD.MM.YYYY'),
       en.ds_roteiro,
       en.cd_entrega,
       en.NU_PROTOCOLO_ENTREGA,
       DECODE (en.ic_entrega_outra_filial, 'N', NULL, 'X'),
       en.DS_TRANSPORTADORA_CLIENTE,
       en.sg_status,
       en.ds_composicao_carga,
       at.NU_CONTRATO,
       at.nu_contrato_sap,                                      /* CHG97363 */
       DECODE (at.cd_cooperado, NULL, 'F', 'C')                 /* CHG97363 */
  FROM  cpt.autorizacao_entrega    at
  inner join cpt.entrega                en
  on 
  at.cd_autorizacao_entrega = en.cd_autorizacao_entrega  
  --and en.CD_ENTREGA > 0
  --and en.SG_STATUS = 'A'
  
  inner join vnd.contrato               ct
  on
  at.nu_contrato = ct.nu_contrato
  
  inner join vnd.item_contrato          ic 
  on
  ct.cd_contrato = ic.cd_contrato
  and at.cd_item_contrato = ic.cd_item_contrato  
  
  inner JOIN VND.PEDIDO PED
  ON 
  
  PED.nu_contrato_sap = ct.nu_contrato_sap
  AND PED.cd_item_contrato = ic.cd_item_contrato
  and ped.cd_produto_sap = ic.cd_produto_sap
  
 
  inner join ctf.usuario                us
  on
  at.cd_usuario = us.cd_usuario

  inner join cpt.cooperativa_filial     cf
  on 
  at.cd_cooperativa_filial = cf.cd_cooperativa_filial  
  
  inner join cpt.cooperativa            cp
  on
  cf.cd_cooperativa = cp.cd_cooperativa    

  left JOIN cpt.propriedade_cooperado  pc
  on 
  at.cd_propriedade = pc.cd_propriedade
  AND at.cd_cooperado = pc.cd_cooperado

  left join  cpt.cooperado              co
  on 
  at.cd_cooperado = co.cd_cooperado

  
   left join ctf.cliente                cl
   on 
   pc.cd_cliente = cl.cd_cliente
   left join ctf.cliente                cl1
   on 
   cf.cd_cliente = cl1.cd_cliente    
       
 WHERE     
        en.sg_status = 'A';