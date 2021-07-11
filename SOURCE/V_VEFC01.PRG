SET ESCAPE OFF

DO WHILE .T.
clear
SET TALK OFF
SET DELE ON
DO ON_KEYS

select 1
use v_clientes order codigo

cod_cl=space(8)
define window ver_cli from 3,5 to 22,75 double title "ELIJA CON [ENTER] - F5 PARA BUSCAR - [ESC] PARA SALIR"
define window bus_cli from 1,1 to 6,40  double title "BUSCAR CLIENTE"

on key label ENTER keyboard chr(23) 
on key label F5 do bus_cli

  browse window ver_cli fields cl_empr:h='EMPR',cl_cod_cl:h='CODIGO',cl_razon:h='RAZON SOCIAL' noedit NODELETE

on key label ENTER
on key label F5

release window ver_cli
release window bus_cli

IF LASTKEY()=27
  EXIT
ENDIF  

EMPR=CL_EMPR
cod_cl=cl_cod_cl
close data

DO VER_FAC WITH EMPR, COD_CL

ENDDO
return

PROCEDURE VER_FAC
*****************
PARAMETER WEMPR, WCOD_CL

SELECT 1
USE V_CLIENT ORDER CODIGO
SELECT 2
USE V_FAC_HD ORDER ESTADOS &&CORRE
&&SET FILTER TO HF_EMPR=WEMPR AND HF_COD_CL=WCOD_CL AND HF_TIPO='R'
SELECT 3
USE V_VENCFC ORDER CORRE

select V_FAC_HD
set relation to hf_empr+'F'+hf_nro into v_vencfc

SELECT V_CLIENT
SEEK WEMPR+WCOD_CL
RAZON=CL_RAZON
TOTf=0

@ 0,1 SAY "CLIENTE:"+WCOD_CL+'-'+RAZON color gr+/b
define window ver_fac from 1,2 to 10,77 double title "ELIJA CON [ENTER] - [ESC] PARA SALIR"
define window ver_VENC from 13,2 to 23,77 double title "VENCIMIENTOS - ENTRAR CON [F2]"

DO WHILE .T.
  SELECT V_VENCFC
  BROW FIELDS FECHA_V:H='FECHA',MONTO_V:H='MONTO VENCIMIENTO'  NOWAIT WINDOW VER_VENC

  SELECT V_FAC_HD
  on key label ENTER keyboard chr(23) 
  on key label f2 do MOD_VENC
  BROW KEY WEMPR+WCOD_CL FIELDS HF_NRO:H='NRO. FAC',HF_FECHA:H='FECHA',HF_OBS:20:H='OBSERVACIONES', IMPORTE=round((v_fac_hd.hf_importe-ROUND((v_fac_hd.hf_importe*v_fac_hd.hf_dscto_p)/100,2)-v_fac_hd.hf_dscto_m+V_FAC_HD.HF_FLETES+V_FAC_HD.HF_EMBALA+V_FAC_HD.HF_OTROS)/v_fac_hd.hf_factor,2):10:h='TOTAL US$'  ;
       when disp_fac() WINDOW VER_FAC

  IF LASTKEY() = 27
    EXIT
  ENDIF
ENDDO

on key label f2
on key label ENTER
MIREC=RECNO()

RELEASE VER_FAC
CLOSE DATA

RETURN


procedure bus_cli
*****************
activate window bus_cli
on key label ENTER
clear
cod=space(8)
nom=space(20)
@ 1,1 say 'DIGITE CODIGO :' get cod WHEN NOM=SPACE(20)
@ 2,1 say 'o RAZON SOCIAL:' get nom WHEN COD=SPACE(8) 
read

DO CASE
  CASE COD<>SPACE(8)
     locate for cl_cod_cl=alltrim(cod) 
  CASE NOM<>SPACE(20)
     locate for alltrim(upper(nom))$upper(cl_razon) 
ENDCASE  

hide window bus_cli
on key label ENTER keyboard chr(23) 
return

PROCEDURE ON_KEYS
*****************
DEACTIVATE MENU _SYSMENU
ON KEY LABEL F1 KEYBOARD ''
ON KEY LABEL F2 KEYBOARD ''
ON KEY LABEL F3 KEYBOARD ''
ON KEY LABEL F4 KEYBOARD ''
ON KEY LABEL F5 KEYBOARD ''
ON KEY LABEL F6 KEYBOARD ''
ON KEY LABEL F7 KEYBOARD ''
ON KEY LABEL F8 KEYBOARD ''
ON KEY LABEL F9 KEYBOARD ''
ON KEY LABEL F10 KEYBOARD ''
ON KEY LABEL F11 keyboard ''
ON KEY LABEL F12 keyboard ''
RETURN

PROCEDURE MOD_VENC
******************
on key label f2
on key label ENTER
on key label F4 do add_venc

define window MOD_VENC from 13,2 to 23,77 double title "[F4]-ADICIONA REGISTRO [F8]-BORRA [ESC]-SALIR"

SELECT 4
USE V_VENCFC ORDER CORRE AGAIN

TOTv=0

do sumven

seek V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO
if eof()
  do add_venc
endif

DO WHILE .T.
  BROW FIELDS FECHA_V:H='FECHA',MONTO_V:H='MONTO VENCIMIENTO':V=SUMVEN()  ;
       KEY V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO WINDOW MOD_VENC 
  IF LASTKEY() = 27 
    IF TOTf=TOTv
      EXIT
    ELSE
      WAIT 'TOTAL FACTURA CON TOTAL VENCIMIENTOS NO COINCIDE !!!' WINDOW
    ENDIF
  ENDIF
ENDDO

USE

release window mod_venc
activate screen
clear

@ 0,1 SAY "CLIENTE:"+WCOD_CL+'-'+RAZON color gr+/b

on key label ENTER keyboard chr(23) 
on key label f2 do MOD_VENC
ON KEY LABEL F4 KEYBOARD ''

KEYBOARD CHR(23)
return

procedure Add_venc
******************
append blank
replace hf_empr with v_fac_hd.hf_empr, ;
        hf_nro  with v_fac_hd.hf_nro, ;
        hf_tipo with v_fac_hd.hf_tipo
KEYBOARD CHR(23)        
return        

PROCEDURE SUMVEN
****************
SEEK V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO
TOTv=0
DO WHILE .NOT. EOF() .AND. HF_EMPR+HF_TIPO+HF_NRO=V_FAC_HD.HF_EMPR+V_FAC_HD.HF_TIPO+V_FAC_HD.HF_NRO
  TOTv=TOTv+MONTO_V  
  SKIP
ENDDO
@ 24,10 SAY "TOT. VENCIMIENTOS:"+TRANSFORM(TOTv,'999,999.99')+"       DIFERENCIA:"+TRANSFORM(TOTf-TOTv,'999,999.99')
RETURN .T.  

function disp_fac
*****************
TOTf=(v_fac_hd.hf_importe-ROUND((v_fac_hd.hf_importe*v_fac_hd.hf_dscto_p)/100,2)-v_fac_hd.hf_dscto_m+V_FAC_HD.HF_FLETES+V_FAC_HD.HF_EMBALA+V_FAC_HD.HF_OTROS)/v_fac_hd.hf_factor
@ 12,0 say "  FACTURA NRO.:"+v_fac_hd.hf_nro+"  "+DTOC(v_fac_hd.hf_FECHA)+"  OBS.:"+SUBSTR(v_fac_hd.hf_OBS,1,25)+"  US$"+TRANSFORM(TOTf,'999,999.99') COLOR GR+/B
return .t.