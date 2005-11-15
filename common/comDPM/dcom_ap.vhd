-- Copyright (C) 1991-2004 Altera Corporation
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
-- VERSION "Version 4.2 Build 157 12/07/2004 SJ Full Version"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY dcom_ap IS 
	port
	(
		tx_pack_rdy :  IN  STD_LOGIC;
		rx_dpr_radr_stb :  IN  STD_LOGIC;
		A_nB :  IN  STD_LOGIC;
		id_avail :  IN  STD_LOGIC;
		HVD_Rx :  IN  STD_LOGIC;
		CLK20 :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		reboot_req :  IN  STD_LOGIC;
		thr_del_wr :  IN  STD_LOGIC;
		clev_wr :  IN  STD_LOGIC;
		clev_max_d :  IN  STD_LOGIC_VECTOR(9 downto 0);
		clev_min_d :  IN  STD_LOGIC_VECTOR(9 downto 0);
		COM_AD_D :  IN  STD_LOGIC_VECTOR(9 downto 0);
		com_thr_d :  IN  STD_LOGIC_VECTOR(7 downto 0);
		dac_max_d :  IN  STD_LOGIC_VECTOR(6 downto 5);
		id :  IN  STD_LOGIC_VECTOR(47 downto 0);
		rec_del_d :  IN  STD_LOGIC_VECTOR(7 downto 0);
		rx_dpr_radr :  IN  STD_LOGIC_VECTOR(15 downto 0);
		send_del_d :  IN  STD_LOGIC_VECTOR(7 downto 0);
		systime :  IN  STD_LOGIC_VECTOR(47 downto 0);
		tx_dataout :  IN  STD_LOGIC_VECTOR(31 downto 0);
		tx_dpr_wadr :  IN  STD_LOGIC_VECTOR(15 downto 0);
		tx_pack_sent :  OUT  STD_LOGIC;
		rx_dpr_aff :  OUT  STD_LOGIC;
		rx_pack_rcvd :  OUT  STD_LOGIC;
		rx_we :  OUT  STD_LOGIC;
		reboot_gnt :  OUT  STD_LOGIC;
		com_avail :  OUT  STD_LOGIC;
		COMM_RESET :  OUT  STD_LOGIC;
		COM_TX_SLEEP :  OUT  STD_LOGIC;
		tx_alm_empty :  OUT  STD_LOGIC;
		com_reset_rcvd :  OUT  STD_LOGIC;
		msg_rd :  OUT  STD_LOGIC;
		data_rcvd :  OUT  STD_LOGIC;
		data_stb :  OUT  STD_LOGIC;
		stf_stb :  OUT  STD_LOGIC;
		eof_stb :  OUT  STD_LOGIC;
		err_stb :  OUT  STD_LOGIC;
		HVD_IN :  OUT  STD_LOGIC;
		HVD_RxENA :  OUT  STD_LOGIC;
		HVD_TxENA :  OUT  STD_LOGIC;
		COM_DB :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		rev :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		rx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		rx_datain :  OUT  STD_LOGIC_VECTOR(31 downto 0);
		rx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		rx_packets :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		tc :  OUT  STD_LOGIC_VECTOR(7 downto 0);
		tx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		tx_dpr_radr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		tx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0)
	);
END dcom_ap;

ARCHITECTURE bdf_type OF dcom_ap IS 

