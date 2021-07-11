SET PRINT OFF
SET ESCAPE OFF
CLEAR
CLOSE DATA
SET EXCLU OFF
SET DELE ON
SET DATE TO FRENCH
SET CONFIRM ON
SET TALK OFF

IF TYPE("EMPRESA")="U" OR TYPE("MI_EMPRESA")="U" ;
OR TYPE("INI_GEST")="U"
  DO V_GETEMP
ENDIF

FECHAI=INI_GEST
FECHAF=DATE()

SELECT 1
USE V_LINEAS ORDER LINEA

SELECT 2
USE V_ITEMS  ORDER PART
SET RELATION TO IT_EMPR+SUBSTR(IT_LINEA,1,2)+' ' INTO V_LINEAS

SELECT 3
USE V_DOC_LN ORDER kardex

MI_GLOSA=SPACE(30)
MI_GLOSA1=SPACE(30)

OPCION=1
ALM='  '

MI_EMPRESA=SPACE(30)

DO V_SALDOB.SPR

IF LASTKEY()=27 .OR. OPCION=3
 CLOSE DATA
 CLEAR 
 RETURN
ENDIF

SELECT V_DOC_LN
SET FILTER TO LD_EMPR=EMPRESA .AND. BETWEEN(LD_FECHA,FECHAI,FECHAF)

SELECT 6
USE V_SALDOS exclu
zap

DO LLENA_SALDO

SELECT V_SALDOS
index on sa_empr+sa_linea+sa_part to v_saldos
SET RELATION TO sa_EMPR+sa_PART INTO V_ITEMS

DO CASE
  CASE OPCION=1 .AND. LASTKEY()<>27
    REPORT FORM V_Balanc TO FILE V_BALANC.TXT FOR SA_ING<>0 .OR. SA_INV<>0 .OR. SA_DEV<>0 .OR. SA_TRA<>0 .OR. SA_SALE<>0 .OR. SA_OSALE<>0 .OR. SA_SALDO<>0
    REPORT FORM V_BalanK TO FILE V_BALANK.TXT FOR SA_ING<>0 .OR. SA_INV<>0 .OR. SA_DEV<>0 .OR. SA_TRA<>0 .OR. SA_SALE<>0 .OR. SA_OSALE<>0 .OR. SA_SALDO<>0
    DEFINE WINDOW VER_REP FROM 0,0 TO 24,79 DOUBLE TITLE '[ESC] - PARA SALIR'
    MODI COMM V_BALANC.TXT WINDOW VER_REP NOEDIT
    MODI COMM V_BALANK.TXT WINDOW VER_REP NOEDIT
    RELEASE WINDOW VER_REP    
  CASE OPCION=2 .AND. LASTKEY()<>27
    REPORT FORM V_Balanc TO FILE V_BALANC.TXT FOR SA_ING<>0 .OR. SA_INV<>0 .OR. SA_DEV<>0 .OR. SA_TRA<>0 .OR. SA_SALE<>0 .OR. SA_OSALE<>0 .OR. SA_SALDO<>0
    REPORT FORM V_BalanK TO FILE V_BALANK.TXT FOR SA_ING<>0 .OR. SA_INV<>0 .OR. SA_DEV<>0 .OR. SA_TRA<>0 .OR. SA_SALE<>0 .OR. SA_OSALE<>0 .OR. SA_SALDO<>0
    impre=' '
    clear
    @ 10,10 say 'IMPRIME REPORTE EN CANTIDADES ?:' GET IMPRE PICTURE '!'
    READ
    IF IMPRE='S'
      ! COPY ..\tmp\V_BALANC.TXT lpt1:
    ENDIF
    impre=' '
    clear
    @ 10,10 say 'IMPRIME REPORTE EN KILOGRAMOS ?:' GET IMPRE PICTURE '!'
    READ
    IF IMPRE='S'
      ! COPY ..\tmp\V_BALANK.TXT lpt1:
    ENDIF
  CASE OPCION=3 .OR. LASTKEY()=27
ENDCASE
CLEAR

CLOSE DATA

RETURN

FUNCTION GET_EMPR
*****************
PARAMETER EMPR
SELECT 0
USE V_EMPR ORDER EMPR
SEEK EMPR
IF EOF()
  USE
  RETURN .F.
ELSE
  MI_EMPRESA=EM_DESCR
  @ 8,37 SAY MI_EMPRESA
  USE
  RETURN .T.
ENDIF

FUNCTION GLOSA
**************
MI_GLOSA=V_LINEAS.LI_DESCR
RETURN ' '

FUNCTION GLOSA1
**************
SELECT V_ITEMS
SET RELATION TO IT_EMPR+SUBSTR(IT_LINEA,1,1)+'  ' INTO V_LINEAS
MI_GLOSA1=V_LINEAS.LI_DESCR
SET RELATION TO IT_EMPR+SUBSTR(IT_LINEA,1,2)+' ' INTO V_LINEAS
SELECT v_saldos
RETURN ' '

