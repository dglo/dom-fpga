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

ENTITY dcom_dpr IS 
	port
	(
		tx_pack_rdy :  IN  STD_LOGIC;
		rx_dpr_radr_stb :  IN  STD_LOGIC;
		CLK20 :  IN  STD_LOGIC;
		A_nB :  IN  STD_LOGIC;
		reboot_req :  IN  STD_LOGIC;
		id_avail :  IN  STD_LOGIC;
		HVD_Rx :  IN  STD_LOGIC;
		COM_AD_D :  IN  STD_LOGIC_VECTOR(9 downto 0);
		id :  IN  STD_LOGIC_VECTOR(47 downto 0);
		rx_dpr_radr :  IN  STD_LOGIC_VECTOR(15 downto 0);
		systime :  IN  STD_LOGIC_VECTOR(47 downto 0);
		tx_dataout :  IN  STD_LOGIC_VECTOR(7 downto 0);
		tx_dpr_wadr :  IN  STD_LOGIC_VECTOR(15 downto 0);
		tx_pack_sent :  OUT  STD_LOGIC;
		rx_dpr_aff :  OUT  STD_LOGIC;
		rx_busy :  OUT  STD_LOGIC;
		rx_pack_rcvd :  OUT  STD_LOGIC;
		rx_we :  OUT  STD_LOGIC;
		HDV_Rx_ENA :  OUT  STD_LOGIC;
		reboot_gnt :  OUT  STD_LOGIC;
		com_avail :  OUT  STD_LOGIC;
		COMM_RESET :  OUT  STD_LOGIC;
		COM_TX_SLEEP :  OUT  STD_LOGIC;
		HDV_IN :  OUT  STD_LOGIC;
		HDV_TxENA :  OUT  STD_LOGIC;
		tx_alm_empty :  OUT  STD_LOGIC;
		COM_DB :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		rev :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		rx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		rx_datain :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		rx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		tx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		tx_dpr_radr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		tx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0)
	);
END dcom_dpr;

ARCHITECTURE bdf_type OF dcom_dpr IS 

