PROCEDURE V_PED_MO
******************
SELECT V_PED_HD
IF HP_ESTADO$'AD'
  MENSAJE1='!!!!  NO SE PUEDE MODIFICAR !!!!!' 
  MENSAJE2='EL PEDIDO HA SIDO DESPACHADO O ANULADO'
  DO V_MENSAJ.SPR
  RETURN
ENDIF

IF HP_OBS_COM=SPACE(10)
  WAIT "NO SE TIENE ASIGNADOS PRECIOS POR DEFECTO ... SELECCIONELO." WINDOW
  IF LASTKEY()=27
    RETURN
  ENDIF

  LISTA=1 &&PRECIO BASE
  DO V_PLISTA.SPR
   DO CASE
   CASE LISTA=1
     REPLACE HP_OBS_COM WITH "Base" 	
   CASE LISTA=2
     REPLACE HP_OBS_COM WITH "Lista 1" 	
   CASE LISTA=3
     REPLACE HP_OBS_COM WITH "Lista 2" 	
   CASE LISTA=4
     REPLACE HP_OBS_COM WITH "Lista 3" 	
   CASE LISTA=5
     REPLACE HP_OBS_COM WITH "Lista 4" 	
   CASE LISTA=6
     REPLACE HP_OBS_COM WITH "Lista 5" 	
   ENDCASE

ENDIF

ACTIVATE SCREEN
CLEAR

ON KEY LABEL F10 KEYBOARD CHR(23)
P_CABEZA=SYS(3)

TPRECIO=HP_OBS_COM

OKCANCEL=1
TIPO_DES='P'
END_MENU=.F.

SELECT V_PED_HD

COPY NEXT 1 TO (P_CABEZA)

SELECT E && P_CABEZA
USE (P_CABEZA) EXCLUSIVE        &&ALIAS CABEZA EXCLUSIVE
SET RELATION TO HP_EMPR INTO V_EMPR
SET RELATION TO HP_EMPR+HP_COD_CL  INTO V_CLIENT ADDITIVE
SET RELATION TO HP_EMPR+HP_COD_VEN INTO V_VENDOR ADDITIVE

P_LINEAS=SYS(3)

SELECT V_PED_LN

SEEK V_PED_HD.HP_EMPR+V_PED_HD.HP_NRO
IF .NOT. EOF()
  COPY REST WHILE V_PED_HD.HP_EMPR+V_PED_HD.HP_NRO=LP_EMPR+LP_NRO TO (P_LINEAS)
ELSE
  COPY STRUCT TO (P_LINEAS)
ENDIF
  
SELECT F && Lineas Pedido temporal
USE (P_LINEAS) EXCLUSIVE &&ALIAS LINEAS EXCLUSIVE
SET RELATION TO LP_EMPR+LP_PART INTO V_ITEMS

TOT_CANT=0
TOT_PESO=0

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

SELECT E && Cabecera Pedidos Temporal
DO V_PED_A2.SPR

IF LASTKEY()<>27 .AND. OKCANCEL=1
  SELECT E && Cabecera Pedidos Temporal
  DO V_PED_V.SPR
  ACTIVATE SCREEN
  SELECT F && Lineas Pedido temporal
  
  COUNT ALL TO TLINEAS
  
  FOR N=TLINEAS TO NROLINEAS-1
    
    APPEND BLANK
    REPLACE LP_EMPR    WITH E.HP_EMPR, ;
            LP_FECHA   WITH E.HP_FECHA, ;
            LP_COD_CL  WITH E.HP_COD_CL, ;
            LP_COD_VEN WITH E.HP_COD_VEN, ;
            LP_ESTADO  WITH E.HP_ESTADO
  ENDFOR
  
  DEFINE WINDOW ped_AL  FROM 9, 0 TO 18,79 ;
		TITLE "D E T A L L E" ;
		NOFLOAT ;
		DOUBLE 

******** PARA CALCULO DE SALDOS ************
  SELECT 0
  USE V_ALM ORDER ALM
  T_ALM=SYS(3)
  COPY TO (T_ALM) WITH CDX FIELDS AL_EMPR,AL_ALM,AL_DESCR,AL_CANT,AL_PESO FOR AL_EMPR=EMPRESA
  USE (T_ALM) ORDER ALM ALIAS ALMACEN EXCLU

  SELECT 0
  USE V_DOC_LN ORDER KARDEX
  SET RELATION TO LD_EMPR+LD_ALM INTO ALMACEN
