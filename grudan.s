;
; HiRes	Game Test
;

; switch off basic rom
;	lda $01
;	and #%11111110
;	sta $01
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
	lda $D018
	and #%00000001
	ora #%00001000  ; bitmap buffer offset to $2000 ($6000)
	ora #%01110000	; color  buffer offset to $1c00 ($5c00)
	sta $D018
; clear screen
	lda #$00
	sta $22
	lda #$5c
	sta $23		; zero page register $22 holds $a000
	lda #%010110101
	ldy #$00
bclear:	sta ($22),y	; loop to clear the bitmap
	iny
	bne bclear
	ldx $23
	inx
	stx $23
	cpx #$80
	bne bclear
; return to basic
	rts
