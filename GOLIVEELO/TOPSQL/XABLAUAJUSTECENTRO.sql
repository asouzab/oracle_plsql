DECLARE 

CURSOR C_CARTEIRA_SAP IS 
select 
ct.CD_ELO_CARTEIRA_SAP, 
ct.NU_CONTRATO_SAP, 
ct.CD_ITEM_CONTRATO, 
ct.NU_ORDEM_VENDA, 
ct.NU_CARTEIRA_VERSION, 
ct.cd_centro_expedidor, 
ct.ds_centro_expedidor, 
cc.DS_CENTRO_EXPEDIDOR CENTRO_FROM_BASE 
from vnd.elo_carteira_sap ct
inner join ctf.centro_expedidor cc
on ct.cd_centro_expedidor = cc.cd_centro_expedidor
where ct.ds_centro_expedidor <> cc.ds_centro_expedidor;

CURSOR C_CARTEIRA_ELO IS 
select 
ct.CD_ELO_CARTEIRA, 
ct.NU_CONTRATO_SAP, 
ct.CD_ITEM_CONTRATO, 
ct.NU_ORDEM_VENDA, 
'' NU_CARTEIRA_VERSION, 
ct.cd_centro_expedidor, 
ct.ds_centro_expedidor, 
cc.DS_CENTRO_EXPEDIDOR CENTRO_FROM_BASE 
from vnd.elo_carteira ct
inner join ctf.centro_expedidor cc
on ct.cd_centro_expedidor = cc.cd_centro_expedidor
where ct.ds_centro_expedidor <> cc.ds_centro_expedidor;

TYPE carteira_sap_r IS RECORD
(
CD_ELO_CARTEIRA_SAP     VND.elo_carteira_sap.CD_ELO_CARTEIRA_SAP%TYPE,
NU_CONTRATO_SAP         VND.elo_carteira_sap.NU_CONTRATO_SAP%TYPE,
CD_ITEM_CONTRATO        VND.elo_carteira_sap.CD_ITEM_CONTRATO%TYPE,
NU_ORDEM_VENDA          VND.elo_carteira_sap.NU_ORDEM_VENDA%TYPE, 
NU_CARTEIRA_VERSION     VND.elo_carteira_sap.NU_CARTEIRA_VERSION%TYPE,
cd_centro_expedidor     VND.elo_carteira_sap.cd_centro_expedidor%TYPE,
ds_centro_expedidor     VND.elo_carteira_sap.ds_centro_expedidor%TYPE,
CENTRO_FROM_BASE        VND.elo_carteira_sap.ds_centro_expedidor%TYPE

);


TYPE carteira_sap_t IS TABLE OF carteira_sap_r;
tableof_carteira_sap carteira_sap_t;

tableof_carteira_elo carteira_sap_t;

BEGIN

BEGIN 


    OPEN C_CARTEIRA_SAP;
    FETCH C_CARTEIRA_SAP BULK COLLECT INTO tableof_carteira_sap LIMIT 10000;
    CLOSE C_CARTEIRA_SAP;
        
    FORALL C_LINHA IN tableof_carteira_sap.first .. tableof_carteira_sap.last
    UPDATE VND.ELO_CARTEIRA_SAP SA
    SET SA.DS_CENTRO_EXPEDIDOR = tableof_carteira_sap(C_LINHA).CENTRO_FROM_BASE
    WHERE 
    SA.DS_CENTRO_EXPEDIDOR <> tableof_carteira_sap(C_LINHA).CENTRO_FROM_BASE 
    AND SA.CD_ELO_CARTEIRA_SAP =  tableof_carteira_sap(C_LINHA).CD_ELO_CARTEIRA_SAP;
    COMMIT;
        


END;

BEGIN 


    OPEN C_CARTEIRA_ELO;
    FETCH C_CARTEIRA_ELO BULK COLLECT INTO tableof_carteira_elo LIMIT 10000;
    CLOSE C_CARTEIRA_ELO;
        
    FORALL C_LINHA IN tableof_carteira_elo.first .. tableof_carteira_elo.last
    UPDATE VND.ELO_CARTEIRA SA
    SET SA.DS_CENTRO_EXPEDIDOR = tableof_carteira_elo(C_LINHA).CENTRO_FROM_BASE
    WHERE 
    SA.DS_CENTRO_EXPEDIDOR <> tableof_carteira_elo(C_LINHA).CENTRO_FROM_BASE 
    AND SA.CD_ELO_CARTEIRA =  tableof_carteira_elo(C_LINHA).CD_ELO_CARTEIRA_SAP;
    COMMIT;
        


END;

END;

/
select 
ct.CD_ELO_CARTEIRA, 
ct.NU_CONTRATO_SAP, 
ct.CD_ITEM_CONTRATO, 
ct.NU_ORDEM_VENDA, 
'' NU_CARTEIRA_VERSION, 
ct.cd_centro_expedidor, 
ct.ds_centro_expedidor, 
cc.DS_CENTRO_EXPEDIDOR CENTRO_FROM_BASE 
from vnd.elo_carteira ct
inner join ctf.centro_expedidor cc
on ct.cd_centro_expedidor = cc.cd_centro_expedidor
where ct.ds_centro_expedidor <> cc.ds_centro_expedidor;
