FUNCTION V_FECHA
****************
PARAMETER FECHA

DIA =day(fecha)
MES =month(fecha)
ANIO=year(fecha)
AMES="*"

DO CASE
	case MES=1
		AMES="ENERO"
	case MES=2
		AMES="FEBRERO"
	case MES=3
		AMES="MARZO"
	case MES=4
		AMES="ABRIL"
	case MES=5
		AMES="MAYO"
	case MES=6
		AMES="JUNIO"
	case MES=7
		AMES="JULIO"
	case MES=8
		AMES="AGOSTO"
	case MES=9
		AMES="SEPTIEMBRE"
	case MES=10
		AMES="OCTUBRE"
	case MES=11
		AMES="NOVIEMBRE"
	case MES=12
		AMES="DICIEMBRE"
ENDCASE		

RETURN ALLTRIM(str(DIA,2,0)+" DE "+AMES+" DEL "+str(ANIO,4,0))