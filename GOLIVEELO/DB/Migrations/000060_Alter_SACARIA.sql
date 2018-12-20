ALTER TABLE VND.SACARIA
 ADD (CD_GRUPO_EMBALAGEM  CHAR(1))
/

ALTER TABLE VND.SACARIA
 ADD CONSTRAINT SACARIA_R01 
  FOREIGN KEY (CD_GRUPO_EMBALAGEM) 
  REFERENCES VND.GRUPO_EMBALAGEM (CD_GRUPO_EMBALAGEM)
  ENABLE VALIDATE
/

update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '100';
update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '101';
update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '102';
update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '105';
update vnd.sacaria set cd_grupo_embalagem = 'B' where cd_sacaria = '108';
update vnd.sacaria set cd_grupo_embalagem = 'B' where cd_sacaria = '110';
update vnd.sacaria set cd_grupo_embalagem = 'B' where cd_sacaria = '111';
update vnd.sacaria set cd_grupo_embalagem = 'B' where cd_sacaria = '112';
update vnd.sacaria set cd_grupo_embalagem = 'B' where cd_sacaria = '114';
update vnd.sacaria set cd_grupo_embalagem = 'B' where cd_sacaria = '115';
update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '116';
update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '117';
update vnd.sacaria set cd_grupo_embalagem = 'S' where cd_sacaria = '118';
update vnd.sacaria set cd_grupo_embalagem = 'G' where cd_sacaria = '150';
update vnd.sacaria set cd_grupo_embalagem = 'G' where cd_sacaria = '151';