PROCEDURE LLENA_SALDO
*********************
SELECT V_ITEMS
SEEK EMPRESA
DO WHILE .NOT. EOF() .AND. IT_EMPR=EMPRESA
  STORE 0 TO TRA, TRAK, DEV, DEVK, INV, INVK, ING, INGK, SALE, SALEK, OSALE, OSALEK, SALDO, SALDOK
  DO get_saldo WITH EMPRESA, ALM, IT_PART
  SELECT V_SALDOS
  append blank
  replace sa_empr with empresa, ;
          sa_alm with alm, ;
          sa_part with v_items.it_part, ;
          sa_linea with v_items.it_linea, ;
          sa_fecha with fechaf, ;
          sa_inv with inv, ;
          sa_invk with invk, ;
          sa_ing with ing, ;
          sa_ingk with ingk, ;
          sa_sale with sale, ;
          sa_salek with salek, ;
          sa_osale with osale, ;
          sa_osalek with osalek, ;
          sa_tra with tra, ;
          sa_trak with trak, ;
          sa_dev with dev, ;
          sa_devk with devk, ;
          sa_saldo with inv+ing+tra+dev-sale-osale, ;
          sa_saldok with invk+ingk+trak+devk-salek-osalek
  SELECT V_ITEMS
  SKIP
ENDDO  
RETURN

FUNCTION get_saldo
******************
PARAMETER EMPRESA,ALM,PARTE
SALDO=0
SELECT V_DOC_LN
SEEK EMPRESA+PARTE
IF ALM<>'  ' .AND. .NOT. EOF()
  DO WHILE .NOT. EOF() .AND. LD_EMPR=EMPRESA .AND. LD_PART=PARTE
   IF LD_ALM=ALM 
     DO CASE
       CASE LD_INSAL='1'
         SALDO =SALDO +LD_CANT
         SALDOK=SALDOK+LD_PESO
         DO CASE
           CASE LD_TIPO='A'  && INVENTARIO
             INV =INV +LD_CANT
             INVK=INVK+LD_PESO
           CASE LD_TIPO='D'  && DEVOLUCION
             DEV =DEV +LD_CANT
             DEVK=DEVK+LD_PESO
           CASE LD_TIPO='T'  .AND. ALM<>'  '
             TRA =TRA +LD_CANT
             TRAK=TRAK+LD_PESO
           otherwise        && CASE LD_TIPO='I'  -- INGRESO A ALMACEN
             ING =ING +LD_CANT
             INGK=INGK+LD_PESO
         ENDCASE
       CASE LD_INSAL='2'
        SALDO=SALDO-LD_CANT
        SALDOK=SALDOK-LD_PESO
        DO CASE
           CASE LD_TIPO='A'  && INVENTARIO
             INV =INV -LD_CANT
             INVK=INVK-LD_PESO
           CASE LD_TIPO='R' .OR. LD_TIPO='N'   && VENTAS
             SALE =SALE +LD_CANT
             SALEK=SALEK+LD_PESO
           OTHERWISE  && VENTAS
             OSALE =OSALE +LD_CANT
             OSALEK=OSALEK+LD_PESO
        ENDCASE
     ENDCASE 
   ENDIF
   SKIP
  ENDDO
  RETURN SALDO
ELSE
  DO WHILE .NOT. EOF() .AND. LD_EMPR=EMPRESA .AND. LD_PART=PARTE
    DO CASE
      CASE LD_INSAL='1'
         SALDO=SALDO+LD_CANT
         SALDOK=SALDOK+LD_PESO
         DO CASE
           CASE LD_TIPO='A'  && INVENTARIO
             INV =INV +LD_CANT
             INVK=INVK+LD_PESO
           CASE LD_TIPO='I'  && INGRESO A ALMACEN
             ING =ING +LD_CANT
             INGK=INGK+LD_PESO
           CASE LD_TIPO='T'  .AND. ALM<>'  '
             TRA =TRA +LD_CANT
             TRAK=TRAK+LD_PESO
           CASE LD_TIPO='D'  && DEVOLUCION
             DEV =DEV +LD_CANT
             DEVK=DEVK+LD_PESO
         ENDCASE
      CASE LD_INSAL='2'
        SALDO=SALDO-LD_CANT
        SALDOK=SALDOK-LD_PESO
        DO CASE
           CASE LD_TIPO='A'  && INVENTARIO
             INV =INV -LD_CANT
             INVK=INVK-LD_PESO
           CASE LD_TIPO='R' .OR. LD_TIPO='N'   && VENTAS
             SALE =SALE +LD_CANT
             SALEK=SALEK+LD_PESO
           OTHERWISE   && USO INT./PEDIDO MATERIAL
             OSALE =OSALE +LD_CANT
             OSALEK=OSALEK+LD_PESO
        ENDCASE
    ENDCASE 
    SKIP
  ENDDO
  RETURN SALDO
ENDIF  
