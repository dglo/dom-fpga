-- Copyright (C) 1991-2002 Altera Corporation
-- Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
-- support information,  device programming or simulation file,  and any other
-- associated  documentation or information  provided by  Altera  or a partner
-- under  Altera's   Megafunction   Partnership   Program  may  be  used  only
-- to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
-- other  use  of such  megafunction  design,  netlist,  support  information,
-- device programming or simulation file,  or any other  related documentation
-- or information  is prohibited  for  any  other purpose,  including, but not
-- limited to  modification,  reverse engineering,  de-compiling, or use  with
-- any other  silicon devices,  unless such use is  explicitly  licensed under
-- a separate agreement with  Altera  or a megafunction partner.  Title to the
-- intellectual property,  including patents,  copyrights,  trademarks,  trade
-- secrets,  or maskworks,  embodied in any such megafunction design, netlist,
-- support  information,  device programming or simulation file,  or any other
-- related documentation or information provided by  Altera  or a megafunction
-- partner, remains with Altera, the megafunction partner, or their respective
-- licensors. No other licenses, including any licenses needed under any third
-- party's intellectual property, are provided herein.

-- PROGRAM "Quartus II"
-- VERSION "Version 2.1 Build 166 07/08/2002 SJ Full Version"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY dcom_04 IS 
	port
	(
		BCLK :  IN  STD_LOGIC;
		CCLK :  IN  STD_LOGIC;
		mono_clk_en :  IN  STD_LOGIC;
		rs4_out :  IN  STD_LOGIC;
		msg_rd :  IN  STD_LOGIC;
		dom_A_sel_L :  IN  STD_LOGIC;
		dom_B_sel_L :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		tx_wrreq :  IN  STD_LOGIC;
		rx_rdreq :  IN  STD_LOGIC;
		drbt_req :  IN  STD_LOGIC;
		rs485_not_dac :  IN  STD_LOGIC;
		id_stb_L :  IN  STD_LOGIC;
		id_stb_H :  IN  STD_LOGIC;
		cal_thr :  IN  STD_LOGIC_VECTOR(9 downto 0);
		dudt :  IN  STD_LOGIC_VECTOR(7 downto 0);
		fc_adc :  IN  STD_LOGIC_VECTOR(9 downto 0);
		id :  IN  STD_LOGIC_VECTOR(47 downto 0);
		time :  IN  STD_LOGIC_VECTOR(47 downto 0);
		tx_fd :  IN  STD_LOGIC_VECTOR(7 downto 0);
		txd :  OUT  STD_LOGIC;
		last_byte :  OUT  STD_LOGIC;
		dac_clk :  OUT  STD_LOGIC;
		dac_slp :  OUT  STD_LOGIC;
		rs4_in :  OUT  STD_LOGIC;
		rs4_den :  OUT  STD_LOGIC;
		ntx_led :  OUT  STD_LOGIC;
		msg_sent :  OUT  STD_LOGIC;
		txwref :  OUT  STD_LOGIC;
		txwraef :  OUT  STD_LOGIC;
		txwrff :  OUT  STD_LOGIC;
		txrdef :  OUT  STD_LOGIC;
		txwraff :  OUT  STD_LOGIC;
		ctrl_sent :  OUT  STD_LOGIC;
		rs4_ren :  OUT  STD_LOGIC;
		nrx_led :  OUT  STD_LOGIC;
		adc_clk :  OUT  STD_LOGIC;
		data_stb :  OUT  STD_LOGIC;
		ctrl_stb :  OUT  STD_LOGIC;
		ctrl_err :  OUT  STD_LOGIC;
		rxwrff :  OUT  STD_LOGIC;
		rxwraff :  OUT  STD_LOGIC;
		rxrdef :  OUT  STD_LOGIC;
		stf_rcvd :  OUT  STD_LOGIC;
		eof_rcvd :  OUT  STD_LOGIC;
		bfstat_rcvd :  OUT  STD_LOGIC;
		drreq_rcvd :  OUT  STD_LOGIC;
		sysres_rcvd :  OUT  STD_LOGIC;
		comres_rcvd :  OUT  STD_LOGIC;
		msg_rcvd :  OUT  STD_LOGIC;
		msg_err :  OUT  STD_LOGIC;
		fifo_msg :  OUT  STD_LOGIC;
		nerr_led :  OUT  STD_LOGIC;
		hl_edge :  OUT  STD_LOGIC;
		lh_edge :  OUT  STD_LOGIC;
		rxd :  OUT  STD_LOGIC;
		drbt_gnt :  OUT  STD_LOGIC;
		com_aval :  OUT  STD_LOGIC;
		sys_res :  OUT  STD_LOGIC;
		tcal_rcvd :  OUT  STD_LOGIC;
		pulse_rcvd :  OUT  STD_LOGIC;
		pulse_sent :  OUT  STD_LOGIC;
		idreq_rcvd :  OUT  STD_LOGIC;
		dac_db :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		data :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		msg_ct_q :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		rev :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		rx_fq :  OUT  STD_LOGIC_VECTOR(7 downto 0)
	);
