-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : constants.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-08-29
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This package contain constants for DOMAPP
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-29  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

PACKAGE constants IS

	-- SDRAM look back memory
	CONSTANT SDRAM_SIZE			: INTEGER := 24;	-- log2(size in bytes)
	CONSTANT SDRAM_MASK			: STD_LOGIC_VECTOR (31 DOWNTO 0) := CONV_STD_LOGIC_VECTOR((2**SDRAM_SIZE)-1-3,32);
	CONSTANT SDRAM_BASE			: STD_LOGIC_VECTOR (31 DOWNTO 0) := X"01000000";

	-- ATWD modes
	CONSTANT ATWD_mode_ALL		: STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT ATWD_mode_NORMAL	: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";

	CONSTANT ov_threshold		: STD_LOGIC_VECTOR (9 DOWNTO 0) := "1110000000";
	
	-- daq mode
	CONSTANT ATWD_FADC			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	CONSTANT FADC_ONLY			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT TIMESTAMP			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
	
	-- local coincidence
	CONSTANT LC_OFF				: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	CONSTANT LC_SOFT			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT LC_HARD			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
	CONSTANT LC_FLABBY			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";
	
	-- compression mode
	CONSTANT COMPR_OFF			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	CONSTANT COMPR_ON			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT COMPR_BOTH			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
	
	-- LBM mode
	CONSTANT LBM_WRAP			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	CONSTANT LBM_STOP			: STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	
	
	CONSTANT eventEngineering	: STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT eventCompressed	: STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
	CONSTANT eventTimestamp		: STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";

	
END constants;