RS_ALIGN_LONGWORD		MACRO
; Input
; Result
	IFNE __RS%4
		RS.W 1
	ENDC
	ENDM


WAIT_LEFT_MOUSE_BUTTON		MACRO
; Input
; Result
wait_left_button_loop\@
	btst	#CIAB_GAMEPORT0,CIAPRA(a4)
	bne.s	wait_left_button_loop\@
	ENDM


WAIT_RIGHT_MOUSE_BUTTON		MACRO
; Input
; Result
wait_right_button_loop\@
	btst	#POTINPB_DATLY-8,POTINP-DMACONR(a6)
	bne.s	wait_right_button_loop\@
	ENDM


RASTER_TIME			MACRO
; Input
; \1 HEXNUMBER:	RGB4 value (optional)
; Result
	move.l	d0,-(a7)
	move.w	VPOSR-DMACONR(a6),d0
	swap	d0
	move.w	VHPOSR-DMACONR(a6),d0
	and.l	#$3ff00,d0
	lsr.l	#8,d0
	cmp.l	rt_rasterlines_number(a3),d0
	blt.s	rt_no_update_y_pos_max\@
	move.l	d0,rt_rasterlines_number(a3)
rt_no_update_y_pos_max\@
	IFNC "","\1"
		SHOW_BEAM_POSITION \1
	ENDC
	move.l	(a7)+,d0
	ENDM


SHOW_BEAM_POSITION		MACRO
; Input
; \1 WORD:	RGB4 color value
; Result
	move.w	#\1,COLOR00-DMACONR(a6)
	ENDM


AUDIO_TEST			MACRO
; Input
; Result
	lea	$20000,a0		; pointer chip memory
	move.l	a0,AUD0LCH-DMACONR(a6)
	move.l	a0,AUD1LCH-DMACONR(a6)
	move.l	a0,AUD2LCH-DMACONR(a6)
	move.l	a0,AUD3LCH-DMACONR(a6)
	moveq	#1,d0			; length = 1 word
	move.w	d0,AUD0LEN-DMACONR(a6)	
	move.w	d0,AUD1LEN-DMACONR(a6)
	move.w	d0,AUD2LEN-DMACONR(a6)
	move.w	d0,AUD3LEN-DMACONR(a6)
	moveq	#0,d0			; clear volume
	move.w	d0,AUD0VOL-DMACONR(a6)	
	move.w	d0,AUD1VOL-DMACONR(a6)
	move.w	d0,AUD2VOL-DMACONR(a6)
	move.w	d0,AUD3VOL-DMACONR(a6)
	move.w	#DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3|DMAF_SETCLR,DMACON-DMACONR(a6) ; enable audio DMA
	ENDM


MOVEF				MACRO
; Input
; \0 STRING:	Size [B/W/L]
; \1 NUMBER:	Source value
; \2 STRING:	Target
; Result
	IFC "","\0"
		FAIL Macro MOVEF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro MOVEF: Source value missing
	ENDC
	IFC "","\2"
		FAIL Macro MOVEF: Target missing
	ENDC
	IFC "B","\0"
		IFLE $80-(\1)
			IFGE $ff-(\1)
				moveq #-((-(\1)&$ff)),\2
			ENDC
		ELSE
			moveq #\1,\2
		ENDC
	ENDC
	IFC "W","\0"
		IFEQ (\1)&$ff00
			IFEQ (\1)&$80
				moveq	#\1,\2
			ENDC
			IFEQ (\1)-$80
				moveq	#$7f,\2
				not.b	\2
			ENDC
			IFGT (\1)-$80
				moveq	#256-(\1),\2
				neg.b	\2
			ENDC
		ELSE
			move.w	#\1,\2
		ENDC
	ENDC
	IFC "L","\0"
		IFEQ (\1)&$ffffff00
			IFEQ (\1)&$80
				moveq	#\1,\2
			ENDC
			IFEQ (\1)-$80
				moveq	#$7f,\2
				not.b	\2
			ENDC
			IFGT (\1)-$80
				moveq	#256-(\1),\2
				neg.b	\2
			ENDC
		ELSE
			move.l	#\1,\2
		ENDC
	ENDC
	ENDM


ADDF				MACRO
; Input
; \0 STRING:	Size [B/W/L]
; \1 NUMBER:	8/16 bit source
; \2 STRING:	Target
; Result
	IFC "","\0"
	 FAIL Macro ADDF: Size missing
	ENDC
	IFC "","\1"
	 FAIL Macro ADDF: 8/16 bit source missing
	ENDC
	IFC "","\2"
	 FAIL Macro ADDF: target missing
	ENDC
	IFEQ \1
		MEXIT
	ENDC
	IFC "B","\0"
		IFGE (\1)-$8000
			add.b	#\1,\2
		ELSE
			IFLE (\1)-8
				addq.b	#(\1),\2
			ELSE
				IFLE (\1)-16
					addq.b	#8,\2
					addq.b	#\1-8,\2
				ELSE
					add.b	#\1,\2
				ENDC
			ENDC
		ENDC
	ENDC
	IFC "W","\0"
		IFGE (\1)-$8000
			add.w	#\1,\2
		ELSE
			IFLE (\1)-8
				addq.w	#(\1),\2
			ELSE
				IFLE (\1)-16
					addq.w	#8,\2
					addq.w	#\1-8,\2
				ELSE
					add.w	#\1,\2
				ENDC
			ENDC
		ENDC
	ENDC
	IFC "L","\0"
		IFGE (\1)-$8000
		add.l	#\1,\2
		ELSE
			IFLE (\1)-8
				addq.l	#(\1),\2
			ELSE
				IFLE (\1)-16
					addq.l	#8,\2
					addq.l	#\1-8,\2
				ELSE						;Wenn Zahl > $0010, dann
					add.l	#\1,\2
				ENDC
			ENDC
			IFGE (\1)-$8000
				add.l	#\1,\2
			ENDC
		ENDC
	ENDC
	ENDM


