* PROGRAMA PARA REGISTRO DE NR DEL CD->PLANTA
SET CLOCK OFF
CLOSE ALL
CLEAR
STORE CTOD('') TO FECHAI,FECHAF
STORE 1 TO IMPRE,COPIAS

DO V_NR_CDP.SPR
IF IMPRE=2 .OR. LASTKEY()=27
   CLOSE ALL
   CLEAR
   RETURN   
ENDIF
ARCH=SYS(5)+SYS(3)+'.DBF'
SELECT 1
   USE V_CLIENT ORDER CODIGO
   WAIT WINDOW "SELECCIONANDO N.R.'s "+CHR(13)+"Por Favor Espere ..." NOWAIT
SELECT 2
   SELECT HD_EMPR,HD_TIPO,HD_NRO,HD_ALM,HD_FECHA,HD_COD_CL,HD_ESTADO FROM V_DOC_HD ;
   HAVING HD_FECHA>=FECHAI.AND.HD_FECHA<=FECHAF.AND.HD_TIPO='R'.AND. HD_ESTADO<>'A' ;
   INTO TABLE (ARCH)
   USE (ARCH) ALIAS NR
   SET RELATION TO HD_EMPR+HD_COD_CL INTO V_CLIENT
   ON KEY LABEL SPACEBAR DO MARCA
   ON KEY LABEL F10 DO IMPRE
   ON KEY LABEL ESC DO CANCELA
   ACTIVATE SCREEN
   CLEAR
   @ 19,10 SAY '� MARQUE CON LA BARRA ESPACIADORA LA N.R. QUE DESEA IMPRIMIR'
   @ 21,10 SAY '� PRESIONE [F10] PARA IMPRIMIR'
   @ 23,10 SAY '� PRESIONE [Esc] PARA CANCELAR'
   KEYBOARD '{LEFTARROW}'
   DEFINE WINDOW W1 FROM 1, 7 TO 17,73 DOUBLE TITLE 'NOTAS DE REMISION EMITIDAS DEL : '+DTOC(FECHAI)+' AL : '+DTOC(FECHAF)
   BROW FIELDS HD_NRO:H='NRO.':W=.F.,HD_ALM:H='ALM':W=.F.,HD_FECHA:H='FECHA':W=.F., ;
               HD_COD_CL:H='COD.CL.':W=.F., V_CLIENT.CL_RAZON:H='RAZON SOCIAL':W=.F.:30, ;
               HD_ESTADO:H='E':1 WINDOW W1 NOAPPEND NODELETE
ON KEY
IF LASTKEY()=27
   RELEASE WINDOW W1
   CLEAR
   CLOSE ALL
   RETURN
   SET CLOCK ON
ENDIF
RETURN

PROCEDURE MARCA
***************
  REPLACE HD_ESTADO WITH CHR(251)
RETURN      

PROCEDURE CANCELA
*****************
SELECT NR
USE
DELETE FILE (ARCH)
RELEASE WINDOW W1
CLEAR
CLOSE ALL
RETURN

PROCEDURE IMPRE
***************
COPIAS=1
ON KEY LABEL ESC KEYBOARD ''
DEFINE WINDOW IMPRE FROM 8,20 TO 17,60 TITLE "> Donde desea Imprimir ? <"
ACTIVATE WINDOW IMPRE
@ 1,14 GET DONDE ;
	PICTURE "@*RVN \<PANTALLA;\<SPOOL" ;
	SIZE 1,10,0 ;
	DEFAULT 1
@ 4,9 SAY 'NRO. DE COPIAS :' GET COPIAS PICTURE '9' VALID COPIAS>0
@ 6,5 GET OPCION ;
	PICTURE "@*HT \<ACEPTAR;\<CANCELAR" ;
	SIZE 1,13,1 ;
	DEFAULT 1 ;
	COLOR SCHEME 2	
READ CYCLE
IF LASTKEY()=27 .OR. OPCION=2
   RELEASE WINDOW IMPRE
   ON KEY LABEL ESC DO CANCELA
   RETURN
ENDIF 
RELEASE WINDOW IMPRE  
DO CASE
   CASE DONDE=1
     DEFINE WINDOW P FROM 0,0 TO 24,79 TITLE "> Presione [Esc] para Salir <"
     ON ESCAPE
     REPORT FORM V_NR_CDP FOR HD_ESTADO='�' TO FILE V_NR_CDP.TXT NOCONSOLE
     MODI COMM V_NR_CDP.TXT WINDOW P NOEDIT
     RELEASE WINDOW P     
   CASE DONDE=2
     REPORT FORM V_NR_CDP FOR HD_ESTADO='�' TO FILE V_NR_CDP.TXT NOCONSOLE
     FOR I=1 TO COPIAS
      !/0  COPY V:V_NR_CDP.TXT lpt1:
     ENDFOR
ENDCASE	
ON KEY LABEL ESC DO CANCELA
RETURN
