PROCEDURE V_FACHTM
******************
PARAMETER OP, EMP, FACNUM, NUMDOS
SET DATE TO DMY

IF .NOT. V_GETDDOS(NUMDOS)
  RETURN
ENDI

*SE OBIENE COMO PUBLICAS ESTOS VALORES DE DOSIFICACION:
*_ACTIVA,_DE_FECHA, _A_FECHA, _NRO_AUT
*_LLAVE,_RAZONSOC, _DE, _NIT, _SUCURSAL
*_DIRECCION1, _DIRECCION2, _DIRECCION3 
*_TEXTO_SIN, _TEXTO_453, _ACTIV_ECO1 
*_ACTIV_ECO2, _ACTIV_ECO3, _MENSAJE

IF OP="SI_SETUP"
  DO SETUP
ENDIF

PUBLIC _NFAC, _FFEC, _LTOT, _NITCL

TEMP_FILE='..\WEB\HTML\FACTURAS\'+'F_'+FACNUM+'.HTM'
LOGO_FILE='..\IMAGES\indumix.jpg'
QR_FILE='..\IMAGES\QRS\QR.jpg'

DO GENHTML

*! COPY &TEMP_FILE lpt1:
*MODI COMM (TEMP_FILE) NOEDIT

MENSAJE1='FACTURA NRO.:'+FACNUM+' HA SIDO IMPRESA'
MENSAJE2=''
DO V_MENSAJ.SPR

IF OP="SI_SETUP"
   CLOSE DATA
ENDIF
RETURN

PROCEDURE SETUP
***************
SELECT 1
USE V_FAC_HD ORDER  CORRE ALIAS HF
SELECT 2
USE V_FAC_LN ORDER  CORRE ALIAS LF
SELECT 3
USE V_ITEMS ORDER PART ALIAS IT
SELECT 4
USE V_CLIENT ORDER CODIGO ALIAS CL

SELECT HF
SET RELATION TO HF_EMPR+HF_COD_CL INTO CL

SELECT LF
SET RELATION TO LF_EMPR+"F"+LF_NRO INTO HF
SET RELATION TO LF_EMPR+LF_PART INTO IT ADDITIVE

SET FILTER TO LF_EMPR=EMP .AND. LF_NRO=FACNUM
GO TOP

SELECT LF
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

DO WHILE .NOT. EOF()

  _PART=LF.LF_PART
  _ITDE=ACENTOS(IT.IT_DESCR)
  _UNME=IT.IT_UNIDAD
  _CANT=TRANSFORM(LF.LF_CANT, formatBO)
  _PREC=TRANSFORM(LF.LF_PRECIO, formatBO)
  _SUTO=TRANSFORM(LF.LF_CANT*LF.LF_PRECIO, formatBO)
  _LTOT=_LTOT+(LF.LF_CANT*LF.LF_PRECIO)

  TEXT
    <tr>
	  <td> <<I>> </td>
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
    <tr><td><<I>></td><td colspan="6" style="text-align: center"><<REPLICATE("*",160)>></td></tr> 
  ENDTEXT

  FOR N=I+1 TO 35 STEP 1
  TEXT
    <tr><td><<N>></td><td></td><td></td><td></td><td></td><td></td><td></td></tr> 
  ENDTEXT
  ENDFOR
ENDIF
*
DO FACBOT
DO HTMLBOT

SET TEXTMERGE TO
RETURN

