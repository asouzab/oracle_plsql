select * from ctf.cliente
where cd_cliente = '0004075225';


--58682473968
--58682473968

--0745384400196
--0745384400196

select * from cpt.propriedade_cooperado where NU_RG_INSCRICAO like '%604987060066%';

select * from cpt.cooperado where cd_cooperado = 35507 or cd_cooperativa = 216;

select * from cpt.cooperativa_filial where cd_cliente = '0004060012'
and cd_cooperativa_filial = 730
;

select * from cpt.cooperativa where cd_cooperativa = 216;

select * from cpt.autorizacao_entrega where cd_propriedade = 40734;

select * from cpt.entrega where cd_autorizacao_entrega in (
    select cd_autorizacao_entrega from cpt.autorizacao_entrega where cd_propriedade = 40734
);

select * from contrato where nu_contrato = 3074541;


select *from cliente_contrato where cd_cliente_contrato = 512389;

select * from ctf.municipio where cd_municipio = 530010;

select * from ctf.estado where cd_estado = 53;



			SELECT DISTINCT DECODE(CL.CD_CLIENTE,NULL,2,1) CD_TIPO_PROPRIEDADE,
                            CO.NO_COOPERATIVA,
                            C.NO_COOPERADO,
                            PC.CD_PROPRIEDADE,
                            PC.NO_PROPRIEDADE,
                            PC.NU_CPF_CNPJ,
                            PC.NU_RG_INSCRICAO,
                            cl.cd_cliente
				FROM CPT.COOPERATIVA           CO,
						 CPT.COOPERADO             C,
						 CPT.AUTORIZACAO_ENTREGA   AE,
						 CPT.ENTREGA               E,
						 CPT.PROPRIEDADE_COOPERADO PC,
						 CTF.CLIENTE               CL
			   WHERE PC.CD_COOPERADO = C.CD_COOPERADO
				 AND CO.CD_COOPERATIVA = C.CD_COOPERATIVA
				 AND PC.CD_PROPRIEDADE = AE.CD_PROPRIEDADE
				 AND E.IC_LIBERADO_ENTREGA = 'S'
				 AND AE.CD_AUTORIZACAO_ENTREGA = E.CD_AUTORIZACAO_ENTREGA
				 AND (E.SG_STATUS = 'L' OR E.SG_STATUS = 'D')
				 AND PC.CD_CLIENTE IS NULL
				 AND AE.CD_PROPRIEDADE IS NOT NULL
				 AND PC.NU_CPF_CNPJ = TRIM(CL.NU_CPF_CNPJ(+))
				 AND PC.NU_RG_INSCRICAO = TRIM(CL.NU_RG_INSCRICAO_ESTADUAL(+))
				 
				 and pc.cd_propriedade = 40734
				 
			 ORDER BY 1,
								2,
								3;
								
								
