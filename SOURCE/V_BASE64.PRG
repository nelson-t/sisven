FUNCTION V_BASE64
*****************
PARAMETER BASE10num

value=BASE10num

*Implementacion de algoritmo que convierte cifras en base 10 a base 64, utilizando divisiones sucesivas adems de un
*diccionario de 64 caracteres. El diccionario a utilizarse para efectos del Cdigo de Control es:

STR64="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/"

QUOTIENT=1
REMAINDER=0
BASE64STR=""

DO WHILE QUOTIENT>0
  QUOTIENT = int(value/64)
  remainder= mod(value,64)
  BASE64STR=SUBSTR(STR64,REMAINDER+1,1)+BASE64STR
  value=QUOTIENT 
ENDDO

RETURN BASE64STR
