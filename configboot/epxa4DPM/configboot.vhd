-------------------------------------------------------------------------------
-- Title      : ConfigBoot
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : configboot.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-05-11
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This is the top level design for ConfigBoot
--              communications uses Dual Ported Memory
-------------------------------------------------------------------------------
-- Copyright (c) 2004 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-05-11  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

ENTITY configboot IS
	PORT (
		-- stripe IO
		CLK_REF			: IN STD_LOGIC;
		nPOR			: IN STD_LOGIC;
		nRESET			: INOUT	STD_LOGIC;
		-- EBI
		INTEXTPIN		: IN	STD_LOGIC;
		EBIACK			: IN	STD_LOGIC;
		EBIDQ			: INOUT	STD_LOGIC_VECTOR(15 downto 0);
		EBICLK			: OUT	STD_LOGIC;
		EBIWEN			: OUT	STD_LOGIC;
		EBIOEN			: OUT	STD_LOGIC;
		EBIADDR			: OUT	STD_LOGIC_VECTOR(24 downto 0);
		EBIBE			: OUT	STD_LOGIC_VECTOR(1 downto 0);
		EBICSN			: OUT	STD_LOGIC_VECTOR(3 downto 0);
		-- general FPGA IO
		CLK1p			: IN STD_LOGIC;
		CLK2p			: IN STD_LOGIC;
		CLK3p			: IN STD_LOGIC;
		CLK4p			: IN STD_LOGIC;
		COMM_RESET		: OUT STD_LOGIC;
		FPGA_LOADED		: OUT STD_LOGIC;
		-- Communications DAC
		COM_TX_SLEEP	: OUT STD_LOGIC;
		COM_DB			: OUT STD_LOGIC_VECTOR (13 downto 6);
		-- Communications ADC
		COM_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
		COM_AD_OTR		: IN STD_LOGIC;
		-- Communications RS485
		HDV_Rx			: IN STD_LOGIC;
		HDV_RxENA		: OUT STD_LOGIC;
		HDV_TxENA		: OUT STD_LOGIC;
		HDV_IN			: OUT STD_LOGIC;
		-- ATWD 0
		ATWDTrigger_0	: OUT STD_LOGIC;
		OutputEnable_0	: OUT STD_LOGIC;
		CounterClock_0	: OUT STD_LOGIC;
		ShiftClock_0	: OUT STD_LOGIC;
		RampSet_0		: OUT STD_LOGIC;
		ChannelSelect_0	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite_0		: OUT STD_LOGIC;
		AnalogReset_0	: OUT STD_LOGIC;
		DigitalReset_0	: OUT STD_LOGIC;
		DigitalSet_0	: OUT STD_LOGIC;
		-- ATWD 1
		ATWDTrigger_1	: OUT STD_LOGIC;
		OutputEnable_1	: OUT STD_LOGIC;
		CounterClock_1	: OUT STD_LOGIC;
		ShiftClock_1	: OUT STD_LOGIC;
		RampSet_1		: OUT STD_LOGIC;
		ChannelSelect_1	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite_1		: OUT STD_LOGIC;
		AnalogReset_1	: OUT STD_LOGIC;
		DigitalReset_1	: OUT STD_LOGIC;
		DigitalSet_1	: OUT STD_LOGIC;
		-- A_nB switch
		A_nB				: IN STD_LOGIC
	);
END configboot;


