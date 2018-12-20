/* Timer utility */

CREATE OR REPLACE PACKAGE sf_timer
IS
   PROCEDURE start_timer;

   PROCEDURE show_elapsed_time (message_in IN VARCHAR2 := NULL);
END sf_timer;
/

CREATE OR REPLACE PACKAGE BODY sf_timer
IS
   /* Package variable which stores the last timing made */
   last_timing   NUMBER := NULL;

   PROCEDURE start_timer
   IS
   BEGIN
      last_timing := DBMS_UTILITY.get_cpu_time;
   END;

   PROCEDURE show_elapsed_time (message_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            '"'
         || message_in
         || '" completed in: '
         || (DBMS_UTILITY.get_cpu_time - last_timing) / 100
         || ' seconds');

      start_timer;
   END;
END sf_timer;
/

CREATE TABLE parts
(
   partnum    NUMBER,
   partname   VARCHAR2 (15)
)
/

CREATE TABLE parts2
(
   partnum    NUMBER,
   partname   VARCHAR2 (15)
)
/

DROP TYPE parts_ot FORCE
/

CREATE OR REPLACE TYPE parts_ot IS OBJECT
(
   partnum NUMBER,
   partname VARCHAR2 (15)
)
/

CREATE OR REPLACE TYPE partstab IS TABLE OF parts_ot;
/

DECLARE
   PROCEDURE compare_inserting (num IN INTEGER)
   IS
      TYPE numtab IS TABLE OF parts.partnum%TYPE;

      TYPE nametab IS TABLE OF parts.partname%TYPE;

      TYPE parts_t IS TABLE OF parts%ROWTYPE
         INDEX BY PLS_INTEGER;

      parts_tab   parts_t;

      pnums       numtab := numtab ();
      pnames      nametab := nametab ();
      parts_nt    partstab := partstab ();
   BEGIN
      pnums.EXTEND (num);
      pnames.EXTEND (num);
      parts_nt.EXTEND (num);

      FOR indx IN 1 .. num
      LOOP
         pnums (indx) := indx;
         pnames (indx) := 'Part ' || TO_CHAR (indx);
         parts_nt (indx) := parts_ot (NULL, NULL);
         parts_nt (indx).partnum := indx;
         parts_nt (indx).partname := pnames (indx);
      END LOOP;

      sf_timer.start_timer;

      FOR indx IN 1 .. num
      LOOP
         INSERT INTO parts
              VALUES (pnums (indx), pnames (indx));
      END LOOP;

      sf_timer.show_elapsed_time (
         'FOR loop (row by row)' || num);

      ROLLBACK;

      sf_timer.start_timer;

      FORALL indx IN 1 .. num
         INSERT INTO parts
              VALUES (pnums (indx), pnames (indx));

      sf_timer.show_elapsed_time ('FORALL (bulk)' || num);

      ROLLBACK;

      sf_timer.start_timer;

      INSERT INTO parts
         SELECT * FROM TABLE (parts_nt);

      sf_timer.show_elapsed_time (
         'Insert Select from nested table ' || num);

      ROLLBACK;

      sf_timer.start_timer;

      INSERT /*+ APPEND */
            INTO  parts
         SELECT * FROM TABLE (parts_nt);

      sf_timer.show_elapsed_time (
         'Insert Select WITH DIRECT PATH ' || num);

      ROLLBACK;

      EXECUTE IMMEDIATE 'TRUNCATE TABLE parts';

      /* Load up the table. */
      FOR indx IN 1 .. num
      LOOP
         INSERT INTO parts
              VALUES (indx, 'Part ' || TO_CHAR (indx));
      END LOOP;

      COMMIT;

      DBMS_SESSION.free_unused_user_memory;

      sf_timer.start_timer;

      INSERT INTO parts2
         SELECT * FROM parts;

      sf_timer.show_elapsed_time ('Insert Select 100% SQL');

      EXECUTE IMMEDIATE 'TRUNCATE TABLE parts2';

      DBMS_SESSION.free_unused_user_memory;

      sf_timer.start_timer;

      SELECT *
        BULK COLLECT INTO parts_tab
        FROM parts;

      FORALL indx IN parts_tab.FIRST .. parts_tab.LAST
         INSERT INTO parts2
              VALUES parts_tab (indx);

      sf_timer.show_elapsed_time ('BULK COLLECT - FORALL');
   END;
BEGIN
   compare_inserting (100000);
END;
/

DROP TABLE parts
/

DROP TABLE parts2
/

DROP PACKAGE sf_timer
/