CLOSE ALL
CLEAR ALL

SELECT 1
USE V_DOC_LN ORDER NR &&EMPRESA+TIPO+NRO+PART

SELECT 2
USE V_FAC_DO ORDER documento &&empr+tipo+alm+nro

SELECT 3
USE V_FAC_LN 
index on lf_empr+lf_nro+lf_part  to fact.tmp

select 1
set relation to ld_empr+ld_tipo+ld_alm+ld_nro into v_fac_do
SET RELATION TO ld_empr+v_fac_do.fa_nro+ld_part INTO V_fac_LN ADDITIVE

SUM LD_CANT,ROUND(LD_PESO,2),V_FAC_LN.LF_CANT,V_FAC_LN.LF_PESO for ld_tipo$'NR' .and. ld_estado='F' 
RETURN


define window w1 from 0,0 to 14,79 double
define window w2 from 15,0 to 19,79 double
define window w3 from 20,0 to 24,79 double


select 3
brow nowait window w3
select 2
brow nowait window w2
select 1
brow nowait window w1 for ld_tipo$'NR' .and. ld_estado='F' .AND. V_FAC_LN.LF_PART=SPACE(15)
