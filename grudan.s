;
; HiRes	Game Test
;

; switch off basic rom
	lda $01
	and #%11111100
	ora #%00000010	; keep KERNAL, but switch off basic
	sta $01
; activate HiRes Mode
	lda $D011
	ora #$20
	sta $D011
; select vic bank 2 (starts at $8000)
	lda $DD00
	and #%11111100
	ora #%00000001
	sta $DD00
; set bank offsets
	lda $D018
	and #%00000001
	ora #%00001000  ; bitmap buffer offset to $2000 ($A000)
	ora #%00000000	; color  buffer offset to $0000 ($8000)
	sta $D018
; clear color
	lda #$00
	sta $22
	lda #$80
	sta $23		; zero page register $22 holds $A000
	lda #$84
	sta $24		; msb of end of block address
	lda #$10
	jsr clear
; clear bitmap
	lda #$A0
	sta $23		; zero page register $22 holds $A000
	lda #$c0
	sta $24		; msb of end of block address
	lda #%11110000
	jsr clear
; load image
	lda #$41	; 'A'
	sta $22
	lda #$00
	sta $23
	lda #$A0
	sta $24
	jsr loadfile

; return to basic
loop:	jmp loop 	; loop forever
	rts

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
