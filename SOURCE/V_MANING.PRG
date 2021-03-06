**** NO SE UTILIZA LD_PRECIO (PRECIO DE VENTA)
**** SOLO LD_COSTO QUE ES EL COSTO UNITARIO PARA INGRESOS Y SALIDAS (NRs)

PARAMETER TIPO

IF TYPE("EMPRESA")="U" OR TYPE("MI_EMPRESA")="U"
  DO V_GETEMP
ENDIF

INSAL='1'

ALM_ALTA='01'
MAX_LINES=35
ALMACEN =SPACE(30)

DO CASE
  CASE TIPO='A'
    TITULO='  NOTA DE INVENTARIO INICIAL '
    NEXT='INV'
  CASE TIPO='D'
    TITULO='    NOTA DE DEVOLUCION       '
    NEXT='DEV'
  CASE TIPO='I'
    TITULO='   INGRESO DE PRODUCCION     '
    NEXT='NI'
  CASE TIPO='C'
    TITULO='  INGRESO POR COMPRA LOCAL   '
    NEXT='CL'
  CASE TIPO='B'
    TITULO='   INGRESO POR IMPORTACION   '
    NEXT='IM'
  CASE TIPO='P'
    TITULO='INGRESO POR TRASPASO DE RS/MP'
    NEXT='TRAS'
  CASE TIPO='T'
    TITULO='T R A N S F E R E N C I A S  '
    NEXT='TRAN'
ENDCASE
*                                          
SET COLOR SET TO plasmar
DO SET_AMBI
DO SET_GRAL
DO V_ONKEYS

SELECT V_DOC_HD
SEEK EMPRESA
DO NR_VER
STORE .T. TO MU_LOOP
DO WHILE MU_LOOP
   ACTIVATE MENU M_NR
ENDDO
DO FIN

RETURN

*******************************************************************************
PROCEDURE SET_AMBI
******************
SET BLINK OFF
SET CLOCK ON
SET CONFIRM ON
SET EXCLU OFF
SET DATE TO DMY
SET DELE ON
SET TALK OFF
SET SAFETY OFF
SET ESCAPE OFF
SET EXACT OFF
RETURN

PROCEDURE SET_GRAL
******************
*MUESTRA PANTALLA INICIAL E INICIALIZA AMBIENTE CON 'SETUP'
SET CURSOR OFF
MENSAJE='ESPERE UN MOMENTO POR FAVOR !!'
CLEAR
DO V_ING_CA.SPR
S_INI=SECONDS()
DO SETUP
S_FIN=SECONDS()
IF S_FIN-S_INI<2
  @ 23,0  
  WAIT '' TIMEOUT 2-(S_FIN-S_INI)
ENDIF
SET CURSOR ON
CLEAR
RETURN

PROCEDURE SETUP
***************
* INICIALIZA AMBIENTE
SELECT 1
USE V_DOC_HD ORDER CORRE
SELECT 2
USE V_DOC_LN ORDER CORRE
SELECT 3
USE V_EMPR ORDER EMPR
SELECT 4
USE V_ITEMS ORDER PART
SELECT 5
* TEMPORAL
SELECT 6
* TEMPORAL
SELECT 7
USE V_CORRE ORDER EMPRESA
SELECT 8
* TEMPORAL
SELECT 9
* TEMPORAL
SELECT 10
USE V_VENDOR ORDER CODIGO
SELECT 11
* TEMPORAL
SELECT 15
* AREA RESERVADA PARA USO TEMPORAL DE CABEZAS DE FACT. 
SELECT 16
* AREA RESERVADA PARA USO TEMPORAL DE LINEAS DE FACT. 
SELECT 17
* TEMPORAL
SELECT V_DOC_LN
SET RELATION TO LD_EMPR+LD_PART INTO V_ITEMS

SELECT  V_DOC_HD
SET RELATION TO HD_EMPR INTO V_EMPR
SET RELATION TO HD_EMPR+HD_COD_VEN INTO V_VENDOR ADDITIVE
SET FILTER TO HD_EMPR=EMPRESA .AND. HD_TIPO=TIPO
GO TOP

