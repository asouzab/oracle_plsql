
CREATE TABLE VND.ELO_AGENDAMENTO_WEEK_FROZZEN
(
  ID NUMBER(9)             NOT NULL,  
  BATCH_ID VARCHAR2(10)    NOT NULL,
  CD_ELO_STATUS_FROZZEN    NUMBER(9),
  CD_ELO_AGENDAMENTO_WEEK  NUMBER(9)            NOT NULL,
  CD_ELO_AGENDAMENTO_ITEM  NUMBER(9)            NOT NULL,
  NU_SEMANA                NUMBER(2)            NOT NULL,
  QT_COTA                  NUMBER(15,3),
  QT_SEMANA                NUMBER(15,3),
  QT_EMERGENCIAL           NUMBER(15,3),
  DH_ULT_ALTERACAO         DATE DEFAULT CURRENT_DATE 
)
TABLESPACE WEB_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING;



CREATE UNIQUE INDEX VND.ELO_AGENDAMENTO_WEEK_FRU01 ON VND.ELO_AGENDAMENTO_WEEK_FROZZEN
(ID)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

ALTER TABLE VND.ELO_AGENDAMENTO_WEEK_FROZZEN ADD (
  CONSTRAINT "ELO_AGENDAMENTO_WEEK_FRU01"
  PRIMARY KEY
  (ID)
  USING INDEX VND."ELO_AGENDAMENTO_WEEK_FRU01"
  ENABLE VALIDATE
);

CREATE INDEX VND.IX_ELO_AGENDA_WEEK_FR_ST_DH ON VND.ELO_AGENDAMENTO_WEEK_FROZZEN
(CD_ELO_STATUS_FROZZEN, DH_ULT_ALTERACAO)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );



GRANT ALTER, DELETE, INDEX, INSERT, SELECT, UPDATE ON VND.ELO_AGENDAMENTO_WEEK_FROZZEN TO CTF;

GRANT DELETE, INSERT, SELECT, UPDATE ON VND.ELO_AGENDAMENTO_WEEK_FROZZEN TO VND_SEC;


CREATE TABLE VND.ELO_AGENDAMENTO_DAY_FROZZEN
(
  ID NUMBER(9)             NOT NULL,  
  BATCH_ID VARCHAR2(10)    NOT NULL,
  CD_ELO_STATUS_FROZZEN    NUMBER(9),
  CD_ELO_AGENDAMENTO_DAY   NUMBER(9)            NOT NULL,
  CD_ELO_AGENDAMENTO_WEEK  NUMBER(9)            NOT NULL,
  NU_DIA_SEMANA            NUMBER(3)            NOT NULL,
  CD_GRUPO_EMBALAGEM       CHAR(1 BYTE)         NOT NULL,
  NU_QUANTIDADE            NUMBER(15,3)         NOT NULL, 
  DH_ULT_ALTERACAO         DATE DEFAULT CURRENT_DATE  
)
TABLESPACE WEB_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING;



CREATE UNIQUE INDEX VND.ELO_AGENDAMENTO_DAY_FRU01 ON VND.ELO_AGENDAMENTO_DAY_FROZZEN
(ID)
LOGGING
TABLESPACE WEB_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

ALTER TABLE VND.ELO_AGENDAMENTO_DAY_FROZZEN ADD (
  CONSTRAINT "ELO_AGENDAMENTO_DAY_FRU01"
  PRIMARY KEY
  (ID)
  USING INDEX VND."ELO_AGENDAMENTO_DAY_FRU01"
  ENABLE VALIDATE
);

GRANT ALTER, DELETE, INDEX, INSERT, SELECT, UPDATE ON VND.ELO_AGENDAMENTO_DAY_FROZZEN TO CTF;

GRANT DELETE, INSERT, SELECT, UPDATE ON VND.ELO_AGENDAMENTO_DAY_FROZZEN TO VND_SEC;



CREATE SEQUENCE VND.SEQ_ELO_AGENDAMENTO_DAY_FROZ
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
  
CREATE SEQUENCE VND.SEQ_ELO_AGENDAMENTO_WEEK_FROZ
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
  
  
CREATE OR REPLACE TRIGGER VND.TI_DAY_FROZZEN 
BEFORE INSERT ON VND.ELO_AGENDAMENTO_DAY_FROZZEN 
REFERENCING NEW AS new FOR EACH ROW
DECLARE



