*** INICIALIZA TABLAS DE TRANSACCIONES BORRANDO TODOS SUS REGISTROS
CLEAR

WAIT "TODOS LOS USUARIOS DEBEN SALIR... PRESIONE [ENTER] O [ESC]" WINDOW
IF LASTKEY()=27
  RETURN
ENDIF

@ 3,0 SAY "ESTE PROGRAMA BORRARA TODAS LAS TRANSACCIONES  ... CUIDADO!!!" 
@ 4,0 SAY "ES IMPORTANTE QUE OBTENGA UNA COPIA DE RESPALDO." 

WAIT "PRESIONE [ENTER] O [ESC]"
IF LASTKEY()=27
  RETURN
ENDIF

@ 7,0 SAY "INTRODUZCA LA SIGUIENTE PALABRA PARA SEGUIR 'ACEPTO'"
PALABRA=SPACE(10)

@ 9,0 SAY "-->"
@ 9,5 GET PALABRA
READ

PALABRA=ALLTRIM(PALABRA)

IF LASTKEY()=27 OR LEN(PALABRA)=0 OR 'ACEPTO'<>PALABRA
  WAIT "INCORRECTO... EL PROGRAMA NO CONTINUARA" TIMEOUT 2
  RETURN
ENDIF

ON ERROR DO errhand WITH ERROR(), MESSAGE()

SET EXCLU ON
SET TALK ON
CLOSE ALL

SELECT 1
USE V_TABLES ORDER DBF
******* IMPORTANTE
SET FILTER TO TB_ZERO
*******

DO WHILE .NOT. EOF()
  SELECT 2
  USE (v_tables.TB_DBF)
  ? "Procesando: "+v_tables.TB_DBF+" "+v_TABLES.TB_DSCR
  ZAP
  REINDEX
  USE

  SELECT 1 
  SKIP
ENDDO
WAIT 'PROCESO CONCLUIDO SATISFACTORIAMENTE ...PRESIONE [ENTER]' WINDOW 

ON ERROR
CLOSE ALL
SET EXCLU OFF
SET TALK OFF
CLEAR

PROCEDURE errhand
************************
PARAMETER errnum,message
SET TALK OFF
SET EXCLU OFF

CLEAR
@ 12,0 SAY 'SE ENCONTRO EL ERROR: '+message
@ 14,0 SAY '      TIPO DE ERROR : '+STR(Errnum)
@ 16,0
WAIT "PRESIONE [ENTER]" 

RETURN TO MASTER