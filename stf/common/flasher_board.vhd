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


ENTITY flasher_board IS
	PORT (
		-- control input
		fl_board			: IN STD_LOGIC_VECTOR(7 downto 0);
		fl_board_read		: OUT STD_LOGIC_VECTOR(1 downto 0);
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
BEGIN
	FL_Trigger		<= fl_board(0);
	FL_Trigger_bar	<= NOT fl_board(0);
	--FL_ATTN			<= fl_board(1);
	fl_board_read(0)	<= FL_ATTN;
	FL_PRE_TRIG		<= fl_board(2);
	
	FL_TMS			<= fl_board(4);
	FL_TCK			<= fl_board(5);
	FL_TDI			<= fl_board(6);
	--FL_TDO			<= fl_board(7);
	fl_board_read(1)	<= FL_TDO;
END flasher_board_arch;
