-------------------------------------------------
-- memory interface
-- 
-- this module interfaces the SDRAM
-- it reads the data from the ATWDs/fADC,
-- formates it and writes it to ADRAM
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mem_interface IS
	PORT (
		CLK20			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END mem_interface;

ARCHITECTURE mem_interface_arch OF mem_interface IS
BEGIN

END mem_interface_arch;