component dc_rx_chan_dpr
	PORT(CLK20 : IN STD_LOGIC;
		 A_nB : IN STD_LOGIC;
		 HVD_Rx : IN STD_LOGIC;
		 rx_dpr_radr_stb : IN STD_LOGIC;
		 rec_ena : IN STD_LOGIC;
		 rec_data : IN STD_LOGIC;
		 rec_ctrl : IN STD_LOGIC;
		 send_data : IN STD_LOGIC;
		 send_ctrl : IN STD_LOGIC;
		 tcal_prec : IN STD_LOGIC;
		 tcal_psnd : IN STD_LOGIC;
		 tcwf_rd_next : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 COM_AD_D : IN STD_LOGIC_VECTOR(9 downto 0);
		 rx_dpr_radr : IN STD_LOGIC_VECTOR(15 downto 0);
		 HDV_RxENA : OUT STD_LOGIC;
		 rx_we : OUT STD_LOGIC;
		 rx_pack_rcvd : OUT STD_LOGIC;
		 rx_busy : OUT STD_LOGIC;
		 rx_dpr_aff : OUT STD_LOGIC;
		 my_adr : OUT STD_LOGIC;
		 stf_rcvd : OUT STD_LOGIC;
		 eof_rcvd : OUT STD_LOGIC;
		 bfstat_rcvd : OUT STD_LOGIC;
		 drreq_rcvd : OUT STD_LOGIC;
		 sysres_rcvd : OUT STD_LOGIC;
		 comres_rcvd : OUT STD_LOGIC;
		 tcal_rcvd : OUT STD_LOGIC;
		 idreq_rcvd : OUT STD_LOGIC;
		 idle_rcvd : OUT STD_LOGIC;
		 msg_rcvd : OUT STD_LOGIC;
		 msg_err : OUT STD_LOGIC;
		 ctrl_stb : OUT STD_LOGIC;
		 ctrl_err : OUT STD_LOGIC;
		 data_stb : OUT STD_LOGIC;
		 pulse_rcvd : OUT STD_LOGIC;
		 tcwf_data_val : OUT STD_LOGIC;
		 tcwf_ef : OUT STD_LOGIC;
		 rx_time_lat : OUT STD_LOGIC;
		 hl_edge : OUT STD_LOGIC;
		 lh_edge : OUT STD_LOGIC;
		 rxd : OUT STD_LOGIC;
		 data : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rx_addr : OUT STD_LOGIC_VECTOR(15 downto 0);
		 rx_datain : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rx_error : OUT STD_LOGIC_VECTOR(15 downto 0);
		 tcwf_data : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

component dc_tx_chan_dpr
	PORT(CLK20 : IN STD_LOGIC;
		 comres_rcvd : IN STD_LOGIC;
		 A_nB : IN STD_LOGIC;
		 tx_pack_rdy : IN STD_LOGIC;
		 id_avail : IN STD_LOGIC;
		 cmd_snd0 : IN STD_LOGIC;
		 cmd_snd1 : IN STD_LOGIC;
		 cmd_snd2 : IN STD_LOGIC;
		 cmd_snd3 : IN STD_LOGIC;
		 send_ctrl : IN STD_LOGIC;
		 send_data : IN STD_LOGIC;
		 send_id : IN STD_LOGIC;
		 tcal_data : IN STD_LOGIC;
		 tcwf_ef : IN STD_LOGIC;
		 h_pulse : IN STD_LOGIC;
		 l_pulse : IN STD_LOGIC;
		 rx_time_lat : IN STD_LOGIC;
		 tx_time_lat : IN STD_LOGIC;
		 id : IN STD_LOGIC_VECTOR(47 downto 0);
		 systime : IN STD_LOGIC_VECTOR(47 downto 0);
		 tcwf_data : IN STD_LOGIC_VECTOR(15 downto 0);
		 tx_dataout : IN STD_LOGIC_VECTOR(7 downto 0);
		 tx_dpr_wadr : IN STD_LOGIC_VECTOR(15 downto 0);
		 COM_TX_SLEEP : OUT STD_LOGIC;
		 HVD_IN : OUT STD_LOGIC;
		 HVD_TxENA : OUT STD_LOGIC;
		 tx_pack_sent : OUT STD_LOGIC;
		 tx_alm_empty : OUT STD_LOGIC;
		 tx_empty : OUT STD_LOGIC;
		 txd : OUT STD_LOGIC;
		 last_byte : OUT STD_LOGIC;
		 msg_sent : OUT STD_LOGIC;
		 ctrl_sent : OUT STD_LOGIC;
		 tcwf_rd_next : OUT STD_LOGIC;
		 id_data_avail : OUT STD_LOGIC;
		 COM_DB : OUT STD_LOGIC_VECTOR(7 downto 0);
		 tx_addr : OUT STD_LOGIC_VECTOR(15 downto 0);
		 tx_dpr_radr : OUT STD_LOGIC_VECTOR(15 downto 0);
		 tx_error : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

component dcc_dpr
	PORT(CLK : IN STD_LOGIC;
		 bfstat_rcvd : IN STD_LOGIC;
		 comres_rcvd : IN STD_LOGIC;
		 ctrl_err : IN STD_LOGIC;
		 ctrl_sent : IN STD_LOGIC;
		 ctrl_stb : IN STD_LOGIC;
		 data_stb : IN STD_LOGIC;
		 del_15us : IN STD_LOGIC;
		 dpr_rx_aff : IN STD_LOGIC;
		 dpr_tx_ef : IN STD_LOGIC;
		 drreq_rcvd : IN STD_LOGIC;
		 eof_rcvd : IN STD_LOGIC;
		 id_data_avail : IN STD_LOGIC;
		 idle_rcvd : IN STD_LOGIC;
		 idreq_rcvd : IN STD_LOGIC;
		 msg_err : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 my_adr : IN STD_LOGIC;
		 pulse_rcvd : IN STD_LOGIC;
		 pulse_sent : IN STD_LOGIC;
		 reboot_req : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 stf_rcvd : IN STD_LOGIC;
		 sysres_rcvd : IN STD_LOGIC;
		 tcal_rcvd : IN STD_LOGIC;
		 time_bit_18 : IN STD_LOGIC;
		 cmd_snd0 : OUT STD_LOGIC;
		 cmd_snd1 : OUT STD_LOGIC;
		 cmd_snd2 : OUT STD_LOGIC;
		 cmd_snd3 : OUT STD_LOGIC;
		 com_avail : OUT STD_LOGIC;
		 COMM_RESET : OUT STD_LOGIC;
		 reboot_gnt : OUT STD_LOGIC;
		 rec_ctrl : OUT STD_LOGIC;
		 rec_data : OUT STD_LOGIC;
		 rec_ena : OUT STD_LOGIC;
		 send_ctrl : OUT STD_LOGIC;
		 send_data : OUT STD_LOGIC;
		 send_id : OUT STD_LOGIC;
		 tcal_cyc : OUT STD_LOGIC;
		 tcal_data : OUT STD_LOGIC;
		 tcal_prec : OUT STD_LOGIC;
		 tcal_psnd : OUT STD_LOGIC;
		 timer_clrn : OUT STD_LOGIC
	);
end component;

component dcom_tcal_timer
	PORT(CLK20 : IN STD_LOGIC;
		 tcal_psnd : IN STD_LOGIC;
		 timer_clrn : IN STD_LOGIC;
		 del_15us : OUT STD_LOGIC;
		 h_pulse : OUT STD_LOGIC;
		 l_pulse : OUT STD_LOGIC;
		 pulse_sent : OUT STD_LOGIC;
		 tx_time_lat : OUT STD_LOGIC
	);
end component;

component dcrev_dpr
	PORT(		 result : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

signal	GND :  STD_LOGIC;
signal	rx_dpr_aff_ALTERA_SYNTHESIZED :  STD_LOGIC;
signal	tx_empty :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
signal	altera_synthesized_wire_46 :  STD_LOGIC;
signal	altera_synthesized_wire_47 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
signal	altera_synthesized_wire_48 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
signal	altera_synthesized_wire_49 :  STD_LOGIC;
signal	altera_synthesized_wire_50 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_21 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_22 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_23 :  STD_LOGIC_VECTOR(15 downto 0);
signal	SYNTHESIZED_WIRE_24 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_26 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_27 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_28 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_29 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_30 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_31 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_33 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_34 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_35 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_36 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_38 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_39 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_40 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_41 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_42 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_43 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_45 :  STD_LOGIC;


BEGIN 



b2v_DC_Rx_chan : dc_rx_chan_dpr
PORT MAP(CLK20 => CLK20,
		 A_nB => A_nB,
		 HVD_Rx => HVD_Rx,
		 rx_dpr_radr_stb => rx_dpr_radr_stb,
		 rec_ena => SYNTHESIZED_WIRE_0,
		 rec_data => SYNTHESIZED_WIRE_1,
		 rec_ctrl => SYNTHESIZED_WIRE_2,
		 send_data => altera_synthesized_wire_46,
		 send_ctrl => altera_synthesized_wire_47,
		 tcal_prec => SYNTHESIZED_WIRE_5,
		 tcal_psnd => altera_synthesized_wire_48,
		 tcwf_rd_next => SYNTHESIZED_WIRE_7,
		 msg_sent => altera_synthesized_wire_49,
		 COM_AD_D => COM_AD_D,
		 rx_dpr_radr => rx_dpr_radr,
		 rx_we => rx_we,
		 rx_pack_rcvd => rx_pack_rcvd,
		 rx_busy => rx_busy,
		 rx_dpr_aff => rx_dpr_aff_ALTERA_SYNTHESIZED,
		 my_adr => SYNTHESIZED_WIRE_38,
		 stf_rcvd => SYNTHESIZED_WIRE_41,
		 eof_rcvd => SYNTHESIZED_WIRE_32,
		 bfstat_rcvd => SYNTHESIZED_WIRE_24,
		 drreq_rcvd => SYNTHESIZED_WIRE_31,
		 sysres_rcvd => SYNTHESIZED_WIRE_42,
		 comres_rcvd => altera_synthesized_wire_50,
		 tcal_rcvd => SYNTHESIZED_WIRE_43,
		 idreq_rcvd => SYNTHESIZED_WIRE_35,
		 idle_rcvd => SYNTHESIZED_WIRE_34,
		 msg_err => SYNTHESIZED_WIRE_36,
		 ctrl_stb => SYNTHESIZED_WIRE_28,
		 ctrl_err => SYNTHESIZED_WIRE_26,
		 data_stb => SYNTHESIZED_WIRE_29,
		 pulse_rcvd => SYNTHESIZED_WIRE_39,
		 tcwf_ef => SYNTHESIZED_WIRE_18,
		 rx_time_lat => SYNTHESIZED_WIRE_21,
		 rx_addr => rx_addr,
		 rx_datain => rx_datain,
		 rx_error => rx_error,
		 tcwf_data => SYNTHESIZED_WIRE_23);

b2v_DC_Tx_chan_dpr : dc_tx_chan_dpr
PORT MAP(CLK20 => CLK20,
		 comres_rcvd => altera_synthesized_wire_50,
		 A_nB => A_nB,
		 tx_pack_rdy => tx_pack_rdy,
		 id_avail => id_avail,
		 cmd_snd0 => SYNTHESIZED_WIRE_10,
		 cmd_snd1 => SYNTHESIZED_WIRE_11,
		 cmd_snd2 => SYNTHESIZED_WIRE_12,
		 cmd_snd3 => SYNTHESIZED_WIRE_13,
		 send_ctrl => altera_synthesized_wire_47,
		 send_data => altera_synthesized_wire_46,
		 send_id => SYNTHESIZED_WIRE_16,
		 tcal_data => SYNTHESIZED_WIRE_17,
		 tcwf_ef => SYNTHESIZED_WIRE_18,
		 h_pulse => SYNTHESIZED_WIRE_19,
		 l_pulse => SYNTHESIZED_WIRE_20,
		 rx_time_lat => SYNTHESIZED_WIRE_21,
		 tx_time_lat => SYNTHESIZED_WIRE_22,
		 id => id,
		 systime => systime,
		 tcwf_data => SYNTHESIZED_WIRE_23,
		 tx_dataout => tx_dataout,
		 tx_dpr_wadr => tx_dpr_wadr,
		 COM_TX_SLEEP => COM_TX_SLEEP,
		 tx_pack_sent => tx_pack_sent,
		 tx_alm_empty => tx_alm_empty,
		 tx_empty => tx_empty,
		 msg_sent => altera_synthesized_wire_49,
		 ctrl_sent => SYNTHESIZED_WIRE_27,
		 tcwf_rd_next => SYNTHESIZED_WIRE_7,
		 id_data_avail => SYNTHESIZED_WIRE_33,
		 COM_DB => COM_DB,
		 tx_addr => tx_addr,
		 tx_dpr_radr => tx_dpr_radr,
		 tx_error => tx_error);

b2v_DCC_DPR : dcc_dpr
PORT MAP(CLK => CLK20,
		 bfstat_rcvd => SYNTHESIZED_WIRE_24,
		 comres_rcvd => altera_synthesized_wire_50,
		 ctrl_err => SYNTHESIZED_WIRE_26,
		 ctrl_sent => SYNTHESIZED_WIRE_27,
		 ctrl_stb => SYNTHESIZED_WIRE_28,
		 data_stb => SYNTHESIZED_WIRE_29,
		 del_15us => SYNTHESIZED_WIRE_30,
		 dpr_rx_aff => rx_dpr_aff_ALTERA_SYNTHESIZED,
		 dpr_tx_ef => tx_empty,
		 drreq_rcvd => SYNTHESIZED_WIRE_31,
		 eof_rcvd => SYNTHESIZED_WIRE_32,
		 id_data_avail => SYNTHESIZED_WIRE_33,
		 idle_rcvd => SYNTHESIZED_WIRE_34,
		 idreq_rcvd => SYNTHESIZED_WIRE_35,
		 msg_err => SYNTHESIZED_WIRE_36,
		 msg_sent => altera_synthesized_wire_49,
		 my_adr => SYNTHESIZED_WIRE_38,
		 pulse_rcvd => SYNTHESIZED_WIRE_39,
		 pulse_sent => SYNTHESIZED_WIRE_40,
		 reboot_req => reboot_req,
		 reset => 0,
		 stf_rcvd => SYNTHESIZED_WIRE_41,
		 sysres_rcvd => SYNTHESIZED_WIRE_42,
		 tcal_rcvd => SYNTHESIZED_WIRE_43,
		 time_bit_18 => systime(18),
		 cmd_snd0 => SYNTHESIZED_WIRE_10,
		 cmd_snd1 => SYNTHESIZED_WIRE_11,
		 cmd_snd2 => SYNTHESIZED_WIRE_12,
		 cmd_snd3 => SYNTHESIZED_WIRE_13,
		 com_avail => com_avail,
		 COMM_RESET => COMM_RESET,
		 reboot_gnt => reboot_gnt,
		 rec_ctrl => SYNTHESIZED_WIRE_2,
		 rec_data => SYNTHESIZED_WIRE_1,
		 rec_ena => SYNTHESIZED_WIRE_0,
		 send_ctrl => altera_synthesized_wire_47,
		 send_data => altera_synthesized_wire_46,
		 send_id => SYNTHESIZED_WIRE_16,
		 tcal_data => SYNTHESIZED_WIRE_17,
		 tcal_prec => SYNTHESIZED_WIRE_5,
		 tcal_psnd => altera_synthesized_wire_48,
		 timer_clrn => SYNTHESIZED_WIRE_45);

b2v_DCOM_tcal_timer : dcom_tcal_timer
PORT MAP(CLK20 => CLK20,
		 tcal_psnd => altera_synthesized_wire_48,
		 timer_clrn => SYNTHESIZED_WIRE_45,
		 del_15us => SYNTHESIZED_WIRE_30,
		 h_pulse => SYNTHESIZED_WIRE_19,
		 l_pulse => SYNTHESIZED_WIRE_20,
		 pulse_sent => SYNTHESIZED_WIRE_40,
		 tx_time_lat => SYNTHESIZED_WIRE_22);

b2v_inst3 : dcrev_dpr
PORT MAP(		 result => rev);
rx_dpr_aff <= rx_dpr_aff_ALTERA_SYNTHESIZED;

GND <= '0';
END; 