************************************************
  SELECT F && Lineas Pedido temporal
  GO TOP
  REG_ACT=0
  BROWSE NOCLEAR FIELDS LP_PART:H='CODIGO':P='@S8 !!!!!!!!!!!!!!!':V=CHK_PART(LP_PART) .AND. GET_PRECIO(LP_PART):E='CODIGO YA EXISTE':W=GET_TOT('W'), ;
         DESCR=V_ITEMS.IT_DESCR:W=.F., ;
         V_ITEMS.IT_UNIDAD:H='UNI.':W=.F., ;
         LP_CANT:H='CANTIDAD':V=GET_TOT('V'):W=GET_TOT('W') .AND. LP_PART<>SPACE(15):P='9999999.99':F, ;
         LP_PRECIO:H='PRECIO U.':P='999999.99':V=GET_TOT('V'):W=GET_TOT('W') .AND. LP_PART<>SPACE(15), ;
         IMPORTE=ROUND(LP_PRECIO*LP_CANT,2):P='999,999.99':R ;
         WINDOW PED_AL  ;
         TITLE '[F10]-TERMINA [ESC]-DESCARTA [*]-FILTRO' 

  SELECT V_DOC_LN
  USE

  SELECT ALMACEN
  USE

  DELETE FILE (T_ALM+'.DBF')
  DELETE FILE (T_ALM+'.CDX')

  SELECT F && Lineas Pedido temporal
  
  IF LASTKEY()<>27

    GO TOP
    IMPORTE=0
    DO WHILE .NOT. EOF() 
      REPLACE LP_C_COTIZ WITH LP_CANT
      IF LP_CANT=0 .OR. LP_PART=SPACE(15)
        DELETE
      ELSE
        IMPORTE=IMPORTE+ROUND(LP_CANT*LP_PRECIO,2)
      ENDIF
      SKIP
    ENDDO
    
    SELECT E  && Cabecera Pedidos Temporal
    REPLACE HP_IMPORTE WITH IMPORTE

    ACTIVATE SCREEN

    @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(HP_IMPORTE*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
    @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(HP_IMPORTE-ROUND(HP_IMPORTE*E.HP_DSCTO_P/100,2),'9,999,999.99') 

	DO MOD_DATOS

    DO V_PED_V.SPR
    
    OPCION=1
    DO V_PED_MO.SPR

    DO CASE
      CASE OPCION=1
        * ALMACENA PEDIDO  
        SELECT E  && Cabecera Pedidos Temporal
        REPLACE HP_USUARIO WITH USER
        SELECT F && Lineas Pedido temporal
        GO TOP
        DO WHILE .NOT. EOF() 
          REPLACE LP_NRO WITH E.HP_NRO
          SKIP
        ENDDO

        SELECT F && Lineas Pedido temporal
        USE
        
        *BORRADO DE LINEAS ANTERIORES
        SELECT V_PED_LN
        SEEK V_PED_HD.HP_EMPR+V_PED_HD.HP_NRO
        DO WHILE .NOT. EOF() .AND. V_PED_HD.HP_EMPR+V_PED_HD.HP_NRO=LP_EMPR+LP_NRO
          IF LOCK()
            DELETE 
          ENDIF
          SKIP
        ENDDO
        
        *ADICION DE NUEVAS LINEAS
        APPEND FROM (P_LINEAS)
        GO TOP

        SELECT E  && Cabecera Pedidos Temporal
        SCATTER MEMVAR
        
        SELECT V_PED_HD
        IF LOCK()
          GATHER MEMVAR
        ENDIF

        SELECT E && Cabecera Pedidos Temporal
        USE
        
        END_MENU=.T.

      CASE OPCION=2
*       ANULA MODIFICACION DEL PEDIDO      
        END_MENU=.F.
    ENDCASE
  ENDIF
ENDIF

SELECT E && Cabecera Pedidos Temporal
USE
SELECT F && Lineas Pedidos Temporal
USE

SELECT V_PED_HD

FLUSH

DELETE FILE (P_CABEZA+'.DBF')
DELETE FILE (P_LINEAS+'.DBF')

DO V_ONKEYS

DO PE_VER

IF LASTKEY()<>27 .AND. END_MENU
  DO V_PED_OP
ENDIF
RETURN

FUNCTION CHK_PART
*****************
PARAMETER PART

IF substr(PART,1,1)="*"
  SELECT V_ITEMS
  set filter to (upper(alltrim(SUBSTR(PART,2,15)))$upper(it_part) .OR. upper(alltrim(SUBSTR(PART,2,15)))$upper(it_descr))
  ACTIVATE POPUP GETITEM
  PART=SUBSTR(PROMPT(),1,15)
  set filter to
  SELECT F   && Lineas Pedido temporal
  REPLACE LP_PART WITH PART
ENDIF

SELECT V_ITEMS
SEEK EMPRESA+PART
IF .NOT. FOUND() AND .NOT. PART=SPACE(15)
  ACTIVATE POPUP GETITEM

  SEEK EMPRESA+SUBSTR(PROMPT(),1,15)
  PART=IT_PART

  SELECT F   && Lineas temporal
  REPLACE LP_PART WITH PART
ENDIF

SELECT F    && Lineas temporal
  IF PART<>SPACE(15)
    REG_NUM=RECNO()
    REPLACE LP_PART WITH 'XXXXXXXXXXXXXXX'
    LOCATE FOR LP_PART=PART
     
    IF FOUND()
      * CODIGO DUPLICADO
      GO REG_NUM
      REPLACE LP_PART WITH SPACE(15)
      RETURN .F.
    ELSE
      GO REG_NUM
      REPLACE LP_PART WITH PART
      REPLACE lp_sus_kg WITH v_items.it_sus_kg
      REPLACE lp_peso_t WITH v_items.it_peso_t
    ENDIF
  ENDIF

RETURN .T.

FUNCTION CHK_POLD
*****************
PARAMETER PART
SELECT V_ITEMS
SEEK EMPRESA+PART
IF FOUND() .OR. PART=SPACE(15)
  SELECT F && Lineas Pedido temporal
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
    ENDIF
  ENDIF
  RETURN .T.
ELSE
  *-  DEFINIR UN POPUP DE CLIENTES -*
  ACTIVATE POPUP GETITEM
  SEEK EMPRESA+SUBSTR(PROMPT(),1,15)
  PART=IT_PART
  SELECT F  && Lineas Pedido temporal
  REPLACE LP_PART WITH PART
  RETURN .T.
ENDIF    


FUNCTION GET_PRECIO
*-----------------*
PARAMETER MI_PART

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

**PRECIOS
SELPRECIO=0	
DO CASE
	CASE ALLTRIM(TPRECIO)='Base'
		SELPRECIO=V_ITEMS.IT_PRECIO	
	CASE ALLTRIM(TPRECIO)='Lista 1'
		SELPRECIO=V_ITEMS.IT_PRECIO1	
	CASE ALLTRIM(TPRECIO)='Lista 2'
		SELPRECIO=V_ITEMS.IT_PRECIO2	
	CASE ALLTRIM(TPRECIO)='Lista 3'
		SELPRECIO=V_ITEMS.IT_PRECIO3	
	CASE ALLTRIM(TPRECIO)='Lista 4'
		SELPRECIO=V_ITEMS.IT_PRECIO4	
	CASE ALLTRIM(TPRECIO)='Lista 5'
		SELPRECIO=V_ITEMS.IT_PRECIO5	
ENDCASE

SELECT F  && Lineas Pedido temporal
REPLACE LP_LISTA   WITH ROUND((SELPRECIO-(SELPRECIO*DESCTO_IT)),2)
REPLACE LP_PRECIO  WITH ROUND((SELPRECIO-(SELPRECIO*DESCTO_IT)),2)
RETURN .T.

FUNCTION CHK_CLIENT
*******************
PARAMETER CODIGO
SELECT V_CLIENT
SEEK EMPRESA+CODIGO
IF FOUND()
  @ 3,22 SAY SUBSTR(CL_RAZON,1,35)
  SELECT E  && Cabecera temporal
  RETURN .T.
ELSE
  *-  DEFINIR UN POPUP DE CLIENTES -*
  SELECT V_CLIENT
  SET ORDER TO RAZON
  
  DEFINE WINDOW GETFILTERCL ;
		FROM 6, 10 ;
		TO 10,70 ;
		TITLE "FILTRO DE BUSQUEDA" ;
		NOFLOAT ;
		DOUBLE 

  ACTIVATE WINDOW getfiltercl
  filter1=space(30)
  @ 1,3 say "Filtrar nombres con:"
  @ 1,25 get filter1 
  read
  release window getfiltercl
      
  if filter1<>space(30)
    set filter to upper(alltrim(filter1))$upper(cl_razon)
  endif
  
  ACTIVATE POPUP GETCLIEN
  SELECT V_CLIENT
  
  if filter1<>space(30)
    set filter to
  endif

  SET ORDER TO CODIGO
  SEEK EMPRESA+SUBSTR(PROMPT(),32,6)
  CODIGO=CL_COD_CL

  SELECT E  && Cabecera temporal
  REPLACE HP_COD_CL WITH CODIGO
  @ 3,22 SAY substr(V_CLIENT.CL_RAZON,1,35)
  RETURN .T.
ENDIF    

  
FUNCTION CHK_CLIOLD
*******************
PARAMETER CODIGO
SELECT V_CLIENT
SEEK EMPRESA+CODIGO
IF FOUND()
  @ 3,22 SAY SUBSTR(CL_RAZON,1,35)
  SELECT E  && Cabecera Pedidos Temporal
  RETURN .T.
ELSE
  *-  DEFINIR UN POPUP DE CLIENTES -*
  SELECT V_CLIENT
  SET ORDER TO RAZON
  ACTIVATE POPUP GETCLIEN
  SET ORDER TO CODIGO
  SEEK EMPRESA+SUBSTR(PROMPT(),32,6)
  CODIGO=CL_COD_CL
  SELECT E  && Cabecera Pedidos Temporal
  REPLACE HP_COD_CL WITH CODIGO
  @ 3,22 SAY SUBSTR(V_CLIENT.CL_RAZON,1,35)
  RETURN .T.
ENDIF    

FUNCTION CHK_VENDOR
*******************
PARAMETER CODIGO
SELECT V_VENDOR
SEEK EMPRESA+CODIGO
IF FOUND()
  @ 2,17 SAY VE_NOMBRE
  SELECT E && Cabecera Pedidos Temporal
  RETURN .T.
ELSE
  @ 2,17 SAY 'CODIGO DE VENDEDOR ERRADO'
  SELECT E  && Cabecera Pedidos Temporal
  RETURN .F.  
ENDIF    

FUNCTION GET_STOCK
*----------------*
PARAMETER MI_PART
RETURN V_ITEMS.IT_SALDO

FUNCTION GET_TOT
****************
PARAMETER DEDONDE

MI_REC=RECNO()
CALCULA=.F.

IF LP_PART=SPACE(15)
  CLEAR
  SUM LP_CANT,ROUND(LP_CANT*LP_PRECIO,2) TO TOT_CANT,TOT_IMPORT
  GO MI_REC
  @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
  @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2),'9,999,999.99') 
  @ 19,0 TO 24,79 DOUBLE COLOR G+/B
  @ 19, 5 SAY 'SALDOS DEL ITEM'
  @ 19,60 SAY 'TOTALES'
  REG_ACT=0
  RETURN .T.
