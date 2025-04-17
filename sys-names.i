	IFND SYS_TAKEN_OVER
dos_name			DC.B "dos.library",0
		EVEN
graphics_name			DC.B "graphics.library",0
		EVEN
intuition_name			DC.B "intuition.library",0
ciaa_name			DC.B "ciaa.resource",0
		EVEN
ciab_name			DC.B "ciab.resource",0
		EVEN
timer_device_name		DC.B "timer.device",0
		EVEN

		IFEQ requires_multiscan_monitor
monitor_request_string_body	DC.B "VGA screen with horizontal frequency of 31 kHz will be opened.",0
			EVEN
monitor_request_string_pos	DC.B "Proceed",0
monitor_request_string_neg	DC.B "Quit",0
			EVEN
		ENDC

		IFNE intena_bits&INTF_PORTS
bsdsocket_name			DC.B "bsdsocket.library",0
			EVEN

tcp_stack_request_string_body	DC.B "Active TCP/IP-stack detected. This has affects on interrupt handling.",0
			EVEN
tcp_stack_request_string_pos	DC.B "Proceed",0
tcp_stack_request_string_neg	DC.B "Quit",0
			EVEN
		ENDC

pal_screen_name			DC.B "Degrade screen",0
		EVEN

invisible_window_name		DC.B "Invisible window",0
		EVEN
		
raw_name			DC.B "RAW:0/0/640/80/  **  Message Window  **  ",0
		EVEN
	ENDC
