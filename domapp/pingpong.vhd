-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : pingpong.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-03-22
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module has all the code for a single ATWD and the linked
--              FADC data
--              instantiate as PING and PONG  :-)
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-09-29  V01-01-00   thorsten  
-- 2007-03-22              thorsten  added ATWD dead flag
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE WORK.icecube_data_types.all;
USE WORK.ctrl_data_types.all;
USE WORK.monitor_data_type.all;


ENTITY pingpong IS
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
		ICETOP_ctrl		: IN ICETOP_CTRL_STRUCT;
		-- some status bits
                dead_flag               : OUT STD_LOGIC;
		SPE_level_stretch	: IN STD_LOGIC_VECTOR (1 downto 0);
		-- trigger
		rst_trig		: OUT STD_LOGIC;
		trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		minimum_bias_hit	: IN STD_LOGIC;
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
		-- monitoring
		PP_status	: OUT PP_STRUCT;
		-- test connector
		TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END pingpong;


ARCHITECTURE arch_pingpong OF pingpong IS

	-- ATWD and FADC input
	COMPONENT ADC_input IS
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
			);
		PORT (
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
			ICETOP_ctrl		: IN ICETOP_CTRL_STRUCT;
			-- some status bits
                        dead_flag               : OUT STD_LOGIC;
			SPE_level_stretch	: IN STD_LOGIC_VECTOR (1 downto 0);
			-- trigger
			rst_trig		: OUT STD_LOGIC;
			trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			minimum_bias_hit	: IN STD_LOGIC;
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
			buffer_full	: IN STD_LOGIC;
			HEADER_data	: OUT HEADER_VECTOR;
			HEADER_we	: OUT STD_LOGIC;
			ATWD_addr	: OUT STD_LOGIC_VECTOR (8 downto 0);
			ATWD_data	: OUT STD_LOGIC_VECTOR (9 downto 0);
			ATWD_we		: OUT STD_LOGIC;
			FADC_addr	: OUT STD_LOGIC_VECTOR (7 downto 0);
			FADC_data	: OUT STD_LOGIC_VECTOR (15 downto 0);
			FADC_we		: OUT STD_LOGIC;
			-- test connector
			TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	
	COMPONENT data_buffer IS
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
			);
		PORT (
			CLK40		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- data input
			HEADER_we	: IN STD_LOGIC;
			header_w	: IN HEADER_VECTOR;
			ATWD_waddr	: IN STD_LOGIC_VECTOR (8 downto 0);
			ATWD_wdata	: IN STD_LOGIC_VECTOR (9 downto 0);
			ATWD_we		: IN STD_LOGIC;
			FADC_waddr	: IN STD_LOGIC_VECTOR (7 downto 0);
			FADC_wdata	: IN STD_LOGIC_VECTOR (15 downto 0);
			FADC_we		: IN STD_LOGIC;
			buffer_full	: OUT STD_LOGIC;
			-- data output
			data_available	: OUT STD_LOGIC;
			read_done	: IN STD_LOGIC;
			header_r	: OUT HEADER_VECTOR;
			ATWD_raddr	: IN STD_LOGIC_VECTOR (7 downto 0);
			ATWD_rdata	: OUT STD_LOGIC_VECTOR (31 downto 0);
			FADC_raddr	: IN STD_LOGIC_VECTOR (6 downto 0);
			FADC_rdata	: OUT STD_LOGIC_VECTOR (31 downto 0);
			-- test connector
			TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	
	COMPONENT compression IS
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
			);
		PORT (
			CLK20		: IN STD_LOGIC;
			CLK40		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable
			COMPR_ctrl	: IN COMPR_STRUCT;
			-- data input from data buffer
			data_avail_in	: IN STD_LOGIC;
			read_done_in	: OUT STD_LOGIC;
			HEADER_in		: IN HEADER_VECTOR;
			ATWD_addr_in	: OUT STD_LOGIC_VECTOR (7 downto 0);
			ATWD_data_in	: IN STD_LOGIC_VECTOR (31 downto 0);
			FADC_addr_in	: OUT STD_LOGIC_VECTOR (6 downto 0);
			FADC_data_in	: IN STD_LOGIC_VECTOR (31 downto 0);
			-- data output
			data_avail_out	: OUT STD_LOGIC;
			read_done_out	: IN STD_LOGIC;
			compr_avail_out	: OUT STD_LOGIC;
			compr_size		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_addr		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			compr_data		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			HEADER_out		: OUT HEADER_VECTOR;
			ATWD_addr_out	: IN STD_LOGIC_VECTOR (7 downto 0);
			ATWD_data_out	: OUT STD_LOGIC_VECTOR (31 downto 0);
			FADC_addr_out	: IN STD_LOGIC_VECTOR (6 downto 0);
			FADC_data_out	: OUT STD_LOGIC_VECTOR (31 downto 0);
			-- test connector
			TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	-- signals from ADC_input to data_buffer
	SIGNAL buffer_full	: STD_LOGIC;
	SIGNAL HEADER_data	: HEADER_VECTOR;
	SIGNAL HEADER_we	: STD_LOGIC;
	SIGNAL ATWD_waddr	: STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL ATWD_wdata	: STD_LOGIC_VECTOR (9 downto 0);
	SIGNAL ATWD_we		: STD_LOGIC;
	SIGNAL FADC_waddr	: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL FADC_wdata	: STD_LOGIC_VECTOR (15 downto 0);
	SIGNAL FADC_we		: STD_LOGIC;
	
	-- signal from data_buffer to compression
	SIGNAL data_available	: STD_LOGIC;
	SIGNAL read_done_r	: STD_LOGIC;
	SIGNAL header_r		: HEADER_VECTOR;
	SIGNAL ATWD_raddr	: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL ATWD_rdata	: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL FADC_raddr	: STD_LOGIC_VECTOR (6 downto 0);
	SIGNAL FADC_rdata	: STD_LOGIC_VECTOR (31 downto 0);
	
	SIGNAL busy_int			: STD_LOGIC;
	SIGNAL busy_FADC_int	: STD_LOGIC;

BEGIN

	busy		<= busy_int;
	busy_FADC	<= busy_FADC_int;

-- ATWD and FADC input
	inst_ADC_input : ADC_input
		GENERIC MAP (
			FADC_WIDTH	=> FADC_WIDTH
			)
		PORT MAP (
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			systime		=> systime,
			-- enable
			busy			=> busy_int,
			busy_FADC		=> busy_FADC_int,
			ATWD_mode		=> ATWD_mode,
			LC_mode			=> LC_mode,
			DAQ_mode		=> DAQ_mode,
			ATWD_AB			=> ATWD_AB,
			ICETOP_ctrl		=> ICETOP_ctrl,
			-- some status bits
                        dead_flag               => dead_flag,
			SPE_level_stretch	=> SPE_level_stretch,
			-- trigger
			rst_trig		=> rst_trig,
			trigger_word	=> trigger_word,
			minimum_bias_hit	=> minimum_bias_hit,
			-- local coincidence
			LC_abort		=> LC_abort,
			LC				=> LC,
			-- ATWD
			ATWDTrigger		=> ATWDTrigger,
			TriggerComplete	=> TriggerComplete,
			OutputEnable	=> OutputEnable,
			CounterClock	=> CounterClock,
			RampSet			=> RampSet,
			ChannelSelect	=> ChannelSelect,
			ReadWrite		=> ReadWrite,
			AnalogReset		=> AnalogReset,
			DigitalReset	=> DigitalReset,
			DigitalSet		=> DigitalSet,
			ATWD_VDD_SUP	=> ATWD_VDD_SUP,
			ShiftClock		=> ShiftClock,
			ATWD_D			=> ATWD_D,
			-- ATWD pedestal
			ATWD_ped_data	=> ATWD_ped_data,
			ATWD_ped_addr	=> ATWD_ped_addr,
			-- FADC
			FADC_D			=> FADC_D,
			FADC_NCO		=> FADC_NCO,
			-- data output
			buffer_full	=> buffer_full,
			HEADER_data	=> HEADER_data,
			HEADER_we	=> HEADER_we,
			ATWD_addr	=> ATWD_waddr,
			ATWD_data	=> ATWD_wdata,
			ATWD_we		=> ATWD_we,
			FADC_addr	=> FADC_waddr,
			FADC_data	=> FADC_wdata,
			FADC_we		=> FADC_we,
			-- test connector
			TC			=> TC --open
		);
	
	
	inst_data_buffer : data_buffer
		GENERIC MAP (
			FADC_WIDTH	=> FADC_WIDTH
			)
		PORT MAP (
			CLK40		=> CLK40,
			RST			=> RST,
			-- data input
			HEADER_we	=> HEADER_we,
			header_w	=> HEADER_data,
			ATWD_waddr	=> ATWD_waddr,
			ATWD_wdata	=> ATWD_wdata,
			ATWD_we		=> ATWD_we,
			FADC_waddr	=> FADC_waddr,
			FADC_wdata	=> FADC_wdata,
			FADC_we		=> FADC_we,
			buffer_full	=> buffer_full,
			-- data output
			data_available	=> data_available,
			read_done	=> read_done_r,
			header_r	=> header_r,
			ATWD_raddr	=> ATWD_raddr,
			ATWD_rdata	=> ATWD_rdata,
			FADC_raddr	=> FADC_raddr,
			FADC_rdata	=> FADC_rdata,
			-- test connector
			TC			=> open
		);
	
	
	inst_compression : compression
		GENERIC MAP (
			FADC_WIDTH		=> FADC_WIDTH
			)
		PORT MAP (
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			RST			=> RST,
			-- enable
			COMPR_ctrl	=> COMPR_ctrl,
			-- data input from data buffer
			data_avail_in	=> data_available,
			read_done_in	=> read_done_r,
			HEADER_in		=> header_r,
			ATWD_addr_in	=> ATWD_raddr,
			ATWD_data_in	=> ATWD_rdata,
			FADC_addr_in	=> FADC_raddr,
			FADC_data_in	=> FADC_rdata,
			-- data output
			data_avail_out	=> data_avail,
			read_done_out	=> read_done,
			compr_avail_out	=> compr_avail,
			compr_size		=> compr_size,
			compr_addr		=> compr_addr,
			compr_data		=> compr_data,
			HEADER_out		=> HEADER,
			ATWD_addr_out	=> ATWD_addr,
			ATWD_data_out	=> ATWD_data,
			FADC_addr_out	=> FADC_addr,
			FADC_data_out	=> FADC_data,
			-- test connector
			TC			=> open
		);
		
	-- monitoring
	PP_status.busy			<= busy_int;
	PP_status.busy_FADC		<= busy_FADC_int;
	PP_status.buffer_full	<= buffer_full;
	
END arch_pingpong;
