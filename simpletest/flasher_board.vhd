-------------------------------------------
-- flasher board interface
-------------------------------------------

library IEEE;
USE IEEE.std_logic_1164.all;


ENTITY flasher_board IS
	PORT (
		-- control input
		fl_board			: IN STD_LOGIC_VECTOR(7 downto 0);
		-- flasher board
		FL_Trigger			: OUT STD_LOGIC;
		FL_Trigger_bar		: OUT STD_LOGIC;
		FL_ATTN				: OUT STD_LOGIC;
		FL_PRE_TRIG			: OUT STD_LOGIC;
		FL_TMS				: OUT STD_LOGIC;
		FL_TCK				: OUT STD_LOGIC;
		FL_TDI				: OUT STD_LOGIC;
		FL_TDO				: OUT STD_LOGIC;
		-- Test connector
		TC					: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END flasher_board;

ARCHITECTURE flasher_board_arch OF flasher_board IS
BEGIN
	FL_Trigger		<= fl_board(0);
	FL_Trigger_bar	<= NOT fl_board(0);
	FL_ATTN			<= fl_board(1);
	FL_PRE_TRIG		<= fl_board(2);
	
	FL_TMS			<= fl_board(4);
	FL_TCK			<= fl_board(5);
	FL_TDI			<= fl_board(6);
	FL_TDO			<= fl_board(7);
END flasher_board_arch;
