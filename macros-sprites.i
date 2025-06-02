SET_SPRITE_POSITION			MACRO
; Input
; \1 WORD:	X position
; \2 WORD:	Y position
; \3 WORD:	Height
; Result
; \2 WORD:	SPRxPOS
; \3 WORD:	SPRxCTL
	IFC "","\1"
		FAIL Makro SET_SPRITE_POSITION: X position missing
	ENDC
	IFC "","\2"
		FAIL Makro SET_SPRITE_POSITION: Y position missing
	ENDC
	IFC "","\3"
		FAIL Makro SET_SPRITE_POSITION: Height missing
	ENDC
	lsl.w	#7,\3			; EV8 EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- ---
	lsl.w	#8,\2		 	; SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- --- ---
	addx.w	\3,\3			; EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- --- SV8
	addx.b	\3,\3			; EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- SV8 EV8
	lsr.w	#1,\1			; --- --- --- --- --- --- --- --- SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1
	addx.b	\3,\3			; EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- SV8 EV8 SH0 = SPRxCTL
	move.b	\1,\2			; SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1 = SPRxPOS
	ENDM


INIT_SPRITE_CONTROL_WORDS	MACRO
; Input
; \1 WORD:	X position
; \2 WORD:	Y position
; \3 WORD:	Height
; Result
; \2 LONGWORD:	low word SPRxCTL, high word SPRxPOS
	IFC "","\1"
		FAIL Makro INIT_SPRITE_CONTROL_WORDS: X position missing
	ENDC
	IFC "","\2"
		FAIL Makro INIT_SPRITE_CONTROL_WORDS: Y position missing
	ENDC
	IFC "","\3"
		FAIL Makro INIT_SPRITE_CONTROL_WORDS: Height missing
	ENDC
	SET_SPRITE_POSITION \1,\2,\3
	swap	\2			; high word: SPRxPOS
	move.w	\3,\2			; low word: SPRxCTL
	ENDM


INIT_SPRITE_POINTERS_TABLE	MACRO
; Input
; Result
	CNOP 0,4
spr_init_pointers_table
	IFNE spr_x_size1
		lea	spr0_construction(a3),a0
		lea	spr_pointers_construction(pc),a1
		moveq	#spr_number-1,d7
spr_init_pointers_table_loop1
		move.l	(a0)+,(a1)+
		dbf	d7,spr_init_pointers_table_loop1
	ENDC
	IFNE spr_x_size2
		lea	spr0_display(a3),a0
		lea	spr_pointers_display(pc),a1
		moveq	#spr_number-1,d7
spr_init_pointers_table_loop2
		move.l	(a0)+,(a1)+
		dbf	d7,spr_init_pointers_table_loop2
	ENDC
	rts
	ENDM


COPY_SPRITE_STRUCTURES		MACRO
; Input
; Result
	CNOP 0,4
spr_copy_structures
	move.l	a4,-(a7)
	lea	spr_pointers_construction(pc),a2
	lea	spr_pointers_display(pc),a4
	move.w	#(sprite0_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite1_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite2_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite3_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite4_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite5_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite6_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite7_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.l	(a7)+,a4
	rts
	CNOP 0,4
spr_copy_data
	move.l	(a2)+,a0		; source
	move.l	(a4)+,a1		; destination
spr_copy_data_loop
	move.l	(a0)+,(a1)+
	dbf	d7,spr_copy_data_loop
	rts
	ENDM


SWAP_SPRITES			MACRO
; Input
; \1 BYTE SIGNED:	Number of sprites
; \2 NUMBER:		Sprite structure pointer index [1,2,3,4,6,7] (optional)
; Result
	IFC "","\1"
		FAIL Macro SWAP_SPRITE_STRUCTURES: Number of sprites missing
	ENDC
	CNOP 0,4
swap_sprite_structures
	IFC "","\2"
		lea	spr_pointers_construction(pc),a0
		lea	spr_pointers_display(pc),a1
	ELSE
		lea	spr_pointers_construction+(\3*LONGWORD_SIZE)(pc),a0
		lea	spr_pointers_display+(\2*LONGWORD_SIZE)(pc),a1
	ENDC
	moveq	#\1-1,d7		; number of sprites
swap_sprite_structures_loop
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	dbf	d7,swap_sprite_structures_loop
	rts
	ENDM


SET_SPRITES			MACRO
; Input
; \1 BYTE SIGNED:	Number of sprites
; \2 NUMBER:		Sprite structure pointer index [1,2,3,4,6,7] (optional)
; Result
	IFC "","\1"
		FAIL Macro SWAP_SPRITE_STRUCTURES: Number of sprites missing
	ENDC
	CNOP 0,4
set_sprite_pointers
	move.l	cl1_display(a3),a0 
	IFC "","\2"
		lea	spr_pointers_display(pc),a1
		ADDF.W	cl1_SPR0PTH+WORD_SIZE,a0
	ELSE
		lea	spr_pointers_display+(\2*LONGWORD_SIZE)(pc),a1
		ADDF.W	cl1_SPR\3PTH+WORD_SIZE,a0
	ENDC
	moveq	#\1-1,d7		; number of sprites
set_sprite_pointers_loop
	move.w	(a1)+,(a0)		; SPRxPTH
	addq.w	#QUADWORD_SIZE,a0
	move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; SPRxPTL
	dbf	d7,set_sprite_pointers_loop
	rts
	ENDM
