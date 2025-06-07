COP_MOVE			MACRO
; Input
; \1 WORD:	Source 16 bit value
; \2 WORD:	CUSTOM register offset
; Result
	IFC "","\1"
		FAIL Macro COP_MOVE: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_MOVE: Custom register offset missing
	ENDC
	move.w	#\2,(a0)+		; CUSTOM register offset
	move.w	\1,(a0)+		; register value
	ENDM


COP_MOVEQ			MACRO
; Input
; \1 WORD:	Source 16 bit value
; \2 WORD:	CUSTOM register offset
; Result
	IFC "","\1"
		FAIL Macro COP_MOVEQ: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_MOVEQ: Custom register offset missing
	ENDC
		move.l	#((\2)<<16)|((\1)&$ffff),(a0)+ ; CUSTOM-Registeroffset + Wert für Register
	ENDM


COP_WAIT			MACRO
; Input
; \1 BYTE:	X position (bits 2..8)
; \2 BYTE:	Y Position (bits 0..7)
; Result
	IFC "","\1"
		FAIL Macro COP_WAIT: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_WAIT: Y position missing
	ENDC
		move.l	#((((\2)<<24)|((((\1)/4)*2)<<16))|$10000)|$fffe,(a0)+ ; CWAIT
	ENDM


COP_WAITBLIT			MACRO
; Input
; Result
	move.l	#$00010000,(a0)+
	ENDM


COP_WAITBLIT2			MACRO
; Input
; \1 BYTE:	X position (bits 2..8)
; \2 BYTE: 	Y position (bits 0..7)
; Result
	IFC "","\1"
		FAIL Macro COP_WAITBLIT2: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_WAITBLIT2: Y position missing
	ENDC
		move.l	#((((\2)<<24)|((((\1)/4)*2)<<16))|$10000)|$7ffe,(a0)+
	ENDM


COP_SKIP MACRO
; \1 BYTE:	X position (bits 2..8)
; \2 BYTE:	Y position (bits 0..7)
	IFC "","\1"
		FAIL Macro COP_SKIP: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_SKIP: Y position missing
	ENDC
		move.l	#((\2)<<24)|((((\1)/4)*2)<<16)|$ffff,(a0)+ ; CSKIP
	ENDM


COP_LISTEND MACRO
; Input
; \1 STRING:	["SAVETAIL"] (optional)
; Result
	moveq	#-2,d0
	move.l	d0,(a0)
	IFC "SAVETAIL","\1"
		move.l	a0,cl_end(a3)
	ENDC
	ENDM


