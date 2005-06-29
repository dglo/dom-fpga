-------------------------------------------------
--- RS486 tranceiver
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY rs486 IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- control
		enable		: IN STD_LOGIC;
		-- manual control
		rs486_ena	: IN STD_LOGIC_VECTOR(1 downto 0);
		rs486_tx	: IN STD_LOGIC;
		rs486_rx	: OUT STD_LOGIC;
		-- Communications RS485
		HDV_Rx		: IN STD_LOGIC;
		HDV_RxENA	: OUT STD_LOGIC;
		HDV_TxENA	: OUT STD_LOGIC;
		HDV_IN		: OUT STD_LOGIC;
		-- test connector
		TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END rs486;



ARCHITECTURE arch_rs486 OF rs486 IS

	TYPE STATE_TYPE IS (POS, NEG ,IDLE);
	SIGNAL state	: STATE_TYPE;
	SIGNAL count	: INTEGER;
	SIGNAL pulse	: STD_LOGIC;

BEGIN
	
	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			HDV_RxENA	<= '0';
			HDV_TxENA	<= '0';
			HDV_IN		<= '0';
			rs486_rx	<= '0';
			state		<= POS;
			count		<= 4;
			pulse		<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF enable='1' THEN
				CASE state IS
					WHEN POS =>
						HDV_TxENA	<= '1';
						HDV_IN		<= pulse;
						IF COUNT=0 THEN
							state		<= NEG;
							count		<= 4;
						ELSE
							count <= count - 1;
						END IF;
					WHEN NEG =>
						HDV_TxENA	<= '1';
						HDV_IN		<= NOT pulse;
						IF COUNT=0 THEN
							state		<= IDLE;
							count		<= 2000;
						ELSE
							count <= count - 1;
						END IF;
					WHEN IDLE =>
						HDV_TxENA	<= '0';
						IF COUNT=0 THEN
							state		<= POS;
							count		<= 4;
							pulse		<= NOT pulse;
						ELSE
							count <= count - 1;
						END IF;
				END CASE;		
			ELSE
				HDV_RxENA	<= rs486_ena(0);
				HDV_TxENA	<= rs486_ena(1);
				HDV_IN		<= rs486_tx;
				rs486_rx	<= HDV_Rx;
			END IF;
		END IF;
	END PROCESS;
	
END;
