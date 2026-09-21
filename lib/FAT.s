&../lib/SD

.FATtable 0001
.FATroot 0236

:FATclustToSec
#converts cluster number to its first sector number
#frame: 6
#args: 2-3 cluster number
#rets: 2-5 sector number

IMM $00
STRO $04

#cluster-1
IMM $FF
ADSO $02
IMM $FF
ACSO $03

#cluster<<6
IMM $06
STR FATi
:FATlp0
LDO $02
SLO $02
LDO $03
SLCO $03
LDO $04
SLCO $04
IMM $FF
ADS FATi
BANZ FATlp0

#cluster+root
IMM FATroot
ADSO $02
IMM ^FATroot
ACSO $03
IMM $00
ACSO $04

#cluster<<1
LDO $02
SLO $02
LDO $03
SLCO $03
LDO $04
SLCO $04
IMM $00

#cluster<<8
LDO $04
STRO $05
LDO $03
STRO $04
LDO $02
STRO $03
IMM $00
STRO $02

RET

:FATparsePath
#finds starting cluster number of the path relative to clst
#frame: 6
#args: 2-3=clst, 4-5=Pointer to path string
#rets: A=status, 2-3=cluster number 

#bookkeeping
LDO $04
STR FATpathP 0000
LDO $05
STR FATpathP 0001
LDO $02
STR FATclst 0000
LDO $03
STR FATclst 0001
ADDIP $FFF8

#if path[0] is '/' set clst to root
STRP SP
LDP FATpathP
LDO $00
CMP $2F
BEQ FATpathIsRoot
JMP FATpathNotRt
:FATpathIsRoot
IMM $01
STR FATclst 0000
IMM $00
STR FATclst 0001
INCP
STRP FATpathP
:FATpathNotRt
LDP SP

#loop through each entry of the cluster

#calculate first sector and setup loop

LD FATclst 0000
STRO $02
LD FATclst 0001
STRO $03
CALL FATclustToSec

IMM $10
STR FATi

:FATparseLp
#if needed, load next sector
LD FATi
CMPI $10
BNE FATnotLdSect

#load into buffer
IMM FATbuffer
STRO $06
IMM ^FATbuffer
STRO $07
CALL SDread

#increment sector and reset loop vars
IMM $02
ADSO $03
IMM $00
ACSO $04
IMM $00
ACSO $05
IMM $00
STR FATi
STRP SP
IMMP FATbuffer
STRP FATnameP
LDP SP

:FATnotLdSect

STRP SP
LDP FATnameP

:FATmatchName


JMP FATmatchName

:FATmatchExt

JMP FATmatchExt


ADDIP $20
STRP FATnameP
LDP SP

IMM $01
ADS FATi

JMP FATparseLp

ADDIP $0008
RET

:FATnextLevel
#parse name



#parse extension


:FATfindClust

:FATopen

:FATclose

:FATwrite

:FATread

:FATcd

:FATseek

:FATrm

#data
:FATi
$00
:FATj
$00
:FATcwd
$0000
:FATbuffer
+0200
:FATclst
$0000
:FATsectLo
$0000
:FATsectHi
$0000
:FAToffset
$0000
:FATpathP
$0000
:FATp
$0000