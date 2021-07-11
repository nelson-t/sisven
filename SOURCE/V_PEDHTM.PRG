PROCEDURE V_PEDHTM
******************
PARAMETER OP, EMP, PEDNUM, PEDCOT, COPIA, CIUDAD
*EJEMPLO PARAMETROS: "SI_SETUP", "1", "000005", "COTIZACION", "ORIGINAL", "SANTA CRUZ"

_PEDCOT=PEDCOT

SET DATE TO DMY

IF OP="SI_SETUP"
  DO SETUP
ENDIF

PUBLIC _NPED, _NFEC, _LTOT, _NITCL

TEMP_FILE='..\WEB\HTML\PEDS\'+'R_'+PEDNUM+'.HTM'
**LOGO FILE --> '..\IMAGES\logo.jpeg'

CONS_WAS=ALLTRIM(SYS(100))
SET CONSOLE OFF

**********
DO GENHTML
**********

IF CONS_WAS="ON"
  SET CONSOLE ON
ENDIF
******************* 
! CMD /C &TEMP_FILE
*******************
MENSAJE1='DOCUMENTO NRO.:'+PEDNUM+' HA SIDO GENERADO'
MENSAJE2=''
DO V_MENSAJ.SPR

IF OP="SI_SETUP"
   CLOSE DATA
ENDIF

RETURN

PROCEDURE SETUP
***************
*SOLO SE EJECUTA SI EL PARAMETRO OP="SI_SETUP"
SELECT 1
USE V_PED_HD ORDER CORRE
SELECT 2
USE V_PED_LN ORDER CORRE
SELECT 3
USE V_ITEMS ORDER PART 
SELECT 4
USE V_CLIENT ORDER CODIGO

SELECT V_PED_HD
SET RELATION TO HP_EMPR+HP_COD_CL INTO V_CLIENT
SEEK EMP+PEDNUM

SELECT V_PED_LN
SET RELATION TO LP_EMPR+LP_PART INTO V_ITEMS
SEEK EMP+PEDNUM

SELECT V_PED_LN
RETURN

PROCEDURE GENHTML
*****************
SET POINT TO ","
SET SEPARATOR TO "."
FORMATBO='99,999,999.99'
SET TEXTMERGE ON TO (TEMP_FILE)
*
DO HTMLTOP
DO DOCTOP
*
_LTOT=0
I=1

*LINEAS DOCUMENTO

SELECT V_PED_LN
DO WHILE .NOT. EOF() .AND. EMP+PEDNUM=LP_EMPR+LP_NRO
  _PART=ALLTRIM(V_PED_LN.LP_PART)
  _ITDE=ACENTOS(ALLTRIM(V_ITEMS.IT_DESCR))
  _UNME=ALLTRIM(V_ITEMS.IT_UNIDAD)
  _CANT=TRANSFORM(V_PED_LN.LP_CANT, formatBO)
  _PREC=TRANSFORM(V_PED_LN.LP_PRECIO, formatBO)
  _SUTO=TRANSFORM(V_PED_LN.LP_CANT*V_PED_LN.LP_PRECIO, formatBO)
  _LTOT=_LTOT+(V_PED_LN.LP_CANT*V_PED_LN.LP_PRECIO)
  
  TEXT
			<tr style="font-weight:normal">
		    	<td> <<_PART>> </td>
		      	<td> <<_ITDE>> </td>        
		      	<td> <<_UNME>> </td>         
		      	<td class="num"> <<_CANT>> </td>
		      	<td class="num"> <<_PREC>> </td>
		      	<td class="num"> <<_SUTO>> </td>	
		    </tr>

  ENDTEXT
  SKIP
  I=I+1
ENDDO

IF I<35
  TEXT
    <tr><td colspan="6" style="text-align: center"><<REPLICATE(" ",80)>></td></tr> 
  ENDTEXT

  FOR N=I+1 TO 35 STEP 1
  TEXT
    <tr><td> </td><td> </td><td> </td><td> </td><td> </td><td> </td></tr> 
  ENDTEXT
  ENDFOR
ENDIF
*
DO DOCBOT
DO HTMLBOT
*
SET TEXTMERGE TO
SET POINT TO "."
SET SEPARATOR TO ","
RETURN

PROCEDURE HTMLTOP
*****************
_NPED=ALLTRIM(str(val(V_PED_HD.HP_NRO),6,0))

TEXT

