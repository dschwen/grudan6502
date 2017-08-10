;
; Raster Interrupt Test
;

; enable sprites
	lda #%11111111
	sta $D015
; set x (and y) positions
	ldx #16
	ldy #225 ; 8*24 + 8 + border
@loop:	dex
	lda #58 ; y position
	sta $D000,x
	tya
	sbc #24
	tay
	dex
	sta $D000,x
	bne @loop
; set sprite pointers
	ldx #8
	lda #0
@loop2:	dex
	sta $07F8,x
	bne @loop2
; switch off CIA interrupts
	lda #%01111111
	sta $DC0D
; clear bit 7 in VIC raster register
	and $D011
	sta $D011
; set raster line number
	lda #50
	sta $D012
; set interrupt vector
	lda #<irq1
	sta $0314
	lda #>irq1
	sta $0315
; enable raster interrupt from VIC
	lda #%00000001
	sta $D01A
	rts

irq1:
; turn frame yellow
	lda #7
	sta $D020
; set interrupt vector
	lda #<irq2
	sta $0314
	lda #>irq2
	sta $0315
; set raster line number
	lda #150
	sta $D012
; acknowledge interrupt and jump to kernal
	asl $d019
	jmp $EA31

irq2:
; turn frame red
	lda #3
	sta $D020
; set interrupt vector
	lda #<irq3
	sta $0314
	lda #>irq3
	sta $0315
; set raster line number
	lda #250
	sta $D012
; acknowledge interrupt and jump to kernal
	asl $d019
	jmp $EA81

irq3:
; turn frame light blue
	lda #15
	sta $D020
; set interrupt vector
	lda #<irq1
	sta $0314
	lda #>irq1
	sta $0315
; set raster line number
	lda #50
	sta $D012
; acknowledge interrupt and jump to kernal
	asl $d019
	jmp $EA81
