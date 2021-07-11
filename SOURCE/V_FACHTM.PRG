PROCEDURE V_FACHTM
******************
PARAMETER OP, EMP, FACNUM, NUMDOS, COPIA, CIUDAD

*"SI_SETUP", "1", "000003", 1, "ORIGINAL", "SANTA CRUZ"
SET DATE TO DMY

IF .NOT. V_GETDDO(NUMDOS, EMP)
   RETURN
ENDIF

*SE OBIENE COMO PUBLICAS ESTOS VALORES DE DOSIFICACION:
*_ACTIVA,_DE_FECHA, _A_FECHA, _NRO_AUT
*_LLAVE,_RAZONSOC, _DE, _NIT, _SUCURSAL
*_DIRECCION1, _DIRECCION2, _DIRECCION3 
*_TEXTO_SIN, _TEXTO_453, _ACTIV_ECO1 
*_ACTIV_ECO2, _ACTIV_ECO3, _MENSAJE

IF OP="SI_SETUP"
  DO SETUP
ENDIF

PUBLIC _NFAC, _FFEC, _LTOT, _NITCL, _CODQR

TEMP_FILE='..\WEB\HTML\FACTURAS\'+'F_'+FACNUM+'.HTM'
**LOGO FILE --> '..\IMAGES\logo.jpeg'
QR_FILE='..\IMAGES\QRS\QR.jpg'

CONS_WAS=ALLTRIM(SYS(100))
SET CONSOLE OFF
**********
DO GENHTML
**********
IF CONS_WAS="ON"
  SET CONSOLE ON
ENDIF

*! START &TEMP_FILE

! CMD /C &TEMP_FILE

MENSAJE1='FACTURA COMPUTARIZADA NRO.:'+FACNUM+' HA SIDO GENERADA'
MENSAJE2=''
DO V_MENSAJ.SPR

IF OP="SI_SETUP"
   CLOSE DATA
ENDIF

RETURN

PROCEDURE SETUP
***************
SELECT 1
USE V_FAC_HD ORDER  CORRE 
SELECT 2
USE V_FAC_LN ORDER  CORRE 
SELECT 3
USE V_ITEMS ORDER PART 
SELECT 4
USE V_CLIENT ORDER CODIGO

SELECT V_FAC_HD
SET RELATION TO HF_EMPR+HF_COD_CL INTO V_CLIENT
SEEK EMP+'F'+STR(NUMDOS,4)+FACNUM

SELECT V_FAC_LN
SET RELATION TO LF_EMPR+LF_PART INTO V_ITEMS
SEEK EMP+'F'+STR(NUMDOS,4)+FACNUM

SELECT V_FAC_LN
RETURN

PROCEDURE GENHTML
*****************
SET POINT TO ","
SET SEPARATOR TO "."
FORMATBO='99,999,999.99'
SET TEXTMERGE ON TO (TEMP_FILE)

DO HTMLTOP

DO FACTOP

_LTOT=0
I=1

SELECT V_FAC_LN
DO WHILE .NOT. EOF() .AND. EMP+str(NUMDOS,4)+FACNUM=LF_EMPR+STR(LF_NDOSIF,4)+LF_NRO

  _PART=ALLTRIM(V_FAC_LN.LF_PART)
  _ITDE=ACENTOS(ALLTRIM(V_ITEMS.IT_DESCR))
  _UNME=ALLTRIM(V_ITEMS.IT_UNIDAD)
  _CANT=TRANSFORM(V_FAC_LN.LF_CANT, formatBO)
  _PREC=TRANSFORM(V_FAC_LN.LF_PRECIO, formatBO)
  _SUTO=TRANSFORM(V_FAC_LN.LF_CANT*V_FAC_LN.LF_PRECIO, formatBO)
  _LTOT=_LTOT+(V_FAC_LN.LF_CANT*V_FAC_LN.LF_PRECIO)

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
DO FACBOT
DO HTMLBOT
SET TEXTMERGE TO
SET POINT TO "."
SET SEPARATOR TO ","
RETURN

PROCEDURE HTMLTOP
*****************
_NFAC=ALLTRIM(str(val(V_FAC_HD.HF_NRO),6,0))

