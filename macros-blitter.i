WAITBLIT			MACRO
; Input
; \1 STRING:	"BUSYBITBUG" for Agnus in Amiga 1000/2000-A to avoid blitter busy bit bug (optional)
; Result
	IFC "BUSYBITBUG","\1"
		tst.w	(a6) 
	ENDC
waitblit_loop\@
	btst	#DMAB_BLTDONE-8,(a6)
	bne.s	waitblit_loop\@
	ENDM


WAITBLITQ			MACRO
; Input
; \1		DMA blitter busy bit in dx or immediate
; \2 STRING:	"BUSYBITBUG" for Agnus in Amiga 1000/2000-A to avoid blitter busy bit bug (optional)
; Result
	IFC "BUSYBITBUG","\2"
		tst.w	(a6) 
	ENDC
wait_blitter_quick_loop\@
	btst	\1,(a6)
	bne.s	wait_blitter_quick_loop\@
	ENDM


GET_LINE_PARAMETERS		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	"AREAFILL" (optional)
; \3 STRING:	"COPPERUSE" (optional)
; \4 WORD:	Multiplicator for y offset in playfield
; Result
	IFC "","\1"
		FAIL Macro GET_LINE_PARAMETERS: Labels prefix missing
	ENDC
	cmp.w	d1,d3
	IFC "AREAFILL","\2"
		beq	\1_draw_lines_no_line ; y1 = y2
		bgt.s	\1_draw_lines_delta_y_positive y2 ; y1 < y2
	ELSE
		bpl.s	\1_draw_lines_delta_y_positive y2 ; y1 <= y2
	ENDC
	exg	d0,d2			; swap x1 with x2 if y1>y2
	exg	d1,d3			; swap Y1 with Y2 if y1>y2
\1_draw_lines_delta_y_positive
	IFC "AREAFILL","\2"
		addq.w	#1,d1		; blunt edges for area filling
	ENDC
	moveq	#BLTCON1F_SUD,d5	; octant #8
	sub.w	d0,d2			; dx = x2-x1
	bpl.s	\1_draw_lines_delta_x_positive
	addq.w	#BLTCON1F_AUL,d5	; octant #5
	neg.w	 d2
\1_draw_lines_delta_x_positive
	sub.w	 d1,d3			; dy = y2-y1
	ror.l	 #4,d0			; adjust shift bits
	IFC "","\4"
		MULUF.W	(pf1_plane_width*pf1_depth3)/2,d1,d4 ; y offset in bitplanes
	ELSE
		MULUF.W	(\4)/2,d1,d4	; custom y offset in bitplanes
	ENDC
	add.w	d0,d1			; xy offset
	MULUF.L	2,d1			; correct xy offset
	cmp.w	d2,d3			; dx <= dy ?
	ble.s	\1_draw_lines_delta_positive
	SUBF.W	BLTCON1F_SUD,d5
	exg	d2,d3			; swap dx with dy
	MULUF.W	2,d5			; octant #6,7
\1_draw_lines_delta_positive
	MULUF.W 4,d3			; dy*4
	move.w	d5,d0			; save octant
	move.w	d3,d4			; save 4*dy
	swap	d4			; high word: 4*dy
	MULUF.W	2,d2			; dx*2
	move.w	d3,d4			; save 4*dy
	sub.w	d2,d3			; (4*dy)-(2*dx)
	bpl.s	\1_draw_lines_no_sign_bit
	or.w	#BLTCON1F_SIGN,d0
\1_draw_lines_no_sign_bit
	IFC "","\3"
		MULUF.W	2,d2		; 2*(2*dx) = 4*dx
		sub.w	d2,d4		; low word: (4*dy)-(4*dx)
		addq.w	#1*4,d2		; (4*dx)+(1*4)
		MULUF.W 16,d2		; length = ((4*dx)+(1*4))*16
		addq.w	#2,d2		; width = 1 word
	ENDC
	ENDM
