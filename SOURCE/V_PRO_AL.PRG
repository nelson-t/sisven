PROCEDURE V_PRO_AL
******************
SELECT V_TC
SEEK DTOS(DATE())
IF EOF()
  MENSAJE1='!!! TIPO DE CAMBIO DEL DIA, NO HA SIDO ACTUALIZADO !!!' 
  MENSAJE2='ACTUALIZE EL TIPO DE CAMBIO ANTES DE INTENTAR DE NUEVO'
  DO V_MENSAJ.SPR
  RETURN
ENDIF

ACTIVATE SCREEN
CLEAR

ON KEY LABEL F10 KEYBOARD CHR(23)
tcambio=0
q_pend=0
OKCANCEL=1
TIPO_DES='P'
END_MENU=.F.

SELECT V_PRO_HD
SET RELATION OFF INTO V_EMPR
SET RELATION OFF INTO V_CLIENT
SET RELATION OFF INTO V_VENDOR 

P_CABEZA=SYS(3)

COPY STRUCTURE TO (P_CABEZA)

SELECT 5 && E   && Cabecera temporal
USE (P_CABEZA) EXCLUSIVE        &&ALIAS CABEZA EXCLUSIVE
SET RELATION TO HP_EMPR INTO V_EMPR
SET RELATION TO HP_EMPR+HP_COD_CL  INTO V_CLIENT ADDITIVE
SET RELATION TO HP_EMPR+HP_COD_VEN INTO V_VENDOR ADDITIVE

P_LINEAS=SYS(3)

SELECT V_PRO_LN
SET RELATION OFF INTO V_ITEMS
COPY STRUCTURE TO (P_LINEAS)

SELECT 6 && F
USE (P_LINEAS) EXCLUSIVE &&ALIAS LINEAS EXCLUSIVE
SET RELATION TO LP_EMPR+LP_PART INTO V_ITEMS

TOT_CANT=0
TOT_PESO=0

SELECT E  && Cabecera temporal
APPEND BLANK
REPLACE HP_EMPR   WITH EMPRESA
REPLACE HP_FECHA  WITH DATE()

HIDE MENU M_PEDIDO
ACTIVATE SCREEN
CLEAR
@ 13,25 TO 17,55 
@ 14,27 SAY 'DIGITE LOS DATOS POR FAVOR'
@ 16,27 SAY '     [ESC] PARA SALIR     '
@ 19,0 TO 24,79 DOUBLE
@ 19, 5 SAY 'SALDOS DEL ITEM'
@ 19,60 SAY 'TOTALES'
@ 22,55 SAY 'DSCTO Bs.='+TRANSFORM(0,'9,999,999.99') 
@ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(0,'9,999,999.99') 
ACTIVATE WINDOW PED_HD
CLEAR
DO V_PRO_A.SPR

IF LASTKEY()<>27 .AND. OKCANCEL=1
  SELECT E  && Cabecera temporal
  DO V_PRO_V.SPR
  ACTIVATE SCREEN
  SELECT F   && lineas temporal
  FOR N=1 TO 11
    APPEND BLANK
    REPLACE LP_EMPR   WITH E.HP_EMPR
    REPLACE LP_FECHA  WITH E.HP_FECHA
    REPLACE LP_COD_CL WITH E.HP_COD_CL
    REPLACE LP_ESTADO WITH E.HP_ESTADO
  ENDFOR

  DEFINE WINDOW ped_AL  FROM 9, 0 TO 18,79 TITLE "D E T A L L E" ;
   NOFLOAT DOUBLE 
******** PARA CALCULO DE SALDOS ************
  SELECT 0
  USE V_ALM ORDER ALM
  T_ALM=SYS(3)
  COPY TO (T_ALM) WITH CDX FIELDS AL_EMPR,AL_ALM,AL_DESCR,AL_CANT,AL_PESO,AL_PENDIEN FOR AL_EMPR=EMPRESA
  USE (T_ALM) ORDER ALM ALIAS ALMACEN EXCLU

  SELECT 0
  USE V_DOC_LN ORDER KARDEX
  SET RELATION TO LD_EMPR+LD_ALM INTO ALMACEN
