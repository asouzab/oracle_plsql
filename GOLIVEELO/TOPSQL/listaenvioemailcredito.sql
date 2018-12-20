
    SELECT CD_LOGIN, DS_EMAIL FROM CTF.USUARIO
--           INTO :T_USUARIO-LOGIN, :T_USUARIO-EMAIL
         WHERE CD_USUARIO IN (SELECT CD_USUARIO
                               FROM CTF.DEPARTAMENTO_MENSAGEM
                              WHERE CD_DEPARTAMENTO = 4
                                AND IC_LOGIN        = 'L'      ) ;
                                
                                
select * from ctf.usuario 
where 
upper(ds_email) in ('SANDRA.PRADA@MOSAICCO.COM.BR', 'KARLA.SERAFIM@MOSAICCO.COM.BR', 'HELLEN.SILVEIRA@MOSAICCO.COM',
'ERICK.SANTOS@MOSAICCO.COM', 'ALESSANDRA.CORREA@MOSAICCO.COM'
 );                                


select dm.*, uss.CD_LOGIN, uss.DS_EMAIL, uss.no_usuario from CTF.DEPARTAMENTO_MENSAGEM dm
inner join CTF.USUARIO uss
on
uss.cd_usuario = dm.cd_usuario;


update CTF.DEPARTAMENTO_MENSAGEM 
set cd_usuario = '4338' 
where cd_usuario_MENSAGEM = 4;


update CTF.DEPARTAMENTO_MENSAGEM 
set cd_usuario = '4339' 
where cd_usuario_MENSAGEM = 6;

update CTF.DEPARTAMENTO_MENSAGEM 
set cd_usuario = '4340' 
where cd_usuario_MENSAGEM = 8;


update CTF.DEPARTAMENTO_MENSAGEM 
set cd_usuario = '4341' 
where cd_usuario_MENSAGEM = 10;

update CTF.DEPARTAMENTO_MENSAGEM 
set IC_LOGIN = 'N'
where cd_usuario_MENSAGEM = 12;

update CTF.DEPARTAMENTO_MENSAGEM 
set cd_usuario = '4342' 
where cd_usuario_MENSAGEM = 11;