ARCHITECTURE configboot_arch OF configboot IS

	-- gerneal siganls
	SIGNAL CLK20	: STD_LOGIC;
	SIGNAL CLK40	: STD_LOGIC;
	SIGNAL RST		: STD_LOGIC;
	
	-- STRIPE to PLD bridge
	SIGNAL masterhclk			: STD_LOGIC;
	SIGNAL masterhready		: STD_LOGIC;
	SIGNAL masterhgrant		: STD_LOGIC;
	SIGNAL masterhrdata		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL masterhresp			: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL masterhwrite		: STD_LOGIC;
	SIGNAL masterhlock			: STD_LOGIC;
	SIGNAL masterhbusreq		: STD_LOGIC;
	SIGNAL masterhaddr			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL masterhburst		: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL masterhsize			: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL masterhtrans		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL masterhwdata		: STD_LOGIC_VECTOR(31 downto 0);
	
	-- DP SRAM
	SIGNAL dp0_2_portaclk	: STD_LOGIC;
	SIGNAL dp0_portawe		: STD_LOGIC;
	SIGNAL dp0_portaaddr	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL dp0_portadatain	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp0_portadataout	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL dp1_3_portaclk	: STD_LOGIC;
	SIGNAL dp1_portawe		: STD_LOGIC;
	SIGNAL dp1_portaaddr	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL dp1_portadatain	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp1_portadataout	: STD_LOGIC_VECTOR(31 downto 0);
	
	-- AHB_slave
	SIGNAL reg_write	: STD_LOGIC; 
	SIGNAL reg_address	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_wdata	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_rdata	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_enable	: STD_LOGIC;
	SIGNAL reg_wait_sig	: STD_LOGIC;
	
	
	-- kale communication
	SIGNAL com_error		: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL com_ctrl			: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL com_status		: STD_LOGIC_VECTOR (31 downto 0);
	
	SIGNAL drbt_req			: STD_LOGIC;
	SIGNAL drbt_gnt			: STD_LOGIC;
	
	-- new signals for DPM communicatios
	SIGNAL tx_alm_empty		: STD_LOGIC;
	SIGNAL tx_pack_sent		: STD_LOGIC;
	SIGNAL rx_pack_rcvd		: STD_LOGIC;
	SIGNAL com_reset_rcvd	: STD_LOGIC;
	SIGNAL rx_dpr_aff		: STD_LOGIC;
	SIGNAL com_avail		: STD_LOGIC;
	SIGNAL rx_addr			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL rx_dpr_radr		: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL tx_dpr_radr		: STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL tx_dpr_wadr		: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL COMM_nRESET		: STD_LOGIC;
	SIGNAL tx_pack_rdy		: STD_LOGIC;
	SIGNAL rx_dpr_radr_stb	: STD_LOGIC;
	
	SIGNAL systime			: STD_LOGIC_VECTOR (47 DOWNTO 0);
	
	COMPONENT ROC
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT pll2x
		PORT (
			inclock		: IN STD_LOGIC;
			locked		: OUT STD_LOGIC;
			clock0		: OUT STD_LOGIC;
			clock1		: OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT stripe
		PORT (
			clk_ref				: IN	STD_LOGIC;
			npor				: IN	STD_LOGIC;
			nreset				: INOUT	STD_LOGIC;
			intextpin			: IN	STD_LOGIC;
			ebiack				: IN	STD_LOGIC;
			ebidq				: INOUT	STD_LOGIC_VECTOR(15 downto 0);
			ebiclk				: OUT	STD_LOGIC;
			ebiwen				: OUT	STD_LOGIC;
			ebioen				: OUT	STD_LOGIC;
			ebiaddr				: OUT	STD_LOGIC_VECTOR(24 downto 0);
			ebibe				: OUT	STD_LOGIC_VECTOR(1 downto 0);
			ebicsn				: OUT	STD_LOGIC_VECTOR(3 downto 0);
			masterhclk			: IN	STD_LOGIC;
			masterhready		: IN	STD_LOGIC;
			masterhgrant		: IN	STD_LOGIC;
			masterhrdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			masterhresp			: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhwrite		: OUT	STD_LOGIC;
			masterhlock			: OUT	STD_LOGIC;
			masterhbusreq		: OUT	STD_LOGIC;
			masterhaddr			: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhburst		: OUT	STD_LOGIC_VECTOR(2 downto 0);
			masterhsize			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhtrans		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhwdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			dp0_2_portaclk		: IN	STD_LOGIC;
			dp0_portawe			: IN	STD_LOGIC;
			dp0_portaaddr		: IN	STD_LOGIC_VECTOR(12 downto 0);
			dp0_portadatain		: IN	STD_LOGIC_VECTOR(31 downto 0);
			dp0_portadataout	: OUT	STD_LOGIC_VECTOR(31 downto 0);
			dp1_3_portaclk		: IN	STD_LOGIC;
			dp1_portawe			: IN	STD_LOGIC;
			dp1_portaaddr		: IN	STD_LOGIC_VECTOR(12 downto 0);
			dp1_portadatain		: IN	STD_LOGIC_VECTOR(31 downto 0);
			dp1_portadataout	: OUT	STD_LOGIC_VECTOR(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ahb_slave
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- connections to the stripe
			masterhready		: OUT	STD_LOGIC;
			masterhgrant		: OUT	STD_LOGIC;
			masterhrdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhresp			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhwrite		: IN	STD_LOGIC;
			masterhlock			: IN	STD_LOGIC;
			masterhbusreq		: IN	STD_LOGIC;
			masterhaddr			: IN	STD_LOGIC_VECTOR(31 downto 0);
			masterhburst		: IN	STD_LOGIC_VECTOR(2 downto 0);
			masterhsize			: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhtrans		: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhwdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- local bus signals
			reg_write		: OUT	STD_LOGIC;
			reg_address		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_wdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_rdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			reg_enable		: OUT	STD_LOGIC;
			reg_wait_sig	: IN	STD_LOGIC
		);
	END COMPONENT;
	
	
	COMPONENT slaveregister
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- connections to ahb_slave
			reg_write		: IN	STD_LOGIC;
			reg_address		: IN	STD_LOGIC_VECTOR(31 downto 0);
			reg_wdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			reg_rdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_enable		: IN	STD_LOGIC;
			reg_wait_sig	: OUT	STD_LOGIC;
			-- command register
			com_ctrl		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			com_status		: IN	STD_LOGIC_VECTOR(31 downto 0);
			tx_dpr_wadr		: OUT	STD_LOGIC_VECTOR(15 downto 0);
			tx_dpr_radr		: IN	STD_LOGIC_VECTOR(15 downto 0);
			rx_dpr_radr		: OUT	STD_LOGIC_VECTOR(15 downto 0);
			rx_addr			: IN	STD_LOGIC_VECTOR(15 downto 0);
			-- kale communication interface
			tx_pack_rdy			: OUT STD_LOGIC;
			rx_dpr_radr_stb		: OUT STD_LOGIC;
			-- test connector
			TC				: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;


	-- Kalle DPM

	COMPONENT dcom_ap
		port
		(
			tx_pack_rdy :  IN  STD_LOGIC;
			rx_dpr_radr_stb :  IN  STD_LOGIC;
			A_nB :  IN  STD_LOGIC;
			reboot_req :  IN  STD_LOGIC;
			id_avail :  IN  STD_LOGIC;
			HVD_Rx :  IN  STD_LOGIC;
			CLK20 :  IN  STD_LOGIC;
			RST :  IN  STD_LOGIC;
			COM_AD_D :  IN  STD_LOGIC_VECTOR(9 downto 0);
			id :  IN  STD_LOGIC_VECTOR(47 downto 0);
			rx_dpr_radr :  IN  STD_LOGIC_VECTOR(15 downto 0);
			systime :  IN  STD_LOGIC_VECTOR(47 downto 0);
			tc :  OUT  STD_LOGIC_VECTOR(7 downto 0);
			tx_dataout :  IN  STD_LOGIC_VECTOR(31 downto 0);
			tx_dpr_wadr :  IN  STD_LOGIC_VECTOR(15 downto 0);
			tx_pack_sent :  OUT  STD_LOGIC;
			rx_dpr_aff :  OUT  STD_LOGIC;
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
			com_reset_rcvd :  OUT  STD_LOGIC;
			msg_rd :  OUT  STD_LOGIC;
			data_rcvd :  OUT  STD_LOGIC;
			COM_DB :  OUT  STD_LOGIC_VECTOR(7 downto 0);
			rev :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			rx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			rx_datain :  OUT  STD_LOGIC_VECTOR(31 downto 0);
			rx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			tx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			tx_dpr_radr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			tx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0)
		);
	END COMPONENT;

	
	COMPONENT timer
		PORT (
			CLK     : IN  STD_LOGIC;
			RST     : IN  STD_LOGIC;
			systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
		);
	END COMPONENT;
	


	
BEGIN
	
	masterhclk			<= CLK20;
	
	-- DP SRAM
	dp0_2_portaclk		<= CLK20;
	dp0_portawe			<= '0';
	dp0_portadatain		<= (others=>'0');
	dp1_3_portaclk		<= CLK20;
	
	
	-- kale communications
	com_status(0)	<= drbt_gnt;
	com_status(1)	<= tx_pack_sent;
	com_status(2)	<= tx_alm_empty;
	com_status(3)	<= rx_pack_rcvd;
	com_status(4)	<= com_reset_rcvd;
	com_status(5)	<= rx_dpr_aff;
	com_status(6)	<= com_avail;
	com_status(31 downto 7)	<= 	(OTHERS=>'0');
	drbt_req		<= com_ctrl(0);

	
	
	inst_ROC : ROC
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST
		);
		
	inst_pll2x : pll2x
		PORT MAP (
			inclock		=> CLK2p,
			locked		=> open,
			clock0		=> CLK20,
			clock1		=> CLK40
		);
	
	stripe_inst : stripe
		PORT MAP (
			clk_ref				=> CLK_REF,
			npor				=> nPOR,
			nreset				=> nRESET,
			intextpin			=> INTEXTPIN,
			ebiack				=> EBIACK,
			ebidq				=> EBIDQ,
			ebiclk				=> EBICLK,
			ebiwen				=> EBIWEN,
			ebioen				=> EBIOEN,
			ebiaddr				=> EBIADDR,
			ebibe				=> EBIBE,
			ebicsn				=> EBICSN,
			masterhclk			=> masterhclk,
			masterhready		=> masterhready,
			masterhgrant		=> masterhgrant,
			masterhrdata		=> masterhrdata,
			masterhresp			=> masterhresp,
			masterhwrite		=> masterhwrite,
			masterhlock			=> masterhlock,
			masterhbusreq		=> masterhbusreq,
			masterhaddr			=> masterhaddr,
			masterhburst		=> masterhburst,
			masterhsize			=> masterhsize,
			masterhtrans		=> masterhtrans,
			masterhwdata		=> masterhwdata,
			dp0_2_portaclk		=> dp0_2_portaclk,
			dp0_portawe			=> dp0_portawe,
			dp0_portaaddr		=> dp0_portaaddr(12 DOWNTO 0),
			dp0_portadatain		=> dp0_portadatain,
			dp0_portadataout	=> dp0_portadataout,
			dp1_3_portaclk		=> dp1_3_portaclk,
			dp1_portawe			=> dp1_portawe,
			dp1_portaaddr		=> dp1_portaaddr(12 DOWNTO 0),
			dp1_portadatain		=> dp1_portadatain,
			dp1_portadataout	=> open
		);
		
	ahb_slave_inst : ahb_slave
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- connections to the stripe
			masterhready	=> masterhready,
			masterhgrant	=> masterhgrant,
			masterhrdata	=> masterhrdata,
			masterhresp		=> masterhresp,
			masterhwrite	=> masterhwrite,
			masterhlock		=> masterhlock,
			masterhbusreq	=> masterhbusreq,
			masterhaddr		=> masterhaddr,
			masterhburst	=> masterhburst,
			masterhsize		=> masterhsize,
			masterhtrans	=> masterhtrans,
			masterhwdata	=> masterhwdata,
			-- local bus signals
			reg_write		=> reg_write,
			reg_address		=> reg_address,
			reg_wdata		=> reg_wdata,
			reg_rdata		=> reg_rdata,
			reg_enable		=> reg_enable,
			reg_wait_sig	=> reg_wait_sig
		);
		

		
	slaveregister_inst : slaveregister
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- connections to ahb_slave
			reg_write		=> reg_write,
			reg_address		=> reg_address,
			reg_wdata		=> reg_wdata,
			reg_rdata		=> reg_rdata,
			reg_enable		=> reg_enable,
			reg_wait_sig	=> reg_wait_sig,
			-- command register
			com_ctrl		=> com_ctrl,
			com_status		=> com_status,
			tx_dpr_wadr		=> tx_dpr_wadr,
			tx_dpr_radr		=> tx_dpr_radr,
			rx_dpr_radr		=> rx_dpr_radr,
			rx_addr			=> rx_addr,
			-- kale communication interface
			tx_pack_rdy			=> tx_pack_rdy,
			rx_dpr_radr_stb		=> rx_dpr_radr_stb,
			-- test connector
			TC				=> open --TC
		);

		