************************************************
  SELECT F  && Lineas temporal
  GO TOP
  REG_ACT=0
  COD_ACT=SPACE(15)
  BROWSE NOCLEAR FIELDS LP_PART:H='CODIGO':P='@S8 !!!!!!!!!!!!!!!':V=CHK_PART(LP_PART) ;
   .AND. GET_PRECIO(EMPRESA,LP_PART):E='CODIGO YA EXISTE':W=GET_TOT('W'), ;
   DESCR=V_ITEMS.IT_DESCR:W=.F., V_ITEMS.IT_UNIDAD:H='UNI.':W=.F., ;
   LP_CANT:H='CANTIDAD':V=GET_TOT('V'):W=GET_TOT('W') .AND. ;
   LP_PART<>SPACE(15):P='9999999.99':F, ;
   LP_PRECIO:H='PRECIO U.':P='999999.9999':V=GET_TOT('V'):W=GET_TOT('W') ;
   .AND. LP_PART<>SPACE(15), ;
   IMPORTE=ROUND(LP_PRECIO*LP_CANT,2):P='999,999.99':W=.F. ;
   WINDOW PED_AL TITLE '[F10] - TERMINA DETALLE   [ESC] - DESCARTA PEDIDO' 
  
  SELECT V_DOC_LN
  USE

  SELECT ALMACEN
  USE

  DELETE FILE (T_ALM+'.DBF')
  DELETE FILE (T_ALM+'.CDX')

  SELECT F   && lineas temporal
  
  IF LASTKEY()<>27

    GO TOP
    IMPORTE=0
    DO WHILE .NOT. EOF() 
      IF LP_CANT=0 .OR. LP_PART=SPACE(15)
        DELETE
      ELSE
        IMPORTE=IMPORTE+ROUND(LP_CANT*LP_PRECIO,2)
      ENDIF
      SKIP
    ENDDO
    
    SELECT E  && Cabecera temporal
    REPLACE HP_IMPORTE WITH IMPORTE

    ACTIVATE SCREEN

    @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM(ROUND(HP_IMPORTE*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
    @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(HP_IMPORTE-ROUND(HP_IMPORTE*E.HP_DSCTO_P/100,2),'9,999,999.99') 

    OPCION=1
    DO V_PRO_MU.SPR

    DO CASE
      CASE OPCION=1
        * ALMACENA PROFORMA
        SELECT E  && Cabecera temporal
        REPLACE HP_NRO WITH V_NEXT_N(EMPRESA,'PRO')
        REPLACE HP_USUARIO WITH SYS(0)
        SELECT F    && lineas temporal
        GO TOP
        DO WHILE .NOT. EOF() 
          REPLACE LP_NRO WITH E.HP_NRO
          SKIP
        ENDDO

        SELECT 5
        USE
        SELECT 6
        USE
  
        SELECT V_PRO_HD
        APPEND FROM (P_CABEZA)

        SELECT V_PRO_LN
        APPEND FROM (P_LINEAS)
        GO TOP
        END_MENU=.T.

      CASE OPCION=2
        * PRIMERO SE ALMACENA PROFORMA
        SELECT E  && Cabecera temporal
        REPLACE HP_NRO WITH V_NEXT_N(EMPRESA,'PRO')
        REPLACE HP_USUARIO WITH SYS(0)
        SELECT F    && lineas temporal
        GO TOP
        DO WHILE .NOT. EOF() 
          REPLACE LP_NRO WITH E.HP_NRO
          SKIP
        ENDDO

        SELECT 5
        USE
        SELECT 6
        USE
  
        SELECT V_PRO_HD
        APPEND FROM (P_CABEZA)

        SELECT V_PRO_LN
        APPEND FROM (P_LINEAS)
        GO TOP

        * ALMACENA PEDIDO  

        SELECT E  && Cabecera temporal
        USE (P_CANBEZA)
        REPLACE HP_NRO WITH V_NEXT_N(EMPRESA,'PED')
        REPLACE HP_USUARIO WITH SYS(0)
        
        SELECT F    && lineas temporal
        USE (P_LINEAS)
        
        GO TOP
        DO WHILE .NOT. EOF() 
          REPLACE LP_PEND WITH LP_CANT        
          REPLACE LP_NRO WITH E.HP_NRO
          SKIP
        ENDDO

        SELECT 5
        USE
        SELECT 6
        USE
  
        SELECT V_PED_HD
        APPEND FROM (P_CABEZA)

        SELECT V_PED_LN
        APPEND FROM (P_LINEAS)
        GO TOP
        END_MENU=.T.


      CASE OPCION=3
*       ANULA NUMERO DE PEDIDO      
        END_MENU=.F.
    ENDCASE
  ENDIF
ENDIF

SELECT 5
USE
SELECT 6
USE

SELECT V_PRO_HD
SET RELATION TO HP_EMPR INTO V_EMPR
SET RELATION TO HP_EMPR+HP_COD_CL  INTO V_CLIENT ADDITIVE
SET RELATION TO HP_EMPR+HP_COD_VEN INTO V_VENDOR ADDITIVE

SELECT V_PRO_LN
SET RELATION TO LP_EMPR+LP_PART INTO V_ITEMS

FLUSH

DELETE FILE (P_CABEZA+'.DBF')
DELETE FILE (P_LINEAS+'.DBF')

DO ON_KEYS
DO PE_VER
IF LASTKEY()<>27 .AND. END_MENU
  DO V_PRO_OP
ENDIF
RETURN

FUNCTION CHK_PART
*****************
PARAMETER PART
SELECT V_ITEMS
SEEK EMPRESA+PART
IF FOUND() .OR. PART=SPACE(15)
  SELECT F    && Lineas temporal
  IF PART<>SPACE(15)
    REG_NUM=RECNO()
    REPLACE LP_PART WITH 'XXXXXXXXXXXXXXX'
    LOCATE FOR LP_PART=PART
    IF FOUND()
      GO REG_NUM
      REPLACE LP_PART WITH SPACE(15)
      RETURN .F.
    ELSE
      GO REG_NUM
      REPLACE LP_PART WITH PART
      REPLACE lp_sus_kg WITH v_items.it_sus_kg
      REPLACE lp_peso_t WITH v_items.it_peso_t
      REPLACE lp_pre_sus WITH v_items.it_precio
    ENDIF
  ENDIF
  RETURN .T.
ELSE
  *-  DEFINIR UN POPUP DE CLIENTES -*
  ACTIVATE POPUP GETITEM
  SEEK EMPRESA+SUBSTR(PROMPT(),1,15)
  PART=IT_PART
  SELECT F   && Lineas temporal
  REPLACE LP_PART WITH PART
  RETURN .T.
ENDIF    


FUNCTION GET_PRECIO
*-----------------*
PARAMETER MI_EMPR,MI_PART

DESCTO_IT=0
SELECT V_DESCTO
SEEK EMPRESA+F.LP_PART
DO WHILE .NOT. EOF() .AND. DE_EMPR+DE_PART=EMPRESA+F.LP_PART
    IF BETWEEN(E.HP_FECHA,DE_FECHAI,DE_FECHAF)
      IF V_CLIENT.CL_CATEGO$DE_CATEGO .OR. DE_CATEGO=SPACE(25)
        DESCTO_IT=DE_DESCTO/100
      ENDIF
      EXIT  
    ENDIF
    SKIP
ENDDO   
SELECT V_TC
SEEK DTOS(E.HP_FECHA)
TCAMBIO=TC_MONTO   
IF .NOT. EOF()
  SELECT F   && Lineas temporal
  REPLACE LP_LISTA   WITH ROUND((V_ITEMS.IT_PRECIO-(V_ITEMS.IT_PRECIO*DESCTO_IT))*TCAMBIO,4)
  REPLACE LP_PRECIO  WITH ROUND((V_ITEMS.IT_PRECIO-(V_ITEMS.IT_PRECIO*DESCTO_IT))*TCAMBIO,4)
  RETURN .T.
ELSE
  SELECT F  && Lineas temporal
  RETURN .F.
ENDIF
  
FUNCTION CHK_CLIENT
*******************
PARAMETER CODIGO
SELECT V_CLIENT
SEEK EMPRESA+CODIGO
IF FOUND()
  @ 3,22 SAY CL_RAZON
  SELECT E  && Cabecera temporal
  RETURN .T.
ELSE
  *-  DEFINIR UN POPUP DE CLIENTES -*
  SELECT V_CLIENT
  SET ORDER TO RAZON
  ACTIVATE POPUP GETCLIEN
  SET ORDER TO CODIGO
  SEEK EMPRESA+SUBSTR(PROMPT(),32,6)
  CODIGO=CL_COD_CL
  SELECT E  && Cabecera temporal
  REPLACE HP_COD_CL WITH CODIGO
  @ 3,22 SAY V_CLIENT.CL_RAZON
  RETURN .T.
ENDIF    

FUNCTION CHK_AREA
*****************
PARAMETER CODIGO

SELECT V_AREAS

IF (LEN(ALLTRIM(CODIGO)) = 0)
	ACTIVATE POPUP GETAREA
  	CODIGO = SUBSTR(PROMPT(),1,1)
  	SELECT E  && Cabecera temporal
  	REPLACE HP_AREA WITH CODIGO
	RESULT = .T.	
ELSE
	IF (LEN(ALLTRIM(CODIGO)) <> 0)
		SEEK CODIGO
		IF FOUND()
  			SELECT E  && Cabecera temporal
  			RESULT = .T.
		ELSE
  			ACTIVATE POPUP GETAREA
  			CODIGO = SUBSTR(PROMPT(),1,1)
  			SELECT E  && Cabecera temporal
  			REPLACE HP_AREA WITH CODIGO
  			RESULT = .T.
		ENDIF    
	ENDIF
ENDIF

IF (LEN(ALLTRIM(HP_AREA)) = 0)
	RESULT = .F.	
ENDIF

RETURN RESULT


FUNCTION CHK_VENDOR
*******************
PARAMETER CODIGO
SELECT V_VENDOR
SEEK EMPRESA+CODIGO
IF FOUND()
  @ 2,17 SAY VE_NOMBRE
  SELECT E  && Cabecera temporal
  RETURN .T.
ELSE
  @ 2,17 SAY 'CODIGO DE VENDEDOR ERRADO'
  SELECT E    && Cabecera temporal
  RETURN .F.  
ENDIF    

FUNCTION GET_TOT
****************
PARAMETER DEDONDE

MI_COD=LP_PART
MI_REC=RECNO()
q_pend=0
CALCULA=.F.

IF LP_PART=SPACE(15)
  CLEAR
  SUM LP_CANT,ROUND(LP_CANT*LP_PRECIO,2) TO TOT_CANT,TOT_IMPORT
  GO MI_REC
  @ 20,65 SAY (lp_precio)/tcambio*.87/v_items.it_peso_t PICTURE "999.9999"    
  @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
  @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2),'9,999,999.99') 
  @ 19,0 TO 24,79 DOUBLE COLOR G+/B
  @ 19, 5 SAY 'SALDOS DEL ITEM'
  @ 19,60 SAY 'TOTALES'
  REG_ACT=0
  COD_ACT=SPACE(15)
  RETURN .T.
