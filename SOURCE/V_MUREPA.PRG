PROCEDURE V_MUREPA
******************
IF .NOT. V_USRAUT(USER,"REPS_ALM",1)  
  RETURN
ENDIF


OPCION=1
SET DATE FRENCH
SET CENTURY ON
DO WHILE .T.
  DO V_MUREPA.SPR
  DO CASE
    CASE OPCION=1
      DO KARDEX
    CASE OPCION=2
      DO V_GSALDO
    CASE OPCION=3
      DO V_BALANC
    CASE OPCION=4
      DO V_REP_IN
    CASE OPCION=5
      DO V_NR_KG
    CASE OPCION=6
      DO V_NEXNR
  ENDCASE
  IF OPCION=7
    EXIT
  ENDIF
ENDDO
RETURN