SUBF				MACRO
; Input
; \0 STRING:	Size [B/W/L]
; \1 NUMBER:	8/16 bit source value
; \2 STRING:	Target
; Result
	IFC "","\0"
		FAIL Macro SUBF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro SUBF: 8/16 bit value missing
	ENDC
	IFC "","\2"
		FAIL Macro SUBF: Target missing
	ENDC
	IFEQ \1
		MEXIT
	ENDC
	IFC "B","\0"
		IFLE (\1)-8
			subq.b	#(\1),\2
		ELSE
			IFLE (\1)-16
				subq.b	#8,\2
				subq.b	#\1-8,\2
			ELSE
				sub.b	#\1,\2
			ENDC
		ENDC
	ENDC
	IFC "W","\0"
		IFLE (\1)-8
			subq.w	#(\1),\2
		ELSE
			IFLE (\1)-16
				subq.w	#8,\2
				subq.w	#\1-8,\2
			ELSE
				sub.w	#\1,\2
			ENDC
		ENDC
	ENDC
	IFC "L","\0"
		IFLE (\1)-8
			subq.l	#(\1),\2
		ELSE
			IFLE (\1)-16
				subq.l	#8,\2
				subq.l	#\1-8,\2
			ELSE
				sub.l	#\1,\2
			ENDC
		ENDC
	ENDC
	ENDM


MULUF				MACRO
; Input
; \0 STRING:	Size [B/W/L]
; \1 NUMBER:	16/32 bit factor
; \2 NUMBER:	Product
; \3 STRING:	Scratch register
; Result
	IFC "","\0"
		FAIL Macro MULUF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro MULUF: 16/32 bit factor missing
	ENDC
	IFC "","\2"
		FAIL Macro MULUF: Product missing
	ENDC
	IFEQ \1
		FAIL Macro MULUF: Factor is 0
	ENDC
	IFC "B","\0"
		IFGT \1-128
			FAIL Macro MULUF.B: Factor > 128
		ENDC
	ENDC
	IFEQ (\1)-2		 	; *2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-3			; *3
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-4			; *4
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-5			; *5
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-6			; *6
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-7			; *7
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-8			; *8
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-9			; *9
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-10			; *10
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-11			; *11
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-12			; *12
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-13			; *13
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-14			; *14
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-15			; *15
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-16			; *16
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-17			; *17
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-18			; *18
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\3
		sub.\0	\3,\2
;		lsl.\0	#3,\2
;		add.\0	\3,\2
;		add.\0	\2,\2
	ENDC
	IFEQ (\1)-19			; *19
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-20			; *20
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-22			; *22
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-23			; *23
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-24			; *24
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-25			; *25
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-28			; *28
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-29			; *29
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-30			; *30
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-31			; *31
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-32			; *32
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-33			; *33
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-34			; *34
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-35			; *35
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-36			; *36
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-37			; *37
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-38			; *38
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-40			; *40
		move.\0	\2,\3
		lsl.\0	#5,\2
		lsl.\0	#3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-41			; *41
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-42			; *42
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-44			; *44
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-45			; *45
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-46			; *46
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-47			; *47
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-48			; *48
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-49			; *49
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-50			; *50
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-51			; *51
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-55			; *55
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		lsl.\0	#3,\3
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-56			; *56
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-60			; *60
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-62			; *62
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-63			; *63
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-64			; *64
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-65			; *65
		move.\0	\2,\3
		lsl.\0	#6,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-66			; *66
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-67			; *67
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-68			; *68
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-70			; *70
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\3
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-72			; *72
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-74			; *74
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-76			; *76
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\3
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-80			; *80
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-84			; *84
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-88			; *88
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-92			; *92
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-94			; *94
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#5,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-96			; *96
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-104			; *104
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-110			; *110
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		lsl.\0	#3,\3
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-112			; *112
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-120			; *120
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-122			; *122
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\3,\3
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-124			; *124
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-126			; *126
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-127			; *127
		move.\0	\2,\3
		lsl.\0	#7,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-128			; *128
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-129			; *129
		move.\0	\2,\3
		lsl.\0	#7,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-130			; *130
		move.\0	\2,\3
		lsl.\0	#6,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-132			; *132
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-136			; *136
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-144			; *144
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-156			; *156
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#5,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-158			; *158
		move.\0 \2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
		add.\0	\3,\3
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-160			; *160
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-168			; *168
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-176			; *176
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-184			; *184
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-192			; *192
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-196			; *196
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-200			; *200
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-208			; *208
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-224			; *224
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-240			; *240
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-248			; *248
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-252			; *252
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-254			; *254
		move.\0	\2,\3
		lsl.\0	#7,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-255			; *255
		move.\0	\2,\3
		lsl.\0	#8,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-256			; *256
		lsl.\0	#8,\2
	ENDC
	IFEQ (\1)-257			; *257
		move.\0	\2,\3
		lsl.\0	#8,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-258			; *258
		move.\0	\2,\3
		lsl.\0	#7,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-260			; *260
		move.\0	\2,\3
		lsl.\0	#6,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-264			; *264
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-266			; *266
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-272			; *272
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-280			; *280
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-288			; *288
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-304			; *304
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-320			; *320
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-384			; *384
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-400			; *400
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-416			; *416
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-448			; *448
		move.\0	\2,\3
		lsl.\0	#8,\2
		lsl.\0	#5,\3
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-464			; *464
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\3,\3
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-480			; *480
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-512			; *512
		lsl.\0	#8,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-576			; *576
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-608			; *608
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-624			; *624
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-625			; *625
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-640			; *640
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-704			; *704
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-768			; *768
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
	ENDC
	IFEQ (\1)-832			; *832
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-896			; *896
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-960			; *960
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-1016			; *1016
		move.\0	\2,\3
		lsl.\0	#7,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-1024			; *1024
		lsl.\0	#8,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-1280			; *1280
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
	ENDC
	IFEQ (\1)-1920			; *1920
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-2048			; *2048
		lsl.\0	#8,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-2560			; *2560
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-3072			; *3072
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-8192			; *8192
		swap	\2
		asr.l	#3,\2
	ENDC
	ENDM


