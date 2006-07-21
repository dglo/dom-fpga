-------------------------------------------------------------------------
--	VHDL Code for IceCube
--
--	file        cw_data_types.vhd
--
-- 	date        June 15, 2005
-- 	last			July 24, 2005
-- 	author      Nobuyoshi Kitamura
-- 	company     IceCube
--
-- 	Description    
--	Data type definition for the loss-less compression module.
--  "cw" for Chris Wendt, who devised the lossless compression algorithm.
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- """synthesis library work"""
package cw_data_types is

	subtype word32 is std_logic_vector(31 downto 0);
	subtype delta_type is signed(10 downto 0);

	constant	COMPR_RAM_SIZE : natural := 512;

    constant   atwd_depth : integer := 128;
    constant   fadc_depth : integer := 256;
    constant   data_width : integer := 10;

end cw_data_types;
