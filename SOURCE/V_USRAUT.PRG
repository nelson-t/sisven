FUNCTION V_USRAUT
*****************
PARAMETER NOM, FUN, NAUT

SELECT 0
USE V_USERS
LOCATE FOR UPPER(U_NOMBRE)=UPPER(NOM)
IF EOF()
  USE
  RETURN .F.
ELSE
  IF EVALUATE(FUN)>=NAUT
    USE
    RETURN .T.
  ELSE
    USE
    WAIT "NO TIENE NIVEL DE ACCESO REQUERIDO!" WINDOW TIMEOUT 2
    RETURN .F.
  ENDIF
ENDIF