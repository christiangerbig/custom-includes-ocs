SET_SPRITE_POSITION		MACRO
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
	rol.w	#8,\2			;  SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- --- SV8
	lsl.w	#5,\1			; SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1 SH0 --- --- --- --- ---
	lsl.w	#8,\3			;  EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- --- ---
	addx.b	\2,\2			;  --- --- --- --- --- --- SV8 EV8
	add.b	\1,\1			;  SH1 SH0 --- --- --- --- --- ---
	addx.b	\2,\2			;  --- --- --- --- --- SV8 EV8 SH2
	lsr.b	#3,\1			;  --- --- --- SH1 SH0 --- --- ---
	or.b	\1,\2			;  --- --- --- SH1 SH0 SV8 EV8 SH2
	lsr.w	#8,\1			;  --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	move.b	\2,\3			;  EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0	--- --- --- SH1 SH0 SV8 EV8 SH2
	move.b	\1,\2			;  SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	ENDM


SET_SPRITE_POSITION_1X		MACRO
; Input
; \1 WORD:	X position
; \2 WORD:	Y position
; \3 WORD:	Height
; Result
; \2 LONGWORD:	low word SPRxCTL, high word SPRxPOS
	IFC "","\1"
		FAIL Makro SET_SPRITE_POSITION_1X: X position missing
	ENDC
	IFC "","\2"
		FAIL Makro SET_SPRITE_POSITION_1X: Y position missing
	ENDC
	IFC "","\3"
		FAIL Makro SET_SPRITE_POSITION_1X: Height missing
	ENDC
	SET_SPRITE_POSITION \1,\2,\3
	swap	\2			; SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
	move.w	\3,\2			; SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 --- --- --- SH1 SH0 SV8 EV8 SH2
	ENDM


INIT_SPRITE_POINTERS_TABLE	MACRO
; Input
; Result
	CNOP 0,4
spr_init_ptrs_table
	IFNE spr_x_size1
		lea	spr0_construction(a3),a0
		lea	spr_ptrs_construction(pc),a1
		moveq	#spr_number-1,d7
spr_init_ptrs_table_loop1
		move.l	(a0)+,a2
		move.l	(a2),(a1)+
		dbf	d7,spr_init_ptrs_table_loop1
	ENDC
	IFNE spr_x_size2
		lea	spr0_display(a3),a0
		lea	spr_ptrs_display(pc),a1
		moveq	#spr_number-1,d7
spr_init_ptrs_table_loop2
		move.l	(a0)+,a2
		move.l	(a2),(a1)+
		dbf	d7,spr_init_ptrs_table_loop2
	ENDC
	rts
	ENDM


COPY_SPRITE_STRUCTURES		MACRO
; Input
; Result
	CNOP 0,4
spr_copy_structures
	move.l	a4,-(a7)
	lea	spr_ptrs_construction(pc),a2
	lea	spr_ptrs_display(pc),a4
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


SWAP_SPRITES_STRUCTURES		MACRO
; Input
; \1 STRING:		Labels prefix
; \2 BYTE SIGNED:	Number of sprites
; \3 NUMBER:		Index [1,2,3,4,6,7] (optional)
	IFC "","\1"
		FAIL Makro SWAP_SPRITES_STRUCTURES: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Makro SWAP_SPRITES_STRUCTURES: Number of sprites missing
	ENDC
	CNOP 0,4
\1_swap_structures
	IFC "","\3"
		lea	spr_ptrs_construction(pc),a0
		lea	spr_ptrs_display(pc),a1
	ELSE
		lea	spr_ptrs_construction+(\3*4)(pc),a0
		lea	spr_ptrs_display+(\3*4)(pc),a1
	ENDC
	moveq	#\2-1,d7		; number of sprites
\1_swap_structures_loop
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	dbf	d7,\1_swap_structures_loop

	move.l	cl1_display(a3),a0 
	IFC "","\3"
		lea	spr_ptrs_display(pc),a1
		ADDF.W	cl1_SPR0PTH+WORD_SIZE,a0
	ELSE
		lea	spr_ptrs_display+(\3*4)(pc),a1 ; with index
		ADDF.W	cl1_SPR\3PTH+WORD_SIZE,a0
	ENDC
	moveq	#\2-1,d7		; Number of sprites
\1_set_sprite_ptrs_loop
	move.w	(a1)+,(a0)		; SPRxPTH
	addq.w	#QUADWORD_SIZE,a0
	move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; SPRxPTL
	dbf	d7,\1_set_sprite_ptrs_loop
	rts
	ENDM
