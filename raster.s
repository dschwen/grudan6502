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

xoffset = 32
; bitmap buffer offset to $0000 ($4000), color  buffer offset to $2000 ($6000) / $2400 ($6400)
screen0 = %10000000
screen1 = %10010000

; activate HiRes Mode
	lda $D011
	ora #$20
	sta $D011
; select vic bank 1 (starts at $4000)
	lda $DD00
	and #%11111100
	ora #%00000010
	sta $DD00
; set bank offsets
	lda #screen0
	sta $D018
; clear color 0
	lda #$00
	sta $22
	lda #$60
	sta $23		; zero page register $22 holds $6000
	lda #$64
	sta $24		; msb of end of block address ($6400)
	lda #$14
	jsr clear
; clear color 1
	lda #$64
	sta $23		; zero page register $22 holds $6400
	lda #$68
	sta $24		; msb of end of block address ($6800)
	lda #$21
	jsr clear
; clear bitmap
	lda #$40
	sta $23		; zero page register $22 holds $4000
	lda #$60
	sta $24		; msb of end of block address ($6000)
	lda #%11110000
	jsr clear

; fill sprite area with junk
	lda #$68
	sta $23		; zero page register $22 holds $6800
	lda #$80
	sta $24		; msb of end of block address ($8000)
	lda #%10101010
	jsr clear

; load image
;	lda #$43	; 'C'
;	sta $22
;	lda #$00
;	sta $23
;	lda #$2E
;	sta $24
;	jsr loadfile

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

.macro	spritepointer ptr_offset, base
; set sprite pointers
	ldx #base
	stx ptr_offset
	ldx #(base+1)
	stx ptr_offset+1
	ldx #(base+2)
	stx ptr_offset+2
	ldx #(base+3)
	stx ptr_offset+3
	ldx #(base+4)
	stx ptr_offset+4
	ldx #(base+5)
	stx ptr_offset+5
	ldx #(base+6)
	stx ptr_offset+6
	ldx #(base+7)
	stx ptr_offset+7
.endmacro

.macro spritepos pos
; set sprite positions (for the next row)
	lda #pos
	sta $D001
	sta $D003
	sta $D005
	sta $D007
	sta $D009
	sta $D00B
	sta $D00D
	sta $D00F
.endmacro

.macro setrasterinterrupt pos, irq
; set raster interrupt 'irq' to line 'pos'
	lda #(pos-2)
	sta $D012
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	asl $d019
.endmacro

.macro nop7wait
	nop
	nop
	nop
	nop
	nop
	nop
	nop
.endmacro

.macro	move0 pos, irq, base
	spritepointer $63F8, base
	lda #screen0
	sta $D018
	nop7wait
	spritepos pos
	setrasterinterrupt pos-2, irq
.endmacro

.macro	move1 pos, irq, base
	spritepointer $67F8, base
	lda #screen1
	sta $D018
	nop7wait
	spritepos pos
	setrasterinterrupt pos-2, irq
.endmacro

irq1:	move0 yoffset+16, irq2, 160
	jmp $EA81

irq2:	move1 yoffset+32, irq3, 160+8
	jmp $EA81

irq3:	move0 yoffset+48, irq4, 160+16
	jmp $EA81

irq4:	move1 yoffset+64, irq5, 160+24
	jmp $EA81

irq5:	move0 yoffset+80, irq6, 160+32
	jmp $EA81

irq6:	move1 yoffset+96, irq7, 160+40
	jmp $EA81

irq7:	move0 yoffset+112, irq8, 160+48
	jmp $EA81

irq8:	move1 yoffset+128, irq9, 160+56
	jmp $EA81

irq9:	move0 yoffset+144, irq10, 160+64
	jmp $EA81

irq10:	move1 yoffset+160, irq11, 160+72
	jmp $EA81

irq11:	move0 yoffset, irq1, 160+80
	jmp $EA31

; clear block
clear:
	ldy #$00
@loop:	sta ($22),y	; loop to clear the bitmap
	iny		; increment lsb (y) for inner loop
	bne @loop
	ldx $23		; increment msb for outer loop
	inx
	stx $23
	cpx $24
	bne @loop
	rts

; fill block with stuff
fill:
	ldy #$00
@loop:	tya
	sta ($22),y	; loop to clear the bitmap
	iny		; increment lsb (y) for inner loop
	bne @loop
	ldx $23		; increment msb for outer loop
	inx
	stx $23
	cpx $24
	bne @loop
	rts

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
