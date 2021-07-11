*..............................................................................
*   Function: DEC2BASX
*    Purpose:  Convert whole number 0-?, to base 2-16 
*
* Parameters: nTempNum - number to convert (0-9007199254740992)
*             base    - base to convert to i.e., 2 4 8 16...
*    returns: string
*      Usage:  cresult=Dec2BasX(nParm1, nParm2)
*              STORE Dec2BasX(255, 16) TO cMyString  &&... cMyString contains 'ff'
*..............................................................................
FUNCTION v_dex2hx
PARAMETERS nTempNum, nNewBase

STORE 0 TO nWorkVal,;
   remainder,;
      dividend,;
         nextnum,;
            digit

nWorkVal = nTempNum  
ret_str = ''

DO WHILE .T.
   digit = MOD(nWorkVal, nNewBase)
      dividend = nWorkVal / nNewBase
         nWorkVal = INT(dividend)

   DO CASE
         CASE digit = 10
                  ret_str = 'a' + ret_str
                        CASE digit = 11
                                 ret_str = 'b' + ret_str
                                       CASE digit = 12
                                                ret_str = 'c' + ret_str
                                                      CASE digit = 13
                                                               ret_str = 'd' + ret_str
                                                                     CASE digit = 14
                                                                              ret_str = 'e' + ret_str
                                                                                    CASE digit = 15
                                                                                             ret_str = 'f' + ret_str
                                                                                                   OTHERWISE
                                                                                                            ret_str = LTRIM(STR(digit)) + ret_str
                                                                                                               ENDCASE
                                                                                                               
                                                                                                                  IF nWorkVal = 0
                                                                                                                        EXIT
                                                                                                                           ENDIF ( nWorkVal = 0 )
                                                                                                                           ENDDO ( .T. )
RETURN ret_str
