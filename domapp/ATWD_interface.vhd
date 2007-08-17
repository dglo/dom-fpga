-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ATWD_interface.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-10-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module interfaces the ATWD and provides the waveform data
-- in binary
-------------------------------------------------------------------------------
-- Copyright (c) 2003 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten
-------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY WORK;
USE WORK.constants.ALL;

ENTITY ATWD_interface IS
	PORT (
		CLK40			: IN STD_LOGIC;
		CLK80			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- control
		ATWD_enable		: IN STD_LOGIC;
		ATWD_busy		: OUT STD_LOGIC;
		ATWD_n_chan		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ATWD_mode		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		abort			: IN STD_LOGIC;
		-- some status bits
		--trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		forced_launch	: IN STD_LOGIC;
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
		-- pedestal interface
		ATWD_ped_data	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		ATWD_ped_addr	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		-- buffer interface
		ATWD_data		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		ATWD_addr		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		ATWD_we			: OUT STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END ATWD_interface;

ARCHITECTURE ATWD_interface_arch OF ATWD_interface IS

	-- ATWD_control
	COMPONENT ATWD_control IS
		PORT (
			CLK40		: IN STD_LOGIC;
			CLK80		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- control
			ATWD_busy	: OUT STD_LOGIC;
			ATWD_enable	: IN STD_LOGIC;
			ATWD_mode	: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			ATWD_n_chan	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			abort		: IN STD_LOGIC;
			-- some status bits
			--trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			forced_launch	: IN STD_LOGIC;
			-- atwd
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
			-- data
			ATWD_D_gray		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_D_addr		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			ATWD_D_we		: OUT STD_LOGIC;
			ATWD_D_bin		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	-- gray2bin
	COMPONENT gray2bin IS
		PORT (
			gray	: IN STD_LOGIC_VECTOR (9 downto 0);
			bin		: OUT STD_LOGIC_VECTOR (9 downto 0)
		);
	END COMPONENT;
	
	-- pedestal_sub
	COMPONENT pedestal_sub IS
		PORT (
			-- ATWD data
			ATWD_bin_data	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_bin_addr	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			ATWD_bin_we		: IN STD_LOGIC;
			-- Pedestal data
			ATWD_ped_data	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_ped_addr	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- 2 memory data
			ATWD_data		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_addr		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			ATWD_we			: OUT STD_LOGIC;
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
	END COMPONENT;
	
	SIGNAL ATWD_D_gray		: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL ATWD_D_addr		: STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL ATWD_D_we		: STD_LOGIC;
	SIGNAL ATWD_bin_data	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL ATWD_bin_addr	: STD_LOGIC_VECTOR (8 DOWNTO 0);

BEGIN

	-- ATWD_control
	inst_ATWD_control : ATWD_control
		PORT MAP (
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			-- control
			ATWD_busy	=> ATWD_busy,
			ATWD_enable	=> ATWD_enable,
			ATWD_mode	=> ATWD_mode,
			ATWD_n_chan	=> ATWD_n_chan,
			abort		=> abort,
			-- some status bits
			--trigger_word	=> trigger_word,
			forced_launch	=> forced_launch,
			-- atwd
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
			-- data
			ATWD_D_gray		=> ATWD_D_gray,
			ATWD_D_addr		=> ATWD_D_addr,
			ATWD_D_we		=> ATWD_D_we,
			ATWD_D_bin		=> ATWD_bin_data,
			-- test connector
			TC				=> open
		);

	-- gray2bin
	inst_gray2bin : gray2bin
		PORT MAP (
			gray	=> ATWD_D_gray,
			bin		=> ATWD_bin_data
		);

	
	-- pedestal_sub
	inst_pedestal_sub : pedestal_sub
		PORT MAP (
			-- ATWD data
			ATWD_bin_data	=> ATWD_bin_data,
			ATWD_bin_addr	=> ATWD_D_addr,
			ATWD_bin_we		=> ATWD_D_we,
			-- Pedestal data
			ATWD_ped_data	=> ATWD_ped_data,
			ATWD_ped_addr	=> ATWD_ped_addr,
			-- 2 memory data
			ATWD_data		=> ATWD_data,
			ATWD_addr		=> ATWD_addr,
			ATWD_we			=> ATWD_we,
			-- test connector
			TC				=> open
	);


END ATWD_interface_arch;