MULSF				MACRO
; Input
; \1 NUMBER:	16 bit signed factor
; \2 NUMBER:	Product
; \3 STRING:	Scratch register
; Result
	IFC "","\1"
		FAIL Macro MULSF: Signed factor missing
	ENDC
	IFC "","\2"
		FAIL Macro MULSF: Product missing
	ENDC
	IFEQ \1
		FAIL Macro MULSF: Factor is 0
	ENDC
	ext.l	\2
	MULUF.L \1,\2,\3
	ENDM


DIVUF				MACRO
; Input
; \0 STRING:	Size [W]
; \1 NUMBER:	Divisor
; \2 NUMBER:	Divident
; \3 STRING:	Scratch register
; Result
; \3 NUMBER	Result
	IFC "","\0"
		FAIL Macro DIVUF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro DIVUF: Divsor missing
	ENDC
	IFC "","\2"
		FAIL Macro DIVUF: Divident missing
	ENDC
	moveq	#-1,\3			; counter for result
divison_loop\@
	addq.w	#1,\3
	sub.w	\1,\2			; substract divisor from divident
	bge.s	divison_loop\@		; until dividend < divisor
	ENDM


CMPF MACRO
; Input
; \0 STRING:	Size [B/W/L]
; \1 NUMBER:	8/16/32 bit source
; \2 STRING:	target
; Result
	IFC "","\0"
		FAIL Macro CMPF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro CMPF: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro CMPF: Target missing
	ENDC
	IFEQ \1
		tst.\0	\2
	ELSE
		cmp.\0	#\1,\2
	ENDC
	ENDM


CPU_INIT_COLOR			MACRO
; Input
; \1 WORD:		First color register offset
; \2 BYTE_SIGNED:	Number of colors
; \3 POINTER:		Color table (optional)
; Result
	IFC "","\1"
		FAIL Macro CPU_INIT_COLOR: First color register offset missing
	ENDC
	IFC "","\2"
		FAIL Macro CPU_INIT_COLOR: Number of color values missing
	ENDC
	lea	(\1)-DMACONR(a6),a0	; first color register
	moveq	#\2-1,d7		; number of color values
	IFNC "","\3"
		lea	\3(pc),a1	; pointer color table
	ENDC
	bsr	cpu_init_colors
	ENDM


INIT_CHARACTERS_OFFSETS MACRO
; Input
; \0 STRING:	Size [W/L]
; \1 STRING:	Labels prefix
; Result
	CNOP 0,4
\1_init_characters_offsets
	IFC "","\0"
		FAIL Macro INIT_CHARACTERS_OFFSETS: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro INIT_CHARACTERS_OFFSETS: Labels prefix missing
	ENDC
	IFC "W","\0"
		moveq	#0,d0		; x offset first character
		moveq	#\1_image_plane_width,d1 ; X offset last character
		move.w	d1,d2		; x offset reset
		MOVEF.W \1_image_plane_width*\1_image_depth*(\1_origin_character_y_size+1),d3 ; y offset next character line
		lea	\1_characters_offsets(pc),a0
		moveq	#\1_ascii_end-\1_ascii-1,d7 ; number of font characters
\1_init_characters_offsets_loop
		move.w	d0,(a0)+	; xy character offset
		addq.w	#\1_origin_character_x_size/8,d0 ; X offset next character
		cmp.w	d1,d0		; last character in line ?
		bne.s	\1_no_x_offset_reset
\1_x_offset_reset
		sub.w	d2,d0		; reset x offset
		add.w	d3,d1		; y offset
		add.w	d3,d0		; y offset
\1_no_x_offset_reset
		dbf	d7,\1_init_characters_offsets_loop
		rts
	ENDC
	IFC "L","\0"
		lea	\1_characters_offsets(pc),a0
		moveq	#0,d0		; x offset first character
		moveq	#\1_image_plane_width,d1 ; x offset last character
		move.l	d1,d2		; x offset reset
		move.l	#\1_image_plane_width*\1_image_depth*(\1_origin_character_y_size),d3			Y-Offset für nächste Reihe der Zeichen in Zeichen-Playfieldvorlage
		moveq	#\1_ascii_end-\1_ascii-1,d7 ; number of font characters
\1_init_characters_offsets_loop
		move.l	d0,(a0)+	; xy offset character
		add.l	#\1_origin_character_x_size/8,d0 ; x offset next character
		cmp.l	d1,d0		; last character ?
		bne.s	\1_no_x_offset_reset
\1_x_offset_reset
		sub.l	d2,d0		; reset x offset
		add.l	d3,d1		; y offset
		add.l	d3,d0		; y offset
\1_no_x_offset_reset
		dbf	d7,\1_init_characters_offsets_loop
		rts
	ENDC
	ENDM


