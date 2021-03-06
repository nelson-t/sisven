DO INICIO
CLOSE DATA

PUBLIC FAC
DEFINE WINDOW  PRIN FROM 0,0 TO 24,79
ACTIVATE WINDOW PRIN
DEFINE WINDOW MENU FROM 21,2 to 23,77
DO SETUP
DO TABLAS
DEFINE WINDOW  ALM01 FROM 08,35 TO 19,63
DEFINE WINDOW  ALM99 FROM 08,3 TO 19,33
DEFINE WINDOW ANULA_WI FROM 1,12 TO 4,60 DOUBLE TITLE 'NUMERO DE FACTURA?' && COLOR B/G,,B/G,B/G,N+/G 
ACTIVATE WINDOW ANULA_WI IN WINDOW PRIN
x=.t.
do while x
@ 0,2 SAY '   INTRODUZCA SU NUMERO DE FACTURA' 
FAC=SPACE(06)
@ 1,2 SAY '          FACTURA:' GET FAC PICTURE '!!!!!!' 
READ
sele 1
go top
locate for hd_factura=fac
if found()
	x=.f.
endif 
enddo
ACTIVATE WINDOW PRIN
DO WHILE LASTKEY()<>27
	DO SETUP
	DO MUESTRA01
	SELE 1
	BROW FIELDS HD_TIPO,HD_NRO,HD_ALM;
	FOR HD_ALM="99".AND. HD_FACTURA=ALLTRIM(FAC);
	WINDOW ALM99 TITLE 'ALMACEN 99' NOEDIT NOAPPEND COLOR SCHEME 10
ENDDO
RELEASE WINDOWS PRIN, ANULA_WI, ALM01, ALM99, MENU, CAMBIA_WI
CLOSE DATA
DELETE FILE (TEMP)+".DBF"
CLOSE DATA

RETURN

PROCEDURE TABLAS
****************
PUBLIC TEMP
TEMP=SYS(3)
CLOSE DATA
CREATE TABLE (TEMP);
(NRO C(6))
SELECT 1
USE V_DOC_HD
GO BOTT
SELECT 2
USE V_DOC_LN
SELECT 3
USE (TEMP) ALIAS TEMP
GO BOTT
RETURN

PROCEDURE INICIO
****************
SET DELE ON
SET TALK OFF
SET EXCLU OFF
SET EXACT OFF
SET CENTURY ON
SET DATE FRENCH
RETURN

PROCEDURE SETUP
***************
ON KEY LABEL F10 KEYBOARD CHR(23)
** 23 CTL+W SALVA CAMBIOS EN EL BROWSE**
ON KEY LABEL F2  DO ALM99 
ON KEY LABEL F3  DO ALM01 
ON KEY LABEL F4  DO VERIFICA
ON KEY LABEL F8  DO NUMERO
ACTIVATE WINDOW PRIN
ACTIVATE WINDOW MENU
CLEAR
@ 0,2 SAY '[F2]-ALM 99 [F3]-ALM 01 [F4]-VERIFICA [F8]-NUEVO NUMERO [Esc]-SALIR' COLOR GR+/B
RETURN

PROCEDURE MUESTRA01
*******************
SELE 3
BROW FIELDS NRO:H="NRO.REMISION" :V=ES_UNICO(NRO):E="NO EXISTE UNA NOTA DE REMISION CON ESE NUMERO O YA FUE FACTURADA";
WINDOW ALM01 TITLE 'ALMACEN 01' NOWAIT COLOR SCHEME 10
RETURN

PROCEDURE VERIFICA
******************
DEFINE WINDOW ITEM99 FROM 1,1 TO 23,39
DEFINE WINDOW ITEM01 FROM 1,40 TO 23,78
sw1=0
DO TOT01
DO TOT99
SELECT COUNT(*) FROM TEMP2 INTO CURSOR CANT2
SELECT COUNT(*) FROM TEMP4 INTO CURSOR CANT4
IF CANT2.CNT=CANT4.CNT .AND. CANT2.CNT<>0 .AND. CANT4.CNT<>0
	SELECT count(TEMP2.LD_PART);
	FROM TEMP2, TEMP4;
	WHERE TEMP4.LD_PART = TEMP2.LD_PART;
	   AND TEMP4.SUM_LD_CAN = temp2.sum_ld_cant;
	   INTO CURSOR QUERY
	if CANT2.cnt=query.cnt
		DEFINE WINDOW CAMBIA_WI FROM 8,20 TO 10,60 DOUBLE TITLE 'DESEA CAMBIAR LAS NOTAS ?' && COLOR B/G,,B/G,B/G,N+/G
		ACTIVATE WINDOW CAMBIA_WI
		SINO='N'
		@ 0,5 SAY '          (S/N):' GET SINO PICTURE '!' VALID SINO$'SN'
		READ
				sw1=1
		IF SINO='S'
				 DO REEMP01
				 DO REEMP99
				 DO TABLAS
				 wait window "Items reemplazados"	
		ENDIF
	ENDIF
