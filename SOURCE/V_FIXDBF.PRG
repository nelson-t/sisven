*
* I hereby release this source code as public domain, feel free to use
* it and change it as desired!
* 
* This is the 'no-frills' version of a program I wrote to combat the
* dreaded 'not a database file' that FoxPro throws at you from time
* to time when some idiot has gone and pressed the reset button or
* kicked the power cord when they shouldn't have.
* 
* This program fixes the error that seems to occur the majority of times,
* where the actual number of records doesn't match the number of records
* stored in the database header.
* 
* Most developers have an on error routine built into their applications,
* (well I hope you do).  One of the case statements on my error catcher
* routine is
* 
*     .
*     .
*     .
*   CASE errnum=15
*     close databases
*     do fix_dbf
*     quit
*     .
*     .
*     .
* 
* I quit from the program once the fix program has been run to prevent the
* program getting stuck in a loop if the error to the database file is not
* corrected.
* 
* KEN DISCLAIMER: While this program has worked perfectly for me for the
*                 last 12 months I cannot guarantee 100% safety of your
*                 databases.  USE AT YOUR OWN RISK!!!
* 
* As with all my programs the comments are minimal, (ie non-existent), but
* hey, good code doesn't need comments - it explains itself  :-)
*
* I'd welcome any comments or suggestions.  Drop me a line...
* 
* Ken Harrison
* Dunedin
* New Zealand
* 
* kenh@dunedin.es.co.nz
 
    
set talk off
dimension l1dbfs(1)
=adir(l1dbfs,'.\*.dbf')
l1err=.f.
clear
? 'Checking Database Files'
?
if alen(l1dbfs)<>1
  for l1dbf=1 to alen(l1dbfs)/5
    l1file=l1dbfs(l1dbf,1)
    ? right('          '+l1file,12)+'    ['
    store fopen(l1file,2) to l1mess
    store fseek(l1mess, 0, 2) to l1ndx_sz
    =fseek(l1mess,0)
    l1str=fread(l1mess,4)
    l1ass=readx(4)
    l1head=readx(2)
    l1rec=readx(2)
    l1actual=(l1ndx_sz-(l1head+1))/l1rec
    l1actual=iif(l1ndx_sz=l1head,0,l1actual)
    if l1actual<>l1ass
      l1err=.t.
      ?? 'X]'
      =fseek(l1mess,0)
      l1str=fread(l1mess,4)
      l1replace=right('00000000'+hex(l1actual),8)
      l1tmp=''
      for l1loop=1 to 4
        l1tmp=chr(dec(substr(l1replace,l1loop*2-1,2)))+l1tmp
      endfor
      =fwrite(l1mess,l1tmp)
    else
      ?? chr(251)+']'
    endif
    = fclose(l1mess)
  endfor
endif
?
? iif(l1err,'Errors Found!  Please Re-Index','All Databases appear okay')
return

Function Readx
parameter l1len
l1str=fread(l1mess,l1len)
l1tmp=''
for l1loop=1 to l1len
  l1tmp=right('00'+hex(asc(substr(l1str,l1loop,1))),2)+l1tmp
endfor
l1value=dec(l1tmp)
return l1value

Function Hex
parameters l1int
private l1loop,l1hex,l1str
l1str='0123456789ABCDEF'
l1hex=''
for l1loop=7 to 0 step -1
  l1part=int(l1int/(16^l1loop))
  l1hex=l1hex+substr(l1str,l1part+1,1)
  l1int=l1int-l1part*(16^l1loop)
endfor
do while left(l1hex,1)='0'.and.len(l1hex)>1
  l1hex=substr(l1hex,2)
enddo
return l1hex

Function Dec
parameters l1hex
private l1loop,l1int,l1str,l1ctr
l1str='0123456789ABCDEF'
l1int=0
for l1loop=len(l1hex)-1 to 0 step -1
  l1int=l1int+(16^l1loop)*(at(substr(l1hex,len(l1hex)-l1loop,1),l1str)-1)
endfor
return l1int