BEGIN

    IF :new.ID IS NULL   THEN 
        :new.ID:= VND.SEQ_ELO_AGENDAMENTO_DAY_FROZ.NEXTVAL;
    END IF;

END;  


  
CREATE OR REPLACE TRIGGER VND.TI_WEEK_FROZZEN 
BEFORE INSERT ON VND.ELO_AGENDAMENTO_WEEK_FROZZEN 
REFERENCING NEW AS new FOR EACH ROW
DECLARE



BEGIN

    IF :new.ID IS NULL   THEN 
        :new.ID:= VND.SEQ_ELO_AGENDAMENTO_WEEK_FROZ.NEXTVAL;
    END IF;

END;  
  


DECLARE
  user_name varchar2(128);
BEGIN
  select user into user_name from dual;
  execute immediate 'alter session set current_schema = VND';
  BEGIN
    SYS.DBMS_JOB.REMOVE(64);
    execute immediate 'alter session set current_schema = ' || user_name ;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name ;
      RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  X NUMBER;
  user_name varchar2(128);
BEGIN
  select user into user_name from dual;
  execute immediate 'alter session set current_schema = VND';
  BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X 
     ,what      => 'VND.GX_ELO_BATCH_ISSUE.PI_AGENDAMENTO_BATCH;'
     ,next_date => to_date('15/06/2018 00:00:00','dd/mm/yyyy hh24:mi:ss')
     ,interval  => 'TRUNC(SYSDATE+1)'
     ,no_parse  => FALSE
    );
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name ;
  EXCEPTION
    WHEN OTHERS THEN 
      execute immediate 'alter session set current_schema = ' || user_name ;
      RAISE;
  END;
  COMMIT;
END;
/
DECLARE
  user_name varchar2(128);
BEGIN
  select user into user_name from dual;
  execute immediate 'alter session set current_schema = VND';
  BEGIN
    SYS.DBMS_JOB.REMOVE(65);
    execute immediate 'alter session set current_schema = ' || user_name ;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name ;
      RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  X NUMBER;
  user_name varchar2(128);
BEGIN
  select user into user_name from dual;
  execute immediate 'alter session set current_schema = VND';
  BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X 
     ,what      => 'VND.GX_ELO_BATCH_ISSUE.PI_AGENDAMENTO_BATCH_MONTH;'
     ,next_date => to_date('01/07/2018 00:00:00','dd/mm/yyyy hh24:mi:ss')
     ,interval  => 'TRUNC(LAST_DAY(SYSDATE)) + 1'
     ,no_parse  => FALSE
    );
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name ;
  EXCEPTION
    WHEN OTHERS THEN 
      execute immediate 'alter session set current_schema = ' || user_name ;
      RAISE;
  END;
  COMMIT;
END;
/
DECLARE
  user_name varchar2(128);
BEGIN
  select user into user_name from dual;
  execute immediate 'alter session set current_schema = VND';
  BEGIN
    SYS.DBMS_JOB.REMOVE(66);
    execute immediate 'alter session set current_schema = ' || user_name ;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name ;
      RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  X NUMBER;
  user_name varchar2(128);
BEGIN
  select user into user_name from dual;
  execute immediate 'alter session set current_schema = VND';
  BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X 
     ,what      => 'VND.GX_ELO_BATCH_ISSUE.PI_AGENDAMENTO_WEEKDAY_FROZZEN;'
     ,next_date => to_date('15/06/2018 05:00:00','dd/mm/yyyy hh24:mi:ss')
     ,interval  => 'TRUNC(SYSDATE+1)+5/24'
     ,no_parse  => FALSE
    );
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name ;
  EXCEPTION
    WHEN OTHERS THEN 
      execute immediate 'alter session set current_schema = ' || user_name ;
      RAISE;
  END;
  COMMIT;
END;
/
  
GRANT EXECUTE ON VND.GX_ELO_BATCH_ISSUE TO VND, VND_SEC;  
  
  
  
  


SELECT TO_CHAR(CURRENT_DATE, 'YYMMDDHH') FROM DUAL;


SELECT * FROM ELO_AGENDAMENTO_WEEK_FROZZEN;

SELECT * FROM ELO_AGENDAMENTO_DAY_FROZZEN;


select * from vnd.elo_status;