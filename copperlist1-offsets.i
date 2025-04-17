	IFD diwstrt_bits
cl1_DIWSTRT			RS.L 1
	ENDC
	IFD diwstop_bits
cl1_DIWSTOP			RS.L 1
	ENDC
	IFD ddfstrt_bits
cl1_DDFSTRT			RS.L 1
	ENDC
	IFD ddfstop_bits
cl1_DDFSTOP			RS.L 1
	ENDC
cl1_BPLCON0			RS.L 1
	IFD bplcon1_bits
cl1_BPLCON1			RS.L 1
	ENDC
	IFD bplcon2_bits
cl1_BPLCON2			RS.L 1
	ENDC
	IFNE pf_depth
cl1_BPL1MOD			RS.L 1
	ENDC
	IFGT pf_depth-1
cl1_BPL2MOD			RS.L 1
	ENDC

	IFNE dma_bits&DMAF_SPRITE
cl1_SPR0PTH			RS.L 1
cl1_SPR0PTL			RS.L 1
cl1_SPR1PTH			RS.L 1
cl1_SPR1PTL			RS.L 1
cl1_SPR2PTH			RS.L 1
cl1_SPR2PTL			RS.L 1
cl1_SPR3PTH			RS.L 1
cl1_SPR3PTL			RS.L 1
cl1_SPR4PTH			RS.L 1
cl1_SPR4PTL			RS.L 1
cl1_SPR5PTH			RS.L 1
cl1_SPR5PTL			RS.L 1
cl1_SPR6PTH			RS.L 1
cl1_SPR6PTL			RS.L 1
cl1_SPR7PTH			RS.L 1
cl1_SPR7PTL			RS.L 1
	ENDC

	IFGE pf_colors_number-1		; number of colors >= 1
cl1_COLOR00			RS.L 1
	ENDC
	IFGE pf_colors_number-2		; number of colors >= 2
cl1_COLOR01			RS.L 1
	ENDC
	IFGE pf_colors_number-3		; number of colors >= 3
cl1_COLOR02			RS.L 1
	ENDC
	IFGE pf_colors_number-4		; number of colors >= 4
cl1_COLOR03			RS.L 1
	ENDC
	IFGE pf_colors_number-5		; number of colors >= 5
cl1_COLOR04			RS.L 1
	ENDC
	IFGE pf_colors_number-6		; number of colors >= 6
cl1_COLOR05			RS.L 1
	ENDC
	IFGE pf_colors_number-7		; number of colors >= 7
cl1_COLOR06			RS.L 1
	ENDC
	IFGE pf_colors_number-8		; number of colors >= 8
cl1_COLOR07			RS.L 1
	ENDC
	IFGE pf_colors_number-9		; number of colors >= 9
cl1_COLOR08			RS.L 1
	ENDC
	IFGE pf_colors_number-10	; number of colors >= 10
cl1_COLOR09			RS.L 1
	ENDC
	IFGE pf_colors_number-11	; number of colors >= 11
cl1_COLOR10			RS.L 1
	ENDC
	IFGE pf_colors_number-12	; number of colors >= 12
cl1_COLOR11			RS.L 1
	ENDC
	IFGE pf_colors_number-13	; number of colors >= 13
cl1_COLOR12			RS.L 1
	ENDC
	IFGE pf_colors_number-14	; number of colors >= 14
cl1_COLOR13			RS.L 1
	ENDC
	IFGE pf_colors_number-15	; number of colors >= 15
cl1_COLOR14			RS.L 1
	ENDC
	IFGE pf_colors_number-16	; number of colors >= 16
cl1_COLOR15			RS.L 1
	ENDC
	IFNE pf_colors_number-32
		IFNE spr_colors_number
cl1_COLOR16			RS.L 1
cl1_COLOR17			RS.L 1
cl1_COLOR18			RS.L 1
cl1_COLOR19			RS.L 1
cl1_COLOR20			RS.L 1
cl1_COLOR21			RS.L 1
cl1_COLOR22			RS.L 1
cl1_COLOR23			RS.L 1
cl1_COLOR24			RS.L 1
cl1_COLOR25			RS.L 1
cl1_COLOR26			RS.L 1
cl1_COLOR27			RS.L 1
cl1_COLOR28			RS.L 1
cl1_COLOR29			RS.L 1
cl1_COLOR30			RS.L 1
cl1_COLOR31			RS.L 1
		ENDC
	ELSE
cl1_COLOR16			RS.L 1
cl1_COLOR17			RS.L 1
cl1_COLOR18			RS.L 1
cl1_COLOR19			RS.L 1
cl1_COLOR20			RS.L 1
cl1_COLOR21			RS.L 1
cl1_COLOR22			RS.L 1
cl1_COLOR23			RS.L 1
cl1_COLOR24			RS.L 1
cl1_COLOR25			RS.L 1
cl1_COLOR26			RS.L 1
cl1_COLOR27			RS.L 1
cl1_COLOR28			RS.L 1
cl1_COLOR29			RS.L 1
cl1_COLOR30			RS.L 1
cl1_COLOR31			RS.L 1
	ENDC

	IFGE pf_depth-1
cl1_BPL1PTH			RS.L 1
cl1_BPL1PTL			RS.L 1
	ENDC

	IFGE pf_depth-2
cl1_BPL2PTH			RS.L 1
cl1_BPL2PTL			RS.L 1
	ENDC

	IFGE pf_depth-3
cl1_BPL3PTH			RS.L 1
cl1_BPL3PTL			RS.L 1
	ENDC

	IFGE pf_depth-4
cl1_BPL4PTH			RS.L 1
cl1_BPL4PTL			RS.L 1
	ENDC

	IFGE pf_depth-5
cl1_BPL5PTH			RS.L 1
cl1_BPL5PTL			RS.L 1
	ENDC

	IFGE pf_depth-6
cl1_BPL6PTH			RS.L 1
cl1_BPL6PTL			RS.L 1
	ENDC
