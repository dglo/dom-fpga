-------------------------------------------------
--- simple transmitter for the communication DAC
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY com_DAC_TX IS
	PORT (
		CLK			: IN STD_LOGIC;
		CLK2x		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable for TX
		enable		: IN STD_LOGIC;
		enable_square	: IN STD_LOGIC;
		-- communications DAC connections
		COM_DAC_CLK		: OUT STD_LOGIC;
		COM_TX_SLEEP	: OUT STD_LOGIC;
		COM_DB			: OUT STD_LOGIC_VECTOR (13 downto 6);
		-- test connector
		TC					: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END com_DAC_TX;

ARCHITECTURE arch_com_DAC_TX OF com_DAC_TX IS
	
	TYPE STATE_TYPE IS (state0, state1, state2);
	SIGNAL state: STATE_TYPE;
	
BEGIN
	
	PROCESS(CLK2x,RST)
		VARIABLE toggle	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			COM_DAC_CLK <= '0';
			toggle		:= '0';
		ELSIF CLK2x'EVENT AND CLK2x='1' THEN
			toggle		:= NOT toggle;
			COM_DAC_CLK <= toggle;
		END IF;
	END PROCESS;
	

	PROCESS(CLK,RST)
		VARIABLE cnt	: STD_LOGIC_VECTOR (7 downto 0);
		VARIABLE up		: STD_LOGIC;
		VARIABLE wait_cnt	: STD_LOGIC_VECTOR (3 downto 0);
		VARIABLE wait_cnt_l	: STD_LOGIC_VECTOR (10 downto 0);
		VARIABLE normal	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			cnt	:= "10000000";
			COM_TX_SLEEP	<= '1';
			up	:= '0';
			state <= state1;
			normal	:= '0';
			wait_cnt := "1110";
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF enable='1' THEN
				COM_TX_SLEEP	<= '0';
				IF up='1' THEN	-- going UP
					IF cnt="11111111" THEN
						up := '0';
					ELSE
						cnt := cnt + 1;
					END IF;
				ELSE			-- going down
					IF cnt = "00000000" THEN
						up := '1';
					ELSE
						cnt := cnt - 1;
					END IF;
				END IF;
				COM_DB <= cnt;
			ELSIF enable_square='1' THEN
				COM_TX_SLEEP	<= '0';
				CASE state IS
					WHEN state1 =>
						IF normal='1' THEN
							COM_DB <= "11111111";
						ELSE
							COM_DB <= "00000001";
						END IF;
						IF wait_cnt = 0 THEN
							state <= state2;
							wait_cnt := "1110";
						ELSE
							wait_cnt := wait_cnt - 1;
						END IF;
					WHEN state2 =>
						IF normal='1' THEN
							COM_DB <= "00000001";
						ELSE
							COM_DB <= "11111111";
						END IF;
						IF wait_cnt = 0 THEN
							state <= state0;
							wait_cnt_l := "11111111110";
						ELSE
							wait_cnt := wait_cnt - 1;
						END IF;
					WHEN state0 =>
						COM_DB <= "10000000";
						IF wait_cnt_l = 0 THEN
							state <= state1;
							wait_cnt := "1110";
							normal := NOT normal;
						ELSE
							wait_cnt_l := wait_cnt_l - 1;
						END IF;
				END CASE;
			ELSE
				cnt	:= "10000000";
				COM_TX_SLEEP	<= '1';
				COM_DB <= cnt;
				state <= state1;
				wait_cnt := "1110";
			END IF;
		END IF;
	END PROCESS;

END;