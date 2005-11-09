-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : hit_counter.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module is a hitrate counter for the discriminator. This
--              module utilizes the latch of the discriminator
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

ENTITY hit_counter IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- setup
		gatetime	: IN STD_LOGIC := '0';
		deadtime	: IN STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
		-- discriminator input
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		-- discriminator reset
		MultiSPE_nl		: OUT STD_LOGIC;
		OneSPE_nl		: OUT STD_LOGIC;
		-- output
		multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END hit_counter;

ARCHITECTURE arch_hit_counter OF hit_counter IS
	
	SIGNAL MultiSPE0	: STD_LOGIC;
	SIGNAL MultiSPE1	: STD_LOGIC;
	SIGNAL MultiSPE2	: STD_LOGIC;
	SIGNAL MultiSPErst	: STD_LOGIC;
	SIGNAL OneSPE0		: STD_LOGIC;
	SIGNAL OneSPE1		: STD_LOGIC;
	SIGNAL OneSPE2		: STD_LOGIC;
	SIGNAL OneSPErst	: STD_LOGIC;
	
BEGIN
	
	PROCESS(RST, CLK)
		VARIABLE cntXms	: integer;
		VARIABLE multiSPEcnt_int	: STD_LOGIC_VECTOR (15 downto 0);
		VARIABLE oneSPEcnt_int		: STD_LOGIC_VECTOR (15 downto 0);
	BEGIN
		IF RST='1' THEN
			cntXms	:= 2000000;
			MultiSPE_nl	<= '1';
			OneSPE_nl	<= '1';
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
			
			IF MultiSPE1='1' THEN
				MultiSPE_nl	<= '1';
			ELSE
				MultiSPE_nl	<= '0';
			END IF;
			IF OneSPE1='1' THEN
				OneSPE_nl	<= '1';
			ELSE
				OneSPE_nl	<= '0';
			END IF;
			
			MultiSPE2	<= MultiSPE1;
			MultiSPE1	<= MultiSPE0;
			MultiSPE0	<= MultiSPE;
			OneSPE2		<= OneSPE1;
			OneSPE1		<= OneSPE0;
			OneSPE0		<= OneSPE;
		END IF;
	END PROCESS;
	
	OneSPEreset : PROCESS (CLK,RST)
		VARIABLE cnt	: STD_LOGIC_VECTOR (11 DOWNTO 0);
	BEGIN
		IF RST='1' THEN
			OneSPErst	<= '1';
			cnt			:= CONV_STD_LOGIC_VECTOR(1,12);
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF OneSPE='1' THEN
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
			IF MultiSPE='1' THEN
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
	
END;