SELECT V_ITEMS
DEFINE POPUP GETITEM FROM 8,15 TO 20,70 PROMPT FIELD IT_PART+'-'+IT_DESCR ;
 TITLE 'SELECCIONE ITEM CON [ENTER]' 
ON SELECTION POPUP GETITEM DEACTIVATE POPUP

SELECT V_DOC_HD
DEFINE WINDOW W_NR FROM 0,0 TO 24,79 DOUBLE
DEFINE WINDOW NR_hd FROM 0, 0 TO 8,79 TITLE ALLTRIM(TITULO) ;
 NOFLOAT DOUBLE 

DEFINE WINDOW NR_ln FROM 9, 0 TO 21,79 TITLE "D E T A L L E" ;
 NOFLOAT DOUBLE 
DEFINE WINDOW NR_MSG FROM 21, 0 TO 24,79 TITLE "MENSAJES" ;
 NOFLOAT DOUBLE 
		

DEFINE MENU M_NR 

DEFINE PAD PREV OF M_NR PROMPT '<- \<PREV'   AT 23,01 SKIP FOR BOF("V_DOC_HD")
DEFINE PAD NEXT OF M_NR PROMPT '\<SIG ->'    AT 23,11 SKIP FOR EOF("V_DOC_HD")
DEFINE PAD OJEAR OF M_NR PROMPT 'O\<JEA'     AT 23,20
DEFINE PAD BUSCA OF M_NR PROMPT '\<BUSCA'    AT 23,27
DEFINE PAD MIRA  OF M_NR PROMPT '\<VERIFICA'    AT 23,35
DEFINE PAD ALTA  OF M_NR PROMPT '\<ALTA'     AT 23,46
DEFINE PAD ANULA OF M_NR PROMPT 'AN\<UL'     AT 23,53
DEFINE PAD OPCION OF M_NR PROMPT '\<OPCIONES'  AT 23,60
DEFINE PAD SALE  OF M_NR PROMPT 'SA\<LIR '    AT 23,71

*          1         2         3         4         5         6         7      
*01234567890123456789012345678901234567890123456789012345678901234567890123456789
*浜様様様様僕様様様曜様様様僕様様様僕様様様様曜様様様僕様様曜様様様様様僕様様様融
*� <- PREV � SIG -> � OJEA � BUSCA � VERIFICA � ALTA � ANUL � OPCIONES � SALIR  �
*藩様様様様瞥様様様擁様様様瞥様様様瞥様様様様擁様様様瞥様様擁様様様様様瞥様様様夕

ON SELECTION PAD PREV   OF M_NR  DO NR_PREV
ON SELECTION PAD NEXT   OF M_NR  DO NR_NEXT
ON SELECTION PAD OJEAR  OF M_NR  DO NR_OJEAR
ON SELECTION PAD BUSCA  OF M_NR  DO NR_BUSCA
ON SELECTION PAD MIRA   OF M_NR  DO NR_MIRA
ON SELECTION PAD ALTA   OF M_NR  DO ALTAS
ON SELECTION PAD ANULA  OF M_NR  DO NR_ANULA
ON SELECTION PAD OPCION OF M_NR  DO NR_OPC
ON SELECTION PAD SALE   OF M_NR  DO NR_SALE
RETURN

PROCEDURE ALTAS
***************
IF TIPO='T'
  DO ALTA_TRA
ELSE
  DO NR_ALTA
ENDIF    
RETURN

PROCEDURE NR_VER
****************
VENDEDOR=SPACE(30)
ALMACEN =SPACE(30)

SELECT V_DOC_HD
DO GET_VENDOR WITH HD_COD_VEN

SELECT V_DOC_HD
DO GET_ALM    WITH HD_ALM

SELECT V_DOC_HD
DO V_ING_V.SPR