END dcom_04;

ARCHITECTURE bdf_type OF dcom_04 IS 

component dc_ctrl
	PORT(CLK : IN STD_LOGIC;
		 bfstat_rcvd : IN STD_LOGIC;
		 comres_rcvd : IN STD_LOGIC;
		 ctrl_sent : IN STD_LOGIC;
		 drbt_req : IN STD_LOGIC;
		 drreq_rcvd : IN STD_LOGIC;
		 eof_rcvd : IN STD_LOGIC;
		 id_data_avail : IN STD_LOGIC;
		 idreq_rcvd : IN STD_LOGIC;
		 line_quiet : IN STD_LOGIC;
		 msg_err : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 pulse_rcvd : IN STD_LOGIC;
		 pulse_sent : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rxwraff : IN STD_LOGIC;
		 stf_rcvd : IN STD_LOGIC;
		 sysres_rcvd : IN STD_LOGIC;
		 tcal_rcvd : IN STD_LOGIC;
		 txrdef : IN STD_LOGIC;
		 cmd_snd0 : OUT STD_LOGIC;
		 cmd_snd1 : OUT STD_LOGIC;
		 cmd_snd2 : OUT STD_LOGIC;
		 cmd_snd3 : OUT STD_LOGIC;
		 com_aval : OUT STD_LOGIC;
		 drbt_gnt : OUT STD_LOGIC;
		 rec_ctrl : OUT STD_LOGIC;
		 rec_data : OUT STD_LOGIC;
		 send_ctrl : OUT STD_LOGIC;
		 send_data : OUT STD_LOGIC;
		 send_id : OUT STD_LOGIC;
		 sys_res : OUT STD_LOGIC;
		 tcal_cyc : OUT STD_LOGIC;
		 tcal_data : OUT STD_LOGIC;
		 tcal_prec : OUT STD_LOGIC;
		 tcal_psnd : OUT STD_LOGIC
	);
end component;

