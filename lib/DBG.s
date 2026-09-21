&../lib/VGA.s
&../lib/PS2.s

:DBGprintStr
#prints out the string at DBGstring on a single line and waits until enter key is pressed
#frame: 2

ADDIP $FFFA
STRP SP
IMM $01
STR DBGx
IMM $08
STRO $02
CALL VGAclrScreen
:DBGlp
LDP DBGp
LDO $00
BAZ DBGwait
INCP
STRP DBGp
LDP SP
STRO $04
LD DBGx
STRO $02
LD DBGy
STRO $03
CALL VGAprintChar
IMM $08
ADS DBGx
JMP DBGlp
:DBGwait
LDP SP
CALL PS2getChar
CMPI $0D
BNE DBGwait
IMMP DBGstring
STRP DBGp
LDP SP
ADDIP $0006
RET

:DBGprintHex
ADDIP $FFFC
STR DBGtemp
CALL PRSbyteToHex
LDO $02
STR DBGstring 0000
LDO $03
STR DBGstring 0001
CALL DBGprintStr
IMM $00
STR DBGstring 0001
LD DBGtemp
ADDIP $0004
RET

:DBGp
@DBGstring
:DBGstring
+0200
:DBGx
$00
:DBGy
$00
:DBGtemp
$00