-- Kalle DPM

	rx_addr		<= dp1_portaaddr;
	dcom_ap_inst : dcom_ap
		port MAP (
			tx_pack_rdy		=> tx_pack_rdy,
			rx_dpr_radr_stb	=> rx_dpr_radr_stb,
			A_nB			=> A_nB,
			reboot_req		=> drbt_req,
			id_avail		=> '1',
			HVD_Rx			=> HDV_Rx,
			CLK20			=> CLK20,
			RST				=> RST,
			COM_AD_D		=> COM_AD_D,
			id				=> (OTHERS=>'0'),
			rx_dpr_radr		=> rx_dpr_radr,
			systime			=> systime,
			tc				=> open,
			tx_dataout		=> dp0_portadataout,
			tx_dpr_wadr		=> tx_dpr_wadr,
			tx_pack_sent	=> tx_pack_sent,
			rx_dpr_aff		=> rx_dpr_aff,
			rx_pack_rcvd	=> rx_pack_rcvd,
			rx_we			=> dp1_portawe,
			HDV_Rx_ENA		=> HDV_RxENA,
			reboot_gnt		=> drbt_gnt,
			com_avail		=> com_avail,
			COMM_RESET		=> COMM_nRESET,
			COM_TX_SLEEP	=> COM_TX_SLEEP,
			HDV_IN			=> HDV_IN,
			HDV_TxENA		=> HDV_TxENA,
			tx_alm_empty	=> tx_alm_empty,
			com_reset_rcvd	=> com_reset_rcvd,
			msg_rd			=> open,
			data_rcvd		=> open,
			COM_DB			=> COM_DB,
			rev				=> open,
			rx_addr			=> dp1_portaaddr,
			rx_datain		=> dp1_portadatain,
			rx_error		=> open,
			tx_addr			=> dp0_portaaddr,
			tx_dpr_radr		=> tx_dpr_radr,
			tx_error		=> open
		);
	
	timer_inst : timer
		PORT MAP (
			CLK		=> CLK40,
			RST		=> RST,
			systime	=> systime
		);
		

	-- indicate FPGA is configured
	FPGA_LOADED	<= '0';
	
	-- Reset through comm	
	COMM_RESET	<= '1'; -- disbled    NOT COMM_nRESET;
	
	
	
	-- safe ATWD idle state to keep the ATWD input bufferes happy
	-- ATWD 0
	ATWDTrigger_0	<= '0';
	OutputEnable_0	<= '0';
	CounterClock_0	<= '0';
	ShiftClock_0	<= '0';
	RampSet_0		<= '0';
	ChannelSelect_0	<= "00";
	ReadWrite_0		<= '0';
	AnalogReset_0	<= '0';
	DigitalReset_0	<= '1';
	DigitalSet_0	<= '0';
	-- ATWD 1
	ATWDTrigger_1	<= '0';
	OutputEnable_1	<= '0';
	CounterClock_1	<= '0';
	ShiftClock_1	<= '0';
	RampSet_1		<= '0';
	ChannelSelect_1	<= "00";
	ReadWrite_1		<= '0';
	AnalogReset_1	<= '0';
	DigitalReset_1	<= '1';
	DigitalSet_1	<= '0';
		
END;
