&../testcode/iotestlib.asm

.KEY $2002
.SP $FFFA

IMMP SP
STRP SP

:main
LDP stringP
LDO $00
BAZ main
INCP
STRP stringP
LDP SP
ADDIP $FFFA
STRO $04
LD curX
STRO $02
LD curY
STRO $03
CALL printChar
ADDIP $0006
STRP SP
IMM $08
ADS curX
JMP main

#data
:curX
$00
:curY
$00
:stringP
@string
:string
$54
$65
$20
$61
$6D
$6F
$20
$6D
$75
$63
$68
$6F
$2C
$20
$61
$6D
$6F
$72
$63
$69
$74
$61
$21
$00