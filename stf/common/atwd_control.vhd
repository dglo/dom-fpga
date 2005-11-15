-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : atwd_control.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-03-25
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module does all the ATWD timing except triggering and
--              readout
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-- 2004-10-22              thorsten  added LC_abort
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY atwd_control IS
	PORT (
		CLK20		: IN STD_LOGIC;
		CLK40		: IN STD_LOGIC;
		CLK80		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- trigger interface
		busy		: OUT STD_LOGIC;
		reset_trig	: OUT STD_LOGIC;
		-- LC interface
		LC_abort	: IN STD_LOGIC := '0';
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
END atwd_control;


ARCHITECTURE arch_atwd_control OF atwd_control IS
	
	TYPE ATWD_state_type is (ATWDrecover, digitize, idle, init_digitize, next_channel, power_up_init1, power_up_init2, readout, readout_end, restart_ATWD, settle, wait_trig_compl);
	SIGNAL state	: ATWD_state_type;
	
	SIGNAL settle_cnt	: INTEGER;
	SIGNAL digitize_cnt	: INTEGER;
	SIGNAL channel		: STD_LOGIC_VECTOR (1 downto 0);
	SIGNAL counterclk_low	: STD_LOGIC;
	SIGNAL counterclk_high	: STD_LOGIC;
	
BEGIN
	
	ATWD_VDD_SUP	<= '1';
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			state	<= power_up_init1;
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			CASE state IS
				WHEN power_up_init1 =>
					state	<= power_up_init2;
					
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					RampSet			<= '1';
					ReadWrite		<= '0';
					AnalogReset		<= '1';
					channel			<= "00";
					OutputEnable	<= '0';
					
					busy			<= '1';
					start_readout	<= '0';
					reset_trig		<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
					
				WHEN power_up_init2 =>
					state	<= idle;
					DigitalReset	<= '0';
				WHEN idle =>
					IF ATWDTrigger='1' THEN
						state	<= wait_trig_compl;
					END IF;
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					channel			<= "00";
					
					busy			<= '0';
					reset_trig		<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
				WHEN wait_trig_compl =>
					IF TriggerComplete='0' THEN
						state	<= init_digitize;
					END IF;
					busy			<= '1';
				WHEN init_digitize =>
					state	<= settle;
					AnalogReset		<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
					settle_cnt		<= 0;
					digitize_cnt	<= 1;
				WHEN settle =>
					IF settle_cnt=128 THEN
						state	<= digitize;
					END IF;
					ReadWrite	<= '1';
					settle_cnt	<= settle_cnt+1;
				WHEN digitize =>
					IF digitize_cnt=512 THEN
						state	<= readout;
					END IF;
					DigitalReset	<= '0';
					RampSet			<= '0';
					counterclk_low	<= '0';
					counterclk_high	<= '0';
					digitize_cnt	<= digitize_cnt + 1;
				WHEN readout =>
					IF readout_done='1' THEN
						state	<= readout_end;
					END IF;
					DigitalSet		<= '1';
					RampSet			<= '1';
					AnalogReset		<= '1';
					OutputEnable	<= '1';
					start_readout	<= '1';
					counterclk_low	<= '0';
					counterclk_high	<= '1';
				WHEN readout_end =>
					IF channel="11" THEN
						state	<= restart_ATWD;
					ELSE
						state	<= next_channel;
					END IF;
					DigitalSet		<= '1';
					RampSet			<= '1';
					AnalogReset		<= '1';
					OutputEnable	<= '0';
					start_readout	<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
				WHEN next_channel =>
					state	<= init_digitize;
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					ReadWrite		<= '0';
					AnalogReset		<= '1';
					channel			<= channel + 1;
				WHEN restart_ATWD =>
					IF TriggerComplete='1' THEN
						state	<= ATWDrecover;
					END IF;
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					ReadWrite		<= '0';
					AnalogReset		<= '1';
					RampSet			<= '1';
					OutputEnable	<= '0';
					channel			<= "00";
					reset_trig		<= '1';
				WHEN ATWDrecover =>
					state	<= idle;
			END CASE;
			
			-- LC abort (goto restart ATWD)
			IF LC_abort = '1' THEN
				state	<= restart_ATWD;
			END IF;
		END IF;
	END PROCESS;
	
	ChannelSelect	<= channel;
	
	PROCESS(CLK80,RST)
		VARIABLE	cclk	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			CounterClock	<= '0';
		ELSIF CLK80'EVENT AND CLK80='1' THEN
			IF counterclk_high='1' THEN
				cclk	:= '1';
			ELSIF counterclk_low='1' THEN
				cclk	:= '0';
			ELSE
				cclk	:= NOT cclk;
			END IF;
			CounterClock	<= cclk;
		END IF;
	END PROCESS;
	
END;