--edit cpt.propriedade_cooperado where NU_RG_INSCRICAO like '%745384400196%';



				SELECT DISTINCT CO.NO_COOPERATIVA,
												CF.NO_COOPERATIVA_FILIAL,
												C.NO_COOPERADO,
												PC.NU_CPF_CNPJ,
												PC.NU_RG_INSCRICAO,
												PC.NO_PROPRIEDADE,
												PC.DS_ENDERECO,
												PC.CD_PROPRIEDADE,
												AE.CD_AUTORIZACAO_ENTREGA,
												EN.CD_ENTREGA,
												EN.SG_STATUS,
												EN.NU_PROTOCOLO_ENTREGA,
	                      CO.NU_CONTRATO,
	                      AE.CD_ITEM_CONTRATO,
												M.CD_MUNICIPIO,
												M.NO_MUNICIPIO,
												E.CD_ESTADO,
												E.NO_ESTADO
					FROM CPT.COOPERATIVA           CO,
							 CPT.COOPERADO             C,
							 CPT.AUTORIZACAO_ENTREGA   AE,
							 CPT.ENTREGA               EN,
							 CPT.PROPRIEDADE_COOPERADO PC,
               VND.CONTRATO              CO,
               VND.ITEM_CONTRATO         IC,
							 CTF.MUNICIPIO             M,
							 CTF.ESTADO                E,
							 CPT.COOPERATIVA_FILIAL    CF
				 WHERE AE.CD_AUTORIZACAO_ENTREGA = EN.CD_AUTORIZACAO_ENTREGA
					 AND PC.CD_COOPERADO = C.CD_COOPERADO
           AND CO.NU_CONTRATO = AE.NU_CONTRATO
           AND CO.CD_CONTRATO = IC.CD_CONTRATO
           AND IC.CD_ITEM_CONTRATO = AE.CD_ITEM_CONTRATO
           AND IC.IC_RECUSADO = 'N'
					 AND PC.CD_MUNICIPIO = M.CD_MUNICIPIO
					 AND M.CD_ESTADO = E.CD_ESTADO
					 AND CO.CD_COOPERATIVA = C.CD_COOPERATIVA
					 AND PC.CD_PROPRIEDADE = AE.CD_PROPRIEDADE
					 AND AE.CD_PROPRIEDADE IS NOT NULL
					 AND EN.IC_LIBERADO_ENTREGA = 'S'
					 AND (EN.SG_STATUS = 'L' OR EN.SG_STATUS = 'D')
					 AND PC.CD_CLIENTE IS NULL
					 AND AE.CD_COOPERATIVA_FILIAL = CF.CD_COOPERATIVA_FILIAL
					 AND PC.CD_PROPRIEDADE = 40734
					 ;


			SELECT CL.CD_CLIENTE,
						 CL.NO_CLIENTE,
						 CL.NU_CPF_CNPJ,
						 CL.NU_RG_INSCRICAO_ESTADUAL,
						 TRIM(LPAD(CL.NO_CLIENTE, 20)) NO_CLIENTE_CURTO,
						 CL.DS_ENDERECO,
						 M.NO_MUNICIPIO,
						 E.NO_ESTADO
				FROM CTF.CLIENTE   CL,
						 CTF.MUNICIPIO M,
						 CTF.ESTADO    E
			 WHERE (CL.NU_CPF_CNPJ = '45236791015970')
				 AND CL.NU_RG_INSCRICAO_ESTADUAL = '7022021815677'
				 AND CL.CD_MUNICIPIO = M.CD_MUNICIPIO(+)
				 AND M.CD_ESTADO = E.CD_ESTADO(+)
				 AND CL.IC_ATIVO = 'S'
				 ;



select x.cd_propriedade, x.nu_cpf_cnpj, x.* 
from cpt.propriedade_cooperado x 
where  instr(nu_cpf_cnpj, ' ') > 0 or length(nu_cpf_cnpj) > 14
union
select x.cd_propriedade, x.nu_cpf_cnpj, x.* 
from cpt.propriedade_cooperado x 
where  length(nu_cpf_cnpj) > 11 and length(nu_cpf_cnpj) < 14

;



select * from vnd.contrato cont
inner join vnd.tipo_ordem tord
on cont.cd_tipo_contrato = tord.cd_tipo_ordem
and cont.CD_SALES_ORG = tord.CD_SALES_ORG
and cont.CD_DISTRIBUTION_CHANNEL = tord.CD_DISTRIBUTION_CHANNEL
and cont.CD_SALES_DIVISION = tord.CD_SALES_DIVISION

inner join VND.CLIENTE_CONTRATO ccli
on cont.cd_cliente_contrato = ccli.cd_cliente_contrato
left join  cpt.cooperativa_filial copfil
on copfil.cd_cliente = ccli.cd_cliente
where copfil.cd_cliente is null
and cont.cd_status_contrato = 8
and (tord.ic_cooperative = 'S' OR ( NVL(tord.ic_cooperative, 'X') = 'S' )  )
 
and cont.cd_situacao_contrato in (20)
and cont.ic_ativo = 'S'
and cont.dt_fim > CURRENT_DATE - 180
and exists (select 1 from vnd.item_contrato ic
where ic.cd_contrato = cont.cd_contrato
and (ic.NU_QUANTIDADE - ic.NU_QTY_DELIVERED) > 0 
)

;
