; Datum:	04.10.2024
; Version:	1.0
; OS:		1.3+

; ** Struktur, die alle Registeroffsets der 1. Copperliste enthält **

	IFD diwstrt_bits
cl2_DIWSTRT			RS.L 1
	ENDC
	IFD diwstop_bits
cl2_DIWSTOP			RS.L 1
	ENDC
	IFD ddfstrt_bits
cl2_DDFSTRT			RS.L 1
	ENDC
	IFD ddfstop_bits
cl2_DDFSTOP			RS.L 1
	ENDC
cl2_BPLCON0			RS.L 1
	IFD bplcon1_bits
cl2_BPLCON1			RS.L 1
	ENDC
	IFD bplcon2_bits
cl2_BPLCON2			RS.L 1
	ENDC
	IFNE pf_depth
cl2_BPL1MOD			RS.L 1
	ENDC
	IFGT pf_depth-1
cl2_BPL2MOD			RS.L 1
	ENDC

	IFNE dma_bits&DMAF_SPRITE
cl2_SPR0PTH			RS.L 1
cl2_SPR0PTL			RS.L 1
cl2_SPR1PTH			RS.L 1
cl2_SPR1PTL			RS.L 1
cl2_SPR2PTH			RS.L 1
cl2_SPR2PTL			RS.L 1
cl2_SPR3PTH			RS.L 1
cl2_SPR3PTL			RS.L 1
cl2_SPR4PTH			RS.L 1
cl2_SPR4PTL			RS.L 1
cl2_SPR5PTH			RS.L 1
cl2_SPR5PTL			RS.L 1
cl2_SPR6PTH			RS.L 1
cl2_SPR6PTL			RS.L 1
cl2_SPR7PTH			RS.L 1
cl2_SPR7PTL			RS.L 1
	ENDC

	IFGE pf_colors_number-1		; Anzahl Playfield-Farben >= 1
cl2_COLOR00			RS.L 1
	ENDC
	IFGE pf_colors_number-2		; Anzahl Playfield-Farben >= 2
cl2_COLOR01			RS.L 1
	ENDC
	IFGE pf_colors_number-3		; Anzahl Playfield-Farben >= 3
cl2_COLOR02			RS.L 1
	ENDC
	IFGE pf_colors_number-4		; Anzahl Playfield-Farben >= 4
cl2_COLOR03			RS.L 1
	ENDC
	IFGE pf_colors_number-5		; Anzahl Playfield-Farben >= 5
cl2_COLOR04			RS.L 1
	ENDC
	IFGE pf_colors_number-6		; Anzahl Playfield-Farben >= 6
cl2_COLOR05			RS.L 1
	ENDC
	IFGE pf_colors_number-7		; Anzahl Playfield-Farben >= 7
cl2_COLOR06			RS.L 1
	ENDC
	IFGE pf_colors_number-8		; Anzahl Playfield-Farben >= 8
cl2_COLOR07			RS.L 1
	ENDC
	IFGE pf_colors_number-9		; Anzahl Playfield-Farben >= 9
cl2_COLOR08			RS.L 1
	ENDC
	IFGE pf_colors_number-10	; Anzahl Playfield-Farben >= 10
cl2_COLOR09			RS.L 1
	ENDC
	IFGE pf_colors_number-11	; Anzahl Playfield-Farben >= 11
cl2_COLOR10			RS.L 1
	ENDC
	IFGE pf_colors_number-12	; Anzahl Playfield-Farben >= 12
cl2_COLOR11			RS.L 1
	ENDC
	IFGE pf_colors_number-13	; Anzahl Playfield-Farben >= 13
cl2_COLOR12			RS.L 1
	ENDC
	IFGE pf_colors_number-14	; Anzahl Playfield-Farben >= 14
cl2_COLOR13			RS.L 1
	ENDC
	IFGE pf_colors_number-15	; Anzahl Playfield-Farben >= 15
cl2_COLOR14			RS.L 1
	ENDC
	IFGE pf_colors_number-16	; Anzahl Playfield-Farben >= 16
cl2_COLOR15			RS.L 1
	ENDC
	IFNE pf_colors_number-32
		IFNE spr_colors_number
cl2_COLOR16			RS.L 1
cl2_COLOR17			RS.L 1
cl2_COLOR18			RS.L 1
cl2_COLOR19			RS.L 1
cl2_COLOR20			RS.L 1
cl2_COLOR21			RS.L 1
cl2_COLOR22			RS.L 1
cl2_COLOR23			RS.L 1
cl2_COLOR24			RS.L 1
cl2_COLOR25			RS.L 1
cl2_COLOR26			RS.L 1
cl2_COLOR27			RS.L 1
cl2_COLOR28			RS.L 1
cl2_COLOR29			RS.L 1
cl2_COLOR30			RS.L 1
cl2_COLOR31			RS.L 1
		ENDC
	ELSE
cl2_COLOR16			RS.L 1
cl2_COLOR17			RS.L 1
cl2_COLOR18			RS.L 1
cl2_COLOR19			RS.L 1
cl2_COLOR20			RS.L 1
cl2_COLOR21			RS.L 1
cl2_COLOR22			RS.L 1
cl2_COLOR23			RS.L 1
cl2_COLOR24			RS.L 1
cl2_COLOR25			RS.L 1
cl2_COLOR26			RS.L 1
cl2_COLOR27			RS.L 1
cl2_COLOR28			RS.L 1
cl2_COLOR29			RS.L 1
cl2_COLOR30			RS.L 1
cl2_COLOR31			RS.L 1
	ENDC

	IFGE pf_depth-1
cl2_BPL1PTH			RS.L 1	; 1 Bitplane
cl2_BPL1PTL			RS.L 1
	ENDC

	IFGE pf_depth-2
cl2_BPL2PTH			RS.L 1	; 2 bitplanes
cl2_BPL2PTL			RS.L 1
	ENDC

	IFGE pf_depth-3
cl2_BPL3PTH			RS.L 1	; 3 Bitplanes
cl2_BPL3PTL			RS.L 1
	ENDC

	IFGE pf_depth-4
cl2_BPL4PTH			RS.L 1	; 4 Bitplanes
cl2_BPL4PTL			RS.L 1
	ENDC

	IFGE pf_depth-5
cl2_BPL5PTH			RS.L 1	; 5 Bitplanes
cl2_BPL5PTL			RS.L 1
	ENDC

	IFGE pf_depth-6
cl2_BPL6PTH			RS.L 1	; 6 Bitplanes
cl2_BPL6PTL			RS.L 1
	ENDC