INIT_CHARACTERS_X_POSITIONS	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	Pixel resolution ["LORES", "HIRES", "SHIRES"]
; \3 STRING:	Read "BACKWARDS" (optional)
; \4 NUMBER:	Number of characters (optional)
; Result
	CNOP 0,4
\1_init_characters_x_positions
	IFC "","\1"
		FAIL Macro INIT_CHARACTERS_X_POSITIONS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_CHARACTERS_X_POSITIONS: Pixel resolution missing
	ENDC
	moveq	#0,d0			; first x position
	IFC "LORES","\2"
		moveq	#\1_text_character_x_size,d1 ; next character image
	ENDC
	IFC "HIRES","\2"
		moveq	#\1_text_character_x_size*2,d1 ; next character image
	ENDC
	IFC "SHIRES","\2"
		MOVEF.W	\1_text_character_x_size*4,d1 ; next character image
	ENDC
	IFNC "BACKWARDS","\3"
		lea	\1_characters_x_positions(pc),a0
	ELSE
		IFC "","\4"
			lea	\1_characters_x_positions+(\1_text_characters_number*WORD_SIZE)(pc),a0 ; table end
		ELSE
			lea	\1_characters_x_positions+((\1_\4)*WORD_SIZE)(pc),a0 ; table end
		ENDC
	ENDC
	IFC "","\4"
		moveq	#(\1_text_characters_number)-1,d7
	ELSE
		moveq	#(\1_\4)-1,d7	; number of characters
	ENDC
\1_init_characters_x_positions_loop
	IFNC "BACKWARDS","\3"
		move.w	d0,(a0)+	; x position
	ELSE
		move.w	d0,-(a0)	; x position
	ENDC
	add.w	d1,d0			; next x position
	dbf	d7,\1_init_characters_x_positions_loop
	rts
	ENDM


INIT_CHARACTERS_Y_POSITIONS		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	Number of characters (optional)
; Result
	CNOP 0,4
\1_init_characters_y_positions
	IFC "","\1"
		FAIL Macro INIT_CHARACTERS_Y_POSITIONS: Labels prefix missing
	ENDC
	moveq	#0,d0			; first y position
	moveq	#\1_text_character_y_size,d1 ; next y position
	lea	\1_characters_y_positions(pc),a0
	IFC "","\2"
		moveq	#(\1_text_characters_number)-1,d7
	ELSE
		moveq	#(\1_\2)-1,d7	; number of characters
	ENDC
\1_init_characters_y_positions_loop
	move.w	d0,(a0)+		; x position
	add.w	d1,d0			; next x position
	dbf	d7,\1_init_characters_y_positions_loop
	rts
	ENDM


INIT_CHARACTERS_IMAGES		MACRO
; Input
; \1 STRING:	Labels prefix
; Result
	CNOP 0,4
\1_init_characters_images
	IFC "","\1"
		FAIL Macro INIT_CHARACTERS_IMAGES: Labels prefix missing
	ENDC
	lea	\1_characters_image_pointers(pc),a2
	MOVEF.W	(\1_text_characters_number)-1,d7
\1_init_characters_images_loop
	bsr	\1_get_new_character_image
	move.l	d0,(a2)+		; character image
	dbf	d7,\1_init_characters_images_loop
	rts
	ENDM


GET_NEW_CHARACTER_IMAGE		MACRO
; Input
; \0 STRING:	Size [W/L]
; \1 STRING:	Labels prefix
; \2 LABEL:	Additional codes check sub routine (optional)
; \3 STRING:	"NORESTART" (optional)
; \4 STRING:	"BACKWARDS" (optional)
; Result
; d0.l		Pointer character image
	IFC "","\0"
		FAIL Macro GET_NEW_CHARACTER_IMAGE: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro GET_NEW_CHARACTER_IMAGE: Labels prefix missing
	ENDC
	CNOP 0,4
\1_get_new_character_image
	move.w	\1_text_table_start(a3),d1
	IFC "BACKWARDS","\4"
		bpl.s	\1_no_restart_text
		move.w	#\1_text_end-\1_text-1,d1 ; restart y posistion
\1_no_restart_text
	ENDC
	lea	\1_text(pc),a0
\1_read_character
	move.b	(a0,d1.w),d0		; ASCII code
	IFNC "","\2"
		bsr.s	\2
		tst.w	d0		; return value TRUE ?
		beq.s	\1_skip_control_code
	ENDC
	IFNC "BACKWARDS","\4"
		IFNC "NORESTART","\3"
			cmp.b	#FALSE,d0 ; end of scrolltext ?
			beq.s	\1_restart_text
		ENDC
	ENDC
	lea	\1_ascii(pc),a0
	moveq	#\1_ascii_end-\1_ascii-1,d6 ; number of characters
\1_get_new_character_image_loop
	cmp.b	(a0)+,d0		; code found ?
	dbeq	d6,\1_get_new_character_image_loop
	IFC "BACKWARDS","\4"
		subq.w	#BYTE_SIZE,d1	; next character
	ELSE
		IFLT \1_origin_character_x_size-32
			addq.w	#BYTE_SIZE,d1 ; next character
		ELSE
		IFNE \1_text_character_x_size-16
			addq.w	#BYTE_SIZE,d1 ; next character
		ENDC
		ENDC
	ENDC

	moveq	#\1_ascii_end-\1_ascii-1,d0 ; number of characters
	IFLT \1_origin_character_x_size-32
		move.w	d1,\1_text_table_start(a3)
	ELSE
		IFNE \1_text_character_x_size-16
			move.w	d1,\1_text_table_start(a3)
		ENDC
	ENDC
	sub.w	d6,d0			; number of characters
	lea	\1_characters_offsets(pc),a0
	IFC "W","\0"
		MULUFW	2,d0
		move.w	(a0,d0.w),d0	; character offset
	ENDC
	IFC "L","\0"
		MULUFW	4,d0
		move.l	(a0,d0.w),d0	; character offset
	ENDC
	add.l	\1_image(a3),d0
	IFNC "BACKWARDS","\4"
		IFEQ \1_origin_character_x_size-32
			IFEQ \1_text_character_x_size-16
				not.w	\1_character_toggle_image(a3) ; new character image ?
				bne.s	\1_no_second_image_part
