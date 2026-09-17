&iotestlib.s

.SP $FFFA

IMMP SP
STRP SP
ADDIP $FFFA

IMM $30
STR debugstring
CALL ITLdebug

CALL SDinit

IMM $31
STR debugstring
CALL ITLdebug

IMM buffer
STRO $02
IMM ^buffer
STRO $03
#CALL SDwrite

IMM $32
STR debugstring
CALL ITLdebug

IMM debugstring
STRO $02
IMM ^debugstring
STRO $03
CALL SDread
CALL ITLdebug

IMM $33
STR debugstring
CALL ITLdebug

:main
CALL getChar
BAZ main
CMPI $0D
BNE notNL
IMM $80
STRO $02
CALL clearScreen
IMM $01
STR curX
JMP main
:notNL
STRO $04
LD curX
STRO $02
LD curY
STRO $03
CALL printChar
IMM $08
ADS curX
JMP main

#data
:curX
$01
:curY
$00

:buffer
"Hola Amor! \"\\"
+0200

