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
		-- setup
		gatetime	: IN STD_LOGIC := '0';
		deadtime	: IN STD_LOGIC_VECTOR (3 DOWNTO 0); 
		-- discriminator input
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		-- output
		multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		-- frontend pulser
		FE_pulse		: IN STD_LOGIC;
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END hit_counter_ff;

ARCHITECTURE arch_hit_counter_ff OF hit_counter_ff IS
	
	SIGNAL MultiSPE_latch	: STD_LOGIC;
	SIGNAL MultiSPE0	: STD_LOGIC;
	SIGNAL MultiSPE1	: STD_LOGIC;
	SIGNAL MultiSPE2	: STD_LOGIC;
	SIGNAL MultiSPErst	: STD_LOGIC;
	SIGNAL OneSPE_latch	: STD_LOGIC;
	SIGNAL OneSPE0		: STD_LOGIC;
	SIGNAL OneSPE1		: STD_LOGIC;
	SIGNAL OneSPE2		: STD_LOGIC;
	SIGNAL OneSPErst	: STD_LOGIC;
	
	SIGNAL blank_disc	: STD_LOGIC;
	SIGNAL FE_pulse_local	: STD_LOGIC;

BEGIN
	
	PROCESS(RST, CLK)
		VARIABLE cntXms	: integer;
		VARIABLE multiSPEcnt_int	: STD_LOGIC_VECTOR (15 downto 0);
		VARIABLE oneSPEcnt_int		: STD_LOGIC_VECTOR (15 downto 0);
	BEGIN
		IF RST='1' THEN
			cntXms	:= 2000000;
			MultiSPE1	<= '1';
			OneSPE1		<= '1';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF cntXms = 0 THEN
				multiSPEcnt	<= multiSPEcnt_int;
				oneSPEcnt	<= oneSPEcnt_int;
				IF gatetime='0' THEN
					cntXms	:= 2000000;	-- 100ms
				ELSE
					cntXms	:= 200000;	-- 10ms
				END IF;
				multiSPEcnt_int	:= (others=>'0');
				oneSPEcnt_int	:= (others=>'0');
			ELSE
				cntXms	:= cntXms - 1;
				
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
		IF OneSPErst='1' THEN	--OneSPE1='1' THEN
			OneSPE_latch	<= '0';
		ELSIF OneSPE'EVENT AND OneSPE='1' THEN
			IF blank_disc='1' THEN
				OneSPE_latch	<= '0';
			ELSE
				OneSPE_latch	<= '1';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(MultiSPE,MultiSPE1)
	BEGIN
		IF MultiSPErst='1' THEN
			MultiSPE_latch	<= '0';
		ELSIF MultiSPE'EVENT AND MultiSPE='1' THEN
			IF blank_disc='1' THEN
				MultiSPE_latch	<= '0';
			ELSE
				MultiSPE_latch	<= '1';
			END IF;
		END IF;
	END PROCESS;
	
	OneSPEreset : PROCESS (CLK,RST)
		VARIABLE cnt	: STD_LOGIC_VECTOR (11 DOWNTO 0);
	BEGIN
		IF RST='1' THEN
			OneSPErst	<= '1';
			cnt			:= CONV_STD_LOGIC_VECTOR(1,12);
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF OneSPE_latch='1' THEN
				IF cnt(1+CONV_INTEGER(deadtime))='1' THEN
					OneSPErst	<= '1';
				ELSE
					OneSPErst	<= '0';
				END IF;
				cnt	:= cnt + 1;
			ELSE
				OneSPErst	<= '0';
				cnt			:= CONV_STD_LOGIC_VECTOR(1,12);
			END IF;
		END IF;
	END PROCESS;
	
	MultiSPEreset : PROCESS (CLK,RST)
		VARIABLE cnt	: STD_LOGIC_VECTOR (11 DOWNTO 0);
	BEGIN
		IF RST='1' THEN
			MultiSPErst	<= '1';
			cnt			:= CONV_STD_LOGIC_VECTOR(1,12);
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF MultiSPE_latch='1' THEN
				IF cnt(1+CONV_INTEGER(deadtime))='1' THEN
					MultiSPErst	<= '1';
				ELSE
					MultiSPErst	<= '0';
				END IF;
				cnt	:= cnt + 1;
			ELSE
				MultiSPErst	<= '0';
				cnt			:= CONV_STD_LOGIC_VECTOR(1,12);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (CLK,RST)
	BEGIN
		IF RST='1' THEN
			FE_pulse_local	<= '0';
		ELSIF CLK'EVENT and CLK='1' THEN
			FE_pulse_local	<= FE_pulse;
		END IF;
	END PROCESS;
	blank_disc <= '1' WHEN FE_pulse='1' and FE_pulse_local='0' ELSE '0';
END;