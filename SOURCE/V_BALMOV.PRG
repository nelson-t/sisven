SET DECIMALS TO 4
SET DATE TO FRENCH

EMPRESA='1'

INI_GEST = {01/04/95}
FECHAI   = {01/08/95}
FECHAF   = {31/08/95}

MI_GLOSA=SPACE(30)
MI_GLOSA1=SPACE(30)

WLINEA='T  '

SELECT 1
USE V_ITEMS ORDER LINEA
SET FILTER TO IT_EMPR=EMPRESA .AND. IT_LINEA=ALLTRIM(WLINEA)

SELECT 2
USE V_DOC_LN ORDER KARDEX
SET FILTER TO LD_ESTADO<>'A' .AND. .NOT. LD_TIPO$'T' .AND. LD_COD_CL<>'000202'

SELECT 3
USE V_FAC_LN ORDER PART
SET FILTER TO LF_ESTADO<>'A' 

SELECT 4
USE V_LINEAS ORDER LINEA

ARCHI=SYS(3)

SELECT 5
USE V_BALANC
COPY STRUC TO (ARCHI)
USE (ARCHI) ALIAS BALANCE EXCLUSIVE

SELECT V_ITEMS
GO TOP
DO WHILE .NOT. EOF()
  SELECT BALANCE
  APPEND BLANK
  REPLACE EMPR  WITH V_ITEMS.IT_EMPR, ;
          PART  WITH V_ITEMS.IT_PART, ;
          LINEA WITH V_ITEMS.IT_LINEA
  ? 'CREANDO=>',PART
  SELECT V_ITEMS
  SKIP
ENDDO  

SELECT V_ITEMS
SET ORDER TO PART

SELECT BALANCE
GO TOP
DO WHILE .NOT. EOF()
  ? "CALCULANDO =>", PART
  DO PROC_DOC
  DO PROC_FAC
  SELECT BALANCE
  SKIP
ENDDO  

SET RELATION TO EMPR+PART INTO V_ITEMS
SET RELATION TO EMPR+SUBSTR(LINEA,1,2)+' ' INTO V_LINEAS ADDITIVE

REPORT FORM V_BALMOV FOR FLAG TO V_BALMOV.TXT

CLOSE DATA

DELE FILE (ARCHI+'.DBF')
RETURN

PROCEDURE PROC_DOC
******************
SELECT V_DOC_LN

LLAVE=BALANCE.EMPR+BALANCE.PART

STORE 0 TO SALINI, SALANT, INGPRO, OTRING, OTRSAL, WNRCRE, WNRCON, WNRCRSF
STORE 0 TO SALINIKG, SALANTKG, INGPROKG, OTRINGKG, OTRSALKG, WNRCREKG, WNRCONKG, WNRCRSFKG
WFLAG=.F.
SEEK LLAVE
DO WHILE .NOT. EOF() .AND. LD_EMPR+LD_PART=LLAVE
  WFLAG=.T.
  IF LD_INSAL='1'
    DO CASE
      CASE BETWEEN(LD_FECHA,FECHAI,FECHAF)
        DO CASE
          CASE LD_TIPO='A'
            SALANT=SALANT+LD_CANT
            SALANTKG=SALANTKG+LD_PESO
            SALINI=SALINI+LD_CANT
            SALINIKG=SALINIKG+LD_PESO
          CASE LD_TIPO='I'
            INGPRO=INGPRO+LD_CANT
            INGPROKG=INGPROKG+LD_PESO
          OTHERWISE
            OTRING=OTRING+LD_CANT
            OTRINGKG=OTRINGKG+LD_PESO
        ENDCASE 
      CASE LD_FECHA>=INI_GEST .AND. LD_FECHA<FECHAI
        SALANT=SALANT+LD_CANT
        SALANTKG=SALANTKG+LD_PESO
        SALINI=SALINI+LD_CANT
        SALINIKG=SALINIKG+LD_PESO
    ENDCASE
  ELSE
    DO CASE
      CASE BETWEEN(LD_FECHA,FECHAI,FECHAF)
        DO CASE
          CASE LD_TIPO='A'
            SALANT=SALANT-LD_CANT
            SALANTKG=SALANTKG-LD_PESO
            SALINI=SALINI-LD_CANT
            SALINIKG=SALINIKG-LD_PESO
          CASE LD_TIPO='R' .AND. LD_ESTADO=' '
            WNRCRSF=WNRCRSF+LD_CANT
            WNRCRSFKG=WNRCRSFKG+LD_PESO
          CASE LD_TIPO='R' .AND. LD_ESTADO='F'
            WNRCRE=WNRCRE+LD_CANT
            WNRCREKG=WNRCREKG+LD_PESO
          CASE LD_TIPO='N'
            WNRCON=WNRCON+LD_CANT
            WNRCONKG=WNRCONKG+LD_PESO
          OTHERWISE
            OTRSAL=OTRSAL+LD_CANT
            OTRSALKG=OTRSALKG+LD_PESO
        ENDCASE 
      CASE LD_FECHA>=INI_GEST .AND. LD_FECHA<FECHAI
        SALANT=SALANT-LD_CANT
        SALANTKG=SALANTKG-LD_PESO
        IF LD_TIPO='A'
          SALINI=SALINI-LD_CANT
          SALINIKG=SALINIKG-LD_PESO
        ENDIF
    ENDCASE
  ENDIF
  SKIP
