

.SP $FFFA
.KEY $2002
IMM $F0
STR ITLchar
JMP testlab

:ITLloop2
IMM $1C
STR ITLchar

:testlab
CMPI $F0
BNE ITLnotbkey
STR KEY
JMP ITLloop2
:ITLnotbkey

CMPI $E0
BEQ ITLloop2
CMPI $E1
BEQ ITLloop2

CMPI $80
BGEU ITLloop2

CMPI $12
BEQ ITLshiftk
CMPI $59
BNE ITLnotshiftk
:ITLshiftk
IMM $01
STR ITLisshift
JMP ITLloop2
:ITLnotshiftk

CMPI $14
BNE ITLnotctrlk
IMM $01
STR ITLisctrl
JMP ITLloop2
:ITLnotctrlk

LD ITLisshift
BAZ ITLnotshift
LD ITLchar
IMMP ITLkeymapS
ADDAP
LDO $00
JMP ITLctrlhandle

:ITLnotshift
LD ITLchar
IMMP ITLkeymap
ADDAP
LDO $00

:ITLctrlhandle
STR ITLascii
LD ITLisctrl
BAZ ITLnotctrl
LD ITLascii
ANDI $1F
STR ITLascii

:ITLnotctrl
LD ITLascii

:ITLret
LDP SP
RET

#data
:ITLchar
$00
:ITLisshift
$00
:ITLisctrl
$00
:ITLascii
$00
:ITLkeymap
#00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$09
$60
$00

#10
$00
$1B
$00
$00
$00
$71
$31
$00
$00
$00
$7A
$73
$61
$77
$32

#20
$00
$63
$78
$64
$65
$34
$33
$00
$00
$20
$76
$66
$74
$72
$35
$00

#30
$00
$6E
$62
$68
$67
$79
$36
$00
$00
$00
$6D
$6A
$75
$37
$38
$00

#40
$00
$2C
$6B
$69
$6F
$30
$39
$00
$00
$2E
$2F
$6C
$3B
$70
$2D
$00

#50
$00
$00
$27
$00
$5B
$3D
$00
$00
$00
$00
$0D
$5D
$00
$5C
$00
$00

#60
$00
$00
$00
$00
$00
$00
$08
$00
$00
$00
$00
$1C
$00
$00
$00
$00

#70
$00
$00
$1F
$00
$1D
$1E
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00

:ITLkeymapS

#00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00
$09
$7E
$00

#10
$00
$1B
$00
$00
$00
$51
$21
$00
$00
$00
$5A
$53
$41
$57
$40

#20
$00
$43
$58
$44
$45
$24
$23
$00
$00
$20
$56
$46
$54
$52
$25
$00

#30
$00
$4E
$42
$48
$47
$59
$5E
$00
$00
$00
$4D
$4A
$55
$26
$2A
$00

#40
$00
$3C
$4B
$49
$4F
$29
$28
$00
$00
$3E
$3F
$4C
$3A
$50
$5F
$00

#50
$00
$00
$22
$00
$7B
$2B
$00
$00
$00
$00
$0D
$7D
$00
$7C
$00
$00

#60
$00
$00
$00
$00
$00
$00
$08
$00
$00
$00
$00
$1C
$00
$00
$00
$00

#70
$00
$00
$1F
$00
$1D
$1E
$00
$00
$00
$00
$00
$00
$00
$00
$00
$00