\1_second_image_part
				addq.w	#BYTE_SIZE,d1 ; next character
				addq.l	#WORD_SIZE,d0 ; 2nd part character image
				move.w	d1,\1_text_table_start(a3)
\1_no_second_image_part
			ENDC
		ENDC
		IFGT \1_origin_character_x_size-32
			IFEQ \1_text_character_x_size-16
				moveq	#0,d3
				move.w	\1_character_words_counter(a3),d3
				move.l	d3,d4
				MULUF.W	2,d4 ; character image word offset
				addq.w	#BYTESIZE,d3 ; next part of character image
				add.l	d4,d0 ; character image address
				cmp.w	#\1_origin_character_x_size/16,d3 ; new character image ?
				bne.s	\1_keep_character_image
\1_next_character
				addq.w	#1,d1 ; nächster Buchstabe
				move.w	d1,\1_text_table_start(a3)
				moveq	#0,d3 ; reset words counter
\1_keep_character_image
				move.w	d3,\1_character_words_counter(a3)
			ENDC
		ENDC
	ENDC
	rts
	IFNC "BACKWARDS","\4"
		IFNC "","\2"
\1_skip_control_code
			addq.w	#BYTE_SIZE,d1 ; next character
			bra.s	\1_read_character
		ENDC
		IFNC "NORESTART","\3"
			CNOP 0,4
\1_restart_text
			moveq	#0,d1
			bra.s	\1_read_character
		ENDC
	ENDC
	ENDM


COPY_IMAGE_TO_BITPLANE		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 WORD:	X offset (optional)
; \3 WORD:	Y offset (optional)
; \4 POINTER:	Target image (optional)
; Result
	IFC "","\1"
		FAIL Macro COPY_IMAGE_TO_BITPLANE: Labels prefix missing
	ENDC
	CNOP 0,4
\1_copy_image_to_bitplane
	movem.l a4-a6,-(a7)
	IFNC "","\2"
		IFC "","\4"
			MOVEF.L (\2/8)+(\3*pf1_plane_width*pf1_depth3),d4
		ELSE
			MOVEF.L (\2/8)+(\3*\4_plane_width*\4_depth),d4
		ENDC
	ENDC
	lea	\1_image_data,a1	; source
	IFC "","\4"
		move.l	pf1_display(a3),a4 ; target
	ELSE
		move.l	\4(a3),a4	; target
	ENDC
	move.w	#(\1_image_plane_width*\1_image_depth)-\1_image_plane_width,a5
	IFC "","\4"
		move.w	#(pf1_plane_width*pf1_depth3)-\1_image_plane_width,a6
	ELSE
		move.w	#(\4_plane_width*\4_depth)-\1_image_plane_width,a6
	ENDC
	IFC "","\4"
		moveq	#pf1_depth3-1,d7
	ELSE
		moveq	#\4_depth-1,d7
	ENDC
\1_copy_image_to_bitplane_loop1
	bsr.s	\1_copy_image_data
	add.l	#\1_image_plane_width,a1 ; next bitplane
	dbf	d7,\1_copy_image_to_bitplane_loop1
	movem.l (a7)+,a4-a6
	rts
	CNOP 0,4
\1_copy_image_data
	move.l	a1,a0			; source
	move.l	(a4)+,a2		; target
	IFNC "","\2"
		add.l	d4,a2		; xy offset
	ENDC
	MOVEF.W	\1_image_y_size-1,d6
\1_copy_image_data_loop1
	moveq	#(\1_image_x_size/16)-1,d5
\1_copy_image_data_loop2
	move.w	(a0)+,(a2)+
	dbf	d5,\1_copy_image_data_loop2
	add.l	a5,a0			; next line in source
	add.l	a6,a2			; next line in target
	dbf	d6,\1_copy_image_data_loop1
	rts
	ENDM


INIT_DISPLAY_PATTERN		MACRO
; Input
; \1 STRING: Labels prefix
; \2 NUMBER: Column width
; Result
	IFC "","\1"
		FAIL Macro INIT_DISPLAY_PATTERN: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_DISPLAY_PATTERN: Column width missing
	ENDC
	CNOP 0,4
\1_init_display_pattern
	moveq	#0,d0			; columns counter
	moveq	#0,d1
	moveq	#1,d3			; first color number
	move.l	pf1_display(a3),a0
	move.l	(a0),a0
	moveq	#(cl2_display_width)-1,d7 ; number of columns
\1_init_display_pattern_loop1
	moveq	#\2-1,d6		; column width
\1_init_display_pattern_loop2
	move.w	d0,d1			; save columns counter
	move.w	d0,d2
	lsr.w	#3,d1			; x offset
	not.b	d2			; bit number
	btst	#0,d3
	beq.s	\1_no_set_pixel_bitplane0
	bset	d2,(a0,d1.l)
\1_no_set_pixel_bitplane0
	btst	#1,d3
	beq.s	\1_no_set_pixel_bitplane1
	bset	d2,pf1_plane_width*1(a0,d1.l)
\1_no_set_pixel_bitplane1
	btst	#2,d3
	beq.s	\1_no_set_pixel_bitplane2
	bset	d2,pf1_plane_width*2(a0,d1.l)
