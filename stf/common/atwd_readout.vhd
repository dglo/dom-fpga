-------------------------------------------------
-- ATWD readout
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY atwd_readout IS
	PORT (
		CLK20		: IN STD_LOGIC;
		CLK40		: IN STD_LOGIC;
		CLK80		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- handshake to control
		start_readout	: IN STD_LOGIC;
		readout_done	: OUT STD_LOGIC;
		busy			: IN STD_LOGIC;
		-- ATWD
		ATWD_D			: IN STD_LOGIC_VECTOR(9 downto 0);
		ShiftClock		: OUT STD_LOGIC;
		-- signal to mem
		ATWD_D_gray		: OUT STD_LOGIC_VECTOR(9 downto 0);
		addr			: OUT STD_LOGIC_VECTOR(8 downto 0);
		data_valid		: OUT STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END atwd_readout;


ARCHITECTURE arch_atwd_readout OF atwd_readout IS
	
	TYPE state_type is (idle, readout_low, readout_high_read, readout_high, done, done_delay_1, done_delay_2);
	SIGNAL state	: state_type;
	
	SIGNAL divide_cnt	: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL rst_divide	: STD_LOGIC;
	SIGNAL readout_cnt	: INTEGER;
	SIGNAL addr_cnt		: STD_LOGIC_VECTOR(8 downto 0);
	
BEGIN
	
	addr <= addr_cnt;
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			state	<= idle;
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			CASE state IS
				WHEN idle =>
					IF start_readout='1' THEN
						state	<= readout_low;
					END IF;
					readout_done	<= '0';
					data_valid		<= '0';
					ShiftClock		<= '0';
					rst_divide		<= '1';
					readout_cnt		<= 0;
					IF busy='0' THEN
						addr_cnt	<= (others=>'1');	-- (-1)
					END IF;
				WHEN readout_low =>
					IF divide_cnt(1)='1' THEN
						state	<= readout_high_read;
					END IF;
					data_valid		<= '0';
					ShiftClock		<= '0';
					rst_divide		<= '0';
				WHEN readout_high_read =>
					state	<= readout_high;
					ATWD_D_gray	<= ATWD_D;
					readout_cnt	<= readout_cnt + 1;
					ShiftClock	<= '1';
					addr_cnt	<= addr_cnt + 1;
				WHEN readout_high =>
					IF divide_cnt(1)='0' THEN
						IF readout_cnt=128 THEN
							state	<= done;
						ELSE
							state	<= readout_low;
						END IF;
					END IF;
					data_valid	<= '1';
				WHEN done =>
					state	<= done_delay_1;
					data_valid		<= '0';
					ShiftClock		<= '0';
					readout_done	<= '1';
				WHEN done_delay_1 =>
					state	<= done_delay_2;
				WHEN done_delay_2 =>
					state	<= idle;
			END CASE;
		END IF;
	END PROCESS;
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			divide_cnt	<= "00";
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			IF rst_divide='1' THEN
				divide_cnt	<= "00";
			ELSE
				divide_cnt	<= divide_cnt + 1;
			END IF;
		END IF;
	END PROCESS;
	
END;
