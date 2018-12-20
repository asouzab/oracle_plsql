CREATE OR REPLACE PACKAGE VND."GX_ELO_SERVICE" AS 

 TYPE T_CURSOR IS REF CURSOR;

    /********************************************************************* 
    Supervisor with mail details

    AUTHOR: Santosh Hargunani

    P_RETORNO – Supervisor with mail details
    /*********************************************************************/
PROCEDURE PX_SUPERVISORMAIL_DATA (P_RESULT OUT T_CURSOR);

PROCEDURE PI_EMAIL (
                    P_DS_EMAIL_TO       IN CTF.EMAIL_SERVICE.DS_EMAIL_TO%TYPE,
                    P_DS_EMAIL_FROM     IN CTF.EMAIL_SERVICE.DS_EMAIL_FROM%TYPE,
                    P_DS_EMAIL_CC       IN CTF.EMAIL_SERVICE.DS_EMAIL_CC%TYPE,
                    P_DS_EMAIL_BCC      IN CTF.EMAIL_SERVICE.DS_EMAIL_BCC%TYPE,
                    P_DS_SUBJECT        IN CTF.EMAIL_SERVICE.DS_SUBJECT%TYPE,
                    P_DS_BODY           IN CTF.EMAIL_SERVICE.DS_BODY%TYPE
                    ); 
END GX_ELO_SERVICE;


/