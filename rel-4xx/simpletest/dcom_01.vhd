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
-- VERSION "Version 2.2 Build 147 12/02/2002 SJ Full Version"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY dcom_01 IS 
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
		line_quiet :  IN  STD_LOGIC;
		pulse_rcvd :  IN  STD_LOGIC;
		pulse_sent :  IN  STD_LOGIC;
		rx_rdreq :  IN  STD_LOGIC;
		dec_thr :  IN  STD_LOGIC_VECTOR(9 downto 0);
		fc_adc :  IN  STD_LOGIC_VECTOR(9 downto 0);
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
		dac_db :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		data :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		msg_ct_q :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		rx_fq :  OUT  STD_LOGIC_VECTOR(7 downto 0)
	);
END dcom_01;

ARCHITECTURE bdf_type OF dcom_01 IS 

component dc_ctrl
	PORT(CLK : IN STD_LOGIC;
		 bfstat_rcvd : IN STD_LOGIC;
		 comres_rcvd : IN STD_LOGIC;
		 ctrl_sent : IN STD_LOGIC;
		 drreq_rcvd : IN STD_LOGIC;
		 eof_rcvd : IN STD_LOGIC;
		 line_quiet : IN STD_LOGIC;
		 msg_err : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 pulse_rcvd : IN STD_LOGIC;
		 pulse_sent : IN STD_LOGIC;
		 rxwraff : IN STD_LOGIC;
		 stf_rcvd : IN STD_LOGIC;
		 sysres_rcvd : IN STD_LOGIC;
		 tcal_rcvd : IN STD_LOGIC;
		 txrdef : IN STD_LOGIC;
		 cmd_snd0 : OUT STD_LOGIC;
		 cmd_snd1 : OUT STD_LOGIC;
		 cmd_snd2 : OUT STD_LOGIC;
		 cmd_snd3 : OUT STD_LOGIC;
		 rec_ctrl : OUT STD_LOGIC;
		 rec_data : OUT STD_LOGIC;
		 send_ctrl : OUT STD_LOGIC;
		 send_data : OUT STD_LOGIC;
		 sys_res : OUT STD_LOGIC;
		 tcal_cmd : OUT STD_LOGIC;
		 tcal_data : OUT STD_LOGIC;
		 tcal_prec : OUT STD_LOGIC;
		 tcal_psnd : OUT STD_LOGIC
	);
end component;

