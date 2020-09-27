.macro setrasterinterrupt pos, irq
; set raster interrupt 'irq' to line 'pos'
	lda #(pos-2)
	sta $D012
	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff
	asl $d019
.endmacro

.macro	spritepointer ptr_offset, base
; set sprite pointers
	lda #base
	sta ptr_offset
	lda #(base+1)
	sta ptr_offset+1
	lda #(base+2)
	sta ptr_offset+2
	lda #(base+3)
	sta ptr_offset+3
	lda #(base+4)
	sta ptr_offset+4
	lda #(base+5)
	sta ptr_offset+5
	lda #(base+6)
	sta ptr_offset+6
	lda #(base+7)
	sta ptr_offset+7
.endmacro

; TODO: use only x tregister in interrupt!!!!!!
.macro spritepos pos
; set sprite y positions (for the next row)
	lda #pos
	sta spriteypos
	sta spriteypos+2
	sta spriteypos+4
	sta spriteypos+6
	sta spriteypos+8
	sta spriteypos+10
	sta spriteypos+12
	sta spriteypos+14
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