component dc_ctrap
	PORT(CLK : IN STD_LOGIC;
		 bfstat_rcvd : IN STD_LOGIC;
		 comres_rcvd : IN STD_LOGIC;
		 data_rcvd : IN STD_LOGIC;
		 del_15us : IN STD_LOGIC;
		 del_30us : IN STD_LOGIC;
		 dpr_rx_aff : IN STD_LOGIC;
		 dpr_tx_ef : IN STD_LOGIC;
		 drreq_rcvd : IN STD_LOGIC;
		 id_data_avail : IN STD_LOGIC;
		 idle_rcvd : IN STD_LOGIC;
		 idreq_rcvd : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 pulse_rcvd : IN STD_LOGIC;
		 pulse_sent : IN STD_LOGIC;
		 reboot_req : IN STD_LOGIC;
		 RES : IN STD_LOGIC;
		 sysres_rcvd : IN STD_LOGIC;
		 tcal_rcvd : IN STD_LOGIC;
		 time_bit_5 : IN STD_LOGIC;
		 buf_res : OUT STD_LOGIC;
		 cmd_snd0 : OUT STD_LOGIC;
		 cmd_snd1 : OUT STD_LOGIC;
		 cmd_snd2 : OUT STD_LOGIC;
		 cmd_snd3 : OUT STD_LOGIC;
		 com_avail : OUT STD_LOGIC;
		 COMM_RESET : OUT STD_LOGIC;
		 reboot_gnt : OUT STD_LOGIC;
		 rec_ena : OUT STD_LOGIC;
		 send_ctrl : OUT STD_LOGIC;
		 send_data : OUT STD_LOGIC;
		 send_id : OUT STD_LOGIC;
		 send_tcal : OUT STD_LOGIC;
		 tcal_cyc : OUT STD_LOGIC;
		 tcal_data : OUT STD_LOGIC;
		 tcal_prec : OUT STD_LOGIC;
		 tcal_psnd : OUT STD_LOGIC;
		 timer_clrn : OUT STD_LOGIC
	);
end component;

