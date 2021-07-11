******************
PROCEDURE V_RCAJA
******************
PARAMETER IMPRE

IF TYPE("EMPRESA")="U" OR TYPE("MI_EMPRESA")="U" OR TYPE("INI_GEST")="U"
  DO V_GETEMP
ENDIF

CLEAR
OPCION=1
EST_ARCH=SYS(3)
ARCH_IMPRE='..\TMP\'+EST_ARCH+'.TXT' 

TIPOREP='D'

DREC=0
DFAC=0
DRCR=0

MREC=0
MFAC=0

TREC=0
TFAC=0

DREC_U=0
DRCR_U=0
DFAC_U=0

MREC_U=0
MFAC_U=0

TREC_U=0
TFAC_U=0

MI_FECHA=DATE()

DO V_RCAJA.SPR
CLEAR

@ 12,10 SAY ' !!! ESPERE UN MOMENTO ....... REPORTE SE ESTA GENERANDO !!!  ' COLOR B*/GR

MI_MES=SUBSTR(DTOS(MI_FECHA),1,6)

IF OPCION=4 .OR. LASTKEY()=27
  CLEAR
  RETURN
ENDIF
  
SELECT 1
USE V_CLIENT ORDER CODIGO

SELECT 2
USE V_TC ORDER FECHA

SELECT 0
USE V_ESTCLI
COPY STRUC TO (EST_ARCH)
USE

SELECT 0
USE (EST_ARCH) ALIAS ESTADOS

SELECT 0
USE V_FAC_HD ORDER CORRE
SET RELATION TO DTOS(HF_FECHA) INTO V_TC

SET FILTER TO HF_EMPR=EMPRESA .AND. HF_TIPO='O'

DO WHILE .NOT. EOF() 

  IF HF_FECHA=MI_FECHA .AND. HF_ESTADO<>'A'
    DFAC  =DFAC+V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros 
    DFAC_U=DFAC_U+(V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros )/V_TC.TC_MONTO
  ENDIF

  IF SUBSTR(DTOS(HF_FECHA),1,6)=MI_MES .AND. HF_ESTADO<>'A'
    MFAC  =MFAC+V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros 
    MFAC_U=MFAC_U+(V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros )/V_TC.TC_MONTO
  ENDIF

  IF HF_FECHA<=MI_FECHA .AND. HF_ESTADO<>'A'
    TFAC  =TFAC+V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros 
    TFAC_U=TFAC_U+(V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros )/V_TC.TC_MONTO
  ENDIF

  IF HF_FECHA=MI_FECHA
    IF  HF_ESTADO<>'A' 
      SELECT ESTADOS
      APPEND BLANK
      IF LOCK()
        REPLACE TIPO WITH 'F.CO.'
        REPLACE OBS WITH V_FAC_HD.HF_NOM_CL
        REPLACE NRO WITH V_FAC_HD.HF_NRO
        REPLACE HABER WITH V_FAC_HD.hf_importe-V_FAC_HD.HF_DSCTO_M-ROUND(V_FAC_HD.hf_importe*(V_FAC_HD.HF_DSCTO_P/100),2)+V_FAC_HD.hf_fletes+V_FAC_HD.hf_embala+V_FAC_HD.hf_otros 
      ENDIF          
    ELSE
      SELECT ESTADOS
      APPEND BLANK
      IF LOCK()
        REPLACE TIPO WITH 'F.CO.'
        REPLACE OBS WITH V_FAC_HD.HF_OBS
        REPLACE NRO WITH V_FAC_HD.HF_NRO
        REPLACE HABER WITH 0  
      ENDIF          
    ENDIF
  ENDIF
  SELECT V_FAC_HD 
  SKIP
ENDDO

SELECT V_FAC_HD
********
* FACTURAS AL CONTADO
********
USE V_REC_HD ORDER CORRE
SET RELATION TO HR_EMPR+HR_COD_CL INTO V_CLIENT
SET RELATION TO DTOS(HR_FECHA) INTO V_TC ADDITIVE

SET FILTER TO HR_EMPR=EMPRESA .AND. hr_cod_cl='000000'

