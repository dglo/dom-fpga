-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : daq.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-10-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module does the data aquisition for the ATWD and the FADC,
--              formats and compresses the data and then writes it into the
--              lookback memory in SDRAM
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-10-23  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

USE WORK.icecube_data_types.all;
USE WORK.ctrl_data_types.all;


ENTITY daq IS
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
END daq;

ARCHITECTURE daq_arch OF daq IS

	COMPONENT trigger IS
		PORT (
			CLK40			: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			-- enable
			enable_DAQ		: IN STD_LOGIC;
			enable_AB		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			trigger_enable	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			-- trigger sources
			cs_trigger		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);	-- calibration sources
			lc_trigger		: IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- local coincidence
			-- handshake
			busy_A			: IN STD_LOGIC;
			busy_B			: IN STD_LOGIC;
			busy_FADC_A		: IN STD_LOGIC;
			busy_FADC_B		: IN STD_LOGIC;
			rst_trg_A		: IN STD_LOGIC;
			rst_trg_B		: IN STD_LOGIC;
			ATWDTrigger_sig_A	: OUT STD_LOGIC;
			ATWDTrigger_sig_B	: OUT STD_LOGIC;
			trigger_word	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			-- discriminator
			MultiSPE		: IN STD_LOGIC;
			OneSPE			: IN STD_LOGIC;
			MultiSPE_nl		: OUT STD_LOGIC;
			OneSPE_nl		: OUT STD_LOGIC;
			-- trigger outputs
			ATWDTrigger_A	: OUT STD_LOGIC;
			ATWDTrigger_B	: OUT STD_LOGIC;
			discSPEpulse	: OUT STD_LOGIC;
			discMPEpulse	: OUT STD_LOGIC;
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT FADC_input IS
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
			);
		PORT (
			CLK40			: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			-- fADC connections
			FLASH_AD_D		: IN STD_LOGIC_VECTOR (FADC_WIDTH-1 downto 0);
			FLASH_AD_STBY	: OUT STD_LOGIC;
			FLASH_NCO		: IN STD_LOGIC;
			-- local fADC connection
			FADC_D			: OUT STD_LOGIC_VECTOR (FADC_WIDTH-1 downto 0);
			FADC_NCO		: OUT STD_LOGIC;
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT pingpong IS
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
			);
		port (
			CLK20		: IN STD_LOGIC;
			CLK40		: IN STD_LOGIC;
			CLK80		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			systime		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			-- enable
			busy			: OUT STD_LOGIC;
			busy_FADC		: OUT STD_LOGIC;
			ATWD_mode		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			LC_mode			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			DAQ_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			ATWD_AB			: IN STD_LOGIC;	-- indicates if ping or pong
			COMPR_ctrl		: IN COMPR_STRUCT;
			-- trigger
			rst_trig		: OUT STD_LOGIC;
			trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			-- local coincidence
			LC_abort		: IN STD_LOGIC;
			LC				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- ATWD
			ATWDTrigger		: IN STD_LOGIC;
			TriggerComplete	: IN STD_LOGIC;
			OutputEnable	: OUT STD_LOGIC;
			CounterClock	: OUT STD_LOGIC;
			RampSet			: OUT STD_LOGIC;
			ChannelSelect	: OUT STD_LOGIC_VECTOR(1 downto 0);
			ReadWrite		: OUT STD_LOGIC;
			AnalogReset		: OUT STD_LOGIC;
			DigitalReset	: OUT STD_LOGIC;
			DigitalSet		: OUT STD_LOGIC;
			ATWD_VDD_SUP	: OUT STD_LOGIC;
			ShiftClock		: OUT STD_LOGIC;
			ATWD_D			: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			-- ATWD pedestal
			ATWD_ped_data	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_ped_addr	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- FADC
			FADC_D			: IN STD_LOGIC_VECTOR (FADC_WIDTH-1 DOWNTO 0);
			FADC_NCO		: IN STD_LOGIC;
			-- data output
			data_avail		: OUT STD_LOGIC;
			read_done		: IN STD_LOGIC;
			compr_avail		: OUT STD_LOGIC;
			compr_size		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_addr		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_data		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			HEADER			: OUT HEADER_VECTOR;
			ATWD_addr		: IN STD_LOGIC_VECTOR (7 downto 0);
			ATWD_data		: OUT STD_LOGIC_VECTOR (31 downto 0);
			FADC_addr		: IN STD_LOGIC_VECTOR (6 downto 0);
			FADC_data		: OUT STD_LOGIC_VECTOR (31 downto 0);
			-- test connector
			TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT mem_interface IS
		PORT (
			CLK20			: IN STD_LOGIC;
			CLK40			: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			-- enable
			LBM_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			LBM_ptr			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			LBM_ptr_RST		: IN STD_LOGIC;
			COMPR_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- data interface A (ping)
			data_avail_A	: IN STD_LOGIC;
			read_done_A		: OUT STD_LOGIC;
			compr_avail_A	: IN STD_LOGIC;
			compr_size_A	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_addr_A	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_data_A	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			HEADER_A		: IN HEADER_VECTOR;
			ATWD_addr_A		: OUT STD_LOGIC_VECTOR (7 downto 0);
			ATWD_data_A		: IN STD_LOGIC_VECTOR (31 downto 0);
			FADC_addr_A		: OUT STD_LOGIC_VECTOR (6 downto 0);
			FADC_data_A		: IN STD_LOGIC_VECTOR (31 downto 0);
			-- data interface B (pong)
			data_avail_B	: IN STD_LOGIC;
			read_done_B		: OUT STD_LOGIC;
			compr_avail_B	: IN STD_LOGIC;
			compr_size_B	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_addr_B	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_data_B	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			HEADER_B		: IN HEADER_VECTOR;
			ATWD_addr_B		: OUT STD_LOGIC_VECTOR (7 downto 0);
			ATWD_data_B		: IN STD_LOGIC_VECTOR (31 downto 0);
			FADC_addr_B		: OUT STD_LOGIC_VECTOR (6 downto 0);
			FADC_data_B		: IN STD_LOGIC_VECTOR (31 downto 0);
			-- ahb_master interface
			start_trans		: OUT	STD_LOGIC;
			abort_trans		: OUT	STD_LOGIC;
			address			: OUT	STD_LOGIC_VECTOR(31 downto 0);
			ahb_address		: IN	STD_LOGIC_VECTOR(31 downto 0);
			wdata			: OUT	STD_LOGIC_VECTOR(31 downto 0);
			wait_sig		: IN	STD_LOGIC;
			ready			: IN	STD_LOGIC;
			trans_length	: OUT	INTEGER;
			bus_error		: IN	STD_LOGIC;
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT ahb_master IS
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- connections to the stripe
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
			-- local bus signals
			start_trans		: IN	STD_LOGIC;
			abort_trans		: IN	STD_LOGIC;
			address			: IN	STD_LOGIC_VECTOR(31 downto 0);
			ahb_address		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			wdata			: IN	STD_LOGIC_VECTOR(31 downto 0);
			wait_sig		: OUT	STD_LOGIC;
			ready			: OUT	STD_LOGIC;
			trans_length	: IN	INTEGER;
			bus_error		: OUT	STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL CLK20n		: STD_LOGIC;
	
	-- local FADC signals
	SIGNAL FADC_D			: STD_LOGIC_VECTOR (FADC_WIDTH-1 downto 0);
	SIGNAL FADC_NCO		: STD_LOGIC;
	-- setup
	CONSTANT ATWD_A		: STD_LOGIC := '0';
	CONSTANT ATWD_B		: STD_LOGIC := '1';
	
	-- trigger handshake signals
	SIGNAL busy_A				: STD_LOGIC;
	SIGNAL busy_B				: STD_LOGIC;
	SIGNAL busy_FADC_A			: STD_LOGIC;
	SIGNAL busy_FADC_B			: STD_LOGIC;
	SIGNAL rst_trig_A			: STD_LOGIC;
	SIGNAL rst_trig_B			: STD_LOGIC;
	SIGNAL ATWDTrigger_sig_A	: STD_LOGIC;
	SIGNAL ATWDTrigger_sig_B	: STD_LOGIC;
	SIGNAL trigger_word			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	-- signals to mem_interface
	-- data interface A (ping)
	SIGNAL data_avail_A		: STD_LOGIC;
	SIGNAL read_done_A		: STD_LOGIC;
	SIGNAL compr_avail_A	: STD_LOGIC;
	SIGNAL compr_size_A		: STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL compr_addr_A		: STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL compr_data_A		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL HEADER_A			: HEADER_VECTOR;
	SIGNAL ATWD_addr_A		: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL ATWD_data_A		: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL FADC_addr_A		: STD_LOGIC_VECTOR (6 downto 0);
	SIGNAL FADC_data_A		: STD_LOGIC_VECTOR (31 downto 0);
	-- data interface B (pong)
	SIGNAL data_avail_B		: STD_LOGIC;
	SIGNAL read_done_B		: STD_LOGIC;
	SIGNAL compr_avail_B	: STD_LOGIC;
	SIGNAL compr_size_B		: STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL compr_addr_B		: STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL compr_data_B		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL HEADER_B			: HEADER_VECTOR;
	SIGNAL ATWD_addr_B		: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL ATWD_data_B		: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL FADC_addr_B		: STD_LOGIC_VECTOR (6 downto 0);
	SIGNAL FADC_data_B		: STD_LOGIC_VECTOR (31 downto 0);
	
	-- local bus signals for the AHB master interface
	SIGNAL start_trans		: STD_LOGIC;
	SIGNAL abort_trans		: STD_LOGIC;
	SIGNAL address			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL ahb_address		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL wdata			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL wait_sig			: STD_LOGIC;
	SIGNAL ready			: STD_LOGIC;
	SIGNAL trans_length		: INTEGER;
	SIGNAL bus_error		: STD_LOGIC;
	
	-- for rate meters and local coincidence
	SIGNAL discSPEpulse_local	: STD_LOGIC;
	SIGNAL discMPEpulse_local	: STD_LOGIC;

BEGIN

	discSPEpulse	<= discSPEpulse_local;
	discMPEpulse	<= discMPEpulse_local;
	LC_disc		<= discMPEpulse_local & discSPEpulse_local;
	LC_launch	<= busy_B & busy_A;

	inst_trigger : trigger
		PORT MAP (
			CLK40			=> CLK40,
			RST				=> RST,
			-- enable
			enable_DAQ		=> enable_DAQ,
			enable_AB		=> enable_AB,
			trigger_enable	=> trigger_enable,
			-- trigger sources
			cs_trigger		=> CS_trigger,
			lc_trigger		=> LC_trigger,
			-- handshake
			busy_A			=> busy_A,
			busy_B			=> busy_B,
			busy_FADC_A		=> busy_FADC_A,
			busy_FADC_B		=> busy_FADC_B,
			rst_trg_A		=> rst_trig_A,
			rst_trg_B		=> rst_trig_B,
			ATWDTrigger_sig_A	=> ATWDTrigger_sig_A,
			ATWDTrigger_sig_B	=> ATWDTrigger_sig_B,
			trigger_word	=> trigger_word,
			-- discriminator
			MultiSPE		=> MultiSPE,
			OneSPE			=> OneSPE,
			MultiSPE_nl		=> MultiSPE_nl,
			OneSPE_nl		=> OneSPE_nl,
			-- trigger outputs
			ATWDTrigger_A	=> ATWDTrigger_0,
			ATWDTrigger_B	=> ATWDTrigger_1,
			discSPEpulse	=> discSPEpulse_local,
			discMPEpulse	=> discMPEpulse_local,
			-- test connector
			TC				=> open
		);
		
	inst_FADC_input : FADC_input
		GENERIC MAP (
			FADC_WIDTH		=> FADC_WIDTH
			)
		PORT MAP (
			CLK40			=> CLK40,
			RST				=> RST,
			-- FADC connections
			FLASH_AD_D		=> FLASH_AD_D,
			FLASH_AD_STBY	=> FLASH_AD_STBY,
			FLASH_NCO		=> FLASH_NCO,
			-- local fADC connection
			FADC_D			=> FADC_D,
			FADC_NCO		=> FADC_NCO,
			-- test connector
			TC				=> open
		);
		
	ping : pingpong		-- A
		GENERIC MAP (
			FADC_WIDTH		=> FADC_WIDTH
			)
		port MAP (
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			systime		=> systime,
			-- enable
			busy			=> busy_A,
			busy_FADC		=> busy_FADC_A,
			ATWD_mode		=> ATWD_mode,
			LC_mode			=> LC_mode,
			DAQ_mode		=> DAQ_mode,
			ATWD_AB			=> ATWD_A,
			COMPR_ctrl		=> COMPR_ctrl,
			-- trigger
			rst_trig		=> rst_trig_A,
			trigger_word	=> trigger_word,
			-- local coincidence
			LC_abort		=> LC_abort(0),
			LC				=> LC,
			-- ATWD
			ATWDTrigger		=> ATWDTrigger_sig_A,
			TriggerComplete	=> TriggerComplete_0,
			OutputEnable	=> OutputEnable_0,
			CounterClock	=> CounterClock_0,
			RampSet			=> RampSet_0,
			ChannelSelect	=> ChannelSelect_0,
			ReadWrite		=> ReadWrite_0,
			AnalogReset		=> AnalogReset_0,
			DigitalReset	=> DigitalReset_0,
			DigitalSet		=> DigitalSet_0,
			ATWD_VDD_SUP	=> ATWD0VDD_SUP,
			ShiftClock		=> ShiftClock_0,
			ATWD_D			=> ATWD0_D,
			-- ATWD pedestal
			ATWD_ped_data	=> ATWD_ped_data_A,
			ATWD_ped_addr	=> ATWD_ped_addr_A,
			-- FADC
			FADC_D			=> FADC_D,
			FADC_NCO		=> FADC_NCO,
			-- data output
			data_avail		=> data_avail_A,
			read_done		=> read_done_A,
			compr_avail		=> compr_avail_A,
			compr_size		=> compr_size_A,
			compr_addr		=> compr_addr_A,
			compr_data		=> compr_data_A,
			HEADER			=> HEADER_A,
			ATWD_addr		=> ATWD_addr_A,
			ATWD_data		=> ATWD_data_A,
			FADC_addr		=> FADC_addr_A,
			FADC_data		=> FADC_data_A,
			-- test connector
			TC			=> open
		);
	
	pong : pingpong		-- B
		GENERIC MAP (
			FADC_WIDTH		=> FADC_WIDTH
			)
		port MAP (
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			systime		=> systime,
			-- enable
			busy			=> busy_B,
			busy_FADC		=> busy_FADC_B,
			ATWD_mode		=> ATWD_mode,
			LC_mode			=> LC_mode,
			DAQ_mode		=> DAQ_mode,
			ATWD_AB			=> ATWD_B,
			COMPR_ctrl		=> COMPR_ctrl,
			-- trigger
			rst_trig		=> rst_trig_B,
			trigger_word	=> trigger_word,
			-- local coincidence
			LC_abort		=> LC_abort(1),
			LC				=> LC,
			-- ATWD
			ATWDTrigger		=> ATWDTrigger_sig_B,
			TriggerComplete	=> TriggerComplete_1,
			OutputEnable	=> OutputEnable_1,
			CounterClock	=> CounterClock_1,
			RampSet			=> RampSet_1,
			ChannelSelect	=> ChannelSelect_1,
			ReadWrite		=> ReadWrite_1,
			AnalogReset		=> AnalogReset_1,
			DigitalReset	=> DigitalReset_1,
			DigitalSet		=> DigitalSet_1,
			ATWD_VDD_SUP	=> ATWD1VDD_SUP,
			ShiftClock		=> ShiftClock_1,
			ATWD_D			=> ATWD1_D,
			-- ATWD pedestal
			ATWD_ped_data	=> ATWD_ped_data_B,
			ATWD_ped_addr	=> ATWD_ped_addr_B,
			-- FADC
			FADC_D			=> FADC_D,
			FADC_NCO		=> FADC_NCO,
			-- data output
			data_avail		=> data_avail_B,
			read_done		=> read_done_B,
			compr_avail		=> compr_avail_B,
			compr_size		=> compr_size_B,
			compr_addr		=> compr_addr_B,
			compr_data		=> compr_data_B,
			HEADER			=> HEADER_B,
			ATWD_addr		=> ATWD_addr_B,
			ATWD_data		=> ATWD_data_B,
			FADC_addr		=> FADC_addr_B,
			FADC_data		=> FADC_data_B,
			-- test connector
			TC			=> open
		);
		
	inst_mem_interface : mem_interface
		PORT MAP (
			CLK20			=> CLK20,
			CLK40			=> CLK40,
			RST				=> RST,
			-- enable
			LBM_mode		=> LBM_mode,
			LBM_ptr			=> LBM_ptr,
			LBM_ptr_RST		=> LBM_ptr_RST,
			COMPR_mode		=> COMPR_mode,
			-- data interface A (ping)
			data_avail_A	=> data_avail_A,
			read_done_A		=> read_done_A,
			compr_avail_A	=> compr_avail_A,
			compr_size_A	=> compr_size_A,
			compr_addr_A	=> compr_addr_A,
			compr_data_A	=> compr_data_A,
			HEADER_A		=> HEADER_A,
			ATWD_addr_A		=> ATWD_addr_A,
			ATWD_data_A		=> ATWD_data_A,
			FADC_addr_A		=> FADC_addr_A,
			FADC_data_A		=> FADC_data_A,
			-- data interface B (pong)
			data_avail_B	=> data_avail_B,
			read_done_B		=> read_done_B,
			compr_avail_B	=> compr_avail_B,
			compr_size_B	=> compr_size_B,
			compr_addr_B	=> compr_addr_B,
			compr_data_B	=> compr_data_B,
			HEADER_B		=> HEADER_B,
			ATWD_addr_B		=> ATWD_addr_B,
			ATWD_data_B		=> ATWD_data_B,
			FADC_addr_B		=> FADC_addr_B,
			FADC_data_B		=> FADC_data_B,
			-- ahb_master interface
			start_trans		=> start_trans,
			abort_trans		=> abort_trans,
			address			=> address,
			ahb_address		=> ahb_address,
			wdata			=> wdata,
			wait_sig		=> wait_sig,
			ready			=> ready,
			trans_length	=> trans_length,
			bus_error		=> bus_error,
			-- test connector
			TC				=> TC --open
		);
	
	CLK20n	<= NOT CLK20;
	inst_ahb_master : ahb_master
		PORT MAP (
			CLK			=> CLK20n,
			RST			=> RST,
			-- connections to the stripe
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
			-- local bus signals
			start_trans		=> start_trans,
			abort_trans		=> abort_trans,
			address			=> address,
			ahb_address		=> ahb_address,
			wdata			=> wdata,
			wait_sig		=> wait_sig,
			ready			=> ready,
			trans_length	=> trans_length,
			bus_error		=> bus_error
		);

END daq_arch;