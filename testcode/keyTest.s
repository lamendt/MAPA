&../lib/PS2.s
&../lib/VGA.s

.SP $FFFA

IMMP SP
STRP SP
ADDIP $FFF8

:main
CALL PS2getChar
BAZ main
CMPI $0D
BNE notNL
IMM $80
STRO $02
CALL VGAclrScreen
IMM $01
STR curX
JMP main
:notNL
STRO $04
LD curX
STRO $02
LD curY
STRO $03
CALL VGAprintChar
IMM $08
ADS curX
JMP main

#data
:curX
$01
:curY
$00