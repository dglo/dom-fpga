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

	SIGNAL launch_mode_A	: STD_LOGIC_VECTOR (1 downto 0);
	SIGNAL launch_mode_A	: STD_LOGIC_VECTOR (1 downto 0);
	CONSTANT TRIG_ENABLE_SPE	: STD_LOGIC_VECTOR (1 downto 0) := "00";
	CONSTANT TRIG_ENABLE_MPE	: STD_LOGIC_VECTOR (1 downto 0) := "11";
	CONSTANT TRIG_SET		: STD_LOGIC_VECTOR (1 downto 0) := "01";
	CONSTANT TRIG_RST		: STD_LOGIC_VECTOR (1 downto 0) := "10";

BEGIN

	-- Discriminator latch FFs
	disc_FF_SPE : PROCESS(OneSPE,rst_trigger_spe)
	BEGIN
		IF rst_trigger_spe = '1' THEN
			discSPE	<= '0';
		ELSIF OneSPE'EVENT AND OneSPE='1' THEN
			discSPE	<= '1';
		END IF;
	END PROCESS;
	
	disc_FF_SPE_reset : PROCESS(RST,CLK40)
	BEGIN
		IF RST='1' THEN
			discSPE_latch	<= '0';
			discSPE_pulse	<= '1';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			discSPE_latch	<= discSPE;
			discSPE_pulse	<= discSPE_latch AND NOT rst_trigger_spe;
		END IF;
	END PROCESS;
	rst_trigger_spe	<= discSPE_pulse;
	
	disc_FF_SPE : PROCESS(OneSPE,rst_trigger_spe)
	BEGIN
		IF rst_trigger_spe = '1' THEN
			discSPE	<= '0';
		ELSIF OneSPE'EVENT AND OneSPE='1' THEN
			discSPE	<= '1';
		END IF;
	END PROCESS;
	
	disc_FF_MPE_reset : PROCESS(RST,CLK40)
	BEGIN
		IF RST='1' THEN
			discMPE_latch	<= '0';
			discMPE_pulse	<= '1';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			discMPE_latch	<= discMPE;
			discMPE_pulse	<= discMPE_latch AND NOT rst_trigger_mpe;
		END IF;
	END PROCESS;
	rst_trigger_mpe	<= discMPE_pulse;
	
	
	-- Launchmode
	enable_spe_sig_A	<= launch_enable_A AND SPE_discriminator;
	enable_mpe_sig_A	<= launch_enable_A AND NOT SPE_discriminator;
	set_sig_A	<= triggered_A
				OR (force_sig AND launch_enable_A);
	rst_sig		<= reset_trigger_A;
	
	enable_spe_sig_B	<= launch_enable_B AND SPE_discriminator;
	enable_mpe_sig_B	<= launch_enable_B AND NOT SPE_discriminator;
	set_sig_B	<= triggered_A
				OR (force_sig AND launch_enable_B);
	rst_sig		<= reset_trigger_B;

	force_sig	<= 1 WHEN ((cs_trigger AND trigger_enable(7 DOWNTO 2)) >= 1)
				OR ((lc_trigger AND trigger_enable(9 DOWNTO 8)) >= 1)
				ELSE 0;
	
	-- LUT before ATWD Launch FF
	trig_lut_A	<= disc_SPE WHEN launch_mode_A = TRIG_ENABLE_SPE ELSE
				disc_MPE WHEN launch_mode_A = TRIG_ENABLE_MPE ELSE
				'0' WHEN launch_mode_A = TRIG_RST ELSE
				'1' WHEN launch_mode_A = TRIG_SET ELSE
				'X';
				
	trig_lut_B	<= discSPE WHEN launch_mode_B = TRIG_ENABLE_SPE ELSE
				discMPE WHEN launch_mode_B = TRIG_ENABLE_MPE ELSE
				'0' WHEN launch_mode_B = TRIG_RST ELSE
				'1' WHEN launch_mode_B = TRIG_SET ELSE
				'X';
		
	-- ATWD Launch FF
	ATWD_TriggerInput_A : PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			ATWDTrigger_A_sig <= '0';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			ATWDTrigger_A_sig <= trig_lut_A;
		END IF;
	END PROCESS;
	ATWDTrigger_A	<= ATWDTrigger_A_sig;
	triggered_A		<= ATWDTrigger_A_sig;
	
	ATWD_TriggerInput_B : PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			ATWDTrigger_B_sig <= '0';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			ATWDTrigger_B_sig <= trig_lut_B;
		END IF;
	END PROCESS;
	ATWDTrigger_B	<= ATWDTrigger_B_sig;
	triggered_B		<= ATWDTrigger_B_sig;

END trigger_arch;