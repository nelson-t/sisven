clear all
close all
use v_tc order fecha

DEFINE WINDOW tc_win ;
		FROM INT((SROW()-22)/2),INT((SCOL()-50)/2) ;
		TO INT((SROW()-22)/2)+21,INT((SCOL()-50)/2)+49 ;
		TITLE "TIPOS DE CAMBIO" ;
		NOFLOAT ;
		NOCLOSE ;
		SHADOW ;
		COLOR SCHEME 1

ACTIVATE WINDOW tc_win

@ 0,3 TO 19,23

@ 3,33 GET OPCION ;
	PICTURE "@*VN AUMENTAR;EDITAR;BUSCAR;BORRAR" ;
	SIZE 1,10,1 ;
	DEFAULT 1 

@ 11,36 GET OK ;
	PICTURE "@*HT OK" ;
	SIZE 1,4,1 ;
	DEFAULT 1

DEFINE WINDOW EN_TC FROM 0,3 TO 19,23 in WINDOW TC_Win

BROW FIELDS TC_FECHA,TC_MONTO window en_tc noclear NODELETE


read cycle

RELEASE WINDOW tc_win


IF USED("v_tc")
	SELECT v_tc
	USE
ENDIF


