CREATE OR REPLACE PACKAGE BODY VND.GX_ELO_CONTROLLERSHIP1 AS

--GET
  PROCEDURE PX_CONTROLLERSHIP_INFO(
      P_CONTROLLERSHIP_INFO OUT T_CURSOR )
      
  AS
  BEGIN
    OPEN P_CONTROLLERSHIP_INFO FOR
        select cr.CD_ELO_CONTROLLERSHIP_REASON  as CodeMotivo, 
               cr.DS_CONTROLLERSHIP_REASON      as Motivo,
               dp.CD_DEPARTAMENTO               as CodeDepartamento,
               dp.DS_DEPARTAMENTO               as Departamento
          from VND.ELO_CONTROLLERSHIP_REASON cr
         inner join CTF.DEPARTAMENTO dp
            on cr.CD_DEPARTAMENTO = dp.CD_DEPARTAMENTO
      order by cr.DS_CONTROLLERSHIP_REASON;
    
  END PX_CONTROLLERSHIP_INFO;

--INSERT
 PROCEDURE PI_INS_CONTROLLERSHIP_PROFILE(
      p_DS_CONTROLLERSHIP_REASON IN VND.ELO_CONTROLLERSHIP_REASON.DS_CONTROLLERSHIP_REASON%TYPE,
      p_CD_DEPARTAMENTO IN VND.ELO_CONTROLLERSHIP_REASON.CD_DEPARTAMENTO%TYPE) AS
 
  P_CD_ELO_CONTROLLERSHIP_REASON	 NUMBER :=0; 
  
  BEGIN

    SELECT NVL(MAX(CD_ELO_CONTROLLERSHIP_REASON),0) + 1
      INTO P_CD_ELO_CONTROLLERSHIP_REASON
	  FROM VND.ELO_CONTROLLERSHIP_REASON;      
            
    INSERT INTO VND.ELO_CONTROLLERSHIP_REASON(CD_ELO_CONTROLLERSHIP_REASON, 
                                              DS_CONTROLLERSHIP_REASON,
                                              CD_DEPARTAMENTO) 
         VALUES(P_CD_ELO_CONTROLLERSHIP_REASON,
                p_DS_CONTROLLERSHIP_REASON,
                p_CD_DEPARTAMENTO);
        
  END PI_INS_CONTROLLERSHIP_PROFILE;

--DELETE
PROCEDURE PD_DEL_CONTROLLERSHIP_PROFILE(p_CD_DEPARTAMENTO IN VND.ELO_CONTROLLERSHIP_REASON.CD_ELO_CONTROLLERSHIP_REASON%TYPE) IS
  BEGIN
  DELETE FROM VND.ELO_CONTROLLERSHIP_REASON PP WHERE  PP.CD_ELO_CONTROLLERSHIP_REASON = p_CD_DEPARTAMENTO;
  END PD_DEL_CONTROLLERSHIP_PROFILE;
  
  --SELECT DEPARATAMENTO
    PROCEDURE PX_CONTROLLERSHIP_SELECT(P_CONTROLLERSHIP_SELECT OUT T_CURSOR)
      
    AS

    BEGIN
      OPEN P_CONTROLLERSHIP_SELECT FOR
        SELECT dp.CD_DEPARTAMENTO   as "value",
               dp.DS_DEPARTAMENTO   as text
          FROM CTF.DEPARTAMENTO dp
      ORDER BY dp.DS_DEPARTAMENTO;
          
    END PX_CONTROLLERSHIP_SELECT;
 
 --UPDATE
 PROCEDURE PU_UPD_CONTROLLERSHIP_PROFILE( p_CD_ELO_CONTROLLERSHIP_REASON IN VND.ELO_CONTROLLERSHIP_REASON.CD_ELO_CONTROLLERSHIP_REASON%TYPE,
       p_DS_CONTROLLERSHIP_REASON IN VND.ELO_CONTROLLERSHIP_REASON.DS_CONTROLLERSHIP_REASON%TYPE
      ,p_CD_DEPARTAMENTO IN VND.ELO_CONTROLLERSHIP_REASON.CD_DEPARTAMENTO%TYPE) AS
       BEGIN
      UPDATE VND.ELO_CONTROLLERSHIP_REASON  
      SET DS_CONTROLLERSHIP_REASON =p_DS_CONTROLLERSHIP_REASON,
      CD_DEPARTAMENTO= p_CD_DEPARTAMENTO 
      WHERE CD_ELO_CONTROLLERSHIP_REASON=p_CD_ELO_CONTROLLERSHIP_REASON ;
      COMMIT;
      END PU_UPD_CONTROLLERSHIP_PROFILE;
      
 
 
END GX_ELO_CONTROLLERSHIP1;
/