-------------------------------------------------
-- daq
-- 
-- this module collects the ATWD and fADC data
-- and writes id to the SDRAM
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY daq IS
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END daq;

ARCHITECTURE daq_arch OF daq IS
BEGIN

END daq_arch;