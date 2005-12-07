-------------------------------------------------------------------------------
--IceCube
--DOM Data Compression Submodule
--
--Author:   N. Kitamura
--Version:  0.00    8/1/2005
--File:     word_counter.vhd
--
--Notes:
--Counts the number of times word_ready goes high.  Also latch word_in
--whenever word_ready goes high.
-------------------------------------------------------------------------------
library IEEE, lpm;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.cw_data_types.all;


entity word_counter is
    port ( 	clock		: in std_logic;
			reset		: in std_logic;
			op_reset		: in std_logic;
			word_ready	: in std_logic;
			word_ack	: out std_logic;
			count_out	: out unsigned(8 downto 0);
			word_in		: in word32;
			word_out	: out word32	);
end word_counter;

architecture behave of word_counter is
	signal count	: unsigned(8 downto 0);
	signal word_was_ready : std_logic;
begin
	process (clock, reset,op_reset, word_ready)
--		use std.textio.all;
--		variable LL: line;
	begin
		if reset = '1' then
			count <= (others => '0');
			word_ack <= '0';
			word_was_ready <= '0';
		elsif clock'event and clock = '1' then
			if op_reset='1' then
				count <= (others => '0');
				word_ack <= '0';
				word_was_ready <= '0';
			else
			if word_ready = '1' and word_was_ready = '0' then
				word_out <= word_in;
				count <= count + 1;
				word_ack <= '1';
				word_was_ready <= '1';
--				write(LL, string'("word counter"));
--				writeline(output, LL);
			elsif word_ready = '1' and word_was_ready = '1' then
--				write(LL, string'("word counter (should be ingnored)"));
--				writeline(output, LL);
				null;
			else
				word_out <= (others => 'Z');
				word_ack <= '0';
				word_was_ready <= '0';
			end if;
			end if;
		end if;
	end process;
	
	count_out <= count;

end behave;