ENDIF
IF SW1=0
		wait window "No corresponden los items"
		DO MUESTRA				
ENDIF
RETURN

PROCEDURE MUESTRA
*****************
DEFINE WINDOW  PANT2 FROM 0,0 TO 24,79 TITLE "PRESIONE F10 PARA SALIR"
ON KEY LABEL F10 KEYBOARD CHR(23) 
PUBLIC PRUEBA,P
prueba=SYS(3)
CREATE TABLE (prueba) (PART C(6), CANT N(10,2),PARTA C(6), CANTA N(10,2))
P=SELECT()
SELE (T4)
go top
DO WHILE NOT EOF((T2)) .AND. NOT EOF((T4))
	sele (P)
	APPEND BLANK
	REPLACE PART WITH TEMP2.LD_PART
	REPLACE CANT WITH TEMP2.SUM_LD_CAN
	REPLACE PARTA WITH TEMP4.LD_PART
	REPLACE CANTA WITH TEMP4.SUM_LD_CAN
	SELE (T2) 
	SKIP
	SELE (T4)
	SKIP
ENDDO

DO WHILE NOT EOF((t2)) 
	SELE (P)
	APPEND BLANK
	REPLACE PART WITH TEMP2.LD_PART
	REPLACE CANT WITH TEMP2.SUM_LD_CAN
	SELE (T2) 
	SKIP
ENDDO
DO WHILE NOT EOF((t4)) 
	SELE (P)
	APPEND BLANK
	REPLACE PRUEBA.PARTA WITH TEMP4.LD_PART
	REPLACE PRUEBA.CANTA WITH TEMP4.SUM_LD_CAN
	SELE (T4) 
	SKIP
ENDDO
sele (P)
go top
ACTIVATE WINDOW PANT2
BROW FIELD PART:H='PARTE EN 01',;
CANT:H='CANTIDAD EN 01',;
PARTA:H='PARTE EN 99',;
CANTA:H='CANTIDAD EN 99';
NOEDIT NOAPPEND COLOR SCHEME 10
DEACTIVATE WINDOW PANT2
********
close data
DELETE FILE (PRUEBA)+".DBF"
DELETE FILE (TEMP)+".DBF"
DO TABLAS
RETURN

PROCEDURE REEMP01
*****************
	SELE 3
	USE (TEMP) ALIAS TEMP
	SELE 1 
	USE V_DOC_HD
	GO TOP
	DO WHILE NOT EOF()
		SELE 1
		LOCATE FOR V_DOC_HD.HD_NRO=TEMP.NRO .AND. HD_ALM="01"
		DO WHILE FOUND()
			REPLACE HD_FACTURA WITH FAC
			REPLACE HD_ESTADO WITH "F"
			REPLACE HD_MIGRA WITH " "
			CONTINUE
		ENDDO
		SELE 3
		IF NOT EOF()
			SKIP
		ENDIF
	ENDDO
RETURN

PROCEDURE REEMP99
*****************
SELE (T3)
	GO TOP
	DO WHILE NOT EOF()
		SELE 1
		LOCATE FOR (V_DOC_HD.HD_NRO=TEMP3.HD_NRO .AND. V_DOC_HD.HD_ALM="99")
		DO WHILE FOUND()
			REPLACE HD_FACTURA WITH " "
			REPLACE HD_ESTADO WITH " "
			REPLACE HD_MIGRA WITH " "
			CONTINUE
		ENDDO
		SELE (T3)
		IF NOT EOF()
			SKIP
		ENDIF
	ENDDO
RETURN