component dc_rx_chan_04
	PORT(BCLK : IN STD_LOGIC;
		 CCLK : IN STD_LOGIC;
		 rec_ctrl : IN STD_LOGIC;
		 tcal_prec : IN STD_LOGIC;
		 rx_rdreq : IN STD_LOGIC;
		 msg_rd : IN STD_LOGIC;
		 dom_A_sel_L : IN STD_LOGIC;
		 dom_B_sel_L : IN STD_LOGIC;
		 mono_clk_en : IN STD_LOGIC;
		 tcwf_rd_next : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 cal_thr : IN STD_LOGIC_VECTOR(9 downto 0);
		 dudt : IN STD_LOGIC_VECTOR(7 downto 0);
		 fc_adc : IN STD_LOGIC_VECTOR(9 downto 0);
		 hl_edge : OUT STD_LOGIC;
		 lh_edge : OUT STD_LOGIC;
		 rxd : OUT STD_LOGIC;
		 adc_clk : OUT STD_LOGIC;
		 rs4_ren : OUT STD_LOGIC;
		 nrx_led : OUT STD_LOGIC;
		 nerr_led : OUT STD_LOGIC;
		 rxwrff : OUT STD_LOGIC;
		 rxwraff : OUT STD_LOGIC;
		 rxrdef : OUT STD_LOGIC;
		 stf_rcvd : OUT STD_LOGIC;
		 eof_rcvd : OUT STD_LOGIC;
		 bfstat_rcvd : OUT STD_LOGIC;
		 drreq_rcvd : OUT STD_LOGIC;
		 sysres_rcvd : OUT STD_LOGIC;
		 comres_rcvd : OUT STD_LOGIC;
		 tcal_rcvd : OUT STD_LOGIC;
		 idreq_rcvd : OUT STD_LOGIC;
		 msg_rcvd : OUT STD_LOGIC;
		 msg_err : OUT STD_LOGIC;
		 ctrl_stb : OUT STD_LOGIC;
		 ctrl_err : OUT STD_LOGIC;
		 data_stb : OUT STD_LOGIC;
		 fifo_msg : OUT STD_LOGIC;
		 rx_time_lat : OUT STD_LOGIC;
		 tcwf_data_val : OUT STD_LOGIC;
		 tcwf_ef : OUT STD_LOGIC;
		 pulse_rcvd : OUT STD_LOGIC;
		 data : OUT STD_LOGIC_VECTOR(7 downto 0);
		 msg_ct_q : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rx_fq : OUT STD_LOGIC_VECTOR(7 downto 0);
		 tcwf_data : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

component dc_tx_chan_04
	PORT(mono_clk_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 comres_rcvd : IN STD_LOGIC;
		 BCLK : IN STD_LOGIC;
		 CCLK : IN STD_LOGIC;
		 tx_wrreq : IN STD_LOGIC;
		 cmd_snd0 : IN STD_LOGIC;
		 cmd_snd1 : IN STD_LOGIC;
		 cmd_snd2 : IN STD_LOGIC;
		 cmd_snd3 : IN STD_LOGIC;
		 dom_B_sel_L : IN STD_LOGIC;
		 send_ctrl : IN STD_LOGIC;
		 send_data : IN STD_LOGIC;
		 send_id : IN STD_LOGIC;
		 tcal_data : IN STD_LOGIC;
		 rs485_not_dac : IN STD_LOGIC;
		 h_pulse : IN STD_LOGIC;
		 tcwf_ef : IN STD_LOGIC;
		 l_pulse : IN STD_LOGIC;
		 rx_time_lat : IN STD_LOGIC;
		 tx_time_lat : IN STD_LOGIC;
		 id_stb_L : IN STD_LOGIC;
		 id_stb_H : IN STD_LOGIC;
		 id : IN STD_LOGIC_VECTOR(47 downto 0);
		 tcwf_data : IN STD_LOGIC_VECTOR(15 downto 0);
		 time : IN STD_LOGIC_VECTOR(47 downto 0);
		 tx_fd : IN STD_LOGIC_VECTOR(7 downto 0);
		 dac_clk : OUT STD_LOGIC;
		 dac_slp : OUT STD_LOGIC;
		 rs4_in : OUT STD_LOGIC;
		 rs4_den : OUT STD_LOGIC;
		 ntx_led : OUT STD_LOGIC;
		 txd : OUT STD_LOGIC;
		 txwref : OUT STD_LOGIC;
		 txwraef : OUT STD_LOGIC;
		 txwraff : OUT STD_LOGIC;
		 txwrff : OUT STD_LOGIC;
		 txrdef : OUT STD_LOGIC;
		 last_byte : OUT STD_LOGIC;
		 msg_sent : OUT STD_LOGIC;
		 ctrl_sent : OUT STD_LOGIC;
		 tcwf_rd_next : OUT STD_LOGIC;
		 id_data_avail : OUT STD_LOGIC;
		 dac_db : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

component tcal_timer
	PORT(CCLK : IN STD_LOGIC;
		 tcal_psnd : IN STD_LOGIC;
		 line_quiet : OUT STD_LOGIC;
		 h_pulse : OUT STD_LOGIC;
		 l_pulse : OUT STD_LOGIC;
		 pulse_sent : OUT STD_LOGIC;
		 tx_time_lat : OUT STD_LOGIC
	);
end component;

component dcrev
	PORT(		 result : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

signal	GND :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
signal	altera_synthesized_wire_38 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
signal	altera_synthesized_wire_39 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_22 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_23 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_24 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_25 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_26 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_27 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_28 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_29 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_30 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_31 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_33 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_34 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_35 :  STD_LOGIC_VECTOR(15 downto 0);
signal	SYNTHESIZED_WIRE_36 :  STD_LOGIC;


BEGIN 
msg_sent <= altera_synthesized_wire_39;
txrdef <= SYNTHESIZED_WIRE_16;
ctrl_sent <= SYNTHESIZED_WIRE_2;
rxwraff <= SYNTHESIZED_WIRE_12;
stf_rcvd <= SYNTHESIZED_WIRE_13;
eof_rcvd <= SYNTHESIZED_WIRE_4;
bfstat_rcvd <= SYNTHESIZED_WIRE_0;
drreq_rcvd <= SYNTHESIZED_WIRE_3;
sysres_rcvd <= SYNTHESIZED_WIRE_14;
comres_rcvd <= altera_synthesized_wire_38;
msg_err <= SYNTHESIZED_WIRE_8;
tcal_rcvd <= SYNTHESIZED_WIRE_15;
pulse_rcvd <= SYNTHESIZED_WIRE_10;
pulse_sent <= SYNTHESIZED_WIRE_11;
idreq_rcvd <= SYNTHESIZED_WIRE_6;



b2v_DC_CTRL : dc_ctrl
PORT MAP(CLK => CCLK,
		 bfstat_rcvd => SYNTHESIZED_WIRE_0,
		 comres_rcvd => altera_synthesized_wire_38,
		 ctrl_sent => SYNTHESIZED_WIRE_2,
		 drbt_req => drbt_req,
		 drreq_rcvd => SYNTHESIZED_WIRE_3,
		 eof_rcvd => SYNTHESIZED_WIRE_4,
		 id_data_avail => SYNTHESIZED_WIRE_5,
		 idreq_rcvd => SYNTHESIZED_WIRE_6,
		 line_quiet => SYNTHESIZED_WIRE_7,
		 msg_err => SYNTHESIZED_WIRE_8,
		 msg_sent => altera_synthesized_wire_39,
		 pulse_rcvd => SYNTHESIZED_WIRE_10,
		 pulse_sent => SYNTHESIZED_WIRE_11,
		 reset => reset,
		 rxwraff => SYNTHESIZED_WIRE_12,
		 stf_rcvd => SYNTHESIZED_WIRE_13,
		 sysres_rcvd => SYNTHESIZED_WIRE_14,
		 tcal_rcvd => SYNTHESIZED_WIRE_15,
		 txrdef => SYNTHESIZED_WIRE_16,
		 cmd_snd0 => SYNTHESIZED_WIRE_22,
		 cmd_snd1 => SYNTHESIZED_WIRE_23,
		 cmd_snd2 => SYNTHESIZED_WIRE_24,
		 cmd_snd3 => SYNTHESIZED_WIRE_25,
		 com_aval => com_aval,
		 drbt_gnt => drbt_gnt,
		 rec_ctrl => SYNTHESIZED_WIRE_17,
		 send_ctrl => SYNTHESIZED_WIRE_26,
		 send_data => SYNTHESIZED_WIRE_27,
		 send_id => SYNTHESIZED_WIRE_28,
		 sys_res => sys_res,
		 tcal_data => SYNTHESIZED_WIRE_29,
		 tcal_prec => SYNTHESIZED_WIRE_18,
		 tcal_psnd => SYNTHESIZED_WIRE_36);

b2v_DC_Rx_chan_04 : dc_rx_chan_04
PORT MAP(BCLK => BCLK,
		 CCLK => CCLK,
		 rec_ctrl => SYNTHESIZED_WIRE_17,
		 tcal_prec => SYNTHESIZED_WIRE_18,
		 rx_rdreq => rx_rdreq,
		 msg_rd => msg_rd,
		 dom_A_sel_L => dom_A_sel_L,
		 dom_B_sel_L => dom_B_sel_L,
		 mono_clk_en => mono_clk_en,
		 tcwf_rd_next => SYNTHESIZED_WIRE_19,
		 reset => reset,
		 msg_sent => altera_synthesized_wire_39,
		 cal_thr => cal_thr,
		 dudt => dudt,
		 fc_adc => fc_adc,
		 hl_edge => hl_edge,
		 lh_edge => lh_edge,
		 rxd => rxd,
		 adc_clk => adc_clk,
		 rs4_ren => rs4_ren,
		 nrx_led => nrx_led,
		 nerr_led => nerr_led,
		 rxwrff => rxwrff,
		 rxwraff => SYNTHESIZED_WIRE_12,
		 rxrdef => rxrdef,
		 stf_rcvd => SYNTHESIZED_WIRE_13,
		 eof_rcvd => SYNTHESIZED_WIRE_4,
		 bfstat_rcvd => SYNTHESIZED_WIRE_0,
		 drreq_rcvd => SYNTHESIZED_WIRE_3,
		 sysres_rcvd => SYNTHESIZED_WIRE_14,
		 comres_rcvd => altera_synthesized_wire_38,
		 tcal_rcvd => SYNTHESIZED_WIRE_15,
		 idreq_rcvd => SYNTHESIZED_WIRE_6,
		 msg_rcvd => msg_rcvd,
		 msg_err => SYNTHESIZED_WIRE_8,
		 ctrl_stb => ctrl_stb,
		 ctrl_err => ctrl_err,
		 data_stb => data_stb,
		 fifo_msg => fifo_msg,
		 rx_time_lat => SYNTHESIZED_WIRE_33,
		 tcwf_ef => SYNTHESIZED_WIRE_31,
		 pulse_rcvd => SYNTHESIZED_WIRE_10,
		 data => data,
		 msg_ct_q => msg_ct_q,
		 rx_fq => rx_fq,
		 tcwf_data => SYNTHESIZED_WIRE_35);

b2v_DC_Tx_chan_04 : dc_tx_chan_04
PORT MAP(mono_clk_en => mono_clk_en,
		 reset => reset,
		 comres_rcvd => altera_synthesized_wire_38,
		 BCLK => BCLK,
		 CCLK => CCLK,
		 tx_wrreq => tx_wrreq,
		 cmd_snd0 => SYNTHESIZED_WIRE_22,
		 cmd_snd1 => SYNTHESIZED_WIRE_23,
		 cmd_snd2 => SYNTHESIZED_WIRE_24,
		 cmd_snd3 => SYNTHESIZED_WIRE_25,
		 dom_B_sel_L => dom_B_sel_L,
		 send_ctrl => SYNTHESIZED_WIRE_26,
		 send_data => SYNTHESIZED_WIRE_27,
		 send_id => SYNTHESIZED_WIRE_28,
		 tcal_data => SYNTHESIZED_WIRE_29,
		 rs485_not_dac => rs485_not_dac,
		 h_pulse => SYNTHESIZED_WIRE_30,
		 tcwf_ef => SYNTHESIZED_WIRE_31,
		 l_pulse => SYNTHESIZED_WIRE_32,
		 rx_time_lat => SYNTHESIZED_WIRE_33,
		 tx_time_lat => SYNTHESIZED_WIRE_34,
		 id_stb_L => id_stb_L,
		 id_stb_H => id_stb_H,
		 id => id,
		 tcwf_data => SYNTHESIZED_WIRE_35,
		 time => time,
		 tx_fd => tx_fd,
		 dac_clk => dac_clk,
		 dac_slp => dac_slp,
		 rs4_in => rs4_in,
		 rs4_den => rs4_den,
		 ntx_led => ntx_led,
		 txd => txd,
		 txwref => txwref,
		 txwraef => txwraef,
		 txwraff => txwraff,
		 txwrff => txwrff,
		 txrdef => SYNTHESIZED_WIRE_16,
		 last_byte => last_byte,
		 msg_sent => altera_synthesized_wire_39,
		 ctrl_sent => SYNTHESIZED_WIRE_2,
		 tcwf_rd_next => SYNTHESIZED_WIRE_19,
		 id_data_avail => SYNTHESIZED_WIRE_5,
		 dac_db => dac_db);

b2v_inst1 : tcal_timer
PORT MAP(CCLK => CCLK,
		 tcal_psnd => SYNTHESIZED_WIRE_36,
		 line_quiet => SYNTHESIZED_WIRE_7,
		 h_pulse => SYNTHESIZED_WIRE_30,
		 l_pulse => SYNTHESIZED_WIRE_32,
		 pulse_sent => SYNTHESIZED_WIRE_11,
		 tx_time_lat => SYNTHESIZED_WIRE_34);

b2v_inst5 : dcrev
PORT MAP(		 result => rev);

GND <= '0';
END; 