\1_no_set_pixel_bitplane2
	btst	#3,d3
	beq.s	\1_no_set_pixel_bitplane3
	bset	d2,pf1_plane_width*3(a0,d1.l)
\1_no_set_pixel_bitplane3
	btst	#4,d3
	beq.s	\1_no_set_pixel_bitplane4
	bset	d2,(pf1_plane_width*4,a0,d1.l)
\1_no_set_pixel_bitplane4
	btst	#5,d3
	beq.s	\1_no_set_pixel_bitplane5
	bset	d2,(pf1_plane_width*5,a0,d1.l)
\1_no_set_pixel_bitplane5
	btst	#6,d3
	beq.s	\1_no_set_pixel_bitplane6
	bset	d2,(pf1_plane_width*6,a0,d1.l)
\1_no_set_pixel_bitplane6
	addq.w	#1,d0			; next column
	dbf	d6,\1_init_display_pattern_loop2
	addq.w	#1,d3			; next color number
	dbf	d7,\1_init_display_pattern_loop1
	rts
	ENDM


GET_SINE_BARS_YZ_COORDINATES MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	Sine table length [256, 360, 512]
; \3 WORD:	Multiplicator y offset in copperlist
; Result
	IFC "","\1"
		FAIL Macro GET_SINE_BARS_YZ_COORDINATES: Labels-Prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro GET_SINE_BARS_YZ_COORDINATES: Sine table length missing
	ENDC
	IFC "","\3"
		FAIL Macro GET_SINE_BARS_YZ_COORDINATES: Multiplicator y offset in copperlist missing
	ENDC
	CNOP 0,4
\1_get_yz_coordinates
	IFEQ \2-256
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		addq.b	#\1_y_angle_speed,d0
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7
\1_get_yz_coordinates_loop
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.w	d2,d0
		MULUF.W	4,d0
		move.l	(a0,d0.w),d0	; sin(w)
		add.w	d2,d1		; - 90°
		ext.w	d1
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y ventre
		MULUF.W (\3)/4,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y position
		add.b	d3,d2		; y distance next bar
		dbf	d7,\1_get_yz_coordinates_loop
		rts
	ENDC
	IFEQ \2-360
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		MOVEF.W sine_table_length,d3 ; overflow
		addq.w	#\1_y_angle_speed,d0
		cmp.w	d3,d0		; 360° ?
		blt.s	\1_get_yz_coordinates_skip1
		sub.w	d3,d0		; reset y angle
\1_get_yz_coordinates_skip1
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W sine_table_length/2,d4 ; 180°
		MOVEF.W \1_y_distance,d5
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7
\1_get_yz_coordinates_loop
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.w	d2,d0
		MULUFW	4,d0
		move.l	(a0,d0.w),d0	; sin(w)
		add.w	d2,d1		; - 90°
		bmi.s	\1_get_yz_coordinates_skip2
		sub.w	d4,d1		; - 180°
		neg.w	d1
\1_get_yz_coordinates_skip2
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W (\3)/4,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; Y position
		add.w	d5,d2		; y distance next bar
		cmp.w	d3,d2		; 360° ?
		blt.s	\1_get_yz_coordinates_skip3
		sub.w	d3,d2		; reset y angle
\1_get_yz_coordinates_skip3
		dbf	d7,\1_get_yz_coordinates_loop
		rts
	ENDC
	IFEQ \2-512
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		MOVEF.W sine_table_length-1,d5 ; overflow
		addq.w	#\1_y_angle_speed,d0 ; next y angle
		and.w	d5,d0		; remove overflow
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		MOVEF.W sine_table_length/2,d4 ; 180°
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7
\1_get_yz_coordinates_loop
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.w	d2,d0
		MULUF.W	4,d0
		move.l	(a0,d0.w),d0	; sin(w)
		add.w	d2,d1		; - 90°
		bmi.s	\1_get_yz_coordinates_skip
		sub.w	d4,d1		; - 180°
		neg.w	d1
\1_get_yz_coordinates_skip
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W (\3)/4,d0,d1	; y offset in
		move.w	d0,(a1)+	; y position
		add.w	d3,d2		; next y angle
		and.w	d5,d2		; remove overflow
		dbf	d7,\1_get_yz_coordinates_loop
		rts
	ENDC
	ENDM


GET_TWISTED_BARS_YZ_COORDINATES MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	Sine table length [256, 360, 512]
; \3 WORD:	Multiplicator y offset in cl
; Result
	IFC "","\1"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Sine table length missing
	ENDC
	IFC "","\3"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Multiplicator y offset in copperlist missing
	ENDC
	CNOP 0,4
\1_get_yz_coordinates
	IFEQ \2-256
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		addq.b	#\1_y_angle_speed,d0
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\*LEFT(\3,3)_display_width-1,d7 ; number of columns
\1_get_yz_coordinates_loop1
		moveq	#\1_bars_number-1,d6
\1_get_yz_coordinates_loop2
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.w	d2,d0
		MULUF.W	4,d0
		move.l	(a0,d0.w),d0	; sin(w)
		add.w	d2,d1		; - 90°
		ext.w	d1
		move.w	d1,(a1)+	; z vectors
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W	(\3)/4,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; Y position
		add.b	d3,d2		; y distance next bar
		dbf	d6,\1_get_yz_coordinates_loop2
		IFGE \1_y_angle_step
			addq.b	#\1_y_angle_step,d2 ; next y angle
		ELSE
			subq.b	#-\1_y_angle_step,d2 ; next y angle
		ENDC
		dbf	d7,\1_get_yz_coordinates_loop1
		rts
	ENDC
	IFEQ \2-360
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		MOVEF.W sine_table_length,d3 ; overflow
		addq.w	#\1_y_angle_speed,d0
		cmp.w	d3,d0		; 360° ?
		blt.s	\1_get_yz_coordinates_skip1
		sub.w	d3,d0		; reset y angle
