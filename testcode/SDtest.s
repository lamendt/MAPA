&../lib/SD.s
&../lib/DBG.s
&../lib/PRS.s

.SP $FFFA

IMMP SP
STRP SP
ADDIP $FFF8

CALL SDinit

IMM buffer
STRO $06
IMM ^buffer
STRO $07
IMM $00
STRO $02
STRO $05
IMM $DA
STRO $03
IMM $01
STRO $04
CALL SDwrite

IMM $00
CALL DBGprintHex

IMM DBGstring
STRO $06
IMM ^DBGstring
STRO $07
CALL SDread

CALL DBGprintStr

:halt
JMP halt

:buffer
"Hola Amorcita! I love you!"
+0200