DO WHILE !EOF()

  IF HR_ESTADO<>'A' .AND. HR_FECHA=MI_FECHA
    DREC  =DREC+V_REC_HD.HR_TOT_BS 
    DREC_U=DREC_U+V_REC_HD.HR_TOT_BS/V_TC.TC_MONTO
  ENDIF

  IF HR_ESTADO<>'A' .AND. HR_FECHA<=MI_FECHA
    TREC  =TREC+V_REC_HD.HR_TOT_BS 
    TREC_U=TREC_U+V_REC_HD.HR_TOT_BS/V_TC.TC_MONTO
  ENDIF

  IF HR_ESTADO<>'A' .AND. SUBSTR(DTOS(HR_FECHA),1,6)=MI_MES
    MREC  =MREC+V_REC_HD.HR_TOT_BS 
    MREC_U=MREC_U+V_REC_HD.HR_TOT_BS/V_TC.TC_MONTO
  ENDIF

  IF HR_ESTADO<>'A' .AND. HR_FECHA=MI_FECHA
    SELECT ESTADOS
    APPEND BLANK
    IF LOCK()
      REPLACE TIPO  WITH 'RECO.'
      REPLACE OBS   WITH V_CLIENT.CL_RAZON
      REPLACE NRO   WITH V_REC_HD.HR_NRO
      REPLACE HABER WITH V_REC_HD.HR_TOT_BS
    ENDIF          
  ENDIF
  SELECT V_REC_HD
  SKIP
ENDDO
SELECT V_REC_HD
USE
********
* FACTURAS AL CREDITO
********
USE V_REC_HD ORDER CORRE
SET RELATION TO HR_EMPR+HR_COD_CL INTO V_CLIENT
SET RELATION TO DTOS(HR_FECHA) INTO V_TC ADDITIVE

SET FILTER TO HR_EMPR=EMPRESA .AND. hr_cod_cl<>'000000'

DO WHILE !EOF()

  IF HR_ESTADO<>'A' .AND. HR_FECHA=MI_FECHA
    DRCR  =DRCR+V_REC_HD.HR_TOT_BS 
    DRCR_U=DRCR_U+V_REC_HD.HR_TOT_BS/V_TC.TC_MONTO
  ENDIF

  IF HR_ESTADO<>'A' .AND. HR_FECHA<=MI_FECHA
    TREC  =TREC+V_REC_HD.HR_TOT_BS 
    TREC_U=TREC_U+V_REC_HD.HR_TOT_BS/V_TC.TC_MONTO
  ENDIF

  IF HR_ESTADO<>'A' .AND. SUBSTR(DTOS(HR_FECHA),1,6)=MI_MES
    MREC  =MREC+V_REC_HD.HR_TOT_BS 
    MREC_U=MREC_U+V_REC_HD.HR_TOT_BS/V_TC.TC_MONTO
  ENDIF

  IF HR_ESTADO<>'A' .AND. HR_FECHA=MI_FECHA
    SELECT ESTADOS
    APPEND BLANK
    IF LOCK()
      REPLACE TIPO  WITH 'RECR.'
      REPLACE OBS   WITH V_CLIENT.CL_RAZON
      REPLACE NRO   WITH V_REC_HD.HR_NRO
      REPLACE HABER WITH V_REC_HD.HR_TOT_BS
    ENDIF          
  ENDIF
  SELECT V_REC_HD
  SKIP
ENDDO

SELECT V_REC_HD
USE

SELECT ESTADOS
CLEAR

DEFINE WINDOW VER_CLIE FROM 0,0 TO 24,79 DOUBLE TITLE 'ESTADO DE CUENTA DEL CLIENTE - [ESC] PARA SALIR'