PROCEDURE TOT01
***************
PUBLIC T2
SELECT V_DOC_LN.LD_PART, SUM(V_DOC_LN.LD_CANT);
 FROM V_DOC_LN, TEMP;
 WHERE TEMP.NRO = V_DOC_LN.LD_NRO AND V_DOC_LN.LD_ALM="01";
 GROUP BY V_DOC_LN.LD_PART;
 INTO CURSOR TEMP2
 T2=SELECT()
RETURN

PROCEDURE TOT99
***************
PUBLIC T3,T4
SELECT V_DOC_HD.HD_NRO;
 FROM V_DOC_HD;
 WHERE V_DOC_HD.HD_FACTURA = FAC .AND. HD_ALM="99" .AND. HD_ESTADO<>"A";
 INTO CURSOR TEMP3
 T3=SELECT()
SELECT V_DOC_LN.LD_PART, SUM(V_DOC_LN.LD_CANT);
 FROM V_DOC_LN, TEMP3;
 WHERE TEMP3.HD_NRO = V_DOC_LN.LD_NRO AND V_DOC_LN.LD_ALM="99";
 GROUP BY V_DOC_LN.LD_PART;
 INTO CURSOR TEMP4
 T4=SELECT()
RETURN

PROCEDURE NUMERO
****************
close data
DELETE FILE (TEMP)+".DBF"
DO TABLAS
DEFINE WINDOW ANULA_WI FROM 1,12 TO 4,60 DOUBLE TITLE 'NUMERO DE FACTURA?' && COLOR B/G,,B/G,B/G,N+/G 
ACTIVATE WINDOW ANULA_WI IN WINDOW PRIN

x=.t.
do while x
@ 0,2 SAY '   INTRODUZCA SU NUMERO DE FACTURA' 
FAC=SPACE(06)
@ 1,2 SAY '          FACTURA:' GET FAC PICTURE '!!!!!!' 
READ
sele 1
go top
locate for hd_factura=fac
if found()
	x=.f.
endif 
enddo
RETURN

PROCEDURE ALM99
***************
SELE 1
BROW FIELDS HD_TIPO,HD_NRO,HD_ALM;
FOR HD_ALM="99".AND. HD_FACTURA=ALLTRIM(FAC);
WINDOW ALM99 TITLE 'ALMACEN 99' COLOR SCHEME 10
RETURN

PROCEDURE ALM01
***************
ON KEY LABEL F10 KEYBOARD CHR(23)
** 23 CTL+W SALVA CAMBIOS EN EL BROWSE**
ON KEY LABEL F4  KEYBOARD CHR(14) 
ON KEY LABEL F8  DO BORRA
ON KEY LABEL F11 KEYBOARD CHR(27)
ACTIVATE WINDOW MENU
clear
@ 0,4 SAY '    [F4]-ADICIONA REGISTRO   [F8]-BORRA REGISTRO     [F10]-SALIR' COLOR GR+/B
SELE 3
APPEND BLANK
BROW FIELDS NRO:H="NRO.REMISION" :V=ES_UNICO(NRO):E="NO EXISTE UNA NOTA DE REMISION CON ESE NUMERO O YA FUE FACTURADA";
WINDOW ALM01 TITLE 'ALMACEN 01'  COLOR SCHEME 10
DO SETUP
RETURN

FUNCTION ES_UNICO
*****************
	PARAMETER COD
	RESULT = .F.
	MI_REC = RECNO()
	SELE 1
	LOCATE FOR HD_NRO=TEMP.NRO .AND. HD_FACTURA=SPACE(6) .AND. HD_ALM="01" .AND. HD_ESTADO<>"F" .AND. HD_ESTADO<>"A" .AND. HD_ESTADO<>"F"
	DO WHILE FOUND()
	 RESULT=.T.
	 CONTINUE
	ENDDO
RETURN RESULT

PROCEDURE BORRA
***************
DEFINE WINDOW ANULA_WI FROM 12,20 TO 14,60 DOUBLE TITLE 'DESEA ANULAR LA NOTA ?' && COLOR B/G,,B/G,B/G,N+/G IN WINDOW _00s0qhga8
ACTIVATE WINDOW ANULA_WI
SINO='N'
@ 0,2 SAY '          (S/N):' GET SINO PICTURE '!' VALID SINO$'SN'
READ
IF SINO="S"
  DELETE 
  SKIP
  IF EOF()
    GO BOTT
  ENDIF
  RELEASE WINDOW ANULA_WI  
  KEYBOARD CHR(27)
ELSE
  RELEASE WINDOW ANULA_WI  
ENDIF
RETURN
