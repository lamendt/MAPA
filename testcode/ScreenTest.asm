IMMP
$string
:loop
LDAP
$00
CMPI
$00
BEQD
$halt

STRAD
$2000
LDAD
$xpos
STRAD
$2000
STRAD
$2000
INCAD
$xpos

INCP
JMPD
$loop

:halt
JMPD
$halt

#data
:xpos
$10
:char
$00
:string
$48
$65
$6C
$6C
$6F
$20
$57
$6F
$72
$6C
$64
$21
$00