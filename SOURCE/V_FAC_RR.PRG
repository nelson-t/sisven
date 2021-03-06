******************
PROCEDURE V_FAC_RR
******************
FECHAI=CTOD('25/08/96')
FECHAF=DATE()
LINEA='T'
DIR='V:\BASE_VEN.96\'
DEFINE WINDOW W1 FROM 0, 0 TO 17,79 DOUBLE TITLE 'PEDIDOS PENDIENTES'
SELECT 1
  USE DIR+'V_ITEMS' ORDER PART
SELECT 2
  USE DIR+'V_PED_LN' ORDER CORRE
  SET RELATION TO LP_EMPR+LP_PART INTO V_ITEMS
  ARCH=SYS(3)+'.PED'
  COPY TO (ARCH) FOR LP_FECHA>=FECHAI.AND.LP_FECHA<=FECHAF ;
         .AND. LP_ESTADO$'P'.AND. V_ITEMS.IT_LINEA=ALLTRIM(LINEA)
SELECT 3
  USE (ARCH) ALIAS PED
  SET RELATION TO LP_EMPR+LP_PART INTO V_ITEMS
  ON KEY LABEL SPACEBAR DO M

  BROW FIELDS LP_PART:H='CODIGO':W=.F.:10,V_ITEMS.IT_DESCR:H='DESCRIPCION':W=.F.:29, ;
              LP_NRO:H='PEDIDO':W=.F.,LP_FECHA:H='FECHA':W=.F., ;
              LP_COD_CL:H='CLIENT':W=.F.:6, ;
              LP_CANT:H='CANTIDAD':W=.F.,LP_ESTADO:H='E':1 WINDOW W1 

ON KEY
RETURN
  
SET DELE ON
SET REFRESH TO 1
COD_VEN=SPACE(3)
COD_CL =SPACE(8)
RUC=SPACE(10)
RAZON=SPACE(30)
OPCION =1
ALM    ='  '



ARCH_NR=SYS(3)+'.DBF'

SELECT V_PED_LN
ARCH_TEMP=SYS(3)+'.FAC'
ARCH_IDX =SYS(3)+'.IDX'
ARCH_UNIC=SYS(3)+'.UNI'

COPY STRUC TO (ARCH_TEMP)

SELECT 0
USE (ARCH_TEMP) ALIAS PED_LN EXCLUSIVE
INDEX ON LP_PART TO (ARCH_IDX)
INDEX ON LP_PART TO (ARCH_UNIC) UNIQUE
SET INDEX TO (ARCH_IDX), (ARCH_UNIC)
SET ORDER TO 1

SELECT V_DOC_HD

CLEAR
SET DISPLAY TO EGA43

DO V_FAC_AL.SPR

IF OPCION=1 .AND. LASTKEY()<>27
  @ 21,46 SAY '        BUSCANDO N.R. !!!     ' COLOR R+/GR*
  DO MUESTRA_NR
  DO V_FAC_AA.SPR
  IF OPCION=1 && PROCESA NR's
    DO MAS_FACT    
  ENDIF
  SELECT NRS
  USE
ENDIF
SET DISPLAY TO CGA

RELEASE WINDOW W1
RELEASE WINDOW W2
RELEASE WINDOW W3

CLEAR

SELECT PED_LN
USE

DELET  FILE (ARCH_TEMP)
DELET  FILE (ARCH_IDX)
DELET  FILE (ARCH_UNIC)
DELETE FILE (ARCH_NR)
ON KEY LABEL SPACEBAR
ON KEY LABEL F10
RETURN

PROCEDURE MAS_FACT
******************
SELECT 0
USE V_TC ORDER FECHA
SEEK DTOS(DATE())

