-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : domapp.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-10-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This is the toplevel design file. It holds the stripe, daq, ...
-------------------------------------------------------------------------------
-- Copyright (c) 2003 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-10-23  V01-01-00   thorsten
-- 2004-07-28              thorsten  added communications code  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE WORK.ctrl_data_types.all;


ENTITY domapp IS
	PORT (
		-- stripe IO
		CLK_REF			: IN STD_LOGIC;
		nPOR			: IN STD_LOGIC;
		nRESET			: INOUT	STD_LOGIC;
		-- UART
		UARTRXD				: IN	STD_LOGIC;
		UARTDSRN			: IN	STD_LOGIC;
		UARTCTSN			: IN	STD_LOGIC;
		UARTRIN				: INOUT	STD_LOGIC;
		UARTDCDN			: INOUT	STD_LOGIC;
		UARTTXD				: OUT	STD_LOGIC;
		UARTRTSN			: OUT	STD_LOGIC;
		UARTDTRN			: OUT	STD_LOGIC;
		-- EBI
		INTEXTPIN			: IN	STD_LOGIC;
		EBIACK				: IN	STD_LOGIC;
		EBIDQ				: INOUT	STD_LOGIC_VECTOR(15 downto 0);
		EBICLK				: OUT	STD_LOGIC;
		EBIWEN				: OUT	STD_LOGIC;
		EBIOEN				: OUT	STD_LOGIC;
		EBIADDR				: OUT	STD_LOGIC_VECTOR(24 downto 0);
		EBIBE				: OUT	STD_LOGIC_VECTOR(1 downto 0);
		EBICSN				: OUT	STD_LOGIC_VECTOR(3 downto 0);
		-- SDRAM
		SDRAMDQ			: INOUT	STD_LOGIC_VECTOR (31 downto 0);
		SDRAMDQS		: INOUT STD_LOGIC_VECTOR (3 downto 0);
		SDRAMCLK		: OUT STD_LOGIC;
		SDRAMCLKN		: OUT STD_LOGIC;
		SDRAMCLKE		: OUT STD_LOGIC;
		SDRAMWEN		: OUT STD_LOGIC;
		SDRAMCASN		: OUT STD_LOGIC;
		SDRAMRASN		: OUT STD_LOGIC;
		SDRAMADDR		: OUT STD_LOGIC_VECTOR (14 downto 0);
		SDRAMCSN		: OUT STD_LOGIC_VECTOR (1 downto 0);
		SDRAMDQM		: OUT STD_LOGIC_VECTOR (3 downto 0);
		-- general FPGA IO
		CLK1p			: IN STD_LOGIC;
		CLK2p			: IN STD_LOGIC;
		CLK3p			: IN STD_LOGIC;
		CLK4p			: IN STD_LOGIC;
		CLKLK_OUT2p		: OUT STD_LOGIC;	-- 40MHz outpout for FADC
		-- setup information
		A_nB			: IN STD_LOGIC;
		COMM_RESET		: OUT STD_LOGIC;	-- board reset initiated by the communication
		FPGA_LOADED		: OUT STD_LOGIC;	-- pulled low when FPGA is configured
		-- Communications DAC
		COM_TX_SLEEP	: OUT STD_LOGIC;
		COM_DB			: OUT STD_LOGIC_VECTOR (13 downto 0);
		-- Communications ADC
		COM_AD_D		: IN STD_LOGIC_VECTOR (11 downto 0);
		COM_AD_OTR		: IN STD_LOGIC;
		-- Communications RS485
		HDV_Rx			: IN STD_LOGIC;
		HDV_RxENA		: OUT STD_LOGIC;
		HDV_TxENA		: OUT STD_LOGIC;
		HDV_IN			: OUT STD_LOGIC;
		-- FLASH ADC
		FLASH_AD_D		: IN STD_LOGIC_VECTOR (11 downto 0);
		FLASH_AD_STBY	: OUT STD_LOGIC;
		FLASH_NCO		: IN STD_LOGIC;
		-- ATWD 0
		ATWD0_D			: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWDTrigger_0	: OUT STD_LOGIC;
		TriggerComplete_0	: IN STD_LOGIC;
		OutputEnable_0	: OUT STD_LOGIC;
		CounterClock_0	: OUT STD_LOGIC;
		ShiftClock_0	: OUT STD_LOGIC;
		RampSet_0		: OUT STD_LOGIC;
		ChannelSelect_0	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite_0		: OUT STD_LOGIC;
		AnalogReset_0	: OUT STD_LOGIC;
		DigitalReset_0	: OUT STD_LOGIC;
		DigitalSet_0	: OUT STD_LOGIC;
		ATWD0VDD_SUP	: OUT STD_LOGIC;
		-- ATWD 1
		ATWD1_D			: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWDTrigger_1	: OUT STD_LOGIC;
		TriggerComplete_1	: IN STD_LOGIC;
		OutputEnable_1	: OUT STD_LOGIC;
		CounterClock_1	: OUT STD_LOGIC;
		ShiftClock_1	: OUT STD_LOGIC;
		RampSet_1		: OUT STD_LOGIC;
		ChannelSelect_1	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite_1		: OUT STD_LOGIC;
		AnalogReset_1	: OUT STD_LOGIC;
		DigitalReset_1	: OUT STD_LOGIC;
		DigitalSet_1	: OUT STD_LOGIC;
		ATWD1VDD_SUP	: OUT STD_LOGIC;
		-- discriminator
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		MultiSPE_nl		: OUT STD_LOGIC;
		OneSPE_nl		: OUT STD_LOGIC;
		-- frontend testpulser (pulse)
		FE_TEST_PULSE	: OUT STD_LOGIC;
		-- frontend testpulser (R2R ladder into signal path)
		FE_PULSER_P		: OUT STD_LOGIC_VECTOR (3 downto 0);
		FE_PULSER_N		: OUT STD_LOGIC_VECTOR (3 downto 0);
		-- frontend testpulser (R2R ladder ATWD ch3 MUX)
		R2BUS			: OUT STD_LOGIC_VECTOR (7 downto 0);
		-- on board single LED flasher
		SingleLED_TRIGGER	: OUT STD_LOGIC;
		-- Flasher board
		FL_Trigger			: OUT STD_LOGIC;
		FL_Trigger_bar		: OUT STD_LOGIC;
		FL_ATTN				: IN STD_LOGIC;
		FL_AUX_RESET		: OUT STD_LOGIC;
		FL_TMS				: OUT STD_LOGIC;
		FL_TCK				: OUT STD_LOGIC;
		FL_TDI				: OUT STD_LOGIC;
		FL_TDO				: IN STD_LOGIC;
		-- local coincidence
		COINCIDENCE_OUT_DOWN	: OUT STD_LOGIC;
		COINC_DOWN_ALATCH	: OUT STD_LOGIC;
		COINC_DOWN_ABAR		: IN STD_LOGIC;
		COINC_DOWN_A		: IN STD_LOGIC;
		COINC_DOWN_BLATCH	: OUT STD_LOGIC;
		COINC_DOWN_BBAR		: IN STD_LOGIC;
		COINC_DOWN_B		: IN STD_LOGIC;
		COINCIDENCE_OUT_UP	: OUT STD_LOGIC;
		COINC_UP_ALATCH		: OUT STD_LOGIC;
		COINC_UP_ABAR		: IN STD_LOGIC;
		COINC_UP_A			: IN STD_LOGIC;
		COINC_UP_BLATCH		: OUT STD_LOGIC;
		COINC_UP_BBAR		: IN STD_LOGIC;
		COINC_UP_B			: IN STD_LOGIC;
		-- PLD to FPGA EBI like interface (not fully defined yet)
		PLD_FPGA		: INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		PLD_FPGA_nOE	: IN STD_LOGIC;
		PLD_FPGA_nWE	: IN STD_LOGIC;
		PLD_FPGA_BUSY	: OUT STD_LOGIC;
		-- Test connector (JP13) No defined use for it yet!
		FPGA_D			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		FPGA_DA			: OUT STD_LOGIC;
		FPGA_CE			: OUT STD_LOGIC;
		FPGA_RW			: OUT STD_LOGIC;
		-- Test connector (JP19)	THERE IS NO 11   11 is CLK1n
		PGM				: OUT STD_LOGIC_VECTOR (15 downto 0)
	);
