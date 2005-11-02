---------------------------------------------------
--- simple transmitter for the frontend dual R2R ladder
---------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY fe_r2r IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable for TX
		enable		: IN STD_LOGIC;
		-- communications DAC connections
		FE_PULSER_P		: OUT STD_LOGIC_VECTOR (3 downto 0);
		FE_PULSER_N		: OUT STD_LOGIC_VECTOR (3 downto 0);
		-- test connector
		TC			: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END fe_r2r;

ARCHITECTURE arch_fe_r2r OF fe_r2r IS

	TYPE STATE_TYPE IS (pup, pdown, nup, ndown);
	SIGNAL state: STATE_TYPE;
	
BEGIN
	
	PROCESS(CLK,RST)
		VARIABLE cntp	: STD_LOGIC_VECTOR (3 downto 0);
		VARIABLE cntn	: STD_LOGIC_VECTOR (3 downto 0);
	BEGIN
		IF RST='1' THEN
			cntp	:= "0000";
			cntn	:= "0000";
			state	<= pup;
		ELSIF CLK'EVENT AND CLK='1' THEN
			FE_PULSER_P	<= cntp;
			FE_PULSER_N	<= cntn;
			IF enable='1' THEN
				CASE state IS
					WHEN pup =>
						IF cntp="1111" THEN
							state	<= pdown;
						ELSE
							cntp := cntp + 1;
						END IF;
					WHEN pdown =>
						IF cntp="0000" THEN
							state	<= nup;
						ELSE
							cntp := cntp - 1;
						END IF;
					WHEN nup =>
						IF cntn="1111" THEN
							state	<= ndown;
						ELSE
							cntn := cntn + 1;
						END IF;
					WHEN ndown =>
						IF cntn="0000" THEN
							state	<= pup;
						ELSE
							cntn := cntn - 1;
						END IF;
				END CASE;
			ELSE
				cntp	:= "0000";
				cntn	:= "0000";
				state	<= pup;
			END IF;
			
		END IF;
	END PROCESS;

END;