TCAMBIO = TC_MONTO   
FACTOR  = TC_MONTO
USE
************ 
SELECT V_FAC_HD
APPEND BLANK
IF LOCK()
  REPLACE HF_EMPR    WITH EMPRESA, ;
          HF_NRO     WITH V_NEXT_N(EMPRESA,'FAC'), ;
          HF_USUARIO WITH SYS(0), ;
          HF_TIPO    WITH 'R', ;
          HF_FECHA   WITH DATE(), ;
          HF_ALM     WITH ALM, ;
          HF_COD_CL  WITH COD_CL, ;
          HF_COD_VEN WITH COD_VEN, ;
          HF_DSCTO_P WITH 0, ;
          HF_FACTOR  WITH TCAMBIO
ENDIF

DO V_FACTOR.SPR

SELECT NRS
SET RELATION TO HD_EMPR+HD_TIPO+HD_NRO INTO V_DOC_HD

GO TOP
DO WHILE .NOT. EOF()
  IF HD_ESTADO=CHR(251)
    SELECT V_FAC_DO 
    APPEND BLANK
    IF LOCK()
      REPLACE FA_EMPR    WITH V_FAC_HD.HF_EMPR, ;
              FA_NRO     WITH V_FAC_HD.HF_NRO,  ;
              FA_DOC_TIP WITH NRS.HD_TIPO, ;
              FA_DOC_ALM WITH NRS.HD_ALM,  ;
              FA_DOC_NRO WITH NRS.HD_NRO,  ;
              FA_PEDIDO  WITH NRS.HD_PEDIDO
    ENDIF

    SELECT V_DOC_HD
    IF LOCK() .AND. HD_EMPR+HD_TIPO+HD_NRO=NRS.HD_EMPR+NRS.HD_TIPO+NRS.HD_NRO
      REPLACE HD_ESTADO WITH 'F'
      SELECT V_DOC_LN
      SEEK V_DOC_HD.HD_EMPR+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO
      DO WHILE .NOT. EOF() .AND. V_DOC_HD.HD_EMPR+V_DOC_HD.HD_TIPO+V_DOC_HD.HD_NRO=LD_EMPR+LD_TIPO+LD_NRO
        REPLACE LD_ESTADO WITH 'F'
        SKIP
      ENDDO
    ENDIF  

  ENDIF
  SELECT NRS
  SKIP
ENDDO  
SELECT NRS
SET RELATION OFF INTO V_DOC_HD

IMPORTE=0

SELECT FACT_LN
GO TOP

DO WHILE .NOT. EOF() 
  SELECT V_FAC_LN
  APPEND BLANK
  IF LOCK()
    REPLACE LF_EMPR    WITH V_FAC_HD.HF_EMPR, ;
            LF_TIPO    WITH V_FAC_HD.HF_TIPO, ;
            LF_NRO     WITH V_FAC_HD.HF_NRO, ;
            LF_FECHA   WITH V_FAC_HD.HF_FECHA, ;
            LF_COD_CL  WITH V_FAC_HD.HF_COD_CL, ;
            LF_PART    WITH FACT_LN.LF_PART, ;
            LF_CANT    WITH FACT_LN.LF_CANT, ;
            LF_PESO    WITH FACT_LN.LF_PESO

    DO GET_PRECIO WITH LF_EMPR,LF_PART

    PARTE=LF_PART
    SELECT FACT_LN
    SKIP
    DO WHILE LF_PART=PARTE .AND. .NOT. EOF()
      REPLACE V_FAC_LN.LF_CANT WITH V_FAC_LN.LF_CANT+LF_CANT
      REPLACE V_FAC_LN.LF_PESO WITH V_FAC_LN.LF_PESO+LF_PESO
      SKIP
    ENDDO
    IMPORTE=IMPORTE+ROUND(LF_CANT*LF_PRECIO,2)
  ENDIF
  SELECT FACT_LN
ENDDO

SET DISPLAY TO CGA
ACTIVATE SCREEN
CLEAR

SELECT V_FAC_HD
DO V_FAC_V.SPR

SELECT V_FAC_LN

DEFINE WINDOW FAC_MOD FROM 9, 0 TO 18,79 ;
		TITLE "DETALLE DE LA FACTURA" ;
		NOFLOAT ;
		DOUBLE 

ACTIVATE SCREEN 

SELECT V_FAC_LN

