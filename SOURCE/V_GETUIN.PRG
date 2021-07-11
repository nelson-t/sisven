FUNCTION V_GETUIN
*****************
PARAMETER TINFO
*GET USER INFO

DATO='?'

DO CASE 
 CASE TINFO="U" && USER NAME
   DATO=GETUNAME()
 CASE TINFO="M" && MACHINE NAME
   DATO=SUBSTR(SYS(0),1,AT('#',SYS(0))-1)
ENDCASE
RETURN DATO

FUNCTION GETUNAME
*****************
NOMBRE="?"

TEMP_BAT='..\TMP\'+SYS(3)+'.BAT'
TEMP_TXT='..\TMP\'+SYS(3)+'.TXT'

fbat=FCREATE(TEMP_BAT)
=FPUTS(fbat,'echo off')
=FPUTS(fbat,'set arg1=%1')
=FPUTS(fbat,'echo %username% > %arg1%')
=FCLOSE(fbat)

! cmd HIDE /c &TEMP_BAT &TEMP_TXT

STORE seconds() TO T1, T2
DO WHILE T1+1>T2
  T2=seconds()
ENDDO

ftext=FOPEN(TEMP_TXT)
nombre=alltrim(FGETS(ftext))
=FCLOSE(ftext)

DELETE FILE (TEMP_BAT)
DELETE FILE (TEMP_TXT)

RETURN nombre
