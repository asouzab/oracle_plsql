DECLARE
    -- Declarations
    var_P_CD_POLO               CHAR (4);
    var_P_CD_CENTRO_EXPEDIDOR   CHAR (4);
    var_P_CD_MACHINE            CHAR (4);
    var_P_CD_WEEK               VARCHAR2 (10);
    var_P_CD_SALES_DISTRICT     CHAR (6);
    var_P_CD_SALES_OFFICE       CHAR (4);
    var_P_CD_SALES_GROUP        CHAR (3);
    var_P_RETORNO               SYS_REFCURSOR;
    
    CURSOR C_AGEND IS

    SELECT AGE.CD_ELO_AGENDAMENTO , AGE.CD_POLO, AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_MACHINE, AGE.CD_WEEK
    FROM VND.ELO_AGENDAMENTO AGE
    WHERE 
    AGE.CD_ELO_STATUS In(6)
    AND AGE.IC_ATIVO = 'S'
    ORDER BY 
    AGE.CD_CENTRO_EXPEDIDOR, AGE.CD_POLO 
    ;
    
    TYPE agend_r IS RECORD
    (
        CD_ELO_AGENDAMENTO      VND.ELO_AGENDAMENTO.CD_ELO_AGENDAMENTO%TYPE,
        CD_POLO                 VND.ELO_AGENDAMENTO.CD_POLO%TYPE,
        CD_CENTRO_EXPEDIDOR     VND.ELO_AGENDAMENTO.CD_CENTRO_EXPEDIDOR%TYPE,
        CD_MACHINE              VND.ELO_AGENDAMENTO.CD_MACHINE%TYPE, 
        CD_WEEK              VND.ELO_AGENDAMENTO.CD_WEEK%TYPE
        

    );

    TYPE agend_t IS TABLE OF agend_r;
    tof_agend agend_t;    
        
    
    
BEGIN
    -- Initialization
    var_P_CD_POLO := NULL;
    var_P_CD_CENTRO_EXPEDIDOR := NULL;
    var_P_CD_MACHINE := NULL;
    var_P_CD_WEEK := NULL;
    var_P_CD_SALES_DISTRICT := NULL;
    var_P_CD_SALES_OFFICE := NULL;
    var_P_CD_SALES_GROUP := NULL;
    
    
        
    OPEN C_AGEND;
    FETCH C_AGEND BULK COLLECT INTO tof_agend LIMIT 10000;
    CLOSE C_AGEND;  


        FOR C_LINHA IN 1 .. tof_agend.COUNT
        LOOP


    -- Call
    VND.GX_CELL_ATTENDANCE.PU_CELL_ATTENDANCE_UPDATE (
        P_CD_POLO               => tof_agend(C_LINHA).cd_polo,
        P_CD_CENTRO_EXPEDIDOR   => tof_agend(C_LINHA).CD_CENTRO_EXPEDIDOR,
        P_CD_MACHINE            => tof_agend(C_LINHA).CD_MACHINE,
        P_CD_WEEK               => tof_agend(C_LINHA).CD_WEEK,
        P_CD_SALES_DISTRICT     => var_P_CD_SALES_DISTRICT,
        P_CD_SALES_OFFICE       => var_P_CD_SALES_OFFICE,
        P_CD_SALES_GROUP        => var_P_CD_SALES_GROUP,
        P_RETORNO               => var_P_RETORNO);

    -- Transaction Control
    COMMIT;
    
    END LOOP;

    -- Output values, do not modify
    
END;