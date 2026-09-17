&../lib/SD.s
&../lib/DBG.s

.SP $FFFA

IMMP SP
STRP SP
ADDIP $FFF8

CALL SDinit

IMM buffer
STRO $02
IMM ^buffer
STRO $03
IMM $00
STRO $04
STRO $06
STRO $07
IMM $02
STRO $05
CALL SDwrite

IMM debugstring
STRO $02
IMM ^debugstring
STRO $03
CALL SDread
CALL ITLdebug

:buffer
"Hola Amor! \"\\
I love you!"
+0200