<!--A partir de aqui la parte superior HTML-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
<title>COTIZACION-PEDIDO_<<_NPED>></title>
<style type="text/css">
@media print {
@page { margin-top: 0; margin-bottom: 0;}
body {
	-webkit-print-color-adjust: exact; margin-top: 0.5cm;
}
}
body {
	font-size: x-small; font-family:Verdana;
}
td {
	text-align: left; height: 0.3cm;
}
th {
	text-align: center; height: 0.4cm;
    border: 1px solid black;
}
#mainTable {
	width: 95%; 	margin: 0px auto;
}
#topTable {
	width: 100%; margin: 0px auto;
}
#topTable td {
	vertical-align: top;
}
#centerTable {
	width: 100%; margin: 0px auto; 
}
#centerTable th {
	text-align: center; 
}
#datosIzquierda {
	width: 100%; font-size: x-small;
}
#datosCentro {
	width: 100%;
}
#datosCentro td {
	text-align: center;
}
.textoDerechaTop {
	font-weight: normal; 	font-size: x-small;
}
.actividades {
	text-align: center; font-size: xx-small;
}
.num {
	text-align: right;
}
.auto-style1 {
	font-weight: bold;
	font-size: large;
}
</style>
</head>

<body>

ENDTEXT
RETURN

PROCEDURE DOCTOP
*****************
*PARTE SUPERIOR DEL DOCUMENTO

_COCL=ALLTRIM(V_PED_HD.HP_COD_CL)
_NFEC=V_PED_HD.HP_FECHA
_NITCL=V_CLIENT.CL_RUC
_COD_CL=V_PED_HD.HP_COD_CL

_CL_RAZON=ACENTOS(ALLTRIM(V_CLIENT.CL_RAZON))
_CL_DIREC=ACENTOS(ALLTRIM(V_CLIENT.CL_DIREC))
_CL_FONOS=ACENTOS(ALLTRIM(V_CLIENT.CL_FONOS))
_OBS=ACENTOS(ALLTRIM(V_PED_HD.HP_OBS))


TEXT
<!--A partir de aqui la parte superior del documento-->
<input style="background-color:aqua" type="button" onclick="printDiv('printableDiv');" value="** IMPRIMIR DOCUMENTO **" />
<input style="background-color:aqua" type="button" onclick="window.close();" value="S A L I R" />
<hr>
<div id="printableDiv">
<table id="mainTable">
	<tr>
		<td>
		<table id="topTable">
			<colgroup>
				<col span="1" style="width: 35%;" />
				<col span="1" style="width: 30%;" />
				<col span="1" style="width: 35%;" />
			</colgroup>
			<tr>
ENDTEXT

* CON O SIN LOGO
IF CON_LOGO
   TEXT
				<td>
				<img src="../IMAGES/logo.jpeg" alt="LOGO" height="60" width="270" style="display:block;"/></td>
   ENDTEXT
ELSE
    TEXT
    			<td>
    			&nbsp;</td>
    ENDTEXT
ENDIF    

TEXT
				<td style="text-align:center; vertical-align:bottom" class="auto-style1">
				<<_PEDCOT>>
				</td>
				<td>
						<table style="width: 100%;">
							<col span="1" style="width: 60%;" />
							<col span="1" style="width: 40%;" />

							<tr>
								<td style="text-align:right">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td style="text-align:right; font-weight:bold; font-size:small">NRO.</td>
								<td style="font-size:small; font-weight:bold">: <<_NPED>> </td>
							</tr>
							<tr>
								<td style="text-align:right">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
						</table>
						</td>
			</tr>
			</table>
			<table style="width: 100%;">
			<colgroup>
				<col span="1" style="width: 45%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 45%;" />
			</colgroup>

			<tr style="vertical-align:top">
				<td>
				&nbsp;</td>
				<td style="text-align:center; font-weight:bold"> <<COPIA>></td>
				<td>
				&nbsp;</td>
			</tr>
			</table>
		<table style="width: 100%;">
			<colgroup>
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 50%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 30%;" />
			</colgroup>

			<tr>
				<td>Fecha</td>
				<td>:&nbsp;<<CIUDAD>>, <<V_FECHA(V_PED_HD.HP_FECHA)>></td>
				<td style="font-weight:bold">NIT/CI </td>
				<td style="font-weight:bold">:&nbsp;<<V_CLIENT.CL_RUC>></td>
			</tr>

			<tr>
				<td>NOMBRE</td>
				<td>: <<_CL_RAZON>></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>Cod. Cliente</td>
				<td>:&nbsp;<<V_CLIENT.CL_COD_CL>></td>
				<td>Tel&eacute;fonos</td>
				<td>:&nbsp;<<_CL_FONOS>></td>
			</tr>
			<tr>
				<td>Direcci&oacute;n</td>
				<td>:&nbsp;<<_CL_DIREC>></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>Observaciones</td>
				<td>:&nbsp;<<_OBS>></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
		</table>
				
		<table id="centerTable">
			<colgroup>
				<col span="1" style="width: 20%;" />
				<col span="1" style="width: 35%;" />
				<col span="1" style="width: 5%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 20%;" />
			</colgroup>
			<tr>
				<th>CODIGO</th>
				<th>DESCRIPCION</th>
				<th>UNI.</th>
				<th>CANTIDAD</th>
				<th>PRECIO</th>
				<th>TOTAL Bs.</th>
			</tr>

