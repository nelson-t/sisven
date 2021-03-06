SET TALK OFF
SET DELE ON
SET DATE TO DMY
SET EXCLU OFF
SET CONFIRM OFF
SET AUTOSAVE ON
SET NOTIFY OFF
SET REPROCESS TO 5 SECONDS
EMPR='1'

DELETE FILE 'A:DOC_HD.DBF'
DELETE FILE 'A:DOC_LN.DBF'
DELETE FILE 'A:CLIENT.DBF'
DELETE FILE 'TEMP.DBF'

CLOSE DATA
DEFINE WINDOW WINSEND FROM 5, 4 TO 21,36 NONE COLOR G+/B
DEFINE WINDOW WINREC  FROM 5,43 TO 21,75 NONE COLOR G+/B

CLEAR

****** GENERACION DE NOTAS DE NOTAS DE REMISION ********

ACTIVATE WINDOW WINSEND

SELECT 1
USE V_DOC_HD ORDER MIGRA
SET FILTER TO HD_TIPO='R' .AND. HD_ALM='01'    && DOC.INV./ING.PROD./COMPRA LOCAL/IMPORT/TRASPASOS ALM 01
GO TOP
NR_ARCH='A:DOC_HD.DBF'
COPY REST WHILE .NOT. EOF() .AND. HD_MIGRA=' ' TO (NR_ARCH)

SELECT 2
USE V_DOC_LN ORDER CORRE
COPY STRUCT TO A:DOC_LN.DBF

SELECT 3
USE A:DOC_LN.DBF ALIAS DOC_LN

SELECT V_DOC_HD
SEEK ' '


DO WHILE .NOT. EOF() .AND. HD_MIGRA=' '
  IF LOCK()
    SELECT V_DOC_LN
    SEEK V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO
    SELECT DOC_LN
    APPEND FROM V_DOC_LN FOR;
      LD_EMPR+LD_ALM+LD_TIPO+LD_NRO=V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO ;
    
    SELECT V_DOC_HD
    REPLACE HD_MIGRA WITH 'M'
    DO CASE
        CASE HD_TIPO='R'
          ? 'NR.:'+HD_NRO
    ENDCASE
    SEEK ' '
  ELSE
    SKIP
  ENDIF
ENDDO
? 
CLOSE DATA

SELECT 1
USE V_CLIENT ORDER MIGRA
COPY STRUCT TO A:CLIENT.DBF

SELECT 3
USE A:CLIENT.DBF ALIAS CLIENT

SELECT V_CLIENT
SEEK ' '
DO WHILE !EOF() .AND. CL_MIGRA=' '
	IF LOCK()
		COPY NEXT 1 TO TEMP
		SELECT CLIENT	
		APPEND FROM TEMP
		DELETE FILE 'TEMP.DBF'
		SELECT V_CLIENT
		REPLACE CL_MIGRA WITH 'M'
		? ' CLIENTE:'+CL_COD_CL
		SEEK ' '
	ELSE
		SKIP
	ENDIF
ENDDO
?
CLOSE DATA

RELEASE WINDOW WINSEND, WINREC
CLEAR PROGRAM
CLEAR
CLOSE DATA
SET VIEW OFF