ACTIVATE SCREEN
@ 22,0 SAY "浜様様様様僕様様様曜様様様僕様様様僕様様様様曜様様様僕様様曜様様様様様僕様様様融"
@ 23,0 SAY "� <- PREV � SIG -> � OJEA � BUSCA � VERIFICA � ALTA � BAJA � MODIFICA � SALIR  �"
@ 24,0 SAY "藩様様様様瞥様様様擁様様様瞥様様様瞥様様様様擁様様様瞥様様擁様様様様様瞥様様様夕"
SELECT V_DOC_LN
GO TOP
KEYBOARD CHR(27)
BROWSE KEY V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO  ;
       FIELDS LD_PART:H='PART.#':W=.F.,V_ITEMS.IT_DESCR:H='DESCRIPCION',LD_CANT:H='CANTIDAD':P='9,999,999.99':W=.F.,V_ITEMS.IT_UNIDAD:H='UNI.',LD_PESO:H='kg. TOT.':P='99,999.99':W=.F.,LD_ESTADO:H='ESTADO':W=.F. WINDOW NR_LN  ;
       NOEDIT NOCLEAR NOAPPEND
RETURN

PROCEDURE NR_NEXT
*****************
SELECT V_DOC_HD
IF .NOT. EOF()
   SKIP
ENDIF 
DO NR_VER
RETURN

PROCEDURE NR_PREV
*****************
SELECT V_DOC_HD
IF .NOT. BOF()
   SKIP -1
ENDIF 
DO NR_VER
RETURN

PROCEDURE NR_ANULA
******************
IF .NOT. V_USRAUT(USER,"DOCS_ALM",3)  
   RETURN
ENDIF

SELECT V_DOC_HD

DEFINE WINDOW ANULA_WI FROM 8,20 TO 10,60 DOUBLE TITLE 'DESEA ANULAR LA NOTA ?' && COLOR B/G,,B/G,B/G,N+/G
ACTIVATE WINDOW ANULA_WI
SINO='N'
@ 0,5 SAY '          (S/N):' GET SINO PICTURE '!' VALID SINO$'SN'
READ

IF SINO='S'

  SELECT V_DOC_HD
  IF LOCK()
    REPLACE HD_ESTADO WITH 'A', ;
            HD_OBS WITH '* * * A N U L A D O/A * * *'

    SELECT V_DOC_LN
    SEEK V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO  
    IF .NOT. EOF() .AND. LOCK()
      REPLACE LD_ESTADO WITH 'A', ;
              LD_PART WITH SPACE(15), ;
              LD_CANT WITH 0, ;
              LD_PESO WITH 0
      SKIP             
      DO WHILE .NOT. EOF() .AND. V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO=LD_EMPR+LD_ALM+LD_TIPO+LD_NRO
        IF LOCK()
          DELETE
        ENDIF
        SKIP
      ENDDO
    ENDIF     
  ENDIF
  RELEASE WINDOW ANULA_WI  
  MENSAJE1='!!!! EL DOCUMENTO HA SIDO ANULADO !!!!' 
  MENSAJE2=''
  DO V_MENSAJ.SPR
  DO NR_VER  
ELSE
  RELEASE WINDOW ANULA_WI  
ENDIF  

RETURN

PROCEDURE NR_SALE
*****************
STORE .F. TO MU_LOOP
DEACTIVATE MENU
RETURN

PROCEDURE FIN
**************
RELEASE MENU   M_NR
RELEASE WINDOW NR_HD
RELEASE WINDOW NR_LN
RELEASE WINDOW NR_MSG
CLOSE DATA
ACTIVATE SCREEN
ON KEY
SET ESCAPE ON
CLEAR
RETURN

FUNCTION CHK_NR
***************
PARAMETER NOTA_REM
CURRENT=SELECT()
SELECT V_DOC_LN
SET ORDER TO NR
SEEK EMPRESA+'R'+NOTA_REM
IF EOF()
  SET ORDER TO CORRE
  SELECT (CURRENT)
  RETURN .F.
ELSE
  COPY REST WHILE .NOT. EOF() .AND. EMPRESA+'R'+NOTA_REM=LD_EMPR+LD_TIPO+LD_NRO TO (REM_JALA) 
  SELECT V_DOC_LN
  SET ORDER TO CORRE
  SELECT (CURRENT)
  RETURN .T.
ENDIF
  
FUNCTION CHK_VENDOR
*******************
PARAMETER CODIGO
CURRENT=SELECT()
SELECT V_VENDOR
SEEK EMPRESA+CODIGO
IF FOUND()
  @ 3,16 SAY '-'+VE_NOMBRE
  SELECT (CURRENT)
  RETURN .T.
ELSE
  SELECT (CURRENT)
  RETURN .F.  
