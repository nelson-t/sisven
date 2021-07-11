* Programa para calcular pesos del Doc. de Inventario
CLOSE ALL
SET DELETE ON
SET EXCLUSIVE OFF
SELECT 1
USE v_doc_ln 
SET FILTER TO ld_tipo='A' .and. ld_nro='900001'
SELECT 2
USE v_items ORDER 1
SELECT 1
GO TOP
DO WHILE !EOF()
 codigo=v_doc_ln.ld_part
 SELECT v_items
 SEEK '1'+codigo
 IF FOUND()
  *IF v_items.it_peso_t<>0
   REPLACE v_doc_ln.ld_peso WITH v_doc_ln.ld_cant*v_items.it_peso_t
  *ELSE
  * REPLACE v_doc_ln.ld_peso WITH v_doc_ln.ld_cant*v_items.it_peso_r
  *ENDIF 
 ELSE
  WAIT WINDOW "No se encuentra: "+CODIGO
 ENDIF
 SELECT 1
 SKIP
ENDDO