PROCEDURE HTMLTOP
*****************
TEXT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<script src="../JS/F_FORM.JS" type="text/javascript"></script>
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<title>FACTURAS</title>
<style type="text/css">
@media print {
@page { margin-top: 0; margin-bottom: 0;}
body {
	-webkit-print-color-adjust: exact; margin-top: 1.0cm;
}
}
body {
	font-family: Arial, Helvetica, sans-serif; font-size: x-small;
}
td {
	text-align: left;
}
th {
	text-align: center;
}
#mainTable {
	width: 1000px; 	background: #EAEAEA; margin: 0px auto;
}
#topTable {
	width: 100%; margin: 0px auto;
}
#topTable td {
	vertical-align: top;
}
#centerTable {
	width: 100%; margin: 0px auto; font-family: Arial, Helvetica, sans-serif; font-size: small;
}
#centerTable th {
	text-align: center; background: #CCCCCC; height: 1.0cm;
}
#centerTable td {
	height: 0.5cm; background: white;
}
#datosIzquierda {
	width: 100%; font-size: small;
}
#datosCentro {
	width: 100%;
}
#datosCentro td {
	text-align: center;
}
.textoResaltado {
	background-color: #CCCCCC; 	font-weight: bold; 	font-size: small;
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

_NFAC=str(val(HF.HF_NRO),6,0)
_COCL=HF.HF_COD_CL
_FFEC=HF.HF_FECHA
_NACL=ACENTOS(CL.CL_RAZON)
_NITCL=CL.CL_RUC

_DIRECCIO1=ACENTOS(_DIRECCIO1)
_DIRECCIO2=ACENTOS(_DIRECCIO2)
_DIRECCIO3=ACENTOS(_DIRECCIO3)

_ACTIV_EC1=ACENTOS(_ACTIV_EC1)
_ACTIV_EC2=ACENTOS(_ACTIV_EC2)
_ACTIV_EC3=ACENTOS(_ACTIV_EC3)

TEXT
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
				<td>
				<table id="datosIzquierda" cellpadding="3" cellspacing="0">
					<tr>
						<td>
						<img alt="INDUMIX" height="49" src="<<LOGO_FILE>>" width="182" /></td>
					</tr>
					<tr>
						<td>De: <<_DE>></td>
					</tr>
					<tr>
						<td><<_SUCURSAL>></td>
					</tr>
					<tr>
						<td><<_DIRECCIO1>></td>
					</tr>
					<tr>
						<td><<_DIRECCIO2>></td>
					</tr>
					<tr>
						<td><<_DIRECCIO3>></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td style="font-size: small">SANTA CRUZ,&nbsp; 01/01/2018</td>
					</tr>
					<tr>
						<td style="font-size: small">Se√±or(es):<<CL.CL_RAZON>></td>
					</tr>
				</table>
				</td>
				<td>
				<table id="datosCentro" cellpadding="3" cellspacing="0" style="font-size: small">
					<tr>
						<td style="font-size: medium; font-weight: bold">FACTURA</td>
					</tr>
					<tr>
						<td></td>
					</tr>
					<tr>
						<td>(ORIGINAL - CLIENTE)</td>
					</tr>
				</table>
				</td>
				<td>
				<table cellpadding="3" cellspacing="0" style="width: 100%; border-spacing: 0px">
					<tr class="textoResaltado">
						<td style="text-align: right;">NIT: </td>
						<td><<_NIT>></td>
					</tr>
					<tr class="textoResaltado">
						<td style="text-align: right;">FACTURA NO.: </td>
						<td><<HF.HF_NRO>></td>
					</tr>
					<tr class="textoResaltado">
						<td style="text-align: right;">AUTORIZACION NO.:</td>
						<td><<_NRO_AUT>></td>
					</tr>
					<tr>
						<td class="actividades" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td class="actividades" colspan="2"><<_ACTIV_EC1>></td>
					</tr>
					<tr>
						<td class="actividades" colspan="2"><<_ACTIV_EC2>></td>
					</tr>
					<tr>
						<td class="actividades" colspan="2"><<_ACTIV_EC3>></td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
		<table id="centerTable">
			<colgroup>
				<col span="1" style="width: 2%;" />
				<col span="1" style="width: 20%;" />
				<col span="1" style="width: 33%;" />
				<col span="1" style="width: 5%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 10%;" />
				<col span="1" style="width: 20%;" />
			</colgroup>
			<tr>
				<th>#</th>
				<th>CODIGO</th>
				<th>DESCRIPCION</th>
				<th>U/M</th>
				<th>CANTIDAD</th>
				<th>PRECIO</th>
				<th>TOTAL</th>
			</tr>
ENDTEXT

RETURN

PROCEDURE FACBOT
****************
*SECCION INFERIOR/TOTALES DE LA FACTURA
SELECT LF
GO TOP

_TOTR=HF.hf_fletes+ HF.hf_embala+ HF.hf_otros
_TDES=ROUND((HF.hf_importe*HF.hf_dscto_p)/100,2)+HF.HF_DSCTO_M
_TFAC=HF.hf_importe-ROUND((HF.hf_importe*HF.hf_dscto_p)/100,2)-HF.hf_dscto_m+HF.HF_FLETES+HF.HF_EMBALA+HF.HF_OTROS
_LITE=V_LITE2(_TFAC)
_TEXTO_SIN=ACENTOS(_TEXTO_SIN)
_TEXTO_453=ACENTOS(_TEXTO_453)

SET DATE TO YMD
_FECHAF=STRTRAN(dtoc(_FFEC),"/", "")
SET DATE TO DMY

_CODCTRL=V_CODCTRL(ALLTRIM(_NRO_AUT), ALLTRIM(_NFAC), ALLTRIM(_NIT), _FECHAF, _TFAC, _LLAVE)

_TFAC=TRANSFORM(_TFAC, formatBO)

_CODQR=alltrim(_NIT)+"|"+alltrim(_NFAC)+"|"+alltrim(_NRO_AUT)+"|"+alltrim(dtoc(_FFEC))+"|"+alltrim(_TFAC)+"|"+alltrim(_TFAC)+"|"+alltrim(_CODCTRL)+"|"+alltrim(_NITCL)+"|"+;
       alltrim("0")+"|"+alltrim("0")+"|"+alltrim("0")+"|"+alltrim("0")

_TOTR=TRANSFORM(_TOTR, formatBO)
_TDES=TRANSFORM(_TDES, formatBO)
_TFAC=TRANSFORM(_TFAC, formatBO)
_LTOT=TRANSFORM(_LTOT, formatBO)

TEXT
            <tr>
				<td colspan="6" style="text-align: right">SUBTOTAL:</td>
				<td class="num"><<_LTOT>></td>
			</tr>
			<tr>
				<td colspan="6" style="text-align: right">FLETES+EMBALAJES+OTROS:</td>
				<td class="num"><<_TOTR>></td>
			</tr>
			<tr>
				<td colspan="6" style="text-align: right">DESCUENTOS:</td>
				<td class="num"><<_TDES>></td>
			</tr>
			
			<tr style="font-weight: bold">
				<td colspan="6" style="text-align: right">TOTAL:</td>
				<td class="num"><<_TFAC>></td>
			</tr>
			<tr style="vertical-align: top">
				<td colspan="7">SON:<<_LITE>></td>
			</tr>
			<tr style="vertical-align: top; font-size: medium">
				<td colspan="6"><br />
				Cod. Control: <<_CODCTRL>><br />
				<br />
				Fecha L√≠mite de Emisi√≥n: <<_A_FECHA>></td>
				<td style="text-align: center">
				<img alt="CODIGO QR" src="<<QR_FILE>>" /></td>
			</tr>
			<tr>
				<td colspan="7" style="text-align: center; font-weight: bold"><<_TEXTO_SIN>></td>
			</tr>
			<tr>
				<td colspan="7" style="text-align: center"><<_TEXTO_453>></td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</body>

</html>
			
ENDTEXT
RETURN

PROCEDURE HTMLBOT
*****************
TEXT
</body>
</html>
ENDTEXT
RETURN

FUNCTION ACENTOS
****************
PARAMETER STR1

STR1=STRTRAN(STR1,"•","&Ntilde;")
STR1=STRTRAN(STR1,"§","&ntilde;")
STR1=STRTRAN(STR1,"†","&aacute;")
STR1=STRTRAN(STR1,"Ç","&eacute;")
STR1=STRTRAN(STR1,"°","&iacute;")
STR1=STRTRAN(STR1,"¢","&oacute;")
STR1=STRTRAN(STR1,"£","&uacute;")

RETURN STR1

