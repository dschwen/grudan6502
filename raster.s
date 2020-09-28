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
yoffset = 58
yheight = 21

tile_x = $22
tile_y = $23
tile_n = $24
tmp_lookup = $25
map_idx = $26
addr = $27 ; and $28

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
	lda #$21
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
	lda #$00
	jsr clear
; clear sprite area
	lda #$68
	sta $23		; zero page register $22 holds $6800
	lda #$80
	sta $24		; msb of end of block address ($8000)
	lda #$00
	jsr clear

; load tile data
	lda #$41	; file name 'A'
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
	sta $0314
	lda #>irq1
	sta $0315
; enable raster interrupt from VIC
	lda #%00000001
	sta $D01A
; switch off BASIC ROM
	lda $01
	and #%11111110
	sta $01

;	lda #$0
;	sta tile_x
;	sta tile_y
;	sta tile_n
;	jsr block1
;	jmp *

testblock:
	; setup minimap pointer and loop indices
	lda #$78
	sta map_idx
	lda #$0a
	sta tile_x
	sta tile_y

@loop:
	; fetch tile number from mini map
	ldx map_idx
	lda map,x
	sta tile_n
	dex ; decrement minimap pointer and save to zeropage
	stx map_idx
	; call tile drawing routine
	jsr block1
	; looping logic
	dec tile_x
	bpl @loop
	lda #$0a
	sta tile_x
	dec tile_y
	bpl @loop
	; holding pattern
	jmp *



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
; set sprite y positions (for the next row)
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

.macro spritedata0 base
	spritepointer $63F8, base
	lda #screen0
	sta $D018
.endmacro

.macro spritedata1 base
	spritepointer $67F8, base
	lda #screen1
	sta $D018
.endmacro

.macro	move0 pos, irq, base
	spritedata0 base
	nop7wait
	spritepos pos
	setrasterinterrupt pos-2, irq
.endmacro

.macro	endirq
	pla
	tay
	pla
	tax
	pla
	rti
.endmacro

; at line -2
irq1:	spritedata0 160
	setrasterinterrupt yoffset+16*1, irq2
	endirq

irq2:	spritedata1 160+8*1
	nop7wait
	spritepos yoffset+21*1			; 21
	setrasterinterrupt yoffset+16*2, irq3	; 32
	endirq

irq3:	spritedata0 160+8*2
	nop7wait
	spritepos yoffset+21*2			; 42
	setrasterinterrupt yoffset+16*3, irq4	; 48
	endirq

irq4:	spritedata1 160+8*3
	nop7wait
	spritepos yoffset+21*3			; 63
	setrasterinterrupt yoffset+16*4, irq5	; 64
	endirq

irq5:	spritedata0 160+8*4
	setrasterinterrupt yoffset+16*5, irq6
	endirq

irq6:	spritedata1 160+8*5
	nop7wait
	spritepos yoffset+21*4			; 84
	setrasterinterrupt yoffset+16*6, irq7	; 96
	endirq

irq7:	spritedata0 160+8*6
	nop7wait
	spritepos yoffset+21*5			; 105
	setrasterinterrupt yoffset+16*7, irq8   ; 112
	endirq

irq8:	spritedata1 160+8*7
	nop7wait
	spritepos yoffset+21*6			; 126
	setrasterinterrupt yoffset+16*8, irq9	; 128
	endirq

irq9:	spritedata0 160+8*8
	setrasterinterrupt yoffset+16*9, irq10
	endirq

irq10:	spritedata1 160+8*9
	nop7wait
	spritepos yoffset+21*7			; 147
	setrasterinterrupt yoffset+16*10, irq11	; 160
	endirq

irq11: spritedata0 160+8*10
	nop7wait
	spritepos yoffset+21*8
	setrasterinterrupt yoffset+16*11, irq12
	endirq

irq12: spritedata1 160+8*11			; switch last row to empty
	spritepos yoffset			; top of screen
	setrasterinterrupt yoffset+16*0, irq1	; top of screen
	endirq

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

.macro blockcol col
.scope
	; high byte of sprite destination address
	lda tile_x  ; load x coordinate of tile from $22
	cmp #$06 ; if x coord >= 6 increment x
	bcc @noinc
	lda tile_y	; load y coordinate of tile from $23
	tay ; move y coord into y register
	rol ; multiply by 2
	ora #$01 ; add one
	jmp @done
@noinc:
	lda tile_y	; load y coordinate of tile from $23
	tay ; move y coord into y register
	asl ; multiply by 2