TEXT
<!--A partir de aquí la parte superior HTML-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
<script type="text/javascript" src="..\..\JS\QRCode\jquery.min.js"></script>
<script type="text/javascript" src="..\..\JS\QRCode\qrcode.js"></script>
<title>FACTURA_<<_NFAC>></title>
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
</style>
</head>

<body>

ENDTEXT
RETURN

PROCEDURE FACTOP
*****************
*PARTE SUPERIOR DE LA FACTURA

_COCL=ALLTRIM(V_FAC_HD.HF_COD_CL)
_FFEC=V_FAC_HD.HF_FECHA
_NACL=ACENTOS(ALLTRIM(V_CLIENT.CL_RAZON))
_NRO_PED=V_FAC_HD.HF_PEDIDO
_NRO_NR=V_FAC_HD.HF_NR
_NOM_CL=ACENTOS(ALLTRIM(V_FAC_HD.HF_NOM_CL))
*_NITCL=V_CLIENT.CL_RUC
_NITCL=V_FAC_HD.HF_RUC
_COD_CL=V_FAC_HD.HF_COD_CL

_DIRECCIO1=ACENTOS(ALLTRIM(_DIRECCIO1))
_DIRECCIO2=ACENTOS(ALLTRIM(_DIRECCIO2))
_DIRECCIO3=ACENTOS(ALLTRIM(_DIRECCIO3))

_ACTIV_EC1=ACENTOS(ALLTRIM(_ACTIV_EC1))
_ACTIV_EC2=ACENTOS(ALLTRIM(_ACTIV_EC2))
_ACTIV_EC3=ACENTOS(ALLTRIM(_ACTIV_EC3))

TEXT
<!--A partir de aquí la parte superior de la factura-->
<input style="background-color:aqua" type="button" onclick="printDiv('printableDiv')" value="** IMPRIMIR FACTURA **" />
<input style="background-color:aqua" type="button" onclick="window.close()" value="S A L I R" />
<hr>
<div id="printableDiv">
<table id="mainTable">
	<tr>
		<td>
		<table id="topTable">
			<colgroup>
				<col span="1" style="width: 40%;" />
				<col span="1" style="width: 20%;" />
				<col span="1" style="width: 40%;" />
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
				<td style="font-size: x-large; font-weight: bold; text-align:center; vertical-align:bottom">FACTURA</td>
				<td>
						<table style="width: 100%;">
							<col span="1" style="width: 60%;" />
							<col span="1" style="width: 40%;" />

							<tr>
								<td style="text-align:right">NIT</td>
								<td>:<<_NIT>> </td>
							</tr>
							<tr>
								<td style="text-align:right; font-weight:bold; font-size:small">FACTURA No.</td>
								<td style="font-size:small; font-weight:bold">: <<_NFAC>> </td>
							</tr>
							<tr>
								<td style="text-align:right">AUTORIZACION No.</td>
								<td>:<<_NRO_AUT>></td>
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
				<table id="datosIzquierda" cellpadding="3" cellspacing="0">
					<tr>
						<td style="text-align:center">De: <<_DE>></td>
					</tr>
					<tr>
						<td style="text-align:center"><<_SUCURSAL>></td>
					</tr>
					<tr>
						<td style="text-align:center"><<_DIRECCIO1>></td>
					</tr>
					<tr>
						<td style="text-align:center"><<_DIRECCIO2>></td>
					</tr>
					<tr>
						<td style="text-align:center"><<_DIRECCIO3>></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
					</tr>
					</table>
				</td>
				<td style="text-align:center; font-weight:bold"><<COPIA>></td>
				<td>
				<table cellpadding="3" cellspacing="0" style="width: 100%; border-spacing: 0px">
					<tr>
						<td class="actividades">&nbsp;</td>
					</tr>
					<tr>
						<td class="actividades"><<_ACTIV_EC1>></td>
					</tr>
					<tr>
						<td class="actividades"><<_ACTIV_EC2>></td>
					</tr>
					<tr>
						<td class="actividades"><<_ACTIV_EC3>></td>
					</tr>
										
				</table>
				</td>
			</tr>
			</table>
		<table style="width: 100%;">
			<colgroup>
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 60%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 20%;" />
			</colgroup>

			<tr>
				<td>Fecha</td>
				<td>:&nbsp;<<CIUDAD>>, <<V_FECHA(V_FAC_HD.HF_FECHA)>></td>
				<td style="font-weight:bold">NIT/CI </td>
				<td style="font-weight:bold">:&nbsp;<<_NITCL>></td>
			</tr>

			<tr>
				<td>Nombre</td>
				<td>: <<_NOM_CL>></td>
				<td>Pedido</td>
				<td>:&nbsp;<<_NRO_PED>></td>
			</tr>
			<tr>
				<td>Cod. Cliente</td>
				<td>:&nbsp;<<_COD_CL>></td>
				<td>N.R.</td>
				<td>:&nbsp;<<_NRO_NR>></_NRO_NR></td>
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
				<th>Unid</th>
				<th>CANTIDAD</th>
				<th>PRECIO</th>
				<th>TOTAL Bs.</th>
			</tr>