ENDIF    

*-----------------*
FUNCTION CHK_ALM
*-----------------*
PARAMETER ALM
CURRENT=SELECT()
SELECT 0 
USE V_ALM ORDER ALM
SEEK EMPRESA+ALM
IF FOUND()
  @ 2,16 SAY '-'+AL_DESCR
  USE
  SELECT (CURRENT)
  RETURN .T.
ELSE
  USE
  SELECT (CURRENT)
  RETURN .F.  
ENDIF    

*-----------------*
PROCEDURE GET_VENDOR
*-----------------*
PARAMETER CODIGO
CURRENT=SELECT()
SELECT V_VENDOR
SEEK EMPRESA+CODIGO
IF FOUND()
  VENDEDOR=VE_NOMBRE
ELSE
  VENDEDOR='VENDEDOR NO EXISTE'
ENDIF    
SELECT (CURRENT)
RETURN

*-----------------*
FUNCTION GET_ALM
*-----------------*
PARAMETER ALM
CURRENT=SELECT()
SELECT 0 
USE V_ALM ORDER ALM
SEEK EMPRESA+ALM
IF FOUND()
  ALMACEN=AL_DESCR
  USE
ELSE
  ALMACEN='ALMACEN NO EXISTE'
  USE
ENDIF    
SELECT (CURRENT)
RETURN

FUNCTION CHK_PAR0     
*****************
*REEMPLAZADO POR RUTINA MAS ABAJO

PARAMETER PART
CURRENT=SELECT()
SELECT V_ITEMS
SEEK EMPRESA+PART
IF FOUND() .OR. PART=SPACE(15)
  SELECT (CURRENT)
  RETURN .T.
ELSE
  *-  DEFINIR UN POPUP DE CLIENTES -*
  ACTIVATE POPUP GETITEM
  SEEK EMPRESA+SUBSTR(PROMPT(),1,15)
  PART=IT_PART
  SELECT (CURRENT)
  REPLACE LD_PART WITH PART
  RETURN .T.
ENDIF    

FUNCTION CHK_PART 
*****************
PARAMETER PART

CURRENT=SELECT()

IF substr(PART,1,1)="*"
  SELECT V_ITEMS
  set filter to (upper(alltrim(SUBSTR(PART,2,15)))$upper(it_part) .OR. upper(alltrim(SUBSTR(PART,2,15)))$upper(it_descr))
  ACTIVATE POPUP GETITEM
  PART=SUBSTR(PROMPT(),1,15)
  set filter to
  SELECT (CURRENT)
  REPLACE LD_PART WITH PART
ELSE
  SELECT V_ITEMS
  SEEK EMPRESA+PART
  IF .NOT. FOUND()
    ACTIVATE POPUP GETITEM
    PART=SUBSTR(PROMPT(),1,15)
    SELECT (CURRENT)
    REPLACE LD_PART WITH PART
  ENDIF
ENDIF

SELECT V_ITEMS
SEEK EMPRESA+PART

SELECT (CURRENT)
IF PART<>SPACE(15)
    REG_NUM=RECNO()
    REPLACE LD_PART WITH 'XXXXXXXXXXXXXXX'
    LOCATE FOR LD_PART=PART
    IF FOUND()
      * CODIGO DUPLICADO
      WAIT "CODIGO DUPLICADO!" WINDOW TIMEOUT 2
      GO REG_NUM
      REPLACE LD_PART   WITH SPACE(15)
      REPLACE LD_PESO   WITH 0
      REPLACE LD_PRECIO WITH 0
      RETURN .F.
    ELSE
      GO REG_NUM
      REPLACE LD_PART WITH PART
    ENDIF
ENDIF

RETURN .T.

PROCEDURE ALTA_TRA
******************
IF .NOT. V_USRAUT(USER,"DOCS_ALM",2)  
   RETURN
ENDIF

REM_JALA=SYS(3)+'.TRA'

SELECT V_DOC_HD

APPEND BLANK
IF LOCK()
  REPLACE HD_EMPR    WITH EMPRESA, ;
          HD_TIPO    WITH 'T', ;
          HD_NRO     WITH V_NEXT_N(EMPRESA,'TRAN'), ;
          HD_FECHA   WITH DATE(), ;
          HD_USUARIO WITH SYS(0), ;
          HD_ALM     WITH ALM_ALTA
