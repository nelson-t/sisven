* ASIGNA PESOS A LA FACTURAS 
* ASUME EL PESO DE LA N.R.


CLOSE ALL
CLEAR ALL

SELECT 1
USE V_DOC_LN ORDER NR &&EMPRESA+TIPO+NRO+PART

SELECT 2
USE V_FAC_DO ORDER FACTURA

SELECT 3
USE V_FAC_LN ORDER CORRE
SET RELATION TO LF_EMPR+LF_NRO INTO V_FAC_DO
SET RELATION TO LF_EMPR+V_FAC_DO.FA_DOC_TIP+V_FAC_DO.FA_DOC_NRO+LF_PART INTO V_DOC_LN ADDITIVE

SELECT 3
GO TOP
DO WHILE .NOT. EOF()
  IF  V_DOC_LN.LD_PART<>SPACE(15)
    IF LOCK()
      REPLACE LF_PESO WITH V_DOC_LN.LD_PESO
    ENDIF
  ENDIF
  SKIP
ENDDO

CLOSE ALL
CLEAR ALL