ON KEY LABEL F10 KEYBOARD CHR(23)

=GET_TOT()

BROWSE KEY V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO  ;
       FIELDS LF_PART:H='CODIGO':P='@S8 !!!!!!!!!!!!!!!', ;
       V_ITEMS.IT_DESCR :H='DESCRIPCION':W=.F., ;
       V_ITEMS.IT_UNIDAD:H='UNI.':W=.F., ;
       LF_CANT:H='CANTIDAD':W=.F.:P='9999999.99', ;
       LF_PRECIO:H='PRECIO U.':P='99999.9999':V=GET_TOT(), ;
       IMPORTE=ROUND(LF_PRECIO*LF_CANT,2):P='999,999.99':R ;
       WINDOW FAC_MOD NOCLEAR  ;
       TITLE '[F10] - ACEPTAR PRECIOS' 

RELEASE WINDOW FAC_MOD

IMPORTE=0

SEEK V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO
SUM REST WHILE .NOT. EOF() .AND. V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO=LF_EMPR+'F'+LF_NRO ;
    ROUND(LF_CANT*LF_PRECIO,2) TO IMPORTE

SELECT V_FAC_HD

IF LOCK()
  REPLACE HF_IMPORTE WITH IMPORTE
  REPLACE HF_NOM_CL  WITH RAZON
  REPLACE HF_RUC     WITH RUC
ENDIF

T_EMBALA=0
T_FLETES=0
T_OTROS=0
T_DSCTO_M=0
T_DSCTO_P=HF_DSCTO_P

ACTIVATE SCREEN 

DO V_FAC_MO.SPR

SELECT V_FAC_HD

IF LOCK()
  REPLACE HF_EMBALA  WITH T_EMBALA , ;
          HF_FLETES  WITH T_FLETES , ;
          HF_OTROS   WITH T_OTROS  , ;
          HF_DSCTO_M WITH T_DSCTO_M, ;
          HF_DSCTO_P WITH T_DSCTO_P
ENDIF          
    
SELECT V_FAC_LN
    
*IMPRESION DE LA FACTURA
MENSAJE1='LA FACTURA GENERADA SE IMPRIMIRA'
MENSAJE2='!!!! ALISTE LA IMPRESORA !!!!'
DO V_MENSAJ.SPR
DO FAC_IMPR
SELECT V_FAC_LN
RETURN

PROCEDURE FAC_IMPR
******************

IF EMPRESA<>'1'
  RETURN
ENDIF
  
SELECT 0
USE V_ALM ORDER ALM
SEEK V_FAC_HD.HF_EMPR+V_FAC_HD.HF_ALM
ALM_DESCR=AL_DESCR
USE

DO WHILE .T.
  SELECT 0
  SET EXCLU OFF
  USE V_SPOOL
  LOCATE FOR SP_EMPR=EMPRESA 
  NRO_FACT=SP_FACT
  USE
                              
  IF NRO_FACT=V_FAC_HD.HF_NRO 
  
    ********** IMPRESION *************** 
    MI_TC=GET_TC(V_FAC_HD.HF_FECHA)

    SELECT V_FAC_LN
    SET RELATION TO LF_EMPR+LF_PART INTO V_ITEMS

    SEEK   V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO     
    TEMP_FILE='V:'+SYS(3)+'.FAC'
    _PADVANCE='LINEFEED'
    REPORT FORM V_FA_FOR NOCONSOLE REST WHILE V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO=LF_EMPR+'F'+LF_NRO TO FILE (TEMP_FILE)
    _PADVANCE='FORMFEED'
    ! /0 NPRINT &TEMP_FILE NFF NB  Q=CAJA
    DELETE FILE (TEMP_FILE)
    MENSAJE1='FACTURA NRO.:'+V_FAC_HD.HF_NRO+' HA SIDO IMPRESA'
    MENSAJE2=''
    DO V_MENSAJ.SPR
    ************************************
    SELECT 0
    USE V_SPOOL
    LOCATE FOR SP_EMPR=EMPRESA 
    IF LOCK()
       REPLACE SP_FACT WITH RIGHT('00000'+ALLTRIM(STR(VAL(SP_FACT)+1)),6)
    ENDIF
    USE
    EXIT
  ELSE
    MENSAJE1='LA FACTURA NO PUEDE SER IMPRESA TODAVIA'
    MENSAJE2='INTENTE OTRA VEZ CUANDO LOS OTROS USUARIOS IMPRIMAN SUS FACT.'
    DO V_MENSAJ.SPR
  ENDIF  
