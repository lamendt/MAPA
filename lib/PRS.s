:PRSbyteToHex
#converts a raw byte into an ASCII hex representation
#frame: 4
#args: A=byte
#rets: 2-3=ASCII string

STR PRSchar
ANDI $0F
CMPI $0A
BLTU PRSisNumLo
ADDI $07
:PRSisNumLo
ADDI $30
STRO $03
LD PRSchar
SRI
SRI
SRI
SRI
ANDI $0F
CMPI $0A
BLTU PRSisNumHi
ADDI $07
:PRSisNumHi
ADDI $30
STRO $02
RET

:PRShexToByte
#converts ASCII hex representation into raw byte
#frame: 4
#args: 2-3=ASCII string
#rets: A=byte

LDO $02
CMPI $3A
BLTU $PRSisNumLo1
SUBI $07
:PRSisNumLo1
SUBI $30
STR PRSchar
LDO $03
CMPI $3A
BLTU $PRSisNumHi1
SUBI $07
:PRSisNumHi1
SUBI $30
SLI
SLI
SLI
SLI
ADS PRSchar
RET

:PRSchar
$00
