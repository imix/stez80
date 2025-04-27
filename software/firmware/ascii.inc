; --- ASCII Control Characters ---
NUL     EQU 0x00    ; Null
SOH     EQU 0x01    ; Start of Header
STX     EQU 0x02    ; Start of Text
ETX     EQU 0x03    ; End of Text
EOT     EQU 0x04    ; End of Transmission
ENQ     EQU 0x05    ; Enquiry
ACK     EQU 0x06    ; Acknowledge
BEL     EQU 0x07    ; Bell (beep)
BS      EQU 0x08    ; Backspace
TAB     EQU 0x09    ; Horizontal Tab
LF      EQU 0x0A    ; Line Feed
VT      EQU 0x0B    ; Vertical Tab
FF      EQU 0x0C    ; Form Feed
CR      EQU 0x0D    ; Carriage Return
SO      EQU 0x0E    ; Shift Out
SI      EQU 0x0F    ; Shift In
DLE     EQU 0x10    ; Data Link Escape
DC1     EQU 0x11    ; Device Control 1
DC2     EQU 0x12    ; Device Control 2
DC3     EQU 0x13    ; Device Control 3
DC4     EQU 0x14    ; Device Control 4
NAK     EQU 0x15    ; Negative Acknowledge
SYN     EQU 0x16    ; Synchronous Idle
ETB     EQU 0x17    ; End of Transmission Block
CAN     EQU 0x18    ; Cancel
EM      EQU 0x19    ; End of Medium
SUB     EQU 0x1A    ; Substitute
ESC     EQU 0x1B    ; Escape
FS      EQU 0x1C    ; File Separator
GS      EQU 0x1D    ; Group Separator
RS      EQU 0x1E    ; Record Separator
US      EQU 0x1F    ; Unit Separator
SP      EQU 0x20    ; Space
DEL     EQU 0x7F    ; Delete

; --- Printable Characters ---
EXCLAM  EQU '!'     ; 0x21
QUOTE   EQU '"'     ; 0x22
HASH    EQU '#'     ; 0x23
DOLLAR  EQU '$'     ; 0x24
PERCENT EQU '%'     ; 0x25
AMP     EQU '&'     ; 0x26
APOST   EQU '\''    ; 0x27
LPAREN  EQU '('     ; 0x28
RPAREN  EQU ')'     ; 0x29
STAR    EQU '*'     ; 0x2A
PLUS    EQU '+'     ; 0x2B
COMMA   EQU ','     ; 0x2C
MINUS   EQU '-'     ; 0x2D
DOT     EQU '.'     ; 0x2E
SLASH   EQU '/'     ; 0x2F

; --- Digits ---
ZERO    EQU '0'
ONE     EQU '1'
TWO     EQU '2'
THREE   EQU '3'
FOUR    EQU '4'
FIVE    EQU '5'
SIX     EQU '6'
SEVEN   EQU '7'
EIGHT   EQU '8'
NINE    EQU '9'

; --- Uppercase Letters ---
A       EQU 'A'
B       EQU 'B'
C       EQU 'C'
D       EQU 'D'
E       EQU 'E'
F       EQU 'F'
G       EQU 'G'
H       EQU 'H'
I       EQU 'I'
J       EQU 'J'
K       EQU 'K'
L       EQU 'L'
M       EQU 'M'
N       EQU 'N'
O       EQU 'O'
P       EQU 'P'
Q       EQU 'Q'
R       EQU 'R'
S       EQU 'S'
T       EQU 'T'
U       EQU 'U'
V       EQU 'V'
W       EQU 'W'
X       EQU 'X'
Y       EQU 'Y'
Z       EQU 'Z'

; --- Lowercase Letters ---
a       EQU 'a'
b       EQU 'b'
c       EQU 'c'
d       EQU 'd'
e       EQU 'e'
f       EQU 'f'
g       EQU 'g'
h       EQU 'h'
i       EQU 'i'
j       EQU 'j'
k       EQU 'k'
l       EQU 'l'
m       EQU 'm'
n       EQU 'n'
o       EQU 'o'
p       EQU 'p'
q       EQU 'q'
r       EQU 'r'
s       EQU 's'
t       EQU 't'
u       EQU 'u'
v       EQU 'v'
w       EQU 'w'
x       EQU 'x'
y       EQU 'y'
z       EQU 'z'
