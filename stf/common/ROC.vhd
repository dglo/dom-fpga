-------------------------------------------------
--- generate reset pulse
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY ROC IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: OUT STD_LOGIC
	);
END ROC;

ARCHITECTURE arch_ROC OF ROC IS

	TYPE STATE_TYPE IS (RST0, RST1, RUN);
	SIGNAL RST_state : STATE_TYPE;
	
BEGIN

	PROCESS(CLK)
	BEGIN
		IF CLK'EVENT AND CLK='1' THEN
			CASE RST_state IS
				WHEN RST0 =>
					RST <= '1';
					RST_state <= RST1;
				WHEN RST1 =>
					RST <= '1';
					RST_state <= RUN;
				WHEN RUN =>
					RST <= '0';
					RST_state <= RUN;
			END CASE;
		END IF;
	END PROCESS;

END;