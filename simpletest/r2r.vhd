---------------------------------------------------
--- simple transmitter for the ATWD MUX R2R ladder
---------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY r2r IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable for TX
		enable		: IN STD_LOGIC;
		-- communications DAC connections
		R2BUS		: OUT STD_LOGIC_VECTOR (6 downto 0);
		-- test connector
		TC			: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END r2r;

ARCHITECTURE arch_r2r OF r2r IS
	
BEGIN
	
	PROCESS(CLK,RST)
		VARIABLE cnt	: STD_LOGIC_VECTOR (6 downto 0);
		VARIABLE up		: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			cnt	:= "1000000";
			up	:= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF enable='1' THEN
				R2BUS <= cnt;
				IF up='1' THEN	-- going UP
					IF cnt="1111111" THEN
						up := '0';
					ELSE
						cnt := cnt + 1;
					END IF;
				ELSE			-- going down
					IF cnt = "0000000" THEN
						up := '1';
					ELSE
						cnt := cnt - 1;
					END IF;
				END IF;
			ELSE
				R2BUS <= cnt;
				cnt	:= "1000000";
			END IF;
		END IF;
	END PROCESS;

END;