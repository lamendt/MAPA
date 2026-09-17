&../ROM/font.s
.KEY $2002

:PS2getChar
#gets next buffered char from raw PS2 codes using translation tables
#no modifiers and shift are both accounted for in tables
#ctrl just masks ascii output to <$20
#outputs slightly modified ASCII where the only change is arrow keys are $1c-$1f
#frame: 2
#rets: A=char 

:PS2loop2
STRP SP
PCURD KEY
STR PS2char

BAZ PS2ret

#Break codes
CMPI $F0
BNE PS2notbkey
:PS2stall
PCURD KEY
BAZ PS2stall
CMPI $12
BEQ PS2shiftkb
CMPI $59
BNE PS2notshiftkb
:PS2shiftkb
IMM $00
STR PS2isshift
JMP PS2loop2
:PS2notshiftkb
CMPI $14
BNE PS2notctrlkb
IMM $00
STR PS2isctrl
:PS2notctrlkb
JMP PS2loop2
:PS2notbkey

CMPI $E0
BEQ PS2loop2
CMPI $E1
BEQ PS2loop2

CMPI $80
BGEU PS2loop2

CMPI $12
BEQ PS2shiftk
CMPI $59
BNE PS2notshiftk
:PS2shiftk
IMM $01
STR PS2isshift
JMP PS2loop2
:PS2notshiftk

CMPI $14
BNE PS2notctrlk
IMM $01
STR PS2isctrl
JMP PS2loop2
:PS2notctrlk

LD PS2isshift
BAZ PS2notshift
LD PS2char
IMMP ROMkeymapS
ADDAP
LDO $00
JMP PS2ctrlhandle

:PS2notshift
LD PS2char
IMMP ROMkeymap
ADDAP
LDO $00

:PS2ctrlhandle
STR PS2ascii
LD PS2isctrl
BAZ PS2notctrl
LD PS2ascii
ANDI $1F
STR PS2ascii

:PS2notctrl
LD PS2ascii

:PS2ret
LDP SP
RET

#data
:PS2char
$00
:PS2isshift
$00
:PS2isctrl
$00
:PS2ascii
$00

