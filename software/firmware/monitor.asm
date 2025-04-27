	org	00000h

	ld sp,01000h

	call MonitorMenu
start_loop:
	call CmdParser
	jr start_loop


MonitorMenu:
	ld HL, str_logo_0
	call PrintLn
	ld HL, str_logo_1
	call PrintLn
	ld HL, str_logo_2
	call PrintLn
	ld HL, str_logo_3
	call PrintLn
	ld HL, str_logo_4
	call PrintLn
	ld HL, str_logo_5
	call PrintLn
	ld HL, str_info
	call PrintLn
	ret

str_logo_0: defb "          __         __________ ______ _______   ",0
str_logo_1: defb "  _______/  |_  ____ \\____    //  __  \\\\   _  \\  ",0
str_logo_2: defb " /  ___/\\   __\\/ __ \\  /     / >      </  /_\\  \\ ",0
str_logo_3: defb " \\___ \\  |  | \\  ___/ /     /_/   --   \\  \\_/   \\",0
str_logo_4: defb "/____  > |__|  \\___  >_______ \\______  /\\_____  /",0
str_logo_5: defb "     \\/            \\/        \\/      \\/       \\/ ",0
str_info: defb "For help type ?",0

CmdParser:
	ld HL, str_prompt
	call PrintStr
	call ReadLine
	ld HL, LINEBUF
cmd_help:
	ld DE, str_help
	call StrCmp
	or a
	jr nz, cmd_reg
	ld HL, help_all
	call PrintLn
	ret
cmd_reg:
	ld DE, str_reg
	call StrCmp
	or a
	jr nz, cmd_peek
	call DumpRegisters
	ret
cmd_peek:
	ld DE, str_reg
	call StrCmp
	or a
	jr nz, cmd_peek
	call DumpRegisters
	ret
cmd_poke:
cmd_dump:
cmd_unknown:
	ld HL, str_unknown
	call PrintLn
	ret

str_prompt: defb "> ",0

Peek:
	ld HL, str_dump
	call PrintLn
	ret

help_all: defb "Commands: REG",0
str_help: defb "?",0
str_reg: defb "REG",0
str_peek: defb "PEEK",0
str_poke: defb "POKE",0
str_dump: defb "DUMP",0
str_unknown: defb "CMD UNKNOWN",0

; StrCmp compares strings pointed to by DE with HL
; Length of String in B
; returns: Z
StrCmp:
str_cmp_loop:
	ld a, (HL)
	ld b, a
	ld a, (DE)
	cp b
	jr nz, str_cmp_notequal
	cp 0
	ret z
	inc HL
	inc DE
	jr str_cmp_loop
str_cmp_notequal:
	ld a, 1
	ret

; ReadLine reads a line terminated by CR 
; it prints the line while typing and ends with LF
; returns: String read in memory pointed to by DE
ReadLine:
	ld DE, LINEBUF
read_next_char_loop:
	call GetChar
	cp 0x0D
	jr z, read_line_done
	out (0x02), a
	ld (DE), a
	inc DE
	jr read_next_char_loop
read_line_done:
	ld a, 0x00 	; zero terminate
	ld (DE), a
	ld a, 0x0A
	out (002h),a
	ret

; XXX put in RAM
LINEBUF: defs 32

; GetChar reads a single character
; returns: character in A
GetChar:
	in a,(003h)
	or a
	jr z, GetChar
	in a,(002h)
	ret

; PrintChar prints a single character
; parameter: A
PrintChar:
	out (002h),a
	ret

; PrintLn prints a string followed by LF
; param: HL -> points to string, zero terminated
PrintLn:
	call PrintStr
	ld a, 0x0A
	out (002h),a
	ret

; PrintStr prints a string
; param: HL -> points to string, zero terminated
PrintStr:
	ld a, (hl)
	or a
	jr z, end_print
	out (002h),a
	inc hl
	jp PrintStr
end_print:
	ret

; PrintHex prints one byte in hex format
; param: A
PrintHex:
	push AF
	push AF
	; print higher nibble
	rrca
	rrca
	rrca
	rrca
	call LowNibbleToHex
	out (002h),a
	pop AF
	call LowNibbleToHex
	out (002h),a
	pop AF
	ret
	
; LowNibbleToHex converts the low nibble in A to a Hex-Character
LowNibbleToHex:
	and 0xF
	cp 10
	jr c,gen_digit
	add a, 'A' - 10
	ret
gen_digit:
	add a, '0'
	ret

; DumpRegisters shows the values of the Z80 registers
; example: PC:0019 AF:2124 BC:0000 DE:0000 HL:0010 SP:fffb IX:0000 IY:0000
DumpRegisters:
	push AF ; SP + 10
	push BC ; SP + 8
	push DE ; SP + 6
	push HL ; SP + 4
	push IX ; SP + 2
	push IY ; SP
	; print PC
	ld HL, dump_pc_str
	call PrintStr
	ld BC, 0x0C ; offset for return address, stored by call
	ld HL,0
	add HL,SP ; get SP
	add HL,BC ; HL points to return address
	ld E, (HL)
	INC HL
	ld D, (HL)
	ex DE,HL
	ld DE, 0x03 	; substract length of call instruction
	call SubDEfromHL
	push HL
	ld HL,0
	add HL,SP 	; get SP
	call PrintHexWord
	pop HL

	; print AF
	ld HL, dump_af_str
	call PrintStr
	ld BC, 0x0A ; offset for AF
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	call PrintHexWord

	; print BC
	ld HL, dump_bc_str
	call PrintStr
	ld BC, 0x08 ; offset for BC
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	call PrintHexWord

	; print DE
	ld HL, dump_de_str
	call PrintStr
	ld BC, 0x06 ; offset for DE
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	call PrintHexWord

	; print HL
	ld HL, dump_hl_str
	call PrintStr
	ld BC, 0x04 ; offset for HL
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	call PrintHexWord

	; print SP
	ld HL, dump_sp_str
	call PrintStr
	ld BC, 0x0E ; stack before calling
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	push HL
	ld HL,0
	add HL,SP ; get SP
	call PrintHexWord
	pop HL

	; print IX
	ld HL, dump_ix_str
	call PrintStr
	ld BC, 0x02 ; offset for IX
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	call PrintHexWord

	; print IY
	ld HL, dump_iy_str
	call PrintStr
	ld BC, 0x00 ; offset for IY
	ld HL,0
	add HL,SP ; get SP
	add HL,BC
	call PrintHexWord

	; print LF
	ld a, 0x0A
	out (002h),a

	pop IY
	pop IX
	pop HL
	pop DE
	pop BC
	pop AF
	ret
dump_pc_str: defb "PC: ", 0
dump_af_str: defb " AF: ", 0
dump_bc_str: defb " BC: ", 0
dump_de_str: defb " DE: ", 0
dump_hl_str: defb " HL: ", 0
dump_sp_str: defb " SP: ", 0
dump_ix_str: defb " IX: ", 0
dump_iy_str: defb " IY: ", 0

; PrintHexWord prints two bytes pointed to by HL
; revert little endian
PrintHexWord:
	INC HL
	ld a, (HL)
	call PrintHex
	DEC HL
	ld a, (HL)
	call PrintHex
	ret

;------------------------------------------------
; Math functions
SubDEfromHL:
	LD A, E
	CPL      	; Invert bits (1's complement)
	LD E, A
	LD A, D
	CPL
	LD D, A
	INC DE 		; Now DE = -DE (2's complement)
	ADD HL, DE
	RET
