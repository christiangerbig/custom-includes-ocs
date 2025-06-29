PF_SOFTSCROLL_8PIXEL_LORES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scratch register
; \3 STRING:	Mask H0-H2 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_LORES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_LORES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$0007,\1	; -- -- -- -- -- -- -- -- -- -- -- -- -- H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- -- -- H2 H1 H0
	ENDC
	move.w	\1,\2			; -- -- -- -- -- -- -- -- -- -- -- -- -- H2 H1 H0
	lsl.b	#4,\2			; -- -- -- -- -- -- -- -- -- H2 H1 H0 -- -- -- --
	or.b	\2,\1			; -- -- -- -- -- -- -- -- -- H2 H1 H0 -- H2 H1 H0
	ENDM


PF_SOFTSCROLL_16PIXEL_LORES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scratch register
; \3 STRING:	Mask H0-H3 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_LORES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_LORES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$000f,\1	; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ENDC
	move.w	\1,\2			; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	lsl.b	#4,\2			; -- -- -- -- -- -- -- -- H3 H2 H1 H0 -- -- -- --
	or.b	\2,\1			; -- -- -- -- -- -- -- -- H3 H2 H1 H0 H3 H2 H1 H0
	ENDM


ODDPF_SOFTSCROLL_16PIXEL_LORES	MACRO
; Input
; \1 WORD:	X shift
; \2 WORD:	H0-H3 mask (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro ODDPF_SOFTSCROLL_16PIXEL_LORES: PF1 x shift missing
	ENDC
	IFC "","\2"
		and.w	#$000f,\1	; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ELSE
		and.w	\2,\1		; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ENDC
	ENDM


EVENPF_SOFTSCROLL_16PIXEL_LORES	MACRO
; Input
; \1 WORD:	X shift
; \2 WORD:	H0-H3 mask (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro EVENPF_SOFTSCROLL_16PIXEL_LORES: X shift missing
	ENDC
	IFC "","\2"
		and.w	#$000f,\1	; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ELSE
		and.w	\2,\1		; -- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ENDC
	lsl.w	#4,\1			; -- -- -- -- -- -- -- -- H3 H2 H1 H0 -- -- -- --
	ENDM


PF_SOFTSCROLL_8PIXEL_HIRES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scratch register
; \3 STRING:	Mask H0-H1 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_HIRES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_8PIXEL_HIRES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$0003,\1	; -- -- -- -- -- -- -- -- -- -- -- -- -- -- H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- -- -- -- H1 H0
	ENDC
	move.w	\1,\2			; -- -- -- -- -- -- -- -- -- -- -- -- -- -- H1 H0
	lsl.b	#4,\2			; -- -- -- -- -- -- -- -- -- -- H1 H0 -- -- -- --
	or.b	\2,\1			; -- -- -- -- -- -- -- -- -- -- H1 H0 -- -- H1 H0
	ENDM


PF_SOFTSCROLL_16PIXEL_HIRES	MACRO
; Input
; \1 WORD:	Playfield x start
; \2 WORD:	Scatch register
; \3 STRING:	Mask H0-H2 (optional)
; Result
; \1 WORD:	BPLCON1 soft scroll
	IFC "","\1"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_HIRES: Playfield x start missing
	ENDC
	IFC "","\2"
		FAIL Macro PF_SOFTSCROLL_16PIXEL_HIRES: Scratch register missing
	ENDC
	IFC "","\3"
		and.w	#$0007,\1	; -- -- -- -- -- -- -- -- -- -- -- -- -- H2 H1 H0
	ELSE
		and.w	\3,\1		; -- -- -- -- -- -- -- -- -- -- -- -- -- H2 H1 H0
	ENDC
	move.w	\1,\2			; -- -- -- -- -- -- -- -- -- -- -- -- -- H2 H1 H0
	lsl.b	#4,\2			; -- -- -- -- -- -- -- -- -- H2 H1 H0 -- -- -- --
	or.b	\2,\1			; -- -- -- -- -- -- -- -- -- H2 H1 H0 -- H2 H1 H0
	ENDM


SWAP_PLAYFIELD			MACRO
; Input
; \1 STRING:		Labels prefix
; \2 NUMBER:		Number of playfields [2,3]
; Global reference
; _construction1
; _construction2
; _display
; Result
	IFC "","\1"
		FAIL Macro SWAP_PLAYFIELD: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SWAP_PLAYFIELD: Number of playfields missing
	ENDC
swap_playfield\*RIGHT(\1,1)
	IFEQ \2-2
		move.l	\1_construction2(a3),a0
		move.l	\1_display(a3),\1_construction2(a3)
		move.l	a0,\1_display(a3)
	ENDC
	IFEQ \2-3
		move.l	\1_construction1(a3),a0
		move.l	\1_construction2(a3),a1
		move.l	\1_display(a3),\1_construction1(a3)
		move.l	a0,\1_construction2(a3)
		move.l	a1,\1_display(a3)
	ENDC
	rts
	ENDM


SET_PLAYFIELD			MACRO
; Input
; \1 STRING:		Labels prefix
; \2 BYTE SIGNED:	Playfield depth
; \3 WORD:		X shift (optional)
; \4 WORD:		y shift (optional)
; Global reference
; cl1_display
; cl1_BPL1PTH
; Result
	IFC "","\1"
		FAIL Macro SET_PLAYFIELD: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_PLAYFIELD: Playfield depth missing
	ENDC
	CNOP 0,4
set_playfield1
	move.l	\1_display(a3),d0
	IFNC "","\3"
		ADDF.L	(\3/8)+(\4*\1_plane_width*\2),d0
	ENDC
	MOVEF.L	\1_plane_width,d1
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
	moveq	#\2-1,d7	; playfield depth
set_playfield1_loop
	swap	d0
	move.w	d0,(a0)		; BPLxPTH
	addq.w	#QUADWORD_SIZE,a0
	swap	d0
	move.w	d0,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
	add.l	d1,d0		; next bitplane
	dbf	d7,set_playfield1_loop
	rts
	ENDM


SET_DUAL_PLAYFIELD		MACRO
; Input
; \1 STRING:		Labels prefix
; \2 BYTE SIGNED:	Playfield depth
; \3 WORD:		X shift (optional)
; \4 WORD:		Y shift (optional)
; Global reference
; _display
; Result
	IFC "","\1"
		FAIL Macro SET_DUAL_PLAYFIELD: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_DUAL_PLAYFIELD: Playfield depth missing
	ENDC
	CNOP 0,4
set_dual_playfield\*RIGHT(\1,1)
	move.l	\1_display(a3),d0
	IFNC "","\3"
		ADDF.L	(\3/8)+(\4*\1_plane_width*\2),d0
	ENDC
	MOVEF.L	\1_plane_width,d1
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL\*RIGHT(\1,1)PTH+WORD_SIZE,a0
	moveq	#\2-1,d7	; playfield depth
set_dual_playfield\*RIGHT(\1,1)_loop
	swap	d0
	move.w	d0,(a0)		; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a0
	swap	d0
	move.w	d0,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a0) ; BPLxPTL
	add.l	d1,d0
	dbf	d7,set_dual_playfield\*RIGHT(\1,1)_loop
	rts
	ENDM