ENDIF
          
DO V_TR_M.SPR

VENDEDOR=SPACE(20)
ALMACEN =SPACE(20)

SELECT V_DOC_HD
DO GET_VENDOR WITH HD_COD_VEN

SELECT V_DOC_HD
DO GET_ALM    WITH HD_ALM

SELECT V_DOC_HD
DO V_TR_V.SPR
        
SELECT V_DOC_LN
DEFINE WINDOW DOC_ADD ;
		FROM 9, 0 ;
		TO 24,79 ;
		DOUBLE 

SELECT 0
USE (REM_JALA) EXCLU
**REM_JALA HA SIDO CREADA EN V_TR_M.SPR LLAMANDO A FUNCION CHK_NR
REPLACE ALL  LD_EMPR    WITH V_DOC_HD.HD_EMPR,  ;
             LD_ALM     WITH V_DOC_HD.HD_ALM,   ;
             LD_TIPO    WITH V_DOC_HD.HD_TIPO,  ;
             LD_NRO     WITH V_DOC_HD.HD_NRO,   ;
             LD_FECHA   WITH V_DOC_HD.HD_FECHA, ;
             LD_COD_VEN WITH V_DOC_HD.HD_COD_VEN, ;
             LD_COD_CL  WITH SPACE(8), ;
             LD_INSAL   WITH '1 ', ;
             LD_COSTO   WITH 0, ;
             LD_ESTADO  WITH ' '
USE 

SELECT V_DOC_LN
APPEND FROM (REM_JALA)
GO TOP
		
ON KEY LABEL F10 KEYBOARD CHR(23)
BROWSE KEY V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO  ;
       FIELDS LD_PART:H='PART.#',V_ITEMS.IT_DESCR:H='DESCRIPCION':W=.F.,LD_CANT:H='CANTIDAD':P='999999.99',V_ITEMS.IT_UNIDAD:H='UNI.':W=.F.,LD_PESO:H='kg. TOT.':P='99999.99' ;
       WINDOW DOC_ADD  ;
       TITLE 'DETALLE - [F10]-PARA SALIR [*]-FILTRO' ;
       NOAPPEND NODELETE

SEEK V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO
DELE REST WHILE .NOT. EOF() .AND. V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO=LD_EMPR+LD_ALM+LD_TIPO+LD_NRO ;
    FOR LD_CANT=0 .OR. LD_PART=SPACE(15)

GO TOP
        
RELEASE WINDOW DOC_ADD
DO V_ONKEYS
DO NR_VER
DELETE FILE (REM_JALA)
RETURN

PROCEDURE NR_ALTA
*****************
IF .NOT. V_USRAUT(USER,"DOCS_ALM",2)  
   RETURN
ENDIF

OKCANCEL=1

MI_HD=SYS(3)+'.HD'
MI_LN=SYS(3)+'.LN'

SELECT V_DOC_HD
COPY STRUC TO (MI_HD)

SELECT 5
USE (MI_HD) ALIAS CABEZA

APPEND BLANK
REPLACE HD_EMPR  WITH EMPRESA, ;
        HD_TIPO  WITH TIPO, ;
        HD_ALM   WITH ALM_ALTA, ;
        HD_FECHA WITH DATE(), ;
        HD_USUARIO WITH SYS(0)

HIDE MENU M_NR
ACTIVATE SCREEN
CLEAR
@ 13,25 TO 17,55 
@ 14,27 SAY 'DIGITE LOS DATOS POR FAVOR'
@ 16,27 SAY '     [ESC] PARA SALIR     '
ACTIVATE WINDOW NR_HD
CLEAR

ON KEY LABEL CTRL+M STORE .T. TO MOD_NRO,MOD_ALM

DO V_ING_M.SPR

IF OKCANCEL=2
  SELECT CABEZA
  USE
  DELETE FILE (MI_HD)
  SELECT V_DOC_HD
  DO NR_VER
  RETURN
ENDIF

VENDEDOR=SPACE(20)
ALMACEN =SPACE(20)