GO TOP
IF TIPOREP='D'
 DO CASE 
  CASE opcion=1   && Pantalla
    REPORT FORM V_RCAJA TO FILE (ARCH_IMPRE) for .NOT. (TIPO='R' .AND. haber=0)
    CLEAR
    ACTIVATE WINDOW VER_CLIE
    MODI COMM (ARCH_IMPRE) NOEDIT WINDOW VER_CLIE 
  CASE opcion=2   && Impresora de Red
    REPORT FORM V_RCAJA TO FILE (ARCH_IMPRE) for .NOT. (TIPO='R' .AND. haber=0)
    ! COPY &ARCH_IMPRE LPT1:
    clear
    @ 12,10 SAY ' !!! ESPERE UN MOMENTO ....... REPORTE SE ESTA GENERANDO !!!  ' COLOR B*/GR
    CLEAR
    do v_finpro.spr 
  CASE opcion=3
    REPORT FORM V_RCAJA TO FILE (ARCH_IMPRE) for .NOT. (TIPO='R' .AND. haber=0)
    titulos=SET("HEADING")
    SET HEADING OFF
    TYPE &ARCH_IMPRE TO PRINTER
    SET HEADING &titulos
    clear
    @ 12,10 SAY ' !!! ESPERE UN MOMENTO ....... REPORTE SE ESTA GENERANDO !!!  ' COLOR B*/GR
    CLEAR
    do v_finpro.spr 
  ENDCASE  
ELSE
  SET ALTERNATE TO (ARCH_IMPRE)
  SET ALTERNATE ON
  SET TEXTMERGE ON
 
  TEXT

     <<MI_EMPRESA>>
                             RESUMEN DE INGRESOS DE CAJA
                             =========================== 
 
                                     EN Bs.                EN US$
     DEL DIA : <<MI_FECHA>>
     ------------------------------------------------------------------------- 
     VENTAS AL CONTADO     :  <<F(DFAC)      >>        <<F(DFAC_U)       >>
     PAGOS RECIBIDOS       :  <<F(DREC)      >>        <<F(DREC_U)       >> 
                            --------------------------------------------------
     TOTAL INGRESOS DEL DIA:  <<F(DFAC+DREC) >>        <<F(DFAC_U+DREC_U)>>
     ========================================================================= 
          
     DEL MES: <<SUBSTR(DTOC(MI_FECHA),4,5)>>
     ------------------------------------------------------------------------- 
     VENTAS AL CONTADO     :  <<F(MFAC)      >>        <<F(MFAC_U)       >>
     PAGOS RECIBIDOS       :  <<F(MREC)      >>        <<F(MREC_U)       >> 
                            --------------------------------------------------
     TOTAL INGRESOS DEL MES:  <<F(MFAC+MREC) >>        <<F(MFAC_U+MREC_U)>>
     ========================================================================= 


     ACUMULADO AL: <<MI_FECHA>> 
     ------------------------------------------------------------------------- 
     VENTAS AL CONTADO     :  <<F(TFAC)      >>        <<F(TFAC_U)       >>
     PAGOS RECIBIDOS       :  <<F(TREC)      >>        <<F(TREC_U)       >> 
                            --------------------------------------------------
     INGRESOS ACUMULADOS   :  <<F(TFAC+TREC) >>        <<F(TFAC_U+TREC_U)>>
     ========================================================================= 
     
  ENDTEXT  
  SET ALTERNATE TO
  DO CASE 
   CASE opcion=1  && Pantalla
    MODI COMM  (ARCH_IMPRE) NOEDIT WINDOW VER_CLIE 
   CASE opcion=2
    ! COPY &ARCH_IMPRE lpt1:
    clear
    @ 12,10 SAY ' !!! ESPERE UN MOMENTO ....... REPORTE SE ESTA IMPRIMIENDO !!!  ' COLOR B*/GR
    CLEAR
    do v_finpro.spr 
   CASE opcion=3
    TYPE &ARCH_IMPRE TO PRINTER
    clear
    @ 12,10 SAY ' !!! ESPERE UN MOMENTO ....... REPORTE SE ESTA IMPRIMIENDO !!!  ' COLOR B*/GR
    CLEAR
    do v_finpro.spr 
  ENDCASE  
ENDIF  
RELEASE WINDOW VER_CLIE
WAIT "PROCESO CONCLUIDO...SALIENDO." TIMEOUT 2
CLOSE DATA
DELETE FILE (EST_ARCH+'.DBF') 
DELETE FILE (ARCH_IMPRE)

RETURN

FUNCTION F
**********
PARAMETER MONTO
RETURN TRANSFORM(MONTO,'999,999,999.99')