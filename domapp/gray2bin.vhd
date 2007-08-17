--------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : gray2bin.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-08-28
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module a 10bit gray code vector into a 10bit binary vector
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-28  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY gray2bin IS
	port (
		gray	: IN STD_LOGIC_VECTOR (9 downto 0);
		bin		: OUT STD_LOGIC_VECTOR (9 downto 0)
	);
END gray2bin;


ARCHITECTURE arch_gray2bin OF gray2bin IS
BEGIN

	PROCESS (gray)
		VARIABLE  bin_sig :	STD_LOGIC_VECTOR (9 downto 0);
	BEGIN
		bin_sig(9) := gray(9);
		bin_sig(8) := gray(8) XOR bin_sig(9);
		bin_sig(7) := gray(7) XOR bin_sig(8);
		bin_sig(6) := gray(6) XOR bin_sig(7);
		bin_sig(5) := gray(5) XOR bin_sig(6);
		bin_sig(4) := gray(4) XOR bin_sig(5);
		bin_sig(3) := gray(3) XOR bin_sig(4);
		bin_sig(2) := gray(2) XOR bin_sig(3);
		bin_sig(1) := gray(1) XOR bin_sig(2);
		bin_sig(0) := gray(0) XOR bin_sig(1);
	
		bin <= bin_sig;
	END PROCESS;
	
END arch_gray2bin;