SELECT CABEZA
DO GET_VENDOR WITH HD_COD_VEN
SELECT CABEZA
DO GET_ALM    WITH HD_ALM

SELECT CABEZA
DO V_ING_V.SPR

SELECT V_DOC_LN
COPY STRUCT TO (MI_LN)
SELECT 6
USE (MI_LN) ALIAS LINEAS

FOR N=1 TO MAX_LINES
  APPEND BLANK
  IF LOCK()
    REPLACE LD_EMPR  WITH CABEZA.HD_EMPR, ;
            LD_TIPO  WITH CABEZA.HD_TIPO, ;
            LD_FECHA WITH CABEZA.HD_FECHA, ;
            LD_NRO   WITH CABEZA.HD_NRO, ;
            LD_ALM   WITH CABEZA.HD_ALM, ;
            LD_INSAL WITH INSAL
  ENDIF
ENDFOR

ON KEY LABEL F10 KEYBOARD CHR(23)

SET RELATION TO LD_EMPR+LD_PART INTO V_ITEMS

GO TOP
BROWSE FIELDS LD_PART:H='PART.#':V=CHK_PART(LD_PART) ,; 
       V_ITEMS.IT_DESCR:H='DESCRIPCION':W=.F.,LD_CANT:H='CANTIDAD':P='9999999.99',V_ITEMS.IT_UNIDAD:H='UNI.':W=.F.,LD_PESO:H='kg. TOT.':P='99999.99',LD_COSTO:H='COSTO U.':P='999999.9999':W=TIPO<>'NI',IMPORTE=ROUND(LD_CANT*LD_COSTO,2):H='IMPORTE Bs.':P='9999999.99' ,LD_ESTADO:H='ESTADO':W=.F. WINDOW NR_LN ;
       NOAPPEND  TITLE '[F10]-TERMINA DETALLE  [ESC]-DESCARTA INGRESO [*]-FILTRO' 

GO TOP
SET CARRY OFF

IF LASTKEY()<>27
  SELECT CABEZA
  IF HD_NRO=SPACE(6)
    REPLACE HD_NRO WITH V_NEXT_N(EMPRESA,NEXT)
  ENDIF
  SELECT LINEAS
  DO WHILE .NOT. EOF() 
    IF LD_CANT=0 .OR. LD_PART=SPACE(15)
      DELETE
    ELSE
      REPLACE LD_NRO WITH CABEZA.HD_NRO
      IF LD_PESO=0
        REPLACE LD_PESO WITH LD_CANT*V_ITEMS.IT_PESO_T
      ENDIF          
    ENDIF
    SKIP
  ENDDO 
  SELECT 5
  USE
  SELECT 6
  USE
  SELECT V_DOC_HD
  APPEND FROM (MI_HD)
  SELECT V_DOC_LN
  APPEND FROM (MI_LN)
ENDIF

SELECT 5
USE
SELECT 6
USE
DELETE FILE (MI_HD)
DELETE FILE (MI_LN)
FLUSH
DO V_ONKEYS
DO NR_VER
RETURN

PROCEDURE NR_MODI
*****************
IF .NOT. V_USRAUT(USER,"DOCS_ALM",2)  
   RETURN
ENDIF

OKCANCEL=1
SELECT V_DOC_HD

HIDE MENU M_NR
ACTIVATE SCREEN
CLEAR
@ 13,25 TO 17,55 
@ 14,27 SAY 'DIGITE LOS DATOS POR FAVOR'
@ 16,27 SAY '     [ESC] PARA SALIR     '
ACTIVATE WINDOW NR_HD
CLEAR

DO V_ING_M.SPR

IF OKCANCEL=2
  DO NR_VER
  RETURN
ENDIF

VENDEDOR=SPACE(20)
ALMACEN =SPACE(20)

SELECT V_DOC_HD
DO GET_VENDOR WITH HD_COD_VEN
SELECT V_DOC_HD
DO GET_ALM    WITH HD_ALM

SELECT V_DOC_HD
DO V_ING_V.SPR

SELECT V_DOC_LN

SEEK V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO

MI_COUNT=0
COUNT REST WHILE .NOT. EOF() .AND. V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO=LD_EMPR+LD_ALM+LD_TIPO+LD_NRO TO MI_COUNT

