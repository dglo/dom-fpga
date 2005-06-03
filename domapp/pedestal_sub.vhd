-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : pedestal_sub.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-08-28
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module subtracts the pedestal from the ATWD data
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-28  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY pedestal_sub IS
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
END pedestal_sub;


ARCHITECTURE arch_pedestal_sub OF pedestal_sub IS
	
BEGIN

	-- subtract pedestal
	-- ATWD_data	<= ATWD_bin_data - ATWD_ped_data;
	ATWD_data	<= ATWD_bin_data - ATWD_ped_data WHEN ATWD_bin_data > ATWD_ped_data ELSE (OTHERS=>'0');
	-- route address out
	ATWD_ped_addr	<= ATWD_bin_addr;
	ATWD_addr		<= ATWD_bin_addr;
	-- route write enable through
	ATWD_we	<= ATWD_bin_we;
	
END;
