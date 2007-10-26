-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : data_buffer.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-08-25
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module bufferes the incomming ADC (FADC abd ATWD) data for
--              for the compression and engineering events
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-25  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY data_buffer IS
	GENERIC (
		FADC_WIDTH		: INTEGER := 10
		);
	PORT (
		CLK40		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable
		enable		: IN STD_LOGIC;
		enable_disc	: IN STD_LOGIC;
		done		: OUT STD_LOGIC;
		-- data input
		header
		ATWD_addr	: IN STD_LOGIC_VECTOR (8 downto 0);
		ATWD_data	: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWD_we		: IN STD_LOGIC;
		FADC_addr	: IN STD_LOGIC_VECTOR (7 downto 0);
		FADC_data	: IN STD_LOGIC_VECTOR (FADC_WIDTH-1 downto 0);
		FADC_we		: IN STD_LOGIC;
		-- data output
		header
		ATWD_addr	: IN STD_LOGIC_VECTOR (8 downto 0);
		ATWD_data	: OUT STD_LOGIC_VECTOR (9 downto 0);
		FADC_addr	: IN STD_LOGIC_VECTOR (7 downto 0);
		FADC_data	: OUT STD_LOGIC_VECTOR (FADC_WIDTH-1 downto 0);
		-- test connector
		TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END data_buffer;


ARCHITECTURE arch_data_buffer OF data_buffer IS

			
BEGIN
	

	
END;