\1_get_yz_coordinates_skip1
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W sine_table_length/2,d4 ; 180°
		MOVEF.W \1_y_distance,d5
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\*LEFT(\3,3)_display_width-1,d7 ; number of colums
\1_get_yz_coordinates_loop1
		moveq	#\1_bars_number-1,d6
\1_get_yz_coordinates_loop2
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.w	d2,d0
		MULUF.W	4,d0
		move.l	(a0,d0.w),d0	; sin(w)
		add.w	d2,d1		; - 90°
		bmi.s	\1_get_yz_coordinates_skip2
		sub.w	d4,d1		; -180°
		neg.w	d1
\1_get_yz_coordinates_skip2
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W	(\3)/4,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y position
		add.w	d5,d2		; y distance next bar
		cmp.w	d3,d2		; 360° ?
		blt.s	\1_get_yz_coordinates_skip3
		sub.w	d3,d2		; reset y angle
\1_get_yz_coordinates_skip3
		dbf	d6,\1_get_yz_coordinates_loop2
		addq.w	#\1_y_angle_step,d2
		cmp.w	d3,d2		; 360° ?
		blt.s	\1_get_yz_coordinates_skip4
		sub.w	d3,d2		; reset y angle
\1_get_yz_coordinates_skip4
		dbf	d7,\1_get_yz_coordinates_loop1
		rts
	ENDC
	ENDM


COLOR_FADER			MACRO
; \1 STRING: Labels prefix
	IFC "","\1"
		FAIL Macro COLOR_FADER: Labels prefix missing
	ENDC
	CNOP 0,4
\1_fader_loop
	move.w	(a0),d0			; RGB4 current
	MOVEF.B	NIBBLE_MASK_HIGH,d1
	and.w	d0,d1			; G4 current
	moveq	#NIBBLE_MASK_LOW,d2
	and.w	d0,d2
	clr.b	d0			; R4 current

	move.w	(a1)+,d3		; RGB4 target
	MOVEF.B	NIBBLE_MASK_HIGH,d4	; G4 target
	and.w	d3,d4
	moveq	#NIBBLE_MASK_LOW,d5
	and.b	d3,d5			; B4 target
	clr.b	d3			; R4 target


; ** Rotwert **
\1_check_red_nibble
	cmp.w	d3,d0
	bgt.s	\1_decrease_red
	blt.s	\1_increase_red
\1_matched_red
	subq.w	#1,d6			; target value reached

; ** Grünwert **
\1_check_green_nibble
	cmp.w	d4,d1
	bgt.s	\1_decrease_green
	blt.s	\1_increase_green
\1_matched_green
	subq.w	#1,d6			; target value reached

; ** Blauwert **
\1_check_blue_nibble
	cmp.b	d5,d2
	bgt.s	\1_decrease_blue
	blt.s	\1_increase_blue
\1_matched_blue
	subq.w	#1,d6			; target value reached

\1_merge_rgb_nibbles
	move.w	d0,d3                   ; R00
	or.w	d1,d3			; RG0
	or.b	d2,d3			; RGB

; ** Farbwerte in Copperliste eintragen **
	move.l	d3,(a0)+		; RGB4
	dbf	d7,\1_fader_loop
	rts
	CNOP 0,4
\1_decrease_red
	sub.w	a2,d0
	cmp.w	d3,d0
	bgt.s	\1_check_green_nibble
	move.w	d3,d0
	bra.s	\1_matched_red
	CNOP 0,4
\1_increase_red
	add.w	a2,d0
	cmp.w	d3,d0
	blt.s	\1_check_green_nibble
	move.w	d3,d0
	bra.s	\1_matched_red
	CNOP 0,4
\1_decrease_green
	sub.w	a4,d1
	cmp.w	d4,d1
	bgt.s	\1_check_blue_nibble
	movewl	d4,d1
	bra.s	\1_matched_green
	CNOP 0,4
\1_increase_green
	add.w	a4,d1
	cmp.w	d4,d1
	blt.s	\1_check_blue_nibble
	move.w	d4,d1
	bra.s	\1_matched_green
	CNOP 0,4
\1_decrease_blue
	sub.b	a5,d2
	cmp.b	d5,d2
	bgt.s	\1_merge_rgb_nibbles
	move.b	d5,d2
	bra.s	\1_matched_blue
	CNOP 0,4
\1_increase_blue
	add.b	a5,d2
	cmp.b	d5,d2
	blt.s	\1_merge_rgb_nibbles
	move.b	d5,d2
	bra.s	\1_matched_blue
	ENDM


ROTATE_X_AXIS			MACRO
; Input
; d1.w	... y
; d2.w	... z
; Result
; d1.w	... y position
; d2.w	... z position
	move.w	d1,d3			; save y
	muls.w	d4,d1			; y*cos(a)
	swap	d4			; sin(w)
	move.w	d2,d7			; save z
	muls.w	d4,d3			; y*sin(a)
	muls.w	d4,d7			; z*sin(a)
	swap	d4			; cos(a)
	sub.l	d7,d1			; y*cos(a)-z*sin(a)
	muls.w	d4,d2			; z*cos(a)
	MULUF.L 2,d1			; y'=(y*cos(a)-z*sin(a))/2^15
	add.l	d3,d2			; y*sin(a)+z*cos(a)
	swap	d1			; y position
	MULUF.L 2,d2			; z'=(y*sin(a)+z*cos(a))/2^15
	swap	d2			; z position
	ENDM


