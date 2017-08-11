;
; Raster Interrupt Test
;

; enable sprites
	lda #%11111111
	sta $D015
; set x (and y) positions
	ldx #16
	ldy #8 ; 8 + border
@loop:	dex
	lda #58 ; y position
	sta $D000,x
	tya
	adc #24
	tay
	dex
	sta $D000,x
	bne @loop
; set sprite pointers and colors
	ldx #8
@loop2:	lda #13
	sta $07F7,x
	lda #0
	sta $D026,x
	dex
	bne @loop2
; initialize sprite pattern
	ldx #64
@loop3: lda #%10101010
	sta $033F,x
	dex
	lda #%01010101
	sta $033F,x
	dex
	bne @loop3
; initialize sprite pattern2
	ldx #64
	lda #%1101100
@loop4: sta $033F+64,x
	dex
	bne @loop4
; initialize sprite pattern3
	ldx #64
	lda #%11101110
@loop5: sta $033F+128,x
	dex
	bne @loop5
; switch off CIA interrupts
	lda #%01111111
	sta $DC0D
; clear bit 7 in VIC raster register
	and $D011
	sta $D011
; set raster line number
	lda #57
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

.macro	movesprites pos, irq, base
; set sprite positions
	lda pos
	sta $D001
	sta $D003
	sta $D005
	sta $D007
	sta $D009
	sta $D00B
	sta $D00D
	sta $D00F
; set sprite pointers
	ldx base
	stx $07F8
	ldx base+1
	stx $07F9
	ldx base
	stx $07FA
	ldx base+1
	stx $07FB
	ldx base
	stx $07FC
	ldx base+1
	stx $07FD
	ldx base
	stx $07FE
	ldx base+1
	stx $07FF
; set raster line number
	lda pos+15
	sta $D012
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	asl $d019
.endmacro

irq1:	movesprites #58, irq2, #13
	jmp $EA81

irq2:	movesprites #79, irq3, #14
	jmp $EA81

irq3:	movesprites #100, irq4, #13
	jmp $EA81

irq4:	movesprites #121, irq5, #14
	jmp $EA81

irq5:	movesprites #142, irq6, #13
	jmp $EA81

irq6:	movesprites #163, irq7, #14
	jmp $EA81

irq7:	movesprites #184, irq8, #13
	jmp $EA81

irq8:	movesprites #205, irq9, #14
	jmp $EA81

irq9:	movesprites #226, irq1, #13
	jmp $EA31
