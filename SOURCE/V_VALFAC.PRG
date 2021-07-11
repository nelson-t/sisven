set escape on

SELECT 1
USE V_FAC_HD ORDER CORRE

SELECT 2
USE V_FAC_LN ORDER CORRE

SELECT 1
DO WHILE .NOT. EOF()
  tot_fac=v_fac_hd.hf_importe- HF_DSCTO_M- ROUND(hf_importe*(HF_DSCTO_P/100),2)    && + v_fac_hd.hf_fletes+ v_fac_hd.hf_embala+ v_fac_hd.hf_otros,0)
  SELECT V_FAC_LN
  SEEK V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO
  SUM (ROUND(lf_cant* lf_precio,2)-lf_desctos) rest while V_FAC_HD.HF_EMPR+'F'+V_FAC_HD.HF_NRO=lf_empr+'F'+lf_nro to tot_linea
  if tot_linea<>tot_fac
    ? v_fac_hd.hf_nro
    wait
  endif
  select v_fac_hd
  SKIP
ENDDO