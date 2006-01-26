----------------------------------------------------------------------------
--File               : delta_encoder.vhd
--Author             : Nobuyoshi Kitamura
--Company            : IceCube
--Created            :
--Version			 : 0.02
--Last Update        : November 7, 2005
----------------------------------------------------------------------------
-- Ver 0.00		6/27/2005	Original version
-- Ver 0.01		10/13/2005	Incorporate the new bit_stuff, ver 0.04, which has a newly
--							defined output port 'channel_done'.  Added 'stuff_done'.
-- Ver 0.02		1/7/2005	(Simulation only:) Creates intermediate monitor files called
--							map_word_out.txt and delta_out.txt.
----------------------------------------------------------------------------
-- Encode a series of "deltas" of a given channel.
-- 
-- T1. 	(async reset) reset_channel <= '1', '0' after Tclk (mininum)
-- T2. 	if encoder_busy = '0' then
--			delta_in <= delta
--			convert	 <= '1'
--			if last_word_of_channel then
--				last_data <= '1'		-- Needed to flush the output buffer
--			else						-- (The unused bits of the last compressed
--				last_data <= '0'		-- word will be set to zero.)
--			end if
--			goto T3
--		else
--			goto T2
--		end if
-- T3.	convert <= '0'
--		if have_word = '1' then
--			get_word <= word_out			 -- 32-bit compressed word
--			if last_word_of_channel then
--				compressed_size <= count_out -- # of 32-bit words
--				goto T4
--			end if
--		end if
--		goto T2
-- T4	(done)


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;
use work.cw_data_types.all;

entity delta_encoder is
    Port ( 	clock           : in std_logic;
          	reset_channel   : in std_logic;
		   	convert			: in std_logic;
           	delta_in        : in signed(10 downto 0);
			last_data		: in std_logic;
           	word_out        : out word32;
			count_out		: out unsigned(8 downto 0);
			have_word		: out std_logic;
			encoder_busy	: out std_logic;
			stuff_done		: out std_logic;
			errors			: out std_logic_vector(7 downto 0)
		);
end delta_encoder;

architecture struct of delta_encoder is

	component map_word
	    port(   clock       : in std_logic;
	            reset       : in std_logic;
	            convert     : in std_logic;
	            delta       : in signed(10 downto 0);
				ready		: in std_logic;
				last_input	: in std_logic;
	            dout        : out std_logic_vector(10 downto 0);
	            BPS         : out unsigned(3 downto 0);
				wreq		: out std_logic;
				last_output	: out std_logic;
	            busy        : out std_logic		);
	end component;
	
	component bit_stuff
	    port ( DX           : in std_logic_vector(10 downto 0);
	           BPS          : in unsigned(3 downto 0);
	           wreq         : in std_logic;
	           clock        : in std_logic;
	           reset        : in std_logic;
			   word_ack		: in std_logic;
			   last_input   : in std_logic;
	           DY           : out word32;
	           busy         : out std_logic;
	           word_ready   : out std_logic;
			   channel_done : out std_logic		);
	end component;

	component word_counter
	    port ( 	clock		: in std_logic;
				reset		: in std_logic;
				word_ready	: in std_logic;
				word_ack	: out std_logic;
				count_out	: out unsigned(8 downto 0);
				word_in		: in word32;
				word_out	: out word32	);
	end component;

	signal	stuff_busy, word_ack, map_wreq, word_ready	: std_logic;
	signal  n_stuff_busy		: std_logic;
	signal  last_input			: std_logic;
	signal 	DX					: std_logic_vector(10 downto 0);
	signal 	BPS					: unsigned(3 downto 0);
	signal 	DY					: word32;

	signal sig_encoder_busy : std_logic;
begin

inst_map_word: map_word
	port map (	clock		=> clock,
				reset		=> reset_channel,
				convert		=> convert,
				delta		=> delta_in,
				ready		=> n_stuff_busy,
				last_input	=> last_data,
				last_output => last_input,
				wreq		=> map_wreq,
				dout		=> DX,
				BPS			=> BPS,
				busy		=> sig_encoder_busy		);
				
	errors <= (others => '0');
				
	n_stuff_busy <= '1' when stuff_busy = '0' else '0';
	encoder_busy <= sig_encoder_busy;
	
-- synthesis translate_off

	process
		use std.textio.all;
		variable LL, L: line;
		variable n : integer;
        file output_file : text open write_mode is "delta_out.txt";
	begin
			wait until rising_edge(clock);

			wait on convert;

			if convert = '1' then
                write(L, conv_integer(delta_in));
                writeline(output_file, L);
			end if;
			
			if last_input = '1' then
                write(L, string'("--- last_data ---"));
                writeline(output_file, L);
				file_close(output_file);
				wait;
			end if;

	end process;

	
	process
		use std.textio.all;
		variable LL, L: line;
		variable n : integer;
        file output_file : text open write_mode is "map_word_out.txt";
	begin
			wait until rising_edge(clock);
			wait on map_wreq;
			if map_wreq = '1' then ----<=================
				write(LL, string'("delta = "));
				write(LL, conv_integer(delta_in));
				write(LL, string'(" : "));
				write(LL, string'("map => "));
				write(LL, conv_integer(BPS));
				n := conv_integer(BPS);
				write(LL, string'(" : "));
				write(LL, to_bitvector(std_logic_vector(DX(n-1 downto 0))));
				writeline(output, LL);
			-- Write to the monitor file
                write(L, to_bitvector(std_logic_vector(DX(n-1 downto 0))));
                writeline(output_file, L);
			end if;
			
			if last_input = '1' then
                	write(L, string'("--- last_data ---"));
                	writeline(output_file, L);
				file_close(output_file);
				wait;
			end if;

	end process;
-- synthesis translate_on
	
inst_bit_stuff: bit_stuff
	port map (	clock		=> clock,
				reset		=> reset_channel,
				wreq		=> map_wreq,
				DX			=> DX,
				BPS			=> BPS,
				word_ack	=> word_ack,
				last_input  => last_input,
				word_ready	=> word_ready,
				channel_done => stuff_done,
				DY			=> DY,
				busy		=> stuff_busy		);
				
	word_out <= DY;

inst_word_counter: word_counter
	port map (	clock		=> clock,
				reset		=> reset_channel,
				word_ready	=> word_ready,
				word_in		=> DY,
				count_out	=> count_out,
				word_out	=> word_out,
				word_ack	=> word_ack		);
				
	have_word <= word_ack;


end struct;