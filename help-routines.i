; Global labels
;	SYS_TAKEN_OVER
;	COLOR_GRADIENT_RGB4


; Input
; d0.l	Memory size
; Result
; d0.l	Pointer to memory block if successful or 0
	CNOP 0,4
do_alloc_memory
	move.l	#MEMF_CLEAR|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	Memory size
; Result
; d0.l	Pointer to memory block if successful or 0
	CNOP 0,4
do_alloc_chip_memory
	move.l	#MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	Memory size
; Result
; d0.l	Pointer to memory block if successful, otherwise 0
	CNOP 0,4
do_alloc_fast_memory
	move.l	#MEMF_CLEAR|MEMF_FAST|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	Playfield width
; d1.l	Playfield height * playfield depth
; Result
; d0.l	Pointer to memory block if successful or 0
	CNOP 0,4
do_alloc_bitmap_memory
	CALLGRAFQ AllocRaster


	IFD SYS_TAKEN_OVER
		IFNE intena_bits&(~INTF_SETCLR)
			MC68020
; Input
; Result
; d0.l	Content VBR
			CNOP 0,4
read_VBR
			or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
			nop
			movec	VBR,d0
			nop
			rte
		ENDC
	ELSE
		MC68020
; Input
; Result
; d0.l	 Content VBR
		CNOP 0,4
read_VBR
		or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
		nop
		movec	VBR,d0
		nop
		rte


; Input
; d0.l	Content VBR
; Result
		CNOP 0,4
write_VBR
		or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
		nop
		movec	d0,VBR
		nop
		rte
	ENDC


; Input
; Result
	CNOP 0,4
wait_beam_position
	move.l	#VERT_POSITION_MASK<<8,d1
	move.l	#beam_position<<8,d2
	lea	VPOSR-DMACONR(a6),a0
	lea	VHPOSR-DMACONR(a6),a1
wait_beam_position_loop1
	move.w	(a0),d0
	swap	d0			; high word: VPOSR
	move.w	(a1),d0			; low word: VHPOSR
	and.l	d1,d0			; vertical position
	cmp.l	d2,d0			; only one position per frame on 680x0 machines
	bge.s	wait_beam_position_loop1
wait_beam_position_loop2
	move.w	(a0),d0
	swap	d0			; high word: VPOSR
	move.w	(a1),d0			; low word: VHPOSR
	and.l	d1,d0			; vertical position
	cmp.l	d2,d0			; wait beam position reached ?
	blt.s	wait_beam_position_loop2
	rts


; Input
; Result
	CNOP 0,4
wait_vbi
	lea	INTREQR-DMACONR(a6),a0
wait_vbi_loop
	moveq	#INTF_VERTB,d0
	and.w	(a0),d0
	beq.s	wait_vbi_loop
	move.w	d0,INTREQ-DMACONR(a6)	; clear interrupt
	rts


; Input
; Result
	CNOP 0,4
wait_copint
	lea	INTREQR-DMACONR(a6),a0
wait_copint_loop
	moveq	#INTF_COPER,d0
	and.w	(a0),d0
	beq.s	wait_copint_loop
	move.w	d0,INTREQ-DMACONR(a6)	; clear interrupt
	rts


; Input
; a0.l	Pointer copperlist
; a1.l	Pointer color table
; d3.w	Offset first color register
; d7.w	Number of colors
; Result
; d0	Kein Rückgabewert
	CNOP 0,4
cop_init_colors
	move.w	d3,(a0)+		; COLORxx
	move.w	(a1)+,(a0)+		; RGB4
	addq.w	#2,d3			; next color register
	dbf	d7,cop_init_colors
	rts


; Input
; a0.l	Offset first color register
; a1.l	Pointer color table
; d7.w	Number of colors
; Result
; d0	Kein Rückgabewert
	CNOP 0,4
cpu_init_colors
	move.w	(a1)+,(a0)+		; COLORxx
	dbf	d7,cpu_init_colors
	rts


	IFD COLOR_GRADIENT_RGB4
; Input
; d0.w	RGB4 current value
; d6.w	RGB4 destination value
; d7.w	Number of colors
; a0.l	Pointer color table
; a1.w	Increase/decrease red
; a2.w	Increase/decrease green
; a4.w	Increase/decrease blue
; a5	Offset to next entry in color table
; Result
		CNOP 0,4
init_color_gradient_rgb4_loop
		move.w	d0,(a0)		; RGB4
		add.l	a5,a0		; next entry
		move.w	d0,d1
		and.w	#NIBBLE_MASK_HIGH,d1 ; G4
		moveq	#NIBBLE_MASK_LOW,d2
		and.w	d0,d2		; B4
		clr.b	d0		; R4
		move.w	d6,d3		; RGB4
		move.w	d3,d4
		moveq	#NIBBLE_MASK_LOW,d5
		and.w	#NIBBLE_MASK_HIGH,d4 ; G4 destination
		and.w	d3,d5		; B4 destination
		clr.b	d3		; R4 destination

		cmp.w	d3,d0
		bgt.s	decrease_red_rgb4
		blt.s	increase_red_rgb4
check_green_rgb4
		cmp.w	d4,d1
		bgt.s	decrease_green_rgb4
		blt.s	increase_green_rgb4
check_blue_rgb4
		cmp.b	d5,d2
		bgt.s	decrease_blue_rgb4
		blt.s	increase_blue_rgb4
merge_rgb4
		move.b	d1,d0
		or.b	d2,d0		; B4
		dbf	d7,init_color_gradient_rgb4_loop
		rts
		CNOP 0,4
decrease_red_rgb4
		sub.w	a1,d0
		cmp.w	d3,d0
		bgt.s	check_green_rgb4
		move.w	d3,d0
		bra.s	check_green_rgb4
		CNOP 0,4
increase_red_rgb4
		add.w	a1,d0
		cmp.w	d3,d0
		blt.s	check_green_rgb4
		move.w	d3,d0
		bra.s	check_green_rgb4
		CNOP 0,4
decrease_green_rgb4
		sub.w	a2,d1
		cmp.w	d4,d1
		bgt.s	check_blue_rgb4
		move.w	d4,d1
		bra.s	check_blue_rgb4
		CNOP 0,4
increase_green_rgb4
		add.w	a2,d1
		cmp.w	d4,d1
		blt.s	check_blue_rgb4
		move.w	d4,d1
		bra.s	check_blue_rgb4
		CNOP 0,4
decrease_blue_rgb4
		sub.w	a4,d2
		cmp.b	d5,d2
		bgt.s	merge_rgb4
		move.b	d5,d2
		bra.s	merge_rgb4
		CNOP 0,4
increase_blue_rgb4
		add.w	a4,d2
		cmp.b	d5,d2
		blt.s	merge_rgb4
		move.b	d5,d2
		bra.s	merge_rgb4
	ENDC