component dc_rx_chan_ap
GENERIC (DPR_ADR_USED:INTEGER);
	PORT(CLK20 : IN STD_LOGIC;
		 RES : IN STD_LOGIC;
		 A_nB : IN STD_LOGIC;
		 HVD_Rx : IN STD_LOGIC;
		 rx_dpr_radr_stb : IN STD_LOGIC;
		 buf_res : IN STD_LOGIC;
		 rec_ena : IN STD_LOGIC;
		 tcal_prec : IN STD_LOGIC;
		 tcwf_rd_next : IN STD_LOGIC;
		 msg_sent : IN STD_LOGIC;
		 clev_max : IN STD_LOGIC_VECTOR(9 downto 0);
		 clev_min : IN STD_LOGIC_VECTOR(9 downto 0);
		 COM_AD_D : IN STD_LOGIC_VECTOR(9 downto 0);
		 com_thr : IN STD_LOGIC_VECTOR(7 downto 0);
		 rec_del : IN STD_LOGIC_VECTOR(7 downto 0);
		 rx_dpr_radr : IN STD_LOGIC_VECTOR(15 downto 0);
		 HVD_RxENA : OUT STD_LOGIC;
		 rx_we : OUT STD_LOGIC;
		 rx_pack_rcvd : OUT STD_LOGIC;
		 com_reset_rcvd : OUT STD_LOGIC;
		 rx_dpr_aff : OUT STD_LOGIC;
		 rx_dpr_ef : OUT STD_LOGIC;
		 my_adr : OUT STD_LOGIC;
		 bfstat_rcvd : OUT STD_LOGIC;
		 drreq_rcvd : OUT STD_LOGIC;
		 sysres_rcvd : OUT STD_LOGIC;
		 comres_rcvd : OUT STD_LOGIC;
		 tcal_rcvd : OUT STD_LOGIC;
		 idreq_rcvd : OUT STD_LOGIC;
		 idle_rcvd : OUT STD_LOGIC;
		 data_rcvd : OUT STD_LOGIC;
		 data_stb : OUT STD_LOGIC;
		 stf_stb : OUT STD_LOGIC;
		 eof_stb : OUT STD_LOGIC;
		 err_stb : OUT STD_LOGIC;
		 pulse_rcvd : OUT STD_LOGIC;
		 tcwf_data_val : OUT STD_LOGIC;
		 tcwf_ef : OUT STD_LOGIC;
		 rx_time_lat : OUT STD_LOGIC;
		 msg_rd : OUT STD_LOGIC;
		 data_error : OUT STD_LOGIC;
		 ctrl_error : OUT STD_LOGIC;
		 hl_edge : OUT STD_LOGIC;
		 rxd : OUT STD_LOGIC;
		 crc_init : OUT STD_LOGIC;
		 crc_zero : OUT STD_LOGIC;
		 ctrl_msg : OUT STD_LOGIC;
		 data_msg : OUT STD_LOGIC;
		 domlev_up_rq : OUT STD_LOGIC;
		 domlev_dn_rq : OUT STD_LOGIC;
		 dorlev_up_rq : OUT STD_LOGIC;
		 dorlev_dn_rq : OUT STD_LOGIC;
		 data : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rx_addr : OUT STD_LOGIC_VECTOR(15 downto 0);
		 rx_datain : OUT STD_LOGIC_VECTOR(31 downto 0);
		 rx_error : OUT STD_LOGIC_VECTOR(15 downto 0);
		 rx_packets : OUT STD_LOGIC_VECTOR(15 downto 0);
		 tcwf_data : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

component dc_tx_chan_ap
GENERIC (DPR_ADR_USED:INTEGER);
	PORT(CLK20 : IN STD_LOGIC;
		 buf_res : IN STD_LOGIC;
		 A_nB : IN STD_LOGIC;
		 thr_del_wr : IN STD_LOGIC;
		 tx_pack_rdy : IN STD_LOGIC;
		 id_avail : IN STD_LOGIC;
		 cmd_snd0 : IN STD_LOGIC;
		 cmd_snd1 : IN STD_LOGIC;
		 cmd_snd2 : IN STD_LOGIC;
		 cmd_snd3 : IN STD_LOGIC;
		 send_ctrl : IN STD_LOGIC;
		 send_data : IN STD_LOGIC;
		 send_tcal : IN STD_LOGIC;
		 send_id : IN STD_LOGIC;
		 tcwf_ef : IN STD_LOGIC;
		 h_pulse : IN STD_LOGIC;
		 l_pulse : IN STD_LOGIC;
		 rx_time_lat : IN STD_LOGIC;
		 tx_time_lat : IN STD_LOGIC;
		 domlev_up_rq : IN STD_LOGIC;
		 domlev_dn_rq : IN STD_LOGIC;
		 dorlev_up_rq : IN STD_LOGIC;
		 dorlev_dn_rq : IN STD_LOGIC;
		 dac_max : IN STD_LOGIC_VECTOR(7 downto 0);
		 id : IN STD_LOGIC_VECTOR(47 downto 0);
		 send_del : IN STD_LOGIC_VECTOR(7 downto 0);
		 systime : IN STD_LOGIC_VECTOR(47 downto 0);
		 tcwf_data : IN STD_LOGIC_VECTOR(15 downto 0);
		 tx_dataout : IN STD_LOGIC_VECTOR(31 downto 0);
		 tx_dpr_wadr : IN STD_LOGIC_VECTOR(15 downto 0);
		 COM_TX_SLEEP : OUT STD_LOGIC;
		 tx_pack_sent : OUT STD_LOGIC;
		 tx_alm_empty : OUT STD_LOGIC;
		 tx_empty : OUT STD_LOGIC;
		 txd : OUT STD_LOGIC;
		 last_byte : OUT STD_LOGIC;
		 msg_sent : OUT STD_LOGIC;
		 tcwf_rd_next : OUT STD_LOGIC;
		 id_data_avail : OUT STD_LOGIC;
		 tx_dpr_ren : OUT STD_LOGIC;
		 HVD_IN : OUT STD_LOGIC;
		 HVD_TxENA : OUT STD_LOGIC;
		 COM_DB : OUT STD_LOGIC_VECTOR(7 downto 0);
		 dac_lev : OUT STD_LOGIC_VECTOR(7 downto 0);
		 tx_addr : OUT STD_LOGIC_VECTOR(15 downto 0);
		 tx_dpr_radr : OUT STD_LOGIC_VECTOR(15 downto 0);
		 tx_error : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

component dcom_tcal_timer
	PORT(CLK20 : IN STD_LOGIC;
		 tcal_psnd : IN STD_LOGIC;
		 timer_clrn : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 del_15us : OUT STD_LOGIC;
		 del_30us : OUT STD_LOGIC;
		 h_pulse : OUT STD_LOGIC;
		 l_pulse : OUT STD_LOGIC;
		 pulse_sent : OUT STD_LOGIC;
		 tx_time_lat : OUT STD_LOGIC;
		 RES : OUT STD_LOGIC
	);
end component;

component test_and_tresholds
	PORT(CLK20 : IN STD_LOGIC;
		 reboot_req : IN STD_LOGIC;
		 drreq_rcvd : IN STD_LOGIC;
		 idle_rcvd : IN STD_LOGIC;
		 buf_res : IN STD_LOGIC;
		 ctrl_error : IN STD_LOGIC;
		 tcal_rcvd : IN STD_LOGIC;
		 pulse_rcvd : IN STD_LOGIC;
		 pulse_sent : IN STD_LOGIC;
		 thr_del_wr : IN STD_LOGIC;
		 clev_wr : IN STD_LOGIC;
		 clev_max_d : IN STD_LOGIC_VECTOR(9 downto 0);
		 clev_min_d : IN STD_LOGIC_VECTOR(9 downto 0);
		 com_thr_d : IN STD_LOGIC_VECTOR(7 downto 0);
		 dac_max_d : IN STD_LOGIC_VECTOR(6 downto 5);
		 rec_del_d : IN STD_LOGIC_VECTOR(7 downto 0);
		 send_del_d : IN STD_LOGIC_VECTOR(7 downto 0);
		 clev_max : OUT STD_LOGIC_VECTOR(9 downto 0);
		 clev_min : OUT STD_LOGIC_VECTOR(9 downto 0);
		 com_thr : OUT STD_LOGIC_VECTOR(7 downto 0);
		 dac_max : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rec_del : OUT STD_LOGIC_VECTOR(7 downto 0);
		 rev : OUT STD_LOGIC_VECTOR(15 downto 0);
		 send_del : OUT STD_LOGIC_VECTOR(7 downto 0);
		 tc : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

signal	rx_dpr_aff_ALTERA_SYNTHESIZED :  STD_LOGIC;
signal	tx_empty :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_55 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_56 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_57 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_58 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_59 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_60 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_61 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_62 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(9 downto 0);
signal	SYNTHESIZED_WIRE_22 :  STD_LOGIC_VECTOR(9 downto 0);
signal	SYNTHESIZED_WIRE_23 :  STD_LOGIC_VECTOR(7 downto 0);
signal	SYNTHESIZED_WIRE_24 :  STD_LOGIC_VECTOR(7 downto 0);
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
signal	SYNTHESIZED_WIRE_37 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_38 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_39 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_40 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_41 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_42 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_43 :  STD_LOGIC_VECTOR(7 downto 0);
signal	SYNTHESIZED_WIRE_44 :  STD_LOGIC_VECTOR(7 downto 0);
signal	SYNTHESIZED_WIRE_45 :  STD_LOGIC_VECTOR(15 downto 0);
signal	SYNTHESIZED_WIRE_46 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_47 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_51 :  STD_LOGIC;


BEGIN 
data_rcvd <= SYNTHESIZED_WIRE_2;



b2v_DC_CTRAP : dc_ctrap
PORT MAP(CLK => CLK20,
		 bfstat_rcvd => SYNTHESIZED_WIRE_0,
		 comres_rcvd => SYNTHESIZED_WIRE_1,
		 data_rcvd => SYNTHESIZED_WIRE_2,
		 del_15us => SYNTHESIZED_WIRE_3,
		 del_30us => SYNTHESIZED_WIRE_4,
		 dpr_rx_aff => rx_dpr_aff_ALTERA_SYNTHESIZED,
		 dpr_tx_ef => tx_empty,
		 drreq_rcvd => SYNTHESIZED_WIRE_55,
		 id_data_avail => SYNTHESIZED_WIRE_6,
		 idle_rcvd => SYNTHESIZED_WIRE_56,
		 idreq_rcvd => SYNTHESIZED_WIRE_8,
		 msg_sent => SYNTHESIZED_WIRE_57,
		 pulse_rcvd => SYNTHESIZED_WIRE_58,
		 pulse_sent => SYNTHESIZED_WIRE_59,
		 reboot_req => reboot_req,
		 RES => SYNTHESIZED_WIRE_60,
		 sysres_rcvd => SYNTHESIZED_WIRE_13,
		 tcal_rcvd => SYNTHESIZED_WIRE_61,
		 time_bit_5 => systime(5),
		 buf_res => SYNTHESIZED_WIRE_62,
		 cmd_snd0 => SYNTHESIZED_WIRE_26,
		 cmd_snd1 => SYNTHESIZED_WIRE_27,
		 cmd_snd2 => SYNTHESIZED_WIRE_28,
		 cmd_snd3 => SYNTHESIZED_WIRE_29,
		 com_avail => com_avail,
		 COMM_RESET => COMM_RESET,
		 reboot_gnt => reboot_gnt,
		 rec_ena => SYNTHESIZED_WIRE_17,
		 send_ctrl => SYNTHESIZED_WIRE_30,
		 send_data => SYNTHESIZED_WIRE_31,
		 send_id => SYNTHESIZED_WIRE_33,
		 send_tcal => SYNTHESIZED_WIRE_32,
		 tcal_prec => SYNTHESIZED_WIRE_18,
		 tcal_psnd => SYNTHESIZED_WIRE_46,
		 timer_clrn => SYNTHESIZED_WIRE_47);

b2v_DC_Rx_chan_ap : dc_rx_chan_ap
GENERIC MAP(DPR_ADR_USED => 13)
PORT MAP(CLK20 => CLK20,
		 RES => SYNTHESIZED_WIRE_60,
		 A_nB => A_nB,
		 HVD_Rx => HVD_Rx,
		 rx_dpr_radr_stb => rx_dpr_radr_stb,
		 buf_res => SYNTHESIZED_WIRE_62,
		 rec_ena => SYNTHESIZED_WIRE_17,
		 tcal_prec => SYNTHESIZED_WIRE_18,
		 tcwf_rd_next => SYNTHESIZED_WIRE_19,
		 msg_sent => SYNTHESIZED_WIRE_57,
		 clev_max => SYNTHESIZED_WIRE_21,
		 clev_min => SYNTHESIZED_WIRE_22,
		 COM_AD_D => COM_AD_D,
		 com_thr => SYNTHESIZED_WIRE_23,
		 rec_del => SYNTHESIZED_WIRE_24,
		 rx_dpr_radr => rx_dpr_radr,
		 HVD_RxENA => HVD_RxENA,
		 rx_we => rx_we,
		 rx_pack_rcvd => rx_pack_rcvd,
		 com_reset_rcvd => com_reset_rcvd,
		 rx_dpr_aff => rx_dpr_aff_ALTERA_SYNTHESIZED,
		 bfstat_rcvd => SYNTHESIZED_WIRE_0,
		 drreq_rcvd => SYNTHESIZED_WIRE_55,
		 sysres_rcvd => SYNTHESIZED_WIRE_13,
		 comres_rcvd => SYNTHESIZED_WIRE_1,
		 tcal_rcvd => SYNTHESIZED_WIRE_61,
		 idreq_rcvd => SYNTHESIZED_WIRE_8,
		 idle_rcvd => SYNTHESIZED_WIRE_56,
		 data_rcvd => SYNTHESIZED_WIRE_2,
		 data_stb => data_stb,
		 stf_stb => stf_stb,
		 eof_stb => eof_stb,
		 err_stb => err_stb,
		 pulse_rcvd => SYNTHESIZED_WIRE_58,
		 tcwf_ef => SYNTHESIZED_WIRE_34,
		 rx_time_lat => SYNTHESIZED_WIRE_37,
		 msg_rd => msg_rd,
		 ctrl_error => SYNTHESIZED_WIRE_51,
		 domlev_up_rq => SYNTHESIZED_WIRE_39,
		 domlev_dn_rq => SYNTHESIZED_WIRE_40,
		 dorlev_up_rq => SYNTHESIZED_WIRE_41,
		 dorlev_dn_rq => SYNTHESIZED_WIRE_42,
		 rx_addr => rx_addr,
		 rx_datain => rx_datain,
		 rx_error => rx_error,
		 rx_packets => rx_packets,
		 tcwf_data => SYNTHESIZED_WIRE_45);

b2v_DC_Tx_chan_ap : dc_tx_chan_ap
GENERIC MAP(DPR_ADR_USED => 13)
PORT MAP(CLK20 => CLK20,
		 buf_res => SYNTHESIZED_WIRE_62,
		 A_nB => A_nB,
		 thr_del_wr => thr_del_wr,
		 tx_pack_rdy => tx_pack_rdy,
		 id_avail => id_avail,
		 cmd_snd0 => SYNTHESIZED_WIRE_26,
		 cmd_snd1 => SYNTHESIZED_WIRE_27,
		 cmd_snd2 => SYNTHESIZED_WIRE_28,
		 cmd_snd3 => SYNTHESIZED_WIRE_29,
		 send_ctrl => SYNTHESIZED_WIRE_30,
		 send_data => SYNTHESIZED_WIRE_31,
		 send_tcal => SYNTHESIZED_WIRE_32,
		 send_id => SYNTHESIZED_WIRE_33,
		 tcwf_ef => SYNTHESIZED_WIRE_34,
		 h_pulse => SYNTHESIZED_WIRE_35,
		 l_pulse => SYNTHESIZED_WIRE_36,
		 rx_time_lat => SYNTHESIZED_WIRE_37,
		 tx_time_lat => SYNTHESIZED_WIRE_38,
		 domlev_up_rq => SYNTHESIZED_WIRE_39,
		 domlev_dn_rq => SYNTHESIZED_WIRE_40,
		 dorlev_up_rq => SYNTHESIZED_WIRE_41,
		 dorlev_dn_rq => SYNTHESIZED_WIRE_42,
		 dac_max => SYNTHESIZED_WIRE_43,
		 id => id,
		 send_del => SYNTHESIZED_WIRE_44,
		 systime => systime,
		 tcwf_data => SYNTHESIZED_WIRE_45,
		 tx_dataout => tx_dataout,
		 tx_dpr_wadr => tx_dpr_wadr,
		 COM_TX_SLEEP => COM_TX_SLEEP,
		 tx_pack_sent => tx_pack_sent,
		 tx_alm_empty => tx_alm_empty,
		 tx_empty => tx_empty,
		 msg_sent => SYNTHESIZED_WIRE_57,
		 tcwf_rd_next => SYNTHESIZED_WIRE_19,
		 id_data_avail => SYNTHESIZED_WIRE_6,
		 HVD_IN => HVD_IN,
		 HVD_TxENA => HVD_TxENA,
		 COM_DB => COM_DB,
		 tx_addr => tx_addr,
		 tx_dpr_radr => tx_dpr_radr,
		 tx_error => tx_error);

b2v_DCOM_tcal_timer : dcom_tcal_timer
PORT MAP(CLK20 => CLK20,
		 tcal_psnd => SYNTHESIZED_WIRE_46,
		 timer_clrn => SYNTHESIZED_WIRE_47,
		 RST => RST,
		 del_15us => SYNTHESIZED_WIRE_3,
		 del_30us => SYNTHESIZED_WIRE_4,
		 h_pulse => SYNTHESIZED_WIRE_35,
		 l_pulse => SYNTHESIZED_WIRE_36,
		 pulse_sent => SYNTHESIZED_WIRE_59,
		 tx_time_lat => SYNTHESIZED_WIRE_38,
		 RES => SYNTHESIZED_WIRE_60);

b2v_test_and_tresholds : test_and_tresholds
PORT MAP(CLK20 => CLK20,
		 reboot_req => reboot_req,
		 drreq_rcvd => SYNTHESIZED_WIRE_55,
		 idle_rcvd => SYNTHESIZED_WIRE_56,
		 buf_res => SYNTHESIZED_WIRE_62,
		 ctrl_error => SYNTHESIZED_WIRE_51,
		 tcal_rcvd => SYNTHESIZED_WIRE_61,
		 pulse_rcvd => SYNTHESIZED_WIRE_58,
		 pulse_sent => SYNTHESIZED_WIRE_59,
		 thr_del_wr => thr_del_wr,
		 clev_wr => clev_wr,
		 clev_max_d => clev_max_d,
		 clev_min_d => clev_min_d,
		 com_thr_d => com_thr_d,
		 dac_max_d => dac_max_d,
		 rec_del_d => rec_del_d,
		 send_del_d => send_del_d,
		 clev_max => SYNTHESIZED_WIRE_21,
		 clev_min => SYNTHESIZED_WIRE_22,
		 com_thr => SYNTHESIZED_WIRE_23,
		 dac_max => SYNTHESIZED_WIRE_43,
		 rec_del => SYNTHESIZED_WIRE_24,
		 rev => rev,
		 send_del => SYNTHESIZED_WIRE_44,
		 tc => tc);
rx_dpr_aff <= rx_dpr_aff_ALTERA_SYNTHESIZED;

END; 