ENDIF

IF DEDONDE='V'   && Si el item es el mismo no calcula
  SUM LP_CANT,ROUND(LP_CANT*LP_PRECIO,2) TO TOT_CANT,TOT_IMPORT
  GO MI_REC
  @ 20,65 SAY (lp_precio)/tcambio*.87/v_items.it_peso_t PICTURE "999.9999"  
  @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
  @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2),'9,999,999.99') 
ELSE   && Si item es diferente calcula
  IF MI_REC<>REG_ACT .OR. MI_COD<>COD_ACT
    CALCULA=.T.
    REG_ACT=MI_REC
    COD_ACT=MI_COD
  ENDIF  

  IF CALCULA
    SUM LP_CANT,ROUND(LP_CANT*LP_PRECIO,2) TO TOT_CANT,TOT_IMPORT
    GO MI_REC
    CLEAR
    @ 19,0 TO 24,79 DOUBLE COLOR G+/B
    @ 19, 5 SAY 'SALDOS DEL ITEM'
    @ 19,60 SAY 'TOTALES'
    @ 22,14 SAY 'CALCULANDO SALDO DEL PRODUCTO ...' COLOR R/GR*
    PARTE=LP_PART

    SELECT ALMACEN
    REPLACE almacen.AL_CANT WITH 0 ALL
    REPLACE almacen.AL_PESO WITH 0 ALL
    REPLACE almacen.al_pendient WITH 0 ALL

