-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : single_led.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module triggers the onboard LED
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten
-- 2003-11-13              thorsten  added early ATWD trigger for the current monitor 
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY single_led IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable flasher
		enable		: IN STD_LOGIC;
		-- LED trigger
		SingleLED_TRIGGER	: OUT STD_LOGIC;
		-- ATWD trigger
		trigLED		: OUT STD_LOGIC
	);
END single_led;


ARCHITECTURE single_led_arch OF single_led IS
	
	SIGNAL LEDdelay		: STD_LOGIC_VECTOR (3 DOWNTO 0);
	
BEGIN

	PROCESS (RST,CLK)
		VARIABLE cnt		: STD_LOGIC_VECTOR(15 downto 0);
		VARIABLE cnt_old	: STD_LOGIC_VECTOR(15 downto 0);
		VARIABLE tick		: STD_LOGIC;
		VARIABLE tick_old	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			cnt			:= (others=>'0');
			cnt_old		:= (others=>'0');
			tick		:= '0';
			tick_old	:= '0';
			SingleLED_TRIGGER	<= '0';
			trigLED		<= '0';
			LEDdelay	<= (OTHERS=>'0');
		ELSIF CLK'EVENT AND CLK='1' THEN
			tick_old	:= tick;
			tick		:= cnt(15) XOR cnt_old(15);
			cnt_old		:= cnt;
			-- SingleLED_TRIGGER	<= tick OR tick_old;
			trigLED	<= tick OR tick_old;
			SingleLED_TRIGGER	<= LEDdelay(3);		-- delay the LED flash to allow the ATWD to launch and capture the current in channel 3
			LEDdelay(3 DOWNTO 1)	<= LEDdelay(2 DOWNTO 0);
			LEDdelay(0)		<= tick OR tick_old;
			IF enable='0' THEN
				cnt	:= (others=>'0');
			ELSE
				cnt	:= cnt + 1;
			END IF;
		END IF;
	END PROCESS;

END;
