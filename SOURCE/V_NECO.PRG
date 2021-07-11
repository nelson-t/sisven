USE v_ne_hd ORDER corre SHARED 
anterior=VAL(hd_nro)
WAIT WINDOW ALLTRIM(STR(anterior))
SKIP
DO WHILE !EOF()
 anterior=STR(hd_nro+1,6,0)
 IF anterior<>hd_nro
  WAIT WINDOW "Diferente"
 ENDIF
 SKIP
ENDDO