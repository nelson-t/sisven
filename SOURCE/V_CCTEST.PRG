SET DATE TO YMD
SET CENTURY ON
CLEAR

IF !FILE('..\TMP\testCTRL.txt') && Does file exist? 
	WAIT 'Cannot find TESTCTRL.TXT file' WINDOW NOWAIT
	RETURN
ENDIF

TESTfile = FOPEN('..\TMP\testCTRL.txt',0) && If so, open read

IF TESTfile < 0 && Check for error opening file
	WAIT 'Cannot open file' WINDOW NOWAIT
	RETURN
ENDIF

COUNT=0

? "FSEEK=",FSEEK(TESTfile, 0)
? "FEOF=", FEOF(TESTfile)

DO WHILE !FEOF(TESTfile) 
  CMD=FGETS(TESTfile)+FGETS(TESTfile)
  *SELECCIONA UN 10% del TOTAL
  IF INT(rand()*10)=1
    COUNT=COUNT+1
    &CMD
  ENDIF
ENDDO

? "COUNT=", COUNT

? "FCLOSE=", FCLOSE(TESTfile)

RETURN

FUNCTION getCod
***************
Parameters p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
p4=substr(p4,1,4)+substr(p4,6,2)+substr(p4,9,2)
p5=strtran(p5,",",".")
codigo=v_codctr(p1,p2,p3,p4,val(p5),p6)
*? p7, p8
*? p9, p10

? IIF(p11=codigo,"","**"), p11+"--->" 
IF p11<>codigo
  wait
ENDIF

Return codigo