ROTATE_Y_AXIS			MACRO
; Input
; d0.w	x
; d2.w	z
; Result
; d0.w	x position
; d2.w	z position
	move.w	d0,d3			; save x
	muls.w	d5,d0			; x*cos(b)
	swap	d5			; sin(b)
	move.w	d2,d7			; save z
	muls.w	d5,d3			; x*sin(b)
	muls.w	d5,d7			; z*sin(b)
	swap	d5			; cos(b)
	add.l	d7,d0			; x*cos(b)+z*sin(b)
	muls.w	d5,d2			; z*cos(b)
	MULUF.L 2,d0			; x'=(x*cos(b)+z*sin(b))/2^15
	sub.l	d3,d2			; z*cos(b)-x*sin(b)
	swap	d0			; x position
	MULUF.L 2,d2			; z'=(z*cos(b)-x*sin(b))/2^15
	swap	d2			; z position
	ENDM


ROTATE_Z_AXIS			MACRO
; Input
; d0.w	x
; d1.w	y
; Result
; d0.w	x position
; d1.w	y position
	move.w	d0,d3			; save x
	muls.w	d6,d0			; x*cos(c)
	swap	d6			; sin(c)
	move.w	d1,d7			; save y
	muls.w	d6,d3			; x*sin(c)
	muls.w	d6,d7			; y*sin(c)
	swap	d6			; cos(c)
	sub.l	d7,d0			; x*cos(c)-y*sin(c)
	muls.w	d6,d1			; y*cos(c)
	MULUF.L 2,d0			; x'=(x*cos(c)-y*sin(c))/2^15
	add.l	d3,d1			; x*sin(c)+y*cos(c)
	swap	d0			; x position
	MULUF.L 2,d1			; y'=(x)*sin(c)+y*cos(c))/2^15
	swap	d1			; y position
	ENDM



INIT_COLOR_GRADIENT_RGB4	MACRO
; Input
; \1 HEXNUMBER:		RGB4 current
; \2 HEXNUMBER:		RGB4 target
; \3 BYTE SIGNED:	Number of color values
; \4 NUMBER:		Color step for RGB (optional)
; \5 POINTER:		Color table (optional)
; \6 STRING:		Pointer base [pc,a3] (optional)
; \7 LONGWORD:		Offset next entry (optional)
; \8 LONGWORD:		Offset table start (optional)
; Result
	IFC "","\1"
		FAIL Macro COLOR_GRADIENT_RGB4: RGB4 current missing
	ENDC
	IFC "","\2"
		FAIL Macro COLOR_GRADIENT_RGB4: RGB4 target missing
	ENDC					
	IFC "","\3"
		FAIL Macro COLOR_GRADIENT_RGB4: Number of color values missing
	ENDC
	move.l	#\1,d0			; RGB4 current
	move.l	#\2,d6			; RGB4 target
	IFNC "","\5"
		IFC "pc","\6"
			lea	\5(\6),a0 ; pointer color table
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0 ; pointer color table
		ENDC
	ENDC
	IFNC "","\8"
		add.l	#(\8)*WORD_SIZE,a0 ; offset table start
	ENDC
	IFNC "","\4"
		move.w	#(\4)<<8,a1	; increase/decrease red
		move.w	#(\4)<<4,a2	; increase/decrease green
		move.w	#\4,a4		; increase/decrease blue
	ENDC
	IFNC "","\7"
		move.w	#(\7)*WORD_SIZE,a5 ; offset next entry
	ENDC
	MOVEF.W	\3-1,d7			; number of color values
	bsr	init_color_gradient_RGB4_loop
	ENDM


INIT_CUSTOM_ERROR_ENTRY		MACRO
; Input
; \1 BYTE_SIGNED:	Error number
; \2 POINTER:		Error text
; \3 BYTE_SIGNED:	Error text length
; Result
	IFC "","\1"
		FAIL Macro INIT_CUSTOM_ERROR_ENTRY: Error number missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_CUSTOM_ERROR_ENTRY: Error text missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_CUSTOM_ERROR_ENTRY: Error text length missing
	ENDC
	moveq	#\1-1,d0
	MULUF.W	8,d0,d1
	lea	\2(pc),a1
	move.l	a1,(a0,d0.w)
	moveq	#\3,d1
	move.l	d1,4(a0,d0.w)
	ENDM



INIT_INTUI_TEXT			MACRO
; Input
; \1 POINTER:	Intuition text structure
; \2 BYTE:	FrontPen
; \3 BYTE:	BackPen
; \4 WORD:	LeftEdge
; \5 WORD:	TopEdge
; \6 POINTER:	Text
; Result
	IFC "","\1"
		FAIL Macro INIT_INTUI_TEXT: Intuition text structure missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_INTUI_TEXT: FrontPen missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_INTUI_TEXT: BackPen missing
	ENDC
	IFC "","\4"
		FAIL Macro INIT_INTUI_TEXT: LeftEdge missing
	ENDC
	IFC "","\5"
		FAIL Macro INIT_INTUI_TEXT: TopEdge missing
	ENDC
	IFC "","\6"
		FAIL Macro INIT_INTUI_TEXT: Text missing
	ENDC
	lea	\1(pc),a0
        move.b	#\2,it_FrontPen(a0)
	move.b	#\3,it_BackPen(a0)
	moveq	#0,d0
	move.b	d0,it_DrawMode(a0)
	move.w	#\4,it_LeftEdge(a0)
	move.w	#\5,it_TopEdge(a0)
	move.l	d0,it_ITextFont(a0)
	lea	\6(pc),a1
	move.l	a1,it_IText(a0)
	move.l	d0,it_NextText(a0)
	ENDM
