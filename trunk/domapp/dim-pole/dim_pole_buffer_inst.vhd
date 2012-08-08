dim_pole_buffer_inst : dim_pole_buffer PORT MAP (
		data	 => data_sig,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 => wren_sig,
		clock	 => clock_sig,
		q	 => q_sig
	);