component dc_rx_chan_01
	PORT(BCLK : IN STD_LOGIC;
		 CCLK : IN STD_LOGIC;
		 rec_data : IN STD_LOGIC;
		 rec_ctrl : IN STD_LOGIC;
		 rx_rdreq : IN STD_LOGIC;
		 msg_rd : IN STD_LOGIC;
		 dom_A_sel_L : IN STD_LOGIC;
		 dom_B_sel_L : IN STD_LOGIC;
		 mono_clk_en : IN STD_LOGIC;
		 rs4_out : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 dec_thr : IN STD_LOGIC_VECTOR(9 downto 0);
		 fc_adc : IN STD_LOGIC_VECTOR(9 downto 0);
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
		 msg_rcvd : OUT STD_LOGIC;
		 msg_err : OUT STD_LOGIC;
		 ctrl_stb : OUT STD_LOGIC;
		 ctrl_err : OUT STD_LOGIC;
		 data_stb : OUT STD_LOGIC;
		 fifo_msg : OUT STD_LOGIC;
		 data : OUT STD_LOGIC_VECTOR(7 downto 0);
		 msg_ct_q : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rx_fq : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

component dc_tx_chan_01
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
		 dac_db : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

signal	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
signal	altera_synthesized_wire_18 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_17 :  STD_LOGIC;


BEGIN 
rxwraff <= SYNTHESIZED_WIRE_5;
stf_rcvd <= SYNTHESIZED_WIRE_6;
eof_rcvd <= SYNTHESIZED_WIRE_3;
bfstat_rcvd <= SYNTHESIZED_WIRE_0;
drreq_rcvd <= SYNTHESIZED_WIRE_2;
sysres_rcvd <= SYNTHESIZED_WIRE_7;
comres_rcvd <= altera_synthesized_wire_18;
msg_err <= SYNTHESIZED_WIRE_4;



b2v_DC_CTRL : dc_ctrl
PORT MAP(CLK => CCLK,
		 bfstat_rcvd => SYNTHESIZED_WIRE_0,
		 comres_rcvd => altera_synthesized_wire_18,
		 ctrl_sent => ,
		 drreq_rcvd => SYNTHESIZED_WIRE_2,
		 eof_rcvd => SYNTHESIZED_WIRE_3,
		 line_quiet => line_quiet,
		 msg_err => SYNTHESIZED_WIRE_4,
		 msg_sent => ,
		 pulse_rcvd => pulse_rcvd,
		 pulse_sent => pulse_sent,
		 rxwraff => SYNTHESIZED_WIRE_5,
		 stf_rcvd => SYNTHESIZED_WIRE_6,
		 sysres_rcvd => SYNTHESIZED_WIRE_7,
		 tcal_rcvd => SYNTHESIZED_WIRE_8,
		 txrdef => ,
		 cmd_snd0 => SYNTHESIZED_WIRE_12,
		 cmd_snd1 => SYNTHESIZED_WIRE_13,
		 cmd_snd2 => SYNTHESIZED_WIRE_14,
		 cmd_snd3 => SYNTHESIZED_WIRE_15,
		 rec_ctrl => SYNTHESIZED_WIRE_10,
		 rec_data => SYNTHESIZED_WIRE_9,
		 send_ctrl => SYNTHESIZED_WIRE_16,
		 send_data => SYNTHESIZED_WIRE_17);

b2v_DC_Rx_chan_01 : dc_rx_chan_01
PORT MAP(BCLK => BCLK,
		 CCLK => CCLK,
		 rec_data => SYNTHESIZED_WIRE_9,
		 rec_ctrl => SYNTHESIZED_WIRE_10,
		 rx_rdreq => rx_rdreq,
		 msg_rd => msg_rd,
		 dom_A_sel_L => dom_A_sel_L,
		 dom_B_sel_L => dom_B_sel_L,
		 mono_clk_en => mono_clk_en,
		 rs4_out => rs4_out,
		 reset => reset,
		 dec_thr => dec_thr,
		 fc_adc => fc_adc,
		 adc_clk => adc_clk,
		 rs4_ren => rs4_ren,
		 nrx_led => nrx_led,
		 nerr_led => nerr_led,
		 rxwrff => rxwrff,
		 rxwraff => SYNTHESIZED_WIRE_5,
		 rxrdef => rxrdef,
		 stf_rcvd => SYNTHESIZED_WIRE_6,
		 eof_rcvd => SYNTHESIZED_WIRE_3,
		 bfstat_rcvd => SYNTHESIZED_WIRE_0,
		 drreq_rcvd => SYNTHESIZED_WIRE_2,
		 sysres_rcvd => SYNTHESIZED_WIRE_7,
		 comres_rcvd => altera_synthesized_wire_18,
		 tcal_rcvd => SYNTHESIZED_WIRE_8,
		 msg_rcvd => msg_rcvd,
		 msg_err => SYNTHESIZED_WIRE_4,
		 ctrl_stb => ctrl_stb,
		 ctrl_err => ctrl_err,
		 data_stb => data_stb,
		 fifo_msg => fifo_msg,
		 data => data,
		 msg_ct_q => msg_ct_q,
		 rx_fq => rx_fq);

b2v_DC_Tx_chan_01 : dc_tx_chan_01
PORT MAP(mono_clk_en => mono_clk_en,
		 reset => reset,
		 comres_rcvd => altera_synthesized_wire_18,
		 BCLK => BCLK,
		 CCLK => CCLK,
		 tx_wrreq => tx_wrreq,
		 cmd_snd0 => SYNTHESIZED_WIRE_12,
		 cmd_snd1 => SYNTHESIZED_WIRE_13,
		 cmd_snd2 => SYNTHESIZED_WIRE_14,
		 cmd_snd3 => SYNTHESIZED_WIRE_15,
		 dom_B_sel_L => dom_B_sel_L,
		 send_ctrl => SYNTHESIZED_WIRE_16,
		 send_data => SYNTHESIZED_WIRE_17,
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
		 txrdef => txrdef,
		 last_byte => last_byte,
		 msg_sent => msg_sent,
		 ctrl_sent => ctrl_sent,
		 dac_db => dac_db);

END; 