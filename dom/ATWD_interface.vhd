-------------------------------------------------
-- ATWD interface
-- 
-- this module interfaces the ATWD
-- and provides the waveform data in binary
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY ATWD_interface IS
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END ATWD_interface;

ARCHITECTURE ATWD_interface_arch OF ATWD_interface IS
BEGIN

END ATWD_interface_arch;