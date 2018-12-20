			SELECT u.CD_LOGIN, u.no_usuario, c.*
				FROM VND.PROPOSTA_CREDITO c
				inner join ctf.usuario u on c.cd_usuario_recomendacao = u.cd_usuario
			 WHERE 1=1
                   -- and CD_CLIENTE = '0004070362'
				 AND CD_STATUS_PROPOSTA_CREDITO IN ('4')
				 and dh_ult_interface > current_date - 30 and dh_ult_interface < current_date - 1
			 ORDER BY cd_cliente DESC;
			 
			 select * from vnd.status_proposta_credito;
			 
			 
--edit VND.PROPOSTA_CREDITO
--where cd_proposta_credito = 12906;			 