ENDIF

IF DEDONDE='V'
  SUM LP_CANT,ROUND(LP_CANT*LP_PRECIO,2) TO TOT_CANT,TOT_IMPORT
  GO MI_REC
  @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
  @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2),'9,999,999.99') 
ELSE
  IF MI_REC<>REG_ACT
    CALCULA=.T.
    REG_ACT=MI_REC
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
    REPLACE AL_CANT WITH 0 , AL_PESO WITH 0 ALL

    SELECT V_DOC_LN
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

    SELECT ALMACEN
    GO TOP
    SEEK EMPRESA
    CLEAR
    @ 19,0
    ? '  [ALMACEN] [  S A L D O  ]'

    DO WHILE .NOT. EOF() .AND. AL_EMPR=EMPRESA
      IF AL_CANT>0
        SET COLOR TO G+/B
      ENDIF
      ? '      '+AL_ALM+'   '+TRANSFORM(AL_CANT,'99,999,999.99')+' '+V_ITEMS.IT_UNIDAD
      SET COLOR TO
      SKIP
    ENDDO
    @ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2) ,'9,999,999.99') 
    @ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*E.HP_DSCTO_P/100,2),'9,999,999.99') 
    @ 19,0 TO 24,79 DOUBLE COLOR G+/B
    @ 19, 5 SAY 'SALDOS DEL ITEM'
    @ 19,60 SAY 'TOTALES'
    SELECT F  && Lineas Pedido temporal
  ENDIF
