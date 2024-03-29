-------------------------------------------------
--- SingleLED flasher
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY single_led IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable flasher
		enable		: IN STD_LOGIC;
		-- LED trigger
		SingleLED_TRIGGER	: OUT STD_LOGIC
	);
END single_led;


ARCHITECTURE single_led_arch OF single_led IS

BEGIN

	PROCESS (RST,CLK)
		VARIABLE cnt		: STD_LOGIC_VECTOR(13 downto 0);
		VARIABLE cnt_old	: STD_LOGIC_VECTOR(13 downto 0);
		VARIABLE tick		: STD_LOGIC;
		VARIABLE tick_old	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			cnt			:= (others=>'0');
			cnt_old		:= (others=>'0');
			tick		:= '0';
			tick_old	:= '0';
			SingleLED_TRIGGER	<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			tick_old	:= tick;
			tick		:= cnt(10) XOR cnt_old(10);
			cnt_old		:= cnt;
			SingleLED_TRIGGER	<= tick OR tick_old;
			IF enable='0' THEN
				cnt	:= (others=>'0');
			ELSE
				cnt	:= cnt + 1;
			END IF;
		END IF;
	END PROCESS;

END;
