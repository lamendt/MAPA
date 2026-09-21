.SD $2004
.SDflags $2005

:SDslowstall
IMM $00
:SDlp7
INCI
CMPI $16
BNE SDlp7
RET

:SDstall
IMM $00
:SDlp7
INCI
CMPI $08
BNE SDlp7
RET

:SDsendCmd
#sends the command from SDcmd in slow mode then waits for and returns R1
#frame: 2
#rets: A=R1 

ADDIP $FFFE
STRP SP

IMM $06
STR SDi
IMMP SDcmd
STRP SDcmdP
:SDlp0
LDP SDcmdP
LDO $00
STR SD
INCP
STRP SDcmdP
LDP SP
CALL SDslowstall
IMM $FF
ADS SDi
BANZ SDlp0

:SDlp1
IMM $FF
STR SD
CALL SDslowstall
LD SD
CMPI $FF
BEQ SDlp1

ADDIP $0002
RET

:SDcmd
$00
$00
$00
$00
$00
$00
:SDi
$00
:SDcmdP
@SDcmd

:SDinit
#initializes SDSC card with default modes and parameters
#frame: 2
#rets: A=success

ADDIP $FFFC
IMM $00
STR SDflags

IMM $00
:SDlp6
INCI
CMPI $E0
BNE SDlp6

IMM $01
STR SDflags

:SDcmd0
IMM $40
STR SDcmd 0000
IMM $95
STR SDcmd 0005
CALL SDsendCmd
CMPI $01
BNE SDcmd0

:SDinitloop
IMM $00
STR SDflags
CALL SDslowstall
IMM $01
STR SDflags

:SDcmd55
IMM $77
STR SDcmd 0000
IMM $65
STR SDcmd 0005
CALL SDsendCmd
CMPI $01
BNE SDcmd55

IMM $00
STR SDflags
CALL SDslowstall
IMM $01
STR SDflags

:SDacmd41
IMM $69
STR SDcmd 0000
IMM $77
STR SDcmd 0005
CALL SDsendCmd
BANZ SDinitloop

IMM $02
STR SDflags

ADDIP $0004
RET

:SDwrite
#writes single sector to card from buffer
#frame: 8
#args: 2-5=sector address, 6-7=buffer address
#rets: A=success

ADDIP $FFFE
IMM $03
STR SDflags

:SDcmd24
IMM $58
STR SD
LDO $07
STR SD
LDO $06
STR SD
LDO $05
STR SD
LDO $04
STR SD
IMM $FF
STR SD

:SDlp2
IMM $FF
STR SD
LD SD
BANZ SDlp2

IMM $FF
STR SD
IMM $FE
STR SD

IMM $00
STR SDcountlo
STR SDcounthi

STRP SP
LDPO $08

:SDwriteloop
LDO $00
STR SD
INCP
IMM $01
ADS SDcountlo
IMM $00
ACS SDcounthi
CMPI $02
BNE SDwriteloop

LDP SP

IMM $FF
STR SD
IMM $FF
STR SD

:SDlpA
IMM $FF
STR SD
LD SD
CMPI $FF
BEQ SDlpA

:SDlp3
IMM $FF
STR SD
LD SD
CMPI $FF
BNE SDlp3

IMM $02
STR SDflags

ADDIP $0002
RET

:SDread
#reads single sector to card into buffer
#frame: 8
#args: 2-5=sector address, 6-7=buffer address
#rets: A=success

ADDIP $FFFE
IMM $03
STR SDflags

:SDcmd17
IMM $51
STR SD
LDO $07 
STR SD
LDO $06 
STR SD
LDO $05 
STR SD
LDO $04 
STR SD
IMM $FF
STR SD

:SDlp4
IMM $FF
STR SD
LD SD
BANZ SDlp4

:SDlp5
IMM $FF
STR SD
LD SD
CMPI $FE
BNE SDlp5

IMM $00
STR SDcountlo
STR SDcounthi

STRP SP
LDPO $08

:SDreadloop
IMM $FF
STR SD
LD SD
STRO $00
INCP
IMM $01
ADS SDcountlo
IMM $00
ACS SDcounthi
CMPI $02
BNE SDreadloop

LDP SP

IMM $FF
STR SD
IMM $FF
STR SD

IMM $02
STR SDflags

ADDIP $0002
RET

:SDcountlo
$00
:SDcounthi
$00