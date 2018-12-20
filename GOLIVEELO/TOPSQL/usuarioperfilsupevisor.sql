
select pe.*
, pa.cd_perfil 
, aca.ds_menu, aca.*
from ctf.perfil pe 
inner join ctf.perfil_acao pa
on 
pe.cd_perfil = pa.cd_perfil 
inner join ctf.acao aca 
on
pa.cd_acao = aca.cd_acao
where lower(aca.ds_menu) like '%com cópia%'
;


select * from ctf.acao where cd_acao in
(
863,
869,
875,
888,
867,
886,
864,
876,
861,
868,
871,
872


);

select upe.*,  us.*
from CTF.USUARIO_PERFIL upe
inner join ctf.usuario us
on upe.cd_usuario = us.cd_usuario
where upe.cd_sistema = 30 and upe.cd_perfil in ( 183)
and us.ic_ativo = 'S' AND us.IC_BLOQUEADO = 'N'
AND us.cd_usuario_original is not null
order by 
us.cd_usuario_original , upe.CD_PERFIL

;