* Calculo de Saldos del Item
    SELECT V_DOC_LN
    ld_cant=0
    ld_peso=0
    SEEK EMPRESA+PARTE
    DO WHILE .NOT. EOF() .AND. LD_EMPR=EMPRESA .AND. LD_PART=PARTE
      DO CASE
        CASE LD_INSAL='1'
           REPLACE ALMACEN.AL_CANT WITH ALMACEN.AL_CANT+LD_CANT
           REPLACE ALMACEN.AL_PESO WITH ALMACEN.AL_PESO+LD_PESO
        CASE LD_INSAL='2'
           REPLACE ALMACEN.AL_CANT WITH ALMACEN.AL_CANT-LD_CANT
           REPLACE ALMACEN.AL_PESO WITH ALMACEN.AL_PESO-LD_PESO
      ENDCASE 
      SKIP
    ENDDO
    
    * Calculo de pendientes
    anterior=ALIAS()
    SELECT 0
    use v_ped_ln
    SUM lp_pend FOR lp_part=parte .AND. lp_estado<>'D' TO q_pend
    SELECT ALMACEN
    REPLACE almacen.al_pendien WITH q_pend
    SELECT V_PED_LN
    USE
    SELECT (anterior)
    * Fin de calculo de pendientes
    SELECT almacen
    GO TOP
    SEEK EMPRESA
    CLEAR
    @ 19,0
    ? ' [ALMACEN] [  S A L D O  ]   [PEND.]    [D I S P.]'
    DO WHILE .NOT. EOF() .AND. AL_EMPR=EMPRESA
      IF AL_CANT>0
        SET COLOR TO G+/B
      ENDIF
      ? '    '+AL_ALM+'  '+TRANSFORM(AL_CANT,'99,999,999.99')+' '+V_ITEMS.IT_UNIDAD+;
      ' '+TRANS(al_pendien,'999,999.99')+' '+TRANSFORM(AL_CANT-AL_PENDIEN,'99,999,999.99')
      SET COLOR TO
      SKIP
    ENDDO
    SELECT F   && Lineas temporal
    @ 20,65 SAY (lp_precio)/tcambio*.87/v_items.it_peso_t PICTURE "999.9999"    
    @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
    @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2),'9,999,999.99') 
    @ 19,0 TO 24,79 DOUBLE COLOR G+/B
    @ 19, 5 SAY 'SALDOS DEL ITEM'
    @ 20,55 SAY '$us./Kg.:'
    @ 19,60 SAY 'TOTALES'
    SELECT F   && Lineas temporal
  ENDIF
ENDIF

RETURN .T.


FUNCTION GET_DSCTO
*******************
SELECT V_CATEGO
SEEK EMPRESA+V_CLIENT.CL_CATEGO
IF FOUND()
  SELECT E    && Cabecera temporal
  REPLACE HP_DSCTO_P WITH V_CATEGO.CA_DSCTO 
ENDIF
SELECT E  && Cabecera temporal
RETURN .T.