COP_INIT_PLAYFIELD_REGISTERS	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["NOBITPLANES", "BLANK"] type of display
; \3 STRING:	["vp1", "vp2".."vpn"] viewport label prefix (optional)
; \4 STRING	["TRIGGERBITPLANES"] inititialize BPLCON0 (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_PLAYFIELD_REGISTERS: Labels prefix missing
	ENDC
	IFC "","\1"
		FAIL Macro COP_INIT_PLAYFIELD_REGISTERS: Type of display missing
	ENDC
	CNOP 0,4
	IFC "","\3"
\1_init_playfield_props
		IFC "","\2"
			COP_MOVEQ diwstrt_bits,DIWSTRT
			COP_MOVEQ diwstop_bits,DIWSTOP
			COP_MOVEQ ddfstrt_bits,DDFSTRT
			COP_MOVEQ ddfstop_bits,DDFSTOP
			COP_MOVEQ bplcon0_bits,BPLCON0
			COP_MOVEQ bplcon1_bits,BPLCON1
			COP_MOVEQ bplcon2_bits,BPLCON2
			COP_MOVEQ pf1_plane_moduli,BPL1MOD
			IFGT pf_depth-1
				IFD pf2_plane_moduli
					COP_MOVEQ pf2_plane_moduli,BPL2MOD
				ELSE
					COP_MOVEQ pf1_plane_moduli,BPL2MOD
				ENDC
			ENDC
			rts
		ELSE
			IFC "NOBITPLANES","\2"
				COP_MOVEQ diwstrt_bits,DIWSTRT
				COP_MOVEQ diwstop_bits,DIWSTOP
				COP_MOVEQ bplcon0_bits,BPLCON0
				rts
			ENDC
			IFC "BLANK","\2"
				COP_MOVEQ bplcon0_bits,BPLCON0
				rts
			ENDC
		ENDC
	ELSE
\1_\3_init_playfield_props
		COP_MOVEQ \3_ddfstrt_bits,DDFSTRT
		COP_MOVEQ \3_ddfstop_bits,DDFSTOP
		IFC "TRIGGERBITPLANES","\4"
			COP_MOVEQ \3_bplcon0_bits,BPLCON0
		ENDC
		COP_MOVEQ \3_bplcon1_bits,BPLCON1
		COP_MOVEQ \3_bplcon2_bits,BPLCON2
		COP_MOVEQ \3_pf1_plane_moduli,BPL1MOD
		IFD \3_pf2_plane_moduli
			COP_MOVEQ \3_pf2_plane_moduli,BPL2MOD
		ELSE
			COP_MOVEQ \3_pf1_plane_moduli,BPL2MOD
		ENDC
		rts
	ENDC
	ENDM


COP_INIT_BITPLANE_POINTERS	MACRO
; Input
; \1 STRING:	Labels prefix
	IFC "","\1"
		FAIL Macro COP_INIT_BITPLANE_POINTERS: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_bitplane_pointers
	move.w	#BPL1PTH,d0
	moveq	#(pf_depth*2)-1,d7
\1_init_bitplane_pointers_loop
	move.w	d0,(a0)			; BPLxPTH/L
	addq.w	#WORD_SIZE,d0		; next register
	addq.w	#LONGWORD_SIZE,a0	; next entry in cl
	dbf	d7,\1_init_bitplane_pointers_loop
	rts
	ENDM


COP_SET_BITPLANE_POINTERS	MACRO
; Input
; \1 STRING:		Labels prefix
; \2 STRING:		["construction1", "construction2", "display"] name of copperlist
; \3 BYTE SIGNED:	Number of bitplanes playfield1
; \4 BYTE SIGNED:	Number of bisplanes playfield2 (optional)
; \5 WORD:		X offset (optional)
; \6 WORD:		Y offset (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_SET_BITPLANE_POINTERS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_SET_BITPLANE_POINTERS: Name of copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_SET_BITPLANE_POINTERS: Number of bitplanes playfield1 missing
	ENDC
	CNOP 0,4
\1_set_bitplane_pointers
	IFC "","\4"
		IFC "","\5"
			move.l	pf1_display(a3),d0
			move.l	\1_\2(a3),a0
			ADDF.W	\1_BPL1PTH+WORD_SIZE,a0
			move.w	#pf1_plane_width,a1
			moveq	#\3-1,d7 ; number of bitplanes
\1_set_bitplane_pointers_loop
			swap	d0
			move.w	d0,(a0) ; BPLxPTH
			swap	d0
			addq.w	#QUADWORD_SIZE,a0
			move.w	d0,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
			add.l	a1,d0	; next bitplane
			dbf	d7,\1_set_bitplane_pointers_loop
		ELSE
			MOVEF.L	(\5/8)+(\6*pf1_plane_width*pf1_depth3),d1
			move.l	pf1_display(a3),d2
			move.l	\1_\2(a3),a0
			ADDF.W	\1_BPL1PTH+WORD_SIZE,a0
			move.w	#pf1_plane_width,a1
			moveq	#\3-1,d7 ; number of bitplanes
\1_set_bitplane_pointers_loop
			move.l	d2,d0
			add.l	d1,d0
			move.w	d0,4(a0) ; BPLxPTL
			swap	d0
			move.w	d0,(a0)	; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			add.l	a1,d2	; next bitplane
			dbf	d7,\1_set_bitplane_pointers_loop
		ENDC
	ELSE
; Playfield 1
		move.l	pf1_display(a3),d0
		move.l	\1_\2(a3),a0
		lea	\1_BPL2PTH+2(a0),a1
		ADDF.W	\1_BPL1PTH+WORD_SIZE,a0
		move.w	#p1_plane_width,a2
		moveq	#\3-1,d7	; number of bitplanes
\1_set_bitplane_pointers_loop1
		swap	d0
		move.w	d0,(a0)		; BPLxPTH
		swap	d0
		ADDF.W	QUADWORD_SIZE*2,a0
		move.w	d0,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a0) ; BPLxPTL
		add.l	a2,d0		; next bitplane
		dbf	d7,\1_set_bitplane_pointers_loop1
; Playfield 2
		move.l	pf2_display(a3),d0
		move.w	#p2_plane_width,a2
		moveq	#\4-1,d7	; number of bitplanes
\1_set_bitplane_pointers_loop2
		swap	d0
		move.w	d0,(a1)		; BPLxPTH
		swap	d0
		ADDF.W	QUADWORD_SIZE*2,a1
		move.w	d0,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a1) ; BPLxPTL
		add.l	a2,d0		; next bitplane
		dbf	d7,\1_set_bitplane_pointers_loop2
	ENDC
	rts
	ENDM


COP_INIT_SPRITE_POINTERS	MACRO
; Input
; \1 STRING:	Labels prefix
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_SPRITE_POINTERS: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_sprite_pointers
	move.w	#SPR0PTH,d0
	moveq	#(spr_number*2)-1,d7	; number of bitplanes
\1_init_sprite_pointers_loop
	move.w	d0,(a0)			; SPRxPTH/L
	addq.w	#WORD_SIZE,d0		; next register
	addq.w	#LONGWORD_SIZE,a0	; next entry in cl
	dbf	d7,\1_init_sprite_pointers_loop
	rts
	ENDM


