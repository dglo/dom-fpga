-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : hit_counter_ff.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module is a hitrate counter for the discriminator. This
--              module utilizes a (FF) latch inside the FPGA
--              the gate time is 0.1s
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

ENTITY hit_counter_ff IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- discriminator input
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		-- output
		multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END hit_counter_ff;

ARCHITECTURE arch_hit_counter_ff OF hit_counter_ff IS
	
	SIGNAL MultiSPE_latch	: STD_LOGIC;
	SIGNAL MultiSPE0	: STD_LOGIC;
	SIGNAL MultiSPE1	: STD_LOGIC;
	SIGNAL MultiSPE2	: STD_LOGIC;
	SIGNAL OneSPE_latch		: STD_LOGIC;
	SIGNAL OneSPE0		: STD_LOGIC;
	SIGNAL OneSPE1		: STD_LOGIC;
	SIGNAL OneSPE2		: STD_LOGIC;
	
BEGIN
	
	PROCESS(RST, CLK)
		VARIABLE cnt100ms	: integer;
		VARIABLE multiSPEcnt_int	: STD_LOGIC_VECTOR (15 downto 0);
		VARIABLE oneSPEcnt_int		: STD_LOGIC_VECTOR (15 downto 0);
	BEGIN
		IF RST='1' THEN
			cnt100ms	:= 2000000;
			MultiSPE1	<= '1';
			OneSPE1		<= '1';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF cnt100ms = 0 THEN
				multiSPEcnt	<= multiSPEcnt_int;
				oneSPEcnt	<= oneSPEcnt_int;
				cnt100ms	:= 2000000;
				multiSPEcnt_int	:= (others=>'0');
				oneSPEcnt_int	:= (others=>'0');
			ELSE
				cnt100ms	:= cnt100ms - 1;
				
				IF MultiSPE2='0' AND MultiSPE1='1' THEN
					multiSPEcnt_int	:= multiSPEcnt_int+1;
				END IF;
				IF OneSPE2='0' AND OneSPE1='1' THEN
					oneSPEcnt_int	:= oneSPEcnt_int+1;
				END IF;
				
			END IF;
			
			MultiSPE2	<= MultiSPE1;
			MultiSPE1	<= MultiSPE0;
			MultiSPE0	<= MultiSPE_latch;
			OneSPE2		<= OneSPE1;
			OneSPE1		<= OneSPE0;
			OneSPE0		<= OneSPE_latch;
		END IF;
	END PROCESS;
	
	
	PROCESS(OneSPE,OneSPE1)
	BEGIN
		IF OneSPE1='1' THEN
			OneSPE_latch	<= '0';
		ELSIF OneSPE'EVENT AND OneSPE='1' THEN
			OneSPE_latch	<= '1';
		END IF;
	END PROCESS;
	
	PROCESS(MultiSPE,MultiSPE1)
	BEGIN
		IF MultiSPE1='1' THEN
			MultiSPE_latch	<= '0';
		ELSIF MultiSPE'EVENT AND MultiSPE='1' THEN
			MultiSPE_latch	<= '1';
		END IF;
	END PROCESS;
	
END;