;;;;;; IRQ routine

	.export _startirq
	.export _stopirq
	
	.export _irqhappend

; Unseren IRQ registrieren	
_startirq:
    sei             ; IRQ sperren

    lda #$7f        ; CIA Timer IRQ aus
    sta $dc0d         
    bit $dc0d 

    lda #$ff        ; Raster IRQ bei Zeile 255
    sta $d012 

    lda $d011       ; Achtes Bit in anderem Register
    and #$7f        
    sta $d011  

    lda #$81        ; VIC2 IRQ durch Rasterzeilen ein
    sta $d01a 

    ldx #<IRQ1Start ; IRQ Addresse vom KERNAL auf unsere Routine abändern 
    ldy #>IRQ1Start 
    stx $0314       
    sty $0315 

    cli             ; IRQ freigeben
	rts

; Unseren IRQ rückgängig machen	
_stopirq:

	sei
.ifdef __C64__
	lda #$ea        ; IRQ Addresse vom KERNAL wieder auf die Ursprungsroutine
	sta $0315
	lda #$31
	sta $0314
	inc $d019       ; Etwaigen Raster IRQ annerkennen
	lda #$81        ; CIA Timer IRQ ein
	sta $dc0d
	lda #$00        ; VIC2 Raster IRQ aus
	sta $d01a
.endif    
	cli
	rts
	
; Unser IRQ	
IRQ1Start:
	pha     ; Register retten. Y wird selten in Musikroutinen genutzt, deswegen kann man das erst mal weglassen
	txa
	pha
    ;tya
    ;pha

    dec $d019       ; Raster IRQ annerkennen

    lda #$01        ; Dem Hauptteil erkennbar machen das der IRQ passiert ist
    sta _irqhappend
	
    ;inc $d020      ; Auskommentieren wenn man sehen will wie viele Zeilen der IRQ futtert, dadurch wird die Rahmenfarbe geändert

    ; Musik, auskommentieren wenn man ab $1000 Musik geladen hat. Nicht vergessen diese einmal mit einem JSR $1000 zu initialisieren.
    ;jsr $1003 

    ;dec $d020      ; Auskommentieren wenn man sehen will wie viele Zeilen der IRQ futtert

    ;pla    ; Register wiederherstellen
    ;tay
	pla
	tax
	pla
	jmp $EA31 ; Zum originalen KERNAL IRQ, sonst gibts keine Tastatureingabe ;) 
	
_irqhappend:
    .byte $00
