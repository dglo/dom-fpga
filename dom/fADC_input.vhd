-------------------------------------------------
-- fADC input latch
-- central input latch for the fADC to ensure timing
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY fADC_input IS
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- fADC connections
		FLASH_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
		FLASH_AD_STBY	: OUT STD_LOGIC;
		FLASH_NCO		: IN STD_LOGIC;
		-- local fADC connection
		fADC_D			: OUT STD_LOGIC_VECTOR (9 downto 0);
		fADC_NCO		: OUT STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END fADC_input;

ARCHITECTURE fADC_input_arch OF fADC_input IS
BEGIN
	FLASH_AD_STBY <= '0';	-- fADC will be on all the time
	
	PROCESS (CLK40, RST)
	BEGIN
		IF RST='1' THEN
			fADC_D		<= (others=>'0');
			fADC_NCO	<= '0';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			fADC_D		<= FLASH_AD_D;
			fADC_NCO	<= FLASH_NCO;
		END IF;
	END PROCESS;
END fADC_input_arch;