ENDIF

RETURN .T.

FUNCTION GET_DSCTO
*******************
RETURN .T.

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

FUNCTION SUM_TOT
****************
@10,21 SAY TRANSFORM(T_FLETES+T_EMBALA+T_OTROS,'99,999,999.99')
@12,21 SAY TRANSFORM(HP_IMPORTE-round((hp_importe*hp_dscto_p)/100,2)+T_FLETES+T_EMBALA+T_OTROS,'99,999,999.99')
RETURN .T.

PROCEDURE MOD_DATOS
*******************
DEFINE WINDOW PED_COTIZ ;
		FROM 0, 0 ;
		TO 8,79 ;
		TITLE " MODIFICACION DATOS COTIZACION " ;
		NOFLOAT ;
		DOUBLE 
ACTIVATE WINDOW ped_cotiz

SELECT E && Cabecera Pedidos Temporal

T_FLETES=HP_FLETES
T_EMBALA=HP_EMBALA
T_OTROS =HP_OTROS

DO V_PED_V2.SPR

DO V_PED_CO.SPR

REPLACE HP_FLETES WITH T_FLETES 
REPLACE HP_EMBALA WITH T_EMBALA 
REPLACE HP_OTROS  WITH T_OTROS

DO V_PE_IN2.SPR

RELEASE WINDOW PED_COTIZ

RETURN