ENDDO

RETURN

FUNCTION SUM_TOT
****************
@ 2,21 SAY TRANSFORM(ROUND((hF_importe*T_dscto_p)/100,2),'99,999,999.99')
@ 4,21 SAY TRANSFORM(HF_IMPORTE-round((hF_importe*T_dscto_p)/100,2),'99,999,999.99')
@ 9,21 SAY TRANSFORM(HF_IMPORTE-round((hF_importe*T_dscto_p)/100,2)+T_FLETES+T_EMBALA+T_OTROS,'99,999,999.99')
@12,21 SAY TRANSFORM(HF_IMPORTE-round((hF_importe*T_dscto_p)/100,2)+T_FLETES+T_EMBALA+T_OTROS-T_DSCTO_M,'99,999,999.99')
RETURN .T.

PROCEDURE GET_PRECIO
********************
PARAMETER MI_EMPR,MI_PART
DESCTO_IT=0
SELECT V_DESCTO
SEEK EMPRESA+V_FAC_LN.LF_PART
DO WHILE .NOT. EOF() .AND. DE_EMPR+DE_PART=EMPRESA+V_FAC_LN.LF_PART
    IF BETWEEN(V_FAC_HD.HF_FECHA,DE_FECHAI,DE_FECHAF)
      IF V_CLIENT.CL_CATEGO$DE_CATEGO .OR. DE_CATEGO=SPACE(25)
        DESCTO_IT=DE_DESCTO/100
      ENDIF
      EXIT  
    ENDIF
    SKIP
ENDDO   

SELECT V_FAC_LN 
IF LOCK()
    REPLACE LF_LISTA   WITH ROUND((V_ITEMS.IT_PRECIO-(V_ITEMS.IT_PRECIO*DESCTO_IT))*V_FAC_HD.HF_FACTOR,4)
    REPLACE LF_PRECIO  WITH ROUND((V_ITEMS.IT_PRECIO-(V_ITEMS.IT_PRECIO*DESCTO_IT))*V_FAC_HD.HF_FACTOR,4)
ENDIF
RETURN .T.

FUNCTION GET_TOT
*******************
MI_REC=RECNO()
SEEK V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO
SUM REST WHILE .NOT. EOF() .AND. V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO=LF_EMPR+'F'+LF_NRO ;
    LF_CANT*LF_PRECIO TO TOT_IMPORT
GO MI_REC

ACTIVATE SCREEN
CLEAR
@ 19,0 TO 24,79 DOUBLE COLOR G+/B
@ 22,55 SAY 'DSCTO Bs.='+TRANSFORM( ROUND(TOT_IMPORT*V_FAC_HD.HF_DSCTO_P/100,2) ,'9,999,999.99') 
@ 23,55 SAY 'TOTAL Bs.='+TRANSFORM(TOT_IMPORT-ROUND(TOT_IMPORT*V_FAC_HD.HF_DSCTO_P/100,2),'9,999,999.99') 
RETURN .T.


PROCEDURE MUESTRA_NR
*******************
SELECT V_DOC_HD
COPY TO (ARCH_NR) FOR HD_TIPO$'RN' .AND. hd_empr=empresa .and. hd_alm=alm .and. hd_cod_cl=cod_cl
select 0
use (arch_nr) alias nrs
set relation to hd_empr+hd_tipo+hd_nro into v_doc_ln

ON KEY LABEL SPACEBAR DO MARCA
ON KEY LABEL F10 KEYBOARD CHR(23)

