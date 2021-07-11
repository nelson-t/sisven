set century on
set delete on
set safety on
set date french
set defa to d:\base_ven.99
use nentr in 1
use v_ne_hd ORDER HD_NRO in 2
sele 1
go top
do while not eof()
	cod=nentr.ne
	nro=nentr.NR
	SELE 2
	seek cod
	if found()
		replace v_ne_hd.hd_d_nro with NRO
	else
		wait window COD
	endif
	SELE 1
	IF NOT EOF()
		SKIP
	ENDIF
enddo