ENDTEXT
RETURN

PROCEDURE FACBOT
****************
*SECCION INFERIOR/TOTALES DE LA FACTURA
SELECT V_FAC_LN
GO TOP

_TOTR=V_FAC_HD.hf_fletes+ V_FAC_HD.hf_embala+ V_FAC_HD.hf_otros
_TDES=ROUND((V_FAC_HD.hf_importe*V_FAC_HD.hf_dscto_p)/100,2)+V_FAC_HD.HF_DSCTO_M
_TFAC=V_FAC_HD.hf_importe-ROUND((V_FAC_HD.hf_importe*V_FAC_HD.hf_dscto_p)/100,2)-V_FAC_HD.hf_dscto_m+V_FAC_HD.HF_FLETES+V_FAC_HD.HF_EMBALA+V_FAC_HD.HF_OTROS
_LITE=V_LITE(_TFAC)
_TEXTO_SIN=ACENTOS(ALLTRIM(_TEXTO_SIN))
_TEXTO_453=ACENTOS(ALLTRIM(_TEXTO_453))

SET DATE TO YMD
_FECHAF=STRTRAN(dtoc(_FFEC),"/", "")
SET DATE TO DMY

_CODCTRL=V_CODCTR(ALLTRIM(_NRO_AUT), ALLTRIM(_NFAC), ALLTRIM(_NITCL), _FECHAF, _TFAC, _LLAVE)

_TFAC=TRANSFORM(_TFAC, formatBO)

_CODQR=alltrim(_NIT)+"|"+alltrim(_NFAC)+"|"+alltrim(_NRO_AUT)+"|"+alltrim(dtoc(_FFEC))+"|"+alltrim(_TFAC)+"|"+alltrim(_TFAC)+"|"+alltrim(_CODCTRL)+"|"+alltrim(_NITCL)+"|"+;
       alltrim("0")+"|"+alltrim("0")+"|"+alltrim("0")+"|"+alltrim("0")

_TOTR=TRANSFORM(_TOTR, formatBO)
_TDES=TRANSFORM(_TDES, formatBO)
_LTOT=TRANSFORM(_LTOT, formatBO)

TEXT
<!--A partir de aquí la parte inferior de la factura-->
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
				<td class="num"><<_TFAC>></td>
			</tr>
			<tr style="vertical-align: top;">
				<td colspan="6">SON: <<_LITE>> BOLIVIANOS</td>
			</tr>
			<tr style="vertical-align: top;">
				<td colspan="5"><br />
				Cod. Control: <<_CODCTRL>><br />
				Fecha L&iacute;mite de Emisi&oacute;n: <<_A_FECHA>><br />
				<br />
				<<_TEXTO_SIN>><br />
				Ley No. 453:<<_TEXTO_453>></td>
				<td><div id="qrcode" style="margin:auto; width:90px; height:90px;"></div></td>
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

<!--Desde seccion final-->
<script type="text/javascript">
var qrcode = new QRCode(document.getElementById("qrcode"), {
	width : 90,
	height : 90
});

function makeCode () {		
	var elText = "<<_CODQR>>";
	qrcode.makeCode(elText);
}

function printDiv(divName) {
	var printContents = document.getElementById(divName).innerHTML;
	var originalContents = document.body.innerHTML;
	document.body.innerHTML = printContents;
	window.print();
	document.body.innerHTML =originalContents;
}

makeCode();

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

