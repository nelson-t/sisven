totpeso=0
totcant=0
SELECT 1
USE nrs   && Notas de Remision
SELECT 2
USE datos
SELECT nrs
DO WHILE !EOF()
 nro=ld_nro
 item=ld_part
 SELECT datos
 SUM ld_cant FOR hd_d_nro=nro .AND. hd_
 SUM ld_peso FOR 

ENDDO