@done:
	clc
	adc #$68 ; add 68 to high byte
	; modify hi byte of write instructions
	sta @spritewrite1+2
	sta @spritewrite2+2
	; get first lo byte from table
	lda tile_y  ; load y coordinate of tile from $23
	asl
	asl
	adc tile_y
	asl
	adc tile_y
	adc tile_x ; add x
	asl ; multiplies y * 22 + 2*x
	tax
	sta tmp_lookup
	lda lowbase1+col, x ; get value from table
	; get first x register value from table
	; modify lo byte of write instruction
	sta @spritewrite1+1
	lda yval1,y ; look up ycounter value
	tay
	ldx #$00
	; at this point we have X=16, Y=yval1(y), spritewrite address hi and lo updated
  ; write one 8*16 pixel column (half a block in the sprite matrix)
	; set up sprite source addresses
	lda tile_n
	lsr
	lsr
	lsr
	clc
	adc #hi_bitsprite
	sta @spritebegin1+2
	sta @spritebegin2+2
	lda tile_n
	asl
	asl
	asl
	asl
	asl
.if col
	clc
	adc #$10
.endif
	sta @spritebegin1+1
	sta @spritebegin2+1
@spritebegin1:
	lda $ffff,x ; the $ffff address is a dummy value that gets overwritten
	inx
@spritewrite1:
	sta $ffff,y
	cpy #$00
	beq @spriteend1
	dey
	dey
	dey
	jmp @spritebegin1
@spriteend1:

	; start second half of the column
	ldy tmp_lookup
	lda lowbase2+col, y ; get value from table
	; modify lo byte of write instruction
	sta @spritewrite2+1
	ldy tile_y	; load y coordinate of tile from $23
	lda yval2,y ; look up ycounter value
	cmp #$ff
	beq @spriteend2
	tay

@spritebegin2:
	lda $ffff,x
	inx
@spritewrite2:
	sta $ffff,y
	cpy #$00
	beq @spriteend2
	dey
	dey
	dey
	jmp @spritebegin2
@spriteend2:
.endscope
.endmacro

.macro hiresrow row
.scope
	; obtain hires buffer address
	lda tile_y
	asl
.if row
	clc
	adc #$01
.endif
	asl
	tay
	lda tile_x
	asl
	asl
	asl
	asl ; x coord * 16
	clc
	adc hiresaddr,y ; lowbyte, carry bit set of overflow
	sta @hireswrite+1
	lda #$00 ; clear acc, carry flac unaffected
	adc hiresaddr+1,y ; add higbyte with carry
	sta @hireswrite+2
	; obtain tile address
	lda tile_n
	lsr
	lsr
	lsr
	clc
	adc #hi_bithires
	sta @hiresbegin+2
	lda tile_n
	asl
	asl
	asl
	asl
	asl
.if row
	clc
	adc #$10
.endif
	sta @hiresbegin+1
	; setup loop counter
	ldx #$0f
@hiresbegin:
	lda $ffff,x
@hireswrite:
	sta $ffff,x
	dex
	bpl @hiresbegin
.endscope
.endmacro


.macro color
.scope
	lda tile_y
	asl ; y * 2
	tay
	lda coloraddr+1, y ; get hi byte from table
	sta addr+1
	lda coloraddr, y ; get lo byte from table
	sta addr
	lda tile_y
	and #$01
	ora #$18
	asl
	asl ; should give $60 for even and $64 for odd rows
	ora addr+1 ; bitwise or with hi byte from table
	sta addr+1 ; store highbyte
	lda #39
	sta tmp_lookup
	lda tile_n
	; TODO: check if top two bit are set and #%11000000, beq @skip, otherwise add them to the hibyte (for >64 tiles)
	asl
	asl; * 4
	tax
	lda tile_x
	asl
	tay
	lda colordata, x
	sta (addr),y
	inx
	iny
	lda colordata, x
	sta (addr),y
	inx
	tya
	adc tmp_lookup
	tay
	lda colordata, x
	sta (addr),y
	inx
	iny
	lda colordata, x
	sta (addr),y
.endscope
.endmacro

block1:
	; write sprite data
	blockcol 0
	blockcol 1
	; write hires data
	hiresrow 0
	hiresrow 1
colorbrk:
	color
	rts

map:
.byte 4,4,4,5,2,3,3,3,3,3,3
.byte 4,4,4,5,2,3,3,3,3,3,3
.byte 4,4,4,5,2,3,3,3,3,3,3
.byte 4,4,4,5,2,3,3,3,3,3,3
.byte 1,1,1,1,0,3,3,3,3,3,3
.byte 3,3,6,3,3,3,3,3,3,3,3
.byte 3,3,6,3,3,3,3,3,3,3,3
.byte 3,3,6,3,3,3,3,3,3,3,3
.byte 3,3,6,3,3,3,3,7,3,3,3
.byte 3,3,6,3,3,3,3,3,3,3,3
.byte 3,3,6,3,3,3,3,3,3,3,3

.include "table.inc"