ENDTEXT
RETURN

PROCEDURE DOCBOT
****************
*SECCION INFERIOR/TOTALES DEL DOCUMENTO
SELECT V_PED_LN
GO TOP

_TOTR=V_PED_HD.HP_FLETES+ V_PED_HD.HP_EMBALA+ V_PED_HD.HP_otros
_TDES=ROUND((V_PED_HD.HP_importe*V_PED_HD.HP_dscto_p)/100,2)
_TPED=V_PED_HD.HP_importe-ROUND((V_PED_HD.HP_importe*V_PED_HD.HP_dscto_p)/100,2)+V_PED_HD.HP_FLETES+V_PED_HD.HP_EMBALA+V_PED_HD.HP_OTROS
_LITE=V_LITE(_TPED)

_TPED=TRANSFORM(_TPED, formatBO)
_TOTR=TRANSFORM(_TOTR, formatBO)
_TDES=TRANSFORM(_TDES, formatBO)
_LTOT=TRANSFORM(_LTOT, formatBO)

_FORMAP=V_PED_HD.HP_FORPAG
_TENTREGA=V_PED_HD.HP_TIENTR
_VOFERTA=V_PED_HD.HP_VALIDEZ
_LENTREGA=V_PED_HD.HP_LUGENT
_OTROSD=V_PED_HD.HP_OBS2

TEXT
<!--A partir de aqui la parte inferior del documento-->
			<tr>
				<td colspan="5" style="text-align: right; height: 17px; border-top: 1px solid black; border-collapse:collapse;">SUBTOTAL 
				Bs.:</td>
				<td class="num" style="height: 17px; border-top: 1px solid black; border-collapse:collapse;"><<_LTOT>></td>
			</tr>
			<tr>
				<td colspan="5" style="text-align: right">+FLETES+EMBALAJES+OTROS 
				Bs.:</td>
				<td class="num"><<_TOTR>></td>
			</tr>
			<tr>
				<td colspan="5" style="text-align: right">-DESCUENTOS Bs.:</td>
				<td class="num"><<_TDES>></td>
			</tr>
			
			<tr style="font-weight: bold">
				<td colspan="5" style="text-align: right">TOTAL Bs.:</td>
				<td class="num"><<_TPED>></td>
			</tr>
			<tr style="vertical-align: top;">
				<td colspan="6">SON: <<_LITE>> Bolivianos.</td>
			</tr>
			<tr style="vertical-align: top;">
			<td colspan="6">&nbsp;</td>
 			</tr>
			</table>
			
			<table id="centerTable">
			    <colgroup>
				<col span="1" style="width: 20%;" />
				<col span="1" style="width: 80%;" />
			    </colgroup>
    			<tr>
				<td class="num">FORMA DE PAGO:</td>
				<td><<_FORMAP>></td>
			</tr>

    			<tr>
				<td class="num">TIEMPO DE ENTREGA:</td>
				<td><<_TENTREGA>></td>
			</tr>


    			<tr>
				<td class="num">VALIDEZ DE LA OFERTA:</td>
				<td><<_VOFERTA>></td>
			</tr>


    			<tr>
				<td class="num">LUGAR DE ENTREGA:</td>
				<td><<_LENTREGA>></td>
			</tr>


    			<tr>
				<td class="num">OTROS DATOS:</td>
				<td><<_OTROSD>></td>
			</tr>


            </table>
		</td>
	</tr>
</table>
</div>

ENDTEXT
RETURN

PROCEDURE HTMLBOT
*****************
TEXT

<!--Desde aqui seccion final-->
<script type="text/javascript">

function printDiv(divName) {
	var printContents = document.getElementById(divName).innerHTML;
	var originalContents = document.body.innerHTML;
	document.body.innerHTML = printContents;
	window.print();
	document.body.innerHTML =originalContents;
}
					
</script>
</body>

</html>

ENDTEXT
RETURN

FUNCTION ACENTOS
****************
PARAMETER STR1

STR1=STRTRAN(STR1,"¥","&Ntilde;")
STR1=STRTRAN(STR1,"¤","&ntilde;")
STR1=STRTRAN(STR1," ","&aacute;")
STR1=STRTRAN(STR1,"‚","&eacute;")
STR1=STRTRAN(STR1,"¡","&iacute;")
STR1=STRTRAN(STR1,"¢","&oacute;")
STR1=STRTRAN(STR1,"£","&uacute;")
STR1=STRTRAN(STR1,"ý","2")
STR1=STRTRAN(STR1,"ø","o")
STR1=STRTRAN(STR1,"§","o")
RETURN STR1
