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
		done		: OUT STD_LOGIC;
		-- controller
		busy		: IN STD_LOGIC;
		reset_trig	: IN STD_LOGIC;
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
			
BEGIN
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			done				<= '0';
			ATWDTrigger			<= '0';
			TriggerComplete_in_sync	<= '1';
			TriggerComplete_in_0	<= '1';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			IF busy='0' AND TriggerComplete_in_sync='1' AND enable_pos_edge='1' THEN
				ATWDTrigger	<='1';
			END IF;
			IF reset_trig='1' THEN
				ATWDTrigger	<= '0';
			END IF;
			IF busy='0' AND enable='1' THEN
				done	<= '1';
			ELSE
				done	<= '0';
			END IF;
			
			TriggerComplete_in_sync <= TriggerComplete_in_0;
			TriggerComplete_in_0	<= TriggerComplete_in;
			enable_old				<= enable;
		END IF;
	END PROCESS;

	TriggerComplete_out	<= TriggerComplete_in_sync;
	enable_pos_edge		<= '1' WHEN enable='1' AND enable_old='0' ELSE '0';
	
END;