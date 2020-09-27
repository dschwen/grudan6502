;
; Raster Interrupt Test
;

.include "irq.s"

xoffset = 32
yoffset = 58
yheight = 21

; bitmap buffer offset to $0000 ($4000), color  buffer offset to $2000 ($6000) / $2400 ($6400)
screen0 = %10000000
screen1 = %10010000

; zeropage
tempa = $25

; vic addresses
spriteypos = $D001

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
	lda #$23
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
	;jsr clear

; load image
	;lda #$42	; 'B'
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
	lda #%0000000
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
	sta $fffe
	lda #>irq1
	sta $ffff
; enable raster interrupt from VIC
	lda #%00000001
	sta $D01A


;	lda #$00
;	sta $22
;	sta $23
;	jsr block1
;; return to basic
;	rts

testblock:jmp testblock
	lda #$08
	sta $22
	sta $23
@loop:	jsr block1
	dec $22
	bpl @loop
	lda #$08
	sta $22
	dec $23
	bpl @loop
	; return to basic
	rts


; at line -2
irq1:	pha
	spritedata0 160
	setrasterinterrupt yoffset+16*1, irq2
	pla
	rti

irq2:	pha
	spritedata1 160+8*1
	nop7wait
	spritepos yoffset+21*1			; 21
	setrasterinterrupt yoffset+16*2, irq3	; 32
	pla
	rti

irq3:	pha
	spritedata0 160+8*2
	nop7wait
	spritepos yoffset+21*2			; 42
	setrasterinterrupt yoffset+16*3, irq4	; 48
	pla
	rti

irq4:	pha
	spritedata1 160+8*3
	nop7wait
	spritepos yoffset+21*3			; 63
	setrasterinterrupt yoffset+16*4, irq5	; 64
	pla
	rti

irq5:	pha
	spritedata0 160+8*4
	setrasterinterrupt yoffset+16*5, irq6
	pla
	rti

irq6:	pha
	spritedata1 160+8*5
	nop7wait
	spritepos yoffset+21*4			; 84
	setrasterinterrupt yoffset+16*6, irq7	; 96
	pla
	rti

irq7:	pha
	spritedata0 160+8*6
	nop7wait
	spritepos yoffset+21*5			; 105
	setrasterinterrupt yoffset+16*7, irq8   ; 112
	pla
	rti

irq8:	pha
	spritedata1 160+8*7
	nop7wait
	spritepos yoffset+21*6			; 126
	setrasterinterrupt yoffset+16*8, irq9	; 128
	pla
	rti

irq9:	pha
	spritedata0 160+8*8
	setrasterinterrupt yoffset+16*9, irq10
	pla
	rti

irq10:	pha
	spritedata1 160+8*9
	nop7wait
	spritepos yoffset+21*7			; 147
	setrasterinterrupt yoffset+16*10, irq11	; 160
	pla
	rti

irq11:	pha
	spritedata0 160+8*10
	nop7wait
	spritepos yoffset+21*8
	setrasterinterrupt yoffset+16*11, irq12
	pla
	rti

irq12:	pha
	spritedata1 160+8*11			; switch last row to empty
	spritepos yoffset			; top of screen
	setrasterinterrupt yoffset+16*0, irq1	; top of screen
	pla
	rti

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
@skip:	ldy #$01	; $01 means: load to address stored in file
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

.macro blockcol lowbase, yval
.scope
	; high byte of sprite destination address
	lda $22  ; load x coordinate of tile from $22
	cmp #$06 ; if x coord >= 6 increment x
	bcc @noinc
	lda $23	; load y coordinate of tile from $23
	tay ; move y coord into y register
	rol ; multiply by 2
	ora #$01 ; add one
	jmp @done
@noinc:
	lda $23	; load y coordinate of tile from $23
	tay ; move y coord into y register
	rol ; multiply by 2
@done:
	adc #$68 ; add 68 to high byte
	; modify hi byte of write instruction
	sta @spritewrite+2
	; get first lo byte from table
	lda $23  ; load y coordinate of tile from $23
	rol
	rol
	adc $23
	rol
	adc $23
	adc $22 ; add x
	rol ; multiplies y * 22 + 2*x
	tax
	lda lowbase, x ; get value from table
	; get first x register value from table
	; modify lo byte of write instruction
	sta @spritewrite+1
	lda yval,y ; look up ycounter value
	cmp #$ff
	beq @spriteend
	tay
	ldx #$0f
	; at this point we have X=16, Y=yval1(y), spritewrite address hi and lo updated
  ; write one 8*16 pixel column (half a block in the sprite matrix)
@spritebegin:
;	lda #%10101010
;	lda #$ff
	txa
@spritewrite:
	sta $ffff,y
	cpx #$00
	beq @spriteend
	dex
	dey
	dey
	dey
	jmp @spritebegin
@spriteend:
.endscope
.endmacro

block1:
	; write sprite data
	;blockcol lowbase1, yval1
	;blockcol lowbase2, yval2
	;blockcol lowbase1+1, yval1
	;blockcol lowbase2+1, yval2
	; write hires data
	; todo
	rts

.SEGMENT "ADATA"
aligned:
.include "table.inc"
