PROCEDURE V_PED_MU
******************
DEFINE PAD PREV  OF M_PEDIDO PROMPT '<-\<PREV'   AT 23,01 SKIP FOR BOF("V_PED_HD")
DEFINE PAD NEXT  OF M_PEDIDO PROMPT '\<SIG->'    AT 23,10 SKIP FOR EOF("V_PED_HD")
DEFINE PAD OJEAR OF M_PEDIDO PROMPT '\<OJEA'     AT 23,18
DEFINE PAD BUSCA OF M_PEDIDO PROMPT '\<BUSCA'    AT 23,25
DEFINE PAD MIRA  OF M_PEDIDO PROMPT '\<VERIF'    AT 23,33
DEFINE PAD INFO  OF M_PEDIDO PROMPT '\<INFO'     AT 23,41
DEFINE PAD ALTA  OF M_PEDIDO PROMPT '\<ALTA'     AT 23,48  
DEFINE PAD ANULA OF M_PEDIDO PROMPT 'AN\<UL'     AT 23,55  
DEFINE PAD IMPRE OF M_PEDIDO PROMPT 'OP\<CIONES' AT 23,62
DEFINE PAD SALE  OF M_PEDIDO PROMPT 'SA\<LE'     AT 23,73

*          1         2         3         4         5         6         7      
*01234567890123456789012345678901234567890123456789012345678901234567890123456789
*浜様様様曜様様様曜様様様僕様様様僕様様様僕様様曜様様様僕様様曜様様様様様僕様様融
*� <-PREV � SIG-> � OJEA � BUSCA � VERIF � INFO � ALTA � ANUL � OPCIONES � SALE �
*藩様様様擁様様様擁様様様瞥様様様瞥様様様瞥様様擁様様様瞥様様擁様様様様様瞥様様夕

ON SELECTION PAD PREV   OF M_PEDIDO DO PE_PREV
ON SELECTION PAD NEXT   OF M_PEDIDO DO PE_NEXT
ON SELECTION PAD OJEAR  OF M_PEDIDO DO PE_OJEAR
ON SELECTION PAD BUSCA  OF M_PEDIDO DO PE_BUSCA
ON SELECTION PAD MIRA   OF M_PEDIDO DO PE_MIRA
ON SELECTION PAD INFO   OF M_PEDIDO DO V_PE_INF.SPR
ON SELECTION PAD ALTA   OF M_PEDIDO DO V_PED_AL
ON SELECTION PAD ANULA  OF M_PEDIDO DO V_PED_AN
ON SELECTION PAD IMPRE  OF M_PEDIDO DO V_PED_OP
ON SELECTION PAD SALE   OF M_PEDIDO DO PE_SALE

RETURN