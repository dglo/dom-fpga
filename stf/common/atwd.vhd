-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : atwd.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003/08/01
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this is the main ATWD code module. It does the triggering of
-- the ATWD, holds the buffer memory and call the modules for triggering,
-- control and readout.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY atwd IS
	PORT (
		CLK20		: IN STD_LOGIC;
		CLK40		: IN STD_LOGIC;
		CLK80		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable
		enable		: IN STD_LOGIC;
		enable_disc	: IN STD_LOGIC;
		enable_LED	: IN STD_LOGIC;
		done		: OUT STD_LOGIC;
		-- disc
		OneSPE		: IN STD_LOGIC;
		LEDtrig		: IN STD_LOGIC;
		-- stripe interface
		wdata		: IN STD_LOGIC_VECTOR (15 downto 0);
		rdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
		address		: IN STD_LOGIC_VECTOR (8 downto 0);
		write_en	: IN STD_LOGIC;
		-- atwd
		ATWD_D			: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWDTrigger		: OUT STD_LOGIC;
		TriggerComplete	: IN STD_LOGIC;
		OutputEnable	: OUT STD_LOGIC;
		CounterClock	: OUT STD_LOGIC;
		ShiftClock		: OUT STD_LOGIC;
		RampSet			: OUT STD_LOGIC;
		ChannelSelect	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite		: OUT STD_LOGIC;
		AnalogReset		: OUT STD_LOGIC;
		DigitalReset	: OUT STD_LOGIC;
		DigitalSet		: OUT STD_LOGIC;
		ATWD_VDD_SUP	: OUT STD_LOGIC;
        -- for ping-pong
        atwd_trig_doneB	: OUT STD_LOGIC;        
		-- frontend pulser
		FE_pulse			: IN STD_LOGIC := '0';
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END atwd;


ARCHITECTURE arch_atwd OF atwd IS
	
	SIGNAL wraddress_sig	: STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL wraddress		: STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL data_sig			: STD_LOGIC_VECTOR (15 downto 0);
	SIGNAL wren				: STD_LOGIC;
	SIGNAL wren_sig			: STD_LOGIC;
	SIGNAL rden_sig			: STD_LOGIC;
	
	SIGNAL start_readout	: STD_LOGIC;
	SIGNAL readout_done		: STD_LOGIC;
	
	SIGNAL reset_trig		: STD_LOGIC;
	SIGNAL busy				: STD_LOGIC;
	SIGNAL ATWDTrigger_sig	: STD_LOGIC;
	SIGNAL TriggerComplete_out	: STD_LOGIC;

	SIGNAL ATWD_D_gray		: STD_LOGIC_VECTOR(9 downto 0);
	-- to mem
	SIGNAL ATWD_D_bin		: STD_LOGIC_VECTOR(9 downto 0);
	SIGNAL ATWD_addr		: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL ATWD_write		: STD_LOGIC;

	COMPONENT atwd_control
		PORT (
			CLK20		: IN STD_LOGIC;
			CLK40		: IN STD_LOGIC;
			CLK80		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- trigger interface
			busy		: OUT STD_LOGIC;
			reset_trig	: OUT STD_LOGIC;
			-- handshake to readout
			start_readout	: OUT STD_LOGIC;
			readout_done	: IN STD_LOGIC;
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
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT atwd_readout
		PORT (
			CLK20			: IN STD_LOGIC;
			CLK40			: IN STD_LOGIC;
			CLK80			: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			-- handshake to control
			start_readout	: IN STD_LOGIC;
			readout_done	: OUT STD_LOGIC;
			busy			: IN STD_LOGIC;
			-- ATWD
			ATWD_D			: IN STD_LOGIC_VECTOR(9 downto 0);
			ShiftClock		: OUT STD_LOGIC;
			-- signal to mem control
			ATWD_D_gray		: OUT STD_LOGIC_VECTOR(9 downto 0);
			addr			: OUT STD_LOGIC_VECTOR(8 downto 0);
			data_valid		: OUT STD_LOGIC;
			-- test connector
			TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT gray2bin
		port (
			gray	: IN STD_LOGIC_VECTOR (9 downto 0);
			bin		: OUT STD_LOGIC_VECTOR (9 downto 0)
		);
	END COMPONENT;
	
	COMPONENT atwd_trigger
		PORT (
			CLK20		: IN STD_LOGIC;
			CLK40		: IN STD_LOGIC;
			CLK80		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable
			enable		: IN STD_LOGIC;
			enable_disc	: IN STD_LOGIC;
			enable_LED	: IN STD_LOGIC;
			done		: OUT STD_LOGIC;
			-- controller
			busy		: IN STD_LOGIC;
			reset_trig	: IN STD_LOGIC;
			-- disc
			OneSPE		: IN STD_LOGIC;
			LEDtrig		: IN STD_LOGIC;
			-- atwd
			ATWDTrigger			: OUT STD_LOGIC;
			TriggerComplete_in	: IN STD_LOGIC;
			TriggerComplete_out	: OUT STD_LOGIC;
			-- frontend pulser
			FE_pulse			: IN STD_LOGIC := '0';
			-- test connector
			TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;



		
	COMPONENT com_adc_mem
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wraddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			rdaddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			wren		: IN STD_LOGIC  := '1';
			rden	 	: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;
	
BEGIN
	
	inst_atwd_control : atwd_control
		PORT MAP (
			CLK20			=> CLK20,
			CLK40			=> CLK40,
			CLK80			=> CLK80,
			RST				=> RST,
			-- trigger interface
			busy			=> busy,
			reset_trig		=> reset_trig,
			-- handshake to readout
			start_readout	=> start_readout,
			readout_done	=> readout_done,
			-- atwd
			ATWDTrigger		=> ATWDTrigger_sig,
			TriggerComplete	=> TriggerComplete_out,
			OutputEnable	=> OutputEnable,
			CounterClock	=> CounterClock,
			RampSet			=> RampSet,
			ChannelSelect	=> ChannelSelect,
			ReadWrite		=> ReadWrite,
			AnalogReset		=> AnalogReset,
			DigitalReset	=> DigitalReset,
			DigitalSet		=> DigitalSet,
			ATWD_VDD_SUP	=> ATWD_VDD_SUP,
			-- test connector
			TC				=> open
		);
		
	inst_atwd_readout : atwd_readout
		PORT MAP (
			CLK20			=> CLK20,
			CLK40			=> CLK40,
			CLK80			=> CLK80,
			RST				=> RST,
			-- handshake to control
			start_readout	=> start_readout,
			readout_done	=> readout_done,
			busy			=> busy,
			-- ATWD
			ATWD_D			=> ATWD_D,
			ShiftClock		=> ShiftClock,
			-- signal to mem control
			ATWD_D_gray		=> ATWD_D_gray,
			addr			=> ATWD_addr,
			data_valid		=> ATWD_write,
			-- test connector
			TC				=> open
		);
		
	inst_gray2bin : gray2bin
		port MAP (
			gray	=> ATWD_D_gray,
			bin		=> ATWD_D_bin
		);
		
	inst_atwd_trigger : atwd_trigger
		PORT MAP (
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			-- enable
			enable		=> enable,
			enable_disc	=> enable_disc,
			enable_LED	=> enable_LED,
			done		=> done,
			-- controller
			busy		=> busy,
			reset_trig	=> reset_trig,
			-- disc
			OneSPE		=> OneSPE,
			LEDtrig		=> LEDtrig,
			-- atwd
			ATWDTrigger			=> ATWDTrigger_sig,
			TriggerComplete_in	=> TriggerComplete,
			TriggerComplete_out	=> TriggerComplete_out,
			-- frontend pulser
			FE_pulse			=> FE_pulse,
			-- test connector
			TC					=> open
		);
	
	ATWDTrigger	<= ATWDTrigger_sig;
	
	
	data_sig(9 downto 0)	<= ATWD_D_bin WHEN write_en='0' ELSE wdata(9 downto 0);
	data_sig(15 downto 10)	<= (others=>'0') WHEN write_en='0' ELSE wdata(15 downto 10);
	wraddress_sig	<= ATWD_addr WHEN write_en='0' ELSE address;
	wren_sig		<= ATWD_write WHEN write_en='0' ELSE write_en;
	
	rden_sig		<= '1';

    atwd_trig_doneB <= TriggerComplete_out;
    
	inst_com_adc_mem : com_adc_mem
		PORT MAP (
			data		=> data_sig,
			wraddress	=> wraddress_sig,
			rdaddress	=> address,
			wren		=> wren_sig,
			rden		=> rden_sig,
			clock		=> CLK40,
			q	 		=> rdata
		);

END;
