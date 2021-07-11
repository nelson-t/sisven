PUBLIC XCOD_AGRU

USE V_ITEMS

GO TOP

DO WHILE .NOT. EOF()
               
   DO CASE
      CASE IT_GRUPO = 'F'
         DO P_FILM
      
      CASE IT_GRUPO = 'A'
         DO P_ACRI
      
      CASE IT_GRUPO = 'P'
         DO P_POLI
      
      CASE IT_GRUPO = 'C'
         DO P_COND
      
      CASE IT_GRUPO = 'T'
         DO P_TUBE
      
      OTHERWISE
         DO P_OTRO
      
   ENDCASE

   *DISPLAY XCOD_AGRU OFF
   REPLACE IT_LINEA WITH XCOD_AGRU
   SKIP
   
ENDDO

CLOSE DATABASE


*--------------*
PROCEDURE P_FILM
*--------------*

STORE SPACE(1) TO X_S1
STORE SPACE(1) TO X_G2
STORE SPACE(2) TO XCOD_AGRU

X_S1 = SUBSTR ( IT_SERIE, 1, 1)
X_G2 = SUBSTR ( IT_GRUPO, 2, 1)

DO CASE
   CASE X_S1='1'.or.X_S1='4'.or.X_S1 ='5'
      DO CASE
         CASE X_G2 = 'F'
            XCOD_AGRU = '111'
            
         CASE X_G2 = 'B'
            XCOD_AGRU = '112'
 
         CASE X_G2 = 'C'
            XCOD_AGRU = '113'
 
         CASE X_G2 = 'R'
            XCOD_AGRU = '114'
 
         CASE X_G2 = 'L'
            XCOD_AGRU = '115'
      
      ENDCASE

   CASE X_S1='2'.or.X_S1='6'
      DO CASE
         CASE X_G2 = 'F'
            XCOD_AGRU = '121'
            
         CASE X_G2 = 'B'
            XCOD_AGRU = '122'
 
         CASE X_G2 = 'C'
            XCOD_AGRU = '123'
 
         CASE X_G2 = 'R'
            XCOD_AGRU = '124'
 
         CASE X_G2 = 'L'
            XCOD_AGRU = '125'

      ENDCASE

   CASE X_S1='3'.or.X_S1='7'.or.X_S1='8'.or.X_S1='9'
      XCOD_AGRU = '131'

   OTHERWISE
      XCOD_AGRU = '191'
      
ENDCASE

RETURN
******


*--------------*
PROCEDURE P_ACRI
*--------------*

STORE SPACE(2) TO XCOD_AGRU

XCOD_AGRU = '411'

RETURN
******


*--------------*
PROCEDURE P_POLI
*--------------*

STORE SPACE(2) TO XCOD_AGRU

XCOD_AGRU = '511'

RETURN
******


*--------------*
PROCEDURE P_COND
*--------------*

STORE SPACE(1) TO X_G2
STORE SPACE(1) TO X_G3
STORE SPACE(2) TO XCOD_AGRU

X_G2 = SUBSTR ( IT_GRUPO, 2, 1)
X_G3 = SUBSTR ( IT_GRUPO, 3, 1)

DO CASE
   CASE X_G2='T' .and. X_G3='W'
      XCOD_AGRU = '211'

   CASE X_G2='A' .and. X_G3='D'
      XCOD_AGRU = '212'
      
   CASE X_G2='T' .and. X_G3='M'
      XCOD_AGRU = '213'
      
   OTHERWISE
      XCOD_AGRU = '291'
      
ENDCASE

RETURN
******

*--------------*
PROCEDURE P_TUBE
*--------------*

STORE SPACE(1) TO X_G2
STORE SPACE(1) TO X_G3
STORE SPACE(2) TO XCOD_AGRU

X_G2 = SUBSTR ( IT_GRUPO, 2, 1)
X_G3 = SUBSTR ( IT_GRUPO, 3, 1)

DO CASE
   CASE X_G2='D' .and. X_G3='E'
      XCOD_AGRU = '311'

   CASE X_G2='C' .and. X_G3='D'
      XCOD_AGRU = '312'
      
   CASE X_G2='R' .and. X_G3='O'
      XCOD_AGRU = '313'

   CASE X_G2='C' .and. X_G3='A'
      XCOD_AGRU = '314'
      
   CASE X_G2='A' .and. X_G3='G'
      XCOD_AGRU = '315'
      
   CASE X_G2='P' .and. X_G3='O'
      XCOD_AGRU = '611'

   OTHERWISE
      XCOD_AGRU = '391'
      
ENDCASE

RETURN
******


*--------------*
PROCEDURE P_OTRO
*--------------*

STORE SPACE(2) TO XCOD_AGRU

XCOD_AGRU = '711'

RETURN
******
