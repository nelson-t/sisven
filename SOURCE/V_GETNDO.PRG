FUNCTION V_GETNDO
*****************
* GET DOSIF NRO

*** PARA DOSIFICACIONES ****
SELECT 0
USE V_DOSIFI ORDER NRO
SET FILTER TO EMPR=EMPRESA AND ACTIVA
GO BOTT
IF EOF()
  USE
  WAIT "NO SE ENCONTRO DOSIFICACION DE FACTURAS ACTIVA !" WINDOW TIMEOUT 4
  RETURN 0
ELSE
  IF .NOT. BETWEEN(DATE(),DE_FECHA, A_FECHA)
    USE
    WAIT "NO SE ENCONTRO DOSIFICACION DE FACTURAS VIGENTE !" WINDOW TIMEOUT 4
    RETURN 0
  ENDIF
  N=V_DOSIFI.NRO
  USE
  RETURN N
ENDIF

***FIN  
  
 