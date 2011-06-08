------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : icecube_data_types.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-09-02
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This package contain constants for DOMAPP
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-09-02  V01-01-00   thorsten  
-- 2005-05-11              thorsten  added "charge stamp"
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE icecube_data_types IS

	-- ATWD data header data type
	TYPE HEADER_VECTOR IS
		RECORD
			timestamp		: STD_LOGIC_VECTOR (47 DOWNTO 0);
			trigger_word	: STD_LOGIC_VECTOR (15 DOWNTO 0);
			eventtype		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			ATWD_AB			: STD_LOGIC;
			ATWDavail		: STD_LOGIC;
			FADCavail		: STD_LOGIC;
			ATWDsize		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			LC				: STD_LOGIC_VECTOR (1 DOWNTO 0);
			deadtime		: STD_LOGIC_VECTOR (15 DOWNTO 0);
			chargestamp		: STD_LOGIC_VECTOR (31 DOWNTO 0);
			forced_launch	: STD_LOGIC;
			ATWD_disc_status	: STD_LOGIC_VECTOR (1 DOWNTO 0);
			minimum_bias_hit	: STD_LOGIC;
		END RECORD;
	
	
END icecube_data_types;