END domapp;


ARCHITECTURE arch_domapp OF domapp IS

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
	
	COMPONENT pll4x
		PORT (
			inclock		: IN STD_LOGIC;
			locked		: OUT STD_LOGIC;
			clock1		: OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT systimer IS
		PORT (
			CLK		: IN  STD_LOGIC;
			RST		: IN  STD_LOGIC;
			systime	: OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT stripe
		PORT (
			clk_ref				: IN	STD_LOGIC;
			npor				: IN	STD_LOGIC;
			nreset				: INOUT	STD_LOGIC;
			uartrxd				: IN	STD_LOGIC;
			uartdsrn			: IN	STD_LOGIC;
			uartctsn			: IN	STD_LOGIC;
			uartrin				: INOUT	STD_LOGIC;
			uartdcdn			: INOUT	STD_LOGIC;
			uarttxd				: OUT	STD_LOGIC;
			uartrtsn			: OUT	STD_LOGIC;
			uartdtrn			: OUT	STD_LOGIC;
			intextpin			: IN	STD_LOGIC;
			ebiack				: IN	STD_LOGIC;
			ebidq				: INOUT	STD_LOGIC_VECTOR(15 downto 0);
			ebiclk				: OUT	STD_LOGIC;
			ebiwen				: OUT	STD_LOGIC;
			ebioen				: OUT	STD_LOGIC;
			ebiaddr				: OUT	STD_LOGIC_VECTOR(24 downto 0);
			ebibe				: OUT	STD_LOGIC_VECTOR(1 downto 0);
			ebicsn				: OUT	STD_LOGIC_VECTOR(3 downto 0);
			sdramdq				: INOUT	STD_LOGIC_VECTOR(31 downto 0);
			sdramdqs			: INOUT	STD_LOGIC_VECTOR(3 downto 0);
			sdramclk			: OUT	STD_LOGIC;
			sdramclkn			: OUT	STD_LOGIC;
			sdramclke			: OUT	STD_LOGIC;
			sdramwen			: OUT	STD_LOGIC;
			sdramcasn			: OUT	STD_LOGIC;
			sdramrasn			: OUT	STD_LOGIC;
			sdramaddr			: OUT	STD_LOGIC_VECTOR(14 downto 0);
			sdramcsn			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			sdramdqm			: OUT	STD_LOGIC_VECTOR(3 downto 0);
			slavehclk			: IN	STD_LOGIC;
			slavehwrite			: IN	STD_LOGIC;
			slavehreadyi		: IN	STD_LOGIC;
			slavehselreg		: IN	STD_LOGIC;
			slavehsel			: IN	STD_LOGIC;
			slavehmastlock		: IN	STD_LOGIC;
			slavehaddr			: IN	STD_LOGIC_VECTOR(31 downto 0);
			slavehtrans			: IN	STD_LOGIC_VECTOR(1 downto 0);
			slavehsize			: IN	STD_LOGIC_VECTOR(1 downto 0);
			slavehburst			: IN	STD_LOGIC_VECTOR(2 downto 0);
			slavehwdata			: IN	STD_LOGIC_VECTOR(31 downto 0);
			slavehreadyo		: OUT	STD_LOGIC;
			slavebuserrint		: OUT	STD_LOGIC;
			slavehresp			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			slavehrdata			: OUT	STD_LOGIC_VECTOR(31 downto 0);
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
			intpld				: IN	STD_LOGIC_VECTOR(5 downto 0);
			dp0_2_portaclk		: IN	STD_LOGIC;
			dp0_portawe			: IN	STD_LOGIC;
			dp0_portaaddr		: IN	STD_LOGIC_VECTOR(12 downto 0);
			dp0_portadatain		: IN	STD_LOGIC_VECTOR(31 downto 0);
			dp0_portadataout	: OUT	STD_LOGIC_VECTOR(31 downto 0);
			dp1_3_portaclk		: IN	STD_LOGIC;
			dp1_portawe			: IN	STD_LOGIC;
			dp1_portaaddr		: IN	STD_LOGIC_VECTOR(12 downto 0);
			dp1_portadatain		: IN	STD_LOGIC_VECTOR(31 downto 0);
			dp1_portadataout	: OUT	STD_LOGIC_VECTOR(31 downto 0);
			gpi					: IN	STD_LOGIC_VECTOR(7 downto 0);
			gpo					: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT daq
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
			);
		PORT (
			CLK20			: IN STD_LOGIC;
			CLK40			: IN STD_LOGIC;
			CLK80			: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			systime			: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			-- setup
			enable_DAQ		: IN STD_LOGIC;
			enable_AB		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			trigger_enable	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			ATWD_mode		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			LC_mode			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			DAQ_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			LBM_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			COMPR_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			COMPR_ctrl		: IN COMPR_STRUCT;
			-- monitor signals
			-- Lookback Memory Pointer
			LBM_ptr			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			LBM_ptr_RST		: IN STD_LOGIC;
			-- interfacs to calibration
			CS_trigger		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			-- interface to countrate meter
			discSPEpulse	: OUT STD_LOGIC;
			discMPEpulse	: OUT STD_LOGIC;
			-- interface to local coincidence
			LC_trigger		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			LC_abort		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	 		LC				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			LC_launch		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			LC_disc			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- discriminator
			MultiSPE		: IN STD_LOGIC;
			OneSPE			: IN STD_LOGIC;
			MultiSPE_nl		: OUT STD_LOGIC;
			OneSPE_nl		: OUT STD_LOGIC;
			-- ATWD A
			ATWD0_D			: IN STD_LOGIC_VECTOR (9 downto 0);
			ATWDTrigger_0	: OUT STD_LOGIC;
			TriggerComplete_0	: IN STD_LOGIC;
			OutputEnable_0	: OUT STD_LOGIC;
			CounterClock_0	: OUT STD_LOGIC;
			ShiftClock_0	: OUT STD_LOGIC;
			RampSet_0		: OUT STD_LOGIC;
			ChannelSelect_0	: OUT STD_LOGIC_VECTOR(1 downto 0);
			ReadWrite_0		: OUT STD_LOGIC;
			AnalogReset_0	: OUT STD_LOGIC;
			DigitalReset_0	: OUT STD_LOGIC;
			DigitalSet_0	: OUT STD_LOGIC;
			ATWD0VDD_SUP	: OUT STD_LOGIC;
			-- ATWD B
			ATWD1_D			: IN STD_LOGIC_VECTOR (9 downto 0);
			ATWDTrigger_1	: OUT STD_LOGIC;
			TriggerComplete_1	: IN STD_LOGIC;
			OutputEnable_1	: OUT STD_LOGIC;
			CounterClock_1	: OUT STD_LOGIC;
			ShiftClock_1	: OUT STD_LOGIC;
			RampSet_1		: OUT STD_LOGIC;
			ChannelSelect_1	: OUT STD_LOGIC_VECTOR(1 downto 0);
			ReadWrite_1		: OUT STD_LOGIC;
			AnalogReset_1	: OUT STD_LOGIC;
			DigitalReset_1	: OUT STD_LOGIC;
			DigitalSet_1	: OUT STD_LOGIC;
			ATWD1VDD_SUP	: OUT STD_LOGIC;
			-- FADC
			FLASH_AD_D		: IN STD_LOGIC_VECTOR (FADC_WIDTH-1 downto 0);
			FLASH_AD_STBY	: OUT STD_LOGIC;
			FLASH_NCO		: IN STD_LOGIC;
			-- ATWD A pedestal
			ATWD_ped_data_A	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_ped_addr_A	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- ATWD B pedestal
			ATWD_ped_data_B	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_ped_addr_B	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- AHB master
			slavehclk		: OUT	STD_LOGIC;
			slavehwrite		: OUT	STD_LOGIC;
			slavehreadyi	: OUT	STD_LOGIC;
			slavehselreg	: OUT	STD_LOGIC;
			slavehsel		: OUT	STD_LOGIC;
			slavehmastlock	: OUT	STD_LOGIC;
			slavehaddr		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			slavehtrans		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			slavehsize		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			slavehburst		: OUT	STD_LOGIC_VECTOR(2 downto 0);
			slavehwdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			slavehreadyo	: IN	STD_LOGIC;
			slavebuserrint	: IN	STD_LOGIC;
			slavehresp		: IN	STD_LOGIC_VECTOR(1 downto 0);
			slavehrdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT slaveregister
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			systime		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			-- connections to the stripe
			masterhclk		: OUT	STD_LOGIC;
			masterhready	: OUT	STD_LOGIC;
			masterhgrant	: OUT	STD_LOGIC;
			masterhrdata	: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhresp		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhwrite	: IN	STD_LOGIC;
			masterhlock		: IN	STD_LOGIC;
			masterhbusreq	: IN	STD_LOGIC;
			masterhaddr		: IN	STD_LOGIC_VECTOR(31 downto 0);
			masterhburst	: IN	STD_LOGIC_VECTOR(2 downto 0);
			masterhsize		: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhtrans	: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhwdata	: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- command register
			DAQ_ctrl		: OUT DAQ_STRUCT;
			CS_ctrl			: OUT CS_STRUCT;
			cs_flash_time	: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			LC_ctrl			: OUT LC_STRUCT;
			RM_ctrl			: OUT RM_CTRL_STRUCT;
			RM_stat			: IN  RM_STAT_STRUCT;
			COMM_CTRL		: OUT COMM_CTRL_STRUCT;
			COMM_STAT		: IN  COMM_STAT_STRUCT;
			
			DOM_status		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			COMPR_ctrl		: OUT COMPR_STRUCT;
			-- pointers
			LBM_ptr			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			-- kale communication interface
			-- R2R ladder
			cs_wf_data		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			cs_wf_addr		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			-- ATWD A pedestal
			ATWD_ped_data_A	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_ped_addr_A	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- ATWD B pedestal
			ATWD_ped_data_B	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_ped_addr_B	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT comm_wrapper
		PORT (
			CLK20				: IN  STD_LOGIC;
			RST					: IN  STD_LOGIC;
			systime				: IN  STD_LOGIC_VECTOR(47 DOWNTO 0);
			-- setup
			COMM_CTRL			: IN  COMM_CTRL_STRUCT;
			COMM_STAT			: OUT COMM_STAT_STRUCT;
			-- hardware
			A_nB				: IN  STD_LOGIC;
			COM_AD_D			: IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
			COM_TX_SLEEP		: OUT STD_LOGIC;
			COM_DB				: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
			HDV_Rx				: IN  STD_LOGIC;
			HDV_RxENA			: OUT STD_LOGIC;
			HDV_IN				: OUT STD_LOGIC;
			HDV_TxENA			: OUT STD_LOGIC;
			COMM_RESET			: OUT STD_LOGIC;
			-- RX DPM
			dp1_portawe			: OUT STD_LOGIC;
			dp1_portaaddr		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
			dp1_portadatain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			-- TX DPM
			dp0_portaaddr		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
			dp0_portadataout	: IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			-- TC
			tc					: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT rate_meters
		PORT (
			-- Common Inputs
			CLK20		: IN  STD_LOGIC;
			CLK40		: IN  STD_LOGIC;
			RST			: IN  STD_LOGIC;
			systime		: IN  STD_LOGIC_VECTOR (47 DOWNTO 0);  --&&&
			-- slaveregister
			RM_ctrl		: IN  RM_CTRL_STRUCT;
			RM_stat		: OUT RM_STAT_STRUCT;
			-- DAQ interface
			RM_daq_disc	: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- test
			TC			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT calibration_sources
		PORT (
			-- Common Inputs
			CLK20				: IN  STD_LOGIC;
			CLK40				: IN  STD_LOGIC;
			RST					: IN  STD_LOGIC;
			systime				: IN  STD_LOGIC_VECTOR (47 DOWNTO 0); --&&&
			-- slaveregister
			cs_ctrl				: CS_STRUCT;
			cs_wf_data			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			cs_wf_addr			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			cs_flash_now		: OUT STD_LOGIC;
			cs_flash_time		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
			-- DAQ interface
			cs_daq_trigger		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			cs_daq_veto			: IN STD_LOGIC;
			-- I/O
			SingleLED_Trigger	: OUT STD_LOGIC;
			FE_TEST_PULSE		: OUT STD_LOGIC;
			R2BUS				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			FE_PULSER_P			: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			FE_PULSER_N			: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			FL_Trigger			: OUT STD_LOGIC;
			FL_Trigger_bar		: OUT STD_LOGIC;
			FL_ATTN				: IN STD_LOGIC;
			FL_AUX_RESET		: OUT STD_LOGIC;
			--test
			TC					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT local_coincidence
		PORT (
			-- Common Inputs
			CLK20                : IN  STD_LOGIC;
			CLK40                : IN  STD_LOGIC;
			CLK80                : IN  STD_LOGIC;
			RST                  : IN  STD_LOGIC;
			systime              : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
			-- slaveregister
			LC_ctrl              : IN  LC_STRUCT;
			-- DAQ interface
			lc_daq_trigger       : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			lc_daq_abort         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			lc_daq_disc          : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
			lc_daq_launch        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- I/O
			COINCIDENCE_OUT_DOWN : OUT STD_LOGIC;
			COINC_DOWN_ALATCH    : OUT STD_LOGIC;
			COINC_DOWN_ABAR      : IN  STD_LOGIC;
			COINC_DOWN_A         : IN  STD_LOGIC;
			COINC_DOWN_BLATCH    : OUT STD_LOGIC;
			COINC_DOWN_BBAR      : IN  STD_LOGIC;
			COINC_DOWN_B         : IN  STD_LOGIC;
			COINCIDENCE_OUT_UP   : OUT STD_LOGIC;
			COINC_UP_ALATCH      : OUT STD_LOGIC;
			COINC_UP_ABAR        : IN  STD_LOGIC;
			COINC_UP_A           : IN  STD_LOGIC;
			COINC_UP_BLATCH      : OUT STD_LOGIC;
			COINC_UP_BBAR        : IN  STD_LOGIC;
			COINC_UP_B           : IN  STD_LOGIC;
			-- test
			TC                   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;



	-- gerneal siganls
	SIGNAL low		: STD_LOGIC;
	SIGNAL high		: STD_LOGIC;
	
	SIGNAL CLK20	: STD_LOGIC;
	SIGNAL CLK40	: STD_LOGIC;
	SIGNAL CLK80	: STD_LOGIC;
	SIGNAL RST		: STD_LOGIC;
	SIGNAL systime	: STD_LOGIC_VECTOR (47 DOWNTO 0);
	
	SIGNAL TC		: STD_LOGIC_VECTOR (7 downto 0);
	
	-- PLD to STRIPE bridge
	SIGNAL slavehclk		: STD_LOGIC;
	SIGNAL slavehwrite		: STD_LOGIC;
	SIGNAL slavehreadyi		: STD_LOGIC;
	SIGNAL slavehselreg		: STD_LOGIC;
	SIGNAL slavehsel		: STD_LOGIC;
	SIGNAL slavehmastlock	: STD_LOGIC;
	SIGNAL slavehaddr		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL slavehtrans		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL slavehsize		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL slavehburst		: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL slavehwdata		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL slavehreadyo		: STD_LOGIC;
	SIGNAL slavebuserrint	: STD_LOGIC;
	SIGNAL slavehresp		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL slavehrdata		: STD_LOGIC_VECTOR(31 downto 0);
	
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
	SIGNAL dp0_portaaddr	: STD_LOGIC_VECTOR(12 downto 0);
	SIGNAL dp0_portadatain	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp0_portadataout	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp1_3_portaclk	: STD_LOGIC;
	SIGNAL dp1_portawe		: STD_LOGIC;
	SIGNAL dp1_portaaddr	: STD_LOGIC_VECTOR(12 downto 0);
	SIGNAL dp1_portadatain	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp1_portadataout	: STD_LOGIC_VECTOR(31 downto 0);
	
	-- interrupts
	SIGNAL intpld	: STD_LOGIC_VECTOR(5 downto 0);
	-- GP stripe IO
	SIGNAL gpi		: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL gpo		: STD_LOGIC_VECTOR(7 downto 0);
	
--	-- AHB_slave
--	SIGNAL reg_write	: STD_LOGIC; 
--	SIGNAL reg_address	: STD_LOGIC_VECTOR(31 downto 0);
--	SIGNAL reg_wdata	: STD_LOGIC_VECTOR(31 downto 0);
--	SIGNAL reg_rdata	: STD_LOGIC_VECTOR(31 downto 0);
--	SIGNAL reg_enable	: STD_LOGIC;
--	SIGNAL reg_wait_sig	: STD_LOGIC;
	
--	-- AHB master
--	SIGNAL start_trans		: STD_LOGIC;
--	SIGNAL address			: STD_LOGIC_VECTOR(31 downto 0);
--	SIGNAL wdata			: STD_LOGIC_VECTOR(31 downto 0);
--	SIGNAL wait_sig			: STD_LOGIC;
--	SIGNAL trans_length		: INTEGER;
--	SIGNAL bus_error		: STD_LOGIC;
--	SIGNAL master_addr_start	: STD_LOGIC_VECTOR(15 downto 0);
	
	-- slaveregister
	SIGNAL DAQ_ctrl		: DAQ_STRUCT;
	SIGNAL LBM_ptr		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL COMM_CTRL		: COMM_CTRL_STRUCT;
	SIGNAL COMM_STAT		: COMM_STAT_STRUCT;
			
	
	
	SIGNAL ATWD_ped_data_A	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL ATWD_ped_addr_A	: STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL ATWD_ped_data_B	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL ATWD_ped_addr_B	: STD_LOGIC_VECTOR (8 DOWNTO 0);
	
	
	-- Rate Meter
	SIGNAL RM_ctrl		: RM_CTRL_STRUCT;
	SIGNAL RM_stat		: RM_STAT_STRUCT;
	SIGNAL RM_daq_disc	: STD_LOGIC_VECTOR (1 DOWNTO 0); -- 0=SPE; 1=MPE
	
	-- Calibration Sources
	SIGNAL CS_ctrl		: CS_STRUCT;
	SIGNAL cs_flash_time	: STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL CS_trigger	: STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL cs_wf_data	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL cs_wf_addr	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	
	-- local coincidence
	SIGNAL LC_ctrl			: LC_STRUCT;
	SIGNAL lc_daq_trigger	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL lc_daq_abort		: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL lc_daq_disc		: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL lc_daq_launch	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	
	-- Compression
	SIGNAL COMPR_ctrl	: COMPR_STRUCT;
	
BEGIN
	-- general
	low		<= '0';
	high	<= '1';
	
	-- STRIPE to PLD bridge
	masterhclk			<= CLK20;

	-- DP SRAM
	dp0_2_portaclk		<= CLK20;
	dp0_portawe			<= '0';
	--dp0_portaaddr		<= (others=>'0');
	dp0_portadatain		<= (others=>'0');
	-- dp0_portadataout	<= ;
	dp1_3_portaclk		<= CLK20;
	--dp1_portawe			<= '0';
	--dp1_portaaddr		<= (others=>'0');
	--dp1_portadatain		<= (others=>'0');
	-- dp2_portadataout	<= ;
	
	-- interrupts
	intpld	<= (others=>'0');
	
	-- GP stripe IO
	gpi(7 downto 0)		<= (others=>'0');
	
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
		
	CLKLK_OUT2p	<= CLK40;
	
	inst_pll4x : pll4x
		PORT MAP (
			inclock		=> CLK1p,
			locked		=> open,
			clock1		=> CLK80
		);
		
	inst_systimer : systimer
		PORT MAP (
			CLK		=> CLK40,
			RST		=> RST,
			systime	=> systime
		);
	
	stripe_inst : stripe
		PORT MAP (
			clk_ref				=> CLK_REF,
			npor				=> nPOR,
			nreset				=> nRESET,
			uartrxd				=> UARTRXD,
			uartdsrn			=> UARTDSRN,
			uartctsn			=> UARTCTSN,
			uartrin				=> UARTRIN,
			uartdcdn			=> UARTDCDN,
			uarttxd				=> UARTTXD,
			uartrtsn			=> UARTRTSN,
			uartdtrn			=> UARTDTRN,
			intextpin			=> INTEXTPIN,
			ebiack				=> EBIACK,
			ebidq				=> EBIDQ,
			ebiclk				=> EBICLK,
			ebiwen				=> EBIWEN,
			ebioen				=> EBIOEN,
			ebiaddr				=> EBIADDR,
			ebibe				=> EBIBE,
			ebicsn				=> EBICSN,
			sdramdq				=> SDRAMDQ,
			sdramdqs			=> SDRAMDQS,
			sdramclk			=> SDRAMCLK,
			sdramclkn			=> SDRAMCLKN,
			sdramclke			=> SDRAMCLKE,
			sdramwen			=> SDRAMWEN,
			sdramcasn			=> SDRAMCASN,
			sdramrasn			=> SDRAMRASN,
			sdramaddr			=> SDRAMADDR,
			sdramcsn			=> SDRAMCSN,
			sdramdqm			=> SDRAMDQM,
			slavehclk			=> slavehclk,
			slavehwrite			=> slavehwrite,
			slavehreadyi		=> slavehreadyi,
			slavehselreg		=> slavehselreg,
			slavehsel			=> slavehsel,
			slavehmastlock		=> slavehmastlock,
			slavehaddr			=> slavehaddr,
			slavehtrans			=> slavehtrans,
			slavehsize			=> slavehsize,
			slavehburst			=> slavehburst,
			slavehwdata			=> slavehwdata,
			slavehreadyo		=> slavehreadyo,
			slavebuserrint		=> slavebuserrint,
			slavehresp			=> slavehresp,
			slavehrdata			=> slavehrdata,
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
			intpld				=> intpld,
			dp0_2_portaclk		=> dp0_2_portaclk,
			dp0_portawe			=> dp0_portawe,
			dp0_portaaddr		=> dp0_portaaddr,
			dp0_portadatain		=> dp0_portadatain,
			dp0_portadataout	=> dp0_portadataout,
			dp1_3_portaclk		=> dp1_3_portaclk,
			dp1_portawe			=> dp1_portawe,
			dp1_portaaddr		=> dp1_portaaddr,
			dp1_portadatain		=> dp1_portadatain,
			dp1_portadataout	=> open,
			gpi					=> gpi,
			gpo					=> gpo
		);
		
	inst_daq:  daq
		GENERIC MAP (
			FADC_WIDTH		=> 10
			)
		PORT MAP (
			CLK20			=> CLK20,
			CLK40			=> CLK40,
			CLK80			=> CLK80,
			RST				=> RST,
			systime			=> systime,
			-- setup
			enable_DAQ		=> DAQ_ctrl.enable_DAQ,
			enable_AB		=> DAQ_ctrl.enable_AB,
			trigger_enable	=> DAQ_ctrl.trigger_enable,
			ATWD_mode(1 DOWNTO 0)	=> DAQ_ctrl.ATWD_mode,
			ATWD_mode(2)	=> '0', --DAQ_ctrl.ATWD_mode,
			LC_mode			=> DAQ_ctrl.LC_mode,
			DAQ_mode		=> DAQ_ctrl.DAQ_mode,
			LBM_mode		=> DAQ_ctrl.LBM_mode,
			COMPR_mode		=> DAQ_ctrl.COMPR_mode,
			COMPR_ctrl		=> COMPR_ctrl,
			-- monitor signals
			-- Lookback Memory Pointer
			LBM_ptr			=> LBM_ptr,
			LBM_ptr_RST		=> DAQ_ctrl.LBM_ptr_RST,
			-- interfacs to calibration
			CS_trigger		=> CS_trigger,
			-- interface to countrate meter
			discSPEpulse	=> RM_daq_disc(0),
			discMPEpulse	=> RM_daq_disc(1),
			-- interface to local coincidence
			LC_trigger		=> lc_daq_trigger,
			LC_abort		=> lc_daq_abort,
	 		LC				=> "00",
			LC_launch		=> lc_daq_launch,
			LC_disc			=> lc_daq_disc,
			-- discriminator
			MultiSPE		=> MultiSPE,
			OneSPE			=> OneSPE,
			MultiSPE_nl		=> MultiSPE_nl,
			OneSPE_nl		=> OneSPE_nl,
			-- ATWD A
			ATWD0_D			=> ATWD0_D,
			ATWDTrigger_0	=> ATWDTrigger_0,
			TriggerComplete_0	=> TriggerComplete_0,
			OutputEnable_0	=> OutputEnable_0,
			CounterClock_0	=> CounterClock_0,
			ShiftClock_0	=> ShiftClock_0,
			RampSet_0		=> RampSet_0,
			ChannelSelect_0	=> ChannelSelect_0,
			ReadWrite_0		=> ReadWrite_0,
			AnalogReset_0	=> AnalogReset_0,
			DigitalReset_0	=> DigitalReset_0,
			DigitalSet_0	=> DigitalSet_0,
			ATWD0VDD_SUP	=> ATWD0VDD_SUP,
			-- ATWD B
			ATWD1_D			=> ATWD1_D,
			ATWDTrigger_1	=> ATWDTrigger_1,
			TriggerComplete_1	=> TriggerComplete_1,
			OutputEnable_1	=> OutputEnable_1,
			CounterClock_1	=> CounterClock_1,
			ShiftClock_1	=> ShiftClock_1,
			RampSet_1		=> RampSet_1,
			ChannelSelect_1	=> ChannelSelect_1,
			ReadWrite_1		=> ReadWrite_1,
			AnalogReset_1	=> AnalogReset_1,
			DigitalReset_1	=> DigitalReset_1,
			DigitalSet_1	=> DigitalSet_1,
			ATWD1VDD_SUP	=> ATWD1VDD_SUP,
			-- FADC
			FLASH_AD_D		=> FLASH_AD_D (11 DOWNTO 2),
			FLASH_AD_STBY	=> FLASH_AD_STBY,
			FLASH_NCO		=> FLASH_NCO,
			-- ATWD A pedestal
			ATWD_ped_data_A	=> ATWD_ped_data_A,
			ATWD_ped_addr_A	=> ATWD_ped_addr_A,
			-- ATWD B pedestal
			ATWD_ped_data_B	=> ATWD_ped_data_B,
			ATWD_ped_addr_B	=> ATWD_ped_addr_B,
			-- AHB master
			slavehclk		=> slavehclk,
			slavehwrite		=> slavehwrite,
			slavehreadyi	=> slavehreadyi,
			slavehselreg	=> slavehselreg,
			slavehsel		=> slavehsel,
			slavehmastlock	=> slavehmastlock,
			slavehaddr		=> slavehaddr,
			slavehtrans		=> slavehtrans,
			slavehsize		=> slavehsize,
			slavehburst		=> slavehburst,
			slavehwdata		=> slavehwdata,
			slavehreadyo	=> slavehreadyo,
			slavebuserrint	=> slavebuserrint,
			slavehresp		=> slavehresp,
			slavehrdata		=> slavehrdata,
			-- test connector
			TC				=> open
		);
		
	inst_slaveregister : slaveregister
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			systime		=> systime,
			-- connections to the stripe
			masterhclk		=> masterhclk,
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
			-- command register
			DAQ_ctrl		=> DAQ_ctrl,
			CS_ctrl			=> CS_ctrl,
			cs_flash_time	=> cs_flash_time,
			LC_ctrl			=> LC_ctrl,
			RM_ctrl			=> RM_ctrl,
			RM_stat			=> RM_stat,
			COMM_CTRL		=> COMM_CTRL,
			COMM_STAT		=> COMM_STAT,
			DOM_status		=> X"00000000",
			COMPR_ctrl		=> COMPR_ctrl,
			-- pointers
			LBM_ptr			=> LBM_ptr,
			-- kale communication interface
			-- R2R ladder
			cs_wf_data		=> cs_wf_data,
			cs_wf_addr		=> cs_wf_addr,
			-- ATWD A pedestal
			ATWD_ped_data_A	=> ATWD_ped_data_A,
			ATWD_ped_addr_A	=> ATWD_ped_addr_A,
			-- ATWD B pedestal
			ATWD_ped_data_B	=> ATWD_ped_data_B,
			ATWD_ped_addr_B	=> ATWD_ped_addr_B,
			-- test connector
			TC				=> open
		);
		
	inst_comm_wrapper : comm_wrapper
		PORT MAP (
			CLK20				=> CLK20,
			RST					=> RST,
			systime				=> systime,
			-- setup
			COMM_CTRL			=> COMM_CTRL,
			COMM_STAT			=> COMM_STAT,
			-- hardware
			A_nB				=> A_nB,
			COM_AD_D			=> COM_AD_D,
			COM_TX_SLEEP		=> COM_TX_SLEEP,
			COM_DB				=> COM_DB,
			HDV_Rx				=> HDV_Rx,
			HDV_RxENA			=> HDV_RxENA,
			HDV_IN				=> HDV_IN,
			HDV_TxENA			=> HDV_TxENA,
			COMM_RESET			=> COMM_RESET,
			-- RX DPM
			dp1_portawe			=> dp1_portawe,
			dp1_portaaddr		=> dp1_portaaddr,
			dp1_portadatain		=> dp1_portadatain,
			-- TX DPM
			dp0_portaaddr		=> dp0_portaaddr,
			dp0_portadataout	=> dp0_portadataout,
			-- TC
			tc					=> open
		);

	inst_rate_meters : rate_meters
		PORT MAP (
			-- Common Inputs
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			RST			=> RST,
			systime		=> systime,
			-- slaveregister
			RM_ctrl		=> RM_ctrl,
			RM_stat		=> RM_stat,
			-- DAQ interface
			RM_daq_disc	=> RM_daq_disc,
			-- test
			TC			=> open
		);
		
	inst_calibration_sources : calibration_sources
		PORT MAP (
			-- Common Inputs
			CLK20				=> CLK20,
			CLK40				=> CLK40,
			RST					=> RST,
			systime				=> systime,
			-- slaveregister
			cs_ctrl				=> CS_ctrl,
			cs_wf_data			=> cs_wf_data,
			cs_wf_addr			=> cs_wf_addr,
			cs_flash_now		=> open,
			cs_flash_time		=> cs_flash_time,
			-- DAQ interface
			cs_daq_trigger		=> CS_trigger,
			cs_daq_veto			=> '0',
			-- I/O
			SingleLED_Trigger	=> SingleLED_Trigger,
			FE_TEST_PULSE		=> FE_TEST_PULSE,
			R2BUS				=> R2BUS,
			FE_PULSER_P			=> FE_PULSER_P,
			FE_PULSER_N			=> FE_PULSER_N,
			FL_Trigger			=> FL_Trigger,
			FL_Trigger_bar		=> FL_Trigger_bar,
			FL_ATTN				=> FL_ATTN,
			FL_AUX_RESET		=> FL_AUX_RESET,
			--test
			TC					=> open
		);
		
	inst_local_coincidence : local_coincidence
		PORT MAP (
			-- Common Inputs
			CLK20                => CLK20,
			CLK40                => CLK40,
			CLK80                => CLK80,
			RST                  => RST,
			systime              => systime,
			-- slaveregister
			LC_ctrl              => LC_ctrl,
			-- DAQ interface
			lc_daq_trigger       => lc_daq_trigger,
			lc_daq_abort         => lc_daq_abort,
			lc_daq_disc          => lc_daq_disc,
			lc_daq_launch        => lc_daq_launch,
			-- I/O
			COINCIDENCE_OUT_DOWN => COINCIDENCE_OUT_DOWN,
			COINC_DOWN_ALATCH    => COINC_DOWN_ALATCH,
			COINC_DOWN_ABAR      => COINC_DOWN_ABAR,
			COINC_DOWN_A         => COINC_DOWN_A,
			COINC_DOWN_BLATCH    => COINC_DOWN_BLATCH,
			COINC_DOWN_BBAR      => COINC_DOWN_BBAR,
			COINC_DOWN_B         => COINC_DOWN_B,
			COINCIDENCE_OUT_UP   => COINCIDENCE_OUT_UP,
			COINC_UP_ALATCH      => COINC_UP_ALATCH,
			COINC_UP_ABAR        => COINC_UP_ABAR,
			COINC_UP_A           => COINC_UP_A,
			COINC_UP_BLATCH      => COINC_UP_BLATCH,
			COINC_UP_BBAR        => COINC_UP_BBAR,
			COINC_UP_B           => COINC_UP_B,
			-- test
			TC                   => OPEN
		);
	
	
	
	
	-- FPGA loaded output to be read by the CPU through the CPLD
	FPGA_LOADED	<= '0';
		
	-- unused pins
	-- PLD to FPGA EBI like interface (not fully defined yet)
	PLD_FPGA		<= (OTHERS=>'Z');
	PLD_FPGA_BUSY	<= 'Z';
	-- Test connector (JP13) No defined use for it yet!
	FPGA_D		<= (OTHERS=>'Z');
	FPGA_DA		<= 'Z';
	FPGA_CE		<= 'Z';
	FPGA_RW		<= 'Z';
	-- Test connector (JP19)
	PGM			<= (OTHERS=>'Z');
		
	
END arch_domapp;