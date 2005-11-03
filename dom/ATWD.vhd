-------------------------------------------------
-- ATWD
-- 
-- this module collects the ATWD and fADC data
-- and stores it in local memory
-- it have the over all contoll about everything
-- related to a signle ATWD
-- data compression will be located in this module
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY ATWD IS
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END ATWD;

ARCHITECTURE ATWD_arch OF ATWD IS
BEGIN

END ATWD_arch;