PROCEDURE V_MUMAIN
******************
CLOSE ALL
CLEAR ALL
SET HELP OFF
SET EXCLU OFF
SET TALK OFF
CLEAR

PUBLIC SISVER
SISVER="5.3"   && DE:MAYO 2021

SET RESOURCE TO VENTAS
SET COLOR SET TO VENTAS
SET PATH TO ..\DBF; ..\FRT ;\POS

PUBLIC USER, MACHINE, SUSER

WINUSER=v_getuin("U")
MACHINE=v_getuin("M")

DO LOGIN
WAIT "BIENVENIDO "+ALLTRIM(SUSER) WINDOW TIMEOUT 1
USER=SUSER
*USER=WINUSER

*DEFINE EMPRESA y MI_EMPRESA
DO V_GETEMP

DO WHILE .T.
  CLEAR 
  CLOSE DATA
  SET COLOR SET TO VENTAS
  SET HELP OFF
  SET PRINT OFF
  SET DEVICE TO SCREEN
  SET BLINK OFF
  SET CLOCK ON
  SET CONFIRM ON
  SET EXCLU OFF
  SET DATE TO FRENCH
  SET DELE ON
  SET TALK OFF
  SET SAFETY OFF
  SET ESCAPE OFF
  SET EXACT OFF
  SET CENTURY ON
* SET SYSMENU OFF
  MU=1
  ON KEY LABEL CTRL+D DO FECHA
  ON KEY LABEL CTRL+I DO V_INFO.SPR
  ON KEY LABEL CTRL+U DO V_MUSERS.SPR

  DO V_MUMAIN.SPR

  IF NOT VALIDA()
    RETURN
  ENDIF  
  
  ON KEY LABEL CTRL+D 
  ON KEY LABEL CTRL+U 
  ON KEY LABEL CTRL+X CANCEL
  DO CASE
    CASE MU=1
      DO V_MUDOCS.SPR
    CASE MU=2
      DO REPVENTA
    CASE MU=3
      DO REPALMAC
    CASE MU=4
      DO PROCESOS
    CASE MU=5
      DO DATOS with 1
    CASE MU=6
      DO DATOS with 2
  ENDCASE
  IF MU=7
    ON KEY LABEL CTRL+X 
    EXIT
  ENDIF
ENDDO
CLOSE DATA
SET HELP ON
CLEAR
RETURN

PROCEDURE FECHA
***************
SAVE SCREEN TO XO
! CLS
! DATE
RESTORE SCREEN FROM XO
RETURN

FUNCTION VALIDA
***************
SELECT 0
USE V_EMPR

KEYNUM0= SOUNDEX(ALLTRIM(SUBSTR(EM_DESCR,1,10)))+SOUNDEX(ALLTRIM(SUBSTR(EM_DESCR,11,10)))+SOUNDEX(ALLTRIM(SUBSTR(EM_DESCR,21,10)))

IF EM_KEY <> KEYNUM0
  WAIT "NOMBRE DE EMPRESA NO AUTORIZADO ... SALIENDO." TIMEOUT 2
  RETURN .F.
  use
ENDIF

USE
RETURN .T.  