@ 1,25 SAY '<--- F10 - PARA SALIR                 '
@ 2,25 SAY '<--- BARRA SPACIADORA PARA SELECCIONAR'
@ 21,46 SAY '                              '

ACTIVATE WINDOW W3
@ 0,1 SAY ' NR.    CODIGO        CANTIDAD      PESO'
@ 1,1 SAY '============================================='
@ 22,60 SAY "NRO. LINEAS:"

SELECT V_DOC_LN
BROWSE NOWAIT NOCLEAR FIELDS LD_PART:H='CODIGO', LD_CANT:H='CANT.',LD_PESO:H='PESO kg.' WINDOW W2 

SELECT NRS
BROWSE NOCLEAR FOR HD_COD_CL=COD_CL .AND. HD_ALM=ALM .AND. .NOT. HD_ESTADO$'FA' fields hd_nro:h='NRO.':R,hd_fecha:H='FECHA':R,hd_estado:H='E.' WINDOW W1

ACTIVATE SCREEN

@ 1,25 SAY '                                      '
@ 2,25 SAY '                                      '

ON KEY LABEL SPACEBAR
ON KEY LABEL F10

RETURN 

PROCEDURE MARCA
***************
set relation OFF into v_doc_ln
SELECT NRS
IF HD_ESTADO=' '
  REPLACE LP_ESTADO WITH CHR(251)
  select v_doc_ln
  SEEK NRS.hd_empr+NRS.hd_tipo+NRS.hd_nro

  DO WHILE .NOT. EOF() .AND. NRS.hd_empr+NRS.hd_tipo+NRS.hd_nro=LD_EMPR+LD_TIPO+LD_NRO
   SELECT FACT_LN
   APPEND BLANK
   REPLACE LF_TIPO WITH V_DOC_LN.LD_TIPO, ;
           LF_NRO  WITH V_DOC_LN.LD_NRO, LF_PART WITH V_DOC_LN.LD_PART, ;
           LF_CANT WITH V_DOC_LN.LD_CANT, LF_PESO WITH V_DOC_LN.LD_PESO
   SELECT V_DOC_LN
   SKIP
  ENDDO
ELSE
  REPLACE HD_ESTADO WITH ' '
  SELECT FACT_LN
  DELE FOR LF_TIPO+LF_NRO=NRS.HD_TIPO+NRS.HD_NRO
  PACK
ENDIF

CLEAR
SELECT FACT_LN
GO TOP
@ 0,1 SAY ' NR.    CODIGO        CANTIDAD      PESO'
@ 1,1 SAY '============================================='
@ 22,60 SAY "NRO. LINEAS:"

N=2
DO WHILE .NOT. EOF()
  @ N,1 SAY LF_NRO+' '+LF_PART+' '+TRANSFORM(LF_CANT,'999,999.99')+'  '+TRANSFORM(LF_PESO,'999,999.99') COLOR G+/B*
  N=N+1
  SKIP
ENDDO

SET ORDER TO 2
COUNT FOR LF_CANT<>0 TO L_NROS
@ 22,60 SAY "NRO. LINEAS:"
@ 22,73 SAY L_NROS PICTURE '99'
SET ORDER TO 1

SELECT NRS
set relation to hd_empr+hd_tipo+hd_nro into v_doc_ln
RETURN  


FUNCTION CHK_CLIE
*****************
PARAMETER CODIGO
SELECT V_CLIENT
SEEK EMPRESA+CODIGO
IF .NOT. EOF()
  RAZON=CL_RAZON
  RUC  =CL_RUC 
  @ 20,28 SAY '- '+CL_RAZON
  RETURN .T.
ELSE
  RETURN .F.
ENDIF    

FUNCTION GET_TC
***************
PARAMETER WFECHA
CURRENT=SELECT()
SELECT 0
USE V_TC ORDER FECHA
SEEK DTOS(WFECHA)
WTC=TC_MONTO
USE
SELECT (CURRENT)
RETURN WTC

PROCEDURE M
***********
  REPLACE LP_ESTADO WITH CHR(251)
RETURN