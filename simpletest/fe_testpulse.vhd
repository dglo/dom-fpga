-------------------------------------------------
--- frontend test pulser
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY fe_testpulse IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable flasher
		enable		: IN STD_LOGIC;
		divider		: IN STD_LOGIC_VECTOR(3 downto 0);
		-- LED trigger
		FE_TEST_PULSE	: OUT STD_LOGIC
	);
END fe_testpulse;


ARCHITECTURE fe_test_pulsearch OF fe_testpulse IS

BEGIN

	PROCESS (RST,CLK)
		VARIABLE cnt		: STD_LOGIC_VECTOR(15 downto 0);
		VARIABLE cnt_o		: STD_LOGIC;
		VARIABLE cnt_oo		: STD_LOGIC;
		VARIABLE tick		: STD_LOGIC;
		VARIABLE tick_old	: STD_LOGIC;
		VARIABLE tick_old0	: STD_LOGIC;
		VARIABLE tick_old1	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			cnt			:= (others=>'0');
			cnt_o		:= '0';
			cnt_oo		:= '0';
			tick		:= '0';
			tick_old	:= '0';
			tick_old0	:= '0';
			tick_old1	:= '0';
			FE_TEST_PULSE	<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			tick		:= cnt_o XOR cnt_oo;
			cnt_oo		:= cnt_o;
	--		IF enable='1' THEN
				cnt_o		:= cnt(CONV_INTEGER(divider)+8);
	--		END IF;
			FE_TEST_PULSE	<= tick OR tick_old OR tick_old0 OR tick_old1;
			tick_old1	:= tick_old0;
			tick_old0	:= tick_old;
			tick_old	:= tick;
			IF enable='0' THEN
				null; --cnt	:= (others=>'0');
			ELSE
				cnt	:= cnt + 1;
			END IF;
		END IF;
	END PROCESS;

END;
