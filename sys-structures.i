	IFND SYS_TAKEN_OVER
		CNOP 0,4
custom_error_table
		DS.B custom_error_entry_size*custom_errors_number

		IFEQ requires_multiscan_monitor
			CNOP 0,4
monitor_request_intui_text_body
			DS.B it_SIZEOF

			CNOP 0,4
monitor_request_intui_text_pos
			DS.B it_SIZEOF

			CNOP 0,4
monitor_request_intui_text_neg
			DS.B it_SIZEOF

			CNOP 0,4
		ENDC

		IFNE intena_bits&INTF_PORTS
			CNOP 0,4
tcp_stack_request_text_body
			DS.B it_SIZEOF

			CNOP 0,4
tcp_stack_request_text_pos
			DS.B it_SIZEOF

			CNOP 0,4
tcp_stack_request_text_neg
			DS.B it_SIZEOF

			CNOP 0,4
		ENDC


		CNOP 0,4
timer_io
		DS.B IOTV_SIZE
	

		CNOP 0,4
pal_extended_newscreen
		DS.B ens_SIZEOF

		CNOP 0,2
pal_screen_rgb4_colors
		DS.W pal_screen_colors_number

		CNOP 0,4
video_control_tags
		DS.B video_control_tag_list_size

		CNOP 0,2
pal_screen_color_spec
		DS.B cs2_SIZEOF*(pal_screen_max_colors_number+1)

		CNOP 0,4
pal_screen_tags
		DS.B screen_tag_list_size

		CNOP 0,4
invisible_extended_newwindow
		DS.B enw_SIZEOF

		CNOP 0,4
invisible_window_tags
		DS.B window_tag_list_size
	ENDC
