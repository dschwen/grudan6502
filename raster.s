;
; Raster Interrupt Test
;

;.macro	setspritex sprite, xcoord
;	lda #<xcoord
;	sta ($D000 + 2 * sprite)
;	lda (#1 << sprite)
;.if #>xcoord
;	ora $D010
;.else
;	eor #$ff
;	and $D010
;.endif
;	sta $D010
;.endmacro

xoffset = 148

; load image
	lda #$43	; 'C'
	sta $22
	lda #$00
	sta $23
	lda #$2E
	sta $24
	jsr loadfile
; enable sprites
	lda #%11111111
	sta $D015
; set x positions
	lda #<(xoffset)
	sta $D000
	lda #<(xoffset + 24)
	sta $D002
	lda #<(xoffset + 24 * 2)
	sta $D004
	lda #<(xoffset + 24 * 3)
	sta $D006
	lda #<(xoffset + 24 * 4)
	sta $D008
	lda #<(xoffset + 24 * 5)
	sta $D00a
	lda #<(xoffset + 24 * 6)
	sta $D00c
	lda #<(xoffset + 24 * 7)
	sta $D00e
	lda #%11100000
	sta $D010
; set sprite colors
	ldx #8
	lda #0
@loop2:	sta $D026,x
	dex
	bne @loop2
; switch off CIA interrupts
	lda #%01111111
	sta $DC0D
; clear bit 7 in VIC raster register
	and $D011
	sta $D011
; set raster line number
	lda #55
	sta $D012
; set interrupt vector
	lda #<irq1
	sta $0314
	lda #>irq1
	sta $0315
; enable raster interrupt from VIC
	lda #%00000001
	sta $D01A
; return to basic
	rts

yoffset = 53
yheight = 21

.macro	movesprites pos, irq, base
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	;lda #2
	;sta $D021

; set sprite pointers
	ldx base
	stx $07F8
	ldx base+1
	stx $07F9
	ldx base+2
	stx $07FA
	ldx base+3
	stx $07FB
	ldx base+4
	stx $07FC
	ldx base+5
	stx $07FD
	ldx base+6
	stx $07FE
	ldx base+7
	stx $07FF

	nop
	nop
	nop
	;lda #6
	;sta $D021

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; set sprite positions
	lda #pos
	sta $D001
	sta $D003
	sta $D005
	sta $D007
;	lda #pos
	sta $D009
	sta $D00B
	sta $D00D
	sta $D00F
	;lda #6
	;sta $D021
; set raster line number
	lda #(pos-2)
	sta $D012
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	asl $d019
	;lda #6
	;sta $D021
.endmacro

irq1:	movesprites (yoffset + yheight), irq2, #184
	jmp $EA81

irq2:	movesprites (yoffset + yheight * 2), irq3, #184+8
	jmp $EA81

irq3:	movesprites (yoffset + yheight * 3), irq4, #184+16
	jmp $EA81

irq4:	movesprites (yoffset + yheight * 4), irq5, #184+24
	jmp $EA81

irq5:	movesprites (yoffset + yheight * 5), irq6, #184+32
	jmp $EA81

irq6:	movesprites (yoffset + yheight * 6), irq7, #184+40
	jmp $EA81

irq7:	movesprites (yoffset + yheight * 7), irq8, #184+48
	jmp $EA81

irq8:	movesprites (yoffset + yheight * 8), irq9, #184+56
	jmp $EA81

irq9:	movesprites yoffset, irq1, #184+64
	jmp $EA31


; load file to address
;   filenames are single characters stored in $22
;   target address is stored in $23/$24 (lo,hi)
loadfile:
	lda #$01	; file name is one character long
	ldx #$22
	ldy #$00
	jsr $FFBD	; call setnam
	lda #$01
	ldx $ba		; last used device number
	bne @skip
	ldx #$08	; default to device 8
@skip:	ldy #$00	; $00 means: load to new address
	jsr $FFBA	; call setlfs
	ldx $23
	ldy $24
	lda #$00	; $00 means: load to memory (not verify)
	jsr $FFD5	; call load
	bcs @err	; if carry set, a load error has happened
	rts
@err:
	; accumulator contains basic error code

	; most likely errors:
	; a = $05 (device not present)
	; a = $04 (file not found)
	; a = $1d (load error)
	; a = $00 (break, run/stop has been pressed during loading)

	;... error handling ...
	rts
