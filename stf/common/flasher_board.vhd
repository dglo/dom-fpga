-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : flasher_board.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module interfaces the flasher board
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-------------------------------------------------------------------------------

library IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY flasher_board IS
	PORT (
		CLK					: IN STD_LOGIC;
		RST					: IN STD_LOGIC;
		-- enable flasher board flash
		enable				: IN STD_LOGIC;
		-- control input
		fl_board			: IN STD_LOGIC_VECTOR(7 downto 0);
		fl_board_read		: OUT STD_LOGIC_VECTOR(1 downto 0);
		-- ATWD trigger
		trigLED		: OUT STD_LOGIC;
		-- flasher board
		FL_Trigger			: OUT STD_LOGIC;
		FL_Trigger_bar		: OUT STD_LOGIC;
		FL_ATTN				: IN STD_LOGIC;
		FL_PRE_TRIG			: OUT STD_LOGIC;
		FL_TMS				: OUT STD_LOGIC;
		FL_TCK				: OUT STD_LOGIC;
		FL_TDI				: OUT STD_LOGIC;
		FL_TDO				: IN STD_LOGIC;
		-- Test connector
		TC					: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END flasher_board;

ARCHITECTURE flasher_board_arch OF flasher_board IS
	SIGNAL LEDdelay		: STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
--	FL_Trigger		<= fl_board(0);
--	FL_Trigger_bar	<= NOT fl_board(0);
	--FL_ATTN			<= fl_board(1);
	fl_board_read(0)	<= FL_ATTN;
	FL_PRE_TRIG		<= fl_board(2); -- now called AUX_RESET
	
	
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
			FL_Trigger	<= '0';
			FL_Trigger_bar	<= '1';
			trigLED		<= '0';
			LEDdelay	<= (OTHERS=>'0');
		ELSIF CLK'EVENT AND CLK='1' THEN
			tick_old	:= tick;
			tick		:= cnt(15) XOR cnt_old(15);
			cnt_old		:= cnt;
			-- SingleLED_TRIGGER	<= tick OR tick_old;
			trigLED	<= tick OR tick_old;
			FL_Trigger	<= LEDdelay(3);		-- delay the LED flash to allow the ATWD to launch and capture the current in channel 3
			FL_Trigger_bar	<= NOT LEDdelay(3);
			LEDdelay(3 DOWNTO 1)	<= LEDdelay(2 DOWNTO 0);
			LEDdelay(0)		<= tick OR tick_old;
			IF enable='0' THEN
				cnt	:= (others=>'0');
			ELSE
				cnt	:= cnt + 1;
			END IF;
		END IF;
	END PROCESS;
	
	
	-- JTAG
	FL_TMS			<= fl_board(4) WHEN fl_board(7)='1' ELSE 'Z';
	FL_TCK			<= fl_board(5) WHEN fl_board(7)='1' ELSE 'Z';
	FL_TDI			<= fl_board(6) WHEN fl_board(7)='1' ELSE 'Z';
	--FL_TDO			<= fl_board(7);
	fl_board_read(1)	<= FL_TDO;
END flasher_board_arch;
