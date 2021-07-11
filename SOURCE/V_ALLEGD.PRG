FUNCTION v_allegd
*****************
PARAMETER TMESSAGE, TKEY
*? "tMESSAGE="+tmessage
*? "tKEY="+tkey

SET LIBRARY TO sys(2004)+"FPATH.PLB" ADDITIVE 

STORE 0 TO i, x, y, index1, index2, nmen

STORE "" TO res

DIMENSION STATE(256)

FOR i=0 TO 255 STEP 1
  STATE(i+1)=i
ENDFOR

FOR i=0 TO 255 STEP 1
    index2= (asc(substr(TKEY,index1+1,1))+STATE(I+1)+index2)%256 
    TMP = STATE(i+1)
	STATE(i+1) = STATE(index2+1)
  	STATE(index2+1) = TMP
  	index1 = (Index1 +1) % LEN(TKEY)

ENDFOR 

FOR I=0 TO len(TMESSAGE)-1 STEP 1
	
	X=(X+1) % 256
	Y=(STATE(X+1)+Y)%256
    
    TMP=STATE(X+1)
	STATE(X+1) = STATE(Y+1)
	STATE(Y+1) = TMP
	
	TMP=(STATE(X+1)+STATE(Y+1)) % 256
			
	nmen=BXOR( ASC(substr(TMESSAGE,I+1,1)), STATE(TMP+1) )

	IF I=0
	 RES=right("0"+v_dex2hx(nmen,16),2)
	ELSE 
   	  RES=RES+right("0"+v_dex2hx(nmen,16),2)
    ENDIF
ENDFOR
SET LIBRARY TO

RETURN RES