ENDDO

SELECT BALANCE
REPLACE SAL_ANT WITH SALANT,  SAL_ANT_KG WITH SALANTKG, ;
        ING_PRO WITH INGPRO,  ING_PRO_KG WITH INGPROKG, ;
        OTR_ING WITH OTRING,  OTR_ING_KG WITH OTRINGKG, ;
        NR_CRE  WITH WNRCRE,  NR_CRE_KG  WITH WNRCREKG, ;
        NR_CON  WITH WNRCON,  NR_CON_KG  WITH WNRCONKG, ;
        NR_CRSF WITH WNRCRSF, NR_CRSF_KG WITH WNRCRSFKG, ;
        OTR_SAL WITH OTRSAL,  OTR_SAL_KG WITH OTRSALKG, ;
        SAL_INI WITH SALINI,  SAL_INI_KG WITH SALINIKG
        IF .NOT. FLAG
          REPLACE FLAG WITH WFLAG
        ENDIF
RETURN        


PROCEDURE PROC_FAC
******************
SELECT V_FAC_LN

LLAVE=BALANCE.EMPR+BALANCE.PART

STORE 0 TO WFACCRE, WFACCREKG, WFACCON, WFACCONKG, SALINI, SALINIKG
WFLAG=.F.
SEEK LLAVE
DO WHILE .NOT. EOF() .AND. LF_EMPR+LF_PART=LLAVE
  WFLAG=.T.
  DO CASE

    CASE LF_TIPO='R' .AND. BETWEEN(LF_FECHA,FECHAI,FECHAF)
      WFACCRE=WFACCRE+LF_CANT
      WFACCREKG=WFACCREKG+LF_PESO

    CASE LF_TIPO='O' .AND. BETWEEN(LF_FECHA,FECHAI,FECHAF)
      WFACCON=WFACCON+LF_CANT
      WFACCONKG=WFACCONKG+LF_PESO

    CASE LF_FECHA>=INI_GEST .AND. LF_FECHA<FECHAI
      SALINI=SALINI+LF_CANT
      SALINIKG=SALINIKG+LF_PESO

  ENDCASE
  SKIP
ENDDO

SELECT BALANCE
REPLACE FAC_CRE WITH WFACCRE, FAC_CRE_KG WITH WFACCREKG, ;
        FAC_CON WITH WFACCON, FAC_CON_KG WITH WFACCONKG, ;
        SAL_INI WITH SAL_INI-SALINI, ;
        SAL_INI_KG WITH SAL_INI_KG-SALINIKG
        IF .NOT. FLAG
          REPLACE FLAG WITH WFLAG
        ENDIF
RETURN        

FUNCTION GLOSA
**************
MI_GLOSA=V_LINEAS.LI_DESCR
RETURN ' '

FUNCTION GLOSA1
**************
SET RELATION OFF INTO V_LINEAS
SET RELATION TO EMPR+SUBSTR(LINEA,1,1)+'  ' INTO V_LINEAS ADDITIVE
MI_GLOSA1=V_LINEAS.LI_DESCR
SET RELATION OFF INTO V_LINEAS
SET RELATION TO EMPR+SUBSTR(LINEA,1,2)+' ' INTO V_LINEAS ADDITIVE
RETURN ' '