COP_SET_SPRITE_POINTERS		MACRO
; Input
; \1 STRING:		Labels prefix
; \2 STRING:		["construction1", "construction2", "display"] name of copperlist
; \3 BYTE SIGNED:	[1..8] number of sprites
; \4 NUMBER:		[1..7] index (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_SET_SPRITE_POINTERS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_SET_SPRITE_POINTERS: Name of copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_SET_SPRITE_POINTERS: Number of sprites missing
	ENDC
	CNOP 0,4
\1_set_sprite_pointers
	move.l	\1_\2(a3),a0
	IFC "","\4"
		lea	spr_pointers_display(pc),a1
		ADDF.W	\1_SPR0PTH+WORD_SIZE,a0
	ELSE
		lea	spr_pointers_display+(\4*4)(pc),a1 ; with index
		ADDF.W	\1_SPR\3PTH+WORD_SIZE,a0
	ENDC
	moveq	#\3-1,d7		; number of sprites
\1_set_sprite_pointers_loop
	move.w	(a1)+,(a0)		; SPRxPTH
	addq.w	#QUADWORD_SIZE,a0
	move.w	(a1)+,4-8(a0)		; SPRxPTL
	dbf	d7,\1_set_sprite_pointers_loop
	rts
	ENDM


COP_INIT_COLOR			MACRO
; Input
; \1 WORD:		First color register offset
; \2 BYTE_SIGNED:	Number of color values
; \3 POINTER:		Color table (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COLOR: First color register offset missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_COLOR: Number of color values missing
	ENDC
	move.w	#\1,d3			; first color register offset
	moveq	#\2-1,d7		; number of colors
	IFNC "","\3"
		lea	\3(pc),a1	; pointer color table
	ENDC

	bsr	cop_init_colors
	ENDM


COP_INIT_COLOR00_SCREEN	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["YWRAP"] (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COLOR00_SCREEN: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_color00
	move.l	#(((\1_vstart1<<24)|(((\1_hstart1/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#(COLOR00<<16)|color00_bits,d1
	IFC "YWRAP","\2"
		move.l	#(((CL_Y_WRAPPING<<24)|(((\1_hstart1/4)*2)<<16))|$10000)|$fffe,d5 ; CWAIT
	ENDC
	move.l	#$01000000,d6
	MOVEF.W	\1_display_y_size-1,d7
\1_init_color00_loop
	move.l	d0,(a0)+		; CWAIT x,y
	move.l	d1,(a0)+		; COLOR00
	IFC "YWRAP","\2"
		cmp.l	d5,d0		; y wrapping ?
		bne.s	no_patch_copperlist2
patch_copperlist2
		COP_WAIT CL_X_WRAPPING,CL_Y_WRAPPING ; patch cl
		bra.s	 \1_init_color00_skip
		CNOP 0,4
no_patch_copperlist2
		COP_MOVEQ 0,NOOP
\1_init_color00_skip
	ENDC
	add.l	d6,d0			; next raster line
	dbf	d7,\1_init_color00_loop
	rts
	ENDM


COP_INIT_COLOR00_CHUNKY		MACRO
; Input
; \1 STRING:	["cl1", "cl2"] label prefix copperlist
; \2 NUMBER:	HSTART
; \3 NUMBER:	VSTART
; \4 NUMBER:	Width
; \5 NUMBER:	Height
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COLOR00_CHUNKY: Label prefix copperlist missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_COLOR00_CHUNKY: HSTART missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_INIT_COLOR00_CHUNKY: VSTART missing
	ENDC
	IFC "","\4"
		FAIL Macro COP_INIT_COLOR00_CHUNKY: Width missing
	ENDC
	IFC "","\5"
		FAIL Macro COP_INIT_COLOR00_CHUNKY: Height missing
	ENDC
	CNOP 0,4
\1_init_color00_chunky
	move.l	#(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#(COLOR00<<16)|(COLOR00_bits),d1
	move.l	#$01000000,d2
	MOVEF.W	\5-1,d7		; number of lines
\1_init_color00_chunky_loop1
	move.l	d0,(a0)+	; CWAIT x,y
	moveq	#(\4/8)-1,d6	; number of columns
\1_init_color00_chunky_loop2
	move.l	d1,(a0)+	; COLOR00
	dbf	d6,\1_init_color00_chunky_loop2
	add.l	d2,d0		; next line in cl
	dbf	d7,\1_init_color00_chunky_loop1
	rts
	ENDM


COP_INIT_BPLCON1_CHUNKY	MACRO
; Input
; \1 STRING:	["cl1", "cl2"] labels prefix copperlist
; \2 NUMBER:	HSTART
; \3 NUMBER:	VSTART
; \4 NUMBER:	width
; \5 NUMBER:	height
; \6 WORD:	alternative BPLCON1 bits (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: Labels prefix copperliste missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: HSTART missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: VSTART missing
	ENDC
	IFC "","\4"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: Width missing
	ENDC
	IFC "","\5"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: Height missing
	ENDC
	CNOP 0,4
\1_init_bplcon1s
	move.l	#(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	IFC "","\6"
		move.l	#(BPLCON1<<16)|bplcon1_bits,d1
	ELSE
		move.l	#(BPLCON1<<16)|\6,d1
	ENDC
	move.l	#$01000000,d3
	MOVEF.W \5-1,d7
\1_init_bplcon1s_loop1
	move.l	d0,(a0)+		; CWAIT x,y
	moveq	 #(\4/8)-1,d6		; number of colums
\1_init_bplcon1s_loop2
	move.l	d1,(a0)+		; BPLCON1
	dbf	d6,\1_init_bplcon1s_loop2
	add.l	d3,d0			; next raster line
	dbf	d7,\1_init_bplcon1s_loop1
	rts
	ENDM


COP_INIT_DISPLAY_VSTOP		MACRO
; Input
; \1 STRING:	["cl1", "cl2"] labels prefix copperlist
; \2 WORD:	X position
; \3 WORD:	Y postion
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_DISPLAY_VSTOP: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_DISPLAY_VSTOP: X position missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_INIT_DISPLAY_VSTOP: Y position missing
	ENDC
	CNOP 0,4
\1_init_display_vstop
	COP_WAIT \2,\3
	COP_MOVEQ BPLCON0F_COLOR,BPLCON0
	rts
	ENDM


COP_INIT_COPINT			MACRO
; Input
; \1 STRING:	["cl1", "cl2"] labels prefix copperlist
; \2 WORD:	X position (optional)
; \3 WORD:	Y postion (optional)
; \4 STRING:	["YWRAP"] (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COPINT: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_copper_interrupt
	IFC "YWRAP","\4"
		COP_WAIT CL_X_WRAPPING,CL_Y_WRAPPING ; patch cl
	ENDC
	IFNC "","\2"
		IFNC "","\3"
			COP_WAIT \2,\3
		ENDC
	ENDC
	COP_MOVEQ INTF_COPER|INTF_SETCLR,INTREQ
	rts
	ENDM


COPY_COPPERLIST			MACRO
; Input
; \1 STRING:	["cl1", "cl2"] labels prefix copperlist
; \2 NUMBER:	[2, 3] number of copperlists
; Result
	IFC "","\1"
		FAIL Macro COPY_COPPERLIST: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COPY_COPPERLIST: Number of copperlists missing
	ENDC
	CNOP 0,4
	IFC "cl1","\1"
copy_first_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0 ; source
			move.l	\1_display(a3),a1 ; destination
			move.w	#(copperlist1_size/LONGWORD_SIZE)-1,d7 ; number of commands
copy_first_copperlist_loop
			move.l	(a0)+,(a1)+
			dbf	d7,copy_first_copperlist_loop
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0 ;Quelle
			move.l	\1_construction2(a3),a1 ;1. Ziel
			move.w	#(copperlist1_size/LONGWORD_SIZE)-1,d7 ; number of commands
			move.l	\1_display(a3),a2 ;2. Ziel
copy_first_copperlist_loop
			move.l	(a0),(a1)+
			move.l	(a0)+,(a2)+
			dbf	d7,copy_first_copperlist_loop
			rts
		ENDC
	ENDC
	IFC "cl2","\1"
copy_second_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0 ; source
			move.l	\1_display(a3),a1 ; destination
			move.w	#(copperlist2_size/LONGWORD_SIZE)-1,d7 ; number of commands
copy_second_copperlist_loop
			move.l	(a0)+,(a1)+
			dbf	d7,copy_second_copperlist_loop
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0 ; source
			move.l	\1_construction2(a3),a1 ; destination
			move.w	#(copperlist2_size/LONGWORD_SIZE)-1,d7 ; number of commands
			move.l	\1_display(a3),a2 ; 2. Ziel
copy_second_copperlist_loop
			move.l	(a0),(a1)+
			move.l	(a0)+,(a2)+
			dbf	d7,copy_second_copperlist_loop
			rts
		ENDC
	ENDC
	ENDM


CONVERT_IMAGE_TO_RGB4_CHUNKY	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	BPLAM table
; \3 STRING:	["pc", "a3"] pointer base
; Result
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_RGB4_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_RGB4_CHUNKY: Pointer BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_RGB4_CHUNKY: Pointer base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	move.l	a4,-(a7)
	lea	\1_image_data,a0
	lea	\1_image_color_table(pc),a1
	IFC "","\2"
		lea	\1_\2(\3),a2
	ELSE
		move.l	\2(\3),a2
	ENDC
	move.w	#\1_image_plane_width*(\1_image_depth-1),a4
	moveq	#16,d1			; COLOR16
	MOVEF.W	\1_image_y_size-1,d7
\1_convert_image_data_loop1
	moveq	#\1_image_plane_width-1,d6
\1_convert_image_data_loop2
	moveq	#8-1,d5			; number of bits per byte
\1_convert_image_data_loop3
	moveq	#0,d0			; color number
	IFGE \1_image_depth-1
		btst	d5,(a0)
		beq.s	\1_no_plane0
		addq.w	#1,d0		; COLOR01
\1_no_plane0
	ENDC
	IFGE \1_image_depth-2
		btst	d5,\1_image_plane_width*1(a0)
		beq.s	\1_no_plane1
		addq.w	#2,d0		; COLOR02
\1_no_plane1
	ENDC
	IFGE \1_image_depth-3
		btst	d5,\1_image_plane_width*2(a0)
		beq.s	\1_no_plane2
		addq.w	#4,d0		; COLOR04
\1_no_plane2
	ENDC
	IFGE \1_image_depth-4
		btst	d5,\1_image_plane_width*3(a0)
		beq.s	\1_no_plane3
		addq.w	#8,d0		; COLOR08
\1_no_plane3
	ENDC
	IFEQ \1_image_depth-5
		btst	d5,\1_image_plane_width*4(a0)
		beq.s	\1_no_plane4
		add.w	d1,d0		; COLOR16
\1_no_plane4
	ENDC
	move.w	(a1,d0.l*2),(a2)+	; RGB4
	dbf	d5,\1_convert_image_data_loop3
	addq.w	#BYTE_SIZE,a0		; next byte
	dbf	d6,\1_convert_image_data_loop2
	add.l	a4,a0			; skip remaining bitplanes
	dbf	d7,\1_convert_image_data_loop1
	move.l	(a7)+,a4
	rts
	ENDM


CONVERT_IMAGE_TO_HAM6_CHUNKY	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	BPLAM table
; \3 STRING:	["pc", "a3"] pointer base
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_HAM6_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_HAM6_CHUNKY: BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_HAM6_CHUNKY: Pointer base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	movem.l	a4-a6,-(a7)
	lea	\1_image_data,a0
	lea	\1_image_color_table(pc),a1
	IFC "","\2"
		lea	\1_\2(\3),a2
	ELSE
		move.l	\2(\3),a2
	ENDC
	move.w	#16,a4			; COLOR16
	move.w	#32,a5			; COLOR32
	move.w	#\1_image_plane_width*(\1_image_depth-1),a6
	moveq	#$30,d3
	moveq	#NIBBLE_MASLK_LOW,d4
	MOVEF.W	\1_image_y_size-1,d7
\1_convert_image_data_loop1
	moveq	#0,d2			; RGB4 (COLOR00)
	moveq	#\1_image_plane_width-1,d6 ; width in bytes
\1_convert_image_data_loop2
	moveq	#8-1,d5			; number of bits per byte
\1_convert_image_data_loop3
	moveq	#0,d0			; color number
	btst	d5,(a0)
	beq.s	\1_no_plane0
	addq.w	#1,d0
\1_no_plane0
	btst	d5,\1_image_plane_width*1(a0)
	beq.s	\1_no_plane1
	addq.w	#2,d0
\1_no_plane1
	btst	d5,\1_image_plane_width*2(a0)
	beq.s	\1_no_plane2
	addq.w	#4,d0
\1_no_plane2
	btst	d5,\1_image_plane_width*3(a0)
	beq.s	\1_no_plane3
	addq.w	#8,d0
\1_no_plane3
	btst	d5,\1_image_plane_width*4(a0)
	beq.s	\1_no_plane4
	add.w	a4,d0
\1_no_plane4
	btst	d5,\1_image_plane_width*5(a0)
	beq.s	\1_no_plane5
	add.w	a5,d0
\1_no_plane5
	move.l	d0,d1
	and.b	d3,d1
	bne.s	\1_check_blue_nibble
\1_use_color_register
	move.w	(a1,d0.l*2),d2		; RGB4
	bra.s	\1_set_rgb_nibbles
	CNOP 0,4
\1_check_blue_nibble
	cmp.b	#$10,d1			; modify blue ?
	bne.s	\1_check_red_nibble
	and.w	#$ff0,d2
	and.w	d4,d0
	or.b	d0,d2			; new blue
	bra.s	\1_set_rgb_nibbles
	CNOP 0,4
\1_check_red_nibble
	cmp.b	#$20,d1			; modify red ?
	bne.s	\1_check_green_nibble
	and.w	#$0ff,d2
	and.w	d4,d0
	lsl.w	#8,d0			; adjust bits
	or.w	d0,d2			; new red
	bra.s	\1_set_rgb_nibbles
	CNOP 0,4
\1_check_green_nibble
	cmp.b	d3,d1			; modify green ?
	bne.s	\1_set_rgb_nibbles
	and.w	#$f0f,d2
	and.w	d4,d0
	lsl.b	#4,d0			; adjust bits
	or.b	d0,d2			; new green
\1_set_rgb_nibbles
	move.w	d2,(a2)+		; RGB4
	dbf	d5,\1_convert_image_data_loop3
	addq.w	#BYTE_SIZE,a0		; next byte
	dbf	d6,\1_convert_image_data_loop2
	add.l	a6,a0			; skip remaining bitplanes
	dbf	d7,\1_convert_image_data_loop1
	movem.l	(a7)+,a4-a6
	rts
	ENDM


SWAP_COPPERLIST			MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	[2, 3] number of copperlists
; Result
	IFC "","\1"
		FAIL Macro SWAP_COPPERLIST: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SWAP_COPPERLIST: Number of copperlists missing
	ENDC
	IFC "cl1","\1"
		CNOP 0,4
swap_first_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0
			move.l	\1_display(a3),\1_construction2(a3)
			move.l	a0,\1_display(a3)
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0
			move.l	\1_display(a3),\1_construction1(a3)
			move.l	\1_construction2(a3),a1
			move.l	a0,\1_construction2(a3)
			move.l	a1,\1_display(a3)
			rts
		ENDC
	ENDC
	IFC "cl2","\1"
		CNOP 0,4
swap_second_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0
			move.l	\1_display(a3),\1_construction2(a3)
			move.l	a0,\1_display(a3)
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0
			move.l	\1_display(a3),\1_construction1(a3)
			move.l	\1_construction2(a3),a1
			move.l	a0,\1_construction2(a3)
			move.l	a1,\1_display(a3)
			rts
		ENDC
	ENDC
	ENDM


SET_COPPERLIST			MACRO
; Input
; \1 STRING:	Labels prefix
; Result
	IFC "","\1"
		FAIL Macro SET_COPPERLIST: Labels prefix missing
	ENDC
	IFC "cl1","\1"
		CNOP 0,4
set_first_copperlist
		move.l	\1_display(a3),COP1LC-DMACONR(a6)
		rts
	ENDC
	IFC "cl2","\1"
		CNOP 0,4
set_second_copperlist
		move.l	\1_display(a3),COP2LC-DMACONR(a6)
		rts
	ENDC
	ENDM


CLEAR_COLOR00_SCREEN		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] labels prefix copperlist
; \3 STRING:	["construction1","construction2"] name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 NUMBER:	[16, 32] number of commands per loop
	IFC "","\1"
		FAIL Macro CLEAR_COLOR00_SCREEN: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CLEAR_COLOR00_SCREEN: Labeld prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro CLEAR_COLOR00_SCREEN: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro CLEAR_COLOR00_SCREEN: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro CLEAR_COLOR00_SCREEN: Number of commands per loop missing
	ENDC
	CNOP 0,4
	IFC "cl1","\2"
\1_clear_first_copperlist
		IFC "16","\5"
			move.w	#color00_bits,d0
			MOVEF.L	\2_\4_size*16,d1
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00+WORD_SIZE,a0
			moveq	#(\2_display_y_size/16)-1,d7
\1_clear_first_copperlist_loop
			move.w	d0,(a0)	; COLOR00
			move.w	d0,\2_\4_size*1(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d0,\2_\4_size*14(a0)
			add.l	d1,a0	; next line in cl
			move.w	d0,(\2_\4_size*15)-(\2_\4_size*16)(a0)
			dbf	d7,\1_clear_first_copperlist_loop
			rts
		ENDC
		IFC "32","\5"
			move.w	#color00_bits,d0
			MOVEF.L \2_\4_size*32,d1
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00+WORD_SIZE,a0
			moveq	#(\2_display_y_size/32)-1,d7
\1_clear_first_copperlist_loop
			move.w	d0,(a0)	; COLOR00
			move.w	d0,\2_\4_size*1(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d0,\2_\4_size*14(a0)
			move.w	d0,\2_\4_size*15(a0)
			move.w	d0,\2_\4_size*16(a0)
			move.w	d0,\2_\4_size*17(a0)
			move.w	d0,\2_\4_size*18(a0)
			move.w	d0,\2_\4_size*19(a0)
			move.w	d0,\2_\4_size*20(a0)
			move.w	d0,\2_\4_size*21(a0)
			move.w	d0,\2_\4_size*22(a0)
			move.w	d0,\2_\4_size*23(a0)
			move.w	d0,\2_\4_size*24(a0)
			move.w	d0,\2_\4_size*25(a0)
			move.w	d0,\2_\4_size*26(a0)
			move.w	d0,\2_\4_size*27(a0)
			move.w	d0,\2_\4_size*28(a0)
			move.w	d0,\2_\4_size*29(a0)
			move.w	d0,\2_\4_size*30(a0)
			add.l	d1,a0	; next line in cl
			move.w	d0,(\2_\4_size*31)-(\2_\4_size*32)(a0)
			dbf	d7,\1_clear_first_copperlist_loop
			rts
		ENDC
	ENDC
	IFC "cl2","\2"
\1_clear_second_copperlist
		IFC "16","\5"
			move.w	#color00_bits,d0
			MOVEF.L	\2_\4_size*16,d1
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00+WORD_SIZE,a0
			moveq	#(\2_display_y_size/16)-1,d7
\1_clear_second_copperlist_loop
			move.w	d0,(a0)	; COLOR00
			move.w	d0,\2_\4_size*1(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d0,\2_\4_size*14(a0)
			add.l	d1,a0	; skip 16 lines in cl
			move.w	d0,(\2_\4_size*15)-(\2_\4_size*16)(a0)
			dbf	d7,\1_clear_second_copperlist_loop
			rts
		ENDC
		IFC "32","\5"
			move.w	#color00_bits,d0
			MOVEF.L	\2_\4_size*32,d1
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00+WORD_SIZE,a0
			moveq	#(\2_display_y_size/32)-1,d7
\1_clear_second_copperlist_loop
			move.w	d0,(a0)	; COLOR00
			move.w	d0,\2_\4_size*1(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d0,\2_\4_size*14(a0)
			move.w	d0,\2_\4_size*15(a0)
			move.w	d0,\2_\4_size*16(a0)
			move.w	d0,\2_\4_size*17(a0)
			move.w	d0,\2_\4_size*18(a0)
			move.w	d0,\2_\4_size*19(a0)
			move.w	d0,\2_\4_size*20(a0)
			move.w	d0,\2_\4_size*21(a0)
			move.w	d0,\2_\4_size*22(a0)
			move.w	d0,\2_\4_size*23(a0)
			move.w	d0,\2_\4_size*24(a0)
			move.w	d0,\2_\4_size*25(a0)
			move.w	d0,\2_\4_size*26(a0)
			move.w	d0,\2_\4_size*27(a0)
			move.w	d0,\2_\4_size*28(a0)
			move.w	d0,\2_\4_size*29(a0)
			move.w	d0,\2_\4_size*30(a0)
			add.l	d1,a0	; skip 32 lines in cl
			move.w	d0,(\2_\4_size*31)-(\2_\4_size*32)(a0)
			dbf	d7,\1_clear_second_copperlist_loop
			rts
		ENDC
	ENDC
	ENDM


CLEAR_COLOR00_CHUNKY		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] label prefix copperlist
; \3 STRING:	["construction1","construction2"] name of copperlist
; \4 STRING:	"extension[1..n]"
; Result
	IFC "","\1"
		FAIL Macro CLEAR_COLOR00_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CLEAR_COLOR00_CHUNKY: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro CLEAR_COLOR00_CHUNKY: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro CLEAR_COLOR00_CHUNKY: Extension missing
	ENDC
	CNOP 0,4
	IFC "cl1","\2"
\1_clear_first_copperlist
		bsr.s	\1_clear_first_copperlist_init
		move.l	\2_\3(a3),a0
		ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_1+WORD_SIZE,a0
		moveq	#(\2_display_width-1)-1,d7
\1_clear_first_copperlist_loop
		WAITBLIT
		move.l	a0,BLTDPT-DMACONR(a6) ; destination
		move.w	#(\1_clear_blit_y_size<<6)|(\1_clear_blit_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
		addq.w	#LONGWORD_SIZE,a0
		dbf	d7,clear_first_copperlist_loop
		move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
		rts
		CNOP 0,4
\1_clear_first_copperlist_init
		move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
		WAITBLIT
		move.l	#(BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D=A
		moveq	#-1,d0
		move.l	d0,BLTAFWM-DMACONR(a6)
		move.w	#\2_\4_size-\1_clear_blit_width,BLTDMOD-DMACONR(a6)
		IFEQ color00_bits
			moveq	#color00_bits,d0
			move.w	d0,BLTADAT-DMACONR(a6)
		ELSE
			move.w	#color00_bits,BLTADAT-DMACONR(a6)
		ENDC
		rts
	ENDC
	IFC "cl2","\2"
\1_clear_second_copperlist
		bsr.s	\1_clear_second_copperlist_init
		move.l	\2_\3(a3),a0
		ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_1+WORD_SIZE,a0
		moveq	#(\2_display_width-1)-1,d7
\1_clear_second_copperlist_loop
		WAITBLIT
		move.l	a0,BLTDPT-DMACONR(a6) ; destination
		move.w	#(\1_clear_blit_y_size<<6)|(\1_clear_blit_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
		addq.w	#LONGWORD_SIZE,a0
		dbf	d7,\1_clear_second_copperlist_loop
		move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
		rts
		CNOP 0,4
\1_clear_second_copperlist_init
		move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
		WAITBLIT
		move.l	#(BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D=A
		moveq	#-1,d0
		move.l	d0,BLTAFWM-DMACONR(a6)
		move.w	#\2_\4_size-\1_clear_blit_width,BLTDMOD-DMACONR(a6)
		IFEQ color00_bits
			moveq	#color00_bits,d0
			move.w	d0,BLTADAT-DMACONR(a6)
		ELSE
			move.w	#color00_bits,BLTADAT-DMACONR(a6)
		ENDC
		rts
	ENDC
	ENDM


SET_TWISTED_BACKGROUND_BARS	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] labels prefix copperlist
; \3 STRING:	["construction2","construction3"] name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 NUMBER:	[24] bar height in lines
; \6 POINTER:	color table
; \7 STRING:	["pc", "a3"] pointer base
; \8 WORD:	Offset table start (optional)
; Result
	IFC "","\1"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Labels prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Bar height missing
	ENDC
	IFC "","\6"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Color table missing
	ENDC
	IFC "","\7"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Pointer base missing
	ENDC
	CNOP 0,4
\1_set_background_bars
	movem.l	a4-a5,-(a7)
	MOVEF.L	\1_\5*WORD_SIZE,d4
	lea	\1_yz_coordinates(pc),a0
	move.l	\2_\3(a3),a2
	ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_1+WORD_SIZE,a2
	IFC "pc","\7"
		lea	\1_\6(\7),a5	; pointer color table
	ENDC
	IFC "a3","\7"
		move.l \6(\7),a5	; pointer collor table
	ENDC
	IFNC "","\8"
		ADDQ.W	\8*WORD_SIZE,a5 ; offset table start
	ENDC
	moveq	#(\2_display_width-1)-1,d7 ; number of columns
\1_set_background_bars_loop1
	move.l	a5,a1			; pointer color table
	moveq	#\1_bars_number-1,d6
\1_set_background_bars_loop2
	move.l	(a0)+,d0		; low word: y position, high word: z vector
	bpl.s	\1_no_background_bars_skip1
	add.l	d4,a1
	bra.s	\1_no_background_bars_skip2
	CNOP 0,4
\1_no_background_bars_skip1
	lea	(a2,d0.w),a4		; y offset
	COPY_TWISTED_BAR \1,\2,\4,\5
\1_no_background_bars_skip2
	dbf	d6,\1_set_background_bars_loop2
	addq.w	#LONGWORD_SIZE,a2	; next column in cl
	dbf	d7,\1_set_background_bars_loop1
	movem.l	(a7)+,a4-a5
	rts
	ENDM


SET_TWISTED_FOREGROUND_BARS	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] labels prefix copperlist
; \3 STRING:	"construction[2,3]" name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 NUMBER:	[24] bar height in lines
; \6 POINTER:	Color table
; \7 STRING:	["pc", "a3"] pointer base
; \8 WORD:	Offset table start (optional)
; Result
	IFC "","\1"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Labels prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Bar height missing
	ENDC
	IFC "","\6"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Color table missing
	ENDC
	IFC "","\7"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Pointer base missing
	ENDC
	CNOP 0,4
\1_set_foreground_bars
	movem.l	a4-a5,-(a7)
	MOVEF.L	\1_\5*WORD_SIZE,d4
	lea	\1_yz_coordinates(pc),a0
	move.l	\2_\3(a3),a2
	ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_1+WORD_SIZE,a2
	IFC "pc","\7"
		lea	\1_\6(\7),a5	; pointer color table
	ENDC
	IFC "a3","\7"
		move.l	\6(\7),a5	; pointer color table
	ENDC
	IFNC "","\8"
		ADDQ.W	\8*WORD_SIZE,a5 ; offset table start
	ENDC
	moveq	#(\2_display_width-1)-1,d7 ; number of columns
\1_set_foreground_bars_loop1
	move.l	a5,a1			; pointer color table
	moveq	#\1_bars_number-1,d6
\1_set_foreground_bars_loop2
	move.l	(a0)+,d0		; low word: y position, high word: z vector
	bmi.s	\1_no_foreground_bars_skip1
	add.l	d4,a1
	bra.s	\1_no_foreground_bars_skip2
	CNOP 0,4
\1_no_foreground_bars_skip1
	lea	(a2,d0.w),a4		; y offset
	COPY_TWISTED_BAR \1,\2,\4,\5
\1_no_foreground_bars_skip2
	dbf	d6,\1_set_foreground_bars_loop2
	addq.w	#LONGWORD_SIZE,a2	; next column
	dbf	d7,\1_set_foreground_bars_loop1
	movem.l (a7)+,a4-a5
	rts
	ENDM


COPY_TWISTED_BAR		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] labels prefix copperlist
; \3 STRING:	"extension[1..n]"
; \4 NUMBER:	[24] bar height in lines
	IFC "","\1"
		FAIL Macro COPY_TWISTED_BAR: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COPY_TWISTED_BAR: Labels prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro COPY_TWISTED_BAR: Extension missing
	ENDC
	IFC "","\4"
		FAIL Macro COPY_TWISTED_BAR: Bar height missing
	ENDC
	IFEQ \1_\4-24
		movem.w	(a1)+,d0-d3	; fetch 4x RGB4 values
		move.w	d1,\2_\3_size*1(a4) ; COLOR00
		move.w	d0,(a4)
		move.w	d3,\2_\3_size*3(a4)
		move.w	d2,\2_\3_size*2(a4)
		movem.w	(a1)+,d0-d3
		move.w	d1,\2_\3_size*5(a4)
		move.w	d0,\2_\3_size*4(a4)
		move.w	d3,\2_\3_size*7(a4)
		move.w	d2,\2_\3_size*6(a4)
		movem.w	(a1)+,d0-d3
		move.w	d1,\2_\3_size*9(a4)
		move.w	d0,\2_\3_size*8(a4)
		move.w	d3,\2_\3_size*11(a4)
		move.w	d2,\2_\3_size*10(a4)
		movem.w	(a1)+,d0-d3
		move.w	d1,\2_\3_size*13(a4)
		move.w	d0,\2_\3_size*12(a4)
		move.w	d3,\2_\3_size*15(a4)
		move.w	d2,\2_\3_size*14(a4)
		movem.w	(a1)+,d0-d3
		move.w	d1,\2_\3_size*17(a4)
		move.w	d0,\2_\3_size*16(a4)
		move.w	d3,\2_\3_size*19(a4)
		move.w	d2,\2_\3_size*18(a4)
		movem.w	(a1)+,d0-d3
		move.w	d1,\2_\3_size*21(a4)
		move.w	d0,\2_\3_size*20(a4)
		move.w	d3,\2_\3_size*23(a4)
		move.w	d2,\2_\3_size*22(a4)
	ENDC
	ENDM
