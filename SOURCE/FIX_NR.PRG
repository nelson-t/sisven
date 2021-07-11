*** Verifica NE Planta vs. NE CD

* Cabeceras

*Select * from V:\BASE_VEN.99\v_DOC_hd where ;
       HD_FECHA < ctod("10/01/2000") AND HD_ALM='01' AND ;
       HD_EMPR+HD_TIPO+HD_ALM+HD_NRO NOT IN ;
       (SELECT HD_EMPR+HD_TIPO+HD_ALM+HD_NRO AS CODIGO ;
       FROM G:\ALMACEN\BASE_PT.99\v_DOC_hd)

*Select * from  G:\ALMACEN\BASE_PT.99\v_DOC_hd where ;
       HD_FECHA < ctod("10/01/2000") AND HD_ALM='01' AND ;
       HD_EMPR+HD_TIPO+HD_ALM+HD_NRO NOT IN ;
       (SELECT HD_EMPR+HD_TIPO+HD_ALM+HD_NRO AS CODIGO ;
       FROM V:\BASE_VEN.99\v_DOC_hd)       
       
* Lineas       

* Documentos en ventas y no en planta

Select * from V:\BASE_VEN.99\v_DOC_ln where ;
       LD_FECHA < ctod("10/01/2000") AND LD_ALM='01' AND ;
       LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part NOT IN ;
       (SELECT LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part AS CODIGO ;
       FROM O:\BASE_PT.99\v_DOC_LN)

* Documentos en planta y noe en ventas

Select * from  O:\BASE_PT.99\v_DOC_ln where ;
       LD_FECHA < ctod("10/01/2000") AND LD_ALM='01' AND ;
       LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part NOT IN ;
       (SELECT LD_EMPR+LD_TIPO+LD_ALM+LD_NRO+ld_part AS CODIGO ;
       FROM V:\BASE_VEN.99\v_DOC_ln)       
