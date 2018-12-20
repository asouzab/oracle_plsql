select * from ctf.acao
where upper(ds_acao) like '%SCHEDULING/REPORTVOLUME.ASPX%';

select * from ctf.usuario where UPPER(no_usuario) like '%ADRIANO%';

select * from ctf.usuario_perfil;


select pers.* from ctf.perfil pers 
inner join ctf.perfil_acao peracao
on pers.cd_sistema = peracao.cd_sistema
and pers.cd_perfil = peracao.cd_perfil
inner join ctf.usuario_perfil usuper
on usuper.cd_sistema = pers.cd_sistema
and usuper.cd_perfil = pers.cd_perfil
inner join  ctf.acao aca
on aca.cd_sistema = peracao.cd_sistema
and aca.cd_acao = peracao.cd_acao
inner join ctf.usuario usu
on  usu.cd_usuario = usuper.cd_usuario

where 1=1 
--and upper(aca.ds_acao) like '%SCHEDULING/REPORTVOLUME.ASPX%'
and upper(ds_email) = 'MARCIO.SILVA@MOSAICCO.COM'
--and  no_perfil =  'Comercial'

;


INSERT INTO ctf.perfil_acao
(CD_PERFIL, CD_SISTEMA, CD_ACAO)
VALUES 
(
192, 31, 937);

SELECT * FROM 

301010749

119181264

update ctf.usuario
set ds_senha = '119181264'
where 
cd_usuario = 4198;


grant execute on GX_ELO_CONTROLLERSHIP1 to vnd, vnd_sec;


