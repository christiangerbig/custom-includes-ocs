INIT_BPLCON0_BITS		MACRO
; Input
; \1 STRING:	Label
; \2 NUMBER:	Playfield depth
; \3 STRING:	BPLCON0 additional bits (optiona)
; Result
	IFC "","\1"
		FAIL Macro INIT_BPLCON0_BITS: Label missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_BPLCON0_BITS: Playfield depth missing
	ENDC
	IFC "","\3"
\1 EQU ((\2>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)
	ELSE
\1 EQU ((\2>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|\3
	ENDC
	ENDM


INIT_DIWSTRT_BITS		MACRO
; Input
; \1 STRING:	Label
; Result
	IFC "","\1"
		FAIL Macro INIT_DIWSTRT_BITS: Label missing
	ENDC
\1 EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
	ENDM


INIT_DIWSTOP_BITS		MACRO
; Input
; \1 STRING:	Label
; Result
	IFC "","\1"
		FAIL Macro INIT_DIWSTOP_BITS: Label missing
	ENDC
\1 EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
	ENDM


PF_SOFTSCROLL_8PIXEL_LORES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scratch register
; \3 STRING:	Mask H0-H4 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_LORES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_LORES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$001f,\1	; -- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ENDC
	lsl.b	#2,\1			; -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0 -- --
	ror.b	#4,\1			; -- -- -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2
	lsl.w	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2 -- --
	lsr.b	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	move.w	\1,\2			; -- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	lsl.w	#4,\2			; -- -- H1 H0 -- -- -- -- -- H4 H3 H2 -- -- -- --
	or.w	\2,\1			; -- -- H1 H0 -- -- H1 H0 -- H4 H3 H2 -- H4 H3 H2
	ENDM


PF_SOFTSCROLL_16PIXEL_LORES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scratch register
; \3 STRING:	Maske H0-H5 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_LORES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_LORES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$003f,\1	; -- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ENDC
	ror.b	#2,\1			; -- -- -- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
	move.w	\1,\2			; -- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
	lsl.w	#4,\2			; -- -- H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
	or.w	\2,\1			; -- -- H1 H0 -- -- H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
	ENDM


PF_SOFTSCROLL_8PIXEL_HIRES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	scratch register
; \3 STRING:	Mask H0-H3 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_HIRES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_HIRES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$000f,\1	; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ENDC
	lsl.b	#2,\1			; -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0 -- --
	ror.b	#4,\1			; -- -- -- -- -- -- -- -- H1 H0 -- -- -- -- H3 H2
	lsl.w	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- -- H3 H2 -- --
	lsr.b	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- -- -- -- H3 H2
	move.w	\1,\2			; -- -- -- -- -- -- H1 H0 -- -- -- -- -- -- H3 H2
	lsl.w	#4,\2			; -- -- H1 H0 -- -- -- -- -- -- H3 H2 -- -- -- --
	or.w	\2,\1			; -- -- H1 H0 -- -- H1 H0 -- -- H3 H2 -- -- H3 H2
	ENDM


PF_SOFTSCROLL_16PIXEL_HIRES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scatch register
; \3 STRING:	Mask H0-H4 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_HIRES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_HIRES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$001f,\1	; -- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ENDC
	ror.b	#2,\1			; -- -- -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2
	lsl.w	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2 -- --
	lsr.b	#2,\1			; -- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	move.w	\1,\2			; -- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	lsl.w	#4,\2			; -- -- H1 H0 -- -- -- -- -- H4 H3 H2 -- -- -- --
	or.w	\2,\1			; -- -- H1 H0 -- -- H1 H0 -- H4 H3 H2 -- H4 H3 H2
	ENDM


SWAP_PLAYFIELD			MACRO
; \1 STRING:		Labels prefix
; \2 NUMBER:		Number of playfields [2,3]
; \3 BYTE SIGNED:	Playfield depth
; \4 WORD:		x offset (optional)
; \5 WORD:		y offset (optional)
	IFC "","\1"
		FAIL Macro SWAP_PLAYFIELD: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SWAP_PLAYFIELD: Number of playfields missing
	ENDC
	IFC "","\3"
		FAIL Macro SWAP_PLAYFIELD: Playfield depth missing
	ENDC
	CNOP 0,4
swap_playfield\*RIGHT(\1,1)
	IFEQ \2-2
		IFC "","\4"
			move.l	cl1_display(a3),a0
			move.l	\1_construction2(a3),a1
			ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
			move.l	\1_display(a3),\1_construction2(a3)
			move.l	a1,\1_display(a3)
			moveq	#\1_depth3-1,d7
swap_playfield\*RIGHT(\1,1)_loop
			move.w	(a1)+,(a0) ; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
			dbf	d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
			rts
		ELSE
			move.l	cl1_display(a3),a0
			move.l	\1_construction2(a3),a1
			ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
			move.l	\1_display(a3),\1_construction2(a3)
			MOVEF.L (\4/8)+(\5*\1_plane_width*\1_depth3),d1
			move.l	a1,\1_display(a3)
			moveq	#\1_depth3-1,d7
swap_playfield\*RIGHT(\1,1)_loop
			move.l	(a1)+,d0
			add.l	d1,d0
			move.w	d0,LONGWORD_SIZE(a0) ; BPLxPTL
			swap	d0	; High
			move.w	d0,(a0)	; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			dbf	d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
			rts
		ENDC
	ENDC
	IFEQ \2-3
		IFC "","\4"
			move.l	cl1_display(a3),a0
			move.l	\1_construction1(a3),a1
			move.l	\1_construction2(a3),a2
			move.l	\1_display(a3),\1_construction1(a3)
			move.l	a1,\1_construction2(a3)
			ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
			move.l	a2,\1_display(a3)
			moveq	#\3-1,d7 ; playfield depth
swap_playfield\*RIGHT(\1,1)_loop
			move.w	(a2)+,(a0) ; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			move.w	(a2)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
			dbf	d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
			rts
		ELSE
			move.l	cl1_display(a3),a0
			move.l	\1_construction1(a3),a1
			move.l	\1_construction2(a3),a2
			move.l	\1_display(a3),\1_construction1(a3)
			MOVEF.L (\4/8)+(\5*\1_plane_width*\1_depth3),d1
			move.l	a1,\1_construction2(a3)
			ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
			move.l	a2,\1_display(a3)
			moveq	#\3-1,d7 ; playfield depth
swap_playfield\*RIGHT(\1,1)_loop
			move.l	(a2)+,d0
			add.l	d1,d0
			move.w	d0,LONGWORD_SIZE(a0) ; BPLxPTL
			swap	d0						 ;High
			move.w	d0,(a0) ; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			dbf	d7,swap_playfield\*RIGHT(\1,1)_loop
			rts
		ENDC
	ENDC
	ENDM
