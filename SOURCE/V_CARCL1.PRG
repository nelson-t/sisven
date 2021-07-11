PROCEDURE V_CARCL1
******************
*CARTA PARA CLIENTE / DEUDA

PARAMETER DONDE     &&DONDE=1 PANTALLA  /  DONDE=2 IMPRESORA

save screen to mi_panta

ON KEY LABEL PGUP
ON KEY LABEL PGDN

MI_ARCH=SYS(3)+'.TXT'

IF DONDE=1
  SET TEXTMERGE ON
  SET TEXTMERGE TO (MI_ARCH)
ELSE
  SET TEXTMERGE ON SHOW
  SET PRINT  ON
  SET MARGIN TO 9
ENDIF  

WSALDOU=INI_US+FCR_US+CARGO_US-REC_US-ABONO_US
WDIAS=date()-ULT_FECHA
WCORRE=ALLTRIM(STR(VAL(ALLTRIM(CL_CORRESP))+1))


IF CL_TIPO='E'
\
\
\
\
\
\
\<<ALLTRIM(EMPCIUD)>>, <<fechatex(DATE())>> (<<SUBSTR(TIME(),1,5)>> hrs.)
\GC-<<ALLTRIM(cl_cod_cl)>>-<<Wcorre>>
\
\
\
\
\Se¤ores
\<<cl_razon>>
\<<cl_direc>>
\<<cl_ciudad>>
\
\
IF CL_MF='M'
  \Attn. Sr.
ELSE
  \Attn. Sra.
ENDIF    
\\ <<alltrim(alltrim(cl_titulo)+' '+cl_respo)>>
\
\
\
\Distinguidos Se¤ores:
\
\Tenemos a bien dirigirnos a ustedes para recordarles que tienen una 
\cuenta pendiente de pago con nuestra empresa de <<ALLTRIM(transform(WSALDOU,'999,999.99'))>> $us., 
\o su equivalente en bolivianos, al tipo de cambio oficial vigente el 
\d¡a en que se efectue el pago.
\
\Seg£n nuestros registros, su cuenta en <<alltrim(V_empr.em_descr)>> muestra 
\saldos pendientes de pago desde hace <<ALLTRIM(STR(WDIAS))>> d¡as, situaci¢n que no est  
\permitida por nuestra pol¡tica de cr‚ditos y que genera diariamente 
\intereses no programados.
\En consecuencia, le agradeceremos nos hagan llegar el pago por 
\el monto indicado antes del pr¢ximo <<fechatex(date()+15)>>.
\
\Nos ponemos a su entera disposici¢n para resolver alguna eventual 
\discrepancia entre sus registros y los nuestros.
\
\Con este motivo les saludamos muy atentamente,
\
\
\
\
\<<alltrim(V_empr.em_descr)>>
\
\
\
\
\
\
\
\cc.  File
\
ELSE
\
\
\
\
\
\
\<<ALLTRIM(EMPCIUD)>>, <<fechatex(DATE())>> (<<SUBSTR(TIME(),1,5)>> hrs.)
\GC-<<ALLTRIM(cl_cod_cl)>>-<<Wcorre>>
\
\
\
\
IF CL_MF='M'
  \Se¤or
ELSE
  \Se¤ora
ENDIF    
\<<alltrim(alltrim(cl_titulo)+' '+cl_respo)>>
\<<cl_direc>>
\<<cl_ciudad>>
\
\
\
\
IF CL_MF='M'
  \Distinguido Se¤or
ELSE
  \Distinguida Se¤ora
ENDIF    
\
\Tenemos a bien dirigirnos a usted para recordarle que tiene una 
\cuenta pendiente de pago con nuestra empresa de <<ALLTRIM(transform(WSALDOU,'999,999.99'))>> $us., 
\o su equivalente en Bolivianos, al tipo de cambio oficial vigente el 
\d¡a en que se efectue el pago.
\
\Seg£n nuestros registros, su cuenta en <<alltrim(V_empr.em_descr)>> muestra 
\saldos pendientes de pago desde hace <<ALLTRIM(STR(WDIAS))>> d¡as, situaci¢n que no est  
\permitida por nuestra pol¡tica de cr‚ditos y que genera diariamente 
\intereses no programados.
\En consecuencia, le agradeceremos nos hagan llegar el pago por 
\el monto indicado antes del pr¢ximo <<fechatex(date()+15)>>.
\
\Nos ponemos a su entera disposici¢n para resolver alguna eventual 
\discrepancia entre sus registros y los nuestros.
\
\Con este motivo les saludamos muy atentamente,
\
\
\
\
\<<alltrim(V_empr.em_descr)>>
\
\
\
\
\
\
\
\cc.  File
\
ENDIF

IF DONDE=1
  SET TEXTMERGE OFF
  SET TEXTMERGE TO
  DEFINE WINDOW WVER FROM 0,0 TO 24,79 TITLE 'ESC - PARA SALIR'
  MODI COMM (MI_ARCH) WINDOW WVER NOEDIT
  RELEASE WINDOW WVER
  DELE FILE (MI_ARCH)  
ELSE
  SET PRINT OFF
  SET TEXTMERGE OFF
  REPLACE v_client.CL_CORRESP WITH ALLTRIM(STR(VAL(V_CLIENT.CL_CORRESP)+1,3))
ENDIF

ON KEY LABEL PGUP DO CAMBIA_P1
ON KEY LABEL PGDN DO CAMBIA_P2
  
restore screen from mi_panta

RETURN



FUNCTION fechatex
*****************
PARAMETERS dfecha1
PRIVATE meses

mes=MONTH(dfecha1 )
DIMENSION meses[12]
meses[1] ="Enero"
meses[2] ="Febrero"
meses[3] ="Marzo"
meses[4] ="Abril"
meses[5] ="Mayo"
meses[6] ="Junio"
meses[7] ="Julio"
meses[8] ="Agosto"
meses[9] ="Septiembre"
meses[10]="Octubre"
meses[11]="Noviembre"
meses[12]="Diciembre"
RETURN alltrim((STR(DAY(dfecha1),2)+" de "+meses[mes]+" de ";
   +STR(YEAR(dfecha1),4)))
