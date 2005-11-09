-------------------------------------------------
-- ATWD trigger
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY atwd_trigger IS
	PORT (
		CLK20		: IN STD_LOGIC;
		CLK40		: IN STD_LOGIC;
		CLK80		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable
		enable		: IN STD_LOGIC;
		enable_disc	: IN STD_LOGIC;
		done		: OUT STD_LOGIC;
		-- controller
		busy		: IN STD_LOGIC;
		reset_trig	: IN STD_LOGIC;
		-- disc
		OneSPE		: IN STD_LOGIC;
		-- atwd
		ATWDTrigger			: OUT STD_LOGIC;
		TriggerComplete_in	: IN STD_LOGIC;
		TriggerComplete_out	: OUT STD_LOGIC;
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END atwd_trigger;


ARCHITECTURE arch_atwd_trigger OF atwd_trigger IS

	SIGNAL TriggerComplete_in_sync	: STD_LOGIC;
	SIGNAL TriggerComplete_in_0		: STD_LOGIC;
	SIGNAL enable_pos_edge			: STD_LOGIC;
	SIGNAL enable_old				: STD_LOGIC;
	
	----------------------
	-- ATWD disc launch --
	----------------------
	SIGNAL CLK			: STD_LOGIC;
	
	SIGNAL launch_mode		: STD_LOGIC_VECTOR (1 downto 0);
	CONSTANT TRIG_ENABLE	: STD_LOGIC_VECTOR (1 downto 0) := "00";
	CONSTANT TRIG_SET		: STD_LOGIC_VECTOR (1 downto 0) := "01";
	CONSTANT TRIG_RST		: STD_LOGIC_VECTOR (1 downto 0) := "10";
	
	SIGNAL trig_lut		: STD_LOGIC;
	SIGNAL enable_sig	: STD_LOGIC;
	SIGNAL set_sig		: STD_LOGIC;
	SIGNAL rst_sig		: STD_LOGIC;
	
	SIGNAL triggered		: STD_LOGIC;
	SIGNAL ATWDTrigger_sig	: STD_LOGIC;
	
	SIGNAL disc			: STD_LOGIC;
	SIGNAL discFF		: STD_LOGIC;
	
	SIGNAL rst_trg		: STD_LOGIC;
	SIGNAL force		: STD_LOGIC;
	
	SIGNAL enable_disc_pos_edge			: STD_LOGIC;
	SIGNAL enable_disc_old				: STD_LOGIC;
	SIGNAL enable_disc_sig				: STD_LOGIC;
			
BEGIN
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			done				<= '0';
	--		ATWDTrigger			<= '0';
			TriggerComplete_in_sync	<= '1';
			TriggerComplete_in_0	<= '1';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
	--		IF busy='0' AND TriggerComplete_in_sync='1' AND enable_pos_edge='1' THEN
	--			ATWDTrigger	<='1';
	--		END IF;
	--		IF reset_trig='1' THEN
	--			ATWDTrigger	<= '0';
	--		END IF;
			IF busy='0' AND (enable='1' OR (enable_disc='1' AND enable_disc_sig='0')) THEN
				done	<= '1';
			ELSE
				done	<= '0';
			END IF;
			
			TriggerComplete_in_sync <= TriggerComplete_in_0;
			TriggerComplete_in_0	<= TriggerComplete_in;
			enable_old				<= enable;
			enable_disc_old				<= enable_disc;
		END IF;
	END PROCESS;

	TriggerComplete_out	<= TriggerComplete_in_sync;
	enable_pos_edge		<= '1' WHEN enable='1' AND enable_old='0' ELSE '0';
	enable_disc_pos_edge		<= '1' WHEN enable_disc='1' AND enable_disc_old='0' ELSE '0';
	
	
	----------------------
	-- ATWD disc launch --
	----------------------
	CLK	<= CLK40;
	
	FF : PROCESS(OneSPE,rst_trg)
	BEGIN
		IF rst_trg='1' THEN
			discFF	<= '0';
		ELSIF OneSPE'EVENT AND OneSPE='1' THEN
			discFF	<= '1';
		END IF;
	END PROCESS;
	rst_trg <= NOT enable_disc;
	
	disc <= discFF;
	
	enable_sig	<= NOT busy AND enable_disc_sig;
	set_sig		<= triggered
				OR (force AND NOT busy);
	force	<= enable_pos_edge;
	rst_sig		<= reset_trig;
	
	launchmode : PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			launch_mode	<= TRIG_RST;
		ELSIF CLK'EVENT AND CLK='0' THEN
			IF rst_sig='1' THEN
				launch_mode	<= TRIG_RST;
			ELSIF set_sig='1' THEN
				launch_mode	<= TRIG_SET;
			ELSIF enable_sig='1' THEN
				launch_mode	<= TRIG_ENABLE;
			ELSE
				launch_mode	<= TRIG_RST;
			END IF;
		END IF;
	END PROCESS;
	
	trig_lut	<= disc WHEN launch_mode = TRIG_ENABLE ELSE
				'0' WHEN launch_mode = TRIG_RST ELSE
				'1' WHEN launch_mode = TRIG_SET ELSE
				'X';
	
	TriggerInput : PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			ATWDTrigger_sig <= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			ATWDTrigger_sig <= trig_lut;
		END IF;
	END PROCESS;
	ATWDTrigger	<= ATWDTrigger_sig;
	triggered	<= ATWDTrigger_sig;
	
	oneshot : PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			enable_disc_sig	<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF enable_disc_pos_edge='1' THEN
				enable_disc_sig	<= '1';
			ELSIF triggered='1' THEN
				enable_disc_sig	<= '0';
			END IF;
		END IF;
	END PROCESS;
	
END;