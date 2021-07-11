*** Verifica NE Planta vs. NE CD

* Cabeceras

*Select * from V:\BASE_VEN.99\v_ne_hd where ;
       HD_FECHA < ctod("10/01/2000") AND ;
       HD_EMPR+HD_TIPO+HD_ALM+HD_NRO NOT IN ;
       (SELECT HD_EMPR+HD_TIPO+HD_ALM+HD_NRO AS CODIGO ;
       FROM G:\ALMACEN\BASE_PT.99\v_ne_hd)

*Select * from  G:\ALMACEN\BASE_PT.99\v_ne_hd where ;
       HD_FECHA < ctod("10/01/2000") AND ;
       HD_EMPR+HD_TIPO+HD_ALM+HD_NRO NOT IN ;
       (SELECT HD_EMPR+HD_TIPO+HD_ALM+HD_NRO AS CODIGO ;
       FROM V:\BASE_VEN.99\v_ne_hd)       
       
* Lineas       

* Select * from V:\BASE_VEN.99\v_ne_ln where ;
       LD_FECHA < ctod("10/01/2000") AND ;
       LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part NOT IN ;
       (SELECT LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part AS CODIGO ;
       FROM O:\BASE_PT.99\v_ne_LN)

* Select * from  O:\BASE_PT.99\v_ne_ln where ;
       LD_FECHA < ctod("10/01/2000") AND ;
       LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part NOT IN ;
       (SELECT LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part AS CODIGO ;
       FROM V:\BASE_VEN.99\v_ne_ln)       

Select * from v_ne_hd ;
	where hd_estado<>"A" and hd_nro not in (select distinct ld_nro from v_ne_ln)