FOR N=1 TO MAX_LINES-MI_COUNT
  APPEND BLANK
  IF LOCK()
    REPLACE LD_EMPR  WITH V_DOC_HD.HD_EMPR, ;
            LD_TIPO  WITH V_DOC_HD.HD_TIPO, ;
            LD_FECHA WITH V_DOC_HD.HD_FECHA, ;
            LD_NRO   WITH V_DOC_HD.HD_NRO, ;
            LD_ALM   WITH V_DOC_HD.HD_ALM, ;
            LD_INSAL WITH INSAL
  ENDIF
ENDFOR

ON KEY LABEL F10 KEYBOARD CHR(23)

SET FILTER TO LD_EMPR+LD_ALM+LD_TIPO+LD_NRO=V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO
GO TOP

BROWSE KEY V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO  ;
       FIELDS LD_PART:H='PART.#':V=CHK_PART(LD_PART), V_ITEMS.IT_DESCR:H='DESCRIPCION':W=.F., ;
       LD_CANT:H='CANTIDAD':P='9999999.99', ;
       V_ITEMS.IT_UNIDAD:H='UNI.':W=.F., ;
       LD_PESO:H='kg. TOT.':P='999999.9999', ;
       LD_COSTO:H='COSTO U.':P='999999.9999':W=TIPO<>'NI', ;
       IMPORTE=ROUND(LD_CANT*LD_COSTO,2):H='IMPORTE Bs.':P='9999999.99', ;
       LD_ESTADO:H='ESTADO':W=.F. ;
       WINDOW NR_LN NOAPPEND TITLE '[F10]-TERMINA DETALLE [*]-FILTRO' 

GO TOP
DO WHILE .NOT. EOF() 
  IF LD_CANT=0 .OR. LD_PART=SPACE(15)
    DELETE
  ELSE
    IF LD_PESO=0
        REPLACE LD_PESO WITH LD_CANT*V_ITEMS.IT_PESO_T
    ENDIF          
  ENDIF
  SKIP
ENDDO 

SET FILTER TO
GO TOP

FLUSH
DO V_ONKEYS
DO NR_VER
RETURN

PROCEDURE NR_MIRA
*****************
SELECT V_DOC_LN
DEFINE WINDOW NR_VERI ;
		FROM 9, 0 ;
		TO 24,79 ;
		DOUBLE 
		
ON KEY LABEL F10 KEYBOARD CHR(23)
BROWSE KEY V_DOC_HD.HD_EMPR+V_DOC_HD.HD_ALM+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO  ;
       FIELDS LD_PART:H='PART.#',V_ITEMS.IT_DESCR:H='DESCRIPCION',LD_CANT:H='CANTIDAD':P='9,999,999.99',V_ITEMS.IT_UNIDAD:H='UNI.', ;
       LD_PESO:H='kg. TOT.':P='99,999.99', LD_COSTO:H='COSTO U.':p='999999.9999', IMPORTE=ROUND(LD_CANT*LD_COSTO,2):H='IMPORTE Bs.':P='9999999.99'   WINDOW NR_VERI  ;
       NOCLEAR NOEDIT NODELETE NOAPPEND TIMEOUT 300  TITLE 'DETALLE  -  [F10] PARA SALIR'
RELEASE WINDOW NR_VERI
DO V_ONKEYS
DO NR_VER
RETURN

PROCEDURE NR_OJEAR
******************
W_FILTRO=".T."
W_TITLE ="SELECCIONE CON [F10] - [F12] GENERA ARCHIVO TEXTO"
ON KEY LABEL F10 KEYBOARD CHR(23)
ON KEY LABEL F12 DO V_BEXPOR WITH "HD_NRO, HD_ALM, HD_FECHA, HD_OBS, HD_ESTADO", W_FILTRO
SELECT V_DOC_HD
DO V_IR_REG.SPR
BROWSE FIELDS HD_NRO:H='NRO.',HD_ALM:H='ALM',HD_FECHA:H='FECHA',HD_OBS:H='OBSERVACIONES',HD_ESTADO:H='ESTADO' NOEDIT NOAPPEND NODELETE WINDOW W_NR ;
   TITLE W_TITLE
DO V_ONKEYS 
DO NR_VER
RETURN

