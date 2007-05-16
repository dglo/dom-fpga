-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ADC_input.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-03-22
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module holds the code for the ADCs (FADC and ATWD) and
--              presents the data to the data buffer
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-26  V01-01-00   thorsten  
-- 2007-03-22              thorsten  added ATWD dead flag
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE WORK.ctrl_data_types.all;
USE WORK.icecube_data_types.all;


ENTITY ADC_input IS
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
                dead_flag               : OUT STD_LOGIC;
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
END ADC_input;


ARCHITECTURE arch_ADC_input OF ADC_input IS

	-- ATWD_interface
	COMPONENT ATWD_interface IS
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
			trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
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
	END COMPONENT;

	-- FADC_interface
	COMPONENT FADC_interface IS
		GENERIC (
			FADC_WIDTH		: INTEGER := 10
		);
		PORT (
			CLK40			: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			-- enable
			FADC_enable		: IN STD_LOGIC;
			FADC_busy		: OUT STD_LOGIC;
			abort			: IN STD_LOGIC;
			trigger			: IN STD_LOGIC;
			-- FADC
			FADC_D			: IN STD_LOGIC_VECTOR (FADC_WIDTH-1 DOWNTO 0);
			FADC_NCO		: IN STD_LOGIC;
			-- buffer interface
			FADC_data		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			FADC_addr		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			FADC_we			: OUT STD_LOGIC;
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	-- ADC_control
	COMPONENT ADC_control IS
		PORT (
			CLK40		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			systime		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			-- enable
			busy		: OUT STD_LOGIC;
			lc_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			daq_mode	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			ATWD_AB		: IN STD_LOGIC;	-- indicates if ping or pong
			abort_ATWD	: OUT STD_LOGIC;
			abort_FADC	: OUT STD_LOGIC;
                        dead_flag       : OUT STD_LOGIC;
			-- trigger
			ATWDtrigger		: IN STD_LOGIC;
			rst_trig		: OUT STD_LOGIC;
			TriggerComplete	: IN STD_LOGIC;
			trigger_word	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			-- local coincidence
			LC_abort		: IN STD_LOGIC;
			LC				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- calibration sources
			-- ATWD
			ATWD_enable	: OUT STD_LOGIC;
			ATWD_busy	: IN STD_LOGIC;
			ATWD_n_chan	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			-- FADC
			FADC_enable	: OUT STD_LOGIC;
			FADC_busy	: IN STD_LOGIC;
			-- data output
			buffer_full	: IN STD_LOGIC;
			HEADER_data	: OUT HEADER_VECTOR;
			HEADER_we	: OUT STD_LOGIC;
			-- test connector
			TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	-- chargestamp
	COMPONENT chargestamp IS
	    GENERIC (
	        FADC_WIDTH : INTEGER := 10
	    );
	    PORT (
	        CLK40       : IN  STD_LOGIC;
	        RST         : IN  STD_LOGIC;
	        systime     : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
	        -- FADC
	        busy_FADC   : IN  STD_LOGIC;
	        FADC_D      : IN  STD_LOGIC_VECTOR (FADC_WIDTH-1 DOWNTO 0);
	        FADC_NCO    : IN  STD_LOGIC;
	        FADC_addr   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
	        -- charege
	        chargestamp : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	        -- test connector
	        TC          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
	END COMPONENT;
	
	-- ATWD chargestamp for IceTop
	COMPONENT icetop_atwd_charge IS
		PORT (
			CLK         : IN  STD_LOGIC;
			RST         : IN  STD_LOGIC;
			-- setup
			channel_sel : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			-- ATWD data
			busy        : IN  STD_LOGIC;
			ATWD_WE     : IN  STD_LOGIC;
			ATWD_data   : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWD_addr   : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
			-- charge
			charge      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			-- test connector
			TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL ATWD_enable	: STD_LOGIC;
	SIGNAL ATWD_busy	: STD_LOGIC;
	SIGNAL ATWD_n_chan	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL FADC_enable	: STD_LOGIC;
	SIGNAL FADC_busy	: STD_LOGIC;
	SIGNAL abort_ATWD	: STD_LOGIC;
	SIGNAL abort_FADC	: STD_LOGIC;
	
	SIGNAL TriggerComplete_sync	: STD_LOGIC;
	
	-- chargestamp
	SIGNAL HEADER_data_int	: HEADER_VECTOR;
	SIGNAL charge_stamp		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL FADC_addr_int	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	
	-- ATWD chargestamp for IceTop
	SIGNAL ATWD_addr_int	: STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL ATWD_data_int	: STD_LOGIC_VECTOR (9 downto 0);
	SIGNAL ATWD_we_int		: STD_LOGIC;
	SIGNAL icetop_charge	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
BEGIN

-- debugging
	TC(0)	<= ATWD_busy;
	TC(1)	<= FADC_busy;


	busy_FADC	<= FADC_busy;

	PROCESS (CLK40, RST)
		VARIABLE	TrigC	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			TriggerComplete_sync <= '1';
			TrigC := '1';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			TriggerComplete_sync <= TrigC;
			TrigC	:= TriggerComplete;
		END IF;
	END PROCESS;

	-- ATWD_interface
	inst_ATWD_interface : ATWD_interface
		PORT MAP (
			CLK40			=> CLK40,
			CLK80			=> CLK80,
			RST				=> RST,
			-- control
			ATWD_enable		=> ATWD_enable,
			ATWD_busy		=> ATWD_busy,
			ATWD_n_chan		=> ATWD_n_chan,
			ATWD_mode		=> ATWD_mode,
			abort			=> abort_ATWD,
			trigger_word	=> trigger_word,
			-- ATWD
			ATWDTrigger		=> ATWDTrigger,
			TriggerComplete	=> TriggerComplete_sync,
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
			-- pedestal interface
			ATWD_ped_data	=> ATWD_ped_data,
			ATWD_ped_addr	=> ATWD_ped_addr,
			-- buffer interface
			ATWD_data		=> ATWD_data_int,
			ATWD_addr		=> ATWD_addr_int,
			ATWD_we			=> ATWD_we_int,
			-- test connector
			TC				=> open
		);
	
	-- FADC_interface
	inst_FADC_interface : FADC_interface
		GENERIC MAP (
			FADC_WIDTH		=> FADC_WIDTH
		)
		PORT MAP (
			CLK40			=> CLK40,
			RST				=> RST,
			-- enable
			FADC_enable		=> FADC_enable,
			FADC_busy		=> FADC_busy,
			abort			=> abort_FADC,
			trigger			=> ATWDTrigger,
			-- FADC
			FADC_D			=> FADC_D,
			FADC_NCO		=> FADC_NCO,
			-- buffer interface
			FADC_data		=> FADC_data,
			FADC_addr		=> FADC_addr_int,
			FADC_we			=> FADC_we,
			-- test connector
			TC				=> open
		);
	
	-- ADC_control
	inst_ADC_control : ADC_control
		PORT MAP (
			CLK40		=> CLK40,
			RST			=> RST,
			systime		=> systime,
			-- enable
			busy		=> busy,
			lc_mode		=> LC_mode,
			daq_mode	=> DAQ_mode,
			ATWD_AB		=> ATWD_AB,
			abort_ATWD	=> abort_ATWD,
			abort_FADC	=> abort_FADC,
                        dead_flag       => dead_flag,
			-- trigger
			ATWDtrigger		=> ATWDTrigger,
			rst_trig		=> rst_trig,
			TriggerComplete	=> TriggerComplete_sync,
			trigger_word	=> trigger_word,
			-- local coincidence
			LC_abort		=> LC_abort,
			LC				=> LC,	
			-- calibration sources
			-- ATWD
			ATWD_enable	=> ATWD_enable,
			ATWD_busy	=> ATWD_busy,
			ATWD_n_chan	=> ATWD_n_chan,
			-- FADC
			FADC_enable	=> FADC_enable,
			FADC_busy	=> FADC_busy,
			-- data output
			buffer_full	=> buffer_full,
			HEADER_data	=> HEADER_data_int,
			HEADER_we	=> HEADER_we,
			-- test connector
			TC			=> open
		);
		
	-- chargestamp
	inst_chargestamp : chargestamp
	    GENERIC MAP (
	        FADC_WIDTH => FADC_WIDTH
	    )
	    PORT MAP (
	        CLK40       => CLK40,
	        RST         => RST,
	        systime     => systime,
	        -- FADC
	        busy_FADC   => FADC_busy,
	        FADC_D      => FADC_D,
	        FADC_NCO    => FADC_NCO,
	        FADC_addr   => FADC_addr_int,
	        -- charege
	        chargestamp => charge_stamp,
	        -- test connector
	        TC          => open
        );
	FADC_addr <= FADC_addr_int;
	
	-- ATWD chargestamp for IceTop
	inst_icetop_atwd_charge : icetop_atwd_charge
		PORT MAP (
			CLK         => CLK40,
			RST         => RST,
			-- setup
			channel_sel => ICETOP_ctrl.IT_atwd_charge_chan,
			-- ATWD data
			busy        => ATWD_busy,
			ATWD_WE     => ATWD_we_int,
			ATWD_data   => ATWD_data_int,
			ATWD_addr   => ATWD_addr_int,
			-- charge
			charge      => icetop_charge,
			-- test connector
			TC          => OPEN
		);
		
	ATWD_we		<= ATWD_we_int;
	ATWD_data	<= ATWD_data_int;
	ATWD_addr	<= ATWD_addr_int;
	
	PROCESS(HEADER_data_int,charge_stamp)
	BEGIN
		HEADER_data				<= HEADER_data_int;
		IF ICETOP_ctrl.IceTop_mode = '0' THEN
			HEADER_data.chargestamp	<= charge_stamp;
		ELSE
			HEADER_data.chargestamp	<= icetop_charge;
		END IF;
	END PROCESS;
		
END;
