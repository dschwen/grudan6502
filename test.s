;
; Raster Interrupt Test
;

; position 8 sprites to where my interrupt is
; enable sprites
	lda #%11111111
	sta $D015
; set x positions
	lda #0
	sta $D000
	sta $D002
	sta $D004
	sta $D006
	sta $D008
	sta $D00a
	sta $D00c
	sta $D00e
; set y positions
	lda #$50
	sta $D001
	sta $D003
	sta $D005
	sta $D007
	sta $D009
	sta $D00b
	sta $D00d
	sta $D00f

; switch off CIA interrupts
	lda #%01111111
	sta $DC0D
; clear bit 7 in VIC raster register
	and $D011
	sta $D011
; set raster line number
	lda #$58
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

irq1:
; change background (for debugging)

; 8 sprite pointer
	lda #2
	sta $D021
	lda #3
	sta $D021
	lda #4
	sta $D021
	lda #5
	sta $D021
	lda #7
	sta $D021
	lda #8
	sta $D021
	lda #9
	sta $D021
	lda #10
	sta $D021
; and the screen ram shift
	lda #6
	sta $D021

; ack interrupt and jump to basic
	asl $d019
	jmp $EA31


	;... error handling ...
	rts
