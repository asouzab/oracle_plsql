select sap.NU_CARTEIRA_VERSION , 
CASE WHEN (SELECT COUNT(1) 
            FROM VND.ELO_CARTEIRA_SAP_IMPORT TEMPARCIAL 
            WHERE TEMPARCIAL.NU_CARTEIRA_VERSION = sap.NU_CARTEIRA_VERSION) >= 1 THEN 1
ELSE 0 END TEMPARCIAL ,
count(1), min(sap.dh_carteira)

from vnd.elo_carteira_sap sap
left join vnd.elo_carteira_sap_import impor
on sap.nu_carteira_version = impor.nu_carteira_version 
and sap.nu_contrato_sap = impor.nu_contrato_sap
and sap.cd_item_contrato = impor.cd_item_contrato
and sap.cd_produto_sap = impor.cd_produto_sap 
and NVL(sap.NU_ORDEM_VENDA, '0') = NVL(impor.NU_ORDEM_VENDA,'0')

WHERE 1=1
--AND NU_CARTEIRA_VERSION = '20180405060009'
and sap.dh_carteira > current_date - 300  
and impor.nu_carteira_version is null 
GROUP BY sap.nu_carteira_version