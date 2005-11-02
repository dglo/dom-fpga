-------------------------------------------------
-- ATWD trigger logic
-- 
-- This module launched the ATWDs and fADC capture
-- including ping/pong
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY trigger IS
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- enable
		-- handshake
		busy_A			: IN STD_LOGIC;
		busy_B			: IN STD_LOGIC;
		rst_trg_A		: IN STD_LOGIC;
		rst_trg_B		: IN STD_LOGIC;
		ATWDTrigger_sig_A	: OUT STD_LOGIC;
		ATWDTrigger_sig_B	: OUT STD_LOGIC;
		-- discriminator
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		MultiSPE_nl		: OUT STD_LOGIC;
		OneSPE_nl		: OUT STD_LOGIC;
		-- trigger outputs
		ATWDTrigger_A	: OUT STD_LOGIC;
		ATWDTrigger_B	: OUT STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END trigger;

ARCHITECTURE trigger_arch OF trigger IS
BEGIN

END trigger_arch;