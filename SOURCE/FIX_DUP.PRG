select ld_alm, ld_tipo, ld_nro, ld_part, count(*) as nums from v_doc_ln  group by ld_empr,ld_alm,ld_tipo,ld_nro,ld_part order by nums desc