PROCEDURE NR_BUSCA
******************
DEFINE WINDOW NR_BUSCA FROM 10,10 TO 19,70 DOUBLE TITLE 'BUSQUEDA DE DOCUMENTOS' 

ACTIVATE WINDOW NR_BUSCA
SELECT V_DOC_HD 
@ 1,1 GET choice FUNCTION '*RNV POR \<NRO;POR \<GLOSA' ;
	SIZE 1,10,1 DEFAULT 1 && COLOR B/G

MI_NR='      '
MI_ALM=' '
MI_OBS=SPACE(20)
MI_ALM='  '
@ 1,20 SAY 'ALM-NUMERO :' GET MI_ALM PICTURE '99' WHEN CHOICE=1  
@ 1,36 say '-'            GET MI_NR  PICTURE '999999'  WHEN CHOICE=1
@ 3,20 SAY 'GLOSA      :' GET MI_OBS WHEN CHOICE=2

@ 7,20 GET okcancel FUNCTION '*TH \!\<OK;\?\<Cancelar' DEFAULT 1;
	SIZE 1,10,1 && COLOR B/G
READ CYCLE
SELECT V_DOC_HD

IF okcancel = 1
  W_FILTRO=".T."
  W_TITLE ="SELECCIONE CON [F10] - [F12] GENERA ARCHIVO TEXTO"
  ON KEY LABEL F10 KEYBOARD CHR(23)
  ON KEY LABEL F12 DO V_BEXPOR WITH "HD_NRO, HD_ALM, HD_FECHA, HD_OBS, HD_ESTADO", W_FILTRO
  DO CASE
   CASE choice = 1
     W_FILTRO="HD_ALM=MI_ALM .AND. ALLTRIM(MI_NR)$HD_NRO"
   CASE choice = 2
     W_FILTRO="ALLTRIM(MI_OBS)$HD_OBS"
  ENDCASE
  BROWSE NOEDIT FOR EVAL(W_FILTRO)  ;
     FIELDS HD_NRO:H='NRO.',HD_ALM:H='ALM',HD_FECHA:H='FECHA',HD_OBS:H='OBSERVACIONES',HD_ESTADO:H='ESTADO' ;
     WINDOW W_NR TITLE 'SELECCIONE NR CON [ENTER]'
ENDIF
RELEASE WINDOW NR_BUSCA
DO V_ONKEYS
DO NR_VER
RETURN

PROCEDURE NR_OPC
****************
OPCION=1

DO V_ING_O.SPR
DO CASE
  CASE LASTKEY()<>27 .AND. OPCION=1
    * IMPRIME DOC
    DO NR_IMPR
  CASE LASTKEY()<>27 .AND. OPCION=2
    * MODIFICA DOC
    DO NR_MODI
  CASE LASTKEY()=27 .OR. OPCION=3
    * SALIR SIN CAMBIOS  
ENDCASE
RETURN

PROCEDURE NR_IMPR
******************
SELECT V_DOC_HD

LLAVE=HD_EMPR+HD_ALM+HD_TIPO+HD_NRO

ACTIVATE WINDOW NR_MSG
@ 0,0 SAY '   ESPERE UN MOMENTO POR FAVOR ..... IMPRIMIENDO'

SELECT V_DOC_LN
SEEK LLAVE
IF FOUND()
  TEMP_FILE='..\TMP\'+SYS(3)+'.NE'
  _PADVANCE='LINEFEED'
  REPORT FORM V_ING_FO FOR LD_EMPR+LD_ALM+LD_TIPO+LD_NRO=LLAVE TO file &TEMP_FILE
  _PADVANCE='FORMFEED'
  *MODI COMM &TEMP_FILE
  *! COPY &TEMP_FILE lpt1:
   ! TYPE &TEMP_FILE > LPT1
  DO NR_VER
  DELETE FILE (TEMP_FILE)
  HIDE WINDOW NR_MSG
  MENSAJE1=ALLTRIM(TITULO)+' NRO.:'+V_DOC_HD.HD_NRO+' HA SIDO IMPRESA'
  MENSAJE2=''
  DO V_MENSAJ.SPR
ENDIF

SELECT V_DOC_HD
DO NR_VER
RETURN
